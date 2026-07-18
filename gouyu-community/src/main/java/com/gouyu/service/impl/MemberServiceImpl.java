package com.gouyu.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.bean.copier.CopyOptions;
import cn.hutool.core.lang.UUID;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.config.AuthProperties;
import com.gouyu.dto.*;
import com.gouyu.entity.Member;
import com.gouyu.exception.RateLimitException;
import com.gouyu.mapper.MemberMapper;
import com.gouyu.service.AuthAuditService;
import com.gouyu.service.AuthRateLimiter;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.BitFieldSubCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * <p>
 * 服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Service
@Slf4j
public class MemberServiceImpl extends ServiceImpl<MemberMapper, Member> implements IMemberService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private AuthProperties authProperties;

    @Resource
    private AuthRateLimiter authRateLimiter;

    @Resource
    private AuthAuditService authAuditService;

    @Resource
    private GouYuPasswordEncoder passwordEncoder;

    @Override
    public ApiResult sendCode(String phone, HttpServletRequest request) {
        if (RegexUtils.isPhoneInvalid(phone)) {
            authAuditService.record("CODE_SEND", null, phone, request,
                    AuthAuditService.FAILURE, "INVALID_PHONE", null);
            return ApiResult.fail("手机号格式错误");
        }
        try {
            authRateLimiter.checkCodeSend(phone, RequestClientUtils.getClientIp(request));
        } catch (RateLimitException e) {
            authAuditService.record("CODE_SEND", null, phone, request,
                    AuthAuditService.BLOCKED, "RATE_LIMITED", null);
            throw e;
        }

        String code = RandomUtil.randomNumbers(6);
        stringRedisTemplate.opsForValue().set(
                RedisKeys.AUTH_CODE_KEY + phone,
                code,
                authProperties.getCodeTtlMinutes(),
                TimeUnit.MINUTES
        );
        authRateLimiter.clearCodeFailures(phone);
        authAuditService.record("CODE_SEND", null, phone, request,
                AuthAuditService.SUCCESS, null, null);
        log.debug("短信验证码已生成并保存，phoneSuffix={}", phone.substring(phone.length() - 4));
        return authProperties.isExposeCode() ? ApiResult.ok(code) : ApiResult.ok();
    }

    @Override
    public ApiResult login(LoginRequest loginForm, HttpServletRequest request) {
        String phone = loginForm == null ? null : loginForm.getPhone();
        try {
            authRateLimiter.checkLoginIp(RequestClientUtils.getClientIp(request));
        } catch (RateLimitException e) {
            authAuditService.record("LOGIN", null, phone, request,
                    AuthAuditService.BLOCKED, "IP_RATE_LIMITED", null);
            throw e;
        }
        if (RegexUtils.isPhoneInvalid(phone)) {
            authAuditService.record("LOGIN", null, phone, request,
                    AuthAuditService.FAILURE, "INVALID_PHONE", null);
            return ApiResult.fail("手机号格式错误");
        }
        try {
            authRateLimiter.checkAccountLock(phone);
        } catch (RateLimitException e) {
            authAuditService.record("LOGIN", null, phone, request,
                    AuthAuditService.BLOCKED, "ACCOUNT_LOCKED", null);
            throw e;
        }

        boolean passwordLogin = StrUtil.isNotBlank(loginForm.getPassword());
        boolean codeLogin = StrUtil.isNotBlank(loginForm.getCode());
        if (passwordLogin == codeLogin) {
            return ApiResult.fail("请使用验证码或密码中的一种方式登录");
        }

        Member member = query().eq("phone", phone).one();
        String eventType;
        if (passwordLogin) {
            eventType = "PASSWORD_LOGIN";
            if (!isPasswordLengthValid(loginForm.getPassword())
                    || member == null
                    || !passwordEncoder.matches(loginForm.getPassword(), member.getPassword())) {
                return loginFailure(eventType, member, phone, request, "BAD_CREDENTIALS");
            }
            if (passwordEncoder.needsUpgrade(member.getPassword())) {
                member.setPassword(passwordEncoder.encode(loginForm.getPassword()));
                updateById(member);
            }
        } else {
            eventType = "CODE_LOGIN";
            String cacheCode = stringRedisTemplate.opsForValue().get(RedisKeys.AUTH_CODE_KEY + phone);
            if (cacheCode == null || !cacheCode.equals(loginForm.getCode())) {
                boolean invalidated = authRateLimiter.registerCodeFailure(phone);
                return loginFailure(eventType, member, phone, request,
                        invalidated ? "CODE_INVALIDATED" : "BAD_CODE");
            }
            if (member == null) {
                member = createMemberWithPhone(phone);
            }
            stringRedisTemplate.delete(RedisKeys.AUTH_CODE_KEY + phone);
            authRateLimiter.clearCodeFailures(phone);
        }

        authRateLimiter.clearLoginFailures(phone);
        String token = createSession(member);
        authAuditService.record(eventType, member.getId(), phone, request,
                AuthAuditService.SUCCESS, null, token);
        return ApiResult.ok(token);
    }

    @Override
    public ApiResult logout(String token, HttpServletRequest request) {
        MemberDTO currentMember = MemberContext.getMember();
        stringRedisTemplate.delete(RedisKeys.AUTH_SESSION_KEY + token);
        authAuditService.record("LOGOUT", currentMember == null ? null : currentMember.getId(),
                null, request, AuthAuditService.SUCCESS, null, token);
        return ApiResult.ok();
    }

    @Override
    public ApiResult changePassword(PasswordChangeRequest passwordRequest, HttpServletRequest request) {
        String validationMessage = validateNewPassword(passwordRequest == null ? null : passwordRequest.getNewPassword());
        Member member = getById(MemberContext.getMember().getId());
        if (validationMessage != null) {
            authAuditService.record("PASSWORD_CHANGE", member.getId(), member.getPhone(), request,
                    AuthAuditService.FAILURE, "INVALID_NEW_PASSWORD", null);
            return ApiResult.fail(validationMessage);
        }
        if (StrUtil.isNotBlank(member.getPassword())
                && !passwordEncoder.matches(passwordRequest.getCurrentPassword(), member.getPassword())) {
            authAuditService.record("PASSWORD_CHANGE", member.getId(), member.getPhone(), request,
                    AuthAuditService.FAILURE, "BAD_CURRENT_PASSWORD", null);
            return ApiResult.fail("当前密码错误");
        }
        member.setPassword(passwordEncoder.encode(passwordRequest.getNewPassword()));
        updateById(member);
        authAuditService.record("PASSWORD_CHANGE", member.getId(), member.getPhone(), request,
                AuthAuditService.SUCCESS, null, null);
        return ApiResult.ok();
    }

    @Override
    public ApiResult resetPassword(PasswordResetRequest passwordRequest, HttpServletRequest request) {
        String phone = passwordRequest == null ? null : passwordRequest.getPhone();
        if (RegexUtils.isPhoneInvalid(phone)) {
            return ApiResult.fail("手机号格式错误");
        }
        String validationMessage = validateNewPassword(passwordRequest.getNewPassword());
        if (validationMessage != null) {
            return ApiResult.fail(validationMessage);
        }
        try {
            authRateLimiter.checkLoginIp(RequestClientUtils.getClientIp(request));
        } catch (RateLimitException e) {
            authAuditService.record("PASSWORD_RESET", null, phone, request,
                    AuthAuditService.BLOCKED, "IP_RATE_LIMITED", null);
            throw e;
        }
        String cacheCode = stringRedisTemplate.opsForValue().get(RedisKeys.AUTH_CODE_KEY + phone);
        if (cacheCode == null || !cacheCode.equals(passwordRequest.getCode())) {
            boolean invalidated = authRateLimiter.registerCodeFailure(phone);
            authAuditService.record("PASSWORD_RESET", null, phone, request,
                    AuthAuditService.FAILURE, invalidated ? "CODE_INVALIDATED" : "BAD_CODE", null);
            return ApiResult.fail("验证码错误或已过期");
        }
        Member member = query().eq("phone", phone).one();
        if (member == null) {
            authAuditService.record("PASSWORD_RESET", null, phone, request,
                    AuthAuditService.FAILURE, "MEMBER_NOT_FOUND", null);
            return ApiResult.fail("该手机号尚未注册");
        }
        member.setPassword(passwordEncoder.encode(passwordRequest.getNewPassword()));
        updateById(member);
        stringRedisTemplate.delete(RedisKeys.AUTH_CODE_KEY + phone);
        authRateLimiter.clearCodeFailures(phone);
        authRateLimiter.clearLoginFailures(phone);
        authAuditService.record("PASSWORD_RESET", member.getId(), phone, request,
                AuthAuditService.SUCCESS, null, null);
        return ApiResult.ok();
    }

    @Override
    public ApiResult checkIn() {
        // 1. 获取当前登录成员
        Long memberId = MemberContext.getMember().getId();
        // 2. 获取日期
        LocalDateTime now = LocalDateTime.now();
        // 3. 拼接key
        String keySuffix = now.format(DateTimeFormatter.ofPattern(":yyyyMM"));
        String key = RedisKeys.MEMBER_CHECK_IN_KEY + memberId + keySuffix;
        // 4. 获取今天是本月的第几天
        int dayOfMonth = now.getDayOfMonth();
        // 5. 写入Redis set bit key offset 1
        stringRedisTemplate.opsForValue().setBit(key, dayOfMonth - 1, true);
        return ApiResult.ok();
    }

    @Override
    public ApiResult checkInCount() {
        // 1. 获取当前登录成员
        Long memberId = MemberContext.getMember().getId();
        // 2. 获取日期
        LocalDateTime now = LocalDateTime.now();
        // 3. 拼接key
        String keySuffix = now.format(DateTimeFormatter.ofPattern(":yyyyMM"));
        String key = RedisKeys.MEMBER_CHECK_IN_KEY + memberId + keySuffix;
        // 4. 获取今天是本月的第几天
        int dayOfMonth = now.getDayOfMonth();
        // 5. 获取本月截止今天为止的所有打卡记录，返货的是一个十进制的数字 BITFIELD sign:1436:202605 GET u9 0
        List<Long> result = stringRedisTemplate.opsForValue().bitField(
                key,
                BitFieldSubCommands.create().
                        get(BitFieldSubCommands.BitFieldType.unsigned(dayOfMonth)).valueAt(0)
        );
        if (result == null || result.isEmpty()){
            // 没有任何打卡结果
            return ApiResult.ok(0);
        }
        Long num = result.get(0);
        if (num == null || num == 0){
            // 没有任何打卡
            return ApiResult.ok(0);
        }
        // 6. 循环遍历
        int count = 0;
        while (true){
            // 6.1 让这个数字与1做与运算，得到数字的最后一个bit位 //  判断这个bit位是否为0
            if ((num & 1) == 0){
                // 如果为0，说明未打卡，结束
                break;
            }else{
                // 如果不为0，说明已打卡，计数器+1
                count++;
            }
            // 把数字右移一位，抛弃最后一个bit位，继续下一个bit位
            num >>>= 1;
        }
        return ApiResult.ok(count);
    }

    private ApiResult loginFailure(String eventType, Member member, String phone,
                                   HttpServletRequest request, String reason) {
        long lockSeconds = authRateLimiter.registerLoginFailure(phone);
        authAuditService.record(eventType, member == null ? null : member.getId(), phone, request,
                lockSeconds > 0L ? AuthAuditService.BLOCKED : AuthAuditService.FAILURE,
                reason, null);
        if (lockSeconds > 0L) {
            throw new RateLimitException("登录失败次数过多，账号已暂时锁定", lockSeconds);
        }
        return ApiResult.fail("手机号、验证码或密码错误");
    }

    private String createSession(Member member) {
        String token = UUID.randomUUID().toString(true);
        MemberDTO memberDTO = BeanUtil.copyProperties(member, MemberDTO.class);
        Map<String, Object> memberMap = BeanUtil.beanToMap(memberDTO, new HashMap<>(),
                CopyOptions.create()
                        .setIgnoreNullValue(true)
                        .setFieldValueEditor((fieldName, fieldValue) -> fieldValue.toString()));
        memberMap.put(SessionRefreshInterceptor.SESSION_ISSUED_AT_FIELD,
                Long.toString(System.currentTimeMillis()));
        String sessionKey = RedisKeys.AUTH_SESSION_KEY + token;
        stringRedisTemplate.opsForHash().putAll(sessionKey, memberMap);
        stringRedisTemplate.expire(sessionKey, authProperties.getSessionIdleMinutes(), TimeUnit.MINUTES);
        return token;
    }

    private boolean isPasswordLengthValid(String password) {
        return password != null
                && password.length() >= authProperties.getPasswordMinLength()
                && password.length() <= authProperties.getPasswordMaxLength();
    }

    private String validateNewPassword(String password) {
        if (StrUtil.isBlank(password) || !isPasswordLengthValid(password)) {
            return "密码长度必须为" + authProperties.getPasswordMinLength()
                    + "至" + authProperties.getPasswordMaxLength() + "位";
        }
        return null;
    }

    private Member createMemberWithPhone(String phone) {
        //1.创建成员
        Member member = new Member();
        member.setPhone(phone);
        member.setDisplayName(GouYuConstants.MEMBER_NAME_PREFIX + RandomUtil.randomString(10));
        //2.保存成员
        save(member);
        return member;
    }
}
