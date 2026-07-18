# 构域项目开发约定

## 项目定位

本项目是面向校园和产业园区的社区服务平台，工程名为 `gouyu-community`，Java 根包为 `com.gouyu`，数据库为 `gouyu`。

## 改动边界

- 未经明确需求，不改变既有业务流程、算法返回值、缓存 TTL、分页大小、Lua 返回码或 Stream 消费顺序。
- 新代码统一使用构域领域词汇：`Member`、`Merchant`、`Benefit`、`Post`、`FollowRelation`。
- 数据库对象统一使用 `gy_` 前缀；Redis Key 统一使用 `gy:` 前缀。
- 公开配置不得写入真实密码、Token、私钥或固定个人环境路径。
- 前端源码位于 `web`，Nginx 运行时位于 `deploy/nginx`，不要维护第二份页面副本。

## 后端结构

```text
com.gouyu
├─ config       Spring、MyBatis、Redisson、Web 配置
├─ controller   REST API
├─ dto          请求、响应与会话数据
├─ entity       构域领域实体
├─ mapper       MyBatis-Plus Mapper
├─ service      服务接口
├─ service.impl 服务实现
└─ utils        Redis、锁、ID、上下文等基础组件
```

## 主要领域

| 领域 | 核心类型 | 说明 |
| --- | --- | --- |
| 成员 | `Member`、`MemberProfile` | 登录、资料、会话、打卡 |
| 商户 | `Merchant`、`MerchantCategory` | 分类、详情缓存、GEO 检索 |
| 权益 | `Benefit`、`LimitedBenefit`、`BenefitOrder` | 限时领取、异步持久化 |
| 内容 | `Post`、`PostComment` | 动态、点赞、热门内容 |
| 社交 | `FollowRelation` | 关注、共同关注、Feed |

## 配置与运行

- 后端端口：`8081`
- 前端端口：`8080`
- API 前缀：Nginx 对外 `/api`，后端控制器不带 `/api`
- MySQL、Redis 和上传路径必须通过 `GOUYU_*` 环境变量覆盖本地差异。
- 初始化脚本：`src/main/resources/db/gouyu.sql`
- 限时权益 Lua：`src/main/resources/limited_benefit.lua`

## 验证要求

至少执行：

```powershell
mvn -DskipTests clean compile
mvn -DskipTests test-compile
```

修改 Nginx 配置时还需执行 `nginx -t`。连接外部 MySQL/Redis 的集成测试必须使用独立构域数据，不能清理或覆盖原项目数据。
