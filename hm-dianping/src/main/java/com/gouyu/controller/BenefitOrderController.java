package com.gouyu.controller;


import com.gouyu.dto.ApiResult;
import com.gouyu.service.IBenefitOrderService;
import com.gouyu.service.impl.BenefitOrderServiceImpl;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
@RequestMapping("/benefit-order")
public class BenefitOrderController {

    @Resource
    private IBenefitOrderService benefitOrderService;

    /**
     * 限时权益权益
     * @param benefitId 权益id
     * @return 权益记录id
     */
    @PostMapping("limited/{id}")
    public ApiResult claimLimitedBenefit(@PathVariable("id") Long benefitId) {
        return benefitOrderService.claimLimitedBenefit(benefitId);
    }
}
