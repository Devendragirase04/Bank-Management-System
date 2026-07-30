# =============================================================================
# Bank Management System - ATM Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class ATMRepository(BaseRepository):
    def __init__(self):
        super().__init__("atms") # Assuming there's an ATMs table, or it can be a service
        
class ATMService:
    def __init__(self):
        self.atm_repo = ATMRepository()

    def get_branch_atms(self, branch_id: int) -> List[Dict]:
        return self.atm_repo.find_all(where_clause="branch_id = %s", params=(branch_id,))
