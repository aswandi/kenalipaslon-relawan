-- Adminer 5.3.0 MySQL 8.4.3 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

DROP TABLE IF EXISTS `administrative_areas`;
CREATE TABLE `administrative_areas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('district','village','rw','rt','tps') COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_id` bigint unsigned DEFAULT NULL,
  `postal_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `administrative_areas_name_parent_id_type_unique` (`name`,`parent_id`,`type`),
  KEY `administrative_areas_type_index` (`type`),
  KEY `administrative_areas_parent_id_index` (`parent_id`),
  KEY `administrative_areas_name_index` (`name`),
  KEY `administrative_areas_code_index` (`code`),
  CONSTRAINT `administrative_areas_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `administrative_areas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `answer_options`;
CREATE TABLE `answer_options` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `question_id` bigint unsigned NOT NULL,
  `option_text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_value` int NOT NULL,
  `order_number` int NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `answer_options_question_id_order_number_index` (`question_id`,`order_number`),
  CONSTRAINT `answer_options_question_id_foreign` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `field_records`;
CREATE TABLE `field_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `volunteer_id` bigint unsigned NOT NULL,
  `voter_id` bigint unsigned NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `responded_at` timestamp NOT NULL,
  `completion_status` enum('complete','partial','incomplete') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'incomplete',
  `total_questions` int NOT NULL DEFAULT '0',
  `answered_questions` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `photo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `sync_status` enum('pending','synced') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'synced',
  PRIMARY KEY (`id`),
  KEY `idx_survey_responses_voter` (`voter_id`),
  KEY `idx_field_records_voter` (`voter_id`),
  KEY `idx_volunteer_date` (`volunteer_id`,`responded_at`),
  CONSTRAINT `fk_field_records_volunteer` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_field_records_voter` FOREIGN KEY (`voter_id`) REFERENCES `voters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `question_text` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_type` enum('multiple_choice','text','boolean') COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_number` int NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `questions_order_number_is_active_index` (`order_number`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `rt`;
CREATE TABLE `rt` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `administrative_area_id` bigint unsigned NOT NULL,
  `rw` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rt` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `population_count` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rt_administrative_area_id_foreign` (`administrative_area_id`),
  CONSTRAINT `rt_administrative_area_id_foreign` FOREIGN KEY (`administrative_area_id`) REFERENCES `administrative_areas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `survey_aggregates`;
CREATE TABLE `survey_aggregates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `question_id` bigint unsigned NOT NULL,
  `answer_option_id` bigint unsigned DEFAULT NULL,
  `aggregate_level` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `area_id` bigint unsigned NOT NULL,
  `response_count` int DEFAULT '0',
  `percentage` decimal(5,2) DEFAULT '0.00',
  `total_responses` int DEFAULT '0',
  `calculation_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_survey_agg_unique` (`question_id`,`answer_option_id`,`aggregate_level`,`area_id`,`calculation_date`),
  KEY `idx_survey_agg_question_level_area` (`question_id`,`aggregate_level`,`area_id`),
  KEY `idx_survey_agg_answer_level` (`answer_option_id`,`aggregate_level`),
  KEY `idx_survey_agg_calculation_date` (`calculation_date`),
  CONSTRAINT `fk_survey_aggregates_answer_option` FOREIGN KEY (`answer_option_id`) REFERENCES `answer_options` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_survey_aggregates_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `survey_calculation_logs`;
CREATE TABLE `survey_calculation_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `calculation_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `area_id` bigint unsigned DEFAULT NULL,
  `calculation_started_at` timestamp NOT NULL,
  `calculation_completed_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','processing','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `processed_records` int DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_calc_logs_type_level` (`calculation_type`,`level`),
  KEY `idx_calc_logs_status_started` (`status`,`calculation_started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `survey_response_details`;
CREATE TABLE `survey_response_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `field_record_id` bigint unsigned NOT NULL,
  `question_id` bigint unsigned NOT NULL,
  `answer_option_id` bigint unsigned DEFAULT NULL,
  `text_answer` text COLLATE utf8mb4_unicode_ci,
  `numeric_value` int DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT '1.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_srd_unique_response_question` (`field_record_id`,`question_id`),
  KEY `idx_srd_survey_question` (`field_record_id`,`question_id`),
  KEY `idx_srd_question_answer` (`question_id`,`answer_option_id`),
  KEY `idx_srd_answer_option` (`answer_option_id`),
  KEY `idx_srd_numeric_value` (`numeric_value`),
  CONSTRAINT `fk_survey_response_details_answer_option` FOREIGN KEY (`answer_option_id`) REFERENCES `answer_options` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_survey_response_details_field_record` FOREIGN KEY (`field_record_id`) REFERENCES `field_records` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_survey_response_details_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `tps`;
CREATE TABLE `tps` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `administrative_area_id` bigint unsigned NOT NULL,
  `number` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `dpt` int NOT NULL DEFAULT '0' COMMENT 'Daftar Pemilih Tetap - jumlah pemilih di TPS ini',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tps_administrative_area_id_number_unique` (`administrative_area_id`,`number`),
  KEY `tps_administrative_area_id_number_index` (`administrative_area_id`,`number`),
  KEY `tps_is_active_index` (`is_active`),
  CONSTRAINT `tps_ibfk_1` FOREIGN KEY (`administrative_area_id`) REFERENCES `administrative_areas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `volunteer_assignments`;
CREATE TABLE `volunteer_assignments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `volunteer_id` bigint unsigned NOT NULL,
  `administrative_area_id` bigint unsigned NOT NULL,
  `district` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `village` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rw` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rt` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `volunteer_assignments_volunteer_id_district_village_rt_unique` (`volunteer_id`,`district`,`village`,`rt`),
  KEY `volunteer_assignments_district_village_rt_index` (`district`,`village`,`rt`),
  KEY `volunteer_assignments_administrative_area_id_foreign` (`administrative_area_id`),
  CONSTRAINT `volunteer_assignments_administrative_area_id_foreign` FOREIGN KEY (`administrative_area_id`) REFERENCES `administrative_areas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `volunteer_assignments_volunteer_id_foreign` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `volunteers`;
CREATE TABLE `volunteers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ktp_number` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('volunteer','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'volunteer',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `volunteers_ktp_number_unique` (`ktp_number`),
  UNIQUE KEY `volunteers_phone_number_unique` (`phone_number`),
  KEY `volunteers_phone_number_index` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


DROP TABLE IF EXISTS `voters`;
CREATE TABLE `voters` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `district_id` bigint unsigned DEFAULT NULL,
  `village_id` bigint unsigned DEFAULT NULL,
  `district` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `village` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nkk` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nik` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `place_of_birth` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `marital_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` enum('L','P') COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `rt` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rw` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `disability` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ektp_status` enum('sudah','belum') COLLATE utf8mb4_unicode_ci NOT NULL,
  `tps` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `voters_nik_unique` (`nik`),
  KEY `voters_name_index` (`name`),
  KEY `voters_nik_index` (`nik`),
  KEY `voters_tps_index` (`tps`),
  KEY `voters_village_tps_index` (`village_id`,`tps`),
  KEY `voters_village_rt_rw_index` (`village_id`,`rt`,`rw`),
  KEY `idx_voters_location` (`district_id`,`village_id`,`rt`,`rw`),
  KEY `idx_voters_tps_area` (`village_id`,`tps`),
  KEY `idx_voters_demographics` (`gender`,`date_of_birth`),
  CONSTRAINT `voters_district_id_foreign` FOREIGN KEY (`district_id`) REFERENCES `administrative_areas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `voters_village_id_foreign` FOREIGN KEY (`village_id`) REFERENCES `administrative_areas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 2025-08-12 14:36:59 UTC
