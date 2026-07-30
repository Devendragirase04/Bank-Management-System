"""
=============================================================================
Bank Management System — Standalone EDA Report Generator
=============================================================================
Purpose  : Connects to BankDB, runs analytical queries, and generates a
           rich interactive HTML report using Plotly.
Output   : exports/eda_report.html  (open in any browser)
Usage    : python analysis/eda_report.py
           python analysis/eda_report.py --no-open  (skip auto-open)
=============================================================================
"""

import sys
import argparse
import logging
import webbrowser
from pathlib import Path
from datetime import datetime

# Allow running from the project root OR from analysis/
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

import pandas as pd

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s | %(levelname)-8s | %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# DB helpers
# ---------------------------------------------------------------------------

def _get_conn():
    """Get a DB connection using the project's pool manager."""
    from database import initialize_pool, get_db_connection
    initialize_pool()
    return get_db_connection


def _fetch(conn_ctx, query: str, params=None) -> pd.DataFrame:
    with conn_ctx() as conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        cursor.close()
    return pd.DataFrame(rows) if rows else pd.DataFrame()


# ---------------------------------------------------------------------------
# Data fetchers
# ---------------------------------------------------------------------------

def fetch_kpis(conn_ctx) -> dict:
    """Fetch single-row executive KPIs."""
    sql = """
        SELECT
            (SELECT COUNT(*) FROM customers WHERE is_active = 1)                        AS total_customers,
            (SELECT COUNT(*) FROM accounts WHERE status = 'Active')                     AS active_accounts,
            (SELECT ROUND(SUM(balance),2) FROM accounts WHERE status = 'Active')        AS total_deposits,
            (SELECT COUNT(*) FROM branches WHERE is_active = 1)                         AS active_branches,
            (SELECT COUNT(*) FROM loans WHERE status = 'Disbursed')                     AS active_loans,
            (SELECT ROUND(SUM(outstanding_amount),2) FROM loans
             WHERE status = 'Disbursed')                                                AS loan_outstanding,
            (SELECT COUNT(*) FROM transactions WHERE status = 'Success'
             AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY))                        AS txns_30d,
            (SELECT ROUND(SUM(amount),2) FROM transactions WHERE status = 'Success'
             AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY))                        AS volume_30d
    """
    df = _fetch(conn_ctx, sql)
    return df.iloc[0].to_dict() if not df.empty else {}


def fetch_monthly_trend(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            DATE_FORMAT(created_at, '%Y-%m')     AS period,
            COUNT(*)                             AS txn_count,
            ROUND(SUM(amount),2)                 AS total_volume,
            ROUND(SUM(CASE WHEN transaction_type IN
                ('Deposit','UPI Credit','Transfer In','Interest Credit')
                THEN amount ELSE 0 END),2)       AS inflow,
            ROUND(SUM(CASE WHEN transaction_type IN
                ('Withdrawal','UPI Debit','Transfer Out','EMI Debit')
                THEN amount ELSE 0 END),2)       AS outflow
        FROM transactions
        WHERE status = 'Success'
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY period
    """)


def fetch_branch_performance(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            b.branch_name,
            b.city,
            b.state,
            COUNT(DISTINCT c.customer_id)              AS customers,
            COUNT(DISTINCT a.account_id)               AS accounts,
            ROUND(COALESCE(SUM(a.balance),0),2)        AS deposits,
            COUNT(DISTINCT l.loan_id)                  AS loans,
            ROUND(COALESCE(SUM(CASE WHEN l.status='Disbursed'
                THEN l.principal_amount END),0),2)     AS loan_amount,
            COUNT(DISTINCT e.employee_id)              AS employees
        FROM branches b
        LEFT JOIN customers c ON b.branch_id = c.branch_id
        LEFT JOIN accounts  a ON b.branch_id = a.branch_id
        LEFT JOIN loans     l ON b.branch_id = l.branch_id
        LEFT JOIN employees e ON b.branch_id = e.branch_id
        WHERE b.is_active = 1
        GROUP BY b.branch_id, b.branch_name, b.city, b.state
        ORDER BY deposits DESC
    """)


def fetch_txn_by_type(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            transaction_type,
            channel,
            COUNT(*)                    AS txn_count,
            ROUND(SUM(amount),2)        AS total_amount,
            ROUND(AVG(amount),2)        AS avg_amount
        FROM transactions
        WHERE status = 'Success'
        GROUP BY transaction_type, channel
        ORDER BY total_amount DESC
    """)


def fetch_customer_segments(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            CASE
                WHEN credit_score >= 750 THEN 'Excellent (750+)'
                WHEN credit_score >= 700 THEN 'Good (700-749)'
                WHEN credit_score >= 650 THEN 'Fair (650-699)'
                ELSE 'Poor (<650)'
            END                         AS credit_band,
            COUNT(*)                    AS customer_count,
            ROUND(AVG(annual_income),2) AS avg_income,
            ROUND(AVG(credit_score),1)  AS avg_score
        FROM customers
        WHERE is_active = 1
        GROUP BY credit_band
        ORDER BY avg_score DESC
    """)


def fetch_account_balance_dist(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            CASE
                WHEN balance < 5000        THEN '< ₹5K'
                WHEN balance < 25000       THEN '₹5K–25K'
                WHEN balance < 100000      THEN '₹25K–1L'
                WHEN balance < 500000      THEN '₹1L–5L'
                ELSE '> ₹5L'
            END                           AS balance_band,
            COUNT(*)                      AS account_count,
            ROUND(SUM(balance),2)         AS total_balance
        FROM accounts
        WHERE status = 'Active'
        GROUP BY balance_band
        ORDER BY total_balance DESC
    """)


def fetch_hourly_pattern(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            HOUR(created_at)             AS hour_of_day,
            COUNT(*)                     AS txn_count,
            ROUND(AVG(amount),2)         AS avg_amount
        FROM transactions
        WHERE status = 'Success'
        GROUP BY HOUR(created_at)
        ORDER BY hour_of_day
    """)


def fetch_top_customers(conn_ctx) -> pd.DataFrame:
    return _fetch(conn_ctx, """
        SELECT
            c.full_name,
            b.branch_name,
            c.credit_score,
            ROUND(SUM(a.balance),2)     AS total_balance,
            COUNT(DISTINCT a.account_id) AS accounts
        FROM customers c
        JOIN branches b   ON c.branch_id = b.branch_id
        JOIN accounts a   ON c.customer_id = a.customer_id AND a.status = 'Active'
        WHERE c.is_active = 1
        GROUP BY c.customer_id, c.full_name, b.branch_name, c.credit_score
        ORDER BY total_balance DESC
        LIMIT 15
    """)


# ---------------------------------------------------------------------------
# Report builder
# ---------------------------------------------------------------------------

BRAND = {
    "primary":    "#4f8ef7",
    "secondary":  "#6c5ce7",
    "success":    "#00d4aa",
    "warning":    "#f5a623",
    "danger":     "#e74c3c",
    "info":       "#17a2b8",
    "gold":       "#ffd700",
    "bg":         "#0f1117",
    "bg2":        "#1a1f2e",
    "text":       "#e8eaf0",
    "muted":      "#9ba3b5",
}

PALETTE = [
    "#4f8ef7", "#6c5ce7", "#00d4aa", "#f5a623",
    "#e74c3c", "#17a2b8", "#ffd700", "#2ecc71",
    "#9b59b6", "#1abc9c", "#3498db", "#e67e22",
]


def _fmt_inr(val) -> str:
    try:
        v = float(val)
        if v >= 1_00_00_000:
            return f"₹{v/1_00_00_000:.2f} Cr"
        elif v >= 1_00_000:
            return f"₹{v/1_00_000:.2f} L"
        elif v >= 1_000:
            return f"₹{v/1_000:.1f} K"
        return f"₹{v:,.0f}"
    except Exception:
        return "₹0"


def build_report(kpis: dict,
                 monthly: pd.DataFrame,
                 branch: pd.DataFrame,
                 txn_type: pd.DataFrame,
                 segments: pd.DataFrame,
                 balance_dist: pd.DataFrame,
                 hourly: pd.DataFrame,
                 top_customers: pd.DataFrame) -> str:
    """Assemble all Plotly figures into a single self-contained HTML report."""
    try:
        import plotly.graph_objects as go
        import plotly.express as px
        from plotly.subplots import make_subplots
    except ImportError:
        logger.error("Plotly not found. Run: pip install plotly")
        raise

    template = "plotly_dark"
    generated_at = datetime.now().strftime("%d %b %Y, %H:%M")

    # ------------------------------------------------------------------
    # KPI Cards (Table as a styled go.Table)
    # ------------------------------------------------------------------
    kpi_labels = [
        "Total Customers", "Active Accounts", "Total Deposits",
        "Active Branches", "Active Loans", "Loan Outstanding",
        "Txns (Last 30d)", "Volume (Last 30d)"
    ]
    kpi_values = [
        f"{int(kpis.get('total_customers', 0)):,}",
        f"{int(kpis.get('active_accounts', 0)):,}",
        _fmt_inr(kpis.get("total_deposits", 0)),
        f"{int(kpis.get('active_branches', 0)):,}",
        f"{int(kpis.get('active_loans', 0)):,}",
        _fmt_inr(kpis.get("loan_outstanding", 0)),
        f"{int(kpis.get('txns_30d', 0)):,}",
        _fmt_inr(kpis.get("volume_30d", 0)),
    ]

    fig_kpi = go.Figure(go.Table(
        columnwidth=[2, 1.5],
        header=dict(
            values=["<b>Key Performance Indicator</b>", "<b>Value</b>"],
            fill_color=BRAND["bg2"],
            font=dict(color=BRAND["primary"], size=13),
            align="left",
            height=40,
        ),
        cells=dict(
            values=[kpi_labels, kpi_values],
            fill_color=[[BRAND["bg"], BRAND["bg2"]] * 4,
                        [BRAND["bg"], BRAND["bg2"]] * 4],
            font=dict(color=[BRAND["text"], BRAND["success"]], size=13),
            align=["left", "right"],
            height=36,
        )
    ))
    fig_kpi.update_layout(
        title=dict(text="📊 Executive KPI Snapshot", font=dict(size=18, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        margin=dict(l=20, r=20, t=60, b=20),
        height=420,
    )

    # ------------------------------------------------------------------
    # Monthly Trend — Inflow / Outflow / Net
    # ------------------------------------------------------------------
    fig_monthly = go.Figure()
    if not monthly.empty:
        fig_monthly.add_trace(go.Bar(
            x=monthly["period"], y=monthly["inflow"],
            name="Inflow", marker_color=BRAND["success"], opacity=0.85
        ))
        fig_monthly.add_trace(go.Bar(
            x=monthly["period"], y=monthly["outflow"],
            name="Outflow", marker_color=BRAND["danger"], opacity=0.85
        ))
        net = monthly["inflow"] - monthly["outflow"]
        fig_monthly.add_trace(go.Scatter(
            x=monthly["period"], y=net,
            name="Net Flow", mode="lines+markers",
            line=dict(color=BRAND["gold"], width=2.5),
            marker=dict(size=7)
        ))
    fig_monthly.update_layout(
        title=dict(text="📈 Monthly Transaction Trends — Inflow vs Outflow", font=dict(size=16, color=BRAND["text"])),
        barmode="group",
        template=template,
        paper_bgcolor=BRAND["bg"],
        plot_bgcolor=BRAND["bg2"],
        xaxis=dict(title="Month", tickangle=-45, color=BRAND["muted"]),
        yaxis=dict(title="Amount (₹)", color=BRAND["muted"]),
        legend=dict(bgcolor=BRAND["bg2"]),
        height=440,
    )

    # ------------------------------------------------------------------
    # Branch Performance — Horizontal bar
    # ------------------------------------------------------------------
    fig_branch = go.Figure()
    if not branch.empty:
        branch_sorted = branch.sort_values("deposits", ascending=True).tail(12)
        fig_branch.add_trace(go.Bar(
            y=branch_sorted["branch_name"],
            x=branch_sorted["deposits"],
            name="Total Deposits",
            orientation="h",
            marker=dict(color=BRAND["primary"], opacity=0.9),
        ))
        fig_branch.add_trace(go.Bar(
            y=branch_sorted["branch_name"],
            x=branch_sorted["loan_amount"],
            name="Loan Portfolio",
            orientation="h",
            marker=dict(color=BRAND["warning"], opacity=0.8),
        ))
    fig_branch.update_layout(
        title=dict(text="🏦 Branch Performance — Deposits vs Loan Portfolio", font=dict(size=16, color=BRAND["text"])),
        barmode="group",
        template=template,
        paper_bgcolor=BRAND["bg"],
        plot_bgcolor=BRAND["bg2"],
        xaxis=dict(title="Amount (₹)", color=BRAND["muted"]),
        yaxis=dict(color=BRAND["muted"]),
        height=480,
    )

    # ------------------------------------------------------------------
    # Customer Distribution by Branch (Pie)
    # ------------------------------------------------------------------
    fig_branch_pie = go.Figure()
    if not branch.empty:
        fig_branch_pie.add_trace(go.Pie(
            labels=branch["branch_name"],
            values=branch["customers"],
            hole=0.4,
            marker=dict(colors=PALETTE),
            textfont=dict(size=11),
        ))
    fig_branch_pie.update_layout(
        title=dict(text="🍩 Customer Share by Branch", font=dict(size=16, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        height=440,
    )

    # ------------------------------------------------------------------
    # Transaction Type Treemap
    # ------------------------------------------------------------------
    fig_treemap = go.Figure()
    if not txn_type.empty:
        fig_treemap = px.treemap(
            txn_type,
            path=["channel", "transaction_type"],
            values="total_amount",
            color="avg_amount",
            color_continuous_scale="Blues",
            title="🌳 Transaction Volume Treemap — Channel → Type",
            template=template,
        )
        fig_treemap.update_layout(
            paper_bgcolor=BRAND["bg"],
            font=dict(color=BRAND["text"]),
            title_font=dict(size=16),
            height=480,
        )

    # ------------------------------------------------------------------
    # Credit Score Band Distribution
    # ------------------------------------------------------------------
    fig_segments = go.Figure()
    if not segments.empty:
        fig_segments.add_trace(go.Bar(
            x=segments["credit_band"],
            y=segments["customer_count"],
            marker=dict(color=PALETTE[:len(segments)]),
            text=segments["customer_count"],
            textposition="outside",
        ))
    fig_segments.update_layout(
        title=dict(text="🎯 Customer Credit Score Segmentation", font=dict(size=16, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        plot_bgcolor=BRAND["bg2"],
        xaxis=dict(title="Credit Band", color=BRAND["muted"]),
        yaxis=dict(title="Number of Customers", color=BRAND["muted"]),
        height=400,
    )

    # ------------------------------------------------------------------
    # Account Balance Distribution
    # ------------------------------------------------------------------
    fig_balance = go.Figure()
    if not balance_dist.empty:
        fig_balance.add_trace(go.Bar(
            x=balance_dist["balance_band"],
            y=balance_dist["account_count"],
            marker=dict(color=BRAND["secondary"], opacity=0.9),
            name="Account Count",
        ))
        fig_balance.add_trace(go.Scatter(
            x=balance_dist["balance_band"],
            y=balance_dist["total_balance"],
            name="Total Balance (₹)",
            yaxis="y2",
            mode="lines+markers",
            line=dict(color=BRAND["gold"], width=2),
        ))
    fig_balance.update_layout(
        title=dict(text="💰 Account Balance Distribution", font=dict(size=16, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        plot_bgcolor=BRAND["bg2"],
        yaxis=dict(title="Account Count", color=BRAND["muted"]),
        yaxis2=dict(title="Total Balance (₹)", overlaying="y", side="right", color=BRAND["gold"]),
        legend=dict(bgcolor=BRAND["bg2"]),
        height=420,
    )

    # ------------------------------------------------------------------
    # Hourly Transaction Pattern
    # ------------------------------------------------------------------
    fig_hourly = go.Figure()
    if not hourly.empty:
        fig_hourly.add_trace(go.Bar(
            x=hourly["hour_of_day"],
            y=hourly["txn_count"],
            name="Transaction Count",
            marker=dict(color=BRAND["info"], opacity=0.85),
        ))
        fig_hourly.add_trace(go.Scatter(
            x=hourly["hour_of_day"],
            y=hourly["avg_amount"],
            name="Avg Amount (₹)",
            yaxis="y2",
            mode="lines+markers",
            line=dict(color=BRAND["warning"], width=2.5),
            marker=dict(size=7),
        ))
    fig_hourly.update_layout(
        title=dict(text="⏰ Peak Hour Analysis — Transaction Volume by Hour", font=dict(size=16, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        plot_bgcolor=BRAND["bg2"],
        xaxis=dict(title="Hour of Day (0–23)", tickmode="linear", color=BRAND["muted"]),
        yaxis=dict(title="Transaction Count", color=BRAND["muted"]),
        yaxis2=dict(title="Avg Amount (₹)", overlaying="y", side="right", color=BRAND["warning"]),
        legend=dict(bgcolor=BRAND["bg2"]),
        height=420,
    )

    # ------------------------------------------------------------------
    # Top Customers Table
    # ------------------------------------------------------------------
    fig_top = go.Figure()
    if not top_customers.empty:
        fig_top = go.Figure(go.Table(
            columnwidth=[2, 2, 1, 1.5, 1],
            header=dict(
                values=["<b>Customer</b>", "<b>Branch</b>", "<b>Credit Score</b>",
                        "<b>Total Balance (₹)</b>", "<b>Accounts</b>"],
                fill_color=BRAND["bg2"],
                font=dict(color=BRAND["primary"], size=12),
                align="left",
                height=36,
            ),
            cells=dict(
                values=[
                    top_customers["full_name"],
                    top_customers["branch_name"],
                    top_customers["credit_score"],
                    top_customers["total_balance"].apply(lambda v: f"₹{float(v):,.0f}"),
                    top_customers["accounts"],
                ],
                fill_color=[[BRAND["bg"], BRAND["bg2"]] * 8],
                font=dict(color=BRAND["text"], size=11),
                align=["left", "left", "center", "right", "center"],
                height=32,
            )
        ))
    fig_top.update_layout(
        title=dict(text="🏆 Top 15 Customers by Total Balance", font=dict(size=16, color=BRAND["text"])),
        template=template,
        paper_bgcolor=BRAND["bg"],
        margin=dict(l=20, r=20, t=60, b=20),
        height=540,
    )

    # ------------------------------------------------------------------
    # Assemble HTML
    # ------------------------------------------------------------------
    def _to_html(fig) -> str:
        return fig.to_html(
            full_html=False,
            include_plotlyjs=False,
            config={"displayModeBar": True, "responsive": True, "displaylogo": False},
        )

    sections = [
        ("Executive KPI Snapshot",           fig_kpi),
        ("Monthly Transaction Trends",       fig_monthly),
        ("Branch Performance — Deposits",    fig_branch),
        ("Customer Share by Branch",         fig_branch_pie),
        ("Transaction Volume Treemap",       fig_treemap),
        ("Credit Score Segmentation",        fig_segments),
        ("Account Balance Distribution",     fig_balance),
        ("Peak Hour Analysis",               fig_hourly),
        ("Top 15 Customers",                 fig_top),
    ]

    charts_html = ""
    for section_title, fig in sections:
        charts_html += f"""
        <section class="chart-section">
            <h2>{section_title}</h2>
            {_to_html(fig)}
        </section>
        """

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Bank Management System — EDA Report</title>
  <script src="https://cdn.plot.ly/plotly-2.29.1.min.js"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: 'Inter', sans-serif;
      background: {BRAND['bg']};
      color: {BRAND['text']};
      min-height: 100vh;
    }}
    header {{
      background: linear-gradient(135deg, {BRAND['bg2']} 0%, #12192a 100%);
      padding: 40px 48px 32px;
      border-bottom: 1px solid #2d3448;
    }}
    header h1 {{
      font-size: 2rem;
      font-weight: 700;
      color: {BRAND['primary']};
      margin-bottom: 6px;
    }}
    header p {{
      color: {BRAND['muted']};
      font-size: 0.95rem;
    }}
    .badge {{
      display: inline-block;
      background: {BRAND['bg']};
      border: 1px solid {BRAND['primary']};
      color: {BRAND['primary']};
      border-radius: 20px;
      padding: 3px 14px;
      font-size: 0.8rem;
      margin-right: 8px;
      margin-top: 12px;
    }}
    nav {{
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      background: {BRAND['bg2']};
      padding: 14px 48px;
      border-bottom: 1px solid #2d3448;
    }}
    nav a {{
      color: {BRAND['muted']};
      text-decoration: none;
      font-size: 0.88rem;
      padding: 4px 14px;
      border-radius: 20px;
      border: 1px solid #2d3448;
      transition: all 0.2s;
    }}
    nav a:hover {{
      color: {BRAND['primary']};
      border-color: {BRAND['primary']};
      background: rgba(79,142,247,0.08);
    }}
    main {{
      max-width: 1440px;
      margin: 0 auto;
      padding: 32px 48px 64px;
    }}
    .chart-section {{
      background: {BRAND['bg2']};
      border: 1px solid #2d3448;
      border-radius: 12px;
      padding: 28px 24px 20px;
      margin-bottom: 28px;
    }}
    .chart-section h2 {{
      font-size: 1.05rem;
      font-weight: 600;
      color: {BRAND['muted']};
      margin-bottom: 18px;
      letter-spacing: 0.02em;
      text-transform: uppercase;
    }}
    footer {{
      text-align: center;
      padding: 28px;
      color: {BRAND['muted']};
      font-size: 0.8rem;
      border-top: 1px solid #2d3448;
    }}
  </style>
</head>
<body>
  <header>
    <h1>🏦 Bank Management System — Exploratory Data Analysis</h1>
    <p>Interactive analytics report · Generated on {generated_at}</p>
    <div>
      <span class="badge">Python</span>
      <span class="badge">MySQL</span>
      <span class="badge">Pandas</span>
      <span class="badge">Plotly</span>
      <span class="badge">Data Analytics</span>
    </div>
  </header>
  <nav>
    {"".join(f'<a href="#">{t}</a>' for t, _ in sections)}
  </nav>
  <main>
    {charts_html}
  </main>
  <footer>
    Bank Management System · EDA Report · {generated_at} ·
    Built with Python · MySQL · Plotly
  </footer>
</body>
</html>"""
    return html


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Generate an interactive EDA report for BankDB"
    )
    parser.add_argument(
        "--no-open", action="store_true",
        help="Do not automatically open the report in the browser"
    )
    parser.add_argument(
        "--output", default=None,
        help="Output file path (default: exports/eda_report.html)"
    )
    args = parser.parse_args()

    logger.info("Initialising database connection …")
    try:
        conn_ctx = _get_conn()
    except Exception as exc:
        logger.error(f"Cannot connect to database: {exc}")
        logger.error("Make sure BankDB is running and .env credentials are correct.")
        sys.exit(1)

    logger.info("Fetching data …")
    try:
        kpis           = fetch_kpis(conn_ctx)
        monthly        = fetch_monthly_trend(conn_ctx)
        branch         = fetch_branch_performance(conn_ctx)
        txn_type       = fetch_txn_by_type(conn_ctx)
        segments       = fetch_customer_segments(conn_ctx)
        balance_dist   = fetch_account_balance_dist(conn_ctx)
        hourly         = fetch_hourly_pattern(conn_ctx)
        top_customers  = fetch_top_customers(conn_ctx)
    except Exception as exc:
        logger.error(f"Data fetch failed: {exc}")
        sys.exit(1)

    logger.info("Building report …")
    html = build_report(
        kpis, monthly, branch, txn_type,
        segments, balance_dist, hourly, top_customers
    )

    # Determine output path
    if args.output:
        out_path = Path(args.output)
    else:
        from config import EXPORTS_DIR
        EXPORTS_DIR.mkdir(parents=True, exist_ok=True)
        out_path = EXPORTS_DIR / "eda_report.html"

    out_path.write_text(html, encoding="utf-8")
    logger.info(f"✅  Report saved: {out_path}")

    if not args.no_open:
        webbrowser.open(out_path.as_uri())
        logger.info("Opened in browser.")


if __name__ == "__main__":
    main()
