package com.gouyu.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.MemberDTO;
import com.gouyu.entity.FollowRelation;
import com.gouyu.mapper.FollowRelationMapper;
import com.gouyu.service.IFollowRelationService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.MemberContext;
import com.gouyu.utils.RedisKeys;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Collections;
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
public class FollowRelationServiceImpl extends ServiceImpl<FollowRelationMapper, FollowRelation> implements IFollowRelationService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private IMemberService memberService;

    @Override
    public ApiResult follow(Long targetMemberId, Boolean isFollowing) {
        // 1. 获取当前成员
        Long memberId = MemberContext.getMember().getId();
        String key = RedisKeys.FOLLOWING_KEY + memberId;
        // 2. 判断是关注还是取关
        if (isFollowing) {
            // 3. 关注，新增数据
            FollowRelation followRelation = new FollowRelation();
            followRelation.setMemberId(memberId);
            followRelation.setTargetMemberId(targetMemberId);
            boolean isSuccess = save(followRelation);
            if (isSuccess){
                //把关注成员的id，放入redis的set集合    sadd memberId targetMemberId
                stringRedisTemplate.opsForSet().add(key, targetMemberId.toString());
            }
        } else {
            // 4. 取关，删除数据 delete from gy_follow_relation where member_id = ? and target_member_id = ?
            boolean isSuccess = remove(new QueryWrapper<FollowRelation>()
                    .eq("member_id", memberId).eq("target_member_id", targetMemberId));
            if (isSuccess) {
                // 把关注成员的id从Redis集合中移除
                stringRedisTemplate.opsForSet().remove(key , targetMemberId.toString());
            }
        }
        return ApiResult.ok();
    }

    @Override
    public ApiResult isFollowing(Long targetMemberId) {
        // 1. 获取当前成员
        Long memberId = MemberContext.getMember().getId();
        // 2. 查询是否关注 select count(*) from gy_follow_relation where member_id = ? and target_member_id = ?
        Integer count = query().eq("member_id", memberId).eq("target_member_id", targetMemberId).count();
        // 3. 判断
        return ApiResult.ok(count > 0);
    }


    @Override
    public ApiResult commonFollows(Long id) {
        // 1. 获取当前成员
        Long memberId = MemberContext.getMember().getId();
        String key = RedisKeys.FOLLOWING_KEY + memberId;
        // 2. 求交集
        String key2 = RedisKeys.FOLLOWING_KEY + id;
        Set<String> intersect = stringRedisTemplate.opsForSet().intersect(key, key2);
        if (intersect == null || intersect.isEmpty()){
            // 无交集
            return ApiResult.ok(Collections.emptyList());
        }
        // 3. 解析id集合
        List<Long> ids = intersect.stream().map(Long::valueOf).collect(Collectors.toList());
        // 4. 查询成员
        List<MemberDTO> members = memberService.listByIds(ids)
                .stream()
                .map(member -> BeanUtil.copyProperties(member, MemberDTO.class))
                .collect(Collectors.toList());
        return ApiResult.ok(members);
    }
}
