# 构域项目等价改造计划书

> 项目名称：构域（GouYu）
>
> 改造类型：不改变业务逻辑的领域化重构与品牌替换
>
> 改造基线：当前 `hm-dianping` 项目
>
> 计划版本：V2.0
>
> 编制日期：2026-07-18
>
> 完成把握：99%

## 1. 需求理解

本次任务不是给当前项目增加新业务，也不是对现有高并发方案进行重新设计，而是在保持现有功能、业务流程和技术实现不变的前提下，将项目完整改造成独立包装项目“构域”。

“构域”定位为面向校园或产业园区的本地社区服务平台。用户可以浏览周边合作商户、领取社区权益、发布社区动态、关注其他成员并参与每日打卡。

本次改造采用**一对一语义迁移**：原项目中的每一个功能在构域中都有对应功能，但更换项目名称、领域名称、代码命名、数据命名、页面文案和演示数据，使项目脱离原有教程语境。

## 2. 改造边界

### 2.1 允许修改

- 项目名称、Maven 坐标、应用名、启动类名和包名。
- Java 类名、接口名、方法名、字段名和局部变量名。
- Controller 路径、请求参数名、DTO 字段名和响应字段名。
- 数据库名、表名、列名、索引名和演示数据。
- Redis Key 前缀、Lua 变量名、Stream 名、消费者组名和锁名称。
- 配置文件、图片目录、日志名称和环境变量名称。
- 前端路由、页面标题、业务文案、Logo、配色、图片和模拟数据。
- README、架构说明、接口文档、部署文档和压测脚本中的项目描述。
- 为保证重命名正确而新增的回归测试、迁移脚本和校验脚本。

### 2.2 禁止修改

- 不增加或删除现有业务功能。
- 不增加空间、多租户、积分商城、审核、私信、活动报名等新业务。
- 不改变登录、商户查询、优惠权益领取、动态发布、关注、点赞、Feed、GEO 和打卡的业务流程。
- 不改变缓存穿透、逻辑过期、分布式锁、Lua、Redis Stream、ZSet、Set、GEO、BitMap 等现有算法。
- 不改变分页大小、缓存 TTL、秒杀返回码、库存扣减方式和订单处理顺序。
- 不在本次改造中升级 Java、Spring Boot、MyBatis-Plus、Redis 或 MySQL 版本。
- 不在本次改造中修复会影响当前运行结果的历史问题。
- 不拆分微服务，不引入新的中间件。

### 2.3 等价改造原则

改造前后的功能关系必须满足：

```text
相同输入语义 + 相同初始数据状态
                ↓
相同业务判断 + 相同 Redis/数据库操作顺序
                ↓
相同结果语义，仅名称、字段和展示文案发生变化
```

例如，“抢购秒杀优惠券”可改名为“领取限时权益”，但库存判断、一人一单校验、Lua 执行、Stream 投递和异步落库逻辑保持原样。

## 3. 构域产品包装

### 3.1 项目定位

**构域**是一套面向校园与产业园区的本地社区服务平台。平台连接社区成员与周边合作商户，提供本地服务发现、限时权益领取、社区动态分享、兴趣关注和每日打卡能力。

为了不引入多租户业务，本次默认采用“一个部署实例服务一个校园或园区”的模式。不同校园或园区可以通过环境配置修改站点名称、Logo 和演示数据，不需要增加 `space_id` 或租户隔离逻辑。

### 3.2 功能一对一映射

| 原项目功能 | 构域包装功能 | 业务逻辑变化 |
|---|---|---|
| 用户登录 | 社区成员登录 | 无 |
| 用户资料 | 成员主页 | 无 |
| 商铺分类 | 周边服务分类 | 无 |
| 商铺详情 | 合作商户详情 | 无 |
| 附近商铺 | 附近服务 | 无 |
| 优惠券 | 社区权益 | 无 |
| 秒杀优惠券 | 限时权益 | 无 |
| 优惠券订单 | 权益领取记录 | 无 |
| 探店笔记 | 社区动态 | 无 |
| 笔记评论 | 动态评论 | 无 |
| 笔记点赞 | 动态点赞 | 无 |
| 用户关注 | 成员关注 | 无 |
| 共同关注 | 共同关注成员 | 无 |
| 关注 Feed | 关注动态流 | 无 |
| 用户签到 | 每日打卡 | 无 |

### 3.3 推荐品牌元素

| 项目 | 构域方案 |
|---|---|
| 中文名 | 构域 |
| 英文名 | GouYu |
| Slogan | 连接身边，共建生活场域 |
| 应用标识 | `gouyu-community` |
| 主包名 | `com.gouyu` |
| 数据库名 | `gouyu` |
| Redis 总前缀 | `gy:` |
| 默认服务名 | `gouyu-server` |
| 页面标题 | 构域 · 身边社区生活 |

## 4. 代码命名改造

### 4.1 工程级命名

| 当前名称 | 目标名称 |
|---|---|
| `hm-dianping` | `gouyu-community` |
| `com.hmdp` | `com.gouyu` |
| `HmDianPingApplication` | `GouYuApplication` |
| Maven `artifactId: hm-dianping` | `artifactId: gouyu-community` |
| Spring 应用名 `hmdp` | `gouyu-community` |
| 数据库 `hmdp` | `gouyu` |

建议保持现有 Controller、Service、Mapper 分层，不在此次任务中调整架构风格，以减少无关变更。

### 4.2 实体类命名映射

| 当前类 | 目标类 | 构域含义 |
|---|---|---|
| `User` | `Member` | 社区成员账号 |
| `UserInfo` | `MemberProfile` | 成员扩展资料 |
| `Shop` | `Merchant` | 周边合作商户 |
| `ShopType` | `MerchantCategory` | 商户服务分类 |
| `Voucher` | `Benefit` | 社区权益 |
| `SeckillVoucher` | `LimitedBenefit` | 限时权益库存与时间 |
| `VoucherOrder` | `BenefitOrder` | 权益领取记录 |
| `Blog` | `Post` | 社区动态 |
| `BlogComments` | `PostComment` | 动态评论 |
| `Follow` | `FollowRelation` | 成员关注关系 |

对应的 Mapper、Service、ServiceImpl 和 Controller 同步重命名，例如：

```text
ShopController              → MerchantController
IShopService                → IMerchantService
ShopServiceImpl             → MerchantServiceImpl
ShopMapper                  → MerchantMapper

VoucherOrderController      → BenefitOrderController
IVoucherOrderService        → IBenefitOrderService
VoucherOrderServiceImpl     → BenefitOrderServiceImpl
VoucherOrderMapper          → BenefitOrderMapper

BlogController              → PostController
IBlogService                → IPostService
BlogServiceImpl             → PostServiceImpl
BlogMapper                  → PostMapper
```

### 4.3 DTO 与工具类命名

| 当前类 | 目标类 |
|---|---|
| `LoginFormDTO` | `LoginRequest` |
| `UserDTO` | `MemberDTO` |
| `Result` | `ApiResult` |
| `ScrollResult` | `CursorPageResult` |
| `UserHolder` | `MemberContext` |
| `RedisIdWorker` | `DistributedIdGenerator` |
| `CacheClient` | `RedisCacheClient` |
| `LoginInterceptor` | `AuthInterceptor` |
| `RefreshTokenInterceptor` | `SessionRefreshInterceptor` |
| `SystemConstants` | `GouYuConstants` |

工具类只修改名称、注释和变量，不改变方法内部算法。

## 5. 字段命名改造

字段允许修改，但必须保持原字段类型、含义和参与业务判断的方式不变。

### 5.1 通用字段

| 当前字段 | 目标字段 | 类型/语义 |
|---|---|---|
| `userId` | `memberId` | 成员 ID |
| `shopId` | `merchantId` | 商户 ID |
| `voucherId` | `benefitId` | 权益 ID |
| `followUserId` | `targetMemberId` | 被关注成员 ID |
| `liked` | `likeCount` | 点赞数量 |
| `comments` | `commentCount` | 评论数量 |
| `images` | `imageUrls` | 图片地址字符串，存储格式不变 |
| `icon` | `avatarUrl` | 头像地址 |
| `nickName` | `displayName` | 展示昵称 |
| `createTime` | `createdAt` | 创建时间 |
| `updateTime` | `updatedAt` | 更新时间 |

### 5.2 商户字段

| 当前字段 | 目标字段 |
|---|---|
| `typeId` | `categoryId` |
| `avgPrice` | `averagePrice` |
| `sold` | `serviceCount` |
| `score` | `ratingScore` |
| `openHours` | `businessHours` |
| `x` | `longitude` |
| `y` | `latitude` |

经纬度字段虽然改名，但 Redis GEO 写入顺序和查询坐标顺序保持不变。

### 5.3 权益字段

| 当前字段 | 目标字段 |
|---|---|
| `title` | `name` |
| `subTitle` | `description` |
| `rules` | `usageRules` |
| `payValue` | `thresholdAmount` |
| `actualValue` | `benefitAmount` |
| `stock` | `availableStock` |
| `beginTime` | `startsAt` |
| `endTime` | `endsAt` |

金额字段单位、库存扣减条件和时间判断方式保持不变。

### 5.4 动态字段

| 当前字段 | 目标字段 |
|---|---|
| `title` | `subject` |
| `content` | `body` |
| `isLike` | `likedByCurrentMember` |
| `parentId` | `parentCommentId` |
| `answerId` | `replyToMemberId` |

## 6. 数据库改造

### 6.1 表名映射

| 当前表 | 目标表 |
|---|---|
| `tb_user` | `gy_member` |
| `tb_user_info` | `gy_member_profile` |
| `tb_shop` | `gy_merchant` |
| `tb_shop_type` | `gy_merchant_category` |
| `tb_voucher` | `gy_benefit` |
| `tb_seckill_voucher` | `gy_limited_benefit` |
| `tb_voucher_order` | `gy_benefit_order` |
| `tb_blog` | `gy_post` |
| `tb_blog_comments` | `gy_post_comment` |
| `tb_follow` | `gy_follow_relation` |
| `tb_sign` | `gy_check_in_record` |

### 6.2 数据改造方式

推荐为构域生成一份独立的 `gouyu.sql`，而不是在原 `hmdp.sql` 上继续追加修改：

1. 复制原有表结构和数据关系。
2. 按映射表修改数据库名、表名、字段名和索引名。
3. 将演示数据中的商户名称、地址、动态内容、用户昵称和图片替换为校园/园区语境。
4. 保持主键值和外键关联值不变，降低迁移验证成本。
5. 修改实体注解、Mapper XML 和查询字段，使其指向新结构。
6. 对改造前后的表执行记录数、主键集合和关联关系比对。

不新增表、不删除业务表、不增加新的唯一约束，也不改变 SQL 查询条件和排序规则。

## 7. API 改造

接口可以更换领域名称，但请求方式、参数含义、调用顺序和返回结果语义必须保持一致。

### 7.1 路径映射示例

| 当前接口 | 构域接口 | 行为 |
|---|---|---|
| `/user/login` | `/member/login` | 不变 |
| `/user/me` | `/member/me` | 不变 |
| `/shop/{id}` | `/merchant/{id}` | 不变 |
| `/shop/of/type` | `/merchant/of/category` | 不变 |
| `/shop-type/list` | `/merchant-category/list` | 不变 |
| `/voucher/list/{shopId}` | `/benefit/list/{merchantId}` | 不变 |
| `/voucher-order/seckill/{id}` | `/benefit-order/limited/{id}` | 不变 |
| `/blog/hot` | `/post/hot` | 不变 |
| `/blog/like/{id}` | `/post/like/{id}` | 不变 |
| `/blog/of/follow` | `/post/of/follow` | 不变 |
| `/follow/common/{id}` | `/follow/common/{id}` | 不变 |
| `/user/sign` | `/member/check-in` | 不变 |
| `/user/sign/count` | `/member/check-in/count` | 不变 |

### 7.2 响应字段

如果将 `Result` 改造成 `ApiResult`，可同步修改字段：

| 当前字段 | 目标字段 |
|---|---|
| `success` | `successful` |
| `errorMsg` | `message` |
| `data` | `data` |
| `total` | `total` |

前端请求封装必须同步更新。除字段名称外，成功/失败条件、HTTP 状态和数据内容保持不变。

## 8. Redis 与 Lua 命名改造

### 8.1 Redis Key 映射

| 当前 Key | 构域 Key |
|---|---|
| `login:code:{phone}` | `gy:auth:code:{phone}` |
| `login:token:{token}` | `gy:auth:session:{token}` |
| `cache:shop:{id}` | `gy:cache:merchant:{id}` |
| `cache:type:list` | `gy:cache:merchant-category:list` |
| `lock:shop:{id}` | `gy:lock:merchant:{id}` |
| `seckill:stock:{id}` | `gy:limited-benefit:stock:{id}` |
| `seckill:order:{id}` | `gy:limited-benefit:order:{id}` |
| `blog:liked:{id}` | `gy:post:liked:{id}` |
| `feed:{memberId}` | `gy:feed:{memberId}` |
| `follows:{memberId}` | `gy:following:{memberId}` |
| `shop:geo:{categoryId}` | `gy:merchant:geo:{categoryId}` |
| `sign:{memberId}:{yyyyMM}` | `gy:check-in:{memberId}:{yyyyMM}` |
| `icr:{type}:{date}` | `gy:id:{type}:{date}` |

TTL 数值和时间单位保持原样。

### 8.2 Stream 与锁

| 当前名称 | 构域名称 |
|---|---|
| `stream.orders` | `gy:stream:benefit-orders` |
| 消费者组 `g1` | `gy-benefit-order-group` |
| 消费者 `c1` | `gy-benefit-order-consumer` |
| `lock:order:{userId}` | `gy:lock:benefit-order:{memberId}` |

消费者名称虽然更换，但消费线程数、读取数量、阻塞时间、Pending 处理和 ACK 时机保持不变。

### 8.3 Lua 脚本

- `seckill.lua` 重命名为 `limited_benefit.lua`。
- `voucherId` 改为 `benefitId`，`userId` 改为 `memberId`，`orderId` 改为 `benefitOrderId`。
- Redis Key 前缀更换为构域前缀。
- 返回码、判断顺序、Redis 命令和消息字段数量保持不变。
- `unlock.lua` 仅修改注释和资源命名，不修改比较删除逻辑。

## 9. 配置与资源改造

### 9.1 配置文件

| 当前配置 | 构域配置 |
|---|---|
| `spring.application.name: hmdp` | `gouyu-community` |
| 数据库 `/hmdp` | `/gouyu` |
| 图片目录 `/hmdp/imgs` | `/gouyu/assets` |
| 日志包 `com.hmdp` | `com.gouyu` |

数据库和 Redis 地址可以改成环境变量占位，以便项目脱离开发者本机；这属于部署配置调整，不改变业务判断。

### 9.2 演示数据

演示数据必须整体更换，避免保留原教程的商户、用户、地址和动态内容。建议数据主题为“星海大学科技园”：

- 商户：校园咖啡、共享自习室、运动中心、打印服务、园区餐厅、维修服务。
- 动态：学习空间体验、园区活动、运动打卡、餐饮推荐、失物招领。
- 权益：咖啡兑换、场地体验、打印折扣、健身体验、午餐减免。
- 成员昵称与头像：重新生成，不沿用原 SQL 数据。
- 经纬度：选择一组合法且相对集中的模拟坐标，保持 GEO 查询效果。

数据数量级和表间关系保持与当前数据相近，不通过增加数据规模改变运行特征。

## 10. 前端与视觉包装

如果使用当前 Nginx 静态前端，需要同步完成以下工作：

1. 修改站点标题、Logo、favicon、登录页和首页文案。
2. 将“店铺”统一改为“商户”或“周边服务”。
3. 将“优惠券/秒杀券”统一改为“权益/限时权益”。
4. 将“探店笔记”统一改为“社区动态”。
5. 将“签到”统一改为“每日打卡”。
6. 替换轮播图、分类图标、默认头像、商户图片和动态示例图片。
7. 修改请求路径和响应字段适配，不改变页面交互流程。
8. 清理页面源码、控制台输出和注释中的原项目名称。

推荐视觉方向：深蓝绿色作为主色，搭配几何网格或连接节点图形，体现“连接成员、商户与生活场域”的品牌含义。

## 11. 文档改造

需要重写或新增：

- `README.md`：构域背景、功能、技术栈、启动方式和截图。
- `docs/domain-mapping.md`：本计划中的类、字段、表和接口映射。
- `docs/api.md`：构域接口清单。
- `docs/redis-keys.md`：构域 Redis Key、数据结构和 TTL。
- `docs/database.md`：表结构和演示数据说明。
- `docs/regression-report.md`：改造前后业务等价性验证结果。
- `CLAUDE.md`：删除原项目语义，改为构域开发说明。

所有文档只描述当前真实实现。现有代码未验证的性能数字不得继续写成既成结果。

## 12. 实施步骤

| 阶段 | 工作内容 | 预计人日 | 业务逻辑变化 |
|---|---|---:|---|
| 0. 行为基线 | 固化接口、数据库、Redis 和页面行为 | 1–2 | 无 |
| 1. 工程更名 | Maven、目录、包名、启动类、应用名 | 1–2 | 无 |
| 2. Java 领域更名 | 实体、Service、Mapper、Controller、DTO、字段 | 2–4 | 无 |
| 3. 数据层更名 | 数据库、表、字段、Mapper XML、演示数据 | 2–3 | 无 |
| 4. 接口与缓存更名 | API 路径、Redis Key、Lua、Stream、锁 | 2–3 | 无 |
| 5. 前端包装 | 路由适配、文案、Logo、图片、配色 | 2–4 | 无 |
| 6. 文档与验收 | README、映射文档、回归和残留扫描 | 1–2 | 无 |

后端完整改造预计 **9–14 人日**；包含现有前端视觉与演示数据替换，预计 **11–20 人日**。实际时间取决于前端资源是否齐全以及是否需要制作新的 Logo 和图片素材。

## 13. 业务等价性验证

### 13.1 基线测试

在重命名前，为当前 29 个接口建立行为快照，记录：

- 请求方法、路径、参数和请求体。
- 登录要求与拦截规则。
- 成功和失败响应。
- 数据库新增、修改和删除结果。
- Redis Key、数据结构、TTL 和成员内容。
- Lua 返回码、Stream 消息字段和订单落库结果。
- 页面跳转和交互流程。

### 13.2 改造后对照

通过映射规则归一化名称后，逐项比较改造前后结果：

```text
旧接口响应 --字段映射--> 归一化结果
新接口响应 --字段映射--> 归一化结果
                         ↓
                      必须一致
```

数据库验证包括：

- 每张表记录数一致。
- 主键集合和关联关系一致。
- 同一操作影响的行数一致。
- 排序、分页和查询条件一致。

Redis 验证包括：

- 数据结构一致。
- TTL 数值与时间单位一致。
- ZSet 分数、Set 成员、BitMap 位和 GEO 坐标一致。
- Stream 消息数量、字段和值一致。

### 13.3 自动残留扫描

最终对源码、配置、SQL、Lua、文档和前端资源执行关键词扫描，以下内容不应再出现：

```text
hm-dianping
hmdp
com.hmdp
HmDianPing
黑马点评
虎哥
大众点评
```

`Shop`、`Voucher`、`Blog` 等旧领域类名也应从业务代码中清除；第三方依赖或 Git 历史不纳入扫描结果。

## 14. 验收标准

- [ ] 项目可使用构域名称独立编译和启动。
- [ ] 包名、类名、字段名、数据库、Redis Key 和接口已完成映射改造。
- [ ] 页面中不存在原项目名称、Logo、文案和示例图片。
- [ ] 构域演示数据能够覆盖现有全部页面和功能。
- [ ] 现有功能数量没有增加或减少。
- [ ] 改造前后每个功能的业务判断和数据操作顺序一致。
- [ ] 29 个接口均有一对一映射和回归结果。
- [ ] Lua 命令顺序、Stream 消费流程和 Redis 数据结构保持一致。
- [ ] 数据库记录关系和核心查询结果保持一致。
- [ ] 源码和资源通过原项目名称残留扫描。
- [ ] README、接口说明、数据库说明和 Redis Key 文档齐全。

## 15. 本次不处理的已知问题

为了严格遵守“不改动业务逻辑”，以下问题不包含在包装改造中：

- 登录验证码校验当前被注释。
- 部分写接口匿名放行。
- 图片删除路径缺少安全校验。
- 秒杀去重 Key 的现有维度问题。
- 秒杀时间校验、Stream 初始化、消费失败补偿和代理竞态问题。
- 关注集合、GEO 数据的自动重建问题。
- 点赞数据库与 Redis 的并发一致性问题。
- 测试依赖外部 Redis/MySQL 且会写真实数据的问题。

这些问题可以在构域包装完成后建立独立的“质量修复计划”。修复时必须单独评审，因为它们会改变当前运行行为或数据结果。

## 16. 风险与控制

| 风险 | 影响 | 控制方式 |
|---|---|---|
| 批量重命名遗漏引用 | 编译失败或运行时报错 | 小批次提交，每批编译并扫描 |
| 字段重命名导致序列化变化 | 前端无法读取响应 | 建立字段映射表并同步修改前端 |
| 表字段重命名遗漏 SQL | 查询或写入失败 | Mapper 集成测试和 SQL 扫描 |
| Redis Key 新旧混用 | 缓存不命中或数据重复 | 集中常量管理并清理测试环境旧 Key |
| Lua 消息字段未同步 | Stream 反序列化失败 | Lua 与消费者使用同一映射清单验证 |
| 演示数据关联破坏 | 页面空白或详情报错 | 保持主键与关联值，执行数据校验脚本 |
| 包装仍有教程痕迹 | 无法真正脱离原项目 | 关键词、图片哈希和页面人工复核 |

## 17. 推荐提交顺序

每次提交只处理一种映射，确保容易审查和回退：

1. `test: 固化改造前业务行为基线`
2. `chore: 重命名构域工程与包结构`
3. `refactor: 迁移成员与商户领域命名`
4. `refactor: 迁移权益与订单领域命名`
5. `refactor: 迁移动态与社交领域命名`
6. `refactor: 迁移数据库表与字段命名`
7. `refactor: 迁移接口与Redis资源命名`
8. `style: 更新构域页面与视觉资源`
9. `docs: 完善构域项目交付文档`

## 18. 交付物

- 完整的构域后端源码。
- 构域数据库建表与演示数据脚本。
- 构域前端静态资源或前端适配补丁。
- 类、字段、数据库、API 和 Redis Key 映射表。
- 改造前后业务等价性回归报告。
- 构域 README、接口文档、数据库文档和 Redis 文档。
- 原项目名称与资源残留扫描报告。

## 19. 完成把握

在“不增加新业务、不修改现有算法和业务流程”的边界下，完成本次构域改造的把握为 **99%**。

当前项目规模明确，代码、SQL、Lua、Redis Key 和接口均可建立一对一映射。主要风险来自批量重命名遗漏和前后端字段不同步，这些风险可以通过编译检查、集成测试、行为快照和自动关键词扫描控制。

唯一需要在正式实施前确认的非技术项是最终 Logo、主色和演示数据风格；即使暂时没有这些素材，也可以使用计划中的默认品牌方案完成全部代码改造。
