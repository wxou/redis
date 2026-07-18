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

登录成功后，客户端把返回的会话令牌放入 `authorization` 请求头。

## 成员 `/member`

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/member/code?phone={phone}` | 发送验证码 |
| POST | `/member/login` | 手机号与验证码登录 |
| POST | `/member/logout` | 退出登录 |
| GET | `/member/me` | 当前成员摘要 |
| GET | `/member/{id}` | 成员信息 |
| GET | `/member/info/{id}` | 成员扩展资料 |
| POST | `/member/check-in` | 当日打卡 |
| GET | `/member/check-in/count` | 当前连续打卡天数 |

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

`/post-comment` 控制器保留为评论域入口，当前等价版本未新增评论读写接口。
