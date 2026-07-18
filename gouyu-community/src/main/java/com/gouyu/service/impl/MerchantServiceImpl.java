package com.gouyu.service.impl;

import cn.hutool.core.util.BooleanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Merchant;
import com.gouyu.mapper.MerchantMapper;
import com.gouyu.service.IMerchantService;
import com.gouyu.utils.RedisCacheClient;
import com.gouyu.utils.RedisKeys;
import com.gouyu.utils.RedisCachePayload;
import com.gouyu.utils.GouYuConstants;
import org.apache.tomcat.util.buf.StringUtils;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.Point;
import org.springframework.data.geo.GeoResult;
import org.springframework.data.geo.GeoResults;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.domain.geo.GeoReference;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Service
public class MerchantServiceImpl extends ServiceImpl<MerchantMapper, Merchant> implements IMerchantService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private RedisCacheClient redisCacheClient;

    /**
     * 根据id查询商户信息
     * @param id 商户id
     * @return 商户详情数据
     */
    @Override
    public ApiResult queryById(Long id) {
        //空值解决缓存穿透
//        Merchant merchant = queryWithPassThrough(id);
        Merchant merchant = redisCacheClient.queryWithPassThrough(RedisKeys.CACHE_MERCHANT_KEY,
                id, Merchant.class, this::getById,
                RedisKeys.CACHE_MERCHANT_TTL, TimeUnit.MINUTES);

        //互斥锁解决缓存击穿
//        Merchant merchant = queryWithMutex(id);

        //逻辑过期解决缓存击穿
        //Merchant merchant = queryWithLogicalExpire(id);
        /*Merchant merchant = redisCacheClient.queryWithLogicalExpire(
                RedisKeys.CACHE_MERCHANT_KEY,id,Merchant.class,this::getById,
                RedisKeys.CACHE_MERCHANT_TTL,TimeUnit.MINUTES);*/

        if (merchant == null) {
            return ApiResult.fail("商户不存在");
        }

        //7.返回
        return ApiResult.ok(merchant);
    }


    //private static final ExecutorService CACHE_REBUILD_EXECUTOR = Executors.newFixedThreadPool(10);

    //逻辑过期解决缓存击穿
    /*public Merchant queryWithLogicalExpire(Long id){
        String key = RedisKeys.CACHE_MERCHANT_KEY + id;
        //1.从Redis查询商户缓存
        String merchantJson = stringRedisTemplate.opsForValue().get(key);
        //2.判断是否存在
        if (StrUtil.isBlank(merchantJson)) {
            //3.不存在，直接返回（缓存未命中，认为不是热点Key）
            return null;
        }

        //4.命中，将数据从Redis反序列化为对象
        RedisCachePayload redisData = JSONUtil.toBean(merchantJson, RedisCachePayload.class);
        Merchant merchant = JSONUtil.toBean((JSONObject)redisData.getData(), Merchant.class);
        LocalDateTime expireTime = redisData.getExpireTime();
        //5.判断是否过期
        if (expireTime.isAfter(LocalDateTime.now())){
            //5.1 未过期，直接返回商户信息
            return merchant;
        }
        //5.2 已过期，需要缓存重建
        //6. 缓存重建
        //6.1 获取互斥锁
        String lockKey = RedisKeys.LOCK_MERCHANT_KEY + id;
        boolean isLock = tryLock(lockKey);
        //6.2 判断是否获取锁成功
        if (isLock){
            //6.3 成功，开启独立线程，实现缓存重建
            CACHE_REBUILD_EXECUTOR.submit(() -> {
                try {
                    //重建缓存
                    this.saveMerchantToRedis(id, 20L);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }finally {
                    //释放锁
                    unLock(lockKey);
                }

            });
        }

        //6.4 返回过期的商户信息
        return merchant;
    }*/


    //互斥锁解决缓存击穿
    /*public Merchant queryWithMutex(Long id){
        String key = RedisKeys.CACHE_MERCHANT_KEY + id;
        //1.从Redis查询商户缓存
        String merchantJson = stringRedisTemplate.opsForValue().get(key);
        //2.判断是否存在
        if (StrUtil.isNotBlank(merchantJson)) {
            //3.存在，直接返回
            return JSONUtil.toBean(merchantJson, Merchant.class);
        }
        //命中且为空字符串
        if (merchantJson != null) {
            //返回一个错误信息
            return null;
        }

        //4.实现缓存重建
        //4.1获取互斥锁
        String lockKey = RedisKeys.LOCK_MERCHANT_KEY + id;
        Merchant merchant = null;
        try {
            boolean isLock = tryLock(lockKey);
            //4.2判断是否获取成功
            if (!isLock) {
                //4.3失败，则休眠并重试
                Thread.sleep(50);
                return queryWithMutex( id);
            }

            //4.4 成功，根据id查询数据库
            merchant = getById(id);
            //模拟重建的延时
            Thread.sleep(200);
            //5.不存在，返回错误
            if (merchant == null){
                //将空值写入Redis
                stringRedisTemplate.opsForValue().set(key, "",RedisKeys.CACHE_NULL_TTL, TimeUnit.MINUTES);
                return null;
            }
            //6.存在，写入Redis
            stringRedisTemplate.opsForValue().set(key, JSONUtil.toJsonStr( merchant),RedisKeys.CACHE_MERCHANT_TTL, TimeUnit.MINUTES);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }finally {
            //7.释放互斥锁
            unLock(lockKey);
        }


        //8.返回
        return merchant;
    }*/

    //空值解决缓存穿透
    /*public Merchant queryWithPassThrough(Long id){
        String key = RedisKeys.CACHE_MERCHANT_KEY + id;
        //1.从Redis查询商户缓存
        String merchantJson = stringRedisTemplate.opsForValue().get(key);
        //2.判断是否存在
        if (StrUtil.isNotBlank(merchantJson)) {
            //3.存在，直接返回
            return JSONUtil.toBean(merchantJson, Merchant.class);
        }
        //判断命中且为空字符串
        if (merchantJson != null) {
            //返回一个错误信息
            return null;
        }
        //4.不存在，根据id查询数据库
        Merchant merchant = getById(id);
        //5.不存在，返回错误
        if (merchant == null){
            //将空值写入Redis
            stringRedisTemplate.opsForValue().set(key, "",RedisKeys.CACHE_NULL_TTL, TimeUnit.MINUTES);
            return null;
        }
        //6.存在，写入Redis
        stringRedisTemplate.opsForValue().set(key, JSONUtil.toJsonStr(merchant),RedisKeys.CACHE_MERCHANT_TTL, TimeUnit.MINUTES);
        //7.返回
        return merchant;
    }*/



    //尝试获取锁
    /*private boolean tryLock(String key){
        Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent(key, "1", 10, TimeUnit.SECONDS);
        return BooleanUtil.isTrue(flag);
    }*/

    //释放锁
    /* private void unLock(String key){
        stringRedisTemplate.delete(key);
    }*/

    //缓存预热
    public void saveMerchantToRedis(Long id, Long expireSeconds) throws InterruptedException {
        //1.查询商户数据
        Merchant merchant = getById(id);
        Thread.sleep(200);
        //2.封装逻辑过期时间
        RedisCachePayload redisData = new RedisCachePayload();
        redisData.setData(merchant);
        redisData.setExpireTime(LocalDateTime.now().plusSeconds(expireSeconds));
        //3.写入Redis
        stringRedisTemplate.opsForValue().set(RedisKeys.CACHE_MERCHANT_KEY + id, JSONUtil.toJsonStr(redisData));
    }



    /**
     * 更新商户信息
     * @param merchant 商户数据
     * @return
     */
    @Override
    @Transactional
    public ApiResult saveMerchant(Merchant merchant) {
        if (merchant.getCategoryId() == null || merchant.getX() == null || merchant.getY() == null) {
            return ApiResult.fail("商户分类和坐标不能为空");
        }
        if (!save(merchant)) {
            return ApiResult.fail("新增商户失败");
        }
        addMerchantToGeo(merchant);
        return ApiResult.ok(merchant.getId());
    }

    @Override
    @Transactional
    public ApiResult update(Merchant merchant) {
        Long id = merchant.getId();
        if (id == null){
            return ApiResult.fail("商户id不能为空");
        }
        Merchant oldMerchant = getById(id);
        if (oldMerchant == null) {
            return ApiResult.fail("商户不存在");
        }
        String key = RedisKeys.CACHE_MERCHANT_KEY + id;

        //1.更新数据库
        if (!updateById(merchant)) {
            return ApiResult.fail("更新商户失败");
        }
        //2.删除缓存
        stringRedisTemplate.delete(key);
        Merchant updatedMerchant = getById(id);
        if (!oldMerchant.getCategoryId().equals(updatedMerchant.getCategoryId())) {
            stringRedisTemplate.opsForGeo().remove(
                    RedisKeys.MERCHANT_GEO_KEY + oldMerchant.getCategoryId(), id.toString());
        }
        addMerchantToGeo(updatedMerchant);
        return ApiResult.ok();
    }

    private void addMerchantToGeo(Merchant merchant) {
        stringRedisTemplate.opsForGeo().add(
                RedisKeys.MERCHANT_GEO_KEY + merchant.getCategoryId(),
                new Point(merchant.getX(), merchant.getY()),
                merchant.getId().toString());
    }

    @Override
    public ApiResult queryMerchantByCategory(Integer categoryId, Integer current, Double x, Double y) {
        // 1. 判断是否需要根据坐标查询
        if (x == null || y == null){
            // 不需要坐标查询，按数据库查询
            Page<Merchant> page = query()
                    .eq("category_id", categoryId)
                    .page(new Page<>(current, GouYuConstants.DEFAULT_PAGE_SIZE));
            // 返回数据
            return ApiResult.ok(page.getRecords());
        }
        // 2. 计算分页参数
        int from = (current -1) * GouYuConstants.DEFAULT_PAGE_SIZE;
        int end = current * GouYuConstants.DEFAULT_PAGE_SIZE;

        // 3. 查询Redis: 按照距离排序、分页.  结果：merchantId,distance
        String key = RedisKeys.MERCHANT_GEO_KEY + categoryId;
        GeoResults<RedisGeoCommands.GeoLocation<String>> results = stringRedisTemplate.opsForGeo() // GEOSEARCH BYLONGLAT x y BYRADIUS 10 WITHDISTANCE
                .search(
                        key,
                        GeoReference.fromCoordinate(x, y),
                        new Distance(5000),
                        RedisGeoCommands.GeoSearchCommandArgs.newGeoSearchArgs().includeDistance().limit(end)
                );
        // 4. 解析出Id
        if (results == null){
            return ApiResult.ok(Collections.emptyList());
        }
        List<GeoResult<RedisGeoCommands.GeoLocation<String>>> list = results.getContent();
        if (list.size() <= from){
            // 没有下一页了，结束
            return ApiResult.ok(Collections.emptyList());
        }
        // 4.1 截取 from ~ end 的部分
        List<Long> ids = new ArrayList<>(list.size());
        Map<String,Distance> distanceMap = new HashMap<>(list.size());
        list.stream().skip(from).forEach(result -> {
            // 4.2 获取商户id
            String merchantIdStr = result.getContent().getName();
            ids.add(Long.valueOf(merchantIdStr));
            // 4.3 获取距离
            Distance distance = result.getDistance();
            distanceMap.put(merchantIdStr, distance);
        });
        // 5. 根据id查询Merchant
        String idStr = StrUtil.join(",", ids);
        List<Merchant> merchants = query().in("id", ids).last("ORDER BY FIELD( id," + idStr + ")").list();
        for (Merchant merchant : merchants) {
            merchant.setDistance(distanceMap.get(merchant.getId().toString()).getValue());
        }
        // 6. 返回
        return ApiResult.ok(merchants);
    }
}
