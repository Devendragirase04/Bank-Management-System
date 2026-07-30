# =============================================================================
# Bank Management System - Analytics Dashboard
# =============================================================================

import os
import tkinter as tk
from datetime import datetime, date
from pathlib import Path

import ttkbootstrap as ttk
from ttkbootstrap.constants import *
from ttkbootstrap.widgets import DateEntry
import pandas as pd
import matplotlib
matplotlib.use("TkAgg")
import seaborn as sns
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
from tkinter import filedialog, messagebox

from config import FONT_HEADING_2, FONT_BODY, EXPORTS_DIR
from database import get_db_connection
from utils import export_to_pdf


class AnalyticsDashboardView(ttk.Frame):
    def __init__(self, master, user=None, app=None):
        super().__init__(master)
        self.master = master
        self.user = user
        self.app = app
        self.pack(fill=BOTH, expand=YES)

        self.chart_canvas_list = []
        self.summary_df = pd.DataFrame()
        self.monthly_df = pd.DataFrame()
        self.branch_df = pd.DataFrame()

        self.branch_var = tk.StringVar(value="All Branches")
        self.period_var = tk.StringVar(value="All Time")
        self.start_date_var = tk.StringVar(value="")
        self.end_date_var = tk.StringVar(value="")
        self.last_refreshed_var = tk.StringVar(value="Not refreshed yet")

        # Apply seaborn styling
        sns.set_theme(style="darkgrid", palette="muted")
        sns.set_palette("husl")

        self.create_widgets()
        self.load_analytics()

    def create_widgets(self):
        header_frame = ttk.Frame(self)
        header_frame.pack(fill=X, pady=(0, 15))

        ttk.Button(
            header_frame,
            text="← Back to Admin",
            style=SECONDARY,
            command=self.app.show_admin_dashboard if self.app else None
        ).pack(side=LEFT)

        ttk.Label(
            header_frame,
            text="Analytics & Reports",
            font=FONT_HEADING_2
        ).pack(side=LEFT, padx=(15, 0))

        controls_frame = ttk.LabelFrame(self, text="Filters")
        controls_frame.pack(fill=X, pady=(0, 12))
        controls_frame.pack_propagate(False)

        ttk.Label(controls_frame, text="Branch:").grid(row=0, column=0, sticky=W, padx=(12, 6), pady=(12, 8))
        self.branch_combo = ttk.Combobox(
            controls_frame,
            textvariable=self.branch_var,
            width=24,
            state="readonly"
        )
        self.branch_combo.grid(row=0, column=1, sticky=EW, padx=(0, 12), pady=(12, 8))

        ttk.Label(controls_frame, text="Period:").grid(row=0, column=2, sticky=W, padx=(0, 6), pady=(12, 8))
        self.period_combo = ttk.Combobox(
            controls_frame,
            textvariable=self.period_var,
            width=18,
            state="readonly",
            values=["All Time", "Last 30 Days", "Last 90 Days", "Last 180 Days", "Custom Range"]
        )
        self.period_combo.grid(row=0, column=3, sticky=EW, padx=(0, 12), pady=(12, 8))

        ttk.Label(controls_frame, text="Start Date:").grid(row=0, column=4, sticky=W, padx=(0, 6), pady=(12, 8))
        self.start_date_entry = DateEntry(controls_frame, width=14, dateformat="%Y-%m-%d")
        self.start_date_entry.entry.configure(textvariable=self.start_date_var, width=14)
        self.start_date_entry.grid(row=0, column=5, sticky=EW, padx=(0, 12), pady=(12, 8))

        ttk.Label(controls_frame, text="End Date:").grid(row=0, column=6, sticky=W, padx=(0, 6), pady=(12, 8))
        self.end_date_entry = DateEntry(controls_frame, width=14, dateformat="%Y-%m-%d")
        self.end_date_entry.entry.configure(textvariable=self.end_date_var, width=14)
        self.end_date_entry.grid(row=0, column=7, sticky=EW, padx=(0, 12), pady=(12, 8))

        action_frame = ttk.Frame(controls_frame)
        action_frame.grid(row=0, column=8, sticky=EW, padx=(0, 12), pady=(12, 8))

        ttk.Button(
            action_frame,
            text="Refresh",
            style=PRIMARY,
            command=self.load_analytics
        ).pack(side=LEFT, padx=(0, 8))

        ttk.Button(
            action_frame,
            text="CSV",
            style=SUCCESS,
            command=self.download_dashboard_csv
        ).pack(side=LEFT, padx=(0, 8))

        ttk.Button(
            action_frame,
            text="PNG",
            style=SECONDARY,
            command=self.download_dashboard_png
        ).pack(side=LEFT, padx=(0, 8))

        ttk.Button(
            action_frame,
            text="PDF",
            style=INFO,
            command=self.download_dashboard_pdf
        ).pack(side=LEFT, padx=(0, 8))

        ttk.Button(
            action_frame,
            text="Interactive",
            style=PRIMARY,
            command=self.open_interactive_charts
        ).pack(side=LEFT)

        self.last_refresh_label = ttk.Label(controls_frame, textvariable=self.last_refreshed_var)
        self.last_refresh_label.grid(row=1, column=0, columnspan=10, sticky=W, padx=12, pady=(0, 12))

        for column in range(10):
            controls_frame.grid_columnconfigure(column, weight=1)

        self.summary_frame = ttk.Frame(self)
        self.summary_frame.pack(fill=X, pady=(5, 10))

        self.highlight_frame = ttk.LabelFrame(self, text="KPI Highlights")
        self.highlight_frame.pack(fill=X, pady=(0, 10))

        self.history_frame = ttk.LabelFrame(self, text="Saved Reports")
        self.history_frame.pack(fill=X, pady=(0, 10))

        self.chart_frame = ttk.Frame(self)
        self.chart_frame.pack(fill=BOTH, expand=YES)
        self.chart_frame.grid_columnconfigure(0, weight=1)
        self.chart_frame.grid_columnconfigure(1, weight=1)
        self.chart_frame.grid_columnconfigure(2, weight=1)

    def _metric_card(self, title, value, subtitle="", parent=None):
        parent = parent or self.summary_frame
        card = ttk.LabelFrame(parent, text=title)
        card.pack(side=LEFT, padx=(0, 12), fill=BOTH, expand=YES)
        ttk.Label(card, text=value, font=FONT_HEADING_2).pack(anchor=W, padx=12, pady=(12, 4))
        if subtitle:
            ttk.Label(card, text=subtitle, font=FONT_BODY).pack(anchor=W, padx=12, pady=(0, 12))
        return card

    def _refresh_report_history(self):
        for widget in self.history_frame.winfo_children():
            widget.destroy()

        EXPORTS_DIR.mkdir(parents=True, exist_ok=True)
        recent_files = sorted(EXPORTS_DIR.glob("*"), key=lambda p: p.stat().st_mtime, reverse=True)[:6]

        if not recent_files:
            ttk.Label(self.history_frame, text="No exports yet. Use the dashboard download buttons.").pack(anchor=W, padx=12, pady=12)
            return

        for export_file in recent_files:
            file_row = ttk.Frame(self.history_frame)
            file_row.pack(fill=X, padx=12, pady=(0, 8))
            ttk.Label(file_row, text=export_file.name, font=FONT_BODY).pack(side=LEFT)
            ttk.Label(file_row, text=f"{export_file.stat().st_size / 1024:.1f} KB", font=FONT_BODY).pack(side=RIGHT)

    def _format_currency(self, amount):
        try:
            return f"₹{float(amount):,.0f}"
        except Exception:
            return "₹0"

    def _fetch_dataframe(self, conn, query, params=None):
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute(query, params or ())
            rows = cursor.fetchall()
            return pd.DataFrame(rows)
        finally:
            cursor.close()

    def _parse_date(self, date_str):
        """Try multiple date formats to parse DateEntry value reliably."""
        if not date_str or not date_str.strip():
            return None
        date_str = date_str.strip()
        formats = ["%m/%d/%Y", "%d/%m/%Y", "%Y-%m-%d", "%m-%d-%Y", "%d-%m-%d",
                   "%m/%d/%y", "%d/%m/%y", "%Y/%m/%d", "%Y-%m-%d"]
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt).strftime("%Y-%m-%d")
            except ValueError:
                continue
        return None

    def _build_filters(self):
        period = self.period_var.get()
        branch = self.branch_var.get()
        where_clauses = ["t.status = 'Success'"]
        params = []

        if period == "Last 30 Days":
            where_clauses.append("t.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)")
        elif period == "Last 90 Days":
            where_clauses.append("t.created_at >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)")
        elif period == "Last 180 Days":
            where_clauses.append("t.created_at >= DATE_SUB(CURDATE(), INTERVAL 180 DAY)")
        elif period == "Custom Range":
            # Only read DateEntry values when Custom Range is explicitly selected
            try:
                sd = self.start_date_entry.entry.get()
                parsed = self._parse_date(sd)
                if parsed:
                    where_clauses.append("DATE(t.created_at) >= %s")
                    params.append(parsed)
            except Exception:
                pass
            try:
                ed = self.end_date_entry.entry.get()
                parsed = self._parse_date(ed)
                if parsed:
                    where_clauses.append("DATE(t.created_at) <= %s")
                    params.append(parsed)
            except Exception:
                pass

        if branch and branch != "All Branches":
            where_clauses.append("c.branch_id = %s")
            params.append(self._branch_lookup.get(branch))

        return " AND ".join(where_clauses), params

    def _populate_branch_filter(self, branch_df):
        branches = ["All Branches"] + branch_df["branch_name"].tolist()
        self._branch_lookup = {
            row["branch_name"]: row["branch_id"] for _, row in branch_df.iterrows()
        }
        self.branch_combo.configure(values=branches)
        if self.branch_var.get() not in branches:
            self.branch_var.set("All Branches")

    def load_analytics(self):
        try:
            with get_db_connection() as conn:
                branch_lookup_df = self._fetch_dataframe(
                    conn,
                    "SELECT branch_id, branch_name FROM branches ORDER BY branch_name"
                )
                self._populate_branch_filter(branch_lookup_df)

                filter_clause, filter_params = self._build_filters()

                summary_query = f"""
                    SELECT
                        COUNT(*) AS total_transactions,
                        COALESCE(SUM(CASE WHEN t.transaction_type IN ('Deposit','UPI Credit','Transfer In','Interest Credit') THEN t.amount ELSE 0 END), 0) AS total_deposit,
                        COALESCE(SUM(CASE WHEN t.transaction_type IN ('Withdrawal','UPI Debit','Transfer Out','EMI Debit','Fee Debit') THEN t.amount ELSE 0 END), 0) AS total_withdrawal
                    FROM transactions t
                    JOIN accounts a ON a.account_id = t.account_id
                    JOIN customers c ON c.customer_id = a.customer_id
                    WHERE {filter_clause}
                """
                self.summary_df = self._fetch_dataframe(conn, summary_query, filter_params)

                monthly_query = f"""
                    SELECT
                        DATE_FORMAT(t.created_at, '%Y-%m') AS month,
                        COUNT(*) AS transaction_count,
                        SUM(t.amount) AS monthly_volume
                    FROM transactions t
                    JOIN accounts a ON a.account_id = t.account_id
                    JOIN customers c ON c.customer_id = a.customer_id
                    WHERE {filter_clause}
                    GROUP BY DATE_FORMAT(t.created_at, '%Y-%m')
                    ORDER BY month ASC
                """
                self.monthly_df = self._fetch_dataframe(conn, monthly_query, filter_params)

                branch_query = """
                    SELECT
                        b.branch_name,
                        COUNT(c.customer_id) AS customer_count
                    FROM branches b
                    LEFT JOIN customers c ON c.branch_id = b.branch_id
                    GROUP BY b.branch_name
                    ORDER BY customer_count DESC
                """
                if self.branch_var.get() and self.branch_var.get() != "All Branches":
                    branch_query = """
                        SELECT
                            b.branch_name,
                            COUNT(c.customer_id) AS customer_count
                        FROM branches b
                        LEFT JOIN customers c ON c.branch_id = b.branch_id
                        WHERE b.branch_id = %s
                        GROUP BY b.branch_name
                        ORDER BY customer_count DESC
                    """
                    branch_params = [self._branch_lookup[self.branch_var.get()]]
                else:
                    branch_params = []

                self.branch_df = self._fetch_dataframe(
                    conn,
                    branch_query,
                    branch_params
                )

            summary_row = self.summary_df.iloc[0] if not self.summary_df.empty else None
            if summary_row is None:
                return

            self.summary_frame.destroy()
            self.summary_frame = ttk.Frame(self)
            self.summary_frame.pack(fill=X, pady=(5, 10))

            net_flow = float(summary_row["total_deposit"]) - float(summary_row["total_withdrawal"])
            self._metric_card(
                "Total Transactions",
                str(int(summary_row["total_transactions"])),
                "Successful activity across the bank database"
            )
            self._metric_card(
                "Total Deposits",
                self._format_currency(summary_row["total_deposit"]),
                "Inbound funds volume"
            )
            self._metric_card(
                "Total Withdrawals",
                self._format_currency(summary_row["total_withdrawal"]),
                "Outbound funds volume"
            )
            self._metric_card(
                "Net Flow",
                self._format_currency(net_flow),
                f"Selected window: {self.period_var.get()}"
            )

            highlight_parent = self.highlight_frame
            for child in highlight_parent.winfo_children():
                child.destroy()

            if not self.monthly_df.empty:
                highest_month = self.monthly_df.loc[self.monthly_df["monthly_volume"].idxmax()]
                peak_month_value = self._format_currency(highest_month["monthly_volume"])
            else:
                peak_month_value = "₹0"

            self._metric_card(
                "Peak Month",
                str(highest_month["month"]) if not self.monthly_df.empty else "N/A",
                f"Volume {peak_month_value}",
                parent=highlight_parent
            )
            self._metric_card(
                "Active Branches",
                str(len(self.branch_df)) if not self.branch_df.empty else "0",
                "Branch coverage in current report",
                parent=highlight_parent
            )
            self._metric_card(
                "Net Flow",
                self._format_currency(net_flow),
                "Current filtered view",
                parent=highlight_parent
            )

            self._draw_bar_chart(summary_row)
            self._draw_line_chart(self.monthly_df)
            self._draw_pie_chart(self.branch_df)
            self.last_refreshed_var.set(f"Last refreshed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            self._refresh_report_history()

        except Exception as exc:
            messagebox.showerror("Analytics Error", f"Unable to load analytics data.\n{exc}")

    def _clear_chart_canvases(self):
        for canvas in self.chart_canvas_list:
            canvas.get_tk_widget().destroy()
        self.chart_canvas_list.clear()

        for child in self.chart_frame.winfo_children():
            child.destroy()

    def _draw_bar_chart(self, summary_row):
        self._clear_chart_canvases()

        bar_frame = ttk.LabelFrame(self.chart_frame, text="Deposit vs Withdrawal Volume")
        bar_frame.grid(row=0, column=0, sticky=NSEW, padx=(0, 10), pady=10)

        figure = Figure(figsize=(4.8, 3.4), dpi=100, facecolor="#1a1f2e")
        axis = figure.add_subplot(111, facecolor="#1a1f2e")
        categories = ["Deposits", "Withdrawals"]
        values = [float(summary_row["total_deposit"]), float(summary_row["total_withdrawal"])]
        sns_palette = sns.color_palette(["#2ecc71", "#e74c3c"])
        bars = axis.bar(categories, values, color=sns_palette, edgecolor="#ffffff", linewidth=0.5)
        axis.set_ylabel("Amount (₹)", color="#e8eaf0")
        axis.set_title("Volume by Flow Type", color="#e8eaf0", fontweight="bold")
        axis.tick_params(colors="#9ba3b5")
        axis.spines["top"].set_visible(False)
        axis.spines["right"].set_visible(False)
        axis.spines["left"].set_color("#2d3448")
        axis.spines["bottom"].set_color("#2d3448")
        axis.grid(True, axis="y", linestyle="--", alpha=0.2, color="#2d3448")

        annotation = axis.annotate(
            "",
            xy=(0, 0),
            xytext=(10, 10),
            textcoords="offset points",
            bbox=dict(boxstyle="round,pad=0.2", fc="#1e1e1e", ec="#808080", alpha=0.85),
            color="#ffffff"
        )
        annotation.set_visible(False)

        def _bar_hover(event):
            if event.inaxes != axis:
                annotation.set_visible(False)
                figure.canvas.draw_idle()
                return

            for bar in bars:
                bar.set_alpha(0.9)

            if event.xdata is not None:
                idx = int(round(event.xdata))
                if 0 <= idx < len(categories):
                    label = categories[idx]
                    value = values[idx]
                    annotation.set_text(f"{label}: ₹{value:,.0f}")
                    annotation.set_position((event.xdata, event.ydata))
                    annotation.set_visible(True)
                    figure.canvas.draw_idle()

        figure.canvas.mpl_connect("motion_notify_event", _bar_hover)

        canvas = FigureCanvasTkAgg(figure, master=bar_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=BOTH, expand=YES)
        toolbar = NavigationToolbar2Tk(canvas, bar_frame)
        toolbar.update()
        toolbar.pack(side=BOTTOM, fill=X)
        self.chart_canvas_list.append(canvas)

    def _draw_line_chart(self, monthly_df):
        line_frame = ttk.LabelFrame(self.chart_frame, text="Monthly Transaction Trends")
        line_frame.grid(row=0, column=1, sticky=NSEW, padx=(0, 10), pady=10)

        figure = Figure(figsize=(5.6, 3.4), dpi=100, facecolor="#1a1f2e")
        axis = figure.add_subplot(111, facecolor="#1a1f2e")

        if monthly_df.empty:
            axis.text(0.5, 0.5, "No transaction data available", ha="center", va="center", color="#9ba3b5")
        else:
            line, = axis.plot(monthly_df["month"], monthly_df["monthly_volume"], marker="o", color="#4f8ef7", linewidth=2.5, markersize=6)
            axis.fill_between(range(len(monthly_df)), monthly_df["monthly_volume"], alpha=0.1, color="#4f8ef7")
            axis.set_xlabel("Month", color="#e8eaf0")
            axis.set_ylabel("Amount (₹)", color="#e8eaf0")
            axis.set_title("Monthly Volume Trend", color="#e8eaf0", fontweight="bold")
            axis.tick_params(colors="#9ba3b5")
            axis.spines["top"].set_visible(False)
            axis.spines["right"].set_visible(False)
            axis.spines["left"].set_color("#2d3448")
            axis.spines["bottom"].set_color("#2d3448")
            axis.grid(True, linestyle="--", alpha=0.2, color="#2d3448")
            figure.autofmt_xdate()

            annotation = axis.annotate(
                "",
                xy=(0, 0),
                xytext=(10, 10),
                textcoords="offset points",
                bbox=dict(boxstyle="round,pad=0.2", fc="#1e1e1e", ec="#808080", alpha=0.85),
                color="#ffffff"
            )
            annotation.set_visible(False)

            def _line_hover(event):
                if event.inaxes != axis:
                    annotation.set_visible(False)
                    figure.canvas.draw_idle()
                    return

                if event.xdata is not None:
                    x_idx = int(round(event.xdata))
                    if 0 <= x_idx < len(monthly_df):
                        label = monthly_df.iloc[x_idx]["month"]
                        value = float(monthly_df.iloc[x_idx]["monthly_volume"])
                        annotation.set_text(f"{label}: ₹{value:,.0f}")
                        annotation.set_position((event.xdata, event.ydata))
                        annotation.set_visible(True)
                        figure.canvas.draw_idle()

            figure.canvas.mpl_connect("motion_notify_event", _line_hover)

        canvas = FigureCanvasTkAgg(figure, master=line_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=BOTH, expand=YES)
        toolbar = NavigationToolbar2Tk(canvas, line_frame)
        toolbar.update()
        toolbar.pack(side=BOTTOM, fill=X)
        self.chart_canvas_list.append(canvas)

    def _draw_pie_chart(self, branch_df):
        pie_frame = ttk.LabelFrame(self.chart_frame, text="Customer Distribution by Branch")
        pie_frame.grid(row=0, column=2, sticky=NSEW, pady=10)

        figure = Figure(figsize=(4.6, 3.4), dpi=100, facecolor="#1a1f2e")
        axis = figure.add_subplot(111, facecolor="#1a1f2e")

        if branch_df.empty:
            axis.text(0.5, 0.5, "No branch data available", ha="center", va="center", color="#9ba3b5")
        else:
            sns_colors = sns.color_palette("husl", len(branch_df))
            wedges, texts, autotexts = axis.pie(
                branch_df["customer_count"],
                labels=branch_df["branch_name"],
                autopct="%1.1f%%",
                startangle=90,
                colors=sns_colors,
                textprops={"color": "#e8eaf0"}
            )
            for t in autotexts:
                t.set_color("#0f1117")
            axis.set_title("Customers per Branch", color="#e8eaf0", fontweight="bold")

            annotation = axis.annotate(
                "",
                xy=(0, 0),
                xytext=(10, 10),
                textcoords="offset points",
                bbox=dict(boxstyle="round,pad=0.2", fc="#1e1e1e", ec="#808080", alpha=0.85),
                color="#ffffff"
            )
            annotation.set_visible(False)

            def _pie_hover(event):
                if event.inaxes != axis:
                    annotation.set_visible(False)
                    figure.canvas.draw_idle()
                    return

                for wedge in wedges:
                    wedge.set_alpha(0.95)

                if event.xdata is not None:
                    for idx, wedge in enumerate(wedges):
                        if wedge.contains(event):
                            branch_name = branch_df.iloc[idx]["branch_name"]
                            count = int(branch_df.iloc[idx]["customer_count"])
                            annotation.set_text(f"{branch_name}: {count} customers")
                            annotation.set_position((event.xdata, event.ydata))
                            annotation.set_visible(True)
                            figure.canvas.draw_idle()
                            break

            figure.canvas.mpl_connect("motion_notify_event", _pie_hover)

        canvas = FigureCanvasTkAgg(figure, master=pie_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=BOTH, expand=YES)
        toolbar = NavigationToolbar2Tk(canvas, pie_frame)
        toolbar.update()
        toolbar.pack(side=BOTTOM, fill=X)
        self.chart_canvas_list.append(canvas)

    def open_interactive_charts(self):
        try:
            from interactive_charts import open_all_charts
            branch_perf_df = pd.DataFrame()
            try:
                with get_db_connection() as conn:
                    branch_perf_df = self._fetch_dataframe(
                        conn,
                        "SELECT b.branch_name, COUNT(DISTINCT c.customer_id) AS total_customers, COUNT(DISTINCT a.account_id) AS total_accounts, COALESCE(SUM(a.balance), 0) AS total_deposits, COUNT(DISTINCT l.loan_id) AS total_loans, COUNT(DISTINCT e.employee_id) AS total_employees FROM branches b LEFT JOIN customers c ON b.branch_id = c.branch_id LEFT JOIN accounts a ON b.branch_id = a.branch_id LEFT JOIN loans l ON b.branch_id = l.branch_id LEFT JOIN employees e ON b.branch_id = e.branch_id GROUP BY b.branch_name"
                    )
            except Exception:
                pass
            txn_type_df = pd.DataFrame()
            try:
                filter_clause, filter_params = self._build_filters()
                with get_db_connection() as conn:
                    txn_type_df = self._fetch_dataframe(
                        conn,
                        "SELECT transaction_type, COUNT(*) AS count, SUM(amount) AS total_amount FROM transactions t JOIN accounts a ON a.account_id = t.account_id JOIN customers c ON c.customer_id = a.customer_id WHERE " + filter_clause + " GROUP BY transaction_type",
                        filter_params
                    )
            except Exception:
                pass
            summary_row = self.summary_df.iloc[0] if not self.summary_df.empty else {}
            messagebox.showinfo("Interactive Charts", "Generating interactive charts... They will open in your browser.")
            results = open_all_charts(
                summary_row,
                self.monthly_df,
                self.branch_df,
                branch_perf_df=branch_perf_df if not branch_perf_df.empty else None,
                txn_type_df=txn_type_df if not txn_type_df.empty else None,
            )
            messagebox.showinfo("Interactive Charts", "Generated " + str(len(results)) + " interactive charts in: " + results.get("full_dashboard", ""))
        except ImportError:
            messagebox.showerror("Missing Library", "Plotly is required. Run: pip install plotly")
        except Exception as exc:
            messagebox.showerror("Chart Error", "Could not generate interactive charts.\n" + str(exc))

    def download_dashboard_csv(self):
        if self.summary_df.empty:
            messagebox.showwarning("No data", "Dashboard data is not available to export yet.")
            return

        export_path = filedialog.asksaveasfilename(
            title="Save analytics dashboard CSV",
            defaultextension=".csv",
            initialfile="bank_analytics_export.csv",
            initialdir=str(EXPORTS_DIR)
        )
        if not export_path:
            return

        # Build well-structured CSV with labeled sections
        lines = []
        lines.append("BANK ANALYTICS REPORT")
        lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(f"Period: {self.period_var.get()} | Branch: {self.branch_var.get()}")
        lines.append("")
        lines.append("=== KPI SUMMARY ===")
        lines.append("Metric,Value")
        summary_row = self.summary_df.iloc[0]
        lines.append(f"Total Transactions,{int(summary_row['total_transactions'])}")
        lines.append(f"Total Deposits (₹),{float(summary_row['total_deposit']):,.0f}")
        lines.append(f"Total Withdrawals (₹),{float(summary_row['total_withdrawal']):,.0f}")
        lines.append(f"Net Flow (₹),{float(summary_row['total_deposit']) - float(summary_row['total_withdrawal']):,.0f}")
        lines.append("")
        lines.append("=== MONTHLY TREND ===")
        if not self.monthly_df.empty:
            lines.append("Month,Transaction Count,Volume (₹)")
            for _, row in self.monthly_df.iterrows():
                lines.append(f"{row['month']},{int(row['transaction_count'])},{float(row['monthly_volume']):,.0f}")
        else:
            lines.append("No monthly data available")
        lines.append("")
        lines.append("=== BRANCH DISTRIBUTION ===")
        if not self.branch_df.empty:
            lines.append("Branch,Customer Count,Share (%)")
            total_customers = self.branch_df['customer_count'].sum()
            for _, row in self.branch_df.iterrows():
                share = (float(row['customer_count']) / float(total_customers)) * 100 if total_customers > 0 else 0
                lines.append(f"{row['branch_name']},{int(row['customer_count'])},{share:.1f}%")
        else:
            lines.append("No branch data available")
        lines.append("")
        lines.append("=== REPORT SUMMARY ===")
        lines.append(f"Total Branches,{len(self.branch_df)}")
        lines.append(f"Total Months with Activity,{len(self.monthly_df)}")
        if not self.monthly_df.empty:
            peak = self.monthly_df.loc[self.monthly_df['monthly_volume'].idxmax()]
            lines.append(f"Peak Month,{peak['month']} (₹{float(peak['monthly_volume']):,.0f})")

        with open(export_path, 'w', encoding='utf-8-sig') as f:
            f.write('\n'.join(lines))

        self._refresh_report_history()
        messagebox.showinfo("Download complete", f"Export saved to:\n{export_path}")

    def download_dashboard_png(self):
        if self.summary_df.empty or self.monthly_df.empty:
            messagebox.showwarning("No data", "Dashboard charts are not available to export yet.")
            return

        export_path = filedialog.asksaveasfilename(
            title="Save dashboard PNG",
            defaultextension=".png",
            initialfile="bank_analytics_dashboard.png",
            initialdir=str(EXPORTS_DIR)
        )
        if not export_path:
            return

        export_figure = Figure(figsize=(12, 7), dpi=120)
        axis1 = export_figure.add_subplot(2, 2, 1)
        axis2 = export_figure.add_subplot(2, 2, 2)
        axis3 = export_figure.add_subplot(2, 2, (3, 4))

        summary_row = self.summary_df.iloc[0]
        axis1.bar(["Deposits", "Withdrawals"], [float(summary_row["total_deposit"]), float(summary_row["total_withdrawal"])], color=["#2ecc71", "#e74c3c"])
        axis1.set_title("Deposit vs Withdrawal Volume")
        axis1.set_ylabel("Amount (₹)")

        axis2.plot(self.monthly_df["month"], self.monthly_df["monthly_volume"], marker="o", color="#3498db")
        axis2.set_title("Monthly Volume Trend")
        axis2.set_xlabel("Month")
        axis2.set_ylabel("Amount (₹)")
        axis2.grid(True, linestyle="--", alpha=0.4)
        export_figure.autofmt_xdate()

        if self.branch_df.empty:
            axis3.text(0.5, 0.5, "No branch data available", ha="center", va="center")
        else:
            axis3.pie(
                self.branch_df["customer_count"],
                labels=self.branch_df["branch_name"],
                autopct="%1.1f%%",
                startangle=90
            )
            axis3.set_title("Customer Distribution by Branch")

        export_figure.tight_layout()
        export_figure.savefig(export_path, bbox_inches="tight")
        self._refresh_report_history()
        messagebox.showinfo("Download complete", f"PNG export saved to:\n{export_path}")

    def download_dashboard_pdf(self):
        if self.summary_df.empty:
            messagebox.showwarning("No data", "Dashboard data is not available to export yet.")
            return

        export_df = pd.concat([
            self.summary_df.assign(metric="summary"),
            self.monthly_df.assign(metric="monthly"),
            self.branch_df.assign(metric="branch")
        ], ignore_index=True)
        records = export_df.to_dict(orient="records")

        try:
            filepath = export_to_pdf(
                records,
                filename=f"bank_analytics_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                title="Bank Analytics Report",
                directory=EXPORTS_DIR,
            )
            self._refresh_report_history()
            messagebox.showinfo("Download complete", f"PDF export saved to:\n{filepath}")
        except Exception as exc:
            messagebox.showerror("PDF Export Error", f"Unable to export PDF report.\n{exc}")
