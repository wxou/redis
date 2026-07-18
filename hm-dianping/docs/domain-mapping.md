# 构域领域映射

本文记录等价改造中的主要语义映射，供代码评审、数据迁移和回归验证使用。左列仅用于追溯迁移来源，新增代码应只使用右列命名。

## 工程身份

| 改造前 | 构域 |
| --- | --- |
| `com.hmdp` | `com.gouyu` |
| `hm-dianping` | `gouyu-community` |
| `HmDianPingApplication` | `GouYuApplication` |
| `hmdp` 数据库 | `gouyu` 数据库 |
| `tb_*` | `gy_*` |

## 核心领域对象

| 改造前 | 构域 | 业务含义 |
| --- | --- | --- |
| `User` | `Member` | 社区成员 |
| `UserInfo` | `MemberProfile` | 成员扩展资料 |
| `Shop` | `Merchant` | 园区商户/服务点 |
| `ShopType` | `MerchantCategory` | 商户分类 |
| `Voucher` | `Benefit` | 商户权益 |
| `SeckillVoucher` | `LimitedBenefit` | 限时权益库存与时段 |
| `VoucherOrder` | `BenefitOrder` | 权益领取记录 |
| `Blog` | `Post` | 社区动态 |
| `BlogComments` | `PostComment` | 动态评论 |
| `Follow` | `FollowRelation` | 成员关注关系 |

## 主要字段

| 改造前 | 构域 | 适用对象 |
| --- | --- | --- |
| `userId` | `memberId` | 动态、关注、权益记录、打卡 |
| `shopId` | `merchantId` | 动态、权益 |
| `voucherId` | `benefitId` | 限时权益、权益记录 |
| `blogId` | `postId` | 评论、点赞 |
| `typeId` | `categoryId` | 商户 |
| `followUserId` | `targetMemberId` | 关注关系 |
| `nickName` | `displayName` | 成员 |
| `icon` | `avatarUrl` / `authorAvatarUrl` | 成员 / 动态展示 |
| `images` | `imageUrls` | 商户、动态 |
| `liked` | `likeCount` | 动态 |
| `comments` | `commentCount` | 商户、动态 |
| `sold` | `serviceCount` | 商户 |
| `avgPrice` | `averagePrice` | 商户 |
| `openHours` | `businessHours` | 商户 |
| `payValue` | `thresholdAmount` | 权益 |
| `actualValue` | `benefitAmount` | 权益 |
| `beginTime` | `startsAt` | 限时权益 |
| `endTime` | `endsAt` | 限时权益 |
| `createTime` | `createdAt` | 通用审计字段 |
| `updateTime` | `updatedAt` | 通用审计字段 |

## API 资源

| 改造前资源 | 构域资源 |
| --- | --- |
| `/user` | `/member` |
| `/shop` | `/merchant` |
| `/shop-type` | `/merchant-category` |
| `/voucher` | `/benefit` |
| `/voucher-order` | `/benefit-order` |
| `/blog` | `/post` |
| `/blog-comments` | `/post-comment` |
| `/upload/blog` | `/upload/post` |

## 等价约束

- 映射只改变身份和表达，不改变业务前置条件与结果。
- ID、库存、金额、分页、TTL、锁粒度和 Lua 返回码保持原值。
- 前后端同步切换，不提供旧接口兼容层，避免包装后继续暴露旧项目身份。
