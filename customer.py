# =============================================================================
# Bank Management System - Customer Module
# =============================================================================
# Description: Models and services for Customer management.
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository, QueryExecutor, AuditLogger

from utils import hash_password

class CustomerRepository(BaseRepository):
    def __init__(self):
        super().__init__("customers")

    def find_by_username(self, username: str) -> Optional[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `username` = %s AND `is_active` = 1"
        return self.executor.execute_query(query, (username,), fetch_one=True)

class CustomerService:
    def __init__(self):
        self.customer_repo = CustomerRepository()

    def authenticate_customer(self, username: str) -> Optional[Dict]:
        return self.customer_repo.find_by_username(username)

    def register_customer(self, data: Dict) -> bool:
        """Register a new customer with hashed password and generated code."""
        import random
        
        # Hash the password
        if 'password_hash' in data:
            data['password_hash'] = hash_password(data['password_hash'])
            
        # Generate customer_code (e.g., CUST + 6 random digits)
        data['customer_code'] = f"CUST{random.randint(100000, 999999)}"
        
        # Set default values
        data['is_active'] = 1
        
        try:
            self.customer_repo.insert(data)
            return True
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Error registering customer: {e}")
            return False
