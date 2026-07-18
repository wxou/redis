# 构域数据库说明

## 初始化

脚本位置：`src/main/resources/db/gouyu.sql`。

脚本创建独立的 `gouyu` 数据库与演示数据，不要求修改或删除其他数据库。生产或共享环境执行前应先备份，并确认目标库名。

## 表结构

| 表 | 领域 | 说明 |
| --- | --- | --- |
| `gy_member` | 成员 | 登录主体与基础资料 |
| `gy_member_profile` | 成员 | 成员扩展资料 |
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

## 演示数据

初始化脚本保留原行为基线需要的记录规模和数值关系，但名称、地点、文案和图片路径已改为构域校园/园区语境。图片全部指向 `web/assets` 下的本地文件，不依赖外部图片站点。

## 与 Redis 的同步数据

数据库初始化后，运行环境还需要按业务数据初始化：

- `gy:merchant:geo:{categoryId}`：写入 `gy_merchant` 的 `x`、`y`。
- `gy:limited-benefit:stock:{id}`：写入 `gy_limited_benefit.stock`。
- `gy:stream:benefit-orders` 及消费组：由应用初始化逻辑或部署脚本确保存在。

这些操作只允许写入 `gy:` 命名空间。
