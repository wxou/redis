package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Benefit;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IBenefitService extends IService<Benefit> {

    ApiResult queryBenefitsOfMerchant(Long merchantId);

    void addLimitedBenefit(Benefit benefit);
}
