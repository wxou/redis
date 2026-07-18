# Redis Key 说明

构域所有运行数据使用 `gy:` 命名空间，避免与其他应用冲突。

| Key 模式 | 类型 | TTL | 用途 |
| --- | --- | --- | --- |
| `gy:auth:code:{phone}` | String | 2 分钟 | 登录验证码 |
| `gy:auth:session:{token}` | Hash | 36000 分钟 | 成员会话 |
| `gy:cache:merchant:{id}` | String | 30 分钟 | 商户详情缓存 |
| `gy:cache:merchant-category:list` | String | 3600 分钟 | 分类列表缓存 |
| `gy:lock:merchant:{id}` | String | 10 秒 | 商户缓存重建锁 |
| `gy:limited-benefit:stock:{id}` | String | 无固定 TTL | 限时权益库存 |
| `gy:limited-benefit:order:{id}` | Set | 无固定 TTL | 限时权益领取成员集合 |
| `gy:post:liked:{postId}` | ZSet | 无固定 TTL | 动态点赞成员与时间 |
| `gy:feed:{memberId}` | ZSet | 无固定 TTL | 成员关注流 |
| `gy:following:{memberId}` | Set | 无固定 TTL | 成员关注集合 |
| `gy:merchant:geo:{categoryId}` | GEO | 无固定 TTL | 分类下商户坐标 |
| `gy:check-in:{memberId}:{yyyyMM}` | Bitmap | 无固定 TTL | 月度打卡位图 |
| `gy:id:{business}:{yyyy:MM:dd}` | String | 无固定 TTL | 分布式 ID 日计数器 |
| `gy:stream:benefit-orders` | Stream | 无固定 TTL | 权益领取消息流 |
| `gy:lock:benefit-order:{memberId}` | Lock | 看门狗/业务释放 | 成员权益领取锁 |

## Stream 约定

- Stream：`gy:stream:benefit-orders`
- 消费组：`gy-benefit-order-group`
- 消费者：`gy-benefit-order-consumer`
- 消息字段：`id`、`memberId`、`benefitId`

## 隔离原则

- 初始化和清理只能针对精确的 `gy:*` Key。
- 不允许使用无命名空间的通配删除命令。
- 验证环境不得清理其他项目的 Key。
