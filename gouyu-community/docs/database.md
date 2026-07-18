# 构域数据库说明

## 初始化

脚本位置：`src/main/resources/db/gouyu.sql`。

脚本通过 `CREATE DATABASE IF NOT EXISTS` 创建并选择独立的 `gouyu` 数据库，然后重建其中的 `gy_*` 表和演示数据，不修改或删除其他数据库。生产或共享环境执行前应先备份，并确认目标库名。

## 表结构

| 表 | 领域 | 说明 |
| --- | --- | --- |
| `gy_member` | 成员 | 登录主体与基础资料 |
| `gy_member_profile` | 成员 | 成员扩展资料 |
| `gy_auth_audit_log` | 认证 | 登录、验证码、密码和会话安全事件审计 |
| `gy_check_in_record` | 成员 | 打卡关系表（Bitmap 为主要运行路径） |
| `gy_merchant` | 商户 | 商户、坐标、评分与营业信息 |
| `gy_merchant_category` | 商户 | 商户分类 |
| `gy_benefit` | 权益 | 权益基础信息 |
| `gy_limited_benefit` | 权益 | 限时库存与时间窗口 |
| `gy_benefit_order` | 权益 | 成员权益领取记录 |
| `gy_post` | 内容 | 社区动态 |
| `gy_post_comment` | 内容 | 动态评论 |
| `gy_follow_relation` | 社交 | 成员关注关系 |

## 命名约定

- 表统一使用 `gy_` 前缀。
- 外键语义字段使用 `member_id`、`merchant_id`、`benefit_id`、`post_id`、`category_id`。
- 审计字段使用 `created_at`、`updated_at`。
- Java 字段通过 MyBatis-Plus 下划线转驼峰映射到数据库列。
- `gy_follow_relation(member_id, target_member_id)` 使用联合唯一索引，防止重复关注。
- `gy_benefit_order(member_id, benefit_id)` 使用联合唯一索引，作为一人一权益的数据库兜底。
- `gy_member_profile.member_id` 是输入型业务主键，与成员 ID 一一对应，不使用自增。
- `gy_auth_audit_log` 只保存脱敏手机号和 Token 的 SHA-256 摘要，不保存验证码、密码或完整 Token；默认保留 180 天。

## 增量迁移

应用默认在启动时复用现有数据源执行 `CREATE TABLE IF NOT EXISTS`，非破坏性补齐认证审计表。生产环境如统一由 DBA 或迁移系统管理表结构，可设置 `GOUYU_AUTH_INITIALIZE_AUDIT_SCHEMA=false`，并手工执行 `src/main/resources/db/migration/20260718_auth_hardening.sql`。该脚本不删除现有表或业务数据，可重复执行。

## 演示数据

初始化脚本保留原行为基线需要的记录规模和数值关系，但名称、地点、文案和图片路径已改为构域校园/园区语境。图片全部指向 `web/assets` 下的本地文件，不依赖外部图片站点。咖啡实验室、西餐厅和音乐空间使用项目内原创无水印素材。

## 与 Redis 的同步数据

数据库初始化后，运行环境还需要按业务数据初始化：

- `gy:merchant:geo:{categoryId}`：写入 `gy_merchant` 的 `x`、`y`。
- `gy:limited-benefit:stock:{id}`：写入 `gy_limited_benefit.stock`。
- `gy:stream:benefit-orders` 及消费组：由应用启动逻辑幂等创建。

这些操作只允许写入 `gy:` 命名空间。
