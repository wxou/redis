package com.gouyu.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.BooleanUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.CursorPageResult;
import com.gouyu.dto.MemberDTO;
import com.gouyu.entity.Post;
import com.gouyu.entity.FollowRelation;
import com.gouyu.entity.Member;
import com.gouyu.mapper.PostMapper;
import com.gouyu.service.IPostService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.service.IFollowRelationService;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.RedisKeys;
import com.gouyu.utils.GouYuConstants;
import com.gouyu.utils.MemberContext;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * <p>
 * 服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Service
public class PostServiceImpl extends ServiceImpl<PostMapper, Post> implements IPostService {

    @Resource
    private IMemberService memberService;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private IFollowRelationService followService;

    @Override
    public ApiResult queryHotPosts(Integer current) {
        // 根据成员查询
        Page<Post> page = query()
                .orderByDesc("like_count")
                .page(new Page<>(current, GouYuConstants.MAX_PAGE_SIZE));
        // 获取当前页数据
        List<Post> records = page.getRecords();
        // 查询成员
        records.forEach(post -> {
            this.populatePostMember(post);
            this.markLikeStatus(post);
        });
        return ApiResult.ok(records);
    }

    @Override
    public ApiResult queryPostById(Long id) {
        //1. 查询post
        Post post = getById(id);
        if (post == null) {
            return ApiResult.fail("动态不存在！");
        }
        //2. 查询post有关的成员
        populatePostMember(post);
        // 3. 查询post是否被点赞
        markLikeStatus(post);
        return ApiResult.ok(post);
    }

    private void markLikeStatus(Post post) {
        //1. 获取登录成员
        MemberDTO member = MemberContext.getMember();
        if (member == null) {
            // 成员未登录，无需查询是否点赞
            return;
        }
        Long memberId = member.getId();
        //2. 判断当前登录成员是否已经点赞
        String key = RedisKeys.POST_LIKED_KEY + post.getId();
        Double score = stringRedisTemplate.opsForZSet().score(key, memberId.toString());
        post.setLikedByCurrentMember(score != null);
    }

    @Override
    public ApiResult likePost(Long id) {
        //1. 获取登录成员
        Long memberId = MemberContext.getMember().getId();
        //2. 判断当前登录成员是否已经点赞
        String key = RedisKeys.POST_LIKED_KEY + id;
        Double score = stringRedisTemplate.opsForZSet().score(key, memberId.toString());
        if (score == null) {
            //3. 如果未点赞，可以点赞
            //3.1 数据库点赞数 + 1
            boolean isSuccess = update().setSql("like_count = like_count + 1").eq("id", id).update();
            //3.2 保存成员到Redis的set集合  zadd key value score
            if (isSuccess) {
                stringRedisTemplate.opsForZSet().add(key, memberId.toString(), System.currentTimeMillis());
            }
        }else{
            //4. 如果已点赞，取消点赞
            //4.1 数据库点赞数 - 1
            boolean isSuccess = update().setSql("like_count = like_count - 1").eq("id", id).update();
            //4.2 把成员从Redis的set集合中移除
            stringRedisTemplate.opsForZSet().remove(key, memberId.toString());
        }

        return ApiResult.ok();
    }

    @Override
    public ApiResult queryPostLikes(Long id) {
        String key = RedisKeys.POST_LIKED_KEY + id;
        // 1. 查询top5的点赞成员 zrange key 0 4
        Set<String> top5 = stringRedisTemplate.opsForZSet().range(key , 0, 4);
        if (top5 == null || top5.isEmpty()) {
            return ApiResult.ok();
        }
        // 2. 解析出其中的成员id
        List<Long> ids = top5.stream().map(Long::valueOf).collect(Collectors.toList());
        String idStr = StrUtil.join(",", ids);
        // 3. 根据成员id查询成员 WHERE id IN ( 5, 1 ) ORDER BY field(id,5,1)
        List<MemberDTO> memberDTOS = memberService.query()
                .in("id", ids).last("ORDER BY FIELD(id, " + idStr + ")").list()
                .stream()
                .map(member -> BeanUtil.copyProperties(member, MemberDTO.class))
                .collect(Collectors.toList());
        // 4. 返回
        return ApiResult.ok(memberDTOS);
    }

    @Override
    public ApiResult savePost(Post post) {
        // 1. 获取登录成员
        MemberDTO member = MemberContext.getMember();
        post.setMemberId(member.getId());
        // 2. 保存社区动态博文
        boolean isSuccess = save(post);
        if (!isSuccess){
            return ApiResult.fail("新增动态失败！");
        }
        // 3. 查询动态作者的所有粉丝   select * from gy_follow_relation where target_member_id = ?
        List<FollowRelation> followRelationRelations = followService.query().eq("target_member_id", member.getId()).list();
        // 4. 推送动态id给所有粉丝
        for (FollowRelation followRelation : followRelationRelations) {
            // 4.1 获取粉丝id
            Long memberId = followRelation.getMemberId();
            // 4.2 推送
            String key = RedisKeys.FEED_KEY + memberId;
            stringRedisTemplate.opsForZSet().add(key, post.getId().toString(), System.currentTimeMillis());
        }
        // 5. 返回id
        return ApiResult.ok(post.getId());
    }

    @Override
    public ApiResult queryFollowRelationFeed(Long max, Integer offset) {
        // 1. 获取当前成员
        Long memberId = MemberContext.getMember().getId();
        // 2. 查询收件箱  ZREVRANGEBYSCORE key Max Min LIMIT offset count
        String key = RedisKeys.FEED_KEY + memberId;
        Set<ZSetOperations.TypedTuple<String>> typedTuples = stringRedisTemplate.opsForZSet()
                .reverseRangeByScoreWithScores(key, 0, max, offset, 2);
        // 3. 非空判断
        if (typedTuples == null || typedTuples.isEmpty()) {
            return ApiResult.ok();
        }
        // 4. 解析数据：postId、minTime（时间戳）、offset
        List<Long> ids = new ArrayList<>(typedTuples.size());
        long minTime = 0;
        int os = 1;
        for (ZSetOperations.TypedTuple<String> tuple : typedTuples) {
            // 4.1 获取id
            ids.add(Long.valueOf(tuple.getValue()));
            // 4.2 获取分数(时间戳)
            long time = tuple.getScore().longValue();
            if (time == minTime){
                os++;
            }else{
                minTime = time;
                os = 1;
            }
        }

        // 5. 根据id查询post
        String idStr = StrUtil.join(",", ids);
        List<Post> posts = query().in("id", ids).last("ORDER BY FIELD(id," + idStr + ")").list();

        for (Post post : posts) {
            // 5.1 查询post有关的成员
            populatePostMember(post);
            // 5.2 查询post是否被点赞
            markLikeStatus(post);
        }

        // 6. 封装并返回
        CursorPageResult r = new CursorPageResult();
        r.setList(posts);
        r.setOffset(os);
        r.setMinTime(minTime);

        return ApiResult.ok(r);
    }

    private void populatePostMember(Post post) {
        Long memberId = post.getMemberId();
        Member member = memberService.getById(memberId);
        post.setAuthorName(member.getDisplayName());
        post.setAuthorAvatarUrl(member.getAvatarUrl());
    }
}
