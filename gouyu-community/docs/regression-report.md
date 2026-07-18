# 构域等价回归报告

## 验证目标

证明工程身份和领域语言已经切换为构域，同时核心业务代码仍可编译、前后端契约一致、部署配置有效，并且 MySQL/Redis 使用独立命名空间。

## 当前结果

| 检查项 | 状态 | 证据 |
| --- | --- | --- |
| 改造前后端编译基线 | 通过 | 改造前 `mvn -o -DskipTests clean compile` 成功 |
| 构域后端编译 | 通过 | 改造后 `mvn -o -DskipTests compile` 成功 |
| 测试源码编译 | 通过 | `mvn -DskipTests test-compile` 成功，72 个主源码、3 个测试源码 |
| 前端内联 JavaScript 语法 | 通过 | 10 个 HTML 页面均通过 Node `new Function` 语法检查 |
| Nginx 配置 | 通过 | `nginx -t` 返回 syntax ok / test successful |
| 本地资源闭环 | 通过 | 46 个构域资源文件，SQL 路径均指向 `/assets` |
| 明文基础设施口令 | 通过 | 应用配置改用 `GOUYU_*` 环境变量 |
| MySQL 构域库 | 通过 | 本机 MySQL 8.0.45；独立 `gouyu` 库 11 张表，演示数据完整 |
| Redis 构域命名空间 | 通过 | 虚拟机 Redis 6.2.6；GEO 为 9+5 个商户，Stream/消费组已创建 |
| 后端启动 | 通过 | Tomcat 8081 启动，Redisson 建立 24 个连接，无启动异常 |
| 只读 API 冒烟 | 通过 | 分类 10、附近商户 5、热门动态 4、商户权益 1 |
| Nginx 端到端代理 | 通过 | 8080 首页与 `/api/merchant/1` 返回 UTF-8 构域内容 |

## 等价性约束检查

- 未升级 Spring Boot、MyBatis-Plus、Redis 客户端等关键依赖。
- 未修改 Lua 返回码、库存扣减顺序和消息入流顺序。
- 未修改缓存 TTL、默认分页大小、最大分页大小。
- 未引入旧 API 兼容层，前后端一次性同步切换。
- 未删除或覆盖原项目数据库和 Redis 数据。

## 运行环境事实

本机实际环境与最初推测不同：MySQL 运行在 Windows 本机，Redis 运行在 VMware CentOS `192.168.100.128`。虚拟机内也存在 MySQL 服务，但其 root 凭据与应用原配置不同，因此本次验证使用能够由原应用配置证实的本机 MySQL，避免修改未知的虚拟机 MySQL 实例。

## 未执行项

没有运行会批量写入 ID、HyperLogLog、登录会话或业务记录的完整测试集。等价验证使用编译、静态契约检查和只读 API 冒烟完成，避免污染现有共享 Redis/MySQL 数据。
