-- ==========================================================
-- DriveEase Database Schema (MySQL)
-- ==========================================================

-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS `driveease`
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE `driveease`;

-- 2. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` VARCHAR(50) NOT NULL, -- GUEST, CUSTOMER, EMPLOYEE, ADMIN
  `gender` VARCHAR(50) NULL,
  `two_factor_code` VARCHAR(50) NULL,
  `two_factor_expiry` DATETIME NULL,
  `reward_points` INT NOT NULL DEFAULT 0,
  `membership_level` VARCHAR(50) NOT NULL DEFAULT 'BRONZE',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Branches Table
CREATE TABLE IF NOT EXISTS `branches` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NULL,
  `city` VARCHAR(255) NULL,
  `location` VARCHAR(255) NULL
);

-- 4. Vehicles Table
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `branch_id` BIGINT NULL,
  `brand` VARCHAR(255) NOT NULL,
  `model` VARCHAR(255) NOT NULL,
  `model_year` INT NULL,
  `price_per_day` DOUBLE NOT NULL,
  `fuel_type` VARCHAR(100) NULL,
  `transmission` VARCHAR(100) NULL,
  `status` VARCHAR(50) NOT NULL, -- AVAILABLE, RESERVED, RENTED, MAINTENANCE, UNAVAILABLE
  `description` VARCHAR(1000) NULL,
  `images` TEXT NULL,
  `capacity` INT NULL,
  `mileage` INT NULL,
  `location` VARCHAR(255) NULL,
  `features` TEXT NULL,
  CONSTRAINT `fk_vehicles_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL
);

-- 5. Bookings Table
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `vehicle_id` BIGINT NOT NULL,
  `pickup_branch_id` BIGINT NULL,
  `return_branch_id` BIGINT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `total_price` DOUBLE NOT NULL,
  `status` VARCHAR(50) NOT NULL, -- PENDING, APPROVED, ACTIVE, COMPLETED, CANCELLED
  CONSTRAINT `fk_bookings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bookings_pickup_branch` FOREIGN KEY (`pickup_branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_bookings_return_branch` FOREIGN KEY (`return_branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL
);

-- 6. Payments Table
CREATE TABLE IF NOT EXISTS `payments` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` BIGINT NOT NULL UNIQUE,
  `user_id` BIGINT NOT NULL,
  `amount` DOUBLE NOT NULL,
  `method` VARCHAR(50) NOT NULL, -- CREDIT_CARD, CASH, WALLET
  `status` VARCHAR(50) NOT NULL, -- PENDING, SUCCESS, FAILED
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_payments_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 7. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `message` VARCHAR(1000) NOT NULL,
  `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 8. Extension Requests Table
CREATE TABLE IF NOT EXISTS `extension_requests` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` BIGINT NOT NULL,
  `new_end_date` DATE NOT NULL,
  `status` VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_extension_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
);

-- 9. Damage Reports Table
CREATE TABLE IF NOT EXISTS `damage_reports` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `vehicle_id` BIGINT NOT NULL,
  `booking_id` BIGINT NULL,
  `reporter_username` VARCHAR(255) NULL,
  `description` TEXT NULL,
  `severity` VARCHAR(50) NULL,
  `report_date` DATETIME NULL,
  `is_resolved` BOOLEAN DEFAULT FALSE,
  CONSTRAINT `fk_damage_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_damage_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL
);

-- 10. Maintenance Records Table
CREATE TABLE IF NOT EXISTS `maintenance_records` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `vehicle_id` BIGINT NOT NULL,
  `maintenance_date` DATE NOT NULL,
  `description` VARCHAR(1000) NULL,
  `cost` DOUBLE NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_maintenance_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
);

-- 11. Pricing Rules Table
CREATE TABLE IF NOT EXISTS `pricing_rules` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `multiplier` DOUBLE NOT NULL
);

-- 12. Coupons Table
CREATE TABLE IF NOT EXISTS `coupons` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(255) NOT NULL UNIQUE,
  `discount_percentage` DOUBLE NOT NULL,
  `expiry_date` DATE NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE
);

-- 13. Loyalty Accounts Table
CREATE TABLE IF NOT EXISTS `loyalty_accounts` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL UNIQUE,
  `points` INT NOT NULL DEFAULT 0,
  `membership_level` VARCHAR(50) NOT NULL DEFAULT 'BRONZE',
  CONSTRAINT `fk_loyalty_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 14. Reviews Table
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `vehicle_id` BIGINT NOT NULL,
  `rating` INT NOT NULL,
  `comment` VARCHAR(1000) NULL,
  `is_hidden` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE
);

-- 15. Tickets Table
CREATE TABLE IF NOT EXISTS `tickets` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `message` VARCHAR(2000) NOT NULL,
  `status` VARCHAR(50) NOT NULL DEFAULT 'OPEN',
  `priority` VARCHAR(50) NOT NULL DEFAULT 'MEDIUM',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` DATETIME NULL,
  CONSTRAINT `fk_tickets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 16. Ticket Replies Table
CREATE TABLE IF NOT EXISTS `ticket_replies` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `ticket_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `message` VARCHAR(2000) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_replies_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 17. Waitlist Entries Table
CREATE TABLE IF NOT EXISTS `waitlist_entries` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `vehicle_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `notified` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_waitlist_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_waitlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 18. SMS Logs Table
CREATE TABLE IF NOT EXISTS `sms_logs` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `phone_number` VARCHAR(255) NOT NULL,
  `message` VARCHAR(1000) NOT NULL,
  `type` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_sms_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- 19. Audit Logs Table
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `username` VARCHAR(255) NULL,
  `action` VARCHAR(255) NULL,
  `entity_name` VARCHAR(255) NULL,
  `entity_id` VARCHAR(255) NULL
);
