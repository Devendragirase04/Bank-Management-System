# =============================================================================
# Bank Management System - Main Application
# =============================================================================
# Description: Main entry point for the application. Sets up the Tkinter 
#              window, initializes the database connection, and manages views.
# =============================================================================

import sys
import logging
import tkinter as tk
import ttkbootstrap as ttk
from ttkbootstrap.constants import *

from config import (
    APP_NAME, APP_VERSION, WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT,
    BANK_NAME, BANK_TAGLINE, COLOR_BG_PRIMARY, COLOR_BG_SECONDARY,
    COLOR_ACCENT_PRIMARY, COLOR_ACCENT_SECONDARY, COLOR_TEXT_PRIMARY,
    FONT_HEADING_2, FONT_BODY, FONT_LABEL
)
from database import initialize_pool
from login import LoginView

# Set up logging
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s | %(levelname)-8s | %(module)s:%(lineno)d | %(message)s"
)
logger = logging.getLogger(__name__)

class MainApp(ttk.Window):
    def __init__(self):
        super().__init__(themename="darkly", title=f"{APP_NAME} v{APP_VERSION}")
        self.geometry(f"{WINDOW_MIN_WIDTH}x{WINDOW_MIN_HEIGHT}")
        self.minsize(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT)
        self.configure(bg=COLOR_BG_PRIMARY)

        app_style = ttk.Style()
        app_style.configure("TFrame", background=COLOR_BG_PRIMARY)
        app_style.configure("TLabel", foreground=COLOR_TEXT_PRIMARY, background=COLOR_BG_PRIMARY)
        app_style.configure("TButton", font=("Segoe UI", 11, "bold"))
        app_style.map(
            "TButton",
            background=[("active", COLOR_ACCENT_SECONDARY), ("!disabled", COLOR_ACCENT_PRIMARY)],
            foreground=[("!disabled", "white")]
        )

        self.sidebar = ttk.Frame(self, width=260)
        self.sidebar.pack(side=LEFT, fill=Y)
        self.sidebar.pack_propagate(False)

        self.content_frame = ttk.Frame(self)
        self.content_frame.pack(side=LEFT, fill=BOTH, expand=YES)
        self.content_frame.pack_propagate(False)

        self.current_view = None
        self.user = None
        self.user_role = None

        self._build_sidebar()
        self.initialize_system()
        self.show_splash()

    def _build_sidebar(self):
        ttk.Label(
            self.sidebar,
            text=BANK_NAME,
            font=("Segoe UI", 20, "bold"),
            foreground=COLOR_ACCENT_PRIMARY,
            justify=CENTER
        ).pack(pady=(24, 8), padx=16)

        ttk.Label(
            self.sidebar,
            text=BANK_TAGLINE,
            font=("Segoe UI", 10),
            foreground="#9fb0ca",
            wraplength=220,
            justify=CENTER
        ).pack(padx=16, pady=(0, 18))

        self.nav_buttons = {}
        self._add_nav_button("Overview", self.show_admin_dashboard, style=SUCCESS)
        self._add_nav_button("Analytics", self.show_analytics_dashboard, style=INFO)
        self._add_nav_button("Customers", self.show_customer_dashboard, style=SECONDARY)
        self._add_nav_button("Employees", self.show_employee_dashboard, style=SECONDARY)
        self._add_nav_button("Logout", self.logout, style=DANGER)

        self._set_sidebar_for_guest()

    def _add_nav_button(self, label, command, style=PRIMARY):
        btn = ttk.Button(self.sidebar, text=label, style=style, command=command)
        btn.pack(fill=X, padx=18, pady=6)
        self.nav_buttons[label] = btn

    def _set_sidebar_for_guest(self):
        for key, button in self.nav_buttons.items():
            if key == "Logout":
                button.configure(state="disabled")
            else:
                button.configure(state="disabled")

    def _set_sidebar_for_user(self):
        for key, button in self.nav_buttons.items():
            if key == "Logout":
                button.configure(state="normal")
            elif self.user_role == "Admin" and key in {"Overview", "Analytics", "Logout"}:
                button.configure(state="normal")
            elif self.user_role == "Employee" and key in {"Overview", "Customers", "Logout"}:
                button.configure(state="normal")
            elif self.user_role == "Customer" and key in {"Overview", "Analytics", "Logout"}:
                button.configure(state="normal")
            else:
                button.configure(state="disabled")

    def initialize_system(self):
        try:
            logger.info("Initializing system...")
            initialize_pool()
            logger.info("Database pool initialized successfully.")
        except Exception as e:
            logger.critical(f"System initialization failed: {e}")
            from tkinter import messagebox
            messagebox.showerror(
                "Initialization Error", 
                f"Failed to connect to the database.\n{e}"
            )
            sys.exit(1)

    def switch_view(self, view_class, **kwargs):
        if self.current_view:
            self.current_view.destroy()

        self.deiconify()
        self.content_frame.pack(fill=BOTH, expand=YES)
        self.current_view = view_class(self.content_frame, **kwargs)
        self.current_view.pack(fill=BOTH, expand=YES)
        self.update_idletasks()

    def show_splash(self):
        if self.current_view:
            self.current_view.destroy()

        self.current_view = ttk.Frame(self)
        self.current_view.pack(fill=BOTH, expand=YES)

        splash_shell = ttk.LabelFrame(self.current_view, text=BANK_NAME)
        splash_shell.pack(expand=YES, padx=80, pady=80)
        splash_shell.pack_configure(padx=80, pady=80)

        ttk.Label(
            splash_shell,
            text="",
            font=FONT_BODY
        ).pack(pady=14)

        ttk.Label(
            splash_shell,
            text=BANK_NAME,
            font=FONT_HEADING_2,
            foreground=COLOR_ACCENT_PRIMARY,
            justify=CENTER
        ).pack(pady=(0, 8))

        ttk.Label(
            splash_shell,
            text=BANK_TAGLINE,
            font=FONT_BODY,
            foreground=COLOR_TEXT_PRIMARY,
            justify=CENTER
        ).pack(pady=(0, 20))

        ttk.Label(
            splash_shell,
            text="Launching secure digital banking experience...",
            font=FONT_BODY,
            foreground="#9fb0ca",
            justify=CENTER
        ).pack()

        self.after(1400, self.show_login)

    def show_login(self):
        self.user = None
        self.user_role = None
        self.deiconify()
        self._set_sidebar_for_guest()
        self.switch_view(
            LoginView,
            on_login_success=self.handle_login_success,
            on_go_to_customer_register=self.show_customer_registration,
            on_go_to_employee_register=self.show_employee_registration
        )

    def show_customer_registration(self):
        from register import CustomerRegisterView
        self.switch_view(
            CustomerRegisterView,
            on_register_success=self.show_login,
            on_back=self.show_login
        )

    def show_employee_registration(self):
        from register import EmployeeRegisterView
        self.switch_view(
            EmployeeRegisterView,
            on_register_success=self.show_login,
            on_back=self.show_login
        )

    def handle_login_success(self, user_data, role):
        self.user = user_data
        self.user_role = role
        logger.info(f"User {user_data['username']} logged in as {role}")
        self._set_sidebar_for_user()

        if role == "Admin":
            self.show_admin_dashboard()
        elif role == "Employee":
            self.show_employee_dashboard()
        elif role == "Customer":
            self.show_customer_dashboard()

    def show_admin_dashboard(self):
        # We will import these inline to avoid circular dependencies
        from admin_dashboard import AdminDashboard
        self.switch_view(AdminDashboard, user=self.user, app=self)

    def show_employee_dashboard(self):
        from employee_dashboard import EmployeeDashboard
        self.switch_view(EmployeeDashboard, user=self.user, app=self)

    def show_customer_dashboard(self):
        from customer_dashboard import CustomerDashboard
        self.switch_view(CustomerDashboard, user=self.user, app=self)

    def show_analytics_dashboard(self):
        from analytics_dashboard import AnalyticsDashboardView
        self.deiconify()
        self.switch_view(AnalyticsDashboardView, user=self.user, app=self)

    def logout(self):
        if self.user:
            logger.info(f"User {self.user['username']} logged out.")
        self.user = None
        self.user_role = None
        self._set_sidebar_for_guest()
        self.show_login()

if __name__ == "__main__":
    app = MainApp()
    app.mainloop()
