# =============================================================================
# Bank Management System - UPI Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class UPIRepository(BaseRepository):
    def __init__(self):
        super().__init__("upi_accounts")

class UPIService:
    def __init__(self):
        self.upi_repo = UPIRepository()

    def get_customer_upi(self, customer_id: int) -> List[Dict]:
        return self.upi_repo.find_all(where_clause="customer_id = %s", params=(customer_id,))
