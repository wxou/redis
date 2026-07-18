package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.FollowRelation;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IFollowRelationService extends IService<FollowRelation> {

    ApiResult follow(Long targetMemberId, Boolean isFollowing);

    ApiResult isFollowing(Long targetMemberId);

    ApiResult commonFollows(Long id);
}
