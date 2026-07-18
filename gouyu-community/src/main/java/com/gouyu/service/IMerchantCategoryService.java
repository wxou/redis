package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.MerchantCategory;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IMerchantCategoryService extends IService<MerchantCategory> {

    /**
     * 查询所有商户分类
     * @return 商户分类列表
     */
    ApiResult queryCategoryList();
}
