# =============================================================================
# Bank Management System - Reports
# =============================================================================

from typing import Dict, List
from database import QueryExecutor
from utils import export_to_pdf, export_to_excel, export_to_csv

class ReportService:
    @staticmethod
    def generate_transaction_report(account_id: int, file_format: str = "pdf") -> str:
        """Generates a full transaction report."""
        query = "SELECT * FROM transactions WHERE account_id = %s ORDER BY created_at DESC"
        data = QueryExecutor.execute_query(query, (account_id,), fetch_all=True)
        
        if not data:
            raise ValueError("No transactions found.")

        if file_format.lower() == "pdf":
            return export_to_pdf(data, f"account_{account_id}_statement", "Transaction Statement")
        elif file_format.lower() == "excel":
            return export_to_excel(data, f"account_{account_id}_statement")
        else:
            return export_to_csv(data, f"account_{account_id}_statement")
