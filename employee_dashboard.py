# =============================================================================
# Bank Management System - Employee Dashboard
# =============================================================================

import tkinter as tk
import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from config import FONT_HEADING_2, FONT_BODY

class EmployeeDashboard(ttk.Frame):
    def __init__(self, master, user, app):
        super().__init__(master)
        self.master = master
        self.user = user
        self.app = app
        
        self.pack(fill=BOTH, expand=YES)
        self.create_widgets()

    def create_widgets(self):
        ttk.Label(self, text=f"Welcome Employee, {self.user['full_name']}", font=FONT_HEADING_2).pack(pady=20)
        
        ttk.Button(self, text="Logout", style=DANGER, command=self.app.logout).pack(pady=10)
