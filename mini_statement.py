# =============================================================================
# Bank Management System - Mini Statement
# =============================================================================

from typing import Dict, List
from database import QueryExecutor

class StatementService:
    @staticmethod
    def get_mini_statement(account_id: int, limit: int = 10) -> List[Dict]:
        """Fetches the last N transactions for an account."""
        query = "SELECT * FROM view_recent_transactions WHERE account_id = %s LIMIT %s"
        return QueryExecutor.execute_query(query, (account_id, limit), fetch_all=True)
