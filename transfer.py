# =============================================================================
# Bank Management System - Transfer Transaction
# =============================================================================

from database import QueryExecutor, get_transaction, AuditLogger

class TransferService:
    @staticmethod
    def process_transfer(from_account: int, to_account: int, amount: float, description: str) -> bool:
        """Processes a fund transfer."""
        query = "CALL sp_fund_transfer(%s, %s, %s, %s)"
        try:
            with get_transaction() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (from_account, to_account, amount, description))
                return True
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Transfer failed: {e}")
            return False
