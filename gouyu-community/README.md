# 构域（GouYu Community）

构域是一个面向校园与产业园区的社区服务平台。成员可以发现附近商户、发布社区动态、关注其他成员、浏览关注流、点赞互动、每日打卡，并领取商户提供的限时权益。

本仓库由一个 Redis 实践项目进行等价改造而来。改造保持核心业务流程、算法、缓存策略和并发语义不变，完整替换了工程身份、Java 包、领域模型、数据库表、API、Redis Key、Lua/Stream、演示数据和前端资源。

## 核心能力

- 手机验证码/密码登录、Redis 双重会话期限与认证限流
- 商户分类、详情缓存、附近商户 GEO 检索
- 缓存穿透、缓存击穿和逻辑过期实践
- 社区动态发布、热门动态、点赞排行
- 成员关注、共同关注和 Feed 滚动分页
- Redis Bitmap 每日打卡统计
- Lua 原子校验、Redis Stream 异步权益领取
- 分布式 ID 与分布式锁实践

## 技术栈

- Java 8、Spring Boot 2.3.12
- MyBatis-Plus 3.4.3、MySQL 5.7+
- Spring Data Redis、Lettuce、Redisson
- Vue 2、Axios、Element UI
- Nginx 1.18（Windows 运行时已包含在 `deploy/nginx`）

## 目录结构

```text
.
├─ src/main/java/com/gouyu   后端源码
├─ src/main/resources        配置、Mapper、Lua 与数据库脚本
├─ src/test                  测试与会话令牌辅助工具
├─ web                       构域前端源码与本地资源
├─ deploy/nginx              可直接使用的 Nginx 运行时
└─ docs                      领域、API、数据与回归文档
```

## 环境变量

公开配置不包含数据库和 Redis 密码。启动前按环境设置以下变量：

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `GOUYU_MYSQL_URL` | `jdbc:mysql://127.0.0.1:3306/gouyu?...` | MySQL 连接地址 |
| `GOUYU_MYSQL_USERNAME` | `root` | MySQL 用户名 |
| `GOUYU_MYSQL_PASSWORD` | 空 | MySQL 密码 |
| `GOUYU_REDIS_HOST` | `192.168.100.128` | Redis 地址 |
| `GOUYU_REDIS_PORT` | `6379` | Redis 端口 |
| `GOUYU_REDIS_PASSWORD` | 空 | Redis 密码 |
| `GOUYU_IMAGE_UPLOAD_DIR` | `web/assets` 的绝对路径 | 图片上传根目录 |
| `GOUYU_EXPOSE_LOGIN_CODE` | `true` | 本地无短信服务时返回验证码；公开/生产环境必须设为 `false` |
| `GOUYU_AUTH_SESSION_IDLE_MINUTES` | `120` | 会话空闲有效期，访问时滑动续期 |
| `GOUYU_AUTH_SESSION_ABSOLUTE_HOURS` | `168` | 会话绝对有效期，默认 7 天 |
| `GOUYU_AUTH_CODE_SEND_INTERVAL_SECONDS` | `60` | 同手机号验证码最短发送间隔 |
| `GOUYU_AUTH_CODE_PHONE_DAILY_LIMIT` | `10` | 同手机号 24 小时发送上限 |
| `GOUYU_AUTH_CODE_IP_HOURLY_LIMIT` | `30` | 同 IP 一小时发送上限 |
| `GOUYU_AUTH_LOGIN_IP_LIMIT` | `30` | 登录限流窗口内同 IP 请求上限 |
| `GOUYU_AUTH_AUDIT_RETENTION_DAYS` | `180` | 认证审计日志保留天数 |
| `GOUYU_AUTH_INITIALIZE_AUDIT_SCHEMA` | `true` | 启动时非破坏性创建缺失的认证审计表 |
| `GOUYU_BENEFIT_ORDER_STATUS_TTL_HOURS` | `168` | 异步订单 Redis 状态保留时间 |
| `GOUYU_BENEFIT_ORDER_MAX_RETRIES` | `5` | 消息最大处理次数 |
| `GOUYU_BENEFIT_ORDER_CLAIM_MIN_IDLE_MILLIS` | `30000` | Pending 消息允许接管的最小空闲时间 |
| `GOUYU_BENEFIT_ORDER_INITIALIZE_SCHEMA` | `true` | 启动时非破坏性创建订单处理归档表 |

PowerShell 示例：

```powershell
$env:GOUYU_MYSQL_PASSWORD = '<your-mysql-password>'
$env:GOUYU_REDIS_HOST = '<redis-host>'
$env:GOUYU_REDIS_PASSWORD = '<your-redis-password>'
mvn spring-boot:run
```

## 初始化数据库

数据库脚本只创建独立的 `gouyu` 数据库，不依赖原项目数据库：

```powershell
mysql -h 127.0.0.1 -u root -p < src/main/resources/db/gouyu.sql
```

脚本包含构域领域表、索引和演示数据。详细说明见 [数据库说明](docs/database.md)。

已有数据库升级认证能力时，无需重新导入演示数据，可单独执行：

```powershell
mysql -h 127.0.0.1 -u root -p gouyu < src/main/resources/db/migration/20260718_auth_hardening.sql
```

异步权益订单可靠性升级可单独执行：

```powershell
mysql -h 127.0.0.1 -u root -p gouyu < src/main/resources/db/migration/20260722_benefit_order_reliability.sql
```

应用默认也会以非破坏方式检查并创建缺失的订单处理归档表。

## 启动

1. 启动 MySQL 与 Redis，并初始化 `gouyu` 数据库。
2. 设置连接环境变量。
3. 启动后端：

   ```powershell
   mvn spring-boot:run
   ```

4. 在另一个终端启动 Nginx：

   ```powershell
   cd deploy/nginx
   .\nginx.exe -p "$PWD\" -c conf\nginx.conf
   ```

5. 访问 `http://localhost:8080`。Nginx 将 `/api` 代理到 `http://127.0.0.1:8081`。

## 验证命令

```powershell
mvn -DskipTests clean compile
mvn -DskipTests test-compile
deploy\nginx\nginx.exe -t -p "<项目绝对路径>\deploy\nginx\" -c conf\nginx.conf
```

集成测试会连接 MySQL/Redis，执行前请确认连接的是独立的构域环境。

## 设计文档

- [等价改造计划](docs/gouyu-transformation-plan.md)
- [领域映射](docs/domain-mapping.md)
- [API 说明](docs/api.md)
- [Redis Key 说明](docs/redis-keys.md)
- [数据库说明](docs/database.md)
- [项目摘要](docs/project-summary.md)
- [回归报告](docs/regression-report.md)

## 当前演进状态

项目先完成了不改变核心业务语义的等价包装，随后修复验证码校验、写接口鉴权、上传路径、Stream 初始化、GEO/关注一致性、资料保存和列表 N+1 等技术债，并补齐密码登录、双重会话期限、认证限流和审计。当前共有 35 个可调用路由；原 42 个业务场景与新增 18 项认证安全断言均已通过。仍需生产化处理的内容见[项目总结](docs/project-summary.md)。
