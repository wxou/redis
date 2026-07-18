package com.gouyu.utils;

import com.gouyu.config.AuthProperties;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;

/**
 * 新密码统一使用 BCrypt；仅为历史数据保留一次性 MD5 验证与登录后升级能力。
 */
@Component
public class GouYuPasswordEncoder {

    private final BCryptPasswordEncoder bcrypt;

    public GouYuPasswordEncoder(AuthProperties authProperties) {
        this.bcrypt = new BCryptPasswordEncoder(authProperties.getBcryptStrength());
    }

    public String encode(String rawPassword) {
        return bcrypt.encode(rawPassword);
    }

    public boolean matches(String rawPassword, String encodedPassword) {
        if (rawPassword == null || encodedPassword == null || encodedPassword.isEmpty()) {
            return false;
        }
        if (isBcrypt(encodedPassword)) {
            try {
                return bcrypt.matches(rawPassword, encodedPassword);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }
        return matchesLegacyMd5(rawPassword, encodedPassword);
    }

    public boolean needsUpgrade(String encodedPassword) {
        return encodedPassword != null && !encodedPassword.isEmpty()
                && (!isBcrypt(encodedPassword) || bcrypt.upgradeEncoding(encodedPassword));
    }

    private boolean isBcrypt(String encodedPassword) {
        return encodedPassword.startsWith("$2a$")
                || encodedPassword.startsWith("$2b$")
                || encodedPassword.startsWith("$2y$");
    }

    private boolean matchesLegacyMd5(String rawPassword, String encodedPassword) {
        int separator = encodedPassword.indexOf('@');
        if (separator <= 0 || separator == encodedPassword.length() - 1) {
            return false;
        }
        String salt = encodedPassword.substring(0, separator);
        String digest = DigestUtils.md5DigestAsHex((rawPassword + salt).getBytes(StandardCharsets.UTF_8));
        return encodedPassword.equals(salt + "@" + digest);
    }
}
