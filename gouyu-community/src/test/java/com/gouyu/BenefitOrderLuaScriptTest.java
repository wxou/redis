package com.gouyu;

import io.lettuce.core.RedisClient;
import io.lettuce.core.ScriptOutputType;
import io.lettuce.core.Consumer;
import io.lettuce.core.StreamMessage;
import io.lettuce.core.XReadArgs;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.sync.RedisCommands;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.List;

import static org.junit.jupiter.api.Assumptions.assumeTrue;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;

class BenefitOrderLuaScriptTest {

    private RedisClient client;
    private StatefulRedisConnection<String, String> connection;
    private RedisCommands<String, String> redis;
    private String claimScript;
    private String compensateScript;
    private String finalizeScript;
    private String deadLetterScript;
    private boolean streamSupported;

    private final String benefitId = "990001";
    private final String memberId = "880001";
    private final String orderId = "770001";
    private final String metaKey = "gy:test:limited-benefit:meta:" + benefitId;
    private final String stockKey = "gy:test:limited-benefit:stock:" + benefitId;
    private final String orderKey = "gy:test:limited-benefit:order:" + benefitId;
    private final String requestKey = "gy:test:limited-benefit:request:" + benefitId;
    private final String statusKey = "gy:test:benefit-order:status:" + orderId;
    private final String streamKey = "gy:test:stream:benefit-orders";
    private final String deadLetterStreamKey = "gy:test:stream:benefit-orders:dlq";
    private final String groupName = "gy-test-benefit-order-group";

    @BeforeEach
    void setUp() throws Exception {
        String host = System.getProperty("gouyu.test.redis.host", "127.0.0.1");
        int port = Integer.parseInt(System.getProperty("gouyu.test.redis.port", "6381"));
        client = RedisClient.create("redis://" + host + ":" + port);
        connection = client.connect();
        redis = connection.sync();
        streamSupported = redis.info("server").matches("(?s).*redis_version:([5-9]|[1-9][0-9])\\..*");
        claimScript = readResource("limited_benefit.lua");
        compensateScript = readResource("compensate_benefit_order.lua");
        finalizeScript = readResource("finalize_benefit_order.lua");
        deadLetterScript = readResource("dead_letter_benefit_order.lua");
        cleanup();
    }

    @AfterEach
    void tearDown() {
        if (redis != null) {
            cleanup();
        }
        if (connection != null) {
            connection.close();
        }
        if (client != null) {
            client.shutdown();
        }
    }

    @Test
    void claimShouldAtomicallyReserveAndPublishThenRejectDuplicate() {
        assumeTrue(streamSupported, "Redis Stream requires Redis 5+");
        prepareActiveBenefit(2);

        Long first = claim(memberId, orderId);

        assertEquals(0L, first.longValue());
        assertEquals("1", redis.get(stockKey));
        assertEquals(true, redis.sismember(orderKey, memberId));
        assertEquals(orderId, redis.hget(requestKey, memberId));
        assertEquals("PENDING", redis.hget(statusKey, "status"));
        assertEquals(1L, redis.xlen(streamKey).longValue());

        Long duplicate = claim(memberId, "770002");
        assertEquals(2L, duplicate.longValue());
        assertEquals("1", redis.get(stockKey));
        assertEquals(1L, redis.xlen(streamKey).longValue());
    }

    @Test
    void claimShouldReturnMissingStateAndTimeWindowCodes() {
        Long missing = claim(memberId, orderId);
        assertEquals(3L, missing.longValue());

        long now = Instant.now().getEpochSecond();
        putMeta(now + 60, now + 120);
        redis.set(stockKey, "1");
        assertEquals(4L, claim(memberId, orderId).longValue());

        putMeta(now - 120, now - 60);
        assertEquals(5L, claim(memberId, orderId).longValue());
    }

    @Test
    void compensationShouldRestoreExactlyOnceAndRejectDifferentOwner() {
        redis.set(stockKey, "0");
        redis.sadd(orderKey, memberId);
        redis.hset(requestKey, memberId, orderId);
        redis.hset(statusKey, "status", "PENDING");

        Long compensated = compensate(memberId, orderId);
        assertEquals(0L, compensated.longValue());
        assertEquals("1", redis.get(stockKey));
        assertFalse(redis.sismember(orderKey, memberId));
        assertNull(redis.hget(requestKey, memberId));
        assertEquals("COMPENSATED", redis.hget(statusKey, "status"));

        Long repeated = compensate(memberId, orderId);
        assertEquals(1L, repeated.longValue());
        assertEquals("1", redis.get(stockKey));

        redis.hset(requestKey, memberId, "another-order");
        Long wrongOwner = compensate(memberId, orderId);
        assertEquals(2L, wrongOwner.longValue());
        assertEquals("1", redis.get(stockKey));
    }

    @Test
    void allReliabilityScriptsShouldLoad() {
        redis.scriptLoad(claimScript);
        redis.scriptLoad(compensateScript);
        redis.scriptLoad(finalizeScript);
        redis.scriptLoad(deadLetterScript);
    }

    @Test
    void finalizeShouldAckDeleteAndWriteSuccessAtomically() {
        assumeTrue(streamSupported, "Redis Stream requires Redis 5+");
        String recordId = addAndReadPending("id", orderId);

        Long result = redis.eval(
                finalizeScript,
                ScriptOutputType.INTEGER,
                new String[]{statusKey, streamKey},
                "SUCCESS", "领取成功", "1", "3600", groupName, recordId,
                "2026-07-22T00:00:00"
        );

        assertEquals(0L, result.longValue());
        assertEquals("SUCCESS", redis.hget(statusKey, "status"));
        assertEquals(0L, redis.xpending(streamKey, groupName).getCount());
        assertEquals(0L, redis.xlen(streamKey).longValue());
    }

    @Test
    void deadLetterShouldArchiveThenAckAndDeleteOriginalAtomically() {
        assumeTrue(streamSupported, "Redis Stream requires Redis 5+");
        String recordId = addAndReadPending("broken", "payload");

        Long result = redis.eval(
                deadLetterScript,
                ScriptOutputType.INTEGER,
                new String[]{statusKey, streamKey, deadLetterStreamKey},
                groupName, recordId, orderId, memberId, benefitId, "{broken}",
                "INVALID_MESSAGE", "invalid payload", "5", "3600",
                "2026-07-22T00:00:00"
        );

        assertEquals(0L, result.longValue());
        assertEquals("DEAD_LETTER", redis.hget(statusKey, "status"));
        assertEquals(0L, redis.xpending(streamKey, groupName).getCount());
        assertEquals(0L, redis.xlen(streamKey).longValue());
        assertEquals(1L, redis.xlen(deadLetterStreamKey).longValue());
    }

    private void prepareActiveBenefit(int stock) {
        long now = Instant.now().getEpochSecond();
        putMeta(now - 60, now + 600);
        redis.set(stockKey, String.valueOf(stock));
    }

    private void putMeta(long startsAt, long endsAt) {
        redis.hset(metaKey, "startsAt", String.valueOf(startsAt));
        redis.hset(metaKey, "endsAt", String.valueOf(endsAt));
        redis.hset(metaKey, "enabled", "1");
    }

    private Long claim(String member, String order) {
        return redis.eval(
                claimScript,
                ScriptOutputType.INTEGER,
                new String[]{metaKey, stockKey, orderKey, requestKey,
                        "gy:test:benefit-order:status:" + order, streamKey},
                member, order, "3600", String.valueOf(Instant.now().getEpochSecond())
        );
    }

    private Long compensate(String member, String order) {
        return redis.eval(
                compensateScript,
                ScriptOutputType.INTEGER,
                new String[]{stockKey, orderKey, requestKey, statusKey},
                member, order, "3600", "2026-07-22T00:00:00", "test failure"
        );
    }

    private String addAndReadPending(String field, String value) {
        String recordId = redis.xadd(streamKey, field, value);
        redis.xgroupCreate(XReadArgs.StreamOffset.from(streamKey, "0"), groupName);
        List<StreamMessage<String, String>> messages = redis.xreadgroup(
                Consumer.from(groupName, "consumer-1"),
                XReadArgs.StreamOffset.lastConsumed(streamKey)
        );
        assertEquals(1, messages.size());
        return recordId;
    }

    private void cleanup() {
        redis.del(metaKey, stockKey, orderKey, requestKey, statusKey,
                "gy:test:benefit-order:status:770002", streamKey, deadLetterStreamKey);
    }

    private String readResource(String name) throws Exception {
        try (InputStream input = new ClassPathResource(name).getInputStream();
             ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = input.read(buffer)) >= 0) {
                output.write(buffer, 0, read);
            }
            return new String(output.toByteArray(), StandardCharsets.UTF_8);
        }
    }
}
