# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在本仓库中工作时提供指引。

## 项目概述

**hm-dianping（黑马点评）** — Spring Boot 2.3.12 教学演示项目，核心目标是展示 Redis 的各种实际应用场景。类似大众点评的本地生活平台，包含商铺、优惠券、秒杀、探店笔记、社交关注等功能。**Redis 使用模式是本项目的核心价值，业务逻辑服务于 Redis 教学。**

## 技术栈

- Java 8, Spring Boot 2.3.12
- MyBatis-Plus 3.4.3, MySQL 5.x
- Redis（Lettuce 6.1.6 + Spring Data Redis 2.6.2）
- Redisson 3.13.6（分布式锁）
- Hutool 5.7.17（工具库）
- Lua 脚本（原子化 Redis 操作）

## 分层架构

```
Controller → Service（接口 + 实现） → Mapper（MyBatis-Plus BaseMapper）
                                     → Redis（StringRedisTemplate）
                                     → Lua 脚本（classpath 资源）
```

主要包：
- `controller/` — REST 接口
- `service/impl/` — 业务逻辑 + Redis 交互
- `utils/` — Redis 工具（ID 生成器、缓存客户端、分布式锁、拦截器）
- `config/` — Spring 配置（MVC 拦截器、Redisson、MyBatis-Plus）
- `dto/` — 数据传输对象（Result、ScrollResult、LoginFormDTO、UserDTO）
- `entity/` — 数据库实体（Shop、Voucher、VoucherOrder、Blog、User 等）

## Redis 模式一览（本项目核心）

| 模式 | 实现方式 | 关键文件 |
|---|---|---|
| 缓存穿透 | 缓存空值，设置短 TTL | `CacheClient.queryWithPassThrough()` |
| 缓存击穿 | 互斥锁 或 逻辑过期 + 异步重建 | `CacheClient.queryWithLogicalExpire()`, `ShopServiceImpl` |
| 分布式锁 | `SET NX EX` + Lua 解锁；Redisson `RLock` | `SimpleRedisLock`, `RedissonConfig` |
| 全局 ID | 时间戳 << 32 \| Redis 自增（按天） | `RedisIdWorker` |
| 异步秒杀 | Lua（库存检查 + 去重）→ Redis Stream → 异步消费 | `seckill.lua`, `VoucherOrderServiceImpl` |
| GEO 附近商户 | `GEOSEARCH` 按类型查询，Java 端分页 | `ShopServiceImpl.queryShopByType()` |
| Set 关注关系 | 关注集合、共同关注交集 | `FollowServiceImpl` |
| ZSet 点赞/推送 | 笔记点赞排行（top5）、Feed 流时间线 | `BlogServiceImpl` |
| BitMap 签到 | 按 `sign:` 前缀存储（Controller 层实现） | `RedisConstants` 常量定义 |
| Token 刷新 | 双层拦截器：刷新（order=0）+ 登录校验（order=1） | `RefreshTokenInterceptor`, `LoginInterceptor` |

## 构建与运行

```bash
# 编译（跳过测试，测试需要外部 Redis/MySQL）
mvn clean package -DskipTests

# 启动
mvn spring-boot:run
```

服务默认端口 8081（配置在 `application.yaml`）。

## 外部依赖

- **MySQL**: `127.0.0.1:3306`，库名 `hmdp`，建表脚本见 `src/main/resources/db/hmdp.sql`
- **Redis**: `192.168.100.128:6379`（密码 `123321`）
- **Nginx**: 提供静态资源和前端页面，图片上传目录配置在 `SystemConstants.IMAGE_UPLOAD_DIR`

## 关键设计决策

- **Token 认证**：登录返回 token 存入 Redis 并设 TTL。`RefreshTokenInterceptor` 每次请求刷新 TTL；`LoginInterceptor` 校验受保护接口的登录状态
- **缓存策略**：旁路缓存（Cache-Aside），读时先查缓存再回源 DB，写时先更新 DB 再删除缓存
- **秒杀流程**：Lua 脚本原子化完成"检查库存 + 一人一单校验 + 扣减"，然后写入 Redis Stream。后台线程异步消费 Stream，落库创建订单
- **Feed 推送**：推模式（写扩散）。用户发笔记时，将笔记 ID 推送给所有粉丝的 ZSet 收件箱（按时间戳排序）
- **ThreadLocal 用户**：`UserHolder` 通过 ThreadLocal 存储当前登录用户，拦截器在进入 Controller 前设置

## 测试

```bash
mvn test
```

测试需要运行中的 Redis 和 MySQL 实例。主要测试文件：
- `HmDianPingApplicationTests.java` — 基础上下文加载
- `RedissonTest.java` — Redisson 客户端连接测试
- `GetTokenTest.java` — Token 生成工具
