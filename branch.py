# =============================================================================
# Bank Management System - Branch Module
# =============================================================================
# Description: Models and services for Branch management.
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class BranchRepository(BaseRepository):
    def __init__(self):
        super().__init__("branches")

    def find_by_ifsc(self, ifsc_code: str) -> Optional[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `ifsc_code` = %s"
        return self.executor.execute_query(query, (ifsc_code,), fetch_one=True)

class BranchService:
    def __init__(self):
        self.branch_repo = BranchRepository()

    def get_all_branches(self) -> List[Dict]:
        return self.branch_repo.find_all(order_by="branch_name ASC")

    def get_branch_by_ifsc(self, ifsc_code: str) -> Optional[Dict]:
        return self.branch_repo.find_by_ifsc(ifsc_code)
