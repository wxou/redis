-- Existing GouYu databases can apply this non-destructive authentication migration.
USE `gouyu`;

CREATE TABLE IF NOT EXISTS `gy_auth_audit_log`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `event_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '认证事件类型',
  `member_id` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '成员id，无法识别时为空',
  `phone_masked` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '脱敏手机号',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '客户端IPv4或IPv6地址',
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '客户端User-Agent',
  `outcome` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SUCCESS、FAILURE或BLOCKED',
  `reason` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '失败或拦截原因',
  `token_fingerprint` char(64) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL COMMENT '会话令牌SHA-256摘要',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '事件时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_auth_audit_created_at`(`created_at`) USING BTREE,
  INDEX `idx_auth_audit_member_time`(`member_id`, `created_at`) USING BTREE,
  INDEX `idx_auth_audit_event_time`(`event_type`, `created_at`) USING BTREE,
  INDEX `idx_auth_audit_ip_time`(`ip_address`, `created_at`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;
