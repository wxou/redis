package com.gouyu.config;

import com.gouyu.utils.AuthInterceptor;
import com.gouyu.utils.SessionRefreshInterceptor;
import com.gouyu.utils.WriteAuthInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.annotation.Resource;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Resource
    private  StringRedisTemplate stringRedisTemplate;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        //登录拦截器
        registry.addInterceptor(new AuthInterceptor())
                .excludePathPatterns(
                        "/member/code",
                        "/member/login",
                        "/post/hot",
                        "/merchant/**",
                        "/merchant-category/**",
                        "/upload/**",
                        "/benefit/**"
                ).order(1);
        //刷新token拦截器
        registry.addInterceptor(new SessionRefreshInterceptor(stringRedisTemplate)).addPathPatterns("/**").order(0);
        // 商户、权益和上传的读取接口公开，写操作必须登录
        registry.addInterceptor(new WriteAuthInterceptor())
                .addPathPatterns("/merchant/**", "/benefit/**", "/upload/**")
                .order(1);
    }
}
