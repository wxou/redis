package com.gouyu.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 认证安全参数。所有时间和阈值均可通过 GOUYU_* 环境变量覆盖。
 */
@Data
@Component
@ConfigurationProperties(prefix = "gouyu.auth")
public class AuthProperties {

    private boolean exposeCode = true;
    private long codeTtlMinutes = 2L;
    private long sessionIdleMinutes = 120L;
    private long sessionAbsoluteHours = 168L;
    private int passwordMinLength = 8;
    private int passwordMaxLength = 20;
    private int bcryptStrength = 10;
    private int codeSendIntervalSeconds = 60;
    private int codePhoneDailyLimit = 10;
    private int codeIpHourlyLimit = 30;
    private int codeMaxFailures = 5;
    private int loginIpLimit = 30;
    private int loginIpWindowMinutes = 10;
    private int loginAccountMaxFailures = 5;
    private int loginAccountFailureWindowMinutes = 15;
    private int loginLockMinutes = 15;
    private int auditRetentionDays = 180;
}
