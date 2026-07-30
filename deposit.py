# =============================================================================
# Bank Management System - Deposit Transaction
# =============================================================================

from database import QueryExecutor, get_transaction, AuditLogger

class DepositService:
    @staticmethod
    def process_deposit(account_id: int, amount: float, description: str, employee_id: int = None) -> bool:
        """Processes a deposit transaction."""
        query = "CALL sp_process_transaction(%s, 'Deposit', %s, %s)"
        try:
            with get_transaction() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (account_id, amount, description))
                return True
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Deposit failed: {e}")
            return False
