-- 获取锁中的线程标识 get key
-- 比较线程标识与锁中的标识是否一致
if(redis.call('GET', KEYS[1]) == ARGV[1]) then
    -- 一致，释放锁 del key
    return redis.call("del", KEYS[1])
end
-- 不一致，直接返回
return 0