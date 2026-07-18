package com.gouyu.controller;


import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.MemberDTO;
import com.gouyu.entity.Post;
import com.gouyu.entity.Member;
import com.gouyu.service.IPostService;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.GouYuConstants;
import com.gouyu.utils.MemberContext;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@RestController
@RequestMapping("/post")
public class PostController {

    @Resource
    private IPostService postService;


    @PostMapping
    public ApiResult savePost(@RequestBody Post post) {
        return postService.savePost(post);
    }

    @PutMapping("/like/{id}")
    public ApiResult likePost(@PathVariable("id") Long id) {
        return postService.likePost(id);
    }

    @GetMapping("/of/me")
    public ApiResult queryMyPosts(@RequestParam(value = "current", defaultValue = "1") Integer current) {
        // 获取登录成员
        MemberDTO member = MemberContext.getMember();
        // 根据成员查询
        Page<Post> page = postService.query()
                .eq("member_id", member.getId()).page(new Page<>(current, GouYuConstants.MAX_PAGE_SIZE));
        // 获取当前页数据
        List<Post> records = page.getRecords();
        return ApiResult.ok(records);
    }

    @GetMapping("/hot")
    public ApiResult queryHotPosts(@RequestParam(value = "current", defaultValue = "1") Integer current) {
        return postService.queryHotPosts(current);
    }

    @GetMapping("/{id}")
    public ApiResult queryPostById(@PathVariable("id") Long id) {
        return postService.queryPostById(id);
    }

    @GetMapping("/likes/{id}")
    public ApiResult queryPostLikes(@PathVariable("id") Long id) {
        return postService.queryPostLikes(id);
    }

    @GetMapping("/of/member")
    public ApiResult queryPostsByMember(
            @RequestParam(value = "current", defaultValue = "1") Integer current,
            @RequestParam("id") Long id) {
        // 根据成员查询
        Page<Post> page = postService.query()
                .eq("member_id", id).page(new Page<>(current, GouYuConstants.MAX_PAGE_SIZE));
        // 获取当前页数据
        List<Post> records = page.getRecords();
        return ApiResult.ok(records);
    }

    @GetMapping("/of/follow")
    public ApiResult queryFollowRelationFeed(
            @RequestParam("lastId") Long max, @RequestParam(value = "offset", defaultValue = "0") Integer offset){
        return postService.queryFollowRelationFeed(max, offset);
    }


}
