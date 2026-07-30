-- =============================================================================
-- Bank Management System — SQL Analytics Showcase
-- =============================================================================
-- Author    : Data Analyst Portfolio Showcase
-- Database  : BankDB (MySQL 8.0+)
-- Purpose   : Demonstrates advanced SQL skills for Data Analyst roles:
--             CTEs, window functions, subqueries, aggregations, segmentation,
--             time-series analysis, and business intelligence queries.
-- =============================================================================
USE BankDB;


-- =============================================================================
-- QUERY 1: MONTHLY REVENUE TREND WITH MONTH-OVER-MONTH GROWTH
-- Technique: CTE + DATE_FORMAT + LAG window function
-- Business:  Track deposit inflow trends and identify growth/decline months
-- =============================================================================
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(t.created_at, '%Y-%m')          AS period,
        COUNT(t.transaction_id)                      AS txn_count,
        SUM(t.amount)                                AS total_volume,
        SUM(CASE WHEN t.transaction_type IN ('Deposit','UPI Credit','Transfer In','Interest Credit')
                 THEN t.amount ELSE 0 END)           AS inflow,
        SUM(CASE WHEN t.transaction_type IN ('Withdrawal','UPI Debit','Transfer Out','EMI Debit')
                 THEN t.amount ELSE 0 END)           AS outflow
    FROM transactions t
    WHERE t.status = 'Success'
    GROUP BY DATE_FORMAT(t.created_at, '%Y-%m')
)
SELECT
    period,
    txn_count,
    ROUND(total_volume, 2)                           AS total_volume,
    ROUND(inflow, 2)                                 AS inflow,
    ROUND(outflow, 2)                                AS outflow,
    ROUND(inflow - outflow, 2)                       AS net_flow,
    LAG(inflow) OVER (ORDER BY period)               AS prev_month_inflow,
    ROUND(
        (inflow - LAG(inflow) OVER (ORDER BY period))
        / NULLIF(LAG(inflow) OVER (ORDER BY period), 0) * 100
    , 2)                                             AS mom_growth_pct
FROM monthly_revenue
ORDER BY period;


-- =============================================================================
-- QUERY 2: CUSTOMER SEGMENTATION BY ACCOUNT BALANCE (RFM-STYLE)
-- Technique: NTILE window function + CASE for segmentation labels
-- Business:  Identify Premium, Standard, and At-Risk customer tiers
-- =============================================================================
WITH customer_balance AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.credit_score,
        b.branch_name,
        COALESCE(SUM(a.balance), 0)                  AS total_balance,
        COUNT(DISTINCT a.account_id)                 AS account_count,
        MAX(a.last_txn_date)                         AS last_activity
    FROM customers c
    JOIN branches b   ON c.branch_id = b.branch_id
    LEFT JOIN accounts a ON c.customer_id = a.customer_id AND a.status = 'Active'
    WHERE c.is_active = 1
    GROUP BY c.customer_id, c.full_name, c.credit_score, b.branch_name
),
ranked AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY total_balance DESC)  AS balance_quartile
    FROM customer_balance
)
SELECT
    customer_id,
    full_name,
    branch_name,
    ROUND(total_balance, 2)                          AS total_balance,
    account_count,
    credit_score,
    last_activity,
    DATEDIFF(CURDATE(), last_activity)               AS days_since_last_txn,
    CASE balance_quartile
        WHEN 1 THEN 'Premium'
        WHEN 2 THEN 'Standard'
        WHEN 3 THEN 'Regular'
        WHEN 4 THEN 'At-Risk'
    END                                              AS customer_segment
FROM ranked
ORDER BY total_balance DESC;


-- =============================================================================
-- QUERY 3: BRANCH PERFORMANCE RANKING WITH COMPOSITE SCORE
-- Technique: Multiple aggregations + DENSE_RANK window function
-- Business:  Identify high-performing and underperforming branches
-- =============================================================================
WITH branch_metrics AS (
    SELECT
        b.branch_id,
        b.branch_name,
        b.city,
        b.state,
        COUNT(DISTINCT c.customer_id)                AS total_customers,
        COUNT(DISTINCT a.account_id)                 AS total_accounts,
        COALESCE(SUM(a.balance), 0)                  AS total_deposits,
        COUNT(DISTINCT l.loan_id)                    AS total_loans,
        COALESCE(SUM(
            CASE WHEN l.status = 'Disbursed'
            THEN l.principal_amount END), 0)         AS loan_portfolio,
        COUNT(DISTINCT e.employee_id)                AS employee_count
    FROM branches b
    LEFT JOIN customers c   ON b.branch_id = c.branch_id
    LEFT JOIN accounts  a   ON b.branch_id = a.branch_id
    LEFT JOIN loans     l   ON b.branch_id = l.branch_id
    LEFT JOIN employees e   ON b.branch_id = e.branch_id
    WHERE b.is_active = 1
    GROUP BY b.branch_id, b.branch_name, b.city, b.state
)
SELECT
    branch_name,
    city,
    state,
    total_customers,
    total_accounts,
    ROUND(total_deposits, 2)                         AS total_deposits,
    total_loans,
    ROUND(loan_portfolio, 2)                         AS loan_portfolio,
    employee_count,
    ROUND(total_deposits / NULLIF(employee_count, 0), 2)
                                                     AS deposits_per_employee,
    ROUND(total_customers / NULLIF(employee_count, 0), 2)
                                                     AS customers_per_employee,
    DENSE_RANK() OVER (ORDER BY total_deposits DESC) AS deposit_rank,
    DENSE_RANK() OVER (ORDER BY total_customers DESC)AS customer_rank,
    DENSE_RANK() OVER (ORDER BY loan_portfolio DESC) AS loan_rank
FROM branch_metrics
ORDER BY total_deposits DESC;


-- =============================================================================
-- QUERY 4: ROLLING 30-DAY TRANSACTION AVERAGE
-- Technique: Self-join for rolling window (MySQL 8 frame clause alternative)
-- Business:  Smooth daily noise to see real transaction trends
-- =============================================================================
WITH daily_volume AS (
    SELECT
        DATE(created_at)                             AS txn_date,
        COUNT(*)                                     AS daily_count,
        SUM(amount)                                  AS daily_volume
    FROM transactions
    WHERE status = 'Success'
    GROUP BY DATE(created_at)
)
SELECT
    txn_date,
    daily_count,
    ROUND(daily_volume, 2)                           AS daily_volume,
    ROUND(AVG(daily_volume)
        OVER (ORDER BY txn_date
              ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2)
                                                     AS rolling_30d_avg,
    ROUND(SUM(daily_volume)
        OVER (ORDER BY txn_date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)
                                                     AS cumulative_volume
FROM daily_volume
ORDER BY txn_date;


-- =============================================================================
-- QUERY 5: TRANSACTION CHANNEL SHARE ANALYSIS
-- Technique: Aggregate + window SUM for percentage share
-- Business:  Understand which channels (UPI/ATM/Branch) drive volume
-- =============================================================================
WITH channel_stats AS (
    SELECT
        channel,
        transaction_type,
        COUNT(*)                                     AS txn_count,
        SUM(amount)                                  AS total_amount,
        AVG(amount)                                  AS avg_amount
    FROM transactions
    WHERE status = 'Success'
    GROUP BY channel, transaction_type
)
SELECT
    channel,
    transaction_type,
    txn_count,
    ROUND(total_amount, 2)                           AS total_amount,
    ROUND(avg_amount, 2)                             AS avg_amount,
    ROUND(
        txn_count * 100.0 /
        SUM(txn_count) OVER ()
    , 2)                                             AS pct_of_total_txns,
    ROUND(
        total_amount * 100.0 /
        SUM(total_amount) OVER ()
    , 2)                                             AS pct_of_total_volume
FROM channel_stats
ORDER BY total_amount DESC;


-- =============================================================================
-- QUERY 6: CUSTOMER CHURN DETECTION — INACTIVE ACCOUNTS
-- Technique: DATEDIFF + nested CASE + CTE for at-risk flagging
-- Business:  Identify customers at risk of churning for retention campaigns
-- =============================================================================
WITH last_activity AS (
    SELECT
        a.customer_id,
        MAX(t.created_at)                            AS last_txn_at,
        COUNT(t.transaction_id)                      AS lifetime_txns,
        SUM(t.amount)                                AS lifetime_volume
    FROM accounts a
    LEFT JOIN transactions t ON a.account_id = t.account_id
                             AND t.status = 'Success'
    GROUP BY a.customer_id
)
SELECT
    c.customer_id,
    c.full_name,
    c.email,
    c.phone,
    b.branch_name,
    c.credit_score,
    COALESCE(SUM(a.balance), 0)                      AS current_balance,
    la.last_txn_at,
    DATEDIFF(CURDATE(), la.last_txn_at)              AS days_since_last_txn,
    la.lifetime_txns,
    ROUND(la.lifetime_volume, 2)                     AS lifetime_volume,
    CASE
        WHEN DATEDIFF(CURDATE(), la.last_txn_at) > 180 THEN 'Churned'
        WHEN DATEDIFF(CURDATE(), la.last_txn_at) > 90  THEN 'High Risk'
        WHEN DATEDIFF(CURDATE(), la.last_txn_at) > 30  THEN 'At Risk'
        ELSE 'Active'
    END                                              AS churn_status
FROM customers c
JOIN branches b          ON c.branch_id = b.branch_id
LEFT JOIN accounts a     ON c.customer_id = a.customer_id AND a.status = 'Active'
LEFT JOIN last_activity la ON c.customer_id = la.customer_id
WHERE c.is_active = 1
GROUP BY c.customer_id, c.full_name, c.email, c.phone,
         b.branch_name, c.credit_score, la.last_txn_at,
         la.lifetime_txns, la.lifetime_volume
HAVING churn_status IN ('High Risk', 'Churned')
ORDER BY days_since_last_txn DESC;


-- =============================================================================
-- QUERY 7: TOP N CUSTOMERS PER BRANCH (ROW_NUMBER PARTITION)
-- Technique: ROW_NUMBER() OVER (PARTITION BY branch) + CTE filter
-- Business:  Identify VIP customers at each branch for relationship banking
-- =============================================================================
WITH customer_ranked AS (
    SELECT
        b.branch_name,
        c.full_name                                  AS customer_name,
        c.credit_score,
        COALESCE(SUM(a.balance), 0)                  AS total_balance,
        COUNT(DISTINCT a.account_id)                 AS account_count,
        ROW_NUMBER() OVER (
            PARTITION BY b.branch_id
            ORDER BY SUM(a.balance) DESC
        )                                            AS branch_rank
    FROM customers c
    JOIN branches b   ON c.branch_id = b.branch_id
    JOIN accounts a   ON c.customer_id = a.customer_id AND a.status = 'Active'
    WHERE c.is_active = 1
    GROUP BY b.branch_id, b.branch_name, c.customer_id, c.full_name, c.credit_score
)
SELECT
    branch_name,
    branch_rank,
    customer_name,
    credit_score,
    ROUND(total_balance, 2)                          AS total_balance,
    account_count
FROM customer_ranked
WHERE branch_rank <= 3                               -- Top 3 per branch
ORDER BY branch_name, branch_rank;


-- =============================================================================
-- QUERY 8: LOAN DEFAULT RISK SCORING
-- Technique: Multi-condition scoring + CASE bucketing
-- Business:  Prioritise loan review queue by default risk
-- =============================================================================
SELECT
    l.loan_id,
    l.loan_account_no,
    l.loan_type,
    c.full_name                                      AS borrower,
    c.credit_score,
    b.branch_name,
    ROUND(l.principal_amount, 2)                     AS principal,
    ROUND(l.outstanding_amount, 2)                   AS outstanding,
    l.emis_paid,
    l.tenure_months,
    ROUND(l.emis_paid * 100.0 / l.tenure_months, 1) AS completion_pct,
    l.next_emi_date,
    DATEDIFF(CURDATE(), l.next_emi_date)             AS emi_days_overdue,
    -- Composite risk score (0–100)
    (
        CASE WHEN c.credit_score < 650  THEN 30
             WHEN c.credit_score < 700  THEN 20
             WHEN c.credit_score < 750  THEN 10
             ELSE 0
        END
        +
        CASE WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 30 THEN 40
             WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 0  THEN 20
             ELSE 0
        END
        +
        CASE WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.9 THEN 20
             WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.7 THEN 10
             ELSE 0
        END
        +
        CASE WHEN c.annual_income < 300000 THEN 10 ELSE 0 END
    )                                                AS risk_score,
    CASE
        WHEN (
            CASE WHEN c.credit_score < 650 THEN 30 WHEN c.credit_score < 700 THEN 20
                 WHEN c.credit_score < 750 THEN 10 ELSE 0 END
            + CASE WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 30 THEN 40
                   WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 0  THEN 20 ELSE 0 END
            + CASE WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.9 THEN 20
                   WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.7 THEN 10 ELSE 0 END
            + CASE WHEN c.annual_income < 300000 THEN 10 ELSE 0 END
        ) >= 60 THEN 'High Risk'
        WHEN (
            CASE WHEN c.credit_score < 650 THEN 30 WHEN c.credit_score < 700 THEN 20
                 WHEN c.credit_score < 750 THEN 10 ELSE 0 END
            + CASE WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 30 THEN 40
                   WHEN DATEDIFF(CURDATE(), l.next_emi_date) > 0  THEN 20 ELSE 0 END
            + CASE WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.9 THEN 20
                   WHEN l.outstanding_amount / NULLIF(l.principal_amount,0) > 0.7 THEN 10 ELSE 0 END
            + CASE WHEN c.annual_income < 300000 THEN 10 ELSE 0 END
        ) >= 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END                                              AS risk_category
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN branches  b ON l.branch_id   = b.branch_id
WHERE l.status IN ('Disbursed', 'Under Review')
ORDER BY risk_score DESC;


-- =============================================================================
-- QUERY 9: COHORT RETENTION — CUSTOMERS BY REGISTRATION MONTH
-- Technique: Cohort analysis using DATE_FORMAT + COUNT DISTINCT
-- Business:  Understand which customer acquisition months retained best
-- =============================================================================
WITH cohort_base AS (
    SELECT
        customer_id,
        DATE_FORMAT(created_at, '%Y-%m')             AS cohort_month
    FROM customers
    WHERE is_active = 1
),
cohort_activity AS (
    SELECT
        cb.cohort_month,
        DATE_FORMAT(t.created_at, '%Y-%m')           AS activity_month,
        COUNT(DISTINCT cb.customer_id)               AS active_customers
    FROM cohort_base cb
    JOIN accounts a   ON cb.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
                       AND t.status = 'Success'
    GROUP BY cb.cohort_month, DATE_FORMAT(t.created_at, '%Y-%m')
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohort_base
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    cs.cohort_size,
    ca.activity_month,
    ca.active_customers,
    ROUND(ca.active_customers * 100.0 / cs.cohort_size, 1)
                                                     AS retention_rate_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.activity_month;


-- =============================================================================
-- QUERY 10: EXECUTIVE KPI SUMMARY — SINGLE-QUERY SNAPSHOT
-- Technique: Multiple subqueries / conditional aggregation in one SELECT
-- Business:  One-shot executive summary for dashboards
-- =============================================================================
SELECT
    -- Customer KPIs
    (SELECT COUNT(*) FROM customers WHERE is_active = 1)
                                                     AS total_active_customers,
    (SELECT COUNT(*) FROM customers
     WHERE is_active = 1
       AND DATEDIFF(CURDATE(), created_at) <= 30)    AS new_customers_30d,

    -- Account KPIs
    (SELECT COUNT(*) FROM accounts WHERE status = 'Active')
                                                     AS total_active_accounts,
    (SELECT ROUND(SUM(balance), 2) FROM accounts WHERE status = 'Active')
                                                     AS total_deposits_inr,

    -- Transaction KPIs (last 30 days)
    (SELECT COUNT(*) FROM transactions
     WHERE status = 'Success'
       AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY))
                                                     AS txns_last_30d,
    (SELECT ROUND(SUM(amount), 2) FROM transactions
     WHERE status = 'Success'
       AND transaction_type IN ('Deposit','UPI Credit','Transfer In')
       AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY))
                                                     AS inflow_last_30d,
    (SELECT ROUND(SUM(amount), 2) FROM transactions
     WHERE status = 'Success'
       AND transaction_type IN ('Withdrawal','UPI Debit','Transfer Out')
       AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY))
                                                     AS outflow_last_30d,

    -- Loan KPIs
    (SELECT COUNT(*) FROM loans WHERE status = 'Disbursed')
                                                     AS active_loans,
    (SELECT ROUND(SUM(outstanding_amount), 2) FROM loans WHERE status = 'Disbursed')
                                                     AS total_loan_outstanding,

    -- Branch KPIs
    (SELECT COUNT(*) FROM branches WHERE is_active = 1)
                                                     AS active_branches;


-- =============================================================================
-- QUERY 11: AVERAGE TRANSACTION VALUE BY HOUR (PEAK HOUR ANALYSIS)
-- Technique: HOUR() time-bucketing + conditional aggregation
-- Business:  Identify staffing needs and peak transaction windows
-- =============================================================================
SELECT
    HOUR(created_at)                                 AS hour_of_day,
    COUNT(*)                                         AS txn_count,
    ROUND(SUM(amount), 2)                            AS total_volume,
    ROUND(AVG(amount), 2)                            AS avg_txn_value,
    ROUND(MAX(amount), 2)                            AS max_txn_value,
    SUM(CASE WHEN transaction_type = 'Deposit'   THEN 1 ELSE 0 END)
                                                     AS deposits,
    SUM(CASE WHEN transaction_type = 'Withdrawal' THEN 1 ELSE 0 END)
                                                     AS withdrawals,
    SUM(CASE WHEN channel = 'UPI'                THEN 1 ELSE 0 END)
                                                     AS upi_txns,
    SUM(CASE WHEN channel = 'ATM'                THEN 1 ELSE 0 END)
                                                     AS atm_txns
FROM transactions
WHERE status = 'Success'
GROUP BY HOUR(created_at)
ORDER BY txn_count DESC;
