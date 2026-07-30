-- =============================================================================
-- Bank Management System - Database Functions
-- =============================================================================
USE BankDB;

DELIMITER $$

-- =============================================================================
-- fn_get_age: Calculate age in years from date of birth
-- =============================================================================
DROP FUNCTION IF EXISTS fn_get_age$$
CREATE FUNCTION fn_get_age(p_dob DATE)
RETURNS TINYINT UNSIGNED
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_dob, CURDATE());
END$$

-- =============================================================================
-- fn_is_account_active: Check if an account can process transactions
-- =============================================================================
DROP FUNCTION IF EXISTS fn_is_account_active$$
CREATE FUNCTION fn_is_account_active(p_account_id INT UNSIGNED)
RETURNS TINYINT(1)
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status
    FROM accounts
    WHERE account_id = p_account_id;
    RETURN IF(v_status = 'Active', 1, 0);
END$$

-- =============================================================================
-- fn_calculate_loan_emi: Standard loan EMI calculation
-- =============================================================================
DROP FUNCTION IF EXISTS fn_calculate_loan_emi$$
CREATE FUNCTION fn_calculate_loan_emi(
    p_principal     DECIMAL(15,2),
    p_annual_rate   DECIMAL(5,2),
    p_months        SMALLINT UNSIGNED
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_monthly_rate DECIMAL(15,8);
    DECLARE v_emi          DECIMAL(12,2);

    IF p_annual_rate = 0 THEN
        RETURN ROUND(p_principal / p_months, 2);
    END IF;

    SET v_monthly_rate = p_annual_rate / (12.0 * 100.0);
    SET v_emi = p_principal
                * (v_monthly_rate * POW(1 + v_monthly_rate, p_months))
                / (POW(1 + v_monthly_rate, p_months) - 1);
    RETURN ROUND(v_emi, 2);
END$$

-- =============================================================================
-- fn_calculate_fd_maturity: Calculate FD maturity amount
-- =============================================================================
DROP FUNCTION IF EXISTS fn_calculate_fd_maturity$$
CREATE FUNCTION fn_calculate_fd_maturity(
    p_principal     DECIMAL(15,2),
    p_annual_rate   DECIMAL(5,2),
    p_months        SMALLINT UNSIGNED,
    p_frequency     TINYINT UNSIGNED  -- 1=yearly, 2=half-yearly, 4=quarterly, 12=monthly
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE v_t  DECIMAL(8,4);
    DECLARE v_r  DECIMAL(8,6);
    DECLARE v_maturity DECIMAL(15,2);

    SET v_t = p_months / 12.0;
    SET v_r = p_annual_rate / 100.0;
    -- Compound interest: A = P * (1 + r/n)^(n*t)
    SET v_maturity = p_principal * POW((1 + v_r / p_frequency), (p_frequency * v_t));
    RETURN ROUND(v_maturity, 2);
END$$

-- =============================================================================
-- fn_generate_account_number: Create unique account number
-- Returns a 16-digit number with bank prefix
-- =============================================================================
DROP FUNCTION IF EXISTS fn_generate_account_number$$
CREATE FUNCTION fn_generate_account_number()
RETURNS VARCHAR(16)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_acc_no VARCHAR(16);
    DECLARE v_exists TINYINT DEFAULT 1;

    WHILE v_exists = 1 DO
        SET v_acc_no = CONCAT(
            'APXB',
            LPAD(FLOOR(RAND() * 999), 3, '0'),
            LPAD(FLOOR(RAND() * 999999999), 9, '0')
        );
        SELECT COUNT(*) INTO v_exists
        FROM accounts
        WHERE account_number = v_acc_no;
    END WHILE;

    RETURN v_acc_no;
END$$

-- =============================================================================
-- fn_generate_card_number: Generate Luhn-valid 16-digit card number
-- =============================================================================
DROP FUNCTION IF EXISTS fn_generate_card_number$$
CREATE FUNCTION fn_generate_card_number(p_prefix CHAR(1))
RETURNS VARCHAR(16)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_digits     VARCHAR(15);
    DECLARE v_total      INT DEFAULT 0;
    DECLARE v_digit      INT;
    DECLARE v_check      INT;
    DECLARE v_card_no    VARCHAR(16);
    DECLARE v_exists     TINYINT DEFAULT 1;
    DECLARE i            INT;

    WHILE v_exists = 1 DO
        SET v_digits = CONCAT(p_prefix, LPAD(FLOOR(RAND() * 100000000000000), 14, '0'));
        -- Luhn algorithm
        SET v_total = 0;
        SET i = 1;
        WHILE i <= 15 DO
            SET v_digit = CAST(SUBSTRING(v_digits, 16 - i, 1) AS UNSIGNED);
            IF i % 2 = 1 THEN
                SET v_digit = v_digit * 2;
                IF v_digit > 9 THEN SET v_digit = v_digit - 9; END IF;
            END IF;
            SET v_total = v_total + v_digit;
            SET i = i + 1;
        END WHILE;
        SET v_check  = (10 - (v_total % 10)) % 10;
        SET v_card_no = CONCAT(v_digits, v_check);

        SELECT COUNT(*) INTO v_exists
        FROM atm_cards
        WHERE card_number = v_card_no;
    END WHILE;

    RETURN v_card_no;
END$$

-- =============================================================================
-- fn_mask_account: Return masked account number (show last 4 digits)
-- =============================================================================
DROP FUNCTION IF EXISTS fn_mask_account$$
CREATE FUNCTION fn_mask_account(p_account_no VARCHAR(20))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_len INT;
    SET v_len = CHAR_LENGTH(p_account_no);
    IF v_len <= 4 THEN
        RETURN REPEAT('X', v_len);
    END IF;
    RETURN CONCAT(REPEAT('X', v_len - 4), RIGHT(p_account_no, 4));
END$$

-- =============================================================================
-- fn_get_account_balance: Get current account balance (safe read)
-- =============================================================================
DROP FUNCTION IF EXISTS fn_get_account_balance$$
CREATE FUNCTION fn_get_account_balance(p_account_id INT UNSIGNED)
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE v_balance DECIMAL(15,2) DEFAULT 0.00;
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;
    RETURN COALESCE(v_balance, 0.00);
END$$

DELIMITER ;

SELECT 'Functions created successfully.' AS status;
