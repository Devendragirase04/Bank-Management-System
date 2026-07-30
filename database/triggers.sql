-- =============================================================================
-- Bank Management System - Triggers
-- =============================================================================
-- Covers: automatic audit logging, balance validation, card expiry check,
--         dormancy detection, notification creation, and FD maturity trigger.
-- =============================================================================
USE BankDB;

DELIMITER $$

-- =============================================================================
-- TRIGGER: After INSERT on transactions - update account balance & notify
-- =============================================================================
DROP TRIGGER IF EXISTS trg_after_transaction_insert$$
CREATE TRIGGER trg_after_transaction_insert
    AFTER INSERT ON transactions
    FOR EACH ROW
BEGIN
    -- Update account's last transaction date
    UPDATE accounts
    SET last_txn_date = DATE(NEW.created_at)
    WHERE account_id = NEW.account_id;

    -- Create notification for customer (only on success)
    IF NEW.status = 'Success' THEN
        INSERT INTO notifications (customer_id, title, message, notif_type, related_txn_id, created_at)
        SELECT
            a.customer_id,
            CONCAT(NEW.transaction_type, ' Alert'),
            CONCAT(
                'Your account ', a.account_number,
                ' has been ', LOWER(NEW.transaction_type), 'd with ₹',
                FORMAT(NEW.amount, 2),
                '. Available balance: ₹', FORMAT(NEW.balance_after, 2),
                '. Ref: ', NEW.reference_number
            ),
            'Transaction',
            NEW.transaction_id,
            NOW()
        FROM accounts a
        WHERE a.account_id = NEW.account_id;
    END IF;
END$$

-- =============================================================================
-- TRIGGER: Before INSERT on transactions - validate account status and balance
-- =============================================================================
DROP TRIGGER IF EXISTS trg_before_transaction_insert$$
CREATE TRIGGER trg_before_transaction_insert
    BEFORE INSERT ON transactions
    FOR EACH ROW
BEGIN
    DECLARE v_acc_status VARCHAR(20);
    DECLARE v_balance    DECIMAL(15,2);
    DECLARE v_min_bal    DECIMAL(10,2);

    SELECT status, balance, min_balance
    INTO v_acc_status, v_balance, v_min_bal
    FROM accounts
    WHERE account_id = NEW.account_id;

    -- Block transactions on non-active accounts
    IF v_acc_status NOT IN ('Active') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction blocked: Account is not active.';
    END IF;

    -- Check sufficient balance for debits
    IF NEW.transaction_type IN ('Withdrawal', 'Transfer Out', 'UPI Debit',
                                 'EMI Debit', 'Fee Debit') THEN
        IF (v_balance - NEW.amount) < v_min_bal THEN
            SIGNAL SQLSTATE '45001'
            SET MESSAGE_TEXT = 'Insufficient balance: Would fall below minimum required balance.';
        END IF;
    END IF;
END$$

-- =============================================================================
-- TRIGGER: After UPDATE on accounts - detect dormancy
-- =============================================================================
DROP TRIGGER IF EXISTS trg_after_account_update$$
CREATE TRIGGER trg_after_account_update
    AFTER UPDATE ON accounts
    FOR EACH ROW
BEGIN
    -- Log status changes
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_logs (user_id, user_type, action, details, ip_address, status)
        VALUES (
            0, 'System',
            'ACCOUNT_STATUS_CHANGE',
            CONCAT('Account ', NEW.account_number, ': ', OLD.status, ' → ', NEW.status),
            '127.0.0.1',
            'Success'
        );
    END IF;
END$$

-- =============================================================================
-- TRIGGER: Before INSERT on accounts - auto-set opened_date and min_balance
-- =============================================================================
DROP TRIGGER IF EXISTS trg_before_account_insert$$
CREATE TRIGGER trg_before_account_insert
    BEFORE INSERT ON accounts
    FOR EACH ROW
BEGIN
    -- Set opened_date to today if not specified
    IF NEW.opened_date IS NULL THEN
        SET NEW.opened_date = CURDATE();
    END IF;

    -- Apply minimum balance rules by account type
    IF NEW.account_type = 'Savings' AND NEW.min_balance < 1000 THEN
        SET NEW.min_balance = 1000.00;
    ELSEIF NEW.account_type = 'Current' AND NEW.min_balance < 5000 THEN
        SET NEW.min_balance = 5000.00;
    ELSEIF NEW.account_type = 'Salary' THEN
        SET NEW.min_balance = 0.00;
    END IF;
END$$

-- =============================================================================
-- TRIGGER: After UPDATE on loans - audit status changes
-- =============================================================================
DROP TRIGGER IF EXISTS trg_after_loan_update$$
CREATE TRIGGER trg_after_loan_update
    AFTER UPDATE ON loans
    FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_logs (user_id, user_type, action, details, ip_address, status)
        VALUES (
            COALESCE(NEW.approved_by, 0), 'Employee',
            'LOAN_STATUS_CHANGE',
            CONCAT('Loan ', NEW.loan_account_no, ': ', OLD.status, ' → ', NEW.status),
            '127.0.0.1',
            'Success'
        );

        -- Notify customer on loan status change
        IF NEW.status IN ('Approved', 'Rejected', 'Disbursed') THEN
            INSERT INTO notifications (customer_id, title, message, notif_type)
            VALUES (
                NEW.customer_id,
                CONCAT('Loan ', NEW.status),
                CONCAT(
                    'Your ', NEW.loan_type, ' application (',
                    NEW.loan_account_no, ') has been ', LOWER(NEW.status), '.',
                    IF(NEW.status = 'Disbursed',
                       CONCAT(' EMI of ₹', FORMAT(NEW.emi_amount, 2), ' starts from ', NEW.first_emi_date),
                       COALESCE(CONCAT(' Reason: ', NEW.rejection_reason), ''))
                ),
                'Info'
            );
        END IF;
    END IF;
END$$

-- =============================================================================
-- TRIGGER: Before INSERT on fixed_deposits - set maturity date
-- =============================================================================
DROP TRIGGER IF EXISTS trg_before_fd_insert$$
CREATE TRIGGER trg_before_fd_insert
    BEFORE INSERT ON fixed_deposits
    FOR EACH ROW
BEGIN
    -- Auto-compute maturity date if not set
    IF NEW.maturity_date IS NULL THEN
        SET NEW.maturity_date = DATE_ADD(NEW.start_date, INTERVAL NEW.tenure_months MONTH);
    END IF;

    -- Auto-compute maturity amount if not set
    IF NEW.maturity_amount IS NULL OR NEW.maturity_amount = 0 THEN
        SET NEW.maturity_amount = fn_calculate_fd_maturity(
            NEW.principal, NEW.interest_rate, NEW.tenure_months, 4
        );
        SET NEW.interest_earned = NEW.maturity_amount - NEW.principal;
    END IF;
END$$

-- =============================================================================
-- TRIGGER: After INSERT on customers - create welcome notification
-- =============================================================================
DROP TRIGGER IF EXISTS trg_after_customer_insert$$
CREATE TRIGGER trg_after_customer_insert
    AFTER INSERT ON customers
    FOR EACH ROW
BEGIN
    INSERT INTO notifications (customer_id, title, message, notif_type)
    VALUES (
        NEW.customer_id,
        'Welcome to Apex National Bank!',
        CONCAT(
            'Dear ', NEW.full_name, ', welcome to Apex National Bank! ',
            'Your Customer ID is: ', NEW.customer_code, '. ',
            'Please complete your KYC to unlock all banking features.'
        ),
        'System'
    );
END$$

-- =============================================================================
-- TRIGGER: After INSERT on atm_cards - notify customer
-- =============================================================================
DROP TRIGGER IF EXISTS trg_after_card_insert$$
CREATE TRIGGER trg_after_card_insert
    AFTER INSERT ON atm_cards
    FOR EACH ROW
BEGIN
    INSERT INTO notifications (customer_id, title, message, notif_type)
    SELECT
        a.customer_id,
        'New ATM Card Issued',
        CONCAT(
            'A new ', NEW.card_type, ' card (', NEW.card_network, ') ending in ',
            RIGHT(NEW.card_number, 4), ' has been issued to your account.'
        ),
        'Info'
    FROM accounts a
    WHERE a.account_id = NEW.account_id;
END$$

-- =============================================================================
-- TRIGGER: Before DELETE on customers - prevent deletion of customers with active accounts
-- =============================================================================
DROP TRIGGER IF EXISTS trg_before_customer_delete$$
CREATE TRIGGER trg_before_customer_delete
    BEFORE DELETE ON customers
    FOR EACH ROW
BEGIN
    DECLARE v_active_accounts INT DEFAULT 0;

    SELECT COUNT(*) INTO v_active_accounts
    FROM accounts
    WHERE customer_id = OLD.customer_id
      AND status = 'Active';

    IF v_active_accounts > 0 THEN
        SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Cannot delete customer: Active accounts exist. Close all accounts first.';
    END IF;
END$$

DELIMITER ;

SELECT 'Triggers created successfully.' AS status;
