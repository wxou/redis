package com.gouyu.service;

import com.gouyu.config.AuthProperties;
import com.gouyu.exception.RateLimitException;
import com.gouyu.utils.RedisKeys;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * 认证限流。计数、首次设置 TTL 和锁定均在 Redis Lua 中原子完成。
 */
@Component
public class AuthRateLimiter {

    @SuppressWarnings("rawtypes")
    private static final DefaultRedisScript<List> CODE_SEND_SCRIPT = new DefaultRedisScript<>(
            "local cooldownTtl = redis.call('TTL', KEYS[1]); " +
                    "if cooldownTtl > 0 then return {1, cooldownTtl}; end; " +
                    "local phoneCount = tonumber(redis.call('GET', KEYS[2]) or '0'); " +
                    "if phoneCount >= tonumber(ARGV[3]) then return {2, redis.call('TTL', KEYS[2])}; end; " +
                    "local ipCount = tonumber(redis.call('GET', KEYS[3]) or '0'); " +
                    "if ipCount >= tonumber(ARGV[5]) then return {3, redis.call('TTL', KEYS[3])}; end; " +
                    "redis.call('SET', KEYS[1], '1', 'EX', ARGV[1]); " +
                    "phoneCount = redis.call('INCR', KEYS[2]); " +
                    "if phoneCount == 1 then redis.call('EXPIRE', KEYS[2], ARGV[2]); end; " +
                    "ipCount = redis.call('INCR', KEYS[3]); " +
                    "if ipCount == 1 then redis.call('EXPIRE', KEYS[3], ARGV[4]); end; " +
                    "return {0, 0};",
            List.class
    );

    @SuppressWarnings("rawtypes")
    private static final DefaultRedisScript<List> FIXED_WINDOW_SCRIPT = new DefaultRedisScript<>(
            "local count = redis.call('INCR', KEYS[1]); " +
                    "if count == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]); end; " +
                    "local ttl = redis.call('TTL', KEYS[1]); " +
                    "if count > tonumber(ARGV[2]) then return {0, ttl}; end; " +
                    "return {1, ttl};",
            List.class
    );

    @SuppressWarnings("rawtypes")
    private static final DefaultRedisScript<List> LOGIN_FAILURE_SCRIPT = new DefaultRedisScript<>(
            "local count = redis.call('INCR', KEYS[1]); " +
                    "if count == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]); end; " +
                    "if count >= tonumber(ARGV[2]) then " +
                    "redis.call('SET', KEYS[2], '1', 'EX', ARGV[3]); redis.call('DEL', KEYS[1]); " +
                    "return {1, tonumber(ARGV[3])}; end; " +
                    "return {0, redis.call('TTL', KEYS[1])};",
            List.class
    );

    private static final DefaultRedisScript<Long> CODE_FAILURE_SCRIPT = new DefaultRedisScript<>(
            "local count = redis.call('INCR', KEYS[1]); " +
                    "if count == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]); end; " +
                    "if count >= tonumber(ARGV[2]) then redis.call('DEL', KEYS[1]); redis.call('DEL', KEYS[2]); return 1; end; " +
                    "return 0;",
            Long.class
    );

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private AuthProperties authProperties;

    @SuppressWarnings("unchecked")
    public void checkCodeSend(String phone, String ip) {
        List<Long> result = stringRedisTemplate.execute(
                CODE_SEND_SCRIPT,
                Arrays.asList(
                        RedisKeys.AUTH_CODE_SEND_COOLDOWN_KEY + phone,
                        RedisKeys.AUTH_CODE_SEND_PHONE_KEY + phone,
                        RedisKeys.AUTH_CODE_SEND_IP_KEY + ip
                ),
                Integer.toString(authProperties.getCodeSendIntervalSeconds()),
                Long.toString(TimeUnit.DAYS.toSeconds(1)),
                Integer.toString(authProperties.getCodePhoneDailyLimit()),
                Long.toString(TimeUnit.HOURS.toSeconds(1)),
                Integer.toString(authProperties.getCodeIpHourlyLimit())
        );
        long reason = valueAt(result, 0, 3L);
        long retryAfter = valueAt(result, 1, authProperties.getCodeSendIntervalSeconds());
        if (reason == 1L) {
            throw new RateLimitException("验证码发送过于频繁，请稍后重试", retryAfter);
        }
        if (reason == 2L) {
            throw new RateLimitException("该手机号今日验证码发送次数已达上限", retryAfter);
        }
        if (reason == 3L) {
            throw new RateLimitException("当前网络验证码发送次数过多，请稍后重试", retryAfter);
        }
    }

    @SuppressWarnings("unchecked")
    public void checkLoginIp(String ip) {
        List<Long> result = stringRedisTemplate.execute(
                FIXED_WINDOW_SCRIPT,
                Collections.singletonList(RedisKeys.AUTH_LOGIN_IP_KEY + ip),
                Long.toString(TimeUnit.MINUTES.toSeconds(authProperties.getLoginIpWindowMinutes())),
                Integer.toString(authProperties.getLoginIpLimit())
        );
        if (valueAt(result, 0, 0L) == 0L) {
            throw new RateLimitException("登录请求过于频繁，请稍后重试", valueAt(result, 1, 60L));
        }
    }

    public void checkAccountLock(String phone) {
        Long ttl = stringRedisTemplate.getExpire(RedisKeys.AUTH_LOGIN_LOCK_KEY + phone, TimeUnit.SECONDS);
        if (ttl != null && ttl > 0L) {
            throw new RateLimitException("登录失败次数过多，账号已暂时锁定", ttl);
        }
    }

    @SuppressWarnings("unchecked")
    public long registerLoginFailure(String phone) {
        List<Long> result = stringRedisTemplate.execute(
                LOGIN_FAILURE_SCRIPT,
                Arrays.asList(
                        RedisKeys.AUTH_LOGIN_FAILURE_KEY + phone,
                        RedisKeys.AUTH_LOGIN_LOCK_KEY + phone
                ),
                Long.toString(TimeUnit.MINUTES.toSeconds(authProperties.getLoginAccountFailureWindowMinutes())),
                Integer.toString(authProperties.getLoginAccountMaxFailures()),
                Long.toString(TimeUnit.MINUTES.toSeconds(authProperties.getLoginLockMinutes()))
        );
        return valueAt(result, 0, 0L) == 1L ? valueAt(result, 1, 60L) : 0L;
    }

    public boolean registerCodeFailure(String phone) {
        Long invalidated = stringRedisTemplate.execute(
                CODE_FAILURE_SCRIPT,
                Arrays.asList(
                        RedisKeys.AUTH_CODE_FAILURE_KEY + phone,
                        RedisKeys.AUTH_CODE_KEY + phone
                ),
                Long.toString(TimeUnit.MINUTES.toSeconds(authProperties.getCodeTtlMinutes())),
                Integer.toString(authProperties.getCodeMaxFailures())
        );
        return invalidated != null && invalidated == 1L;
    }

    public void clearLoginFailures(String phone) {
        stringRedisTemplate.delete(Arrays.asList(
                RedisKeys.AUTH_LOGIN_FAILURE_KEY + phone,
                RedisKeys.AUTH_LOGIN_LOCK_KEY + phone
        ));
    }

    public void clearCodeFailures(String phone) {
        stringRedisTemplate.delete(RedisKeys.AUTH_CODE_FAILURE_KEY + phone);
    }

    private long valueAt(List<Long> values, int index, long defaultValue) {
        if (values == null || values.size() <= index || values.get(index) == null) {
            return defaultValue;
        }
        return Math.max(0L, values.get(index));
    }
}
