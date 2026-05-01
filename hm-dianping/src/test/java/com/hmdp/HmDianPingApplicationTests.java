package com.hmdp;

import com.hmdp.entity.Shop;
import com.hmdp.service.IShopService;
import com.hmdp.service.impl.ShopServiceImpl;
import com.hmdp.utils.CacheClient;
import com.hmdp.utils.RedisIdWorker;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import javax.annotation.Resource;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

@SpringBootTest
class HmDianPingApplicationTests {

    @Resource
    private CacheClient cacheClient;

    @Resource
    private ShopServiceImpl shopService;

    @Resource
    private RedisIdWorker redisIdWorker;

    //线程池初始化，创建500个线程，线程复用，避免频繁创建销毁线程
    private ExecutorService ex = Executors.newFixedThreadPool(500);

    @Test
    void testIdWorker() throws InterruptedException {
        //创建倒计时锁,初始计数为 300,等待所有 300 个线程完成任务后再统计总耗时,每次 countDown() 减 1，减到 0 时释放等待的主线程
        CountDownLatch latch = new CountDownLatch(300);

        //定义并发任务，每个线程的任务：循环 100 次生成 ID
        Runnable task = () ->{
            for (int i = 0; i < 100; i++) {
                long id = redisIdWorker.nextId("order");
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
    void testSaveShop() throws InterruptedException {
        Shop shop = shopService.getById(1L);
        cacheClient.setWithLogicalExpire("cache:shop:" + 1L, shop, 10L, TimeUnit.SECONDS);
    }


}
