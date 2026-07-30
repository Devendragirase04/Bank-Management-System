# =============================================================================
# Bank Management System - Configuration Module
# =============================================================================
# Author: Bank Management System Team
# Version: 1.0.0
# Description: Central configuration file for all application-wide constants,
#              UI theme tokens, colors, fonts, and settings.
# =============================================================================

import os
import logging
from pathlib import Path

# =============================================================================
# APPLICATION METADATA
# =============================================================================
APP_NAME = "Bank Management System"
APP_VERSION = "1.0.0"
APP_AUTHOR = "BMS Development Team"
APP_WEBSITE = "https://bms.example.com"
BANK_NAME = "Dev Bank"
BANK_TAGLINE = "Your Trusted Financial Partner Since 2026"
BANK_CODE = "DEVB"
BANK_SWIFT = "DEVBINBBXXX"
BANK_IFSC_PREFIX = "DEVB"

# =============================================================================
# PATHS
# =============================================================================
BASE_DIR = Path(__file__).parent.resolve()
ASSETS_DIR = BASE_DIR / "assets"
ICONS_DIR = ASSETS_DIR / "icons"
REPORTS_DIR = BASE_DIR / "reports"
STATEMENTS_DIR = BASE_DIR / "statements"
EXPORTS_DIR = BASE_DIR / "exports"
LOGS_DIR = BASE_DIR / "logs"
TESTS_DIR = BASE_DIR / "tests"
DATABASE_DIR = BASE_DIR / "database"

# Ensure required directories exist
for directory in [ASSETS_DIR, ICONS_DIR, REPORTS_DIR, STATEMENTS_DIR,
                  EXPORTS_DIR, LOGS_DIR, TESTS_DIR, DATABASE_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================
LOG_FILE = LOGS_DIR / "bank_system.log"
LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(module)s:%(lineno)d | %(message)s"
LOG_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
LOG_LEVEL = logging.DEBUG  # Change to INFO in production
LOG_MAX_BYTES = 10 * 1024 * 1024  # 10 MB
LOG_BACKUP_COUNT = 5

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================
MAX_LOGIN_ATTEMPTS = 3
LOCKOUT_DURATION_MINUTES = 30
SESSION_TIMEOUT_MINUTES = 30
PASSWORD_MIN_LENGTH = 8
PIN_LENGTH = 4
BCRYPT_ROUNDS = 12
REMEMBER_ME_DAYS = 30

# Password policy
PASSWORD_REQUIRES_UPPERCASE = True
PASSWORD_REQUIRES_LOWERCASE = True
PASSWORD_REQUIRES_DIGIT = True
PASSWORD_REQUIRES_SPECIAL = True
SPECIAL_CHARACTERS = "!@#$%^&*()_+-=[]{}|;:,.<>?"

# =============================================================================
# BANKING RULES
# =============================================================================
MIN_BALANCE_SAVINGS = 1000.00       # Minimum balance for savings account
MIN_BALANCE_CURRENT = 5000.00       # Minimum balance for current account
MAX_WITHDRAWAL_DAILY = 50000.00     # Daily withdrawal limit
MAX_TRANSFER_DAILY = 200000.00      # Daily transfer limit
MAX_DEPOSIT_CASH = 200000.00        # Max cash deposit per transaction
TRANSACTION_FEE = 0.00              # Base transaction fee
INTEREST_RATE_SAVINGS = 3.5         # Annual interest rate (%)
INTEREST_RATE_CURRENT = 0.0
INTEREST_RATE_FIXED_DEPOSIT_MIN = 5.5
INTEREST_RATE_FIXED_DEPOSIT_MAX = 7.5
LOAN_PROCESSING_FEE_PERCENT = 1.0   # Loan processing fee
LATE_PAYMENT_PENALTY = 2.0          # % per month

# Account types
ACCOUNT_TYPES = ["Savings", "Current", "Salary", "NRI", "Joint"]
LOAN_TYPES = ["Home Loan", "Car Loan", "Personal Loan", "Education Loan",
              "Business Loan", "Gold Loan", "Agricultural Loan"]
LOAN_STATUS = ["Pending", "Under Review", "Approved", "Rejected",
               "Disbursed", "Closed", "Defaulted"]
TRANSACTION_TYPES = ["Deposit", "Withdrawal", "Transfer", "UPI",
                     "EMI", "Interest", "Fee", "Reversal"]
CARD_TYPES = ["Debit", "Credit", "Prepaid"]
CARD_NETWORKS = ["Visa", "Mastercard", "RuPay"]
ACCOUNT_STATUS = ["Active", "Dormant", "Frozen", "Closed", "Suspended"]
LOAN_EMI_FREQUENCIES = ["Monthly", "Quarterly", "Half-Yearly", "Yearly"]
FD_TENURE_OPTIONS = [3, 6, 12, 18, 24, 36, 48, 60]  # Months

# =============================================================================
# UI THEME - DARK MODE BANKING THEME
# =============================================================================

# Primary Palette
COLOR_BG_PRIMARY = "#0f1117"         # Deep dark background
COLOR_BG_SECONDARY = "#1a1f2e"       # Card / panel background
COLOR_BG_TERTIARY = "#252b3b"        # Input / elevated background
COLOR_BG_HOVER = "#2d3448"           # Hover state

# Accent Colors
COLOR_ACCENT_PRIMARY = "#4f8ef7"     # Electric blue (primary CTA)
COLOR_ACCENT_SECONDARY = "#6c5ce7"   # Purple (secondary)
COLOR_ACCENT_SUCCESS = "#00d4aa"     # Teal green (success)
COLOR_ACCENT_WARNING = "#f5a623"     # Amber (warning)
COLOR_ACCENT_DANGER = "#e74c3c"      # Red (danger/error)
COLOR_ACCENT_INFO = "#17a2b8"        # Cyan (info)
COLOR_ACCENT_GOLD = "#ffd700"        # Gold (premium)

# Text Colors
COLOR_TEXT_PRIMARY = "#e8eaf0"       # Main text
COLOR_TEXT_SECONDARY = "#9ba3b5"     # Muted text
COLOR_TEXT_TERTIARY = "#636b7d"      # Placeholder text
COLOR_TEXT_INVERSE = "#0f1117"       # Text on light background
COLOR_TEXT_LINK = "#4f8ef7"          # Link text

# Border Colors
COLOR_BORDER = "#2d3448"             # Default border
COLOR_BORDER_FOCUS = "#4f8ef7"       # Focused input border
COLOR_BORDER_ERROR = "#e74c3c"       # Error border
COLOR_BORDER_SUCCESS = "#00d4aa"     # Success border

# Sidebar
COLOR_SIDEBAR_BG = "#111827"         # Sidebar background
COLOR_SIDEBAR_ACTIVE = "#1e3a5f"     # Active nav item
COLOR_SIDEBAR_HOVER = "#1a2942"      # Hover nav item
COLOR_SIDEBAR_TEXT = "#cbd5e1"       # Sidebar text
COLOR_SIDEBAR_ACTIVE_TEXT = "#4f8ef7"  # Active item text
COLOR_SIDEBAR_ICON = "#64748b"       # Icon color

# Status Colors
STATUS_COLORS = {
    "Active": "#00d4aa",
    "Dormant": "#f5a623",
    "Frozen": "#4f8ef7",
    "Closed": "#636b7d",
    "Suspended": "#e74c3c",
    "Pending": "#f5a623",
    "Approved": "#00d4aa",
    "Rejected": "#e74c3c",
    "Disbursed": "#4f8ef7",
}

# =============================================================================
# FONTS
# =============================================================================
FONT_FAMILY_PRIMARY = "Segoe UI"
FONT_FAMILY_MONO = "Consolas"
FONT_FAMILY_FALLBACK = "Helvetica"

FONT_SIZE_XS = 9
FONT_SIZE_SM = 10
FONT_SIZE_MD = 11
FONT_SIZE_LG = 13
FONT_SIZE_XL = 16
FONT_SIZE_2XL = 20
FONT_SIZE_3XL = 28
FONT_SIZE_4XL = 36

FONT_HEADING_1 = (FONT_FAMILY_PRIMARY, FONT_SIZE_4XL, "bold")
FONT_HEADING_2 = (FONT_FAMILY_PRIMARY, FONT_SIZE_3XL, "bold")
FONT_HEADING_3 = (FONT_FAMILY_PRIMARY, FONT_SIZE_2XL, "bold")
FONT_HEADING_4 = (FONT_FAMILY_PRIMARY, FONT_SIZE_XL, "bold")
FONT_BODY_LARGE = (FONT_FAMILY_PRIMARY, FONT_SIZE_LG)
FONT_BODY = (FONT_FAMILY_PRIMARY, FONT_SIZE_MD)
FONT_BODY_SMALL = (FONT_FAMILY_PRIMARY, FONT_SIZE_SM)
FONT_CAPTION = (FONT_FAMILY_PRIMARY, FONT_SIZE_XS)
FONT_MONO = (FONT_FAMILY_MONO, FONT_SIZE_MD)
FONT_LABEL = (FONT_FAMILY_PRIMARY, FONT_SIZE_SM, "bold")
FONT_BUTTON = (FONT_FAMILY_PRIMARY, FONT_SIZE_MD, "bold")
FONT_SIDEBAR = (FONT_FAMILY_PRIMARY, FONT_SIZE_MD)
FONT_SIDEBAR_ACTIVE = (FONT_FAMILY_PRIMARY, FONT_SIZE_MD, "bold")

# =============================================================================
# WINDOW DIMENSIONS
# =============================================================================
WINDOW_MIN_WIDTH = 1280
WINDOW_MIN_HEIGHT = 720
LOGIN_WINDOW_WIDTH = 900
LOGIN_WINDOW_HEIGHT = 580
SPLASH_DURATION_MS = 2500

# =============================================================================
# TABLE / TREEVIEW STYLING
# =============================================================================
TREE_ROW_HEIGHT = 32
TREE_HEADING_FONT = (FONT_FAMILY_PRIMARY, FONT_SIZE_SM, "bold")
TREE_ROW_FONT = (FONT_FAMILY_PRIMARY, FONT_SIZE_SM)
TREE_BG = COLOR_BG_TERTIARY
TREE_FG = COLOR_TEXT_PRIMARY
TREE_HEADING_BG = COLOR_BG_SECONDARY
TREE_HEADING_FG = COLOR_TEXT_SECONDARY
TREE_SELECT_BG = "#1e3a5f"
TREE_SELECT_FG = COLOR_TEXT_PRIMARY
TREE_ALT_ROW = "#1e2333"            # Alternating row color

# =============================================================================
# INPUT STYLING
# =============================================================================
ENTRY_HEIGHT = 36
ENTRY_PADDING = 10
ENTRY_RADIUS = 6
BUTTON_HEIGHT = 40
BUTTON_RADIUS = 6
CARD_RADIUS = 12
CARD_PADDING = 20

# =============================================================================
# PAGINATION
# =============================================================================
DEFAULT_PAGE_SIZE = 25
PAGE_SIZE_OPTIONS = [10, 25, 50, 100]

# =============================================================================
# DATE / TIME FORMATS
# =============================================================================
DATE_FORMAT = "%d/%m/%Y"
DATETIME_FORMAT = "%d/%m/%Y %H:%M:%S"
TIME_FORMAT = "%H:%M:%S"
DB_DATE_FORMAT = "%Y-%m-%d"
DB_DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"

# =============================================================================
# EXPORT SETTINGS
# =============================================================================
PDF_PAGE_SIZE = "A4"
PDF_FONT_NAME = "Helvetica"
PDF_MARGIN = 36  # points
EXCEL_SHEET_NAME = "Data"
CSV_DELIMITER = ","
CSV_ENCODING = "utf-8-sig"  # UTF-8 with BOM for Excel compatibility

# =============================================================================
# NOTIFICATIONS
# =============================================================================
NOTIF_TOAST_DURATION_MS = 3000      # Toast display duration
NOTIF_TYPES = ["Info", "Success", "Warning", "Error", "Transaction", "System"]

# =============================================================================
# REGEX PATTERNS (for validation)
# =============================================================================
REGEX_EMAIL = r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$'
REGEX_PHONE = r'^[6-9]\d{9}$'       # Indian mobile numbers
REGEX_PAN = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$'
REGEX_AADHAR = r'^\d{12}$'
REGEX_IFSC = r'^[A-Z]{4}0[A-Z0-9]{6}$'
REGEX_PINCODE = r'^\d{6}$'
REGEX_ACCOUNT_NUMBER = r'^\d{10,18}$'
REGEX_UPI_ID = r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$'
REGEX_CARD_NUMBER = r'^\d{16}$'
REGEX_CVV = r'^\d{3}$'

# =============================================================================
# STATES IN INDIA (for dropdowns)
# =============================================================================
INDIAN_STATES = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
    "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim",
    "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand",
    "West Bengal", "Delhi", "Jammu & Kashmir", "Ladakh", "Puducherry",
    "Chandigarh", "Andaman & Nicobar", "Dadra & Nagar Haveli",
    "Daman & Diu", "Lakshadweep"
]

# =============================================================================
# OCCUPATION TYPES
# =============================================================================
OCCUPATION_TYPES = [
    "Salaried - Private", "Salaried - Government", "Self-Employed",
    "Business Owner", "Freelancer", "Student", "Retired", "Homemaker",
    "Professional (Doctor/Lawyer/CA)", "Farmer", "Other"
]

# =============================================================================
# GENDER OPTIONS
# =============================================================================
GENDER_OPTIONS = ["Male", "Female", "Other", "Prefer not to say"]
