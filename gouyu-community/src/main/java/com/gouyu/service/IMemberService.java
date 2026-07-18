package com.gouyu.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.gouyu.dto.LoginRequest;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Member;

import javax.servlet.http.HttpSession;

/**
 * <p>
 *  服务类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface IMemberService extends IService<Member> {

    /**
     * 发送验证码
     * @param phone 手机号
     * @return 验证码发送结果
     */
    ApiResult sendCode(String phone, HttpSession session);

    /**
     * 登录功能
     * @param loginForm 登录参数，包含手机号、验证码；或者手机号、密码
     * @return 登录结果
     */
    ApiResult login(LoginRequest loginForm, HttpSession session);

    ApiResult logout(String token);

    ApiResult checkIn();

    ApiResult checkInCount();

}
