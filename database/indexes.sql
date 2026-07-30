-- =============================================================================
-- Bank Management System - Indexes for Performance Optimization
-- =============================================================================
USE BankDB;

-- =============================================================================
-- BRANCHES INDEXES
-- =============================================================================
CREATE INDEX idx_branch_city      ON branches (city);
CREATE INDEX idx_branch_state     ON branches (state);
CREATE INDEX idx_branch_active    ON branches (is_active);

-- =============================================================================
-- CUSTOMERS INDEXES
-- =============================================================================
CREATE INDEX idx_customer_email   ON customers (email);
CREATE INDEX idx_customer_phone   ON customers (phone);
CREATE INDEX idx_customer_city    ON customers (city);
CREATE INDEX idx_customer_state   ON customers (state);
CREATE INDEX idx_customer_kyc     ON customers (kyc_status);
CREATE INDEX idx_customer_branch  ON customers (branch_id);
CREATE INDEX idx_customer_active  ON customers (is_active);
CREATE INDEX idx_customer_name    ON customers (full_name);

-- Full-text search on customer name
CREATE FULLTEXT INDEX ft_customer_name ON customers (full_name, email, phone);

-- =============================================================================
-- EMPLOYEES INDEXES
-- =============================================================================
CREATE INDEX idx_emp_branch   ON employees (branch_id);
CREATE INDEX idx_emp_role     ON employees (role_id);
CREATE INDEX idx_emp_name     ON employees (full_name);
CREATE INDEX idx_emp_active   ON employees (is_active);
CREATE FULLTEXT INDEX ft_emp_name ON employees (full_name, email);

-- =============================================================================
-- ACCOUNTS INDEXES
-- =============================================================================
CREATE INDEX idx_acc_customer   ON accounts (customer_id);
CREATE INDEX idx_acc_branch     ON accounts (branch_id);
CREATE INDEX idx_acc_type       ON accounts (account_type);
CREATE INDEX idx_acc_status     ON accounts (status);
CREATE INDEX idx_acc_balance    ON accounts (balance);
CREATE INDEX idx_acc_opened     ON accounts (opened_date);

-- =============================================================================
-- TRANSACTIONS INDEXES (critical for performance)
-- =============================================================================
CREATE INDEX idx_txn_account    ON transactions (account_id);
CREATE INDEX idx_txn_type       ON transactions (transaction_type);
CREATE INDEX idx_txn_status     ON transactions (status);
CREATE INDEX idx_txn_channel    ON transactions (channel);
CREATE INDEX idx_txn_date       ON transactions (created_at);
CREATE INDEX idx_txn_date_acc   ON transactions (account_id, created_at);   -- Composite: statement queries
CREATE INDEX idx_txn_amount     ON transactions (amount);

-- =============================================================================
-- LOANS INDEXES
-- =============================================================================
CREATE INDEX idx_loan_customer  ON loans (customer_id);
CREATE INDEX idx_loan_status    ON loans (status);
CREATE INDEX idx_loan_type      ON loans (loan_type);
CREATE INDEX idx_loan_branch    ON loans (branch_id);
CREATE INDEX idx_loan_next_emi  ON loans (next_emi_date);

-- =============================================================================
-- ATM CARDS INDEXES
-- =============================================================================
CREATE INDEX idx_card_account   ON atm_cards (account_id);
CREATE INDEX idx_card_status    ON atm_cards (status);
CREATE INDEX idx_card_expiry    ON atm_cards (expiry_year, expiry_month);

-- =============================================================================
-- FIXED DEPOSITS INDEXES
-- =============================================================================
CREATE INDEX idx_fd_customer    ON fixed_deposits (customer_id);
CREATE INDEX idx_fd_account     ON fixed_deposits (account_id);
CREATE INDEX idx_fd_status      ON fixed_deposits (status);
CREATE INDEX idx_fd_maturity    ON fixed_deposits (maturity_date);

-- =============================================================================
-- UPI INDEXES
-- =============================================================================
CREATE INDEX idx_upi_customer   ON upi_accounts (customer_id);
CREATE INDEX idx_upi_account    ON upi_accounts (account_id);
CREATE INDEX idx_upi_active     ON upi_accounts (is_active);

-- =============================================================================
-- BENEFICIARIES INDEXES
-- =============================================================================
CREATE INDEX idx_bene_customer  ON beneficiaries (customer_id);
CREATE INDEX idx_bene_active    ON beneficiaries (is_active);

-- =============================================================================
-- NOTIFICATIONS INDEXES
-- =============================================================================
CREATE INDEX idx_notif_customer ON notifications (customer_id);
CREATE INDEX idx_notif_read     ON notifications (customer_id, is_read);
CREATE INDEX idx_notif_date     ON notifications (created_at);

-- =============================================================================
-- SESSIONS INDEXES
-- =============================================================================
CREATE INDEX idx_session_expires ON sessions (expires_at);
CREATE INDEX idx_session_active  ON sessions (is_active);

SELECT 'Indexes created successfully.' AS status;
