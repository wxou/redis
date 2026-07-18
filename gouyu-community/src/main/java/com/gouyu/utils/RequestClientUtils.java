package com.gouyu.utils;

import cn.hutool.core.util.StrUtil;

import javax.servlet.http.HttpServletRequest;

public final class RequestClientUtils {

    private static final int MAX_IP_LENGTH = 45;

    private RequestClientUtils() {
    }

    public static String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Real-IP");
        if (StrUtil.isBlank(ip)) {
            String forwardedFor = request.getHeader("X-Forwarded-For");
            if (StrUtil.isNotBlank(forwardedFor)) {
                ip = forwardedFor.split(",", 2)[0].trim();
            }
        }
        if (StrUtil.isBlank(ip)) {
            ip = request.getRemoteAddr();
        }
        if (StrUtil.isBlank(ip)) {
            return "unknown";
        }
        return ip.length() <= MAX_IP_LENGTH ? ip : ip.substring(0, MAX_IP_LENGTH);
    }
}
