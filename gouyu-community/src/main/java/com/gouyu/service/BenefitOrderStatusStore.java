package com.gouyu.service;

import com.gouyu.config.BenefitOrderProperties;
import com.gouyu.utils.RedisKeys;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class BenefitOrderStatusStore {

    private final StringRedisTemplate stringRedisTemplate;
    private final BenefitOrderProperties properties;

    public BenefitOrderStatusStore(StringRedisTemplate stringRedisTemplate,
                                   BenefitOrderProperties properties) {
        this.stringRedisTemplate = stringRedisTemplate;
        this.properties = properties;
    }

    public void update(Long orderId, Long memberId, Long benefitId, BenefitOrderStatus status,
                       String message, int retryCount) {
        if (orderId == null) {
            return;
        }
        String key = RedisKeys.BENEFIT_ORDER_STATUS_KEY + orderId;
        Map<String, String> values = new HashMap<>();
        values.put("orderId", orderId.toString());
        if (memberId != null) {
            values.put("memberId", memberId.toString());
        }
        if (benefitId != null) {
            values.put("benefitId", benefitId.toString());
        }
        values.put("status", status.name());
        values.put("message", message == null ? "" : message);
        values.put("retryCount", String.valueOf(retryCount));
        values.put("updatedAt", LocalDateTime.now().toString());
        stringRedisTemplate.opsForHash().putAll(key, values);
        stringRedisTemplate.expire(key, properties.getStatusTtlHours(), TimeUnit.HOURS);
    }

    public Map<Object, Object> get(Long orderId) {
        return stringRedisTemplate.opsForHash().entries(RedisKeys.BENEFIT_ORDER_STATUS_KEY + orderId);
    }
}
