# =============================================================================
# Bank Management System - Admin Dashboard
# =============================================================================

import tkinter as tk
import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from config import (
    FONT_HEADING_2, FONT_BODY, FONT_HEADING_3,
    COLOR_BG_PRIMARY, COLOR_BG_SECONDARY, COLOR_ACCENT_PRIMARY,
    COLOR_ACCENT_SECONDARY, COLOR_ACCENT_SUCCESS, COLOR_TEXT_PRIMARY
)

class AdminDashboard(ttk.Frame):
    def __init__(self, master, user, app):
        super().__init__(master)
        self.master = master
        self.user = user
        self.app = app

        self.configure(style="TFrame")
        self.pack(fill=BOTH, expand=YES, padx=24, pady=24)
        self.create_widgets()

    def create_widgets(self):
        hero = ttk.LabelFrame(self, text="Executive Overview")
        hero.pack(fill=X, pady=(0, 18))
        hero.pack_propagate(False)

        ttk.Label(
            hero,
            text=f"Welcome Admin, {self.user['full_name']}",
            font=FONT_HEADING_2,
            foreground="#ffffff"
        ).pack(anchor=W)

        ttk.Label(
            hero,
            text="Monitor branch performance, customer activity, and banking analytics from one premium control panel.",
            font=FONT_BODY,
            wraplength=720,
            justify=LEFT,
            foreground="#cfd8e3"
        ).pack(anchor=W, pady=(8, 12))

        quick_cards = ttk.Frame(hero)
        quick_cards.pack(fill=X)

        self._info_card(quick_cards, "Branch Efficiency", "89%", "Operational stability")
        self._info_card(quick_cards, "Live Portfolio", "1.8k+", "Customers & accounts")
        self._info_card(quick_cards, "Analyst Ready", "Live", "Downloadable reports")

        actions = ttk.Frame(self)
        actions.pack(fill=X, pady=(0, 12))

        ttk.Button(
            actions,
            text="View Analytics & Reports",
            style=SUCCESS,
            command=self.app.show_analytics_dashboard
        ).pack(side=LEFT, padx=(0, 12))

        ttk.Button(actions, text="Logout", style=DANGER, command=self.app.logout).pack(side=LEFT)

    def _info_card(self, parent, title, value, subtitle):
        card = ttk.LabelFrame(parent, text=title)
        card.pack(side=LEFT, padx=(0, 12), fill=BOTH, expand=YES)
        ttk.Label(card, text=value, font=FONT_HEADING_3, foreground="#ffffff").pack(anchor=W)
        ttk.Label(card, text=subtitle, font=FONT_BODY, foreground="#9fb0ca").pack(anchor=W, pady=(6, 0))
