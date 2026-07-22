package com.gouyu.service;

import com.gouyu.entity.LimitedBenefit;
import com.gouyu.utils.RedisKeys;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class LimitedBenefitRedisStateService {

    private static final ZoneId BUSINESS_ZONE = ZoneId.of("Asia/Shanghai");

    private final ILimitedBenefitService limitedBenefitService;
    private final StringRedisTemplate stringRedisTemplate;
    private final RedissonClient redissonClient;

    public LimitedBenefitRedisStateService(ILimitedBenefitService limitedBenefitService,
                                           StringRedisTemplate stringRedisTemplate,
                                           RedissonClient redissonClient) {
        this.limitedBenefitService = limitedBenefitService;
        this.stringRedisTemplate = stringRedisTemplate;
        this.redissonClient = redissonClient;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void initializeMissingStates() {
        List<LimitedBenefit> benefits = limitedBenefitService.list();
        for (LimitedBenefit benefit : benefits) {
            writeState(benefit, false);
        }
        log.info("已检查并初始化 {} 个限时权益Redis状态", benefits.size());
    }

    public boolean restoreIfMissing(Long benefitId) {
        String lockKey = "gy:lock:limited-benefit:init:" + benefitId;
        RLock lock = redissonClient.getLock(lockKey);
        boolean acquired = false;
        try {
            acquired = lock.tryLock(300, TimeUnit.MILLISECONDS);
            if (!acquired) {
                return hasCompleteState(benefitId);
            }
            if (hasCompleteState(benefitId)) {
                return true;
            }
            LimitedBenefit benefit = limitedBenefitService.getById(benefitId);
            if (benefit == null) {
                return false;
            }
            writeState(benefit, false);
            return true;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        } finally {
            if (acquired && lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    public void writeState(LimitedBenefit benefit, boolean replaceStock) {
        Long benefitId = benefit.getBenefitId();
        Map<String, String> meta = new HashMap<>();
        meta.put("startsAt", String.valueOf(benefit.getStartsAt().atZone(BUSINESS_ZONE).toEpochSecond()));
        meta.put("endsAt", String.valueOf(benefit.getEndsAt().atZone(BUSINESS_ZONE).toEpochSecond()));
        meta.put("enabled", "1");
        stringRedisTemplate.opsForHash().putAll(RedisKeys.LIMITED_BENEFIT_META_KEY + benefitId, meta);
        String stockKey = RedisKeys.LIMITED_BENEFIT_STOCK_KEY + benefitId;
        if (replaceStock) {
            stringRedisTemplate.opsForValue().set(stockKey, benefit.getStock().toString());
        } else {
            stringRedisTemplate.opsForValue().setIfAbsent(stockKey, benefit.getStock().toString());
        }
    }

    private boolean hasCompleteState(Long benefitId) {
        return Boolean.TRUE.equals(stringRedisTemplate.hasKey(RedisKeys.LIMITED_BENEFIT_META_KEY + benefitId))
                && Boolean.TRUE.equals(stringRedisTemplate.hasKey(RedisKeys.LIMITED_BENEFIT_STOCK_KEY + benefitId));
    }
}
