package com.gouyu;

import com.gouyu.entity.Merchant;
import com.gouyu.service.IMerchantService;
import com.gouyu.service.impl.MerchantServiceImpl;
import com.gouyu.utils.RedisCacheClient;
import com.gouyu.utils.RedisKeys;
import com.gouyu.utils.DistributedIdGenerator;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.StringRedisTemplate;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@SpringBootTest
class GouYuApplicationTests {

    @Resource
    private RedisCacheClient redisCacheClient;

    @Resource
    private MerchantServiceImpl merchantService;

    @Resource
    private DistributedIdGenerator distributedIdGenerator;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    //线程池初始化，创建500个线程，线程复用，避免频繁创建销毁线程
    private ExecutorService ex = Executors.newFixedThreadPool(500);

    @Test
    void testIdWorker() throws InterruptedException {
        //创建倒计时锁,初始计数为 300,等待所有 300 个线程完成任务后再统计总耗时,每次 countDown() 减 1，减到 0 时释放等待的主线程
        CountDownLatch latch = new CountDownLatch(300);

        //定义并发任务，每个线程的任务：循环 100 次生成 ID
        Runnable task = () ->{
            for (int i = 0; i < 100; i++) {
                long id = distributedIdGenerator.nextId("benefit-order");
                System.out.println("id = " + id);
            }
            //当前线程完成，计数器减 1
            latch.countDown();
        };
        long begin = System.currentTimeMillis();
        for (int i = 0; i < 300; i++) {
            ex.submit(task);
        }
        latch.await();
        long end = System.currentTimeMillis();
        System.out.println("耗时：" + (end - begin));
    }

    @Test
    void testSaveMerchant() throws InterruptedException {
        Merchant merchant = merchantService.getById(1L);
        redisCacheClient.setWithLogicalExpire(RedisKeys.CACHE_MERCHANT_KEY + 1L, merchant, 10L, TimeUnit.SECONDS);
    }

    @Test
    void loadMerchantData() {
        // 1. 查询商户信息
        List<Merchant> list = merchantService.list();
        // 2. 把商户分组，按照categoryId分组，id一致的放到一个集合
        Map<Long,List<Merchant>> map = list.stream().collect(Collectors.groupingBy(Merchant::getCategoryId));
        // 3. 分批完成写入Redis
        for (Map.Entry<Long, List<Merchant>> entry : map.entrySet()) {
            // 3.1 获取分类id
            Long categoryId = entry.getKey();
            String key = RedisKeys.MERCHANT_GEO_KEY + categoryId;
            // 3.2 获取同分类的商户集合
            List<Merchant> value = entry.getValue();
            List<RedisGeoCommands.GeoLocation<String>> locations = new ArrayList<>(value.size());
            // 3.3 写入Redis GEOADD key x y member
            for (Merchant merchant : value) {
                //stringRedisTemplate.opsForGeo().add(key , new Point(merchant.getX(),merchant.getY()) , merchant.getId().toString());
                locations.add(new RedisGeoCommands.GeoLocation<>(
                        merchant.getId().toString(),
                        new Point(merchant.getX(),merchant.getY())));
            }
            stringRedisTemplate.opsForGeo().add(key , locations);
        }
    }


    @Test
    void testHyperLogLog(){
        String[] values = new String[1000];
        int j = 0;
        for (int i = 0; i < 1000000; i++) {
            j = i % 1000;
            values[j] = "member_" + i;
            if (j == 999) {
                // 发送到Redis
                stringRedisTemplate.opsForHyperLogLog().add("gy:test:member-hll", values);
            }
        }
        // 统计数量
        Long count = stringRedisTemplate.opsForHyperLogLog().size("gy:test:member-hll");
        System.out.println("count = " + count);
    }


}
