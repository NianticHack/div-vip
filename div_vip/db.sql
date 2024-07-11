/*
 Navicat Premium Data Transfer

 Source Server         : alamakrp
 Source Server Type    : MySQL
 Source Server Version : 110402
 Source Host           : localhost:3306
 Source Schema         : qbcoreframework_6c5327

 Target Server Type    : MySQL
 Target Server Version : 110402
 File Encoding         : 65001

 Date: 06/07/2024 17:13:55
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for player_vip
-- ----------------------------
DROP TABLE IF EXISTS `player_vip`;
CREATE TABLE `player_vip`  (
  `citizenid` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `registered` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'not',
  `date_expiried` date NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
