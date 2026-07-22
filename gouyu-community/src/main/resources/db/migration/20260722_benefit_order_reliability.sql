-- Non-destructive reliability migration for asynchronous benefit orders.

CREATE TABLE IF NOT EXISTS `gy_benefit_order_process` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `stream_record_id` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT 'Redis Stream消息ID',
  `order_id` bigint(20) NULL DEFAULT NULL COMMENT '订单ID，毒消息可能为空',
  `member_id` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '成员ID',
  `benefit_id` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '权益ID',
  `status` varchar(24) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL COMMENT '处理状态',
  `retry_count` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '处理次数',
  `error_code` varchar(64) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL COMMENT '失败码',
  `error_message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '脱敏失败原因',
  `payload_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '原始消息归档',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次接收时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近处理时间',
  `finished_at` timestamp NULL DEFAULT NULL COMMENT '进入终态时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_benefit_order_process_stream` (`stream_record_id`) USING BTREE,
  UNIQUE KEY `uk_benefit_order_process_order` (`order_id`) USING BTREE,
  INDEX `idx_benefit_order_process_member_benefit` (`member_id`, `benefit_id`) USING BTREE,
  INDEX `idx_benefit_order_process_status_time` (`status`, `updated_at`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;
