-- KEYS[1] 权益元数据Hash
-- KEYS[2] Redis库存String
-- KEYS[3] 已领取成员Set
-- KEYS[4] 成员到订单ID的请求所有权Hash
-- KEYS[5] 订单处理状态Hash
-- KEYS[6] 订单Stream
-- ARGV[1] memberId
-- ARGV[2] orderId
-- ARGV[3] 状态TTL秒数
-- ARGV[4] 当前Epoch秒数

local startsAt = tonumber(redis.call("hget", KEYS[1], "startsAt"))
local endsAt = tonumber(redis.call("hget", KEYS[1], "endsAt"))
local enabled = redis.call("hget", KEYS[1], "enabled")
if (not startsAt or not endsAt or enabled ~= "1") then
    return 3
end

local now = tonumber(ARGV[4])
if (now < startsAt) then
    return 4
end
if (now > endsAt) then
    return 5
end

local stockValue = redis.call("get", KEYS[2])
if (not stockValue) then
    return 3
end
local stock = tonumber(stockValue)
if (stock <= 0) then
    return 1
end
if (redis.call("sismember", KEYS[3], ARGV[1]) == 1) then
    return 2
end

redis.call("incrby", KEYS[2], -1)
redis.call("sadd", KEYS[3], ARGV[1])
redis.call("hset", KEYS[4], ARGV[1], ARGV[2])
redis.call("hmset", KEYS[5],
    "orderId", ARGV[2],
    "memberId", ARGV[1],
    "status", "PENDING",
    "message", "领取请求已受理",
    "retryCount", "0",
    "updatedAt", tostring(now))
redis.call("expire", KEYS[5], tonumber(ARGV[3]))
redis.call("xadd", KEYS[6], "*",
    "memberId", ARGV[1],
    "benefitId", string.match(KEYS[2], "(%d+)$"),
    "id", ARGV[2],
    "acceptedAt", tostring(now))
return 0
