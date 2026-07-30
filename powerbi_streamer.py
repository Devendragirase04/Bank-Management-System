# =============================================================================
# Bank Management System - Power BI Real-Time Data Streamer & Connector
# =============================================================================
# Description: Real-Time streamer for Power BI Dashboards.
#              Supports both direct database snapshot generation for DirectQuery
#              and live streaming push to Power BI REST API endpoints.
# =============================================================================

import os
import sys
import time
import json
import logging
import argparse
from datetime import datetime, date
from decimal import Decimal
import urllib.request
import urllib.error

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database import get_db_connection
from db_config import DB_CONFIG

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(message)s"
)
logger = logging.getLogger("PowerBIStreamer")


class DecimalEncoder(json.JSONEncoder):
    """JSON Encoder that handles Decimal and datetime objects."""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        return super().default(obj)


def fetch_realtime_kpis() -> dict:
    """Fetch high-level real-time banking KPIs for Power BI."""
    sql = """
        SELECT 
            (SELECT COUNT(*) FROM customers) AS total_customers,
            (SELECT COUNT(*) FROM accounts WHERE status = 'Active') AS active_accounts,
            (SELECT COALESCE(SUM(balance), 0) FROM accounts) AS total_deposits,
            (SELECT COUNT(*) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_transactions,
            (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE DATE(created_at) = CURDATE()) AS today_volume,
            NOW() AS timestamp
    """
    with get_db_connection() as conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql)
        res = cursor.fetchone()
        return res or {}


def fetch_recent_transactions(limit: int = 50) -> list:
    """Fetch recent live transactions for Power BI streaming."""
    view_sql = """
        SELECT 
            transaction_id,
            reference_number,
            transaction_type,
            amount,
            account_number,
            customer_name,
            branch_name,
            txn_date AS transaction_date,
            txn_status AS status,
            channel
        FROM v_transaction_detail
        ORDER BY txn_date DESC
        LIMIT %s
    """
    direct_sql = """
        SELECT 
            t.transaction_id,
            t.reference_number,
            t.transaction_type,
            t.amount,
            a.account_number,
            c.full_name AS customer_name,
            b.branch_name,
            t.created_at AS transaction_date,
            t.status,
            t.channel
        FROM transactions t
        JOIN accounts a ON t.account_id = a.account_id
        JOIN customers c ON a.customer_id = c.customer_id
        JOIN branches b ON a.branch_id = b.branch_id
        ORDER BY t.created_at DESC
        LIMIT %s
    """
    with get_db_connection() as conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute(view_sql, (limit,))
            return cursor.fetchall() or []
        except Exception:
            cursor.execute(direct_sql, (limit,))
            return cursor.fetchall() or []


def fetch_branch_performance() -> list:
    """Fetch live branch performance metrics."""
    view_sql = """
        SELECT 
            branch_id,
            branch_name,
            total_accounts,
            total_balance,
            total_loans,
            active_customers
        FROM v_branch_performance
    """
    direct_sql = """
        SELECT 
            b.branch_id,
            b.branch_name,
            COUNT(DISTINCT a.account_id) AS total_accounts,
            COALESCE(SUM(a.balance), 0) AS total_balance,
            0 AS total_loans,
            COUNT(DISTINCT a.customer_id) AS active_customers
        FROM branches b
        LEFT JOIN accounts a ON b.branch_id = a.branch_id
        GROUP BY b.branch_id, b.branch_name
    """
    with get_db_connection() as conn:
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute(view_sql)
            return cursor.fetchall() or []
        except Exception:
            cursor.execute(direct_sql)
            return cursor.fetchall() or []




def push_to_powerbi_stream(push_url: str, payload: list) -> bool:
    """
    Push streaming payload to Power BI REST API Real-Time Streaming Endpoint.
    
    Args:
        push_url: The Power BI Streaming Dataset Push URL created in Power BI Service.
        payload: List of dictionary records matching the Power BI Dataset Schema.
    """
    try:
        data_bytes = json.dumps(payload, cls=DecimalEncoder).encode('utf-8')
        req = urllib.request.Request(
            push_url,
            data=data_bytes,
            headers={'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status in (200, 201, 202):
                logger.info(f"Successfully pushed {len(payload)} records to Power BI Streaming API.")
                return True
            else:
                logger.warning(f"Power BI API returned status code: {response.status}")
                return False
    except urllib.error.URLError as e:
        logger.error(f"Failed to push data to Power BI API: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error while streaming to Power BI: {e}")
        return False


def export_powerbi_snapshots(output_dir: str = "exports"):
    """Export current real-time data snapshots to JSON files for file-based Power BI refresh."""
    os.makedirs(output_dir, exist_ok=True)
    
    kpis = fetch_realtime_kpis()
    txs = fetch_recent_transactions(100)
    branches = fetch_branch_performance()
    
    snapshot_file = os.path.join(output_dir, "powerbi_realtime_snapshot.json")
    data = {
        "generated_at": datetime.now().isoformat(),
        "kpis": kpis,
        "recent_transactions": txs,
        "branch_performance": branches
    }
    
    with open(snapshot_file, "w", encoding="utf-8") as f:
        json.dump(data, f, cls=DecimalEncoder, indent=2)
        
    logger.info(f"Power BI Snapshot successfully written to: {snapshot_file}")
    return snapshot_file


def simulate_live_traffic(interval: float = 3.0, count: int = 10, push_url: str = None):
    """
    Simulate live deposit/withdrawal activity into BankDB and push updates to Power BI.
    Allows testing real-time visual updates in Power BI DirectQuery / Streaming mode.
    """
    import random
    import uuid
    logger.info(f"Starting Real-Time Banking Activity Simulator ({count} events, interval {interval}s)...")
    
    with get_db_connection() as conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT account_number FROM accounts WHERE status='Active' LIMIT 20")
        accounts = [r['account_number'] for r in cursor.fetchall()]
        
    if not accounts:
        logger.error("No active accounts found in database to perform real-time simulation!")
        return

    for i in range(1, count + 1):
        account_no = random.choice(accounts)
        tx_type = random.choice(["Deposit", "Withdrawal", "UPI Credit", "Transfer Out"])
        amount = Decimal(str(round(random.uniform(100.0, 5000.0), 2)))
        ref_no = f"TXN{datetime.now().strftime('%Y%m%d%H%M%S')}{random.randint(1000, 9999)}"
        
        try:
            with get_db_connection() as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute("SELECT account_id, balance FROM accounts WHERE account_number = %s", (account_no,))
                acc = cursor.fetchone()
                if not acc:
                    continue
                
                account_id = acc['account_id']
                bal_before = acc['balance']
                
                if tx_type in ("Deposit", "UPI Credit"):
                    bal_after = bal_before + amount
                else:
                    bal_after = max(Decimal("0.00"), bal_before - amount)
                    
                cursor.execute("UPDATE accounts SET balance = %s WHERE account_id = %s", (bal_after, account_id))
                
                cursor.execute("""
                    INSERT INTO transactions 
                    (reference_number, account_id, transaction_type, amount, balance_before, balance_after, description, channel, status)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, 'Mobile', 'Success')
                """, (ref_no, account_id, tx_type, amount, bal_before, bal_after, f"Live PowerBI Test Tx #{i}"))
                conn.commit()
                
            logger.info(f"[{i}/{count}] Simulated Tx: {tx_type} | Account: {account_no} | Amount: ₹{amount} | Ref: {ref_no}")
            
            # If Push URL is specified, stream immediately
            if push_url:
                kpi_data = fetch_realtime_kpis()
                push_to_powerbi_stream(push_url, [kpi_data])
                
        except Exception as e:
            logger.error(f"Simulation error on iteration {i}: {e}")
            
        time.sleep(interval)

    logger.info("Real-Time Simulation Complete!")



def main():
    parser = argparse.ArgumentParser(description="Bank Management System - Power BI Real-Time Data Streamer")
    parser.add_argument("--test", action="store_true", help="Test database connection and query live KPIs")
    parser.add_argument("--snapshot", action="store_true", help="Export latest data snapshot to JSON for Power BI")
    parser.add_argument("--stream-url", type=str, help="Power BI Real-Time Push Dataset REST API Endpoint URL")
    parser.add_argument("--simulate", action="store_true", help="Simulate real-time live transactions to update Power BI")
    parser.add_argument("--interval", type=float, default=2.0, help="Simulation time interval in seconds (default: 2.0s)")
    parser.add_argument("--count", type=int, default=15, help="Number of simulated transactions to execute")
    
    args = parser.parse_args()

    if args.test:
        logger.info("Testing MySQL Database Connection for Power BI...")
        try:
            kpis = fetch_realtime_kpis()
            logger.info("Successfully fetched live KPIs from BankDB:")
            print(json.dumps(kpis, cls=DecimalEncoder, indent=2))
            
            recent = fetch_recent_transactions(5)
            logger.info(f"Recent 5 Transactions (total fetched): {len(recent)}")
            print(json.dumps(recent, cls=DecimalEncoder, indent=2))
        except Exception as e:
            logger.error(f"Test connection failed: {e}")
            sys.exit(1)
            
    elif args.snapshot:
        export_powerbi_snapshots()

    elif args.simulate:
        simulate_live_traffic(interval=args.interval, count=args.count, push_url=args.stream_url)

    else:
        # Default behavior if no args: perform test and export snapshot
        logger.info("No explicit flag provided. Running test and creating snapshot...")
        export_powerbi_snapshots()


if __name__ == "__main__":
    main()
