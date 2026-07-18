package com.gouyu.controller;


import com.gouyu.dto.ApiResult;
import com.gouyu.service.IFollowRelationService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@RestController
@RequestMapping("/follow")
public class FollowRelationController {

    @Resource
    private IFollowRelationService followService;

    @PutMapping("/{id}/{isFollowing}")
    public ApiResult follow(@PathVariable("id") Long targetMemberId, @PathVariable("isFollowing") Boolean isFollowing) {
        return followService.follow(targetMemberId, isFollowing);
    }

    @GetMapping("/or/not/{id}")
    public ApiResult isFollowing(@PathVariable("id") Long targetMemberId) {
        return followService.isFollowing(targetMemberId);
    }

    @GetMapping("/common/{id}")
    public ApiResult commonFollows(@PathVariable("id") Long id) {
        return followService.commonFollows(id);
    }
}
