-- KEYS[1] 订单状态Hash或毒消息状态Hash
-- KEYS[2] 原订单Stream
-- KEYS[3] 死信Stream
-- ARGV[1] 消费组
-- ARGV[2] 原消息ID
-- ARGV[3] orderId
-- ARGV[4] memberId
-- ARGV[5] benefitId
-- ARGV[6] 原始Payload
-- ARGV[7] 错误码
-- ARGV[8] 错误信息
-- ARGV[9] 处理次数
-- ARGV[10] 状态TTL秒数
-- ARGV[11] 更新时间

redis.call("xadd", KEYS[3], "*",
    "sourceRecordId", ARGV[2],
    "orderId", ARGV[3],
    "memberId", ARGV[4],
    "benefitId", ARGV[5],
    "payload", ARGV[6],
    "errorCode", ARGV[7],
    "errorMessage", ARGV[8],
    "retryCount", ARGV[9],
    "deadLetteredAt", ARGV[11])
redis.call("hmset", KEYS[1],
    "status", "DEAD_LETTER",
    "message", "订单处理失败，请稍后重试",
    "retryCount", ARGV[9],
    "updatedAt", ARGV[11])
redis.call("expire", KEYS[1], tonumber(ARGV[10]))
redis.call("xack", KEYS[2], ARGV[1], ARGV[2])
redis.call("xdel", KEYS[2], ARGV[2])
return 0
