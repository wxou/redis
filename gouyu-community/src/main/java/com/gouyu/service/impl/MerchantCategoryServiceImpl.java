package com.gouyu.service.impl;

import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.MerchantCategory;
import com.gouyu.mapper.MerchantCategoryMapper;
import com.gouyu.service.IMerchantCategoryService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.utils.RedisKeys;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Service
public class MerchantCategoryServiceImpl extends ServiceImpl<MerchantCategoryMapper, MerchantCategory> implements IMerchantCategoryService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public ApiResult queryCategoryList() {
        // 1、从Redis中查询商户分类
        String key = RedisKeys.CACHE_MERCHANT_CATEGORY_KEY;
        String merchantCategoryJson = stringRedisTemplate.opsForValue().get(key);

        List<MerchantCategory> typeList = null;
        // 2、判断缓存是否命中
        if (StrUtil.isNotBlank(merchantCategoryJson)) {
            // 2.1 缓存命中，直接返回缓存数据
            typeList = JSONUtil.toList(merchantCategoryJson, MerchantCategory.class);
            return ApiResult.ok(typeList);
        }
        // 2.1 缓存未命中，查询数据库
        typeList = this.query().orderByAsc("sort").list();

        // 3、判断数据库中是否存在该数据
        if (Objects.isNull(typeList)) {
            // 3.1 数据库中不存在该数据，返回失败信息
            return ApiResult.fail("商户分类不存在");
        }
        // 3.2 商户数据存在，写入Redis，并返回查询的数据
        stringRedisTemplate.opsForValue().set(key, JSONUtil.toJsonStr(typeList),
                RedisKeys.CACHE_MERCHANT_CATEGORY_TTL, TimeUnit.MINUTES);
        return ApiResult.ok(typeList);

    }
}
