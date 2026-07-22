package com.gouyu.service.impl;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.config.BenefitOrderProperties;
import com.gouyu.dto.ApiResult;
import com.gouyu.dto.BenefitOrderClaimDTO;
import com.gouyu.dto.BenefitOrderStatusDTO;
import com.gouyu.entity.BenefitOrder;
import com.gouyu.entity.BenefitOrderProcess;
import com.gouyu.exception.RetryableBenefitOrderException;
import com.gouyu.mapper.BenefitOrderMapper;
import com.gouyu.service.BenefitOrderFaultInjector;
import com.gouyu.service.BenefitOrderProcessService;
import com.gouyu.service.BenefitOrderStatus;
import com.gouyu.service.BenefitOrderStatusStore;
import com.gouyu.service.IBenefitOrderService;
import com.gouyu.service.ILimitedBenefitService;
import com.gouyu.service.LimitedBenefitRedisStateService;
import com.gouyu.utils.DistributedIdGenerator;
import com.gouyu.utils.MemberContext;
import com.gouyu.utils.RedisKeys;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.core.io.ClassPathResource;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.domain.Range;
import org.springframework.data.redis.connection.RedisStreamCommands;
import org.springframework.data.redis.connection.RedisZSetCommands;
import org.springframework.data.redis.connection.stream.ByteRecord;
import org.springframework.data.redis.connection.stream.Consumer;
import org.springframework.data.redis.connection.stream.MapRecord;
import org.springframework.data.redis.connection.stream.PendingMessage;
import org.springframework.data.redis.connection.stream.PendingMessages;
import org.springframework.data.redis.connection.stream.ReadOffset;
import org.springframework.data.redis.connection.stream.RecordId;
import org.springframework.data.redis.connection.stream.StreamOffset;
import org.springframework.data.redis.connection.stream.StreamReadOptions;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class BenefitOrderServiceImpl extends ServiceImpl<BenefitOrderMapper, BenefitOrder>
        implements IBenefitOrderService {

    private static final ZoneId BUSINESS_ZONE = ZoneId.of("Asia/Shanghai");

    private static final DefaultRedisScript<Long> CLAIM_SCRIPT = script("limited_benefit.lua");
    private static final DefaultRedisScript<Long> COMPENSATE_SCRIPT = script("compensate_benefit_order.lua");
    private static final DefaultRedisScript<Long> FINALIZE_SCRIPT = script("finalize_benefit_order.lua");
    private static final DefaultRedisScript<Long> DEAD_LETTER_SCRIPT = script("dead_letter_benefit_order.lua");

    private final ILimitedBenefitService limitedBenefitService;
    private final DistributedIdGenerator distributedIdGenerator;
    private final StringRedisTemplate stringRedisTemplate;
    private final RedissonClient redissonClient;
    private final BenefitOrderProperties properties;
    private final BenefitOrderProcessService processService;
    private final BenefitOrderStatusStore statusStore;
    private final LimitedBenefitRedisStateService redisStateService;
    private final BenefitOrderFaultInjector faultInjector;
    private final PlatformTransactionManager transactionManager;

    private final String consumerName = "gy-benefit-order-consumer-"
            + UUID.randomUUID().toString().substring(0, 8);
    private final ExecutorService consumerExecutor = Executors.newSingleThreadExecutor(r -> {
        Thread thread = new Thread(r, "gy-benefit-order-consumer");
        thread.setDaemon(true);
        return thread;
    });

    private TransactionTemplate transactionTemplate;
    private volatile boolean running = true;
    private volatile boolean streamReady;
    private volatile String pendingScanCursor;
    private volatile String deadLetterScanCursor;

    public BenefitOrderServiceImpl(ILimitedBenefitService limitedBenefitService,
                                   DistributedIdGenerator distributedIdGenerator,
                                   StringRedisTemplate stringRedisTemplate,
                                   RedissonClient redissonClient,
                                   BenefitOrderProperties properties,
                                   BenefitOrderProcessService processService,
                                   BenefitOrderStatusStore statusStore,
                                   LimitedBenefitRedisStateService redisStateService,
                                   BenefitOrderFaultInjector faultInjector,
                                   PlatformTransactionManager transactionManager) {
        this.limitedBenefitService = limitedBenefitService;
        this.distributedIdGenerator = distributedIdGenerator;
        this.stringRedisTemplate = stringRedisTemplate;
        this.redissonClient = redissonClient;
        this.properties = properties;
        this.processService = processService;
        this.statusStore = statusStore;
        this.redisStateService = redisStateService;
        this.faultInjector = faultInjector;
        this.transactionManager = transactionManager;
    }

    private static DefaultRedisScript<Long> script(String location) {
        DefaultRedisScript<Long> script = new DefaultRedisScript<>();
        script.setLocation(new ClassPathResource(location));
        script.setResultType(Long.class);
        return script;
    }

    @PostConstruct
    private void init() {
        transactionTemplate = new TransactionTemplate(transactionManager);
        ensureStreamGroup();
        streamReady = true;
        consumerExecutor.submit(this::consumeNewMessages);
    }

    @PreDestroy
    private void shutdown() {
        running = false;
        consumerExecutor.shutdownNow();
        try {
            consumerExecutor.awaitTermination(3, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    @Override
    public ApiResult claimLimitedBenefit(Long benefitId) {
        Long memberId = MemberContext.getMember().getId();
        long orderId = distributedIdGenerator.nextId("benefit-order");
        Long result = executeClaim(benefitId, memberId, orderId);
        if (result != null && result == 3L && redisStateService.restoreIfMissing(benefitId)) {
            result = executeClaim(benefitId, memberId, orderId);
        }
        if (result == null) {
            return ApiResult.fail("权益领取服务暂不可用");
        }
        int code = result.intValue();
        if (code != 0) {
            return ApiResult.fail(claimFailureMessage(code));
        }
        return ApiResult.ok(new BenefitOrderClaimDTO(orderId, BenefitOrderStatus.PENDING.name(), "领取请求已受理"));
    }

    private Long executeClaim(Long benefitId, Long memberId, Long orderId) {
        List<String> keys = new ArrayList<>();
        keys.add(RedisKeys.LIMITED_BENEFIT_META_KEY + benefitId);
        keys.add(RedisKeys.LIMITED_BENEFIT_STOCK_KEY + benefitId);
        keys.add(RedisKeys.LIMITED_BENEFIT_ORDER_KEY + benefitId);
        keys.add(RedisKeys.LIMITED_BENEFIT_REQUEST_KEY + benefitId);
        keys.add(RedisKeys.BENEFIT_ORDER_STATUS_KEY + orderId);
        keys.add(RedisKeys.BENEFIT_ORDER_STREAM_KEY);
        return stringRedisTemplate.execute(
                CLAIM_SCRIPT,
                keys,
                memberId.toString(),
                orderId.toString(),
                String.valueOf(statusTtlSeconds()),
                String.valueOf(Instant.now().getEpochSecond())
        );
    }

    private String claimFailureMessage(int code) {
        switch (code) {
            case 1:
                return "库存不足";
            case 2:
                return "不能重复领取";
            case 3:
                return "限时权益不存在或状态未初始化";
            case 4:
                return "限时权益尚未开始";
            case 5:
                return "限时权益已结束";
            default:
                return "权益领取服务暂不可用";
        }
    }

    @Override
    public ApiResult queryOrder(Long orderId) {
        Long memberId = MemberContext.getMember().getId();
        BenefitOrder order = getById(orderId);
        if (order != null) {
            if (!memberId.equals(order.getMemberId())) {
                return ApiResult.fail("权益记录不存在");
            }
            BenefitOrderStatusDTO dto = new BenefitOrderStatusDTO();
            dto.setOrderId(orderId);
            dto.setStatus(BenefitOrderStatus.SUCCESS.name());
            dto.setMessage("领取成功");
            dto.setRetryCount(0);
            dto.setUpdatedAt(order.getUpdatedAt());
            dto.setOrder(order);
            return ApiResult.ok(dto);
        }

        BenefitOrderProcess process = processService.findByOrderId(orderId);
        if (process != null) {
            if (!memberId.equals(process.getMemberId())) {
                return ApiResult.fail("权益记录不存在");
            }
            return ApiResult.ok(fromProcess(process));
        }

        Map<Object, Object> state = statusStore.get(orderId);
        if (state.isEmpty() || !memberId.toString().equals(String.valueOf(state.get("memberId")))) {
            return ApiResult.fail("权益记录不存在");
        }
        return ApiResult.ok(fromRedisState(orderId, state));
    }

    private BenefitOrderStatusDTO fromProcess(BenefitOrderProcess process) {
        BenefitOrderStatusDTO dto = new BenefitOrderStatusDTO();
        dto.setOrderId(process.getOrderId());
        dto.setStatus(publicStatus(process.getStatus()));
        dto.setMessage(publicMessage(process.getStatus(), process.getErrorMessage()));
        dto.setRetryCount(process.getRetryCount());
        dto.setUpdatedAt(process.getUpdatedAt());
        return dto;
    }

    private BenefitOrderStatusDTO fromRedisState(Long orderId, Map<Object, Object> state) {
        BenefitOrderStatusDTO dto = new BenefitOrderStatusDTO();
        String status = String.valueOf(state.get("status"));
        dto.setOrderId(orderId);
        dto.setStatus(publicStatus(status));
        dto.setMessage(publicMessage(status, String.valueOf(state.get("message"))));
        dto.setRetryCount(parseInteger(state.get("retryCount"), 0));
        dto.setUpdatedAt(parseUpdatedAt(state.get("updatedAt")));
        return dto;
    }

    private String publicStatus(String status) {
        if (BenefitOrderStatus.COMPENSATED.name().equals(status)
                || BenefitOrderStatus.DEAD_LETTER.name().equals(status)) {
            return BenefitOrderStatus.FAILED.name();
        }
        return status;
    }

    private String publicMessage(String status, String detail) {
        if (BenefitOrderStatus.COMPENSATED.name().equals(status)) {
            return "领取失败，资格与库存已恢复";
        }
        if (BenefitOrderStatus.DEAD_LETTER.name().equals(status)) {
            return "订单处理失败，请稍后重试";
        }
        return detail == null || "null".equals(detail) || detail.isEmpty() ? "订单处理中" : detail;
    }

    private LocalDateTime parseUpdatedAt(Object value) {
        if (value == null) {
            return null;
        }
        String text = String.valueOf(value);
        try {
            if (text.matches("\\d+")) {
                return LocalDateTime.ofInstant(Instant.ofEpochSecond(Long.parseLong(text)), BUSINESS_ZONE);
            }
            return LocalDateTime.parse(text);
        } catch (RuntimeException e) {
            return null;
        }
    }

    private void consumeNewMessages() {
        while (running) {
            try {
                List<MapRecord<String, Object, Object>> records = stringRedisTemplate.opsForStream().read(
                        Consumer.from(RedisKeys.BENEFIT_ORDER_STREAM_GROUP, consumerName),
                        StreamReadOptions.empty().count(1).block(Duration.ofSeconds(2)),
                        StreamOffset.create(RedisKeys.BENEFIT_ORDER_STREAM_KEY, ReadOffset.lastConsumed())
                );
                if (records == null || records.isEmpty()) {
                    continue;
                }
                MapRecord<String, Object, Object> record = records.get(0);
                processRecord(record.getId().getValue(), stringify(record.getValue()), 1);
            } catch (Exception e) {
                if (running) {
                    log.error("读取限时权益订单消息失败", e);
                }
            }
        }
    }

    @Scheduled(fixedDelayString = "${gouyu.benefit-order.claim-interval-millis:10000}")
    public void recoverStalePendingMessages() {
        if (!streamReady || !running) {
            return;
        }
        try {
            PendingMessages pending = stringRedisTemplate.opsForStream().pending(
                    RedisKeys.BENEFIT_ORDER_STREAM_KEY,
                    RedisKeys.BENEFIT_ORDER_STREAM_GROUP,
                    rangeAfter(pendingScanCursor),
                    properties.getClaimBatchSize()
            );
            List<PendingMessage> stale = new ArrayList<>();
            String lastRecordId = null;
            for (PendingMessage message : pending) {
                lastRecordId = message.getIdAsString();
                if (message.getElapsedTimeSinceLastDelivery().toMillis() >= properties.getClaimMinIdleMillis()) {
                    stale.add(message);
                }
            }
            pendingScanCursor = pending.size() < properties.getClaimBatchSize() ? null : lastRecordId;
            if (stale.isEmpty()) {
                return;
            }
            Map<String, Integer> deliveryCounts = new HashMap<>();
            List<RecordId> ids = new ArrayList<>();
            for (PendingMessage message : stale) {
                ids.add(message.getId());
                deliveryCounts.put(message.getIdAsString(), (int) message.getTotalDeliveryCount() + 1);
            }
            List<ByteRecord> claimed = claimPending(ids);
            if (claimed == null) {
                return;
            }
            for (ByteRecord record : claimed) {
                MapRecord<String, String, String> decoded = record.deserialize(
                        stringRedisTemplate.getStringSerializer(),
                        stringRedisTemplate.getStringSerializer(),
                        stringRedisTemplate.getStringSerializer()
                );
                String recordId = decoded.getId().getValue();
                processRecord(recordId, new LinkedHashMap<>(decoded.getValue()),
                        deliveryCounts.getOrDefault(recordId, 2));
            }
        } catch (Exception e) {
            log.error("接管其他消费者Pending消息失败", e);
        }
    }

    @Scheduled(fixedDelayString = "${gouyu.benefit-order.dead-letter-reconcile-interval-millis:60000}")
    public void reconcileDeadLetters() {
        if (!streamReady || !running) {
            return;
        }
        try {
            List<MapRecord<String, Object, Object>> records = stringRedisTemplate.opsForStream().range(
                    RedisKeys.BENEFIT_ORDER_DEAD_LETTER_STREAM_KEY,
                    rangeAfter(deadLetterScanCursor),
                    RedisZSetCommands.Limit.limit().count(properties.getClaimBatchSize())
            );
            if (records == null || records.isEmpty()) {
                deadLetterScanCursor = null;
                return;
            }
            deadLetterScanCursor = records.size() < properties.getClaimBatchSize()
                    ? null : records.get(records.size() - 1).getId().getValue();
            for (MapRecord<String, Object, Object> record : records) {
                try {
                    reconcileDeadLetter(record);
                } catch (Exception e) {
                    log.error("单条死信订单对账失败，保留消息等待下轮重试，recordId={}",
                            record.getId().getValue(), e);
                }
            }
        } catch (Exception e) {
            log.error("死信订单自动对账失败，将在下个周期重试", e);
        }
    }

    private void reconcileDeadLetter(MapRecord<String, Object, Object> record) {
        Map<String, String> payload = stringify(record.getValue());
        String sourceRecordId = payload.get("sourceRecordId");
        if (sourceRecordId == null || sourceRecordId.trim().isEmpty()) {
            sourceRecordId = "dlq:" + record.getId().getValue();
        }
        BenefitOrder order = parseDeadLetterOrder(payload);
        if (order == null) {
            processService.record(sourceRecordId, null, null, null,
                    BenefitOrderStatus.DEAD_LETTER,
                    parseInteger(payload.get("retryCount"), properties.getMaxRetries()),
                    payload.get("errorCode"), payload.get("errorMessage"), payload.get("payload"), true);
            stringRedisTemplate.opsForStream().delete(
                    RedisKeys.BENEFIT_ORDER_DEAD_LETTER_STREAM_KEY, record.getId());
            return;
        }

        BenefitOrder existingById = getById(order.getId());
        int retryCount = parseInteger(payload.get("retryCount"), properties.getMaxRetries());
        if (existingById != null && sameBusinessOrder(existingById, order)) {
            processService.record(sourceRecordId, order.getId(), order.getMemberId(), order.getBenefitId(),
                    BenefitOrderStatus.SUCCESS, retryCount, null, null, payload.get("payload"), true);
            statusStore.update(order.getId(), order.getMemberId(), order.getBenefitId(),
                    BenefitOrderStatus.SUCCESS, "领取成功", retryCount);
            stringRedisTemplate.opsForStream().delete(
                    RedisKeys.BENEFIT_ORDER_DEAD_LETTER_STREAM_KEY, record.getId());
            return;
        }

        Long compensation = stringRedisTemplate.execute(
                COMPENSATE_SCRIPT,
                compensationKeys(order),
                order.getMemberId().toString(),
                order.getId().toString(),
                String.valueOf(statusTtlSeconds()),
                LocalDateTime.now().toString(),
                "订单处理失败，资格与库存已恢复"
        );
        if (compensation == null || (compensation != 0L && compensation != 1L)) {
            throw new RetryableBenefitOrderException("DLQ_COMPENSATION_REJECTED",
                    "死信补偿被拒绝，返回码=" + compensation);
        }
        processService.record(sourceRecordId, order.getId(), order.getMemberId(), order.getBenefitId(),
                BenefitOrderStatus.COMPENSATED, retryCount,
                payload.get("errorCode"), payload.get("errorMessage"), payload.get("payload"), true);
        statusStore.update(order.getId(), order.getMemberId(), order.getBenefitId(),
                BenefitOrderStatus.COMPENSATED, "领取失败，资格与库存已恢复", retryCount);
        stringRedisTemplate.opsForStream().delete(
                RedisKeys.BENEFIT_ORDER_DEAD_LETTER_STREAM_KEY, record.getId());
    }

    private BenefitOrder parseDeadLetterOrder(Map<String, String> payload) {
        try {
            if (payload.get("orderId") == null || payload.get("orderId").isEmpty()
                    || payload.get("memberId") == null || payload.get("memberId").isEmpty()
                    || payload.get("benefitId") == null || payload.get("benefitId").isEmpty()) {
                return null;
            }
            BenefitOrder order = new BenefitOrder();
            order.setId(Long.valueOf(payload.get("orderId")));
            order.setMemberId(Long.valueOf(payload.get("memberId")));
            order.setBenefitId(Long.valueOf(payload.get("benefitId")));
            return order;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private List<ByteRecord> claimPending(List<RecordId> ids) {
        return stringRedisTemplate.execute((RedisCallback<List<ByteRecord>>) connection ->
                connection.streamCommands().xClaim(
                        RedisKeys.BENEFIT_ORDER_STREAM_KEY.getBytes(StandardCharsets.UTF_8),
                        RedisKeys.BENEFIT_ORDER_STREAM_GROUP,
                        consumerName,
                        RedisStreamCommands.XClaimOptions.minIdle(
                                Duration.ofMillis(properties.getClaimMinIdleMillis())
                        ).ids(ids)
                )
        );
    }

    private void processRecord(String recordId, Map<String, String> payload, int deliveryCount) {
        BenefitOrder order;
        try {
            order = parseOrder(payload);
        } catch (RuntimeException e) {
            handleRetryOrDeadLetter(recordId, payload, null, deliveryCount, "INVALID_MESSAGE", e);
            return;
        }

        try {
            statusStore.update(order.getId(), order.getMemberId(), order.getBenefitId(),
                    BenefitOrderStatus.PROCESSING, "订单处理中", deliveryCount);
            ProcessingResult result = handleBenefitOrder(recordId, payload, order, deliveryCount);
            if (result.getOutcome() == ProcessingOutcome.SUCCESS) {
                finalizeMessage(recordId, order, BenefitOrderStatus.SUCCESS, "领取成功", deliveryCount);
            } else {
                compensateAndFinalize(recordId, payload, order, deliveryCount, result);
            }
        } catch (RetryableBenefitOrderException e) {
            handleRetryOrDeadLetter(recordId, payload, order, deliveryCount, e.getErrorCode(), e);
        } catch (Exception e) {
            handleRetryOrDeadLetter(recordId, payload, order, deliveryCount, "UNEXPECTED_ERROR", e);
        }
    }

    private ProcessingResult handleBenefitOrder(String recordId, Map<String, String> payload,
                                                BenefitOrder order, int deliveryCount) {
        faultInjector.beforeLock(order);
        String lockKey = RedisKeys.BENEFIT_ORDER_LOCK_KEY + order.getMemberId() + ":" + order.getBenefitId();
        RLock lock = redissonClient.getLock(lockKey);
        boolean acquired;
        try {
            acquired = lock.tryLock(properties.getLockWaitMillis(), TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RetryableBenefitOrderException("LOCK_INTERRUPTED", "获取订单锁时线程被中断", e);
        }
        if (!acquired) {
            throw new RetryableBenefitOrderException("LOCK_BUSY", "订单正在由其他消费者处理");
        }
        try {
            return transactionTemplate.execute(status -> persistOrder(recordId, payload, order, deliveryCount));
        } catch (DuplicateKeyException e) {
            BenefitOrder existing = findExistingOrder(order);
            if (existing != null && existing.getId().equals(order.getId())) {
                return ProcessingResult.success();
            }
            if (existing != null) {
                return ProcessingResult.compensate("DUPLICATE_BENEFIT", "成员已经领取该权益");
            }
            throw new RetryableBenefitOrderException("DUPLICATE_KEY_UNRESOLVED", "唯一键冲突后无法确认既有订单", e);
        } catch (RetryableBenefitOrderException e) {
            throw e;
        } catch (RuntimeException e) {
            throw new RetryableBenefitOrderException("DATABASE_ERROR", "数据库事务执行失败", e);
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    private ProcessingResult persistOrder(String recordId, Map<String, String> payload,
                                          BenefitOrder order, int deliveryCount) {
        BenefitOrder byId = getById(order.getId());
        if (byId != null) {
            if (sameBusinessOrder(byId, order)) {
                processService.record(recordId, order.getId(), order.getMemberId(), order.getBenefitId(),
                        BenefitOrderStatus.SUCCESS, deliveryCount, null, null, JSONUtil.toJsonStr(payload), true);
                return ProcessingResult.success();
            }
            throw new RetryableBenefitOrderException("ORDER_ID_CONFLICT", "订单ID已被其他业务记录占用");
        }

        BenefitOrder existing = findExistingOrder(order);
        if (existing != null) {
            return ProcessingResult.compensate("DUPLICATE_BENEFIT", "成员已经领取该权益");
        }

        faultInjector.beforePersist(order);
        boolean stockUpdated = limitedBenefitService.update()
                .setSql("stock = stock - 1")
                .eq("benefit_id", order.getBenefitId())
                .gt("stock", 0)
                .update();
        if (!stockUpdated) {
            return ProcessingResult.compensate("DATABASE_OUT_OF_STOCK", "数据库库存不足");
        }
        if (!save(order)) {
            throw new RetryableBenefitOrderException("ORDER_SAVE_FAILED", "保存权益订单失败");
        }
        processService.record(recordId, order.getId(), order.getMemberId(), order.getBenefitId(),
                BenefitOrderStatus.SUCCESS, deliveryCount, null, null, JSONUtil.toJsonStr(payload), true);
        return ProcessingResult.success();
    }

    private BenefitOrder findExistingOrder(BenefitOrder order) {
        return query()
                .eq("member_id", order.getMemberId())
                .eq("benefit_id", order.getBenefitId())
                .last("LIMIT 1")
                .one();
    }

    private boolean sameBusinessOrder(BenefitOrder left, BenefitOrder right) {
        return left.getMemberId().equals(right.getMemberId())
                && left.getBenefitId().equals(right.getBenefitId());
    }

    private void compensateAndFinalize(String recordId, Map<String, String> payload,
                                       BenefitOrder order, int deliveryCount, ProcessingResult result) {
        if (getById(order.getId()) != null) {
            finalizeMessage(recordId, order, BenefitOrderStatus.SUCCESS, "领取成功", deliveryCount);
            return;
        }
        faultInjector.beforeCompensate(order);
        Long compensation = stringRedisTemplate.execute(
                COMPENSATE_SCRIPT,
                compensationKeys(order),
                order.getMemberId().toString(),
                order.getId().toString(),
                String.valueOf(statusTtlSeconds()),
                LocalDateTime.now().toString(),
                result.getMessage()
        );
        if (compensation == null || (compensation != 0L && compensation != 1L)) {
            throw new RetryableBenefitOrderException("COMPENSATION_REJECTED",
                    "补偿脚本拒绝执行，返回码=" + compensation);
        }
        processService.record(recordId, order.getId(), order.getMemberId(), order.getBenefitId(),
                BenefitOrderStatus.COMPENSATED, deliveryCount, result.getErrorCode(), result.getMessage(),
                JSONUtil.toJsonStr(payload), true);
        finalizeMessage(recordId, order, BenefitOrderStatus.COMPENSATED,
                "领取失败，资格与库存已恢复", deliveryCount);
    }

    private List<String> compensationKeys(BenefitOrder order) {
        List<String> keys = new ArrayList<>();
        keys.add(RedisKeys.LIMITED_BENEFIT_STOCK_KEY + order.getBenefitId());
        keys.add(RedisKeys.LIMITED_BENEFIT_ORDER_KEY + order.getBenefitId());
        keys.add(RedisKeys.LIMITED_BENEFIT_REQUEST_KEY + order.getBenefitId());
        keys.add(RedisKeys.BENEFIT_ORDER_STATUS_KEY + order.getId());
        return keys;
    }

    private void finalizeMessage(String recordId, BenefitOrder order, BenefitOrderStatus status,
                                 String message, int deliveryCount) {
        faultInjector.beforeFinalize(order);
        Long result = stringRedisTemplate.execute(
                FINALIZE_SCRIPT,
                asList(RedisKeys.BENEFIT_ORDER_STATUS_KEY + order.getId(), RedisKeys.BENEFIT_ORDER_STREAM_KEY),
                status.name(),
                message,
                String.valueOf(deliveryCount),
                String.valueOf(statusTtlSeconds()),
                RedisKeys.BENEFIT_ORDER_STREAM_GROUP,
                recordId,
                LocalDateTime.now().toString()
        );
        if (result == null) {
            throw new RetryableBenefitOrderException("FINALIZE_FAILED", "订单终态写入与消息确认失败");
        }
    }

    private void handleRetryOrDeadLetter(String recordId, Map<String, String> payload, BenefitOrder order,
                                         int deliveryCount, String errorCode, Exception error) {
        String message = safeMessage(error);
        if (deliveryCount >= properties.getMaxRetries()) {
            moveToDeadLetter(recordId, payload, order, deliveryCount, errorCode, message);
            return;
        }
        if (order != null) {
            try {
                statusStore.update(order.getId(), order.getMemberId(), order.getBenefitId(),
                        BenefitOrderStatus.RETRYING, "订单处理暂时失败，正在重试", deliveryCount);
            } catch (RuntimeException statusError) {
                log.error("更新订单重试状态失败，orderId={}", order.getId(), statusError);
            }
        }
        try {
            processService.record(recordId, order == null ? null : order.getId(),
                    order == null ? null : order.getMemberId(), order == null ? null : order.getBenefitId(),
                    BenefitOrderStatus.RETRYING, deliveryCount, errorCode, message,
                    JSONUtil.toJsonStr(payload), false);
        } catch (RuntimeException processError) {
            log.error("持久化订单重试记录失败，recordId={}", recordId, processError);
        }
        log.warn("权益订单处理失败且未ACK，recordId={}, deliveryCount={}, errorCode={}",
                recordId, deliveryCount, errorCode, error);
    }

    private void moveToDeadLetter(String recordId, Map<String, String> payload, BenefitOrder order,
                                  int deliveryCount, String errorCode, String errorMessage) {
        try {
            processService.record(recordId, order == null ? null : order.getId(),
                    order == null ? null : order.getMemberId(), order == null ? null : order.getBenefitId(),
                    BenefitOrderStatus.DEAD_LETTER, deliveryCount, errorCode, errorMessage,
                    JSONUtil.toJsonStr(payload), true);
        } catch (RuntimeException e) {
            log.error("死信写入MySQL归档失败，将保留Redis死信Payload，recordId={}", recordId, e);
        }
        String statusKey = order == null
                ? RedisKeys.BENEFIT_ORDER_STATUS_KEY + "stream:" + recordId
                : RedisKeys.BENEFIT_ORDER_STATUS_KEY + order.getId();
        Long result = stringRedisTemplate.execute(
                DEAD_LETTER_SCRIPT,
                asList(statusKey, RedisKeys.BENEFIT_ORDER_STREAM_KEY,
                        RedisKeys.BENEFIT_ORDER_DEAD_LETTER_STREAM_KEY),
                RedisKeys.BENEFIT_ORDER_STREAM_GROUP,
                recordId,
                order == null ? "" : order.getId().toString(),
                order == null ? "" : order.getMemberId().toString(),
                order == null ? "" : order.getBenefitId().toString(),
                JSONUtil.toJsonStr(payload),
                errorCode,
                errorMessage,
                String.valueOf(deliveryCount),
                String.valueOf(statusTtlSeconds()),
                LocalDateTime.now().toString()
        );
        if (result == null) {
            log.error("消息转移死信失败，保留Pending等待下次接管，recordId={}", recordId);
        }
    }

    private BenefitOrder parseOrder(Map<String, String> payload) {
        BenefitOrder order = new BenefitOrder();
        order.setId(requiredLong(payload, "id"));
        order.setMemberId(requiredLong(payload, "memberId"));
        order.setBenefitId(requiredLong(payload, "benefitId"));
        return order;
    }

    private Long requiredLong(Map<String, String> payload, String field) {
        String value = payload.get(field);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("消息缺少字段: " + field);
        }
        return Long.valueOf(value);
    }

    private Map<String, String> stringify(Map<Object, Object> source) {
        Map<String, String> result = new LinkedHashMap<>();
        for (Map.Entry<Object, Object> entry : source.entrySet()) {
            result.put(String.valueOf(entry.getKey()), String.valueOf(entry.getValue()));
        }
        return result;
    }

    private int parseInteger(Object value, int defaultValue) {
        try {
            return value == null ? defaultValue : Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String safeMessage(Throwable error) {
        String message = error.getMessage();
        if (message == null || message.trim().isEmpty()) {
            return error.getClass().getSimpleName();
        }
        return message.length() <= 255 ? message : message.substring(0, 255);
    }

    private long statusTtlSeconds() {
        return TimeUnit.HOURS.toSeconds(properties.getStatusTtlHours());
    }

    private List<String> asList(String first, String second) {
        List<String> keys = new ArrayList<>();
        keys.add(first);
        keys.add(second);
        return keys;
    }

    private List<String> asList(String first, String second, String third) {
        List<String> keys = asList(first, second);
        keys.add(third);
        return keys;
    }

    private Range<String> rangeAfter(String cursor) {
        return cursor == null
                ? Range.unbounded()
                : Range.rightUnbounded(Range.Bound.exclusive(cursor));
    }

    private void ensureStreamGroup() {
        RecordId bootstrapId = null;
        try {
            if (Boolean.FALSE.equals(stringRedisTemplate.hasKey(RedisKeys.BENEFIT_ORDER_STREAM_KEY))) {
                Map<String, String> bootstrap = Collections.singletonMap("bootstrap", "1");
                bootstrapId = stringRedisTemplate.opsForStream()
                        .add(RedisKeys.BENEFIT_ORDER_STREAM_KEY, bootstrap);
            }
            stringRedisTemplate.opsForStream().createGroup(
                    RedisKeys.BENEFIT_ORDER_STREAM_KEY,
                    ReadOffset.from("0"),
                    RedisKeys.BENEFIT_ORDER_STREAM_GROUP
            );
        } catch (Exception e) {
            if (e.getMessage() == null || !e.getMessage().contains("BUSYGROUP")) {
                throw e;
            }
        } finally {
            if (bootstrapId != null) {
                stringRedisTemplate.opsForStream().delete(RedisKeys.BENEFIT_ORDER_STREAM_KEY, bootstrapId);
            }
        }
    }

    @Getter
    @AllArgsConstructor
    private static class ProcessingResult {
        private final ProcessingOutcome outcome;
        private final String errorCode;
        private final String message;

        static ProcessingResult success() {
            return new ProcessingResult(ProcessingOutcome.SUCCESS, null, null);
        }

        static ProcessingResult compensate(String errorCode, String message) {
            return new ProcessingResult(ProcessingOutcome.COMPENSATE, errorCode, message);
        }
    }

    private enum ProcessingOutcome {
        SUCCESS,
        COMPENSATE
    }
}
