# =============================================================================
# Bank Management System - Withdraw Transaction
# =============================================================================

from database import QueryExecutor, get_transaction, AuditLogger

class WithdrawService:
    @staticmethod
    def process_withdrawal(account_id: int, amount: float, description: str, employee_id: int = None) -> bool:
        """Processes a withdrawal transaction."""
        query = "CALL sp_process_transaction(%s, 'Withdrawal', %s, %s)"
        try:
            with get_transaction() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (account_id, amount, description))
                return True
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Withdrawal failed: {e}")
            return False
