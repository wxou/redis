package com.gouyu.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gouyu.config.AuthProperties;
import com.gouyu.entity.AuthAuditLog;
import com.gouyu.mapper.AuthAuditLogMapper;
import com.gouyu.utils.RequestClientUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;

@Slf4j
@Service
public class AuthAuditService {

    public static final String SUCCESS = "SUCCESS";
    public static final String FAILURE = "FAILURE";
    public static final String BLOCKED = "BLOCKED";

    @Resource
    private AuthAuditLogMapper authAuditLogMapper;

    @Resource
    private AuthProperties authProperties;

    public void record(String eventType, Long memberId, String phone, HttpServletRequest request,
                       String outcome, String reason, String token) {
        try {
            AuthAuditLog auditLog = new AuthAuditLog();
            auditLog.setEventType(limit(eventType, 32));
            auditLog.setMemberId(memberId);
            auditLog.setPhoneMasked(maskPhone(phone));
            auditLog.setIpAddress(request == null ? null : RequestClientUtils.getClientIp(request));
            auditLog.setUserAgent(request == null ? null : limit(request.getHeader("User-Agent"), 255));
            auditLog.setOutcome(limit(outcome, 16));
            auditLog.setReason(limit(reason, 128));
            auditLog.setTokenFingerprint(fingerprint(token));
            auditLog.setCreatedAt(LocalDateTime.now());
            authAuditLogMapper.insert(auditLog);
        } catch (RuntimeException e) {
            // 审计存储故障不能扩大为登录不可用，但必须留下服务端告警。
            log.warn("认证审计日志写入失败，eventType={}", eventType, e);
        }
    }

    @Scheduled(cron = "${gouyu.auth.audit-cleanup-cron:0 30 3 * * ?}")
    public void cleanExpiredLogs() {
        try {
            LocalDateTime cutoff = LocalDateTime.now().minusDays(authProperties.getAuditRetentionDays());
            authAuditLogMapper.delete(new LambdaQueryWrapper<AuthAuditLog>()
                    .lt(AuthAuditLog::getCreatedAt, cutoff));
        } catch (RuntimeException e) {
            log.warn("过期认证审计日志清理失败", e);
        }
    }

    private String maskPhone(String phone) {
        if (StrUtil.isBlank(phone) || phone.length() < 7) {
            return null;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    private String fingerprint(String token) {
        if (StrUtil.isBlank(token)) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashed = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder(hashed.length * 2);
            for (byte b : hashed) {
                result.append(String.format("%02x", b));
            }
            return result.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("当前运行环境不支持 SHA-256", e);
        }
    }

    private String limit(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
