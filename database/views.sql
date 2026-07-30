-- =============================================================================
-- Bank Management System - Database Views
-- =============================================================================
-- Covers: account summaries, transaction details, customer portfolio,
--         loan summary, branch performance, employee details, and more.
-- =============================================================================
USE BankDB;

-- =============================================================================
-- 1. ACCOUNT SUMMARY VIEW
-- Joins accounts with customer name and branch info for dashboards
-- =============================================================================
CREATE OR REPLACE VIEW v_account_summary AS
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    a.min_balance,
    a.interest_rate,
    a.status          AS account_status,
    a.opened_date,
    a.last_txn_date,
    c.customer_id,
    c.customer_code,
    c.full_name       AS customer_name,
    c.email           AS customer_email,
    c.phone           AS customer_phone,
    b.branch_id,
    b.branch_name,
    b.ifsc_code,
    b.city            AS branch_city,
    (SELECT COUNT(*)
     FROM transactions t
     WHERE t.account_id = a.account_id) AS total_transactions
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches  b ON a.branch_id   = b.branch_id;

-- =============================================================================
-- 2. TRANSACTION DETAIL VIEW
-- Full transaction history with account and customer info
-- =============================================================================
CREATE OR REPLACE VIEW v_transaction_detail AS
SELECT
    t.transaction_id,
    t.reference_number,
    t.transaction_type,
    t.amount,
    t.balance_before,
    t.balance_after,
    t.description,
    t.counterpart_account,
    t.channel,
    t.status          AS txn_status,
    t.created_at      AS txn_date,
    a.account_number,
    a.account_type,
    c.customer_id,
    c.full_name       AS customer_name,
    c.email           AS customer_email,
    CONCAT(e.full_name) AS processed_by_name,
    b.branch_name
FROM transactions t
JOIN accounts   a ON t.account_id   = a.account_id
JOIN customers  c ON a.customer_id  = c.customer_id
JOIN branches   b ON a.branch_id    = b.branch_id
LEFT JOIN employees e ON t.processed_by = e.employee_id;

-- =============================================================================
-- 3. CUSTOMER PORTFOLIO VIEW
-- Aggregated customer view: accounts, balance, loans, FDs
-- =============================================================================
CREATE OR REPLACE VIEW v_customer_portfolio AS
SELECT
    c.customer_id,
    c.customer_code,
    c.full_name,
    c.email,
    c.phone,
    c.kyc_status,
    c.credit_score,
    c.is_active,
    b.branch_name     AS home_branch,
    -- Account aggregates
    COUNT(DISTINCT a.account_id)                            AS total_accounts,
    COALESCE(SUM(a.balance), 0)                             AS total_balance,
    COUNT(DISTINCT CASE WHEN a.status = 'Active' THEN a.account_id END) AS active_accounts,
    -- Loan aggregates
    COUNT(DISTINCT l.loan_id)                               AS total_loans,
    COALESCE(SUM(CASE WHEN l.status = 'Disbursed' THEN l.outstanding_amount END), 0)
                                                            AS total_outstanding,
    -- FD aggregates
    COUNT(DISTINCT fd.fd_id)                                AS total_fds,
    COALESCE(SUM(CASE WHEN fd.status = 'Active' THEN fd.principal END), 0)
                                                            AS total_fd_invested,
    -- Cards
    COUNT(DISTINCT ac.card_id)                              AS total_cards
FROM customers c
JOIN    branches b  ON c.branch_id   = b.branch_id
LEFT JOIN accounts a   ON c.customer_id = a.customer_id
LEFT JOIN loans    l   ON c.customer_id = l.customer_id
LEFT JOIN fixed_deposits fd ON c.customer_id = fd.customer_id
LEFT JOIN atm_cards      ac ON a.account_id  = ac.account_id
GROUP BY
    c.customer_id, c.customer_code, c.full_name, c.email,
    c.phone, c.kyc_status, c.credit_score, c.is_active, b.branch_name;

-- =============================================================================
-- 4. LOAN SUMMARY VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_loan_summary AS
SELECT
    l.loan_id,
    l.loan_account_no,
    l.loan_type,
    l.principal_amount,
    l.interest_rate,
    l.tenure_months,
    l.emi_amount,
    l.outstanding_amount,
    l.emis_paid,
    l.status          AS loan_status,
    l.disbursement_date,
    l.next_emi_date,
    c.customer_id,
    c.full_name       AS customer_name,
    c.email           AS customer_email,
    c.phone           AS customer_phone,
    c.credit_score,
    b.branch_name,
    a.account_number  AS disbursement_account,
    CONCAT(e.full_name) AS approved_by_name,
    (l.tenure_months - l.emis_paid) AS remaining_emis,
    (l.outstanding_amount / NULLIF(l.principal_amount, 0) * 100) AS completion_pct
FROM loans l
JOIN customers  c ON l.customer_id  = c.customer_id
JOIN accounts   a ON l.account_id   = a.account_id
JOIN branches   b ON l.branch_id    = b.branch_id
LEFT JOIN employees e ON l.approved_by = e.employee_id;

-- =============================================================================
-- 5. BRANCH PERFORMANCE VIEW
-- Monthly metrics per branch for management reporting
-- =============================================================================
CREATE OR REPLACE VIEW v_branch_performance AS
SELECT
    b.branch_id,
    b.branch_name,
    b.city,
    b.state,
    b.ifsc_code,
    COUNT(DISTINCT c.customer_id)                           AS total_customers,
    COUNT(DISTINCT a.account_id)                            AS total_accounts,
    COALESCE(SUM(a.balance), 0)                             AS total_deposits,
    COUNT(DISTINCT CASE WHEN a.status = 'Active' THEN a.account_id END) AS active_accounts,
    COUNT(DISTINCT l.loan_id)                               AS total_loans,
    COALESCE(SUM(CASE WHEN l.status IN ('Disbursed') THEN l.principal_amount END), 0)
                                                            AS total_loan_amount,
    COUNT(DISTINCT e.employee_id)                           AS total_employees,
    COUNT(DISTINCT fd.fd_id)                                AS total_fds,
    COALESCE(SUM(CASE WHEN fd.status = 'Active' THEN fd.principal END), 0)
                                                            AS total_fd_amount
FROM branches b
LEFT JOIN accounts  a ON b.branch_id = a.branch_id
LEFT JOIN customers c ON b.branch_id = c.branch_id
LEFT JOIN loans     l ON b.branch_id = l.branch_id
LEFT JOIN employees e ON b.branch_id = e.branch_id
LEFT JOIN fixed_deposits fd ON b.branch_id = fd.branch_id
WHERE b.is_active = 1
GROUP BY b.branch_id, b.branch_name, b.city, b.state, b.ifsc_code;

-- =============================================================================
-- 6. EMPLOYEE DETAILS VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_employee_details AS
SELECT
    e.employee_id,
    e.employee_code,
    e.full_name,
    e.email,
    e.phone,
    e.gender,
    e.designation,
    e.department,
    e.joining_date,
    e.salary,
    e.is_active,
    r.role_name,
    b.branch_name,
    b.city            AS branch_city,
    TIMESTAMPDIFF(YEAR, e.date_of_birth, CURDATE()) AS age,
    TIMESTAMPDIFF(YEAR, e.joining_date, CURDATE())  AS years_of_service
FROM employees e
JOIN roles    r ON e.role_id   = r.role_id
JOIN branches b ON e.branch_id = b.branch_id;

-- =============================================================================
-- 7. ACTIVE CARDS VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_active_cards AS
SELECT
    ac.card_id,
    ac.card_number,
    ac.card_type,
    ac.card_network,
    ac.cardholder_name,
    ac.expiry_month,
    ac.expiry_year,
    CONCAT(LPAD(ac.expiry_month, 2, '0'), '/', ac.expiry_year) AS expiry_display,
    ac.daily_limit,
    ac.status         AS card_status,
    ac.is_contactless,
    ac.is_international,
    ac.issued_date,
    ac.last_used_date,
    a.account_number,
    a.account_type,
    c.customer_id,
    c.full_name       AS customer_name,
    DATEDIFF(
        MAKEDATE(ac.expiry_year, 1) + INTERVAL ac.expiry_month MONTH,
        CURDATE()
    ) AS days_to_expiry
FROM atm_cards ac
JOIN accounts  a ON ac.account_id  = a.account_id
JOIN customers c ON a.customer_id  = c.customer_id
WHERE ac.status = 'Active';

-- =============================================================================
-- 8. FIXED DEPOSIT SUMMARY VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_fd_summary AS
SELECT
    fd.fd_id,
    fd.fd_number,
    fd.principal,
    fd.interest_rate,
    fd.tenure_months,
    fd.compounding,
    fd.maturity_amount,
    fd.interest_earned,
    fd.start_date,
    fd.maturity_date,
    fd.status         AS fd_status,
    fd.auto_renew,
    DATEDIFF(fd.maturity_date, CURDATE()) AS days_to_maturity,
    c.customer_id,
    c.full_name       AS customer_name,
    c.email,
    a.account_number,
    b.branch_name
FROM fixed_deposits fd
JOIN customers  c ON fd.customer_id = c.customer_id
JOIN accounts   a ON fd.account_id  = a.account_id
JOIN branches   b ON fd.branch_id   = b.branch_id;

-- =============================================================================
-- 9. MONTHLY REPORT VIEW (Power BI ready)
-- =============================================================================
CREATE OR REPLACE VIEW v_monthly_report AS
SELECT
    YEAR(t.created_at)                                      AS txn_year,
    MONTH(t.created_at)                                     AS txn_month,
    DATE_FORMAT(t.created_at, '%Y-%m')                      AS period,
    t.transaction_type,
    t.channel,
    b.branch_name,
    COUNT(t.transaction_id)                                 AS txn_count,
    SUM(t.amount)                                           AS total_amount,
    AVG(t.amount)                                           AS avg_amount,
    MIN(t.amount)                                           AS min_amount,
    MAX(t.amount)                                           AS max_amount,
    COUNT(DISTINCT t.account_id)                            AS unique_accounts
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN branches b ON a.branch_id  = b.branch_id
WHERE t.status = 'Success'
GROUP BY
    YEAR(t.created_at), MONTH(t.created_at),
    DATE_FORMAT(t.created_at, '%Y-%m'),
    t.transaction_type, t.channel, b.branch_name;

-- =============================================================================
-- 10. INACTIVE ACCOUNTS VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_inactive_accounts AS
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    a.last_txn_date,
    DATEDIFF(CURDATE(), COALESCE(a.last_txn_date, a.opened_date)) AS days_inactive,
    a.status,
    c.full_name       AS customer_name,
    c.email,
    c.phone,
    b.branch_name
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches  b ON a.branch_id   = b.branch_id
WHERE a.status = 'Active'
  AND (
      a.last_txn_date IS NULL
      OR DATEDIFF(CURDATE(), a.last_txn_date) > 365
  );

-- =============================================================================
-- 11. TOP CUSTOMERS BY BALANCE VIEW
-- =============================================================================
CREATE OR REPLACE VIEW v_top_customers AS
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    c.credit_score,
    SUM(a.balance)                          AS total_balance,
    COUNT(DISTINCT a.account_id)            AS account_count,
    COALESCE(SUM(CASE WHEN l.status = 'Disbursed' THEN l.principal_amount END), 0)
                                            AS total_loans,
    RANK() OVER (ORDER BY SUM(a.balance) DESC) AS balance_rank
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
WHERE c.is_active = 1 AND a.status = 'Active'
GROUP BY c.customer_id, c.full_name, c.email, c.phone, c.credit_score;

SELECT 'Views created successfully.' AS status;
