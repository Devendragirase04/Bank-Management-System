-- =============================================================================
-- Bank Management System - Additional Constraints
-- =============================================================================
USE BankDB;

-- =============================================================================
-- Additional CHECK Constraints (MySQL 8.0+ supports these fully)
-- =============================================================================

-- Customers: credit score range
ALTER TABLE customers
    ADD CONSTRAINT chk_credit_score CHECK (credit_score BETWEEN 300 AND 900);

-- Customers: annual income non-negative
ALTER TABLE customers
    ADD CONSTRAINT chk_annual_income CHECK (annual_income IS NULL OR annual_income >= 0);

-- Accounts: interest rate range
ALTER TABLE accounts
    ADD CONSTRAINT chk_acc_interest CHECK (interest_rate BETWEEN 0 AND 25);

-- Accounts: minimum balance non-negative
ALTER TABLE accounts
    ADD CONSTRAINT chk_acc_min_bal CHECK (min_balance >= 0);

-- Transactions: amount limit
ALTER TABLE transactions
    ADD CONSTRAINT chk_txn_max_amount CHECK (amount <= 99999999.99);

-- Loans: interest rate range
ALTER TABLE loans
    ADD CONSTRAINT chk_loan_interest CHECK (interest_rate BETWEEN 0 AND 50);

-- Loans: outstanding amount non-negative
ALTER TABLE loans
    ADD CONSTRAINT chk_loan_outstanding CHECK (outstanding_amount >= 0);

-- Fixed Deposits: interest rate range
ALTER TABLE fixed_deposits
    ADD CONSTRAINT chk_fd_interest CHECK (interest_rate BETWEEN 0 AND 25);

-- Fixed Deposits: maturity_date must be after start_date
ALTER TABLE fixed_deposits
    ADD CONSTRAINT chk_fd_dates CHECK (maturity_date > start_date);

-- Employees: salary non-negative
ALTER TABLE employees
    ADD CONSTRAINT chk_emp_salary CHECK (salary >= 0);

-- ATM Cards: daily limit range
ALTER TABLE atm_cards
    ADD CONSTRAINT chk_card_daily_limit_max CHECK (daily_limit BETWEEN 100 AND 500000);

-- UPI: daily limit range
ALTER TABLE upi_accounts
    ADD CONSTRAINT chk_upi_daily CHECK (daily_limit BETWEEN 100 AND 200000);

SELECT 'Constraints applied successfully.' AS status;
