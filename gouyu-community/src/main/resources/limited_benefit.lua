---
-- 1.参数列表
-- 1.1 权益id
local benefitId = ARGV[1]
-- 1.2 成员id
local memberId = ARGV[2]
-- 1.3 权益记录id
local benefitOrderId = ARGV[3]

-- 2.数据key
-- 2.1 库存key
local stockKey = "gy:limited-benefit:stock:" .. benefitId
-- 2.2 权益领取去重key
local orderKey = "gy:limited-benefit:order:" .. benefitId

-- 3.脚本业务
-- 3.1 判断库存是否充足 get stockKey
local stock = tonumber(redis.call("get", stockKey))
if (not stock or stock <= 0) then
    -- 3.1.1 库存不足，返回1
    return 1
end
-- 3.2 判断成员是否重复领取 sismember orderKey memberId
if (redis.call("sismember", orderKey, memberId) == 1) then
    -- 3.2.1 重复下单，返回2
    return 2
end
-- 3.3 扣减库存 incrby stockKey -1
redis.call("incrby", stockKey, -1)
-- 3.4 记录已领取成员 sadd orderKey memberId
redis.call("sadd", orderKey, memberId)
-- 3.5 发送消息到队列中，XADD gy:stream:benefit-orders * k1 v1 k2 v1 ...
redis.call("xadd", "gy:stream:benefit-orders", "*", "memberId", memberId, "benefitId", benefitId, "id", benefitOrderId)
return 0
