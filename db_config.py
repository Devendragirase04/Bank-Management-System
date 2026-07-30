# =============================================================================
# Bank Management System - Database Configuration
# =============================================================================
# Author: Bank Management System Team
# Version: 1.0.0
# Description: Database connection configuration and connection pool manager.
#              Reads from environment variables with secure fallback defaults.
# =============================================================================

import os
import logging
from typing import Optional
from dotenv import load_dotenv

# Load .env file if present
load_dotenv()

logger = logging.getLogger(__name__)

# =============================================================================
# DATABASE CONNECTION SETTINGS
# =============================================================================
# All sensitive values should be stored in a .env file, not hardcoded.

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),  # Set in .env
    "database": os.getenv("DB_NAME", "BankDB"),
    "charset": "utf8mb4",
    "collation": "utf8mb4_unicode_ci",
    "use_unicode": True,
    "autocommit": False,
    "connection_timeout": 30,
    "sql_mode": "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO",
    "time_zone": "+05:30",             # IST
    "raise_on_warnings": True,
}

# Connection pool settings
POOL_CONFIG = {
    "pool_name": "bms_pool",
    "pool_size": 10,
    "pool_reset_session": True,
}

# =============================================================================
# DATABASE CONSTANTS
# =============================================================================
DB_NAME = "BankDB"

# Tables
TABLE_BRANCHES = "branches"
TABLE_ROLES = "roles"
TABLE_ADMINS = "admins"
TABLE_EMPLOYEES = "employees"
TABLE_CUSTOMERS = "customers"
TABLE_ACCOUNTS = "accounts"
TABLE_TRANSACTIONS = "transactions"
TABLE_ATM_CARDS = "atm_cards"
TABLE_LOANS = "loans"
TABLE_LOAN_EMI = "loan_emi_schedule"
TABLE_BENEFICIARIES = "beneficiaries"
TABLE_FIXED_DEPOSITS = "fixed_deposits"
TABLE_UPI_ACCOUNTS = "upi_accounts"
TABLE_AUDIT_LOGS = "audit_logs"
TABLE_NOTIFICATIONS = "notifications"
TABLE_SESSIONS = "sessions"
TABLE_FAILED_LOGINS = "failed_logins"

# Views
VIEW_ACCOUNT_SUMMARY = "v_account_summary"
VIEW_TRANSACTION_DETAIL = "v_transaction_detail"
VIEW_CUSTOMER_PORTFOLIO = "v_customer_portfolio"
VIEW_LOAN_SUMMARY = "v_loan_summary"
VIEW_BRANCH_PERFORMANCE = "v_branch_performance"
VIEW_EMPLOYEE_DETAILS = "v_employee_details"
VIEW_ACTIVE_CARDS = "v_active_cards"
VIEW_FD_SUMMARY = "v_fd_summary"
VIEW_MONTHLY_REPORT = "v_monthly_report"

# Stored Procedures
PROC_TRANSFER_FUNDS = "sp_transfer_funds"
PROC_CALCULATE_INTEREST = "sp_calculate_interest"
PROC_APPROVE_LOAN = "sp_approve_loan"
PROC_CLOSE_ACCOUNT = "sp_close_account"
PROC_GENERATE_STATEMENT = "sp_generate_statement"
PROC_PROCESS_EMI = "sp_process_emi"
PROC_MATURE_FD = "sp_mature_fixed_deposit"

# Functions
FUNC_GENERATE_ACCOUNT_NO = "fn_generate_account_number"
FUNC_GENERATE_CARD_NO = "fn_generate_card_number"
FUNC_CALCULATE_LOAN_EMI = "fn_calculate_loan_emi"
FUNC_CALCULATE_FD_MATURITY = "fn_calculate_fd_maturity"
FUNC_GET_AGE = "fn_get_age"
FUNC_IS_ACCOUNT_ACTIVE = "fn_is_account_active"
