package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Merchant;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IMerchantService extends IService<Merchant> {

    /**
     * 根据id查询商户信息
     * @param id 商户id
     * @return 商户详情数据
     */
    ApiResult queryById(Long id);

    /**
     * 更新商户信息
     * @param merchant 商户数据
     * @return
     */
    ApiResult update(Merchant merchant);

    ApiResult queryMerchantByCategory(Integer categoryId, Integer current, Double x, Double y);
}
