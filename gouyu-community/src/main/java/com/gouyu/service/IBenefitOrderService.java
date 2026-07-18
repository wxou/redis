package com.gouyu.service;

import com.gouyu.dto.ApiResult;
import com.gouyu.entity.BenefitOrder;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IBenefitOrderService extends IService<BenefitOrder> {

    /**
     * 限时权益权益
     * @param benefitId 权益id
     * @return 权益记录id
     */
    ApiResult claimLimitedBenefit(Long benefitId);

    void createBenefitOrder(BenefitOrder benefitOrder);
}
