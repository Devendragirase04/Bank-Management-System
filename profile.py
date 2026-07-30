# =============================================================================
# Bank Management System - User Profile
# =============================================================================

from database import QueryExecutor, AuditLogger

class ProfileService:
    @staticmethod
    def get_customer_profile(customer_id: int):
        """Fetches customer profile details."""
        query = "SELECT * FROM customers WHERE customer_id = %s"
        return QueryExecutor.execute_query(query, (customer_id,), fetch_one=True)
