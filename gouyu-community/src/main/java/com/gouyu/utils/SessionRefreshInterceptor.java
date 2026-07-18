    package com.gouyu.utils;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import com.gouyu.config.AuthProperties;
import com.gouyu.dto.MemberDTO;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;
import java.util.concurrent.TimeUnit;

    public class SessionRefreshInterceptor implements HandlerInterceptor {

    private StringRedisTemplate stringRedisTemplate;
    private AuthProperties authProperties;

    public static final String SESSION_ISSUED_AT_FIELD = "_issuedAt";

    public SessionRefreshInterceptor(StringRedisTemplate stringRedisTemplate, AuthProperties authProperties) {
        this.stringRedisTemplate = stringRedisTemplate;
        this.authProperties = authProperties;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //1.获取请求头中的token
        String token = request.getHeader("Authorization");
        if (StrUtil.isBlank( token)) {
           return true;
        }
        //2.基于token获取Redis中的成员
        String key = RedisKeys.AUTH_SESSION_KEY + token;
        Map<Object, Object> memberMap = stringRedisTemplate.opsForHash().entries(key);
        //3.判断成员是否存在
        if (memberMap.isEmpty()){
            return true;
        }
        long now = System.currentTimeMillis();
        Object issuedAtValue = memberMap.remove(SESSION_ISSUED_AT_FIELD);
        long issuedAt;
        if (issuedAtValue == null) {
            // 兼容部署前创建的旧会话，从首次访问时开始计算绝对有效期。
            issuedAt = now;
            stringRedisTemplate.opsForHash().put(key, SESSION_ISSUED_AT_FIELD, Long.toString(issuedAt));
        } else {
            try {
                issuedAt = Long.parseLong(issuedAtValue.toString());
            } catch (NumberFormatException e) {
                stringRedisTemplate.delete(key);
                return true;
            }
        }
        long absoluteMillis = TimeUnit.HOURS.toMillis(authProperties.getSessionAbsoluteHours());
        long remainingAbsoluteSeconds = TimeUnit.MILLISECONDS.toSeconds(issuedAt + absoluteMillis - now);
        if (remainingAbsoluteSeconds <= 0L) {
            stringRedisTemplate.delete(key);
            return true;
        }
        //5.将查询到的Hash数据转为MemberDTO对象
        MemberDTO memberDTO = BeanUtil.fillBeanWithMap(memberMap, new MemberDTO(), false);
        //6.存在，保存成员信息到 ThreadLocal
        MemberContext.saveMember(memberDTO);

        //7.刷新token有效期
        long idleSeconds = TimeUnit.MINUTES.toSeconds(authProperties.getSessionIdleMinutes());
        stringRedisTemplate.expire(key, Math.min(idleSeconds, remainingAbsoluteSeconds), TimeUnit.SECONDS);
        //8.放行
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        //清空成员
        MemberContext.removeMember();
    }
}
