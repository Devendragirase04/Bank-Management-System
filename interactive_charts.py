# =============================================================================
# Bank Management System - Interactive Plotly Charts
# =============================================================================
# Generates interactive HTML visualizations using Plotly for browser-based
# data exploration. Integrates with the Analytics Dashboard data.
# =============================================================================

import os
import webbrowser
import logging
from datetime import datetime
from pathlib import Path

import pandas as pd
import numpy as np

from config import EXPORTS_DIR

logger = logging.getLogger(__name__)

# =============================================================================
# CONSTANTS
# =============================================================================
PLOTLY_TEMPLATE = "plotly_dark"
CHARTS_DIR = EXPORTS_DIR / "interactive_charts"


# =============================================================================
# COLORS & STYLING
# =============================================================================
COLOR_DEPOSIT = "#2ecc71"
COLOR_WITHDRAWAL = "#e74c3c"
COLOR_PRIMARY = "#4f8ef7"
COLOR_SECONDARY = "#6c5ce7"
COLOR_ACCENT = "#00d4aa"
COLOR_WARNING = "#f5a623"
COLOR_INFO = "#17a2b8"
COLOR_GOLD = "#ffd700"

BRAND_COLORS = [
    "#4f8ef7", "#6c5ce7", "#00d4aa", "#f5a623",
    "#e74c3c", "#17a2b8", "#ffd700", "#2ecc71",
    "#9b59b6", "#1abc9c", "#3498db", "#e67e22"
]


def _get_plotly():
    """Lazy import plotly to avoid overhead if not used."""
    try:
        import plotly.express as px
        import plotly.graph_objects as go
        from plotly.subplots import make_subplots
        return px, go, make_subplots
    except ImportError:
        logger.error("Plotly is not installed. Run: pip install plotly")
        raise ImportError("plotly is required. Run: pip install plotly")


def _format_currency(val):
    """Format value as Indian currency string."""
    try:
        return f"₹{float(val):,.0f}"
    except:
        return f"₹{val}"


def _save_and_open(fig, filename, auto_open=True):
    """Save a Plotly figure as HTML and optionally open in browser."""
    CHARTS_DIR.mkdir(parents=True, exist_ok=True)
    filepath = CHARTS_DIR / f"{filename}.html"

    fig.write_html(
        str(filepath),
        include_plotlyjs="cdn",
        full_html=True,
        config={
            "displayModeBar": True,
            "responsive": True,
            "displaylogo": False,
            "modeBarButtonsToRemove": ["lasso2d", "select2d"],
        }
    )

    logger.info(f"Chart saved: {filepath}")

    if auto_open:
        webbrowser.open(f"file:///{filepath}")

    return str(filepath)


# =============================================================================
# 1. INTERACTIVE MONTHLY TREND (Line + Area + Range Slider)
# =============================================================================
def create_monthly_trend_chart(monthly_df, title="Monthly Transaction Volume Trend", auto_open=True):
    """Interactive line chart with area fill and range slider for monthly volume."""
    px, go, _ = _get_plotly()

    if monthly_df.empty:
        fig = go.Figure()
        fig.add_annotation(text="No transaction data available", showarrow=False)
        fig.update_layout(title=title, template=PLOTLY_TEMPLATE)
        return _save_and_open(fig, "monthly_trend", auto_open)

    df = monthly_df.copy()
    df["month_str"] = df["month"].astype(str)

    fig = go.Figure()

    # Volume line + area
    fig.add_trace(go.Scatter(
        x=df["month_str"],
        y=df["monthly_volume"],
        mode="lines+markers",
        name="Transaction Volume",
        line=dict(color=COLOR_PRIMARY, width=3),
        fill="tozeroy",
        fillcolor="rgba(79, 142, 247, 0.15)",
        hovertemplate="<b>%{x}</b><br>Volume: %{customdata}<extras></extras>",
        customdata=[_format_currency(v) for v in df["monthly_volume"]],
    ))

    # Transaction count as bars (secondary axis)
    if "transaction_count" in df.columns:
        fig.add_trace(go.Bar(
            x=df["month_str"],
            y=df["transaction_count"],
            name="Transaction Count",
            yaxis="y2",
            marker=dict(color=COLOR_ACCENT, opacity=0.3),
            hovertemplate="<b>%{x}</b><br>Count: %{y}<extra></extra>",
        ))

    fig.update_layout(
        title=dict(text=title, font=dict(size=20)),
        template=PLOTLY_TEMPLATE,
        hovermode="x unified",
        xaxis=dict(title="Month", type="category", showgrid=False),
        yaxis=dict(title="Volume (₹)", showgrid=True, gridcolor="rgba(255,255,255,0.1)"),
        yaxis2=dict(title="Transaction Count", overlaying="y", side="right", showgrid=False),
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1),
        margin=dict(l=60, r=60, t=60, b=40),
        paper_bgcolor="rgba(15,17,23,0.95)",
        plot_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
    )
    fig.update_xaxes(rangeslider=dict(visible=True, thickness=0.05))

    # Peak annotation
    if not df.empty:
        peak_idx = df["monthly_volume"].idxmax()
        peak_row = df.loc[peak_idx]
        fig.add_annotation(
            x=peak_row["month_str"], y=peak_row["monthly_volume"],
            text=f"Peak: {_format_currency(peak_row['monthly_volume'])}",
            showarrow=True, arrowhead=2, ax=0, ay=-40,
            font=dict(color=COLOR_GOLD, size=11),
            bgcolor="rgba(0,0,0,0.6)", bordercolor=COLOR_GOLD, borderwidth=1,
        )

    return _save_and_open(fig, "monthly_trend", auto_open)


# =============================================================================
# 2. DEPOSIT VS WITHDRAWAL COMPARISON
# =============================================================================
def create_deposit_withdrawal_chart(summary_row, title="Deposit vs Withdrawal Comparison", auto_open=True):
    """Interactive bar chart comparing deposit vs withdrawal volumes."""
    _, go, _ = _get_plotly()

    deposit = float(summary_row.get("total_deposit", 0))
    withdrawal = float(summary_row.get("total_withdrawal", 0))
    net_flow = deposit - withdrawal

    fig = go.Figure()

    fig.add_trace(go.Bar(
        name="Deposits (Inbound)", x=["Deposits"], y=[deposit],
        marker_color=COLOR_DEPOSIT, marker_line=dict(color="#1a8f4a", width=1),
        hovertemplate="<b>Deposits</b><br>Amount: %{customdata}<extra></extra>",
        customdata=[_format_currency(deposit)],
        text=_format_currency(deposit), textposition="outside",
        textfont=dict(size=14, color=COLOR_DEPOSIT),
    ))

    fig.add_trace(go.Bar(
        name="Withdrawals (Outbound)", x=["Withdrawals"], y=[withdrawal],
        marker_color=COLOR_WITHDRAWAL, marker_line=dict(color="#a93226", width=1),
        hovertemplate="<b>Withdrawals</b><br>Amount: %{customdata}<extra></extra>",
        customdata=[_format_currency(withdrawal)],
        text=_format_currency(withdrawal), textposition="outside",
        textfont=dict(size=14, color=COLOR_WITHDRAWAL),
    ))

    fig.add_hline(
        y=0, line_dash="dot", line_color="rgba(255,255,255,0.3)",
        annotation_text=f"Net Flow: {_format_currency(net_flow)}",
        annotation_position="bottom right",
        annotation_font=dict(size=12, color=COLOR_GOLD if net_flow >= 0 else COLOR_WITHDRAWAL),
    )

    fig.update_layout(
        title=dict(text=title, font=dict(size=20)),
        template=PLOTLY_TEMPLATE, hovermode="x",
        yaxis=dict(title="Amount (₹)", showgrid=True, gridcolor="rgba(255,255,255,0.1)"),
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1),
        margin=dict(l=60, r=60, t=60, b=40),
        paper_bgcolor="rgba(15,17,23,0.95)",
        plot_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
        barmode="group", bargap=0.4,
    )

    return _save_and_open(fig, "deposit_withdrawal", auto_open)


# =============================================================================
# 3. BRANCH CUSTOMER DISTRIBUTION (Donut Pie)
# =============================================================================
def create_branch_distribution_chart(branch_df, title="Customer Distribution by Branch", auto_open=True):
    """Interactive donut chart for branch customer distribution."""
    _, go, _ = _get_plotly()

    if branch_df.empty:
        fig = go.Figure()
        fig.add_annotation(text="No branch data available", showarrow=False)
        fig.update_layout(title=title, template=PLOTLY_TEMPLATE)
        return _save_and_open(fig, "branch_distribution", auto_open)

    df = branch_df.copy()
    total_customers = df["customer_count"].sum()

    fig = go.Figure()

    fig.add_trace(go.Pie(
        labels=df["branch_name"],
        values=df["customer_count"],
        hole=0.45,
        marker=dict(colors=BRAND_COLORS[:len(df)], line=dict(color="#0f1117", width=2)),
        textinfo="label+percent",
        textposition="outside",
        hovertemplate="<b>%{label}</b><br>Customers: %{value:,}<br>Share: %{percent}<extra></extra>",
        rotation=90,
        pull=[0.05 if i == df["customer_count"].idxmax() else 0 for i in df.index],
    ))

    fig.add_annotation(
        x=0.5, y=0.5, text=f"Total<br>{total_customers:,}",
        showarrow=False, font=dict(size=18, color="#e8eaf0"), align="center",
    )

    fig.update_layout(
        title=dict(text=title, font=dict(size=20)),
        template=PLOTLY_TEMPLATE, hovermode="closest",
        legend=dict(orientation="h", yanchor="bottom", y=-0.15, xanchor="center", x=0.5, font=dict(size=10)),
        margin=dict(l=40, r=40, t=60, b=80),
        paper_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
    )

    return _save_and_open(fig, "branch_distribution", auto_open)


# =============================================================================
# 4. BRANCH PERFORMANCE HEATMAP
# =============================================================================
def create_branch_heatmap(branch_perf_df, title="Branch Performance Heatmap", auto_open=True):
    """Interactive heatmap for branch performance metrics."""
    px, go, _ = _get_plotly()

    if branch_perf_df.empty:
        fig = go.Figure()
        fig.add_annotation(text="No branch performance data", showarrow=False)
        fig.update_layout(title=title, template=PLOTLY_TEMPLATE)
        return _save_and_open(fig, "branch_heatmap", auto_open)

    df = branch_perf_df.copy()
    metric_cols = [c for c in df.columns if c not in ("branch_name", "branch_id", "city", "state", "ifsc_code")
                   and pd.api.types.is_numeric_dtype(df[c])]

    if not metric_cols:
        fig = go.Figure()
        fig.add_annotation(text="No numeric metrics for heatmap", showarrow=False)
        fig.update_layout(title=title, template=PLOTLY_TEMPLATE)
        return _save_and_open(fig, "branch_heatmap", auto_open)

    heatmap_data = df[metric_cols].copy()
    heatmap_data = heatmap_data.apply(lambda x: (x - x.min()) / (x.max() - x.min() + 0.001), axis=0)
    display_cols = [c.replace("_", " ").title() for c in metric_cols]

    fig = go.Figure(data=go.Heatmap(
        z=heatmap_data.values, x=display_cols, y=df["branch_name"],
        colorscale="Viridis", text=df[metric_cols].values,
        texttemplate="%{text:.0f}", textfont=dict(size=9, color="white"),
        hovertemplate="<b>%{y}</b><br>%{x}: %{text}<extra></extra>",
        colorbar=dict(title="Score", tickvals=[0, 0.5, 1], ticktext=["Low", "Mid", "High"]),
    ))

    fig.update_layout(
        title=dict(text=title, font=dict(size=20)),
        template=PLOTLY_TEMPLATE,
        xaxis=dict(tickangle=30, side="bottom"),
        yaxis=dict(autorange="reversed"),
        margin=dict(l=120, r=30, t=60, b=120),
        paper_bgcolor="rgba(15,17,23,0.95)",
        plot_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
        height=max(400, len(df) * 45),
    )

    return _save_and_open(fig, "branch_heatmap", auto_open)


# =============================================================================
# 5. TRANSACTION TYPE DISTRIBUTION (Treemap)
# =============================================================================
def create_transaction_type_chart(txn_type_df, title="Transaction Type Distribution", auto_open=True):
    """Interactive treemap for transaction type breakdown."""
    px, go, _ = _get_plotly()

    if txn_type_df.empty:
        fig = go.Figure()
        fig.add_annotation(text="No transaction type data", showarrow=False)
        fig.update_layout(title=title, template=PLOTLY_TEMPLATE)
        return _save_and_open(fig, "transaction_types", auto_open)

    df = txn_type_df.copy()
    value_col = "total_amount" if "total_amount" in df.columns else "count"

    fig = px.treemap(
        df, names="transaction_type", values=value_col, color=value_col,
        color_continuous_scale="Viridis", title=title,
        hover_data={"count": ":,"} if "count" in df.columns else {},
    )

    fig.update_traces(
        textinfo="label+value+percent root",
        texttemplate="<b>%{label}</b><br>%{value:,.0f}",
        hovertemplate="<b>%{label}</b><br>Amount: ₹%{value:,.2f}<extra></extra>",
    )

    fig.update_layout(
        title=dict(text=title, font=dict(size=20)),
        template=PLOTLY_TEMPLATE,
        margin=dict(l=10, r=10, t=60, b=10),
        paper_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
    )

    return _save_and_open(fig, "transaction_types", auto_open)


# =============================================================================
# 6. COMBINED DASHBOARD (All charts in one HTML page)
# =============================================================================
def create_full_dashboard(summary_row, monthly_df, branch_df, branch_perf_df=None, txn_type_df=None, auto_open=True):
    """Comprehensive interactive dashboard with all charts in a tabbed HTML layout."""
    _, go, make_subplots = _get_plotly()

    total_txn = int(summary_row.get("total_transactions", 0))
    deposit = float(summary_row.get("total_deposit", 0))
    withdrawal = float(summary_row.get("total_withdrawal", 0))
    net = deposit - withdrawal

    fig = make_subplots(
        rows=3, cols=2,
        specs=[
            [{"type": "indicator"}, {"type": "indicator"}],
            [{"type": "scatter", "colspan": 2}, None],
            [{"type": "bar"}, {"type": "pie"}],
        ],
        subplot_titles=("Total Transactions", "Net Flow", "Monthly Volume Trend", "Deposit vs Withdrawal", "Branch Distribution"),
        vertical_spacing=0.12, horizontal_spacing=0.08,
    )

    # KPI: Total Transactions
    fig.add_trace(go.Indicator(
        mode="number", value=total_txn, title={"text": "Total Transactions"},
        number={"font": {"size": 36, "color": COLOR_PRIMARY}},
    ), row=1, col=1)

    # KPI: Net Flow
    fig.add_trace(go.Indicator(
        mode="number+delta", value=net,
        number={"prefix": "₹", "font": {"size": 30, "color": COLOR_ACCENT if net >= 0 else COLOR_WITHDRAWAL}},
        delta={"reference": 0, "position": "bottom"},
        title={"text": "Net Flow"},
    ), row=1, col=2)

    # Monthly trend
    if not monthly_df.empty:
        df = monthly_df.copy()
        df["month_str"] = df["month"].astype(str)
        fig.add_trace(go.Scatter(
            x=df["month_str"], y=df["monthly_volume"],
            mode="lines+markers", name="Monthly Volume",
            line=dict(color=COLOR_PRIMARY, width=3),
            fill="tozeroy", fillcolor="rgba(79, 142, 247, 0.15)",
            hovertemplate="<b>%{x}</b><br>Volume: %{customdata}<extra></extra>",
            customdata=[_format_currency(v) for v in df["monthly_volume"]],
        ), row=2, col=1)

    # Deposit vs Withdrawal bar
    fig.add_trace(go.Bar(
        name="Deposits", x=["Deposits"], y=[deposit],
        marker_color=COLOR_DEPOSIT, showlegend=False,
        hovertemplate="<b>Deposits</b><br>%{customdata}<extra></extra>",
        customdata=[_format_currency(deposit)],
    ), row=3, col=1)

    fig.add_trace(go.Bar(
        name="Withdrawals", x=["Withdrawals"], y=[withdrawal],
        marker_color=COLOR_WITHDRAWAL, showlegend=False,
        hovertemplate="<b>Withdrawals</b><br>%{customdata}<extra></extra>",
        customdata=[_format_currency(withdrawal)],
    ), row=3, col=1)

    # Branch distribution pie
    if not branch_df.empty:
        fig.add_trace(go.Pie(
            labels=branch_df["branch_name"],
            values=branch_df["customer_count"],
            hole=0.4,
            marker=dict(colors=BRAND_COLORS[:len(branch_df)]),
            showlegend=False,
            hovertemplate="<b>%{label}</b><br>%{value} customers<extra></extra>",
        ), row=3, col=2)

    fig.update_layout(
        template=PLOTLY_TEMPLATE,
        title=dict(text="Bank Analytics Dashboard - Interactive View", font=dict(size=24)),
        height=700,
        paper_bgcolor="rgba(15,17,23,0.95)",
        plot_bgcolor="rgba(15,17,23,0.95)",
        font=dict(color="#e8eaf0"),
        showlegend=False,
    )

    return _save_and_open(fig, "full_dashboard", auto_open)


def open_all_charts(summary_row, monthly_df, branch_df, branch_perf_df=None, txn_type_df=None):
    results = {}
    results["monthly_trend"] = create_monthly_trend_chart(monthly_df, auto_open=False)
    results["deposit_withdrawal"] = create_deposit_withdrawal_chart(summary_row, auto_open=False)
    results["branch_distribution"] = create_branch_distribution_chart(branch_df, auto_open=False)
    if branch_perf_df is not None and not branch_perf_df.empty:
        results["branch_heatmap"] = create_branch_heatmap(branch_perf_df, auto_open=False)
    if txn_type_df is not None and not txn_type_df.empty:
        results["transaction_types"] = create_transaction_type_chart(txn_type_df, auto_open=False)
    results["full_dashboard"] = create_full_dashboard(summary_row, monthly_df, branch_df, branch_perf_df=branch_perf_df, txn_type_df=txn_type_df, auto_open=True)
    return results


if __name__ == "__main__":
    print("Interactive Charts Module - Run from Analytics Dashboard")
