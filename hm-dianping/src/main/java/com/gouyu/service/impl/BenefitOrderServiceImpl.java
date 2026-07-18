package com.gouyu.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.BenefitOrder;
import com.gouyu.mapper.BenefitOrderMapper;
import com.gouyu.service.ILimitedBenefitService;
import com.gouyu.service.IBenefitOrderService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.utils.DistributedIdGenerator;
import com.gouyu.utils.MemberContext;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.aop.framework.AopContext;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.connection.stream.*;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.time.Duration;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

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
public class BenefitOrderServiceImpl extends ServiceImpl<BenefitOrderMapper, BenefitOrder> implements IBenefitOrderService {

    @Resource
    private ILimitedBenefitService limitedBenefitService;

    @Resource
    private DistributedIdGenerator distributedIdGenerator;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private RedissonClient redissonClient;

    private static final DefaultRedisScript<Long> LIMITED_BENEFIT_SCRIPT;

    static {
        LIMITED_BENEFIT_SCRIPT = new DefaultRedisScript<>();
        LIMITED_BENEFIT_SCRIPT.setLocation(new ClassPathResource("limited_benefit.lua"));
        LIMITED_BENEFIT_SCRIPT.setResultType(Long.class);
    }

    private static final ExecutorService BENEFIT_ORDER_EXECUTOR = Executors.newSingleThreadExecutor();

    @PostConstruct
    private void init() {
        BENEFIT_ORDER_EXECUTOR.submit(new BenefitOrderHandler());
    }


    private class BenefitOrderHandler implements Runnable {
        String queueName = "gy:stream:benefit-orders";
        @Override
        public void run() {
            while (true) {

                try {
                    //1. 获取消息队列中的权益记录信息   XREADGROUP GROUP g1 c1 COUNT 1 BLOCK 2000 STREAMS streams.order >
                    List<MapRecord<String, Object, Object>> list = stringRedisTemplate.opsForStream().read(
                            Consumer.from("gy-benefit-order-group", "gy-benefit-order-consumer"),
                            StreamReadOptions.empty().count(1).block(Duration.ofSeconds(2)),
                            StreamOffset.create(queueName, ReadOffset.lastConsumed())
                    );
                    //2.判断消息获取是否成功
                    if (list == null || list.isEmpty()) {
                        //2.1 如果获取失败，说明没有消息，继续下一次循环
                        continue;
                    }
                    // 3.解析消息中的权益记录信息
                    MapRecord<String, Object, Object> record = list.get(0);
                    Map<Object, Object> values = record.getValue();
                    BenefitOrder benefitOrder = BeanUtil.fillBeanWithMap(values, new BenefitOrder(), true);
                    //4.  如果获取成功，可以领取
                    handleBenefitOrder(benefitOrder);
                    //5. ACK确认  SACK stream.order g1 id
                    stringRedisTemplate.opsForStream().acknowledge(queueName, "gy-benefit-order-group" , record.getId());
                } catch (Exception e) {
                    log.error("处理权益记录异常", e);
                    handlePendingList();
                }
            }
        }
    }

    private void handlePendingList() {
        String queueName = "gy:stream:benefit-orders";
        while (true) {
            try {
                //1. 获取pending-list中的权益记录信息   XREADGROUP GROUP g1 c1 COUNT 1 STREAMS streams.order 0
                List<MapRecord<String, Object, Object>> list = stringRedisTemplate.opsForStream().read(
                        Consumer.from("gy-benefit-order-group", "gy-benefit-order-consumer"),
                        StreamReadOptions.empty().count(1),
                        StreamOffset.create(queueName, ReadOffset.from("0"))
                );
                //2.判断消息获取是否成功
                if (list == null || list.isEmpty()) {
                    //2.1 如果获取失败，说明pending-list没有异常消息，结束循环
                    break;
                }
                // 3.解析消息中的权益记录信息
                MapRecord<String, Object, Object> record = list.get(0);
                Map<Object, Object> values = record.getValue();
                BenefitOrder benefitOrder = BeanUtil.fillBeanWithMap(values, new BenefitOrder(), true);
                //4.  如果获取成功，可以领取
                handleBenefitOrder(benefitOrder);
                //5. ACK确认  SACK stream.order g1 id
                stringRedisTemplate.opsForStream().acknowledge(queueName, "gy-benefit-order-group" , record.getId());
            } catch (Exception e) {
                log.error("处理pending-list权益记录异常", e);
                try {
                    Thread.sleep(20);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    /*private BlockingQueue<BenefitOrder> orderTasks = new ArrayBlockingQueue<>(1024 * 1024);
    private class BenefitOrderHandler implements Runnable {
        @Override
        public void run() {
            while (true) {

                try {
                    //1. 获取队列中的权益记录信息
                    BenefitOrder benefitOrder = orderTasks.take();
                    //2.创建权益记录
                    handleBenefitOrder(benefitOrder);
                } catch (Exception e) {
                    log.error("处理权益记录异常", e);
                }

            }
        }
    }*/

    private void handleBenefitOrder(BenefitOrder benefitOrder) {
        //1. 获取成员
        Long memberId = benefitOrder.getMemberId();
        //2. 创建锁对象
        RLock lock = redissonClient.getLock("gy:lock:benefit-order:" + memberId);
        //3. 获取锁
        boolean isLock = lock.tryLock();
        //4. 判断是否获取锁成功
        if (!isLock) {
            //获取锁失败，返回错误信息或重试
            log.error("不允许重复领取");
            return;
        }

        try {
            proxy.createBenefitOrder(benefitOrder);
        } finally {
            //释放锁
            lock.unlock();
        }
    }

    private IBenefitOrderService proxy;

    /**
     * 限时权益权益
     *
     * @param benefitId 权益id
     * @return 权益记录id
     */
    @Override
    public ApiResult claimLimitedBenefit(Long benefitId) {
        // 获取成员
        Long memberId = MemberContext.getMember().getId();
        //获取权益记录id
        long orderId = distributedIdGenerator.nextId("benefit-order");

        // 1. 执行lua脚本
        Long result = stringRedisTemplate.execute(
                LIMITED_BENEFIT_SCRIPT,
                Collections.emptyList(),
                benefitId.toString(), memberId.toString(),String.valueOf(orderId)
        );
        // 2. 判断结果是否为0
        int r = result.intValue();
        if (r != 0) {
            // 2.1 不为0，代表没有领取资格
            return ApiResult.fail(r == 1 ? "库存不足" : "不能重复领取");
        }

        // 3. 获取代理对象
        proxy = (IBenefitOrderService) AopContext.currentProxy();
        // 4. 返回权益记录 id
        return ApiResult.ok(orderId);

    }


   /* @Override
    public ApiResult claimLimitedBenefit(Long benefitId) {
        // 获取成员
        Long memberId = MemberContext.getMember().getId();
        // 1. 执行lua脚本
        Long result = stringRedisTemplate.execute(
                LIMITED_BENEFIT_SCRIPT,
                Collections.emptyList(),
                benefitId.toString(), memberId.toString()
        );
        // 2. 判断结果是否为0
        int r = result.intValue();
        if (r != 0) {
            // 2.1 不为0，代表没有领取资格
            return ApiResult.fail(r == 1 ? "库存不足" : "不能重复领取");
        }
        // 2.2 为0，有领取资格，把领取信息保存到阻塞队列中
        BenefitOrder benefitOrder = new BenefitOrder();
        // 2.2.1 权益记录id
        long orderId = distributedIdGenerator.nextId("benefit-order");
        benefitOrder.setId(orderId);
        // 2.2.2 成员id
        benefitOrder.setMemberId(memberId);
        // 2.2.3 权益id
        benefitOrder.setBenefitId(benefitId);
        // 2.3 放入阻塞队列中
        orderTasks.add(benefitOrder);

        // 3. 获取代理对象
        proxy = (IBenefitOrderService) AopContext.currentProxy();
        // 4. 返回权益记录 id
        return ApiResult.ok(orderId);

    }*/
    /*@Override
    public ApiResult claimLimitedBenefit(Long benefitId) {
        //1. 查询权益
        LimitedBenefit benefit = limitedBenefitService.getById(benefitId);
        //2. 判断限时权益是否开始
        if (benefit.getStartsAt().isAfter(LocalDateTime.now())) {
            //尚未开始
            return ApiResult.fail("限时权益尚未开始");
        }
        //3. 判断限时权益是否结束
        if (benefit.getEndsAt().isBefore(LocalDateTime.now())) {
            //已结束
            return ApiResult.fail("限时权益已结束");
        }
        //4. 判断库存是否充足
        if (benefit.getStock() < 1) {
            //库存不足
            return ApiResult.fail("库存不足");
        }

        Long memberId = MemberContext.getMember().getId();
        //创建锁对象
        //SimpleRedisDistributedLock lock = new SimpleRedisDistributedLock("order:" + memberId, stringRedisTemplate);
        RLock lock = redissonClient.getLock("gy:lock:benefit-order:" + memberId);
        //获取锁
        boolean isLock = lock.tryLock();
        //判断是否获取锁成功
        if (!isLock){
            //获取锁失败，返回错误信息或重试
            return ApiResult.fail("不允许重复领取");
        }

        try {
            //获取代理对象（事务）
            IBenefitOrderService proxy = (IBenefitOrderService) AopContext.currentProxy();
            return proxy.createBenefitOrder(benefitId);
        } finally {
            //释放锁
            lock.unlock();
        }

    }*/

    @Transactional
    public void createBenefitOrder(BenefitOrder benefitOrder) {
        //5. 一人一单
        Long memberId = benefitOrder.getMemberId();

        //5.1 查询权益记录
        int count = query().eq("member_id", memberId).eq("benefit_id", benefitOrder.getBenefitId()).count();
        //5.2 判断是否存在
        if (count > 0) {
            //成员已经领取过了
            log.error("成员已经领取过了");
            return;
        }
        //6. 扣减库存
        boolean success = limitedBenefitService.update()
                .setSql("stock = stock - 1") //set stock = stock - 1
                .eq("benefit_id", benefitOrder.getBenefitId()).gt("stock", 0) //where id = ? and stock >0
                .update();
        if (!success) {
            //扣减库存失败
            log.error("库存不足");
            return;
        }
        //7. 创建权益记录
        save(benefitOrder);

    }


}
