# Redis Key 说明

构域所有运行数据使用 `gy:` 命名空间，避免与其他应用冲突。

| Key 模式 | 类型 | TTL | 用途 |
| --- | --- | --- | --- |
| `gy:auth:code:{phone}` | String | 2 分钟 | 登录验证码 |
| `gy:auth:session:{token}` | Hash | 空闲 120 分钟、最长 7 天 | 成员会话及签发时间 |
| `gy:auth:limit:code:cooldown:{phone}` | String | 60 秒 | 同手机号验证码发送冷却 |
| `gy:auth:limit:code:phone:{phone}` | String | 24 小时 | 同手机号验证码发送计数 |
| `gy:auth:limit:code:ip:{ip}` | String | 1 小时 | 同 IP 验证码发送计数 |
| `gy:auth:failure:code:{phone}` | String | 2 分钟 | 验证码错误计数，5 次后作废 |
| `gy:auth:limit:login:ip:{ip}` | String | 10 分钟 | 同 IP 登录请求计数 |
| `gy:auth:failure:login:{phone}` | String | 15 分钟 | 单账号登录失败计数 |
| `gy:auth:lock:login:{phone}` | String | 15 分钟 | 登录失败达到阈值后的账号锁 |
| `gy:cache:merchant:{id}` | String | 30 分钟 | 商户详情缓存 |
| `gy:cache:merchant-category:list` | String | 3600 分钟 | 分类列表缓存 |
| `gy:lock:merchant:{id}` | String | 10 秒 | 商户缓存重建锁 |
| `gy:limited-benefit:stock:{id}` | String | 无固定 TTL | 限时权益库存 |
| `gy:limited-benefit:meta:{id}` | Hash | 无固定 TTL | 限时权益开始、结束时间与启用状态 |
| `gy:limited-benefit:order:{id}` | Set | 无固定 TTL | 限时权益领取成员集合 |
| `gy:limited-benefit:request:{id}` | Hash | 无固定 TTL | 成员到订单 ID 的预留所有权 |
| `gy:benefit-order:status:{orderId}` | Hash | 默认 168 小时 | 异步订单处理状态、次数与提示 |
| `gy:post:liked:{postId}` | ZSet | 无固定 TTL | 动态点赞成员与时间 |
| `gy:feed:{memberId}` | ZSet | 无固定 TTL | 成员关注流 |
| `gy:following:{memberId}` | Set | 无固定 TTL | 成员关注集合 |
| `gy:following:loaded:{memberId}` | String | 无固定 TTL | 关注集合已从 MySQL 加载标记 |
| `gy:merchant:geo:{categoryId}` | GEO | 无固定 TTL | 分类下商户坐标 |
| `gy:check-in:{memberId}:{yyyyMM}` | Bitmap | 无固定 TTL | 月度打卡位图 |
| `gy:id:benefit-order:{yyyy:MM:dd}` | String | 无固定 TTL | 权益记录分布式 ID 日计数器 |
| `gy:stream:benefit-orders` | Stream | 无固定 TTL | 权益领取消息流 |
| `gy:stream:benefit-orders:dlq` | Stream | 对账完成后删除 | 超过处理次数的失败消息 |
| `gy:lock:benefit-order:{memberId}:{benefitId}` | Lock | 看门狗/业务释放 | 成员与权益业务键锁 |

## Stream 约定

- Stream：`gy:stream:benefit-orders`
- 消费组：`gy-benefit-order-group`
- 消费者：`gy-benefit-order-consumer-{实例随机后缀}`
- 消息字段：`id`、`memberId`、`benefitId`
- 应用启动时幂等创建 Stream 与消费组，不再依赖外部手工初始化。
- 未确认消息由组级 `XPENDING` 扫描并通过 `XCLAIM` 接管，不局限于当前消费者。
- 成功、补偿或死信迁移后原子执行 `XACK + XDEL`；长期处理历史写入 MySQL。

## 隔离原则

- 初始化和清理只能针对精确的 `gy:*` Key。
- 不允许使用无命名空间的通配删除命令。
- 验证环境不得清理其他项目的 Key。
