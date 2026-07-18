package com.gouyu.controller;


import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Benefit;
import com.gouyu.service.IBenefitService;
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
@RequestMapping("/benefit")
public class BenefitController {

    @Resource
    private IBenefitService benefitService;

    /**
     * 新增普通券
     * @param benefit 权益信息
     * @return 权益id
     */
    @PostMapping
    public ApiResult addBenefit(@RequestBody Benefit benefit) {
        benefitService.save(benefit);
        return ApiResult.ok(benefit.getId());
    }

    /**
     * 新增限时权益券
     * @param benefit 权益信息，包含限时权益信息
     * @return 权益id
     */
    @PostMapping("limited")
    public ApiResult addLimitedBenefit(@RequestBody Benefit benefit) {
        benefitService.addLimitedBenefit(benefit);
        return ApiResult.ok(benefit.getId());
    }

    /**
     * 查询商户的权益列表
     * @param merchantId 商户id
     * @return 权益列表
     */
    @GetMapping("/list/{merchantId}")
    public ApiResult queryBenefitsOfMerchant(@PathVariable("merchantId") Long merchantId) {
       return benefitService.queryBenefitsOfMerchant(merchantId);
    }
}
