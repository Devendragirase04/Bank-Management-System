# =============================================================================
# Bank Management System - Fixed Deposit Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class FDRepository(BaseRepository):
    def __init__(self):
        super().__init__("fixed_deposits")

class FDService:
    def __init__(self):
        self.fd_repo = FDRepository()

    def get_customer_fds(self, customer_id: int) -> List[Dict]:
        return self.fd_repo.find_all(where_clause="customer_id = %s", params=(customer_id,))
