# 构域 API 说明

前端统一请求 `/api`，Nginx 去掉该前缀后转发到后端 `8081` 端口。响应结构为：

```json
{
  "success": true,
  "errorMsg": null,
  "data": {},
  "total": null
}
```

登录成功后，客户端把返回的会话令牌放入 `authorization` 请求头。会话空闲 120 分钟后过期，请求会滑动续期，但创建 7 天后必须重新登录。

由于当前无法接入短信服务，本地开发默认会在 `/member/code` 的 `data` 中返回验证码并由登录页自动回填；生产环境必须设置 `GOUYU_EXPOSE_LOGIN_CODE=false` 并接入短信发送。验证码会从 Redis 读取、严格比对，并在登录成功后删除。密码使用 BCrypt 存储，要求 8 至 20 位。商户、权益和上传的读取接口公开，写操作必须登录。

验证码发送和登录接口受手机号与 IP 频率限制。触发限制时返回 HTTP `429`，响应体仍使用统一 `ApiResult`，并通过 `Retry-After` 响应头给出建议等待秒数。

## 成员 `/member`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/member/code?phone={phone}` | 发送验证码 |
| POST | `/member/login` | 手机号与验证码或手机号与密码登录 |
| POST | `/member/logout` | 退出登录 |
| PUT | `/member/password` | 登录后设置或修改密码 |
| POST | `/member/password/reset` | 使用手机验证码重置密码 |
| GET | `/member/me` | 当前成员摘要 |
| GET | `/member/{id}` | 成员信息 |
| GET | `/member/info/{id}` | 成员扩展资料 |
| PUT | `/member/info` | 保存当前成员扩展资料 |
| POST | `/member/check-in` | 当日打卡 |
| GET | `/member/check-in/count` | 当前连续打卡天数 |

验证码登录请求：

```json
{"phone":"13686869696","code":"123456"}
```

密码登录请求：

```json
{"phone":"13686869696","password":"password8"}
```

设置/修改密码请求为 `{"currentPassword":"旧密码","newPassword":"新密码"}`。账号尚未设置密码时可省略 `currentPassword`；已有密码时必须正确提供。验证码重置请求为 `{"phone":"13686869696","code":"123456","newPassword":"新密码"}`。

## 商户 `/merchant`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET | `/merchant/{id}` | 商户详情 |
| POST | `/merchant` | 新增商户 |
| PUT | `/merchant` | 更新商户并失效缓存 |
| GET | `/merchant/of/category` | 按 `categoryId` 分页或按距离查询 |
| GET | `/merchant/of/name` | 按名称查询 |
| GET | `/merchant-category/list` | 商户分类列表 |

`/merchant/of/category` 支持 `categoryId`、`current`、可选 `x`、`y` 参数。

## 权益 `/benefit`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/benefit` | 新增普通权益 |
| POST | `/benefit/limited` | 新增限时权益 |
| GET | `/benefit/list/{merchantId}` | 商户权益列表 |
| POST | `/benefit-order/limited/{benefitId}` | 领取限时权益 |
| GET | `/benefit-order/{orderId}` | 查询当前成员的异步权益订单 |

领取成功表示请求已被 Redis 原子受理，响应 `data` 示例：

```json
{"orderId":75249025321795585,"status":"PENDING","message":"领取请求已受理"}
```

订单查询返回状态 DTO。公开状态包括 `PENDING`、`PROCESSING`、`RETRYING`、`SUCCESS`、`FAILED`；成功时 `order` 包含 MySQL 订单，失败时 `message` 说明是否已恢复库存和资格。

```json
{
  "orderId": 75249025321795585,
  "status": "SUCCESS",
  "message": "领取成功",
  "retryCount": 0,
  "updatedAt": "2026-07-22T18:44:39",
  "order": {"id": 75249025321795585, "memberId": 1017, "benefitId": 20}
}
```

## 动态 `/post`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/post` | 发布动态 |
| PUT | `/post/like/{id}` | 点赞或取消点赞 |
| GET | `/post/of/me` | 当前成员动态 |
| GET | `/post/hot` | 热门动态分页 |
| GET | `/post/{id}` | 动态详情 |
| GET | `/post/likes/{id}` | 点赞成员列表 |
| GET | `/post/of/member?id={id}` | 指定成员动态 |
| GET | `/post/of/follow` | 关注流滚动分页 |

关注流参数为 `lastId` 和 `offset`。

## 关注 `/follow`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| PUT | `/follow/{memberId}/{isFollowing}` | 关注或取消关注 |
| GET | `/follow/or/not/{memberId}` | 查询关注状态 |
| GET | `/follow/common/{memberId}` | 查询共同关注 |

## 文件 `/upload`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/upload/post` | 上传动态图片 |
| GET | `/upload/post/delete?name={name}` | 删除未使用的上传图片 |

上传只接受 JPEG、PNG、WebP、GIF，大小不超过 5 MB，服务端返回 `/assets/posts/...` 路径。上传与删除均需登录；删除只能作用于规范化后的 `web/assets/posts` 子目录。

`/post-comment` 控制器保留为评论域入口，当前等价版本未新增评论读写接口。
