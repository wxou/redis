package com.gouyu.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Benefit;
import com.gouyu.mapper.BenefitMapper;
import com.gouyu.entity.LimitedBenefit;
import com.gouyu.service.ILimitedBenefitService;
import com.gouyu.service.IBenefitService;
import com.gouyu.utils.RedisKeys;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Service
public class BenefitServiceImpl extends ServiceImpl<BenefitMapper, Benefit> implements IBenefitService {

    @Resource
    private ILimitedBenefitService claimLimitedBenefitService;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public ApiResult queryBenefitsOfMerchant(Long merchantId) {
        // 查询权益信息
        List<Benefit> benefits = getBaseMapper().queryBenefitsOfMerchant(merchantId);
        // 返回结果
        return ApiResult.ok(benefits);
    }

    @Override
    @Transactional
    public void addLimitedBenefit(Benefit benefit) {
        if (benefit.getStock() == null || benefit.getStock() < 1) {
            throw new IllegalArgumentException("限时权益库存必须大于0");
        }
        if (benefit.getStartsAt() == null || benefit.getEndsAt() == null
                || !benefit.getEndsAt().isAfter(benefit.getStartsAt())) {
            throw new IllegalArgumentException("限时权益时间范围无效");
        }
        // 保存权益
        save(benefit);
        // 保存限时权益信息
        LimitedBenefit claimLimitedBenefit = new LimitedBenefit();
        claimLimitedBenefit.setBenefitId(benefit.getId());
        claimLimitedBenefit.setStock(benefit.getStock());
        claimLimitedBenefit.setStartsAt(benefit.getStartsAt());
        claimLimitedBenefit.setEndsAt(benefit.getEndsAt());
        claimLimitedBenefitService.save(claimLimitedBenefit);
        //保存限时权益信息到redis中
        stringRedisTemplate.opsForValue().set(RedisKeys.LIMITED_BENEFIT_STOCK_KEY + benefit.getId(), benefit.getStock().toString());
    }
}
