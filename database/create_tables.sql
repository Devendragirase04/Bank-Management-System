-- =============================================================================
-- Bank Management System - Complete Table Definitions
-- =============================================================================
-- Follows 3NF normalization, with all constraints, FK relationships, and
-- audit-ready columns on every table.
-- =============================================================================

USE BankDB;

-- =============================================================================
-- 1. ROLES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS roles (
    role_id         TINYINT UNSIGNED    NOT NULL AUTO_INCREMENT,
    role_name       VARCHAR(50)         NOT NULL,
    description     VARCHAR(255)        DEFAULT NULL,
    permissions     JSON                DEFAULT NULL COMMENT 'JSON array of permission strings',
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id),
    UNIQUE KEY uq_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='User roles and permission sets';

-- =============================================================================
-- 2. BRANCHES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS branches (
    branch_id       INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    branch_name     VARCHAR(100)        NOT NULL,
    branch_code     VARCHAR(10)         NOT NULL COMMENT 'Short unique branch code',
    ifsc_code       VARCHAR(11)         NOT NULL,
    address_line1   VARCHAR(150)        NOT NULL,
    address_line2   VARCHAR(150)        DEFAULT NULL,
    city            VARCHAR(60)         NOT NULL,
    state           VARCHAR(60)         NOT NULL,
    pincode         CHAR(6)             NOT NULL,
    phone           VARCHAR(15)         DEFAULT NULL,
    email           VARCHAR(120)        DEFAULT NULL,
    manager_name    VARCHAR(100)        DEFAULT NULL,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    established_date DATE               DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (branch_id),
    UNIQUE KEY uq_branch_code  (branch_code),
    UNIQUE KEY uq_ifsc_code    (ifsc_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bank branch locations and contact information';

-- =============================================================================
-- 3. ADMINS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS admins (
    admin_id        INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    username        VARCHAR(50)         NOT NULL,
    password_hash   VARCHAR(255)        NOT NULL,
    full_name       VARCHAR(100)        NOT NULL,
    email           VARCHAR(120)        NOT NULL,
    phone           VARCHAR(15)         DEFAULT NULL,
    role_id         TINYINT UNSIGNED    NOT NULL DEFAULT 1,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    is_locked       TINYINT(1)          NOT NULL DEFAULT 0,
    failed_attempts TINYINT UNSIGNED    NOT NULL DEFAULT 0,
    last_login      DATETIME            DEFAULT NULL,
    locked_until    DATETIME            DEFAULT NULL,
    profile_photo   VARCHAR(255)        DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (admin_id),
    UNIQUE KEY uq_admin_username (username),
    UNIQUE KEY uq_admin_email    (email),
    CONSTRAINT fk_admin_role FOREIGN KEY (role_id) REFERENCES roles (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='System administrator accounts';

-- =============================================================================
-- 4. EMPLOYEES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS employees (
    employee_id     INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    employee_code   VARCHAR(20)         NOT NULL COMMENT 'Unique staff ID',
    branch_id       INT UNSIGNED        NOT NULL,
    role_id         TINYINT UNSIGNED    NOT NULL,
    full_name       VARCHAR(100)        NOT NULL,
    father_name     VARCHAR(100)        DEFAULT NULL,
    date_of_birth   DATE                NOT NULL,
    gender          ENUM('Male','Female','Other')  NOT NULL,
    email           VARCHAR(120)        NOT NULL,
    phone           VARCHAR(15)         NOT NULL,
    alt_phone       VARCHAR(15)         DEFAULT NULL,
    pan_number      VARCHAR(10)         NOT NULL,
    aadhar_number   VARCHAR(12)         NOT NULL,
    address_line1   VARCHAR(150)        NOT NULL,
    address_line2   VARCHAR(150)        DEFAULT NULL,
    city            VARCHAR(60)         NOT NULL,
    state           VARCHAR(60)         NOT NULL,
    pincode         CHAR(6)             NOT NULL,
    designation     VARCHAR(100)        DEFAULT NULL,
    department      VARCHAR(100)        DEFAULT NULL,
    joining_date    DATE                NOT NULL,
    salary          DECIMAL(12,2)       NOT NULL DEFAULT 0.00,
    username        VARCHAR(50)         NOT NULL,
    password_hash   VARCHAR(255)        NOT NULL,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    is_locked       TINYINT(1)          NOT NULL DEFAULT 0,
    failed_attempts TINYINT UNSIGNED    NOT NULL DEFAULT 0,
    locked_until    DATETIME            DEFAULT NULL,
    last_login      DATETIME            DEFAULT NULL,
    profile_photo   VARCHAR(255)        DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id),
    UNIQUE KEY uq_employee_code (employee_code),
    UNIQUE KEY uq_employee_email (email),
    UNIQUE KEY uq_employee_pan (pan_number),
    UNIQUE KEY uq_employee_aadhar (aadhar_number),
    UNIQUE KEY uq_employee_username (username),
    CONSTRAINT fk_employee_branch FOREIGN KEY (branch_id) REFERENCES branches (branch_id),
    CONSTRAINT fk_employee_role   FOREIGN KEY (role_id)   REFERENCES roles   (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bank employee records and credentials';

-- =============================================================================
-- 5. CUSTOMERS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id     INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    customer_code   VARCHAR(20)         NOT NULL COMMENT 'Unique customer ID (CIF)',
    full_name       VARCHAR(100)        NOT NULL,
    father_name     VARCHAR(100)        DEFAULT NULL,
    mother_name     VARCHAR(100)        DEFAULT NULL,
    date_of_birth   DATE                NOT NULL,
    gender          ENUM('Male','Female','Other','Prefer not to say')  NOT NULL,
    marital_status  ENUM('Single','Married','Divorced','Widowed')      DEFAULT 'Single',
    nationality     VARCHAR(50)         NOT NULL DEFAULT 'Indian',
    email           VARCHAR(120)        NOT NULL,
    phone           VARCHAR(15)         NOT NULL,
    alt_phone       VARCHAR(15)         DEFAULT NULL,
    pan_number      VARCHAR(10)         NOT NULL,
    aadhar_number   VARCHAR(12)         NOT NULL,
    address_line1   VARCHAR(150)        NOT NULL,
    address_line2   VARCHAR(150)        DEFAULT NULL,
    city            VARCHAR(60)         NOT NULL,
    state           VARCHAR(60)         NOT NULL,
    pincode         CHAR(6)             NOT NULL,
    occupation      VARCHAR(100)        DEFAULT NULL,
    annual_income   DECIMAL(14,2)       DEFAULT NULL,
    credit_score    SMALLINT UNSIGNED   DEFAULT 700 COMMENT 'CIBIL/Equifax score',
    kyc_status      ENUM('Pending','Verified','Rejected')  NOT NULL DEFAULT 'Pending',
    kyc_date        DATE                DEFAULT NULL,
    username        VARCHAR(50)         NOT NULL,
    password_hash   VARCHAR(255)        NOT NULL,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    is_locked       TINYINT(1)          NOT NULL DEFAULT 0,
    failed_attempts TINYINT UNSIGNED    NOT NULL DEFAULT 0,
    locked_until    DATETIME            DEFAULT NULL,
    last_login      DATETIME            DEFAULT NULL,
    profile_photo   VARCHAR(255)        DEFAULT NULL,
    branch_id       INT UNSIGNED        NOT NULL COMMENT 'Home branch',
    referred_by     INT UNSIGNED        DEFAULT NULL COMMENT 'Self-referential referral',
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customer_code   (customer_code),
    UNIQUE KEY uq_customer_email  (email),
    UNIQUE KEY uq_customer_pan    (pan_number),
    UNIQUE KEY uq_customer_aadhar (aadhar_number),
    UNIQUE KEY uq_customer_username (username),
    CONSTRAINT fk_customer_branch  FOREIGN KEY (branch_id)   REFERENCES branches   (branch_id),
    CONSTRAINT fk_customer_referred FOREIGN KEY (referred_by) REFERENCES customers (customer_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Customer master record (CIF)';

-- =============================================================================
-- 6. ACCOUNTS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS accounts (
    account_id      INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    account_number  VARCHAR(20)         NOT NULL,
    customer_id     INT UNSIGNED        NOT NULL,
    branch_id       INT UNSIGNED        NOT NULL,
    account_type    ENUM('Savings','Current','Salary','NRI','Joint')  NOT NULL DEFAULT 'Savings',
    balance         DECIMAL(15,2)       NOT NULL DEFAULT 0.00,
    min_balance     DECIMAL(10,2)       NOT NULL DEFAULT 1000.00,
    interest_rate   DECIMAL(5,2)        NOT NULL DEFAULT 3.50,
    currency        CHAR(3)             NOT NULL DEFAULT 'INR',
    status          ENUM('Active','Dormant','Frozen','Closed','Suspended') NOT NULL DEFAULT 'Active',
    opened_date     DATE                NOT NULL,
    closed_date     DATE                DEFAULT NULL,
    last_txn_date   DATE                DEFAULT NULL,
    nominee_name    VARCHAR(100)        DEFAULT NULL,
    nominee_relation VARCHAR(50)        DEFAULT NULL,
    joint_holder_id INT UNSIGNED        DEFAULT NULL,
    created_by      INT UNSIGNED        DEFAULT NULL COMMENT 'Employee who opened account',
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id),
    UNIQUE KEY uq_account_number (account_number),
    CONSTRAINT fk_account_customer     FOREIGN KEY (customer_id)    REFERENCES customers  (customer_id),
    CONSTRAINT fk_account_branch       FOREIGN KEY (branch_id)      REFERENCES branches   (branch_id),
    CONSTRAINT fk_account_joint_holder FOREIGN KEY (joint_holder_id) REFERENCES customers (customer_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_account_created_by   FOREIGN KEY (created_by)     REFERENCES employees  (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_account_balance     CHECK (balance >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bank accounts linked to customers';

-- =============================================================================
-- 7. TRANSACTIONS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id      BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    reference_number    VARCHAR(30)         NOT NULL COMMENT 'Unique TXN reference',
    account_id          INT UNSIGNED        NOT NULL,
    transaction_type    ENUM('Deposit','Withdrawal','Transfer In','Transfer Out',
                             'UPI Credit','UPI Debit','EMI Debit','Interest Credit',
                             'Fee Debit','Reversal','FD Maturity','Loan Disbursement')
                                            NOT NULL,
    amount              DECIMAL(15,2)       NOT NULL,
    balance_before      DECIMAL(15,2)       NOT NULL,
    balance_after       DECIMAL(15,2)       NOT NULL,
    description         VARCHAR(255)        DEFAULT NULL,
    counterpart_account VARCHAR(20)         DEFAULT NULL COMMENT 'Other account in transfer',
    counterpart_bank    VARCHAR(100)        DEFAULT 'Apex National Bank',
    channel             ENUM('Branch','ATM','Net Banking','Mobile','UPI','NEFT','RTGS','IMPS','Internal')
                                            NOT NULL DEFAULT 'Branch',
    status              ENUM('Pending','Success','Failed','Reversed')  NOT NULL DEFAULT 'Success',
    processed_by        INT UNSIGNED        DEFAULT NULL COMMENT 'Employee ID for branch txn',
    ip_address          VARCHAR(45)         DEFAULT NULL,
    device_info         VARCHAR(255)        DEFAULT NULL,
    remarks             VARCHAR(500)        DEFAULT NULL,
    created_at          DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_id),
    UNIQUE KEY uq_reference_number (reference_number),
    CONSTRAINT fk_txn_account       FOREIGN KEY (account_id)    REFERENCES accounts   (account_id),
    CONSTRAINT fk_txn_processed_by  FOREIGN KEY (processed_by)  REFERENCES employees  (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_txn_amount       CHECK (amount > 0),
    CONSTRAINT chk_txn_balance_after CHECK (balance_after >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='All financial transactions';

-- =============================================================================
-- 8. ATM CARDS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS atm_cards (
    card_id         INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    account_id      INT UNSIGNED        NOT NULL,
    card_number     VARCHAR(16)         NOT NULL,
    card_type       ENUM('Debit','Credit','Prepaid')  NOT NULL DEFAULT 'Debit',
    card_network    ENUM('Visa','Mastercard','RuPay')  NOT NULL DEFAULT 'RuPay',
    cardholder_name VARCHAR(100)        NOT NULL,
    expiry_month    TINYINT UNSIGNED    NOT NULL,
    expiry_year     SMALLINT UNSIGNED   NOT NULL,
    cvv_hash        VARCHAR(255)        NOT NULL,
    pin_hash        VARCHAR(255)        NOT NULL,
    credit_limit    DECIMAL(12,2)       DEFAULT NULL,
    daily_limit     DECIMAL(10,2)       NOT NULL DEFAULT 50000.00,
    status          ENUM('Active','Blocked','Expired','Hot-listed','Inactive')
                                        NOT NULL DEFAULT 'Active',
    is_contactless  TINYINT(1)          NOT NULL DEFAULT 1,
    is_international TINYINT(1)         NOT NULL DEFAULT 0,
    is_online_txn_enabled TINYINT(1)    NOT NULL DEFAULT 1,
    issued_date     DATE                NOT NULL,
    last_used_date  DATETIME            DEFAULT NULL,
    blocked_reason  VARCHAR(255)        DEFAULT NULL,
    issued_by       INT UNSIGNED        DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (card_id),
    UNIQUE KEY uq_card_number (card_number),
    CONSTRAINT fk_card_account   FOREIGN KEY (account_id) REFERENCES accounts  (account_id),
    CONSTRAINT fk_card_issued_by FOREIGN KEY (issued_by)  REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_card_expiry_month CHECK (expiry_month BETWEEN 1 AND 12),
    CONSTRAINT chk_card_daily_limit  CHECK (daily_limit > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Debit/Credit/Prepaid cards linked to accounts';

-- =============================================================================
-- 9. LOANS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS loans (
    loan_id         INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    loan_account_no VARCHAR(20)         NOT NULL,
    customer_id     INT UNSIGNED        NOT NULL,
    account_id      INT UNSIGNED        NOT NULL COMMENT 'Disbursement account',
    branch_id       INT UNSIGNED        NOT NULL,
    loan_type       ENUM('Home Loan','Car Loan','Personal Loan','Education Loan',
                         'Business Loan','Gold Loan','Agricultural Loan')  NOT NULL,
    principal_amount DECIMAL(15,2)      NOT NULL,
    interest_rate   DECIMAL(5,2)        NOT NULL COMMENT 'Annual %',
    tenure_months   SMALLINT UNSIGNED   NOT NULL,
    emi_amount      DECIMAL(12,2)       NOT NULL,
    emi_frequency   ENUM('Monthly','Quarterly','Half-Yearly','Yearly')  NOT NULL DEFAULT 'Monthly',
    total_payable   DECIMAL(15,2)       NOT NULL,
    outstanding_amount DECIMAL(15,2)   NOT NULL,
    emis_paid       SMALLINT UNSIGNED   NOT NULL DEFAULT 0,
    disbursement_date DATE              DEFAULT NULL,
    first_emi_date  DATE                DEFAULT NULL,
    last_emi_date   DATE                DEFAULT NULL,
    next_emi_date   DATE                DEFAULT NULL,
    status          ENUM('Pending','Under Review','Approved','Rejected',
                         'Disbursed','Closed','Defaulted')  NOT NULL DEFAULT 'Pending',
    purpose         VARCHAR(500)        DEFAULT NULL,
    collateral      VARCHAR(255)        DEFAULT NULL,
    processing_fee  DECIMAL(10,2)       DEFAULT NULL,
    guarantor_name  VARCHAR(100)        DEFAULT NULL,
    guarantor_phone VARCHAR(15)         DEFAULT NULL,
    approved_by     INT UNSIGNED        DEFAULT NULL,
    processed_by    INT UNSIGNED        DEFAULT NULL,
    rejection_reason VARCHAR(500)       DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (loan_id),
    UNIQUE KEY uq_loan_account_no (loan_account_no),
    CONSTRAINT fk_loan_customer    FOREIGN KEY (customer_id)  REFERENCES customers  (customer_id),
    CONSTRAINT fk_loan_account     FOREIGN KEY (account_id)   REFERENCES accounts   (account_id),
    CONSTRAINT fk_loan_branch      FOREIGN KEY (branch_id)    REFERENCES branches   (branch_id),
    CONSTRAINT fk_loan_approved_by FOREIGN KEY (approved_by)  REFERENCES employees  (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_loan_processed_by FOREIGN KEY (processed_by) REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_loan_principal   CHECK (principal_amount > 0),
    CONSTRAINT chk_loan_rate        CHECK (interest_rate >= 0),
    CONSTRAINT chk_loan_tenure      CHECK (tenure_months > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Loan applications and active loan records';

-- =============================================================================
-- 10. LOAN EMI SCHEDULE TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS loan_emi_schedule (
    schedule_id     INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    loan_id         INT UNSIGNED        NOT NULL,
    emi_number      SMALLINT UNSIGNED   NOT NULL,
    due_date        DATE                NOT NULL,
    emi_amount      DECIMAL(12,2)       NOT NULL,
    principal_component DECIMAL(12,2)   NOT NULL,
    interest_component  DECIMAL(12,2)   NOT NULL,
    outstanding_after   DECIMAL(15,2)   NOT NULL,
    paid_date       DATE                DEFAULT NULL,
    paid_amount     DECIMAL(12,2)       DEFAULT NULL,
    penalty         DECIMAL(10,2)       DEFAULT 0.00,
    status          ENUM('Pending','Paid','Overdue','Partially Paid','Waived')
                                        NOT NULL DEFAULT 'Pending',
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (schedule_id),
    UNIQUE KEY uq_loan_emi (loan_id, emi_number),
    CONSTRAINT fk_emi_loan FOREIGN KEY (loan_id) REFERENCES loans (loan_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Amortization schedule for each loan';

-- =============================================================================
-- 11. BENEFICIARIES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS beneficiaries (
    beneficiary_id  INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    customer_id     INT UNSIGNED        NOT NULL,
    nickname        VARCHAR(50)         DEFAULT NULL,
    beneficiary_name VARCHAR(100)       NOT NULL,
    account_number  VARCHAR(20)         NOT NULL,
    bank_name       VARCHAR(100)        NOT NULL DEFAULT 'Apex National Bank',
    ifsc_code       VARCHAR(11)         DEFAULT NULL,
    branch_name     VARCHAR(100)        DEFAULT NULL,
    relation        VARCHAR(50)         DEFAULT NULL,
    is_verified     TINYINT(1)          NOT NULL DEFAULT 0,
    transfer_limit  DECIMAL(12,2)       DEFAULT NULL,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    added_at        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (beneficiary_id),
    UNIQUE KEY uq_beneficiary (customer_id, account_number),
    CONSTRAINT fk_beneficiary_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Saved beneficiaries for fund transfers';

-- =============================================================================
-- 12. FIXED DEPOSITS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS fixed_deposits (
    fd_id           INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    fd_number       VARCHAR(20)         NOT NULL,
    customer_id     INT UNSIGNED        NOT NULL,
    account_id      INT UNSIGNED        NOT NULL COMMENT 'Source/linked account',
    branch_id       INT UNSIGNED        NOT NULL,
    principal       DECIMAL(15,2)       NOT NULL,
    interest_rate   DECIMAL(5,2)        NOT NULL,
    tenure_months   SMALLINT UNSIGNED   NOT NULL,
    compounding     ENUM('Monthly','Quarterly','Half-Yearly','Yearly')
                                        NOT NULL DEFAULT 'Quarterly',
    maturity_amount DECIMAL(15,2)       NOT NULL,
    interest_earned DECIMAL(12,2)       NOT NULL,
    start_date      DATE                NOT NULL,
    maturity_date   DATE                NOT NULL,
    status          ENUM('Active','Matured','Closed','Prematurely Closed','Renewed')
                                        NOT NULL DEFAULT 'Active',
    auto_renew      TINYINT(1)          NOT NULL DEFAULT 0,
    payout_account  INT UNSIGNED        DEFAULT NULL COMMENT 'Interest payout account',
    premature_penalty DECIMAL(5,2)      NOT NULL DEFAULT 1.00 COMMENT '% penalty',
    closed_date     DATE                DEFAULT NULL,
    created_by      INT UNSIGNED        DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (fd_id),
    UNIQUE KEY uq_fd_number (fd_number),
    CONSTRAINT fk_fd_customer  FOREIGN KEY (customer_id)  REFERENCES customers (customer_id),
    CONSTRAINT fk_fd_account   FOREIGN KEY (account_id)   REFERENCES accounts  (account_id),
    CONSTRAINT fk_fd_branch    FOREIGN KEY (branch_id)    REFERENCES branches  (branch_id),
    CONSTRAINT fk_fd_payout    FOREIGN KEY (payout_account) REFERENCES accounts (account_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_fd_created_by FOREIGN KEY (created_by)  REFERENCES employees (employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_fd_principal CHECK (principal > 0),
    CONSTRAINT chk_fd_tenure    CHECK (tenure_months > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Fixed deposit accounts';

-- =============================================================================
-- 13. UPI ACCOUNTS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS upi_accounts (
    upi_id          INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    upi_address     VARCHAR(100)        NOT NULL COMMENT 'e.g. john123@apxb',
    customer_id     INT UNSIGNED        NOT NULL,
    account_id      INT UNSIGNED        NOT NULL,
    upi_pin_hash    VARCHAR(255)        NOT NULL,
    daily_limit     DECIMAL(10,2)       NOT NULL DEFAULT 100000.00,
    monthly_limit   DECIMAL(12,2)       NOT NULL DEFAULT 1000000.00,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    is_blocked      TINYINT(1)          NOT NULL DEFAULT 0,
    failed_attempts TINYINT UNSIGNED    NOT NULL DEFAULT 0,
    last_used       DATETIME            DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (upi_id),
    UNIQUE KEY uq_upi_address (upi_address),
    CONSTRAINT fk_upi_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT fk_upi_account  FOREIGN KEY (account_id)  REFERENCES accounts  (account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='UPI virtual payment addresses';

-- =============================================================================
-- 14. AUDIT LOGS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id          BIGINT UNSIGNED     NOT NULL AUTO_INCREMENT,
    user_id         INT UNSIGNED        NOT NULL,
    user_type       ENUM('Admin','Employee','Customer','System')  NOT NULL,
    action          VARCHAR(100)        NOT NULL COMMENT 'Short action code',
    details         TEXT                DEFAULT NULL,
    ip_address      VARCHAR(45)         DEFAULT NULL,
    user_agent      VARCHAR(500)        DEFAULT NULL,
    status          ENUM('Success','Failed','Warning')  NOT NULL DEFAULT 'Success',
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    INDEX idx_audit_user    (user_id, user_type),
    INDEX idx_audit_action  (action),
    INDEX idx_audit_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Complete audit trail for all user actions';

-- =============================================================================
-- 15. NOTIFICATIONS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS notifications (
    notif_id        INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    customer_id     INT UNSIGNED        NOT NULL,
    title           VARCHAR(100)        NOT NULL,
    message         TEXT                NOT NULL,
    notif_type      ENUM('Info','Success','Warning','Error','Transaction','System','Promotional')
                                        NOT NULL DEFAULT 'Info',
    is_read         TINYINT(1)          NOT NULL DEFAULT 0,
    related_txn_id  BIGINT UNSIGNED     DEFAULT NULL,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at         DATETIME            DEFAULT NULL,
    PRIMARY KEY (notif_id),
    CONSTRAINT fk_notif_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_notif_txn      FOREIGN KEY (related_txn_id) REFERENCES transactions (transaction_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Customer notification inbox';

-- =============================================================================
-- 16. SESSIONS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS sessions (
    session_id      INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    user_id         INT UNSIGNED        NOT NULL,
    user_type       ENUM('Admin','Employee','Customer')  NOT NULL,
    session_token   VARCHAR(64)         NOT NULL,
    expires_at      DATETIME            NOT NULL,
    ip_address      VARCHAR(45)         DEFAULT NULL,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id),
    UNIQUE KEY uq_session_token (session_token),
    INDEX idx_session_user (user_id, user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Active user sessions for remember-me functionality';

-- =============================================================================
-- 17. FAILED LOGINS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS failed_logins (
    attempt_id      INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    username        VARCHAR(50)         NOT NULL,
    user_type       ENUM('Admin','Employee','Customer')  NOT NULL,
    ip_address      VARCHAR(45)         DEFAULT NULL,
    attempted_at    DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (attempt_id),
    INDEX idx_failed_username (username, user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Failed login attempt tracking for lockout';

SELECT 'All tables created successfully.' AS status;
