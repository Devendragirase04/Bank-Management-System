# =============================================================================
# Bank Management System - Employee Module
# =============================================================================
# Description: Models and services for Employee management.
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository, QueryExecutor, AuditLogger
from utils import hash_password

class EmployeeRepository(BaseRepository):
    def __init__(self):
        super().__init__("employees")

    def find_by_username(self, username: str) -> Optional[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `username` = %s AND `is_active` = 1"
        return self.executor.execute_query(query, (username,), fetch_one=True)


class AdminRepository(BaseRepository):
    def __init__(self):
        super().__init__("admins")

    def find_by_username(self, username: str) -> Optional[Dict]:
        query = f"SELECT * FROM `{self.table_name}` WHERE `username` = %s AND `is_active` = 1"
        return self.executor.execute_query(query, (username,), fetch_one=True)


class EmployeeService:
    def __init__(self):
        self.employee_repo = EmployeeRepository()
        self.admin_repo = AdminRepository()

    def authenticate_admin(self, username: str) -> Optional[Dict]:
        return self.admin_repo.find_by_username(username)

    def authenticate_employee(self, username: str) -> Optional[Dict]:
        return self.employee_repo.find_by_username(username)

    def register_employee(self, data: Dict) -> bool:
        """Register a new employee with hashed password and generated code."""
        import datetime
        import random
        
        # Hash the password
        if 'password_hash' in data:
            data['password_hash'] = hash_password(data['password_hash'])
            
        # Generate employee_code (e.g., EMP + 6 random digits)
        data['employee_code'] = f"EMP{random.randint(100000, 999999)}"
        
        # Set joining_date if not provided
        if 'joining_date' not in data:
            data['joining_date'] = datetime.date.today().strftime("%Y-%m-%d")
            
        # Set default values
        data['is_active'] = 1
        
        try:
            self.employee_repo.insert(data)
            return True
        except Exception as e:
            import logging
            logging.getLogger(__name__).error(f"Error registering employee: {e}")
            return False

