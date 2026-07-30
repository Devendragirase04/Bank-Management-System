"""
Synthetic data generation script for Bank Management System analytics.
Generates realistic branch, customer, account, and transaction data compatible
with the current schema so the analytics dashboard can operate on a larger dataset.
"""

import random
from datetime import datetime, timedelta
from decimal import Decimal

from faker import Faker

from database import get_db_connection
from db_config import DB_CONFIG
from utils import hash_password

fake = Faker("en_IN")

NUM_BRANCHES = 10
NUM_CUSTOMERS = 500
NUM_EMPLOYEES = 30
NUM_ACCOUNTS = 500
NUM_TRANSACTIONS = 3000


def build_branch_records(existing_branch_codes=None):
    records = []
    existing_branch_codes = set(existing_branch_codes or [])
    next_branch_code = 1000
    for index in range(NUM_BRANCHES):
        city = fake.city()
        state = fake.state()
        while True:
            branch_code = f"BR{next_branch_code:03d}"
            if branch_code not in existing_branch_codes:
                existing_branch_codes.add(branch_code)
                break
            next_branch_code += 1
        next_branch_code += 1
        records.append(
            (
                f"{city} Branch",
                branch_code,
                f"APXB{random.randint(1000000, 9999999)}",
                fake.street_address(),
                fake.street_name() or "",
                city,
                state,
                fake.postcode(),
                fake.phone_number()[:15],
                fake.email(),
                fake.name(),
                fake.date_between(start_date="-15y", end_date="-1y"),
            )
        )
    return records


def build_customer_records(branch_ids, existing_customer_codes=None):
    records = []
    existing_customer_codes = set(existing_customer_codes or [])
    password_hash = hash_password("Password@123")
    for index in range(NUM_CUSTOMERS):
        gender = random.choice(["Male", "Female", "Other"])
        dob = fake.date_of_birth(minimum_age=18, maximum_age=80)
        while True:
            customer_code = f"C{fake.unique.random_number(digits=8)}"
            if customer_code not in existing_customer_codes:
                existing_customer_codes.add(customer_code)
                break
        full_name = fake.name()
        email = fake.unique.email()
        phone = fake.unique.msisdn()[:10]
        pan = fake.bothify(text="?????####?").upper()
        aadhar = str(fake.unique.random_number(digits=12))
        records.append(
            (
                customer_code,
                full_name,
                fake.first_name_male() if gender == "Male" else fake.first_name_female() if gender == "Female" else fake.first_name(),
                fake.first_name_female() if gender in {"Male", "Female"} else fake.first_name(),
                dob,
                gender,
                random.choice(["Single", "Married", "Divorced", "Widowed"]),
                "Indian",
                email,
                phone,
                fake.phone_number()[:15],
                pan,
                aadhar,
                fake.street_address(),
                fake.street_name() or "",
                fake.city(),
                fake.state(),
                fake.postcode(),
                random.choice(["Salaried", "Business Owner", "Self Employed", "Professional"]),
                Decimal(random.randint(200000, 2500000)),
                random.randint(650, 850),
                "Verified",
                fake.date_between(start_date="-3y", end_date="today"),
                f"user{index}_{fake.unique.random_number(digits=5)}",
                password_hash,
                random.choice(branch_ids),
            )
        )
    return records


def build_employee_records(branch_ids, existing_employee_codes=None):
    records = []
    existing_employee_codes = set(existing_employee_codes or [])
    password_hash = hash_password("Password@123")
    next_employee_code = 1000
    for index in range(NUM_EMPLOYEES):
        branch_id = random.choice(branch_ids)
        role_id = random.choice([2, 3, 4])
        gender = random.choice(["Male", "Female", "Other"])
        dob = fake.date_of_birth(minimum_age=22, maximum_age=65)
        while True:
            employee_code = f"EMPX{next_employee_code:03d}"
            if employee_code not in existing_employee_codes:
                existing_employee_codes.add(employee_code)
                break
            next_employee_code += 1
        next_employee_code += 1
        full_name = fake.name()
        email = fake.unique.email()
        phone = fake.unique.msisdn()[:10]
        pan = fake.bothify(text="?????####?").upper()
        aadhar = str(fake.unique.random_number(digits=12))
        designation = random.choice(["Branch Manager", "Cashier", "Loan Officer", "Operations Officer"])
        department = random.choice(["Management", "Operations", "Credit", "Support"])
        username = f"empx.{full_name.lower().replace(' ', '.')}"[:30]
        records.append(
            (
                employee_code,
                branch_id,
                role_id,
                full_name,
                fake.first_name_male() if gender == "Male" else fake.first_name_female() if gender == "Female" else fake.first_name(),
                dob,
                gender,
                email,
                phone,
                fake.phone_number()[:15],
                pan,
                aadhar,
                fake.street_address(),
                fake.street_name() or "",
                fake.city(),
                fake.state(),
                fake.postcode(),
                designation,
                department,
                fake.date_between(start_date="-10y", end_date="today"),
                Decimal(random.randint(30000, 140000)),
                username,
                password_hash,
            )
        )
    return records


def build_account_records(customer_rows):
    records = []
    for customer_id, branch_id in customer_rows:
        account_type = random.choice(["Savings", "Current"])
        balance = Decimal(random.randint(1500, 295000))
        records.append(
            (
                f"APXB{fake.unique.random_number(digits=12)}",
                customer_id,
                branch_id,
                account_type,
                balance,
                Decimal(1000 if account_type == "Savings" else 5000),
                "Active",
                fake.date_between(start_date="-5y", end_date="today"),
            )
        )
    return records


def generate_transactions(cursor, account_rows):
    print(f"Generating {NUM_TRANSACTIONS} transactions...")
    account_balances = {row[0]: Decimal(row[1]) for row in account_rows}
    txn_types = [
        ("Deposit", "Branch", "Deposit"),
        ("Withdrawal", "ATM", "Withdrawal"),
        ("Transfer In", "Net Banking", "Transfer"),
        ("Transfer Out", "Mobile", "Transfer"),
        ("UPI Credit", "UPI", "UPI"),
        ("UPI Debit", "UPI", "UPI"),
    ]

    for index in range(NUM_TRANSACTIONS):
        account_id = random.choice(account_rows)[0]
        txn_type, channel, description = random.choice(txn_types)
        amount = Decimal(random.randint(50, 2500))
        current_balance = account_balances[account_id]

        if txn_type in {"Withdrawal", "Transfer Out", "UPI Debit"}:
            amount = min(amount, current_balance)
            balance_before = current_balance
            balance_after = current_balance - amount
        else:
            balance_before = current_balance
            balance_after = current_balance + amount

        account_balances[account_id] = balance_after
        reference_number = f"TXN{fake.unique.random_number(digits=10)}"
        created_at = fake.date_time_between(start_date="-1y", end_date="now")

        cursor.execute(
            """
            INSERT INTO transactions (
                reference_number, account_id, transaction_type, amount,
                balance_before, balance_after, description, channel, status, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                reference_number,
                account_id,
                txn_type,
                amount,
                balance_before,
                balance_after,
                description,
                channel,
                "Success",
                created_at,
            ),
        )

        cursor.execute(
            "UPDATE accounts SET balance = %s, last_txn_date = %s WHERE account_id = %s",
            (balance_after, created_at.date(), account_id),
        )


def run():
    print("Starting synthetic data generation...")
    with get_db_connection() as conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT branch_code FROM branches")
            existing_branch_codes = {row[0] for row in cursor.fetchall()}
            cursor.execute("SELECT employee_code FROM employees")
            existing_employee_codes = {row[0] for row in cursor.fetchall()}
            cursor.execute("SELECT customer_code FROM customers")
            existing_customer_codes = {row[0] for row in cursor.fetchall()}

            branch_records = build_branch_records(existing_branch_codes)
            cursor.executemany(
                """
                INSERT INTO branches (
                    branch_name, branch_code, ifsc_code, address_line1, address_line2,
                    city, state, pincode, phone, email, manager_name, established_date
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                branch_records,
            )
            conn.commit()

            cursor.execute("SELECT branch_id FROM branches")
            branch_ids = [row[0] for row in cursor.fetchall()]

            employee_records = build_employee_records(branch_ids, existing_employee_codes)
            cursor.executemany(
                """
                INSERT INTO employees (
                    employee_code, branch_id, role_id, full_name, father_name,
                    date_of_birth, gender, email, phone, alt_phone, pan_number,
                    aadhar_number, address_line1, address_line2, city, state,
                    pincode, designation, department, joining_date, salary,
                    username, password_hash
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                employee_records,
            )
            conn.commit()

            customer_records = build_customer_records(branch_ids, existing_customer_codes)
            cursor.executemany(
                """
                INSERT INTO customers (
                    customer_code, full_name, father_name, mother_name, date_of_birth,
                    gender, marital_status, nationality, email, phone, alt_phone,
                    pan_number, aadhar_number, address_line1, address_line2, city,
                    state, pincode, occupation, annual_income, credit_score,
                    kyc_status, kyc_date, username, password_hash, branch_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                customer_records,
            )
            conn.commit()

            cursor.execute("SELECT customer_id, branch_id FROM customers")
            customer_rows = cursor.fetchall()
            account_records = build_account_records(customer_rows)
            cursor.executemany(
                """
                INSERT INTO accounts (
                    account_number, customer_id, branch_id, account_type, balance,
                    min_balance, status, opened_date
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                account_records,
            )
            conn.commit()

            cursor.execute("SELECT account_id, balance FROM accounts WHERE status = 'Active'")
            account_rows = cursor.fetchall()
            generate_transactions(cursor, account_rows)
            conn.commit()
            print("Data generation complete.")
        except Exception as exc:
            conn.rollback()
            print(f"Data generation failed: {exc}")
            raise
        finally:
            cursor.close()


if __name__ == "__main__":
    run()
