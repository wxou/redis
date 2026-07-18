package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Post;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IPostService extends IService<Post> {

    ApiResult queryHotPosts(Integer current);

    ApiResult queryPostById(Long id);

    ApiResult likePost(Long id);

    ApiResult queryPostLikes(Long id);

    ApiResult savePost(Post post);

    ApiResult queryFollowRelationFeed(Long max, Integer offset);
}
