# =============================================================================
# Bank Management System - Beneficiary Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class BeneficiaryRepository(BaseRepository):
    def __init__(self):
        super().__init__("beneficiaries")

class BeneficiaryService:
    def __init__(self):
        self.beneficiary_repo = BeneficiaryRepository()

    def get_customer_beneficiaries(self, customer_id: int) -> List[Dict]:
        return self.beneficiary_repo.find_all(where_clause="customer_id = %s", params=(customer_id,))
