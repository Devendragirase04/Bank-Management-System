# =============================================================================
# Bank Management System - Login Module
# =============================================================================
# Description: User login and authentication interface.
# =============================================================================

import tkinter as tk
import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from tkinter import messagebox

from config import (
    BANK_NAME, COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_TEXT_PRIMARY,
    COLOR_ACCENT_PRIMARY, FONT_HEADING_2, FONT_BODY, FONT_LABEL, FONT_BUTTON
)
from employee import EmployeeService
from customer import CustomerService
from utils import verify_password

class LoginView(ttk.Frame):
    def __init__(self, master, on_login_success, on_go_to_customer_register=None, on_go_to_employee_register=None):
        super().__init__(master, style="dark")
        self.master = master
        self.on_login_success = on_login_success
        self.on_go_to_customer_register = on_go_to_customer_register
        self.on_go_to_employee_register = on_go_to_employee_register
        self.employee_service = EmployeeService()
        self.customer_service = CustomerService()

        self.pack(fill=BOTH, expand=YES)
        self.create_widgets()

    def create_widgets(self):
        container = ttk.Frame(self)
        container.pack(fill=BOTH, expand=YES, padx=24, pady=24)

        shell = ttk.Frame(container)
        shell.pack(fill=BOTH, expand=YES)

        brand_panel = ttk.LabelFrame(shell, text="Banking Experience")
        brand_panel.pack(side=LEFT, fill=Y, padx=(0, 16))

        brand_panel.columnconfigure(0, weight=1)
        brand_panel.rowconfigure(0, weight=1)

        ttk.Label(
            brand_panel,
            text=BANK_NAME,
            font=FONT_HEADING_2,
            foreground=COLOR_ACCENT_PRIMARY,
            justify=CENTER
        ).pack(anchor=W, pady=(0, 8))

        ttk.Label(
            brand_panel,
            text="A secure digital banking platform for customers, staff, and branch operations.",
            font=FONT_BODY,
            foreground=COLOR_TEXT_PRIMARY,
            wraplength=360,
            justify=LEFT
        ).pack(anchor=W, pady=(0, 18))

        stats = ttk.Frame(brand_panel)
        stats.pack(fill=X)

        self._stat_card(stats, "24/7", "Access")
        self._stat_card(stats, "1.8K+", "Customers")
        self._stat_card(stats, "100%", "Secure")

        login_panel = ttk.LabelFrame(shell, text="Secure Sign In")
        login_panel.pack(side=RIGHT, fill=BOTH, expand=YES)

        login_panel.columnconfigure(0, weight=1)

        ttk.Label(
            login_panel,
            text="Sign in to your account",
            font=FONT_HEADING_2,
            foreground=COLOR_TEXT_PRIMARY,
            justify=CENTER
        ).pack(pady=(0, 12))

        ttk.Label(login_panel, text="Username", font=FONT_LABEL).pack(anchor=W, pady=(0, 5))
        self.username_var = tk.StringVar()
        self.username_entry = ttk.Entry(
            login_panel, textvariable=self.username_var, font=FONT_BODY, width=30
        )
        self.username_entry.pack(fill=X, pady=(0, 15))

        ttk.Label(login_panel, text="Password", font=FONT_LABEL).pack(anchor=W, pady=(0, 5))
        self.password_var = tk.StringVar()
        self.password_entry = ttk.Entry(
            login_panel, textvariable=self.password_var, font=FONT_BODY, show="*", width=30
        )
        self.password_entry.pack(fill=X, pady=(0, 20))

        ttk.Button(
            login_panel,
            text="Login",
            style=PRIMARY,
            width=30,
            command=self.handle_login
        ).pack(fill=X, pady=(0, 15), ipady=5)

        reg_frame = ttk.Frame(login_panel)
        reg_frame.pack(fill=X, pady=(10, 0))

        ttk.Label(reg_frame, text="Don't have an account?", font=FONT_BODY).pack(anchor=CENTER, pady=(0, 8))

        reg_buttons = ttk.Frame(reg_frame)
        reg_buttons.pack(fill=X)

        if self.on_go_to_customer_register:
            ttk.Button(
                reg_buttons,
                text="Register as Customer",
                style=LINK,
                command=self.on_go_to_customer_register
            ).pack(side=LEFT, expand=YES, padx=(0, 8))

        if self.on_go_to_employee_register:
            ttk.Button(
                reg_buttons,
                text="Register as Employee",
                style=LINK,
                command=self.on_go_to_employee_register
            ).pack(side=RIGHT, expand=YES)

    def _stat_card(self, parent, value, title):
        card = ttk.LabelFrame(parent, text=title)
        card.pack(side=LEFT, fill=BOTH, expand=YES, padx=(0, 8))
        ttk.Label(card, text=value, font=FONT_HEADING_2, foreground=COLOR_ACCENT_PRIMARY).pack(anchor=CENTER)

    def handle_login(self):
        username = self.username_var.get().strip()
        password = self.password_var.get().strip()

        if not username or not password:
            messagebox.showwarning("Validation Error", "Username and password are required.")
            return

        # 1. Check Admin
        admin = self.employee_service.authenticate_admin(username)
        if admin and verify_password(password, admin['password_hash']):
            self.on_login_success(admin, "Admin")
            return

        # 2. Check Employee
        employee = self.employee_service.authenticate_employee(username)
        if employee and verify_password(password, employee['password_hash']):
            self.on_login_success(employee, "Employee")
            return
            
        # 3. Check Customer
        customer = self.customer_service.authenticate_customer(username)
        if customer and verify_password(password, customer['password_hash']):
            self.on_login_success(customer, "Customer")
            return

        messagebox.showerror("Authentication Failed", "Invalid username or password.")
