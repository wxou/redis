-- KEYS[1] Redis库存String
-- KEYS[2] 已领取成员Set
-- KEYS[3] 成员到订单ID的请求所有权Hash
-- KEYS[4] 订单状态Hash
-- ARGV[1] memberId
-- ARGV[2] orderId
-- ARGV[3] 状态TTL秒数
-- ARGV[4] 更新时间
-- ARGV[5] 失败信息

local owner = redis.call("hget", KEYS[3], ARGV[1])
if (not owner) then
    local status = redis.call("hget", KEYS[4], "status")
    if (status == "COMPENSATED") then
        return 1
    end
    return 3
end
if (owner ~= ARGV[2]) then
    return 2
end

redis.call("incrby", KEYS[1], 1)
redis.call("srem", KEYS[2], ARGV[1])
redis.call("hdel", KEYS[3], ARGV[1])
redis.call("hmset", KEYS[4],
    "status", "COMPENSATED",
    "message", ARGV[5],
    "updatedAt", ARGV[4])
redis.call("expire", KEYS[4], tonumber(ARGV[3]))
return 0
