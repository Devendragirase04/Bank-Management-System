# =============================================================================
# Bank Management System - Change PIN / Password
# =============================================================================

from database import QueryExecutor, get_transaction, AuditLogger
from utils import hash_password, verify_password

class AuthUpdateService:
    @staticmethod
    def change_customer_password(customer_id: int, new_password: str) -> bool:
        """Updates customer password."""
        query = "UPDATE customers SET password_hash = %s WHERE customer_id = %s"
        try:
            QueryExecutor.execute_query(query, (hash_password(new_password), customer_id))
            return True
        except Exception as e:
            return False
