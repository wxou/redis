/*
 构域（GouYu）社区服务平台数据库初始化脚本

 数据库：gouyu
 字符集：utf8mb4
 说明：表结构和数据关系与改造前保持一致，演示数据已替换为校园/园区社区语境。
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `gouyu`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `gouyu`;

-- ----------------------------
-- Table structure for gy_post
-- ----------------------------
DROP TABLE IF EXISTS `gy_post`;
CREATE TABLE `gy_post`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint(20) NOT NULL COMMENT '商户id',
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '成员id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `image_urls` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '社区动态的照片，最多9张，多张以\",\"隔开',
  `content` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '社区动态的文字描述',
  `like_count` int(8) UNSIGNED NULL DEFAULT 0 COMMENT '点赞数量',
  `comment_count` int(8) UNSIGNED NULL DEFAULT NULL COMMENT '评论数量',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_post
-- ----------------------------
INSERT INTO `gy_post` VALUES (4, 4, 2, '园区夜晚的浪漫角落｜光屿西餐厅体验', '/assets/generated/western-restaurant.png', '下班后在园区发现了一处安静的社区餐厅。空间设计简洁，服务细致，很适合成员聚会和放松。', 1, 104, '2021-12-28 19:50:01', '2022-03-10 14:26:34');
INSERT INTO `gy_post` VALUES (5, 1, 2, '校园咖啡新据点｜构域咖啡实验室', '/assets/generated/campus-coffee-lab.png', '学习和工作间隙可以来这里坐坐，饮品选择丰富，空间安静，适合自习和小组讨论。', 1, 0, '2021-12-28 20:57:49', '2022-03-10 09:21:39');
INSERT INTO `gy_post` VALUES (6, 10, 1, '周末好去处｜回声音乐空间体验', '/assets/generated/campus-music-space.png', '园区周末活动的新选择，交通方便，空间宽敞，适合和朋友一起放松。', 1, 0, '2022-01-11 16:05:47', '2022-03-10 09:21:41');
INSERT INTO `gy_post` VALUES (7, 10, 1, '社区文体活动记录｜在构域遇见同好', '/assets/posts/post-7.jpg', '参加了一次社区成员组织的文体活动，认识了不少新朋友，记录这次轻松的周末体验。', 1, 0, '2022-01-11 16:05:47', '2022-03-10 09:21:42');

-- ----------------------------
-- Table structure for gy_post_comment
-- ----------------------------
DROP TABLE IF EXISTS `gy_post_comment`;
CREATE TABLE `gy_post_comment`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '成员id',
  `post_id` bigint(20) UNSIGNED NOT NULL COMMENT '社区动态id',
  `parent_comment_id` bigint(20) UNSIGNED NOT NULL COMMENT '关联的1级评论id，如果是一级评论，则值为0',
  `reply_to_comment_id` bigint(20) UNSIGNED NOT NULL COMMENT '回复的评论id',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '回复的内容',
  `like_count` int(8) UNSIGNED NULL DEFAULT NULL COMMENT '点赞数',
  `status` tinyint(1) UNSIGNED NULL DEFAULT NULL COMMENT '状态，0：正常，1：被举报，2：禁止查看',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_post_comment
-- ----------------------------

-- ----------------------------
-- Table structure for gy_follow_relation
-- ----------------------------
DROP TABLE IF EXISTS `gy_follow_relation`;
CREATE TABLE `gy_follow_relation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '成员id',
  `target_member_id` bigint(20) UNSIGNED NOT NULL COMMENT '被关注成员id',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_member_target` (`member_id`, `target_member_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_follow_relation
-- ----------------------------

-- ----------------------------
-- Table structure for gy_limited_benefit
-- ----------------------------
DROP TABLE IF EXISTS `gy_limited_benefit`;
CREATE TABLE `gy_limited_benefit`  (
  `benefit_id` bigint(20) UNSIGNED NOT NULL COMMENT '关联的权益的id',
  `stock` int(8) NOT NULL COMMENT '库存',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `starts_at` timestamp NOT NULL COMMENT '生效时间',
  `ends_at` timestamp NOT NULL COMMENT '失效时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`benefit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '限时权益权益表，与权益是一对一关系' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_limited_benefit
-- ----------------------------

-- ----------------------------
-- Table structure for gy_merchant
-- ----------------------------
DROP TABLE IF EXISTS `gy_merchant`;
CREATE TABLE `gy_merchant`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商户名称',
  `category_id` bigint(20) UNSIGNED NOT NULL COMMENT '商户类型的id',
  `image_urls` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商户图片，多个图片以\',\'隔开',
  `area` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商圈，例如陆家嘴',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '地址',
  `x` double UNSIGNED NOT NULL COMMENT '经度',
  `y` double UNSIGNED NOT NULL COMMENT '维度',
  `average_price` bigint(10) UNSIGNED NULL DEFAULT NULL COMMENT '均价，取整数',
  `service_count` int(10) UNSIGNED ZEROFILL NOT NULL COMMENT '销量',
  `comment_count` int(10) UNSIGNED ZEROFILL NOT NULL COMMENT '评论数量',
  `score` int(2) UNSIGNED ZEROFILL NOT NULL COMMENT '评分，1~5分，乘10保存，避免小数',
  `business_hours` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '营业时间，例如 10:00-22:00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `foreign_key_type`(`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_merchant
-- ----------------------------
INSERT INTO `gy_merchant` VALUES (1, '构域咖啡实验室', 1, '/assets/generated/campus-coffee-lab.png,/assets/merchants/merchant-1-2.jpg', '星海大学东区', '学府路18号创新中心1层', 120.149192, 30.316078, 80, 0000004215, 0000003035, 37, '10:00-22:00', '2021-12-22 18:10:39', '2022-01-13 17:32:19');
INSERT INTO `gy_merchant` VALUES (2, '星海园区烤肉工坊', 1, '/assets/merchants/merchant-2-1.jpg,/assets/merchants/merchant-2-2.jpg', '科技园A区', '科创大道66号A3栋', 120.151505, 30.333422, 85, 0000002160, 0000001460, 46, '11:30-03:00', '2021-12-22 19:00:13', '2022-01-11 16:12:26');
INSERT INTO `gy_merchant` VALUES (3, '青禾社区食堂', 1, '/assets/merchants/merchant-3-1.jpg,/assets/merchants/merchant-3-2.jpg', '星海大学生活区', '青春路8号生活中心2层', 120.151954, 30.32497, 61, 0000012035, 0000008045, 47, '10:30-21:00', '2021-12-22 19:10:05', '2022-01-11 16:12:42');
INSERT INTO `gy_merchant` VALUES (4, '光屿西餐厅', 1, '/assets/generated/western-restaurant.png,/assets/merchants/merchant-4-2.jpg', '科技园创意街区', '光屿路12号创意街区B1', 120.146659, 30.312742, 290, 0000013519, 0000009529, 49, '11:00-22:00', '2021-12-22 19:17:15', '2022-01-11 16:12:51');
INSERT INTO `gy_merchant` VALUES (5, '云栖共享厨房', 1, '/assets/merchants/merchant-5-1.jpg,/assets/merchants/merchant-5-2.jpg', '星海大学西区', '云栖路20号共享空间1层', 120.15778, 30.310633, 104, 0000004125, 0000002764, 49, '10:00-07:00', '2021-12-22 19:20:58', '2022-01-11 16:13:01');
INSERT INTO `gy_merchant` VALUES (6, '北辰暖锅', 1, '/assets/merchants/merchant-6-1.jpg,/assets/merchants/merchant-6-2.jpg', '北辰社区', '北辰路9号社区中心', 120.148603, 30.318618, 130, 0000009531, 0000007324, 46, '11:00-13:50,17:00-20:50', '2021-12-22 19:24:53', '2022-01-11 16:13:09');
INSERT INTO `gy_merchant` VALUES (7, '拾光烤鱼社', 1, '/assets/merchants/merchant-7-1.jpg,/assets/merchants/merchant-7-2.jpg', '科技园B区', '科创大道88号B2栋', 120.124691, 30.336819, 85, 0000002631, 0000001320, 47, '00:00-24:00', '2021-12-22 19:40:52', '2022-01-11 16:13:19');
INSERT INTO `gy_merchant` VALUES (8, '青空寿司屋', 1, '/assets/merchants/merchant-8-1.jpg,/assets/merchants/merchant-8-2.jpg', '星海大学东区', '学府路26号东区商业街', 120.150526, 30.325231, 88, 0000002406, 0000001206, 46, ' 11:00-21:30', '2021-12-22 19:51:06', '2022-01-11 16:13:25');
INSERT INTO `gy_merchant` VALUES (9, '知味炭火馆', 1, '/assets/merchants/merchant-9-1.jpg,/assets/merchants/merchant-9-2.jpg', '青禾社区', '青禾路15号邻里中心', 120.150598, 30.325251, 101, 0000002763, 0000001363, 44, '11:00-21:30', '2021-12-22 19:53:59', '2022-01-11 16:13:34');
INSERT INTO `gy_merchant` VALUES (10, '回声音乐空间', 2, '/assets/generated/campus-music-space.png,/assets/merchants/merchant-10-2.jpg', '星海大学文体区', '文体路6号活动中心4层', 120.149093, 30.324666, 67, 0000026891, 0000000902, 37, '00:00-24:00', '2021-12-22 20:25:16', '2021-12-22 20:25:16');
INSERT INTO `gy_merchant` VALUES (11, '星轨K歌馆', 2, '/assets/merchants/merchant-11-1.jpg,/assets/merchants/merchant-11-2.jpg', '科技园A区', '科创大道28号A1栋', 120.15853, 30.310002, 75, 0000035977, 0000005684, 47, '11:30-06:00', '2021-12-22 20:29:02', '2021-12-22 20:39:00');
INSERT INTO `gy_merchant` VALUES (12, '拾音练歌房', 2, '/assets/merchants/merchant-12-1.jpg,/assets/merchants/merchant-12-2.jpg', '星海大学生活区', '青春路16号生活中心3层', 120.14983, 30.31211, 88, 0000006444, 0000000235, 46, '10:00-02:00', '2021-12-22 20:34:34', '2021-12-22 20:34:34');
INSERT INTO `gy_merchant` VALUES (13, '青禾创意空间', 2, '/assets/merchants/merchant-13-1.jpg,/assets/merchants/merchant-13-2.jpg', '青禾社区', '青禾路30号创客中心', 120.130453, 30.327655, 58, 0000018997, 0000001857, 41, '12:00-02:00', '2021-12-22 20:38:54', '2021-12-22 20:40:04');
INSERT INTO `gy_merchant` VALUES (14, '云帆音乐厅', 2, '/assets/merchants/merchant-14-1.jpg,/assets/merchants/merchant-14-2.jpg', '星海大学文体区', '文体路18号艺术中心', 120.128958, 30.337252, 60, 0000017771, 0000000685, 47, '10:00-22:00', '2021-12-22 20:48:54', '2021-12-22 20:48:54');

-- ----------------------------
-- Table structure for gy_merchant_category
-- ----------------------------
DROP TABLE IF EXISTS `gy_merchant_category`;
CREATE TABLE `gy_merchant_category`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类型名称',
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标',
  `sort` int(3) UNSIGNED NULL DEFAULT NULL COMMENT '顺序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_merchant_category
-- ----------------------------
INSERT INTO `gy_merchant_category` VALUES (1, '校园餐饮', '/assets/categories/category-1.png', 1, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (2, '文娱空间', '/assets/categories/category-2.png', 2, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (3, '生活服务', '/assets/categories/category-3.png', 3, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (4, '运动健身', '/assets/categories/category-4.png', 10, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (5, '健康服务', '/assets/categories/category-5.png', 5, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (6, '美容护理', '/assets/categories/category-6.png', 6, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (7, '社团活动', '/assets/categories/category-7.png', 7, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (8, '校园夜市', '/assets/categories/category-8.png', 8, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (9, '聚会空间', '/assets/categories/category-9.png', 9, '2021-12-22 20:17:47', '2021-12-23 11:24:31');
INSERT INTO `gy_merchant_category` VALUES (10, '形象护理', '/assets/categories/category-10.png', 4, '2021-12-22 20:17:47', '2021-12-23 11:24:31');

-- ----------------------------
-- Table structure for gy_check_in_record
-- ----------------------------
DROP TABLE IF EXISTS `gy_check_in_record`;
CREATE TABLE `gy_check_in_record`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '成员id',
  `year` year NOT NULL COMMENT '打卡年份',
  `month` tinyint(2) NOT NULL COMMENT '打卡月份',
  `date` date NOT NULL COMMENT '打卡日期',
  `is_backup` tinyint(1) UNSIGNED NULL DEFAULT NULL COMMENT '是否补签',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_check_in_record
-- ----------------------------

-- ----------------------------
-- Table structure for gy_member
-- ----------------------------
DROP TABLE IF EXISTS `gy_member`;
CREATE TABLE `gy_member`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '手机号码',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '密码，加密存储',
  `display_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '展示名称，默认由成员id生成',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '成员头像',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uniqe_key_phone`(`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1010 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Table structure for gy_auth_audit_log
-- ----------------------------
DROP TABLE IF EXISTS `gy_auth_audit_log`;
CREATE TABLE `gy_auth_audit_log`  (
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

-- ----------------------------
-- Records of gy_member
-- ----------------------------
INSERT INTO `gy_member` VALUES (1, '13686869696', '', '小鱼同学', '/imgs/blogs/blog1.jpg', '2021-12-24 10:27:19', '2022-01-11 16:04:00');
INSERT INTO `gy_member` VALUES (2, '13838411438', '', '可可今天不吃肉', '/imgs/icons/kkjtbcr.jpg', '2021-12-24 15:14:39', '2021-12-28 19:58:04');
INSERT INTO `gy_member` VALUES (4, '13456789011', '', 'member_slxaxy2au9f3tanffaxr', '', '2022-01-07 12:07:53', '2022-01-07 12:07:53');
INSERT INTO `gy_member` VALUES (5, '13456789001', '', '可爱多', '/imgs/icons/user5-icon.png', '2022-01-07 16:11:33', '2022-03-11 09:09:20');
INSERT INTO `gy_member` VALUES (6, '13456762069', '', 'member_xn5wr3hpsv', '', '2022-02-07 17:54:10', '2022-02-07 17:54:10');
INSERT INTO `gy_member` VALUES (10, '13688668889', '', 'member_88arndojw9', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (11, '13688668890', '', 'member_qcfr2k1lmi', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (12, '13688668891', '', 'member_ffsk4hli07', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (13, '13688668892', '', 'member_r62q62ijef', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (14, '13688668893', '', 'member_f3rymyt1q5', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (15, '13688668894', '', 'member_hnyhc3mjat', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (16, '13688668895', '', 'member_2spo35f5rl', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (17, '13688668896', '', 'member_q3r70baqe1', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (18, '13688668897', '', 'member_v73ottjqxt', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (19, '13688668898', '', 'member_tmh8o4r11q', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (20, '13688668899', '', 'member_4epgb7b5u1', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (21, '13688668900', '', 'member_g474zoujxj', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (22, '13688668901', '', 'member_r3kh1g6aah', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (23, '13688668902', '', 'member_u3uuo7l5fo', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (24, '13688668903', '', 'member_9o93lbsojt', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (25, '13688668904', '', 'member_jbhmr43wpq', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (26, '13688668905', '', 'member_nevyd3c5ux', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (27, '13688668906', '', 'member_oow4frmjp3', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (28, '13688668907', '', 'member_cvmknmec74', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (29, '13688668908', '', 'member_0t2x5njbz7', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (30, '13688668909', '', 'member_y5x09783hp', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (31, '13688668910', '', 'member_owe4eyuhhh', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (32, '13688668911', '', 'member_j76auh0ggg', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (33, '13688668912', '', 'member_aal5w9rm33', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (34, '13688668913', '', 'member_a2pgu8cr21', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (35, '13688668914', '', 'member_nle60p846v', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (36, '13688668915', '', 'member_w1mck7c7yv', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (37, '13688668916', '', 'member_bnpiybumlk', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (38, '13688668917', '', 'member_4w7xeo2yyt', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (39, '13688668918', '', 'member_99u4voj7xl', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (40, '13688668919', '', 'member_g03is27pd6', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (41, '13688668920', '', 'member_3j9erfkl0p', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (42, '13688668921', '', 'member_l7rs56ah9y', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (43, '13688668922', '', 'member_p3655ctliy', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (44, '13688668923', '', 'member_qi1qze1yp1', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (45, '13688668924', '', 'member_vrd5ir0rj0', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (46, '13688668925', '', 'member_tubboh1byc', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (47, '13688668926', '', 'member_j2bdj3d2eo', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (48, '13688668927', '', 'member_ncj7r0vu1h', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (49, '13688668928', '', 'member_63rhqjqa0a', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (50, '13688668929', '', 'member_80ue5cywnk', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (51, '13688668930', '', 'member_j4q037vhpi', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (52, '13688668931', '', 'member_ms0uat5bf0', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (53, '13688668932', '', 'member_oqep16bdel', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (54, '13688668933', '', 'member_vjtvjjdqh7', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (55, '13688668934', '', 'member_0168i9hv5g', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (56, '13688668935', '', 'member_vh1j6zw1q4', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (57, '13688668936', '', 'member_rkf2nxouof', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (58, '13688668937', '', 'member_whlt2chtv3', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (59, '13688668938', '', 'member_lpqr90wbeo', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (60, '13688668939', '', 'member_h40y3ipk9k', '', '2022-02-28 10:50:47', '2022-02-28 10:50:47');
INSERT INTO `gy_member` VALUES (61, '13688668940', '', 'member_awdqkmbkt7', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (62, '13688668941', '', 'member_1xgbg9v4r5', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (63, '13688668942', '', 'member_7vf5fgiu68', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (64, '13688668943', '', 'member_lsgiz015vf', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (65, '13688668944', '', 'member_0nqjvanruk', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (66, '13688668945', '', 'member_8alg1taath', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (67, '13688668946', '', 'member_q45ykjgpxe', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (68, '13688668947', '', 'member_4hy0o6ir0r', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (69, '13688668948', '', 'member_q6rh7e6zo9', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (70, '13688668949', '', 'member_1wp3ygfyn2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (71, '13688668950', '', 'member_13vjvo6flp', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (72, '13688668951', '', 'member_glyshbbwin', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (73, '13688668952', '', 'member_3ewzgsnhzj', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (74, '13688668953', '', 'member_ky481zf1fs', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (75, '13688668954', '', 'member_o5yzu0epev', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (76, '13688668955', '', 'member_ycbracmsi3', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (77, '13688668956', '', 'member_974wwi1283', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (78, '13688668957', '', 'member_1y0xokmk9w', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (79, '13688668958', '', 'member_nd74cho3tu', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (80, '13688668959', '', 'member_5z7u2eysa4', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (81, '13688668960', '', 'member_yvf8hfu5yy', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (82, '13688668961', '', 'member_2poi4wvpms', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (83, '13688668962', '', 'member_v4ysxjt1yu', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (84, '13688668963', '', 'member_kbvn4gpgk6', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (85, '13688668964', '', 'member_23niik1tyg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (86, '13688668965', '', 'member_uf2zz6ispe', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (87, '13688668966', '', 'member_5k19vf7c4o', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (88, '13688668967', '', 'member_5ahdd98xbr', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (89, '13688668968', '', 'member_a5cnfnoopx', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (90, '13688668969', '', 'member_utnmcyfg13', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (91, '13688668970', '', 'member_0k6n8ikb95', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (92, '13688668971', '', 'member_zqk5maqtmi', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (93, '13688668972', '', 'member_9i9suwd3nd', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (94, '13688668973', '', 'member_u0y0ngrdjo', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (95, '13688668974', '', 'member_stvijjwvzu', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (96, '13688668975', '', 'member_7if7tttays', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (97, '13688668976', '', 'member_f9hmz0ngdu', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (98, '13688668977', '', 'member_wuhs2nq9d0', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (99, '13688668978', '', 'member_1u3rlntd5s', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (100, '13688668979', '', 'member_ywe62vhu7u', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (101, '13688668980', '', 'member_rbfpzdt6tg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (102, '13688668981', '', 'member_jv69l0d1kg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (103, '13688668982', '', 'member_dg6hwl48r6', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (104, '13688668983', '', 'member_8rwl92pixr', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (105, '13688668984', '', 'member_k5dek2os3m', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (106, '13688668985', '', 'member_kw1nr2scyz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (107, '13688668986', '', 'member_h81c5g0t7s', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (108, '13688668987', '', 'member_jar6djas5e', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (109, '13688668988', '', 'member_f9x2qm4grh', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (110, '13688668989', '', 'member_mg5h6c4bcu', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (111, '13688668990', '', 'member_hcg7ocbnus', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (112, '13688668991', '', 'member_rsbxx7g2yz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (113, '13688668992', '', 'member_bi3fhutbd1', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (114, '13688668993', '', 'member_o4pjkkyu3q', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (115, '13688668994', '', 'member_7zfs7g5vqb', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (116, '13688668995', '', 'member_oq71inq541', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (117, '13688668996', '', 'member_u9zoiadq6l', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (118, '13688668997', '', 'member_4elguvu5pz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (119, '13688668998', '', 'member_90dclmdv94', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (120, '13688668999', '', 'member_v2of3k1liq', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (121, '13688669000', '', 'member_bg04b99iqn', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (122, '13688669001', '', 'member_6fo9sul3q6', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (123, '13688669002', '', 'member_vl7ajjlhnn', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (124, '13688669003', '', 'member_df3kaj5zi1', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (125, '13688669004', '', 'member_yo6iohe5s2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (126, '13688669005', '', 'member_2iss3wrcm1', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (127, '13688669006', '', 'member_7y8qm8sv4r', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (128, '13688669007', '', 'member_f825rhknpq', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (129, '13688669008', '', 'member_3bigm0aauz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (130, '13688669009', '', 'member_ib9eo5dtgk', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (131, '13688669010', '', 'member_ci5hhnufj9', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (132, '13688669011', '', 'member_cc56u62rny', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (133, '13688669012', '', 'member_i8fg7azvnt', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (134, '13688669013', '', 'member_bw5dqkv6d9', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (135, '13688669014', '', 'member_1n1o9ri5oz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (136, '13688669015', '', 'member_1b0zexoldy', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (137, '13688669016', '', 'member_lz9dr6wxkw', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (138, '13688669017', '', 'member_zfpfscu53e', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (139, '13688669018', '', 'member_5kldn59nn9', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (140, '13688669019', '', 'member_p0mjswjh9x', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (141, '13688669020', '', 'member_z4jcqggm11', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (142, '13688669021', '', 'member_pv9yctbxza', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (143, '13688669022', '', 'member_u702tikvol', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (144, '13688669023', '', 'member_sy4a5f3qmy', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (145, '13688669024', '', 'member_n6g293r60l', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (146, '13688669025', '', 'member_uylyp6ttqz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (147, '13688669026', '', 'member_h2zmzefha3', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (148, '13688669027', '', 'member_5outop6hz2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (149, '13688669028', '', 'member_vp8l74sadq', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (150, '13688669029', '', 'member_n9ww3of8fg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (151, '13688669030', '', 'member_rfm7pfgkv8', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (152, '13688669031', '', 'member_h7298xuo0u', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (153, '13688669032', '', 'member_72s0smb2wz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (154, '13688669033', '', 'member_twhphih9nd', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (155, '13688669034', '', 'member_vfocakn5gl', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (156, '13688669035', '', 'member_tfwe1v2x82', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (157, '13688669036', '', 'member_eyrq375qgg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (158, '13688669037', '', 'member_rg2obilrot', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (159, '13688669038', '', 'member_rzfwln2aw2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (160, '13688669039', '', 'member_rzfgzeshe1', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (161, '13688669040', '', 'member_c67s0sjbmv', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (162, '13688669041', '', 'member_fkyp652kkn', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (163, '13688669042', '', 'member_sv1i552okx', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (164, '13688669043', '', 'member_fsrmh6e0d3', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (165, '13688669044', '', 'member_jey7gkjesn', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (166, '13688669045', '', 'member_00xdq55r0f', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (167, '13688669046', '', 'member_wkb6tveg4e', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (168, '13688669047', '', 'member_51ong6aunx', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (169, '13688669048', '', 'member_ke4h0uxthm', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (170, '13688669049', '', 'member_oswyb9opx5', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (171, '13688669050', '', 'member_iy8itbwg6q', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (172, '13688669051', '', 'member_g1mk023p9r', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (173, '13688669052', '', 'member_2507p7kvzs', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (174, '13688669053', '', 'member_piixbanfxl', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (175, '13688669054', '', 'member_w2d2is43jc', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (176, '13688669055', '', 'member_lrk4it56lt', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (177, '13688669056', '', 'member_3273q3j2ft', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (178, '13688669057', '', 'member_ltf42q0vy4', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (179, '13688669058', '', 'member_7npp13snqp', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (180, '13688669059', '', 'member_slxftqmjp9', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (181, '13688669060', '', 'member_il4dsuvdfr', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (182, '13688669061', '', 'member_esm2d4uh7a', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (183, '13688669062', '', 'member_te4prs2y3j', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (184, '13688669063', '', 'member_dycwcufgj0', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (185, '13688669064', '', 'member_jjo4dvsgag', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (186, '13688669065', '', 'member_9opl0t1sd2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (187, '13688669066', '', 'member_hbm1dnssq6', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (188, '13688669067', '', 'member_tx88zar5cs', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (189, '13688669068', '', 'member_1p206nyupm', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (190, '13688669069', '', 'member_8lnbd2ao5u', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (191, '13688669070', '', 'member_v4uwls1wg7', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (192, '13688669071', '', 'member_z1bkh9lnjj', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (193, '13688669072', '', 'member_r7u852ex1n', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (194, '13688669073', '', 'member_yqr54gdh8t', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (195, '13688669074', '', 'member_x4kngjjng7', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (196, '13688669075', '', 'member_xvtxjocno2', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (197, '13688669076', '', 'member_1zj77q03tf', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (198, '13688669077', '', 'member_0q8yjtlp7a', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (199, '13688669078', '', 'member_nt2ogdyl73', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (200, '13688669079', '', 'member_6w0ex6afsz', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (201, '13688669080', '', 'member_qpm2vyflc3', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (202, '13688669081', '', 'member_dzvf9xujj1', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (203, '13688669082', '', 'member_aiypeaeupd', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (204, '13688669083', '', 'member_5iznj0t5hg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (205, '13688669084', '', 'member_4t1flvqz2h', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (206, '13688669085', '', 'member_542t36rd41', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (207, '13688669086', '', 'member_kmhowbydu6', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (208, '13688669087', '', 'member_e8nz64jbym', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (209, '13688669088', '', 'member_zjbr3zq6we', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (210, '13688669089', '', 'member_ptk6qaspna', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (211, '13688669090', '', 'member_jei7tqtu1j', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (212, '13688669091', '', 'member_8x7cyv5ey8', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (213, '13688669092', '', 'member_mx3l4tj2jq', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (214, '13688669093', '', 'member_ba6e9l6exg', '', '2022-02-28 10:50:48', '2022-02-28 10:50:48');
INSERT INTO `gy_member` VALUES (215, '13688669094', '', 'member_vlku3rop6e', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (216, '13688669095', '', 'member_hsff9net6q', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (217, '13688669096', '', 'member_mbaficnzfe', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (218, '13688669097', '', 'member_b3wglh40dk', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (219, '13688669098', '', 'member_dvi1yllk48', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (220, '13688669099', '', 'member_cxv8smu642', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (221, '13688669100', '', 'member_ze5exti1z5', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (222, '13688669101', '', 'member_b6524nuosz', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (223, '13688669102', '', 'member_jw3xmz31ss', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (224, '13688669103', '', 'member_3fqrglyqj0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (225, '13688669104', '', 'member_uf9dy1kfmg', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (226, '13688669105', '', 'member_nn4ss4oupv', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (227, '13688669106', '', 'member_khse5vlch8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (228, '13688669107', '', 'member_xfpqrk3hea', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (229, '13688669108', '', 'member_0sfyf9o74l', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (230, '13688669109', '', 'member_936vlojcwy', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (231, '13688669110', '', 'member_wq9m8aqmay', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (232, '13688669111', '', 'member_uqw0c5ilp5', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (233, '13688669112', '', 'member_qjucgt4ar1', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (234, '13688669113', '', 'member_sry5bqf8ev', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (235, '13688669114', '', 'member_9csdwveeh8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (236, '13688669115', '', 'member_y9kl1yd7fk', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (237, '13688669116', '', 'member_mahwf66irm', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (238, '13688669117', '', 'member_tud2i4itlr', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (239, '13688669118', '', 'member_p1s640kfny', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (240, '13688669119', '', 'member_2tyzfj49r6', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (241, '13688669120', '', 'member_wjswilvpou', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (242, '13688669121', '', 'member_yuushg7x44', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (243, '13688669122', '', 'member_pb0fas6tob', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (244, '13688669123', '', 'member_3k4nn4dhuh', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (245, '13688669124', '', 'member_lljtt3ttml', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (246, '13688669125', '', 'member_weftqlsasg', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (247, '13688669126', '', 'member_1lo78exvpl', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (248, '13688669127', '', 'member_qzbukb32cm', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (249, '13688669128', '', 'member_k80i5kfvoj', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (250, '13688669129', '', 'member_ggx53ve2zp', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (251, '13688669130', '', 'member_yz0fmlzjxv', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (252, '13688669131', '', 'member_jh6epyjgiw', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (253, '13688669132', '', 'member_0k0ly383fy', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (254, '13688669133', '', 'member_ibc8pgs2jc', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (255, '13688669134', '', 'member_ys8yxdm6cr', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (256, '13688669135', '', 'member_7zdagyyymi', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (257, '13688669136', '', 'member_9q7fiiqwzm', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (258, '13688669137', '', 'member_64qzvesiku', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (259, '13688669138', '', 'member_5fi8fsc9e5', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (260, '13688669139', '', 'member_1wo4aktp89', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (261, '13688669140', '', 'member_5mis2rucuh', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (262, '13688669141', '', 'member_pghkcw4cog', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (263, '13688669142', '', 'member_ymh7a5t69k', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (264, '13688669143', '', 'member_58qypl26r3', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (265, '13688669144', '', 'member_oknszihfil', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (266, '13688669145', '', 'member_rx5qu0277b', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (267, '13688669146', '', 'member_4mwekx3q8z', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (268, '13688669147', '', 'member_ie9qzfwu27', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (269, '13688669148', '', 'member_l80r6phxur', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (270, '13688669149', '', 'member_np6iqqeuql', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (271, '13688669150', '', 'member_5c27qgw2o3', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (272, '13688669151', '', 'member_ujpa6juatc', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (273, '13688669152', '', 'member_van4fds7cx', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (274, '13688669153', '', 'member_ox11o9krp9', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (275, '13688669154', '', 'member_c7o3u0usf2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (276, '13688669155', '', 'member_cq7hojlerq', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (277, '13688669156', '', 'member_kphis0ntao', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (278, '13688669157', '', 'member_nd12v2tdpj', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (279, '13688669158', '', 'member_5far04rjm0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (280, '13688669159', '', 'member_f33abomjs2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (281, '13688669160', '', 'member_1qty1oyawt', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (282, '13688669161', '', 'member_9l463o7me2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (283, '13688669162', '', 'member_0seyfs8ou8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (284, '13688669163', '', 'member_7uhqt2zf11', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (285, '13688669164', '', 'member_wy2jtbkr1t', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (286, '13688669165', '', 'member_yjf1kbl6r8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (287, '13688669166', '', 'member_r98pel35gn', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (288, '13688669167', '', 'member_u2eg1jcwvz', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (289, '13688669168', '', 'member_5z7d4fr9ye', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (290, '13688669169', '', 'member_kl0p0ku6zv', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (291, '13688669170', '', 'member_dsdocfa64r', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (292, '13688669171', '', 'member_gbygsd03kc', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (293, '13688669172', '', 'member_dj1xqos2is', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (294, '13688669173', '', 'member_il6yctz040', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (295, '13688669174', '', 'member_y4zn043gvj', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (296, '13688669175', '', 'member_oh9tjoxq8c', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (297, '13688669176', '', 'member_6xlq088asi', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (298, '13688669177', '', 'member_0sepghh66s', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (299, '13688669178', '', 'member_dzo7q333x7', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (300, '13688669179', '', 'member_n7j3j68agt', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (301, '13688669180', '', 'member_b99vc3qr3d', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (302, '13688669181', '', 'member_o2uu01ngfw', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (303, '13688669182', '', 'member_q0yy8pvku3', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (304, '13688669183', '', 'member_lipi4iyiv9', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (305, '13688669184', '', 'member_x2dq9i90ms', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (306, '13688669185', '', 'member_bz9twrcx01', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (307, '13688669186', '', 'member_iun0ocev18', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (308, '13688669187', '', 'member_uob3pxr062', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (309, '13688669188', '', 'member_nxuwi8q3n5', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (310, '13688669189', '', 'member_g6si4hwe4r', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (311, '13688669190', '', 'member_v4xud6pxnh', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (312, '13688669191', '', 'member_n3vq5a4c49', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (313, '13688669192', '', 'member_6qdfn8dkja', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (314, '13688669193', '', 'member_872mdw0ibu', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (315, '13688669194', '', 'member_s426pmlnno', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (316, '13688669195', '', 'member_n7d3fcnlqf', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (317, '13688669196', '', 'member_d1euhpgvjt', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (318, '13688669197', '', 'member_luwqlqye4n', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (319, '13688669198', '', 'member_m9khstqle0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (320, '13688669199', '', 'member_7u54hoeh5p', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (321, '13688669200', '', 'member_hndxi8iyg7', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (322, '13688669201', '', 'member_csagq8b16v', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (323, '13688669202', '', 'member_sa979r5vfr', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (324, '13688669203', '', 'member_gojbeoieko', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (325, '13688669204', '', 'member_vrxmccmk36', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (326, '13688669205', '', 'member_kwzzzxile8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (327, '13688669206', '', 'member_8ik6wmzcs3', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (328, '13688669207', '', 'member_x9f4po6eok', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (329, '13688669208', '', 'member_vn0g3rywt0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (330, '13688669209', '', 'member_0h0hqnoqvv', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (331, '13688669210', '', 'member_ne3rvn4cim', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (332, '13688669211', '', 'member_bz20tomja0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (333, '13688669212', '', 'member_7k5d8324tm', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (334, '13688669213', '', 'member_5va74it1op', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (335, '13688669214', '', 'member_gc21xkfgph', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (336, '13688669215', '', 'member_rv1o0ousua', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (337, '13688669216', '', 'member_lkp3hk0t8q', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (338, '13688669217', '', 'member_e2kjjqo7ee', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (339, '13688669218', '', 'member_ja24gfl42z', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (340, '13688669219', '', 'member_5sxrarxxd2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (341, '13688669220', '', 'member_lzilfx23jr', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (342, '13688669221', '', 'member_4healeh2sq', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (343, '13688669222', '', 'member_txh60qz6xe', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (344, '13688669223', '', 'member_ofie8fobtu', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (345, '13688669224', '', 'member_wxfngmqndc', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (346, '13688669225', '', 'member_n11kdqn95y', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (347, '13688669226', '', 'member_7b9etto6jl', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (348, '13688669227', '', 'member_sa23n9pacw', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (349, '13688669228', '', 'member_1lhe46upfz', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (350, '13688669229', '', 'member_jioft4gdiu', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (351, '13688669230', '', 'member_jta7ld4vty', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (352, '13688669231', '', 'member_5tkaejhk7g', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (353, '13688669232', '', 'member_fkoe771g9p', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (354, '13688669233', '', 'member_snv802ujrx', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (355, '13688669234', '', 'member_4szkwdl3hw', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (356, '13688669235', '', 'member_qq4cteo33l', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (357, '13688669236', '', 'member_hwn4ofw0dp', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (358, '13688669237', '', 'member_2r4xhcvxp2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (359, '13688669238', '', 'member_iphgurk3nk', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (360, '13688669239', '', 'member_ih9kbl5kzb', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (361, '13688669240', '', 'member_2odlf3rqex', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (362, '13688669241', '', 'member_i9jalo3ouw', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (363, '13688669242', '', 'member_whbqd8vhr2', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (364, '13688669243', '', 'member_bzlvvy10mp', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (365, '13688669244', '', 'member_pe7y2zyii7', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (366, '13688669245', '', 'member_cnk071ghc7', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (367, '13688669246', '', 'member_21cue7tpm0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (368, '13688669247', '', 'member_nidneujm1x', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (369, '13688669248', '', 'member_tx2y3v0pb0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (370, '13688669249', '', 'member_i8ikz0nufr', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (371, '13688669250', '', 'member_omq8bsw2ij', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (372, '13688669251', '', 'member_ffpuo977gj', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (373, '13688669252', '', 'member_jcgx7mukv0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (374, '13688669253', '', 'member_gn6k43jfx8', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (375, '13688669254', '', 'member_esfv726lun', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (376, '13688669255', '', 'member_l7vh3qyhnk', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (377, '13688669256', '', 'member_aqo9nsp13v', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (378, '13688669257', '', 'member_45z1cjwo34', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (379, '13688669258', '', 'member_cukuugiquc', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (380, '13688669259', '', 'member_cmzben5ql1', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (381, '13688669260', '', 'member_fm136hckhd', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (382, '13688669261', '', 'member_4neww35d6t', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (383, '13688669262', '', 'member_p4e2t04dl0', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (384, '13688669263', '', 'member_3s22mzjlgl', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (385, '13688669264', '', 'member_kf0pbo00lp', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (386, '13688669265', '', 'member_7tan2lj2jn', '', '2022-02-28 10:50:49', '2022-02-28 10:50:49');
INSERT INTO `gy_member` VALUES (387, '13688669266', '', 'member_w88q6nof2r', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (388, '13688669267', '', 'member_9aze983wkj', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (389, '13688669268', '', 'member_wtioxpbho1', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (390, '13688669269', '', 'member_yf70g0cjfu', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (391, '13688669270', '', 'member_i1w18vru0l', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (392, '13688669271', '', 'member_6lr3w5npe5', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (393, '13688669272', '', 'member_9n8rjbb9gp', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (394, '13688669273', '', 'member_fe3u4g7p1f', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (395, '13688669274', '', 'member_618vib46zb', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (396, '13688669275', '', 'member_mj4b8uxpu3', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (397, '13688669276', '', 'member_3jq7brld6h', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (398, '13688669277', '', 'member_8577262ob3', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (399, '13688669278', '', 'member_x63u1e3sap', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (400, '13688669279', '', 'member_o2c2l1j9zs', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (401, '13688669280', '', 'member_rtupie4qut', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (402, '13688669281', '', 'member_othsv0bkha', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (403, '13688669282', '', 'member_4wqa1vn3kw', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (404, '13688669283', '', 'member_xmhuythdnn', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (405, '13688669284', '', 'member_alzyibl549', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (406, '13688669285', '', 'member_3nhqsa0htg', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (407, '13688669286', '', 'member_vn81ys9n64', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (408, '13688669287', '', 'member_iz6t7kpxz2', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (409, '13688669288', '', 'member_7gnmjhg1rh', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (410, '13688669289', '', 'member_r2i71mq5lk', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (411, '13688669290', '', 'member_gevxv4bfda', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (412, '13688669291', '', 'member_hqneva0vaz', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (413, '13688669292', '', 'member_8fvquxjm0t', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (414, '13688669293', '', 'member_9u8dxzs9nk', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (415, '13688669294', '', 'member_8mwcrg9ez9', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (416, '13688669295', '', 'member_erzqptr80b', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (417, '13688669296', '', 'member_97xgccgwaf', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (418, '13688669297', '', 'member_5rz6s0zuoh', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (419, '13688669298', '', 'member_8o7cg6rp05', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (420, '13688669299', '', 'member_rhftetybs4', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (421, '13688669300', '', 'member_mjh9uzi92z', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (422, '13688669301', '', 'member_bvaub566b3', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (423, '13688669302', '', 'member_e97b0z12jc', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (424, '13688669303', '', 'member_mcc1pteaw5', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (425, '13688669304', '', 'member_gz1ymib0dl', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (426, '13688669305', '', 'member_owszpn6jem', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (427, '13688669306', '', 'member_nyqxiekdus', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (428, '13688669307', '', 'member_ilr27xnuxu', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (429, '13688669308', '', 'member_mhzftdfxi4', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (430, '13688669309', '', 'member_kavgc8r8f6', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (431, '13688669310', '', 'member_svztbpgr9w', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (432, '13688669311', '', 'member_fdjhoysgy8', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (433, '13688669312', '', 'member_drssks7627', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (434, '13688669313', '', 'member_53kuim78p1', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (435, '13688669314', '', 'member_tpjaw9ygl6', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (436, '13688669315', '', 'member_zlj9ao4lbw', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (437, '13688669316', '', 'member_9nsckyz0k8', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (438, '13688669317', '', 'member_rkyjx5n0k9', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (439, '13688669318', '', 'member_e47mr17jmo', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (440, '13688669319', '', 'member_gdouwxu8bm', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (441, '13688669320', '', 'member_7odu05tcri', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (442, '13688669321', '', 'member_x6dga1y84j', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (443, '13688669322', '', 'member_ubzwoytroz', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (444, '13688669323', '', 'member_brivojp5b1', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (445, '13688669324', '', 'member_q5sluitgii', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (446, '13688669325', '', 'member_bbqazzzawl', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (447, '13688669326', '', 'member_82fbd0oo0u', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (448, '13688669327', '', 'member_87ft14as7t', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (449, '13688669328', '', 'member_diabg787km', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (450, '13688669329', '', 'member_oo1gf0pxln', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (451, '13688669330', '', 'member_4fc1q8u2f3', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (452, '13688669331', '', 'member_hgny53jwpn', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (453, '13688669332', '', 'member_5m75miuy6r', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (454, '13688669333', '', 'member_qx5ohjcayd', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (455, '13688669334', '', 'member_cff2zkpu62', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (456, '13688669335', '', 'member_dsb1rk9dsr', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (457, '13688669336', '', 'member_50h3ylhjnz', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (458, '13688669337', '', 'member_i02f5rjdab', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (459, '13688669338', '', 'member_3vwdqpif1l', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (460, '13688669339', '', 'member_g6xewzg33w', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (461, '13688669340', '', 'member_63u60u6o7f', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (462, '13688669341', '', 'member_m6ikxcr92q', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (463, '13688669342', '', 'member_yzd5lmecur', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (464, '13688669343', '', 'member_m3163uc9al', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (465, '13688669344', '', 'member_1x6f94jq0v', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (466, '13688669345', '', 'member_keo0udy60g', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (467, '13688669346', '', 'member_87y52es2uw', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (468, '13688669347', '', 'member_1zkkz9j0e6', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (469, '13688669348', '', 'member_baznwk8x5q', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (470, '13688669349', '', 'member_b4hnhsmpxw', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (471, '13688669350', '', 'member_1hr6wbd939', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (472, '13688669351', '', 'member_4w7dhr290a', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (473, '13688669352', '', 'member_tkxg6jo3xa', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (474, '13688669353', '', 'member_saosjqptnq', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (475, '13688669354', '', 'member_wjge9hxzfv', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (476, '13688669355', '', 'member_8ex8ynmec4', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (477, '13688669356', '', 'member_beih06msot', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (478, '13688669357', '', 'member_e4tuso2fad', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (479, '13688669358', '', 'member_iolxs2wbfs', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (480, '13688669359', '', 'member_5trre9akf1', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (481, '13688669360', '', 'member_y3l832hamq', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (482, '13688669361', '', 'member_gs7kvt65y8', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (483, '13688669362', '', 'member_8rda39nfpx', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (484, '13688669363', '', 'member_wix6t6g14l', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (485, '13688669364', '', 'member_s2k023vtn7', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (486, '13688669365', '', 'member_qc3nhavb9f', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (487, '13688669366', '', 'member_98eoecfe9s', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (488, '13688669367', '', 'member_kknik7xw80', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (489, '13688669368', '', 'member_17d7bifhpp', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (490, '13688669369', '', 'member_04vbus432n', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (491, '13688669370', '', 'member_3e1xl0tvss', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (492, '13688669371', '', 'member_jpvv20rmfk', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (493, '13688669372', '', 'member_51jd3tfl3e', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (494, '13688669373', '', 'member_agt44szvcb', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (495, '13688669374', '', 'member_pr7icguenq', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (496, '13688669375', '', 'member_2jl0qaecm0', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (497, '13688669376', '', 'member_m1fxzx8i0u', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (498, '13688669377', '', 'member_fh7a1j0vaz', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (499, '13688669378', '', 'member_ty7afbm01v', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (500, '13688669379', '', 'member_bwazk1tt71', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (501, '13688669380', '', 'member_c1wrwmqzfi', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (502, '13688669381', '', 'member_nbfyg2pfql', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (503, '13688669382', '', 'member_h85lj9y0jy', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (504, '13688669383', '', 'member_e0r5gg439j', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (505, '13688669384', '', 'member_k0s8h8v8wt', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (506, '13688669385', '', 'member_0v423qhiz2', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (507, '13688669386', '', 'member_zgze48neoq', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (508, '13688669387', '', 'member_un4nppmh7k', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (509, '13688669388', '', 'member_knr2flv5mr', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (510, '13688669389', '', 'member_cvhg3r8aqj', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (511, '13688669390', '', 'member_92xh46mlff', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (512, '13688669391', '', 'member_vhp8pxmhk6', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (513, '13688669392', '', 'member_hc4c7z9y3k', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (514, '13688669393', '', 'member_03ikpqtn96', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (515, '13688669394', '', 'member_g0l23kj1ta', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (516, '13688669395', '', 'member_hdd1qkfbjy', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (517, '13688669396', '', 'member_vmc478haq2', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (518, '13688669397', '', 'member_g16kk9w1jp', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (519, '13688669398', '', 'member_vlviloabak', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (520, '13688669399', '', 'member_f4t9c9x0qs', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (521, '13688669400', '', 'member_uhd0vskqux', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (522, '13688669401', '', 'member_uidqqwety9', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (523, '13688669402', '', 'member_ijqz4fb077', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (524, '13688669403', '', 'member_d16wfogt38', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (525, '13688669404', '', 'member_50cj7qxejp', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (526, '13688669405', '', 'member_w0mawjfxbf', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (527, '13688669406', '', 'member_vihcs8gddy', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (528, '13688669407', '', 'member_1io84j51kb', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (529, '13688669408', '', 'member_sac23jn0ct', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (530, '13688669409', '', 'member_84saoi0eaq', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (531, '13688669410', '', 'member_bqfd0lusff', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (532, '13688669411', '', 'member_a717jzadbk', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (533, '13688669412', '', 'member_3e6nd805yp', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (534, '13688669413', '', 'member_bgkv3zjjsy', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (535, '13688669414', '', 'member_4lzfuo6hcl', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (536, '13688669415', '', 'member_y748pleoq8', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (537, '13688669416', '', 'member_ciyuki97of', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (538, '13688669417', '', 'member_kaulf89rnl', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (539, '13688669418', '', 'member_h0dan7ux0u', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (540, '13688669419', '', 'member_fvmx4u2re0', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (541, '13688669420', '', 'member_njomftlkps', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (542, '13688669421', '', 'member_2ezx5lxtc4', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (543, '13688669422', '', 'member_161mxzchbt', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (544, '13688669423', '', 'member_f8e3enit63', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (545, '13688669424', '', 'member_j1ygvb30zr', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (546, '13688669425', '', 'member_lskpl9geya', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (547, '13688669426', '', 'member_feww9njnhi', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (548, '13688669427', '', 'member_e8x6u5i9ca', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (549, '13688669428', '', 'member_17al8oqa4w', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (550, '13688669429', '', 'member_nbo1m8bazt', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (551, '13688669430', '', 'member_rqfyp2isyr', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (552, '13688669431', '', 'member_epr1i52q5x', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (553, '13688669432', '', 'member_x154dr8sch', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (554, '13688669433', '', 'member_i5lvnupsu6', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (555, '13688669434', '', 'member_qsnre265gc', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (556, '13688669435', '', 'member_7f3zwt1uso', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (557, '13688669436', '', 'member_qgkrbv1r7p', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (558, '13688669437', '', 'member_b39j58u8ql', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (559, '13688669438', '', 'member_wby0tn39v5', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (560, '13688669439', '', 'member_9vt11wm6wb', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (561, '13688669440', '', 'member_y4rokt5rzh', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (562, '13688669441', '', 'member_lyarwzepjm', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (563, '13688669442', '', 'member_er844jel5s', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (564, '13688669443', '', 'member_2gkdrbu7rd', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (565, '13688669444', '', 'member_fnks15rgap', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (566, '13688669445', '', 'member_fe79dtlbf3', '', '2022-02-28 10:50:50', '2022-02-28 10:50:50');
INSERT INTO `gy_member` VALUES (567, '13688669446', '', 'member_jrl1kdhopy', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (568, '13688669447', '', 'member_p5h5hfw0h5', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (569, '13688669448', '', 'member_756lckggox', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (570, '13688669449', '', 'member_9w56lad204', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (571, '13688669450', '', 'member_kjfvuonq64', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (572, '13688669451', '', 'member_k1i16oya8x', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (573, '13688669452', '', 'member_z4wz2wq9oj', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (574, '13688669453', '', 'member_jotms6c1vz', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (575, '13688669454', '', 'member_29iu6j1olp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (576, '13688669455', '', 'member_rfkqpu7bs1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (577, '13688669456', '', 'member_yecqp8c38k', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (578, '13688669457', '', 'member_1mbkrz4rng', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (579, '13688669458', '', 'member_bx6h4wu47y', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (580, '13688669459', '', 'member_usub0nsxez', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (581, '13688669460', '', 'member_2vvxjpuwgr', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (582, '13688669461', '', 'member_9tmhy4nfm1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (583, '13688669462', '', 'member_q1gyjoatnm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (584, '13688669463', '', 'member_vaqe3soyoz', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (585, '13688669464', '', 'member_bz81fj51ul', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (586, '13688669465', '', 'member_pwp8w2oife', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (587, '13688669466', '', 'member_6i8a8jpc4a', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (588, '13688669467', '', 'member_e19oms872y', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (589, '13688669468', '', 'member_7jnvjujuk5', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (590, '13688669469', '', 'member_1brabvuxfp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (591, '13688669470', '', 'member_w25xjchkmt', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (592, '13688669471', '', 'member_qc38678j1q', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (593, '13688669472', '', 'member_5wqfc087pg', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (594, '13688669473', '', 'member_l921wy6ghf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (595, '13688669474', '', 'member_qgdwy1c8ya', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (596, '13688669475', '', 'member_2ftowbar49', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (597, '13688669476', '', 'member_e0rqhfdde9', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (598, '13688669477', '', 'member_vpswd32xps', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (599, '13688669478', '', 'member_ec479wdojq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (600, '13688669479', '', 'member_6kz95u775k', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (601, '13688669480', '', 'member_iyyh1jdjvk', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (602, '13688669481', '', 'member_jbv97r3zcf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (603, '13688669482', '', 'member_1t7nmmwx2g', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (604, '13688669483', '', 'member_fb8j6mb1cn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (605, '13688669484', '', 'member_ld0b3fd8uk', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (606, '13688669485', '', 'member_sv8tt0fhb0', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (607, '13688669486', '', 'member_ovqhhaqzfs', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (608, '13688669487', '', 'member_mdybbx800t', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (609, '13688669488', '', 'member_dy1n5yoxhv', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (610, '13688669489', '', 'member_xefu4y7d2d', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (611, '13688669490', '', 'member_4aun9z96dn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (612, '13688669491', '', 'member_guva8ofunq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (613, '13688669492', '', 'member_6l4gzaotnf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (614, '13688669493', '', 'member_ngbcy6a2zk', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (615, '13688669494', '', 'member_dqqj7ti3pd', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (616, '13688669495', '', 'member_5zq4rzlbik', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (617, '13688669496', '', 'member_7e0qi512hf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (618, '13688669497', '', 'member_jpmnhzwesi', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (619, '13688669498', '', 'member_00xb9uvv0m', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (620, '13688669499', '', 'member_nxn2ldt3gl', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (621, '13688669500', '', 'member_cyd1a9zfqw', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (622, '13688669501', '', 'member_0nhklq4xie', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (623, '13688669502', '', 'member_rtf3z1wptn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (624, '13688669503', '', 'member_ov4uix8csm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (625, '13688669504', '', 'member_lxi5i68cdf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (626, '13688669505', '', 'member_do1slgl1ph', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (627, '13688669506', '', 'member_qj8pbsjpl5', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (628, '13688669507', '', 'member_ygrl56l48d', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (629, '13688669508', '', 'member_maynz9h3vn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (630, '13688669509', '', 'member_m7qnvuej5k', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (631, '13688669510', '', 'member_ceg7kezzrd', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (632, '13688669511', '', 'member_v7ky9w9v6f', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (633, '13688669512', '', 'member_kk8rzbittq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (634, '13688669513', '', 'member_mskczihgi8', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (635, '13688669514', '', 'member_0tmadlzf1j', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (636, '13688669515', '', 'member_oeui72807w', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (637, '13688669516', '', 'member_ad49besbbs', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (638, '13688669517', '', 'member_huzzpviaax', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (639, '13688669518', '', 'member_b0p11t8qon', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (640, '13688669519', '', 'member_14k8fje63n', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (641, '13688669520', '', 'member_bl5rc085pr', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (642, '13688669521', '', 'member_938covh4nt', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (643, '13688669522', '', 'member_olt9qfefvw', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (644, '13688669523', '', 'member_bhkdwtkfdg', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (645, '13688669524', '', 'member_we6790rc8v', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (646, '13688669525', '', 'member_wqmiqbrj3a', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (647, '13688669526', '', 'member_ccdo9ncgzt', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (648, '13688669527', '', 'member_pk3l58b3cf', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (649, '13688669528', '', 'member_meqr7dxbog', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (650, '13688669529', '', 'member_x70v1uaf0g', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (651, '13688669530', '', 'member_yijawdxi8k', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (652, '13688669531', '', 'member_qlv8jnv927', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (653, '13688669532', '', 'member_2tkj1s7aex', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (654, '13688669533', '', 'member_5vbfw1gln6', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (655, '13688669534', '', 'member_zseyyi59z2', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (656, '13688669535', '', 'member_8ch1tq5bfp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (657, '13688669536', '', 'member_gdgb5nbkqn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (658, '13688669537', '', 'member_rr5448qo4l', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (659, '13688669538', '', 'member_e6zwifzqhw', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (660, '13688669539', '', 'member_7ytv4vd6he', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (661, '13688669540', '', 'member_pc84newj49', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (662, '13688669541', '', 'member_h4wpk3e9ht', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (663, '13688669542', '', 'member_d3vt4vqim8', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (664, '13688669543', '', 'member_eqr14mgaz2', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (665, '13688669544', '', 'member_ldd4kzq961', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (666, '13688669545', '', 'member_w4qu1bb2lk', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (667, '13688669546', '', 'member_0627bn8px3', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (668, '13688669547', '', 'member_64aj20cdf1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (669, '13688669548', '', 'member_l7u34b3ler', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (670, '13688669549', '', 'member_2ze9tl9994', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (671, '13688669550', '', 'member_m5phoejixm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (672, '13688669551', '', 'member_8ogdovuirm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (673, '13688669552', '', 'member_wfk4ebck83', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (674, '13688669553', '', 'member_oupbnni466', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (675, '13688669554', '', 'member_89967wcevq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (676, '13688669555', '', 'member_xr6g2q08cm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (677, '13688669556', '', 'member_m313bjckeq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (678, '13688669557', '', 'member_x25nq1ss14', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (679, '13688669558', '', 'member_jeidzxzp6y', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (680, '13688669559', '', 'member_l7dkffo3n0', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (681, '13688669560', '', 'member_pqio9ol2ln', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (682, '13688669561', '', 'member_k1cbsqi4gt', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (683, '13688669562', '', 'member_p1i9b4p4sv', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (684, '13688669563', '', 'member_07yfm6qtl1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (685, '13688669564', '', 'member_y3mmmk1kak', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (686, '13688669565', '', 'member_lkxjnwtqa7', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (687, '13688669566', '', 'member_v5w9pm18iq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (688, '13688669567', '', 'member_364l5poxpw', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (689, '13688669568', '', 'member_trlfkptv3g', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (690, '13688669569', '', 'member_rkheg82tnp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (691, '13688669570', '', 'member_5zmzrjgo5o', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (692, '13688669571', '', 'member_6uacx6cqhp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (693, '13688669572', '', 'member_wnats1phoj', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (694, '13688669573', '', 'member_dcm1w7674v', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (695, '13688669574', '', 'member_r7ik7ae272', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (696, '13688669575', '', 'member_xk77qyl4gl', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (697, '13688669576', '', 'member_989d1fsji4', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (698, '13688669577', '', 'member_macs32vcct', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (699, '13688669578', '', 'member_z5mahfpa9r', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (700, '13688669579', '', 'member_tn1bnk3zir', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (701, '13688669580', '', 'member_95ajn6osry', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (702, '13688669581', '', 'member_qff1n375uc', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (703, '13688669582', '', 'member_gdjqlq4i6n', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (704, '13688669583', '', 'member_w6tsnpzfqn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (705, '13688669584', '', 'member_lqp4c4j2ch', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (706, '13688669585', '', 'member_1raii40ps1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (707, '13688669586', '', 'member_0r9izz201x', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (708, '13688669587', '', 'member_vlrp22q0rk', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (709, '13688669588', '', 'member_f7kvbzb8i4', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (710, '13688669589', '', 'member_yn8nntyyur', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (711, '13688669590', '', 'member_p58nxqajou', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (712, '13688669591', '', 'member_61msspy26k', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (713, '13688669592', '', 'member_fqb0ch1hh1', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (714, '13688669593', '', 'member_oyq3nszclx', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (715, '13688669594', '', 'member_ggybvkn73t', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (716, '13688669595', '', 'member_po0gph6jgp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (717, '13688669596', '', 'member_hlzvh6wl1y', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (718, '13688669597', '', 'member_btb024hqic', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (719, '13688669598', '', 'member_wqasvon847', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (720, '13688669599', '', 'member_rdp7fvaz3z', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (721, '13688669600', '', 'member_oh5q9kfkvc', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (722, '13688669601', '', 'member_ae21kmiles', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (723, '13688669602', '', 'member_b1ouyw3sww', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (724, '13688669603', '', 'member_9o5qz4s17l', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (725, '13688669604', '', 'member_6urs1iwti9', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (726, '13688669605', '', 'member_80pnfhyqyi', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (727, '13688669606', '', 'member_mynvmq4zcn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (728, '13688669607', '', 'member_q09fj27oc4', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (729, '13688669608', '', 'member_v4e7hkfw63', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (730, '13688669609', '', 'member_x4sol5dj4f', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (731, '13688669610', '', 'member_v53dsicdtx', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (732, '13688669611', '', 'member_fcoezs141i', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (733, '13688669612', '', 'member_viv3l4o52c', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (734, '13688669613', '', 'member_8j4m80dj76', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (735, '13688669614', '', 'member_r65xyt3opb', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (736, '13688669615', '', 'member_moi9x442th', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (737, '13688669616', '', 'member_qxkltii6ec', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (738, '13688669617', '', 'member_72vsybd20b', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (739, '13688669618', '', 'member_eai1g9ltu9', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (740, '13688669619', '', 'member_h47ubi7f36', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (741, '13688669620', '', 'member_yxo46519hp', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (742, '13688669621', '', 'member_499diayvwn', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (743, '13688669622', '', 'member_ytomkocl3c', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (744, '13688669623', '', 'member_271mt5x5uo', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (745, '13688669624', '', 'member_h5s36mj609', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (746, '13688669625', '', 'member_sklzx3z3nq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (747, '13688669626', '', 'member_9v2ikjkwm8', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (748, '13688669627', '', 'member_w5jjd49ipx', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (749, '13688669628', '', 'member_3rzokm18yo', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (750, '13688669629', '', 'member_vm6zz6ejs7', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (751, '13688669630', '', 'member_r494p0jlle', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (752, '13688669631', '', 'member_c50thdpyv0', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (753, '13688669632', '', 'member_hc4qi0sfo2', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (754, '13688669633', '', 'member_w8y4nebzxs', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (755, '13688669634', '', 'member_mxxqu6isy9', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (756, '13688669635', '', 'member_sd3f76mtg3', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (757, '13688669636', '', 'member_6zb026vsmm', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (758, '13688669637', '', 'member_mzya91331l', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (759, '13688669638', '', 'member_adu5gmym2g', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (760, '13688669639', '', 'member_31bidh90w5', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (761, '13688669640', '', 'member_iectlacbk7', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (762, '13688669641', '', 'member_by8vl07035', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (763, '13688669642', '', 'member_n8ii3p3b6z', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (764, '13688669643', '', 'member_eopvczuyzq', '', '2022-02-28 10:50:51', '2022-02-28 10:50:51');
INSERT INTO `gy_member` VALUES (765, '13688669644', '', 'member_2m36qy9yht', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (766, '13688669645', '', 'member_re1q80zze2', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (767, '13688669646', '', 'member_lelhu217ad', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (768, '13688669647', '', 'member_dyv7ll1h9r', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (769, '13688669648', '', 'member_7zws9wi4cp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (770, '13688669649', '', 'member_tvseis2smv', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (771, '13688669650', '', 'member_975ls201ra', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (772, '13688669651', '', 'member_0416smxpjc', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (773, '13688669652', '', 'member_dkdw3wuvxt', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (774, '13688669653', '', 'member_d1z5jtfh2g', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (775, '13688669654', '', 'member_yg9r3ws35z', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (776, '13688669655', '', 'member_9cos7jzgmy', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (777, '13688669656', '', 'member_679sq0b6eb', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (778, '13688669657', '', 'member_kzk5m1pgqv', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (779, '13688669658', '', 'member_28qetr02oe', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (780, '13688669659', '', 'member_peazcxx51i', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (781, '13688669660', '', 'member_roghf2lerp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (782, '13688669661', '', 'member_sth9xhgsoj', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (783, '13688669662', '', 'member_38ejcd1npp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (784, '13688669663', '', 'member_m0y48rqbxs', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (785, '13688669664', '', 'member_a0f919rrdw', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (786, '13688669665', '', 'member_veddhmnfa7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (787, '13688669666', '', 'member_ltexwx6bm6', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (788, '13688669667', '', 'member_euqn9si8dg', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (789, '13688669668', '', 'member_wm4s4v0o87', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (790, '13688669669', '', 'member_mthbqaorve', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (791, '13688669670', '', 'member_k63cindeeh', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (792, '13688669671', '', 'member_kz30acb48r', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (793, '13688669672', '', 'member_1jmeyd8a28', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (794, '13688669673', '', 'member_su5oi3kpfx', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (795, '13688669674', '', 'member_4eurdp0387', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (796, '13688669675', '', 'member_orxdegd4d4', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (797, '13688669676', '', 'member_50vxeli8rd', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (798, '13688669677', '', 'member_vqsnl66ot5', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (799, '13688669678', '', 'member_en3q7qyiqb', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (800, '13688669679', '', 'member_0yyk9mnng0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (801, '13688669680', '', 'member_l48qjtjmxl', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (802, '13688669681', '', 'member_1wvigh2hxq', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (803, '13688669682', '', 'member_gr0bhwfvhu', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (804, '13688669683', '', 'member_qpku5s9nr6', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (805, '13688669684', '', 'member_kyhepj12kd', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (806, '13688669685', '', 'member_3x99ypxvqy', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (807, '13688669686', '', 'member_np8bk7b07w', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (808, '13688669687', '', 'member_dnu8kswk6o', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (809, '13688669688', '', 'member_u01mnauofu', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (810, '13688669689', '', 'member_48sv36r3xs', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (811, '13688669690', '', 'member_6ojf6nhxch', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (812, '13688669691', '', 'member_wd32jqla7r', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (813, '13688669692', '', 'member_zsdxxcpkuq', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (814, '13688669693', '', 'member_ib97xw8nl2', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (815, '13688669694', '', 'member_b7qb56z1p0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (816, '13688669695', '', 'member_i7jmrgmisg', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (817, '13688669696', '', 'member_5nf21zmos7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (818, '13688669697', '', 'member_mck6nqe55g', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (819, '13688669698', '', 'member_6xnadvfus7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (820, '13688669699', '', 'member_450u8mqe4z', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (821, '13688669700', '', 'member_hv55cq5n1w', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (822, '13688669701', '', 'member_qiy3ulbyd0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (823, '13688669702', '', 'member_sx58542ugn', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (824, '13688669703', '', 'member_9xs0uuyds5', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (825, '13688669704', '', 'member_zveuo0azp4', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (826, '13688669705', '', 'member_qwt4x5faay', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (827, '13688669706', '', 'member_ztzuqeybvp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (828, '13688669707', '', 'member_kh5n7wfie8', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (829, '13688669708', '', 'member_dwxkvw03b7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (830, '13688669709', '', 'member_3tyhv91k7p', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (831, '13688669710', '', 'member_0jwdppbvdk', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (832, '13688669711', '', 'member_twx4z08vzb', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (833, '13688669712', '', 'member_lly5v9ibpk', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (834, '13688669713', '', 'member_kkho7xpu2u', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (835, '13688669714', '', 'member_l51d2os1wh', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (836, '13688669715', '', 'member_i6gkyfawkv', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (837, '13688669716', '', 'member_v2k5vdh4he', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (838, '13688669717', '', 'member_7k9ql2go9e', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (839, '13688669718', '', 'member_tnz3f99w2c', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (840, '13688669719', '', 'member_833zw6fgxz', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (841, '13688669720', '', 'member_f4hq0ga1oj', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (842, '13688669721', '', 'member_uxuxrig26t', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (843, '13688669722', '', 'member_grn37re7bg', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (844, '13688669723', '', 'member_5msjf8z2fj', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (845, '13688669724', '', 'member_53x3w7l7mv', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (846, '13688669725', '', 'member_pyolvy8m0v', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (847, '13688669726', '', 'member_12i4hpk09n', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (848, '13688669727', '', 'member_zjhyyt7zfq', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (849, '13688669728', '', 'member_avv8zgw4qk', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (850, '13688669729', '', 'member_khxmnqb6ni', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (851, '13688669730', '', 'member_i80iu0pb5k', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (852, '13688669731', '', 'member_lqkx9uurmj', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (853, '13688669732', '', 'member_ewiswre8fm', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (854, '13688669733', '', 'member_d0nwznn64y', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (855, '13688669734', '', 'member_v7wyz44u6m', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (856, '13688669735', '', 'member_ipkx0z0nno', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (857, '13688669736', '', 'member_64tnyqwxun', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (858, '13688669737', '', 'member_r9bjp3fegg', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (859, '13688669738', '', 'member_i36s8hsq72', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (860, '13688669739', '', 'member_cqe1zvq4dr', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (861, '13688669740', '', 'member_omdgisd0ls', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (862, '13688669741', '', 'member_3mgz8z636y', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (863, '13688669742', '', 'member_ts3qtzwp68', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (864, '13688669743', '', 'member_56seol3kxp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (865, '13688669744', '', 'member_4x55muo0si', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (866, '13688669745', '', 'member_ny46fscq78', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (867, '13688669746', '', 'member_raano2keb9', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (868, '13688669747', '', 'member_31m00sj2bt', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (869, '13688669748', '', 'member_2ovmzeq4f3', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (870, '13688669749', '', 'member_dis12x5ko3', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (871, '13688669750', '', 'member_jx9defd5pu', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (872, '13688669751', '', 'member_k3u9zems0n', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (873, '13688669752', '', 'member_o84aucm31f', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (874, '13688669753', '', 'member_h4msccd8qo', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (875, '13688669754', '', 'member_6sk051bxed', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (876, '13688669755', '', 'member_1s1r4kks05', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (877, '13688669756', '', 'member_2pfvfdb27x', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (878, '13688669757', '', 'member_k5nxhuil69', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (879, '13688669758', '', 'member_6wu2vujv7x', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (880, '13688669759', '', 'member_05jr9c63o0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (881, '13688669760', '', 'member_cc2l1lrlw5', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (882, '13688669761', '', 'member_ieeqrlof8f', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (883, '13688669762', '', 'member_6m5ermqkua', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (884, '13688669763', '', 'member_mh99rug0nh', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (885, '13688669764', '', 'member_n55ceoc392', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (886, '13688669765', '', 'member_72vzhk8py3', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (887, '13688669766', '', 'member_bthii5wt36', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (888, '13688669767', '', 'member_mut3q0vunf', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (889, '13688669768', '', 'member_symgsydmbd', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (890, '13688669769', '', 'member_7qs7kedl19', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (891, '13688669770', '', 'member_uwyx1i29m0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (892, '13688669771', '', 'member_ls2p6sldmi', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (893, '13688669772', '', 'member_1kmmkpegso', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (894, '13688669773', '', 'member_4zp483y1e7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (895, '13688669774', '', 'member_nr78kan9c3', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (896, '13688669775', '', 'member_0r0m7ngv6x', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (897, '13688669776', '', 'member_lknjznxmau', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (898, '13688669777', '', 'member_v9g6j6h0ah', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (899, '13688669778', '', 'member_wuyim37fx5', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (900, '13688669779', '', 'member_l0lfqjjzs0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (901, '13688669780', '', 'member_6uyxk7pa4u', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (902, '13688669781', '', 'member_f17o0qymn9', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (903, '13688669782', '', 'member_ogpqk1b39a', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (904, '13688669783', '', 'member_9jpofrgda1', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (905, '13688669784', '', 'member_n298v8udm3', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (906, '13688669785', '', 'member_0biwjc5wwt', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (907, '13688669786', '', 'member_xbbdx6wq53', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (908, '13688669787', '', 'member_nh79qly5ir', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (909, '13688669788', '', 'member_v86oajknbs', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (910, '13688669789', '', 'member_e13odsshad', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (911, '13688669790', '', 'member_6cvwrirdtl', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (912, '13688669791', '', 'member_nqr7bpgz67', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (913, '13688669792', '', 'member_wn1ae0p6gw', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (914, '13688669793', '', 'member_te48rluimb', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (915, '13688669794', '', 'member_p2r85n4k8g', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (916, '13688669795', '', 'member_ca8fdlrbty', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (917, '13688669796', '', 'member_toque00p0i', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (918, '13688669797', '', 'member_uiti5cdbhf', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (919, '13688669798', '', 'member_8pgku7viy8', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (920, '13688669799', '', 'member_cdafki4cwc', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (921, '13688669800', '', 'member_fyyk2yfpk5', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (922, '13688669801', '', 'member_78e1meevls', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (923, '13688669802', '', 'member_qzwls7m33b', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (924, '13688669803', '', 'member_jxuw8ixefk', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (925, '13688669804', '', 'member_1xye60infx', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (926, '13688669805', '', 'member_gvccna2mni', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (927, '13688669806', '', 'member_tftvpegd2c', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (928, '13688669807', '', 'member_6ihh78vpox', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (929, '13688669808', '', 'member_46qroyojdl', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (930, '13688669809', '', 'member_wwi4i2wb77', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (931, '13688669810', '', 'member_s28l0bryil', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (932, '13688669811', '', 'member_4lgib8jvrx', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (933, '13688669812', '', 'member_fczpz5s31b', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (934, '13688669813', '', 'member_3cvkn9pv9w', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (935, '13688669814', '', 'member_wtvk7gx8ar', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (936, '13688669815', '', 'member_yrel6rbyyd', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (937, '13688669816', '', 'member_hmxjnsbnon', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (938, '13688669817', '', 'member_cuxcl0d2oo', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (939, '13688669818', '', 'member_1ax8x9zw0c', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (940, '13688669819', '', 'member_p7v98oe5nm', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (941, '13688669820', '', 'member_m90rt3bwsz', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (942, '13688669821', '', 'member_xhty5jm1hy', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (943, '13688669822', '', 'member_7h88k22eo0', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (944, '13688669823', '', 'member_5a75z9jcqa', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (945, '13688669824', '', 'member_3t0twwq0nh', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (946, '13688669825', '', 'member_861ywr4gfr', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (947, '13688669826', '', 'member_iwkz8k1zpx', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (948, '13688669827', '', 'member_vzmhyoz1ap', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (949, '13688669828', '', 'member_5tmpddukgq', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (950, '13688669829', '', 'member_h6siyam4hb', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (951, '13688669830', '', 'member_n5yqq6mgka', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (952, '13688669831', '', 'member_an9epa7f2r', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (953, '13688669832', '', 'member_5vr0cdy8sz', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (954, '13688669833', '', 'member_xpanlhqjbq', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (955, '13688669834', '', 'member_3cfykc172m', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (956, '13688669835', '', 'member_1n0jceyzim', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (957, '13688669836', '', 'member_4ixi7efxtr', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (958, '13688669837', '', 'member_5adpp336iy', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (959, '13688669838', '', 'member_mflzjd6e6b', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (960, '13688669839', '', 'member_80bwfj72p7', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (961, '13688669840', '', 'member_i3anusitco', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (962, '13688669841', '', 'member_yj4pcsrkl9', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (963, '13688669842', '', 'member_7v9x6gxjdz', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (964, '13688669843', '', 'member_2ahufmnyzp', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (965, '13688669844', '', 'member_1oel6c441t', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (966, '13688669845', '', 'member_qxzcv0ib6g', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (967, '13688669846', '', 'member_9uyh0i8ykg', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (968, '13688669847', '', 'member_tb01d4d9ql', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (969, '13688669848', '', 'member_hwpkx6ovii', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (970, '13688669849', '', 'member_pqd04q9hq2', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (971, '13688669850', '', 'member_4t7wkgkufh', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (972, '13688669851', '', 'member_834e4vzf0e', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (973, '13688669852', '', 'member_pxk4urlnmo', '', '2022-02-28 10:50:52', '2022-02-28 10:50:52');
INSERT INTO `gy_member` VALUES (974, '13688669853', '', 'member_e3x6n0ff0d', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (975, '13688669854', '', 'member_wxnvsvb5ut', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (976, '13688669855', '', 'member_ehi7k4zpjb', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (977, '13688669856', '', 'member_om0pzyh3z1', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (978, '13688669857', '', 'member_9asdqbe7od', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (979, '13688669858', '', 'member_seuabngxt9', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (980, '13688669859', '', 'member_b0qvb27eiy', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (981, '13688669860', '', 'member_63sjue2tkh', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (982, '13688669861', '', 'member_cc3lvxfr1u', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (983, '13688669862', '', 'member_in37hfw5tk', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (984, '13688669863', '', 'member_jtg0c9tyqn', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (985, '13688669864', '', 'member_qzpipaj50w', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (986, '13688669865', '', 'member_ppnb4ljetq', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (987, '13688669866', '', 'member_zbcui7783k', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (988, '13688669867', '', 'member_ki4dxb9q9b', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (989, '13688669868', '', 'member_27b5dxktn0', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (990, '13688669869', '', 'member_fxvb2av882', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (991, '13688669870', '', 'member_6vp3uflnwm', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (992, '13688669871', '', 'member_7ix7djbg30', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (993, '13688669872', '', 'member_vx8r39tjiu', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (994, '13688669873', '', 'member_l2wdiwule0', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (995, '13688669874', '', 'member_z4qe1up5zx', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (996, '13688669875', '', 'member_bklo4b32lu', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (997, '13688669876', '', 'member_ax0y473ndh', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (998, '13688669877', '', 'member_yx2p44qww3', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (999, '13688669878', '', 'member_bnw9bzib34', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1000, '13688669879', '', 'member_cdj4ojh4pc', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1001, '13688669880', '', 'member_l7o3r96hn3', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1002, '13688669881', '', 'member_zbehzrz279', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1003, '13688669882', '', 'member_tql21zepcx', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1004, '13688669883', '', 'member_jnxnrk8qt0', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1005, '13688669884', '', 'member_8e5twg6q0k', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1006, '13688669885', '', 'member_gfeusukbpp', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1007, '13688669886', '', 'member_sveivfswhn', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1008, '13688669887', '', 'member_qgf4t8jkx0', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');
INSERT INTO `gy_member` VALUES (1009, '13688669888', '', 'member_4qh6bofkol', '', '2022-02-28 10:50:53', '2022-02-28 10:50:53');

-- ----------------------------
-- Table structure for gy_member_profile
-- ----------------------------
DROP TABLE IF EXISTS `gy_member_profile`;
CREATE TABLE `gy_member_profile`  (
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '主键，成员id',
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '城市名称',
  `introduce` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '个人介绍，不要超过128个字符',
  `fans` int(8) UNSIGNED NULL DEFAULT 0 COMMENT '粉丝数量',
  `followee` int(8) UNSIGNED NULL DEFAULT 0 COMMENT '关注的人的数量',
  `gender` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '性别，0：男，1：女',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `credits` int(8) UNSIGNED NULL DEFAULT 0 COMMENT '积分',
  `level` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '会员级别，0~9级,0代表未开通会员',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`member_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_member_profile
-- ----------------------------

-- ----------------------------
-- Table structure for gy_benefit
-- ----------------------------
DROP TABLE IF EXISTS `gy_benefit`;
CREATE TABLE `gy_benefit`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `merchant_id` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '商户id',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '权益标题',
  `sub_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '副标题',
  `rules` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '使用规则',
  `threshold_amount` bigint(10) UNSIGNED NOT NULL COMMENT '支付金额，单位是分。例如200代表2元',
  `benefit_amount` bigint(10) NOT NULL COMMENT '抵扣金额，单位是分。例如200代表2元',
  `type` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0,普通券；1,限时权益券',
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '1,上架; 2,下架; 3,过期',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_benefit
-- ----------------------------
INSERT INTO `gy_benefit` VALUES (1, 1, '构域咖啡50元权益', '园区营业时段均可使用', '全场通用\\n无需预约\\n不可兑现、不找零\\n仅限到店使用', 4750, 5000, 0, 1, '2022-01-04 09:42:39', '2022-01-04 09:43:31');

-- ----------------------------
-- Table structure for gy_benefit_order
-- ----------------------------
DROP TABLE IF EXISTS `gy_benefit_order`;
CREATE TABLE `gy_benefit_order`  (
  `id` bigint(20) NOT NULL COMMENT '主键',
  `member_id` bigint(20) UNSIGNED NOT NULL COMMENT '领取权益的成员id',
  `benefit_id` bigint(20) UNSIGNED NOT NULL COMMENT '购买的权益id',
  `pay_type` tinyint(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '支付方式 1：余额支付；2：支付宝；3：微信',
  `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 1 COMMENT '权益记录状态，1：未支付；2：已支付；3：已核销；4：已取消；5：退款中；6：已退款',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `pay_time` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  `use_time` timestamp NULL DEFAULT NULL COMMENT '核销时间',
  `refund_time` timestamp NULL DEFAULT NULL COMMENT '退款时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_member_benefit` (`member_id`, `benefit_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of gy_benefit_order
-- ----------------------------

-- ----------------------------
-- Table structure for gy_benefit_order_process
-- ----------------------------
DROP TABLE IF EXISTS `gy_benefit_order_process`;
CREATE TABLE `gy_benefit_order_process` (
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

SET FOREIGN_KEY_CHECKS = 1;
