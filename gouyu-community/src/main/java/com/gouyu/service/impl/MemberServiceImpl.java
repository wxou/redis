package com.gouyu.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.bean.copier.CopyOptions;
import cn.hutool.core.lang.UUID;
import cn.hutool.core.util.RandomUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.dto.LoginRequest;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.MemberDTO;
import com.gouyu.entity.Member;
import com.gouyu.mapper.MemberMapper;
import com.gouyu.service.IMemberService;
import com.gouyu.utils.RedisKeys;
import com.gouyu.utils.RegexUtils;
import com.gouyu.utils.GouYuConstants;
import com.gouyu.utils.MemberContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.data.redis.connection.BitFieldSubCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
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

    /**
     * 发送验证码
     * @param phone 手机号
     * @param session
     * @return
     */
    @Override
    public ApiResult sendCode(String phone, HttpSession session) {
        //1.校验手机号
        if (RegexUtils.isPhoneInvalid(phone)) {
            //2.如果不符合，返回错误信息
            return ApiResult.fail("手机号格式错误");
        }

        //3.符合，生成验证码
        String  code = RandomUtil.randomNumbers(6);

        //4.保存验证码到 Redis
        stringRedisTemplate.opsForValue().set(RedisKeys.AUTH_CODE_KEY +phone, code, RedisKeys.AUTH_CODE_TTL, TimeUnit.MINUTES);

        //5.发送验证码
        log.debug("发送短信验证码成功，验证码：{}",code);

        //返回ok
        return ApiResult.ok();
    }

    /**
     * 登录功能
     * @param loginForm 登录参数，包含手机号、验证码；或者手机号、密码
     */
    @Override
    public ApiResult login(LoginRequest loginForm, HttpSession session) {
        //1.校验手机号
        String phone = loginForm.getPhone();
        if (RegexUtils.isPhoneInvalid(phone)) {
            //2.如果不符合，返回错误信息
            return ApiResult.fail("手机号格式错误");
        }
        //3.校验验证码,从Redis获取验证码并校验
      /*  String cacheCode = stringRedisTemplate.opsForValue().get(RedisKeys.AUTH_CODE_KEY +phone);
        String code = loginForm.getCode();
        if (cacheCode == null || !cacheCode.equals(code)) {
            //3.不一致，报错
            return ApiResult.fail("验证码错误");
        }*/
        //4.一致，根据手机号查询成员 select * from tb_ser where phone = ?
        Member member = query().eq("phone", phone).one();

        //5.判断成员是否存在
        if (member == null){
            //6.不存在，创建新成员并保存
            member = createMemberWithPhone(phone);
        }
        //7.保存成员信息到Redis中
        //7.1.随机生成token，作为登录令牌
        String token = UUID.randomUUID().toString(true);
        //7.2.将Member对象转为Hash存储
        MemberDTO memberDTO =BeanUtil.copyProperties(member, MemberDTO.class);
        Map<String, Object> memberMap = BeanUtil.beanToMap(memberDTO , new HashMap<>() ,
                CopyOptions.create()
                        .setIgnoreNullValue( true)
                        .setFieldValueEditor((fieldName,fieldValue)->fieldValue.toString()));
        //7.3.存储
        stringRedisTemplate.opsForHash().putAll(RedisKeys.AUTH_SESSION_KEY + token , memberMap);
        //7.4.设置token有效期
        stringRedisTemplate.expire(RedisKeys.AUTH_SESSION_KEY + token, RedisKeys.AUTH_SESSION_TTL, TimeUnit.MINUTES);
        return ApiResult.ok(token);
    }

    @Override
    public ApiResult logout(String token) {
        stringRedisTemplate.delete(RedisKeys.AUTH_SESSION_KEY + token);
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
