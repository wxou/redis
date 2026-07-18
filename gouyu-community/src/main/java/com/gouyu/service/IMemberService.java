package com.gouyu.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.gouyu.dto.LoginRequest;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.PasswordChangeRequest;
import com.gouyu.dto.PasswordResetRequest;
import com.gouyu.entity.Member;

import javax.servlet.http.HttpServletRequest;

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
    ApiResult sendCode(String phone, HttpServletRequest request);

    /**
     * 登录功能
     * @param loginForm 登录参数，包含手机号、验证码；或者手机号、密码
     * @return 登录结果
     */
    ApiResult login(LoginRequest loginForm, HttpServletRequest request);

    ApiResult logout(String token, HttpServletRequest request);

    ApiResult changePassword(PasswordChangeRequest passwordRequest, HttpServletRequest request);

    ApiResult resetPassword(PasswordResetRequest passwordRequest, HttpServletRequest request);

    ApiResult checkIn();

    ApiResult checkInCount();

}
