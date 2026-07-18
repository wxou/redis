# 构域等价回归报告

## 验证目标

证明工程身份和领域语言已经切换为构域，同时核心业务代码仍可编译、前后端契约一致、部署配置有效，并且 MySQL/Redis 使用独立命名空间。

## 当前结果

| 检查项 | 状态 | 证据 |
| --- | --- | --- |
| 改造前后端编译基线 | 通过 | 改造前 `mvn -o -DskipTests clean compile` 成功 |
| 构域后端编译 | 通过 | 改造后 `mvn -o -DskipTests compile` 成功 |
| 测试源码编译 | 通过 | `mvn -DskipTests test-compile` 成功，71 个主源码、3 个测试源码 |
| 前端内联 JavaScript 语法 | 通过 | 10 个 HTML 页面均通过 Node `new Function` 语法检查 |
| Nginx 配置 | 通过 | `nginx -t` 返回 syntax ok / test successful |
| 本地资源闭环 | 通过 | 46 个构域资源文件，SQL 路径均指向 `/assets` |
| 明文基础设施口令 | 通过 | 应用配置改用 `GOUYU_*` 环境变量 |
| MySQL 构域库 | 待运行验证 | 等待虚拟机服务检查与独立库初始化 |
| Redis 构域命名空间 | 待运行验证 | 等待虚拟机服务检查与 `gy:*` 初始化 |
| 端到端主流程 | 待运行验证 | 数据库和 Redis 就绪后执行 |

## 等价性约束检查

- 未升级 Spring Boot、MyBatis-Plus、Redis 客户端等关键依赖。
- 未修改 Lua 返回码、库存扣减顺序和消息入流顺序。
- 未修改缓存 TTL、默认分页大小、最大分页大小。
- 未引入旧 API 兼容层，前后端一次性同步切换。
- 未删除或覆盖原项目数据库和 Redis 数据。

## 待补证据

运行时验证完成后，在本文件补充 MySQL 表数量、Redis Key 初始化、应用健康启动和关键 API 冒烟结果。
