# =============================================================================
# Bank Management System - Card Module
# =============================================================================

from typing import Dict, List, Optional
from database import BaseRepository

class CardRepository(BaseRepository):
    def __init__(self):
        super().__init__("atm_cards")

class CardService:
    def __init__(self):
        self.card_repo = CardRepository()

    def get_account_cards(self, account_id: int) -> List[Dict]:
        return self.card_repo.find_all(where_clause="account_id = %s", params=(account_id,))
