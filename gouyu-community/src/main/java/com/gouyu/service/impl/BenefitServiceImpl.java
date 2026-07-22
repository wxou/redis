package com.gouyu.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Benefit;
import com.gouyu.mapper.BenefitMapper;
import com.gouyu.entity.LimitedBenefit;
import com.gouyu.service.ILimitedBenefitService;
import com.gouyu.service.IBenefitService;
import com.gouyu.service.LimitedBenefitRedisStateService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

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
@Slf4j
public class BenefitServiceImpl extends ServiceImpl<BenefitMapper, Benefit> implements IBenefitService {

    @Resource
    private ILimitedBenefitService claimLimitedBenefitService;

    @Resource
    private LimitedBenefitRedisStateService limitedBenefitRedisStateService;

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
        // MySQL事务提交后再写Redis，避免数据库回滚时提前暴露权益。
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    syncLimitedBenefitState(claimLimitedBenefit);
                }
            });
        } else {
            syncLimitedBenefitState(claimLimitedBenefit);
        }
    }

    private void syncLimitedBenefitState(LimitedBenefit limitedBenefit) {
        try {
            limitedBenefitRedisStateService.writeState(limitedBenefit, true);
        } catch (RuntimeException e) {
            // 数据库已提交，不能向调用方伪装成整体失败；领取时的缺失状态修复会再次同步。
            log.error("限时权益已写入MySQL，但Redis状态同步失败，benefitId={}",
                    limitedBenefit.getBenefitId(), e);
        }
    }
}
