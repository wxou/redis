package com.gouyu.utils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 为公开资源下的写操作补充登录校验。商户和权益的 GET 保持公开，
 * POST/PUT/DELETE 以及图片删除必须登录。
 */
public class WriteAuthInterceptor extends AuthInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String method = request.getMethod();
        String path = request.getRequestURI();
        boolean publicRead = "GET".equalsIgnoreCase(method) && !path.endsWith("/delete");
        return publicRead || super.preHandle(request, response, handler);
    }
}
