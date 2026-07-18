# 构域项目摘要

## 一句话介绍

构域是一个面向校园和产业园区的社区服务平台，以 Redis 为核心支撑附近商户、内容互动、关注流、每日打卡和高并发限时权益领取。

## 项目边界

本项目完成的是“领域等价包装”，不是业务重写：

- 保留原有核心用例、算法步骤、异常分支和数据规模。
- 允许修改类名、字段名、表名、接口路径和基础设施命名。
- 不升级 Spring Boot、Redis 客户端、MyBatis-Plus 等主要依赖。
- 不顺带修复已知业务缺陷，以免改变行为基线。

## 构域业务域

| 业务域 | 能力 | Redis 数据结构 |
| --- | --- | --- |
| 成员中心 | 验证码登录、会话续期、资料、打卡 | String、Hash、Bitmap |
| 商户发现 | 分类缓存、详情缓存、附近商户 | String、List、GEO |
| 社区动态 | 发布、热门排序、点赞排行 | ZSet |
| 社交关系 | 关注、共同关注、关注流 | Set、ZSet |
| 权益中心 | 库存校验、一人一份、异步持久化 | String、Set、Stream |

## 关键技术路径

### 商户缓存

商户详情查询保留三种 Redis 实践方案：空值缓存防穿透、互斥锁重建缓存、逻辑过期异步重建。缓存 Key 更名为 `gy:cache:merchant:{id}`，实现语义保持不变。

### 附近商户

商户坐标按分类写入 `gy:merchant:geo:{categoryId}`，查询使用 Redis GEO 按距离排序，再按返回 ID 顺序回查 MySQL。

### 社区互动

动态点赞以 `gy:post:liked:{postId}` 的 ZSet 保存成员和时间戳，既支持点赞状态判断，也支持按时间读取点赞成员。关注流使用 `gy:feed:{memberId}` 的 ZSet 和滚动分页。

### 限时权益

`limited_benefit.lua` 在 Redis 内原子执行库存检查、重复领取检查和消息入流。Java 消费者从 `gy:stream:benefit-orders` 读取消息，并在事务中写入权益领取记录。

## 独立性结果

- Maven 坐标：`com.gouyu:gouyu-community`
- Java 根包：`com.gouyu`
- Spring 应用名：`gouyu-community`
- 数据库：`gouyu`
- 数据表：`gy_*`
- API：`/member`、`/merchant`、`/benefit`、`/post` 等
- Redis 命名空间：`gy:*`
- 前端：`web` 内的构域页面与本地资源
- 部署：项目内 `deploy/nginx`
- 配置：无公开明文密码，使用 `GOUYU_*` 环境变量

## 当前技术版本

| 组件 | 版本/范围 |
| --- | --- |
| Java | 8 |
| Spring Boot | 2.3.12.RELEASE |
| MyBatis-Plus | 3.4.3 |
| Spring Data Redis | 2.6.2 |
| Lettuce | 6.1.6.RELEASE |
| Redisson | 3.13.6 |
| MySQL Connector | 5.1.47 |
| Nginx | 1.18.0 |

## 交付判断

构域包装完成的判据不是“页面换名称”，而是代码、数据、接口、缓存、脚本、资源、配置和文档形成一套可独立启动的闭环，同时关键业务行为与改造前基线一致。验证证据记录在 [回归报告](regression-report.md)。
