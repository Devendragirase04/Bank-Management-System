# =============================================================================
# Bank Management System - Loan Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class LoanRepository(BaseRepository):
    def __init__(self):
        super().__init__("loans")

class LoanService:
    def __init__(self):
        self.loan_repo = LoanRepository()

    def get_customer_loans(self, customer_id: int) -> List[Dict]:
        return self.loan_repo.find_all(where_clause="customer_id = %s", params=(customer_id,))
