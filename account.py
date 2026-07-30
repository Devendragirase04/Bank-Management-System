# =============================================================================
# Bank Management System - Account Module
# =============================================================================
# Description: Models and services for Account management.
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository, QueryExecutor, AuditLogger

class AccountRepository(BaseRepository):
    def __init__(self):
        super().__init__("accounts")

    def find_by_customer_id(self, customer_id: int) -> List[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `customer_id` = %s"
        return self.executor.execute_query(query, (customer_id,), fetch_all=True)

    def find_by_account_number(self, account_number: str) -> Optional[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `account_number` = %s"
        return self.executor.execute_query(query, (account_number,), fetch_one=True)

class AccountService:
    def __init__(self):
        self.account_repo = AccountRepository()

    def get_customer_accounts(self, customer_id: int) -> List[Dict]:
        return self.account_repo.find_by_customer_id(customer_id)

    def get_account_details(self, account_number: str) -> Optional[Dict]:
        return self.account_repo.find_by_account_number(account_number)
