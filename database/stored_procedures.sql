-- =============================================================================
-- Bank Management System - Stored Procedures
-- =============================================================================
USE BankDB;

DELIMITER $$

-- =============================================================================
-- sp_transfer_funds: Atomic fund transfer between two accounts
-- Uses a transaction to ensure both debit and credit succeed together.
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_transfer_funds$$
CREATE PROCEDURE sp_transfer_funds(
    IN  p_from_account_id   INT UNSIGNED,
    IN  p_to_account_no     VARCHAR(20),
    IN  p_amount            DECIMAL(15,2),
    IN  p_description       VARCHAR(255),
    IN  p_processed_by      INT UNSIGNED,
    IN  p_channel           VARCHAR(50),
    OUT p_reference         VARCHAR(30),
    OUT p_status            VARCHAR(20),
    OUT p_message           VARCHAR(255)
)
BEGIN
    DECLARE v_to_account_id   INT UNSIGNED;
    DECLARE v_from_balance    DECIMAL(15,2);
    DECLARE v_to_balance      DECIMAL(15,2);
    DECLARE v_from_min_bal    DECIMAL(10,2);
    DECLARE v_from_status     VARCHAR(20);
    DECLARE v_to_status       VARCHAR(20);
    DECLARE v_ref_no          VARCHAR(30);
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Transfer failed due to a database error.';
    END;

    START TRANSACTION;

    -- Generate unique reference
    SET v_ref_no = CONCAT('TXN', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
                           LPAD(FLOOR(RAND() * 999999), 6, '0'));

    -- Validate FROM account
    SELECT status, balance, min_balance
    INTO v_from_status, v_from_balance, v_from_min_bal
    FROM accounts
    WHERE account_id = p_from_account_id
    FOR UPDATE;

    IF v_from_status != 'Active' THEN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Source account is not active.';
        LEAVE sp_transfer_funds;
    END IF;

    IF (v_from_balance - p_amount) < v_from_min_bal THEN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Insufficient balance in source account.';
        LEAVE sp_transfer_funds;
    END IF;

    -- Validate TO account
    SELECT account_id, status, balance
    INTO v_to_account_id, v_to_status, v_to_balance
    FROM accounts
    WHERE account_number = p_to_account_no
    FOR UPDATE;

    IF v_to_account_id IS NULL THEN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Destination account not found.';
        LEAVE sp_transfer_funds;
    END IF;

    IF v_to_status != 'Active' THEN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Destination account is not active.';
        LEAVE sp_transfer_funds;
    END IF;

    -- Debit source account
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account_id;

    -- Credit destination account
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = v_to_account_id;

    -- Record debit transaction
    INSERT INTO transactions (
        reference_number, account_id, transaction_type, amount,
        balance_before, balance_after, description,
        counterpart_account, channel, status, processed_by, created_at
    ) VALUES (
        CONCAT(v_ref_no, 'D'),
        p_from_account_id, 'Transfer Out', p_amount,
        v_from_balance, v_from_balance - p_amount,
        COALESCE(p_description, CONCAT('Transfer to ', p_to_account_no)),
        p_to_account_no, p_channel, 'Success', p_processed_by, NOW()
    );

    -- Record credit transaction
    INSERT INTO transactions (
        reference_number, account_id, transaction_type, amount,
        balance_before, balance_after, description,
        counterpart_account, channel, status, processed_by, created_at
    ) VALUES (
        CONCAT(v_ref_no, 'C'),
        v_to_account_id, 'Transfer In', p_amount,
        v_to_balance, v_to_balance + p_amount,
        COALESCE(p_description, CONCAT('Transfer from account ending ', RIGHT(
            (SELECT account_number FROM accounts WHERE account_id = p_from_account_id), 4))),
        (SELECT account_number FROM accounts WHERE account_id = p_from_account_id),
        p_channel, 'Success', p_processed_by, NOW()
    );

    COMMIT;

    SET p_reference = v_ref_no;
    SET p_status    = 'Success';
    SET p_message   = CONCAT('Transfer of ₹', FORMAT(p_amount, 2), ' completed successfully.');
END$$

-- =============================================================================
-- sp_deposit: Deposit money into an account
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_deposit$$
CREATE PROCEDURE sp_deposit(
    IN  p_account_id    INT UNSIGNED,
    IN  p_amount        DECIMAL(15,2),
    IN  p_description   VARCHAR(255),
    IN  p_processed_by  INT UNSIGNED,
    IN  p_channel       VARCHAR(50),
    OUT p_reference     VARCHAR(30),
    OUT p_new_balance   DECIMAL(15,2),
    OUT p_status        VARCHAR(20),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_balance   DECIMAL(15,2);
    DECLARE v_status    VARCHAR(20);
    DECLARE v_ref_no    VARCHAR(30);
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status  = 'Failed';
        SET p_message = 'Deposit failed.';
    END;

    START TRANSACTION;

    SELECT status, balance INTO v_status, v_balance
    FROM accounts
    WHERE account_id = p_account_id FOR UPDATE;

    IF v_status NOT IN ('Active') THEN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Account is not active.';
        LEAVE sp_deposit;
    END IF;

    IF p_amount <= 0 THEN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Deposit amount must be positive.';
        LEAVE sp_deposit;
    END IF;

    SET v_ref_no = CONCAT('DEP', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
                           LPAD(FLOOR(RAND() * 999999), 6, '0'));

    UPDATE accounts SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions (
        reference_number, account_id, transaction_type, amount,
        balance_before, balance_after, description, channel, status,
        processed_by, created_at
    ) VALUES (
        v_ref_no, p_account_id, 'Deposit', p_amount,
        v_balance, v_balance + p_amount,
        COALESCE(p_description, 'Cash Deposit'), p_channel, 'Success',
        p_processed_by, NOW()
    );

    COMMIT;

    SET p_reference   = v_ref_no;
    SET p_new_balance = v_balance + p_amount;
    SET p_status      = 'Success';
    SET p_message     = CONCAT('Deposit of ₹', FORMAT(p_amount, 2), ' successful.');
END$$

-- =============================================================================
-- sp_withdraw: Withdraw money from an account
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_withdraw$$
CREATE PROCEDURE sp_withdraw(
    IN  p_account_id    INT UNSIGNED,
    IN  p_amount        DECIMAL(15,2),
    IN  p_description   VARCHAR(255),
    IN  p_processed_by  INT UNSIGNED,
    IN  p_channel       VARCHAR(50),
    OUT p_reference     VARCHAR(30),
    OUT p_new_balance   DECIMAL(15,2),
    OUT p_status        VARCHAR(20),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_balance   DECIMAL(15,2);
    DECLARE v_min_bal   DECIMAL(10,2);
    DECLARE v_status    VARCHAR(20);
    DECLARE v_ref_no    VARCHAR(30);
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Withdrawal failed.';
    END;

    START TRANSACTION;

    SELECT status, balance, min_balance INTO v_status, v_balance, v_min_bal
    FROM accounts WHERE account_id = p_account_id FOR UPDATE;

    IF v_status != 'Active' THEN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Account is not active.';
        LEAVE sp_withdraw;
    END IF;

    IF p_amount <= 0 THEN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Withdrawal amount must be positive.';
        LEAVE sp_withdraw;
    END IF;

    IF (v_balance - p_amount) < v_min_bal THEN
        ROLLBACK;
        SET p_status = 'Failed';
        SET p_message = CONCAT('Insufficient balance. Minimum balance ₹',
                               FORMAT(v_min_bal, 2), ' must be maintained.');
        LEAVE sp_withdraw;
    END IF;

    SET v_ref_no = CONCAT('WDR', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
                           LPAD(FLOOR(RAND() * 999999), 6, '0'));

    UPDATE accounts SET balance = balance - p_amount
    WHERE account_id = p_account_id;

    INSERT INTO transactions (
        reference_number, account_id, transaction_type, amount,
        balance_before, balance_after, description, channel, status,
        processed_by, created_at
    ) VALUES (
        v_ref_no, p_account_id, 'Withdrawal', p_amount,
        v_balance, v_balance - p_amount,
        COALESCE(p_description, 'Cash Withdrawal'), p_channel, 'Success',
        p_processed_by, NOW()
    );

    COMMIT;

    SET p_reference   = v_ref_no;
    SET p_new_balance = v_balance - p_amount;
    SET p_status      = 'Success';
    SET p_message     = CONCAT('Withdrawal of ₹', FORMAT(p_amount, 2), ' successful.');
END$$

-- =============================================================================
-- sp_approve_loan: Approve a loan and disburse funds
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_approve_loan$$
CREATE PROCEDURE sp_approve_loan(
    IN  p_loan_id       INT UNSIGNED,
    IN  p_approved_by   INT UNSIGNED,
    OUT p_status        VARCHAR(20),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_account_id    INT UNSIGNED;
    DECLARE v_principal     DECIMAL(15,2);
    DECLARE v_emi           DECIMAL(12,2);
    DECLARE v_tenure        SMALLINT UNSIGNED;
    DECLARE v_loan_status   VARCHAR(30);
    DECLARE v_acc_balance   DECIMAL(15,2);
    DECLARE v_ref_no        VARCHAR(30);
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Loan approval failed.';
    END;

    START TRANSACTION;

    SELECT status, account_id, principal_amount, emi_amount, tenure_months
    INTO v_loan_status, v_account_id, v_principal, v_emi, v_tenure
    FROM loans WHERE loan_id = p_loan_id FOR UPDATE;

    IF v_loan_status NOT IN ('Approved') THEN
        ROLLBACK;
        SET p_status = 'Failed';
        SET p_message = CONCAT('Cannot disburse loan in status: ', v_loan_status);
        LEAVE sp_approve_loan;
    END IF;

    SELECT balance INTO v_acc_balance FROM accounts WHERE account_id = v_account_id;

    SET v_ref_no = CONCAT('LND', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'),
                           LPAD(FLOOR(RAND() * 999999), 6, '0'));

    -- Credit loan amount to account
    UPDATE accounts SET balance = balance + v_principal
    WHERE account_id = v_account_id;

    -- Record disbursement transaction
    INSERT INTO transactions (
        reference_number, account_id, transaction_type, amount,
        balance_before, balance_after, description, channel, status
    ) VALUES (
        v_ref_no, v_account_id, 'Loan Disbursement', v_principal,
        v_acc_balance, v_acc_balance + v_principal,
        CONCAT('Loan disbursement - Loan ID: ', p_loan_id),
        'Internal', 'Success'
    );

    -- Update loan status to Disbursed
    UPDATE loans SET
        status            = 'Disbursed',
        approved_by       = p_approved_by,
        disbursement_date = CURDATE(),
        first_emi_date    = DATE_ADD(CURDATE(), INTERVAL 1 MONTH),
        next_emi_date     = DATE_ADD(CURDATE(), INTERVAL 1 MONTH),
        last_emi_date     = DATE_ADD(CURDATE(), INTERVAL v_tenure MONTH)
    WHERE loan_id = p_loan_id;

    -- Generate EMI schedule
    CALL sp_generate_emi_schedule(p_loan_id);

    COMMIT;

    SET p_status  = 'Success';
    SET p_message = CONCAT('Loan disbursed: ₹', FORMAT(v_principal, 2), ' credited to account.');
END$$

-- =============================================================================
-- sp_generate_emi_schedule: Create amortization table for a loan
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_generate_emi_schedule$$
CREATE PROCEDURE sp_generate_emi_schedule(IN p_loan_id INT UNSIGNED)
BEGIN
    DECLARE v_principal     DECIMAL(15,2);
    DECLARE v_annual_rate   DECIMAL(5,2);
    DECLARE v_tenure        SMALLINT UNSIGNED;
    DECLARE v_emi           DECIMAL(12,2);
    DECLARE v_monthly_rate  DECIMAL(15,8);
    DECLARE v_outstanding   DECIMAL(15,2);
    DECLARE v_first_emi     DATE;
    DECLARE v_interest_comp DECIMAL(12,2);
    DECLARE v_principal_comp DECIMAL(12,2);
    DECLARE i               SMALLINT DEFAULT 1;

    SELECT principal_amount, interest_rate, tenure_months, emi_amount, first_emi_date
    INTO v_principal, v_annual_rate, v_tenure, v_emi, v_first_emi
    FROM loans WHERE loan_id = p_loan_id;

    SET v_monthly_rate = v_annual_rate / (12.0 * 100.0);
    SET v_outstanding  = v_principal;

    -- Delete existing schedule if regenerating
    DELETE FROM loan_emi_schedule WHERE loan_id = p_loan_id;

    WHILE i <= v_tenure DO
        SET v_interest_comp  = ROUND(v_outstanding * v_monthly_rate, 2);
        SET v_principal_comp = ROUND(v_emi - v_interest_comp, 2);

        -- Last EMI: clear remaining outstanding
        IF i = v_tenure THEN
            SET v_principal_comp = v_outstanding;
            SET v_emi = v_outstanding + v_interest_comp;
        END IF;

        SET v_outstanding = v_outstanding - v_principal_comp;
        IF v_outstanding < 0 THEN SET v_outstanding = 0.00; END IF;

        INSERT INTO loan_emi_schedule (
            loan_id, emi_number, due_date, emi_amount,
            principal_component, interest_component, outstanding_after, status
        ) VALUES (
            p_loan_id, i,
            DATE_ADD(v_first_emi, INTERVAL (i - 1) MONTH),
            v_emi, v_principal_comp, v_interest_comp,
            v_outstanding, 'Pending'
        );

        SET i = i + 1;
    END WHILE;
END$$

-- =============================================================================
-- sp_close_account: Safely close a bank account
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_close_account$$
CREATE PROCEDURE sp_close_account(
    IN  p_account_id    INT UNSIGNED,
    IN  p_closed_by     INT UNSIGNED,
    OUT p_status        VARCHAR(20),
    OUT p_message       VARCHAR(255)
)
BEGIN
    DECLARE v_balance   DECIMAL(15,2);
    DECLARE v_status    VARCHAR(20);
    DECLARE v_active_loans INT DEFAULT 0;
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Account closure failed.';
    END;

    START TRANSACTION;

    SELECT status, balance INTO v_status, v_balance
    FROM accounts WHERE account_id = p_account_id FOR UPDATE;

    IF v_status = 'Closed' THEN
        ROLLBACK;
        SET p_status = 'Failed'; SET p_message = 'Account is already closed.';
        LEAVE sp_close_account;
    END IF;

    -- Check for active loans on this account
    SELECT COUNT(*) INTO v_active_loans FROM loans
    WHERE account_id = p_account_id AND status IN ('Pending','Approved','Disbursed');

    IF v_active_loans > 0 THEN
        ROLLBACK;
        SET p_status = 'Failed';
        SET p_message = 'Cannot close account: Active loans exist.';
        LEAVE sp_close_account;
    END IF;

    -- Return remaining balance via withdrawal transaction
    IF v_balance > 0 THEN
        INSERT INTO transactions (
            reference_number, account_id, transaction_type, amount,
            balance_before, balance_after, description, channel, status
        ) VALUES (
            CONCAT('CLO', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s')),
            p_account_id, 'Withdrawal', v_balance,
            v_balance, 0.00, 'Account Closure - Balance Returned', 'Branch', 'Success'
        );

        UPDATE accounts SET balance = 0.00 WHERE account_id = p_account_id;
    END IF;

    UPDATE accounts SET status = 'Closed', closed_date = CURDATE()
    WHERE account_id = p_account_id;

    -- Block associated ATM cards
    UPDATE atm_cards SET status = 'Blocked', blocked_reason = 'Account Closed'
    WHERE account_id = p_account_id AND status = 'Active';

    INSERT INTO audit_logs (user_id, user_type, action, details, ip_address)
    VALUES (p_closed_by, 'Employee', 'ACCOUNT_CLOSED',
            CONCAT('Account ID: ', p_account_id, ' closed. Balance returned: ₹', v_balance),
            '127.0.0.1');

    COMMIT;

    SET p_status  = 'Success';
    SET p_message = 'Account closed successfully. Balance has been returned.';
END$$

-- =============================================================================
-- sp_generate_statement: Fetch account statement for a date range
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_generate_statement$$
CREATE PROCEDURE sp_generate_statement(
    IN p_account_id     INT UNSIGNED,
    IN p_from_date      DATE,
    IN p_to_date        DATE
)
BEGIN
    SELECT
        t.transaction_id,
        t.reference_number,
        DATE(t.created_at)      AS date,
        TIME(t.created_at)      AS time,
        t.transaction_type,
        t.description,
        IF(t.transaction_type IN ('Deposit','Transfer In','UPI Credit',
                                   'Interest Credit','Loan Disbursement','FD Maturity'),
           t.amount, NULL)       AS credit,
        IF(t.transaction_type IN ('Withdrawal','Transfer Out','UPI Debit',
                                   'EMI Debit','Fee Debit'),
           t.amount, NULL)       AS debit,
        t.balance_after         AS balance,
        t.channel,
        t.status
    FROM transactions t
    WHERE t.account_id = p_account_id
      AND DATE(t.created_at) BETWEEN p_from_date AND p_to_date
    ORDER BY t.created_at ASC;
END$$

-- =============================================================================
-- sp_calculate_interest: Calculate and credit interest to savings accounts
-- (Run periodically via scheduled job)
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_calculate_interest$$
CREATE PROCEDURE sp_calculate_interest()
BEGIN
    DECLARE v_done          INT DEFAULT 0;
    DECLARE v_account_id    INT UNSIGNED;
    DECLARE v_balance       DECIMAL(15,2);
    DECLARE v_rate          DECIMAL(5,2);
    DECLARE v_interest      DECIMAL(12,2);
    DECLARE v_ref_no        VARCHAR(30);

    DECLARE cur CURSOR FOR
        SELECT account_id, balance, interest_rate
        FROM accounts
        WHERE account_type = 'Savings'
          AND status = 'Active'
          AND interest_rate > 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur;

    calc_loop: LOOP
        FETCH cur INTO v_account_id, v_balance, v_rate;
        IF v_done = 1 THEN LEAVE calc_loop; END IF;

        -- Monthly interest = (balance * annual_rate) / 12 / 100
        SET v_interest = ROUND((v_balance * v_rate) / 12 / 100, 2);

        IF v_interest > 0 THEN
            SET v_ref_no = CONCAT('INT', DATE_FORMAT(NOW(), '%Y%m%d'), v_account_id);

            UPDATE accounts SET balance = balance + v_interest
            WHERE account_id = v_account_id;

            INSERT INTO transactions (
                reference_number, account_id, transaction_type, amount,
                balance_before, balance_after, description, channel, status
            ) VALUES (
                v_ref_no, v_account_id, 'Interest Credit', v_interest,
                v_balance, v_balance + v_interest,
                CONCAT('Monthly interest @ ', v_rate, '% p.a.'),
                'Internal', 'Success'
            );
        END IF;
    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

SELECT 'Stored procedures created successfully.' AS status;
