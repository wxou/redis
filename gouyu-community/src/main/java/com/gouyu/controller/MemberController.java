package com.gouyu.controller;


import cn.hutool.core.bean.BeanUtil;
import com.gouyu.dto.LoginRequest;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.MemberDTO;
import com.gouyu.dto.PasswordChangeRequest;
import com.gouyu.dto.PasswordResetRequest;
import com.gouyu.entity.Member;
import com.gouyu.entity.MemberProfile;
import com.gouyu.service.IMemberProfileService;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.MemberContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Slf4j
@RestController
@RequestMapping("/member")
public class MemberController {

    @Resource
    private IMemberService memberService;

    @Resource
    private IMemberProfileService memberProfileService;

    /**
     * 发送手机验证码
     */
    @PostMapping("code")
    public ApiResult sendCode(@RequestParam("phone") String phone, HttpServletRequest request) {
        //发送短信验证码并保存验证码
        return memberService.sendCode(phone, request);
    }

    /**
     * 登录功能
     * @param loginForm 登录参数，包含手机号、验证码；或者手机号、密码
     */
    @PostMapping("/login")
    public ApiResult login(@RequestBody LoginRequest loginForm, HttpServletRequest request){
        //登录功能
        return memberService.login(loginForm, request);
    }

    /**
     * 登出功能
     * @return 无
     */
    @PostMapping("/logout")
    public ApiResult logout(@RequestHeader("authorization") String token, HttpServletRequest request){
        return memberService.logout(token, request);
    }

    @PutMapping("/password")
    public ApiResult changePassword(@RequestBody PasswordChangeRequest passwordRequest,
                                    HttpServletRequest request) {
        return memberService.changePassword(passwordRequest, request);
    }

    @PostMapping("/password/reset")
    public ApiResult resetPassword(@RequestBody PasswordResetRequest passwordRequest,
                                   HttpServletRequest request) {
        return memberService.resetPassword(passwordRequest, request);
    }

    @GetMapping("/me")
    public ApiResult me(){
        //获取当前登录的成员并返回
        MemberDTO member = MemberContext.getMember();
        return ApiResult.ok( member);
    }

    @GetMapping("/info/{id}")
    public ApiResult info(@PathVariable("id") Long memberId){
        // 查询详情
        MemberProfile info = memberProfileService.getById(memberId);
        if (info == null) {
            // 没有详情，应该是第一次查看详情
            return ApiResult.ok();
        }
        info.setCreatedAt(null);
        info.setUpdatedAt(null);
        // 返回
        return ApiResult.ok(info);
    }

    @PutMapping("/info")
    public ApiResult updateInfo(@RequestBody MemberProfile info) {
        info.setMemberId(MemberContext.getMember().getId());
        info.setFans(null);
        info.setFollowee(null);
        info.setCredits(null);
        info.setLevel(null);
        info.setCreatedAt(null);
        info.setUpdatedAt(null);
        memberProfileService.saveOrUpdate(info);
        return ApiResult.ok();
    }

    @GetMapping("/{id}")
    public ApiResult queryMemberById(@PathVariable("id") Long memberId){
        // 查询详情
        Member member = memberService.getById(memberId);
        if (member == null) {
            return ApiResult.ok();
        }
        MemberDTO memberDTO = BeanUtil.copyProperties(member, MemberDTO.class);
        // 返回
        return ApiResult.ok(memberDTO);
    }

    @PostMapping("/check-in")
    public ApiResult checkIn(){
        return memberService.checkIn();
    }

    @GetMapping("/check-in/count")
    public ApiResult checkInCount(){
        return memberService.checkInCount();
    }
}
