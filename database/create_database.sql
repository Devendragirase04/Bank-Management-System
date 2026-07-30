-- =============================================================================
-- Bank Management System - Database Creation
-- =============================================================================
-- Author  : Bank Management System Team
-- Version : 1.0.0
-- Database: MySQL 8.0+
-- =============================================================================

-- Drop and recreate database for clean setup
DROP DATABASE IF EXISTS BankDB;
CREATE DATABASE BankDB
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE BankDB;

-- =============================================================================
-- Set SQL mode for strict data integrity
-- =============================================================================
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO';
SET time_zone = '+05:30';

SELECT 'BankDB created successfully.' AS status;
