# 🏦 Bank Management System

<div align="center">

![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-5.x-3F4F75?style=for-the-badge&logo=plotly&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-3.9+-11557C?style=for-the-badge&logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00d4aa?style=for-the-badge)

**A full-stack banking application with a live analytics engine, interactive dashboards,
Power BI integration, and an advanced SQL analytics layer — built to demonstrate
end-to-end Data Analyst skills.**

[Features](#-features) · [Analytics](#-data-analytics-capabilities) · [Database Design](#-database-design) · [Quick Start](#-quick-start) · [Project Structure](#-project-structure) · [Tech Stack](#-tech-stack)

</div>

---

## ✨ Features

| Module | Highlights |
|---|---|
| 🔐 **Role-Based Auth** | Secure login for Admin, Employee, and Customer with bcrypt hashing and session lockout |
| 📊 **Live Analytics Dashboard** | KPI cards, deposit/withdrawal bar chart, monthly trend line, branch distribution pie — all filterable by date range and branch |
| 🌐 **Interactive HTML Charts** | Full Plotly dashboard opens in-browser: treemap, waterfall, scatter, heatmap, and more |
| 📈 **EDA Report Generator** | One-command script → rich HTML exploratory report (9 chart sections, executive KPIs) |
| 🗄️ **Advanced SQL Layer** | 11 analytical views, stored procedures, triggers, and a curated showcase of 11 advanced DA queries |
| 📤 **Multi-Format Export** | Download analytics as PDF, CSV, or PNG from the dashboard |
| ⚡ **Power BI Integration** | Real-time DirectQuery mode + streaming simulator to feed live dashboards |
| 🧪 **Synthetic Data Generator** | Faker-powered script generates 500 customers, 500 accounts, and 3 000 transactions |
| 🏗️ **Production-Grade Architecture** | Connection pooling, Repository Pattern, Audit Logging, thread-safe singletons |

---

## 📊 Data Analytics Capabilities

This project demonstrates a **full Data Analyst workflow** from raw data to insight:

### 1. In-App Analytics Dashboard
The `analytics_dashboard.py` module delivers a live Matplotlib/Seaborn dashboard embedded in the Tkinter UI, featuring:
- **KPI Summary Cards** — total transactions, inflow, outflow, net flow
- **Bar Chart** — deposit vs withdrawal volume comparison
- **Line Chart** — monthly transaction volume trend with hover tooltips
- **Pie Chart** — customer distribution by branch
- **Filters** — branch selector, period selector (30/90/180 days, custom range)
- **Export** — one-click PDF, CSV, and PNG download

### 2. Interactive Plotly Charts
Launch from the dashboard → `interactive_charts.py` generates browser-based HTML charts:
- Volume waterfall chart
- Branch performance radar
- Transaction type treemap
- Customer scatter segmentation
- Rolling average trend

### 3. EDA Report (`analysis/eda_report.py`)
Run once to generate `exports/eda_report.html` — a 9-section exploratory dashboard:

```
📊 Executive KPI Snapshot
📈 Monthly Inflow / Outflow / Net Trend
🏦 Branch Performance (Deposits + Loans)
🍩 Customer Distribution by Branch
🌳 Transaction Treemap (Channel → Type)
🎯 Credit Score Segmentation
💰 Account Balance Distribution
⏰ Peak Hour Analysis
🏆 Top 15 Customers by Balance
```

### 4. SQL Analytics Showcase (`analysis/sql_showcase.sql`)
11 production-quality SQL queries demonstrating advanced DA techniques:

| Query | Technique |
|---|---|
| Monthly Revenue Trend + MoM Growth | `CTE` + `LAG()` window function |
| Customer Segmentation | `NTILE(4)` + `CASE` labelling |
| Branch Performance Ranking | `DENSE_RANK()` + multi-metric scoring |
| Rolling 30-Day Average | `AVG() OVER (ROWS BETWEEN 29 PRECEDING)` |
| Channel Share Analysis | Aggregate + `SUM() OVER ()` for % share |
| Customer Churn Detection | `DATEDIFF` + multi-tier CASE classification |
| Top N per Branch | `ROW_NUMBER() OVER (PARTITION BY branch)` |
| Loan Default Risk Scoring | Composite weighted scoring + CASE bucketing |
| Cohort Retention Analysis | Cohort month CTE + retention rate |
| Executive KPI One-Shot | Multiple subqueries in a single SELECT |
| Peak Hour Analysis | `HOUR()` time-bucketing + dual-axis |

### 5. Power BI Real-Time Integration
See [`powerbi_setup_guide.md`](powerbi_setup_guide.md) for DirectQuery setup and real-time streaming:
```bash
python powerbi_streamer.py --simulate --interval 2.0 --count 20
```

---

## 🗄️ Database Design

The MySQL schema (`database/`) is engineered for analytics workloads:

```
database/
├── create_tables.sql      # 15+ normalised tables with full DDL
├── constraints.sql        # Foreign keys + CHECK constraints
├── indexes.sql            # 20+ indexes for query performance
├── views.sql              # 11 analytical views (Power BI / dashboard ready)
├── functions.sql          # Scalar SQL functions
├── triggers.sql           # Audit trail + business rule enforcement
├── stored_procedures.sql  # sp_transfer_funds (atomic), sp_process_emi, ...
└── sample_data.sql        # Seed roles, admin, initial branches
```

### Key Tables

```sql
customers       — demographics, KYC, credit score, annual income
accounts        — savings/current/salary, balance, status, branch
transactions    — amount, type, channel, reference, before/after balance
loans           — principal, outstanding, EMI, disbursement, risk
branches        — city, state, IFSC, manager, employees
employees       — role, designation, department, salary
fixed_deposits  — principal, tenure, compounding, maturity
atm_cards       — card network, limits, expiry, contactless
audit_logs      — every user action timestamped
```

### 11 Analytical Views (ready for Power BI / Tableau)

| View | Purpose |
|---|---|
| `v_account_summary` | Accounts + customer + branch joined |
| `v_transaction_detail` | Full transaction history with names |
| `v_customer_portfolio` | Per-customer: balance, loans, FDs, cards |
| `v_loan_summary` | Loan + completion %, outstanding |
| `v_branch_performance` | Branch KPIs: deposits, loans, employees |
| `v_employee_details` | Employee + role + years of service |
| `v_active_cards` | Cards with days-to-expiry |
| `v_fd_summary` | FD maturity tracking |
| `v_monthly_report` | Power BI–ready aggregated monthly view |
| `v_inactive_accounts` | Accounts dormant > 365 days |
| `v_top_customers` | Balance-ranked with RANK() window |

---

## 🏗️ Architecture Overview

```
┌───────────────────────────────────────────────────────┐
│                   Tkinter GUI Layer                   │
│  login · register · admin_dashboard · analytics ···   │
└──────────────────────────┬────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────┐
│                  Service / View Layer                  │
│  deposit · withdraw · transfer · loan · upi · card ···│
└──────────────────────────┬────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────┐
│               Database Layer (database.py)             │
│  ConnectionPool · QueryExecutor · BaseRepository       │
│  AuditLogger · get_db_connection() · get_transaction() │
└──────────────────────────┬────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────┐
│               MySQL 8.0 — BankDB                       │
│  15+ Tables · 11 Views · Triggers · Stored Procs       │
└───────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼───────────────────┐
        ▼                  ▼                   ▼
  analytics_dashboard  interactive_charts  analysis/
  (Matplotlib/Seaborn) (Plotly HTML)       eda_report.py
                                           sql_showcase.sql
                                           Power BI (DirectQuery)
```

---

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- MySQL 8.0+ (running locally or remotely)
- Git

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/bank-management-system.git
cd bank-management-system
```

### 2. Create a Virtual Environment & Install Dependencies
```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
```

### 3. Configure Environment Variables
```bash
cp .env.example .env
# Edit .env with your MySQL credentials
```

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=BankDB
DB_USER=root
DB_PASSWORD=your_password
```

### 4. Initialise the Database
```bash
# Creates all tables, views, triggers, stored procedures, and seed data
python setup_db.py
```

### 5. Generate Synthetic Data (Optional but Recommended)
```bash
# Inserts 500 customers, 500 accounts, 3 000 transactions
python generate_data.py
```

### 6. Launch the Application
```bash
python app.py
```

**Default Admin Login:** `admin` / `Admin@1234`

---

### 🔬 Run the EDA Report (Data Analyst Showcase)
```bash
python analysis/eda_report.py
# → Opens exports/eda_report.html in your browser automatically
```

### ⚡ Power BI Real-Time Simulation
```bash
python powerbi_streamer.py --simulate --interval 2.0 --count 20
```

---

## 📁 Project Structure

See [`PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md) for a full annotated map.

```
bank-management-system/
├── app.py                   # Main entry point
├── config.py                # All constants, colors, paths
├── database.py              # DB pool, QueryExecutor, Repository
├── utils.py                 # Validation, hashing, export helpers
├── generate_data.py         # Faker synthetic data generator
├── setup_db.py              # One-command DB initialiser
│
├── analytics_dashboard.py   # In-app Matplotlib/Seaborn dashboard
├── interactive_charts.py    # Browser Plotly charts
├── powerbi_streamer.py      # Power BI real-time streamer
│
├── analysis/                # ★ Data Analyst showcase
│   ├── eda_report.py        # → generates exports/eda_report.html
│   └── sql_showcase.sql     # 11 advanced SQL queries
│
├── database/                # MySQL schema
│   ├── create_tables.sql
│   ├── views.sql            # 11 analytical views
│   ├── triggers.sql
│   ├── stored_procedures.sql
│   └── ...
│
├── .env.example             # Credential template
├── requirements.txt
└── LICENSE
```

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Language** | Python 3.11+ |
| **GUI Framework** | Tkinter + ttkbootstrap (dark theme) |
| **Database** | MySQL 8.0 (InnoDB, Connection Pooling) |
| **Data Analysis** | Pandas 2.x, NumPy |
| **Visualisation** | Matplotlib, Seaborn (embedded), Plotly (interactive HTML) |
| **Reporting** | ReportLab (PDF), OpenPyXL (Excel), CSV |
| **Security** | bcrypt (password hashing), parameterised queries |
| **Data Generation** | Faker (realistic Indian locale data) |
| **BI Integration** | Power BI DirectQuery + REST API streaming |
| **Environment** | python-dotenv |

---

## 📸 Screenshots

> **Add your own screenshots here!**
> Run the app, take screenshots of:
> - The Analytics Dashboard (charts visible)
> - The EDA HTML Report in the browser
> - The Admin Overview screen
>
> Then place them in `assets/screenshots/` and embed with:
> `![Analytics Dashboard](assets/screenshots/analytics_dashboard.png)`

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
See the open issues tab or submit a pull request.

---

## 📄 License

This project is licensed under the **MIT License** — see [`LICENSE`](LICENSE) for details.

---

<div align="center">

Built as a **Data Analyst portfolio project** showcasing SQL, Python analytics, data visualisation, ETL, and BI integration.

⭐ Star this repo if you find it useful!

</div>
