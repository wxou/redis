-- KEYS[1] 订单状态Hash
-- KEYS[2] 原订单Stream
-- ARGV[1] 最终状态
-- ARGV[2] 用户消息
-- ARGV[3] 处理次数
-- ARGV[4] 状态TTL秒数
-- ARGV[5] 消费组
-- ARGV[6] Stream消息ID
-- ARGV[7] 更新时间

redis.call("hmset", KEYS[1],
    "status", ARGV[1],
    "message", ARGV[2],
    "retryCount", ARGV[3],
    "updatedAt", ARGV[7])
redis.call("expire", KEYS[1], tonumber(ARGV[4]))
redis.call("xack", KEYS[2], ARGV[5], ARGV[6])
redis.call("xdel", KEYS[2], ARGV[6])
return 0
