# =============================================================================
# Bank Management System — Project Structure
# =============================================================================
#
# A comprehensive guide to every file and directory in this repository.
# =============================================================================

```
Bank Management System/
│
├── 📄 app.py                    # Main entry point — launches the Tkinter GUI
├── 📄 config.py                 # Central config: colors, fonts, paths, banking rules
├── 📄 database.py               # DB layer: connection pool, QueryExecutor, BaseRepository
├── 📄 db_config.py              # MySQL credentials loader (reads from .env)
├── 📄 utils.py                  # Shared utilities: validation, hashing, PDF/CSV/Excel export
├── 📄 generate_data.py          # Synthetic data generator (Faker — 500 customers, 3 000 txns)
├── 📄 setup_db.py               # One-command DB schema initializer
│
├── 📊 ANALYTICS & REPORTING
├── 📄 analytics_dashboard.py    # In-app analytics dashboard (Matplotlib + Seaborn charts)
├── 📄 interactive_charts.py     # Browser-based interactive charts (Plotly HTML)
├── 📄 powerbi_streamer.py       # Real-time Power BI data streamer / simulator
├── 📄 powerbi_setup_guide.md    # Step-by-step Power BI DirectQuery integration guide
│
├── 📁 analysis/                 # ★ Data Analyst showcase scripts
│   ├── 📄 eda_report.py         # Standalone EDA → generates exports/eda_report.html
│   └── 📄 sql_showcase.sql      # Curated advanced SQL (CTEs, window functions, segmentation)
│
├── 🖥️ GUI VIEWS
├── 📄 login.py                  # Login screen with role-based auth
├── 📄 register.py               # Customer & employee registration forms
├── 📄 admin_dashboard.py        # Admin overview dashboard
├── 📄 customer_dashboard.py     # Customer portal entry
├── 📄 employee_dashboard.py     # Employee portal entry
├── 📄 account.py                # Account management view
├── 📄 customer.py               # Customer management view
├── 📄 employee.py               # Employee management view
├── 📄 branch.py                 # Branch management view
├── 📄 deposit.py                # Deposit transaction view
├── 📄 withdraw.py               # Withdrawal transaction view
├── 📄 transfer.py               # Fund transfer view
├── 📄 upi.py                    # UPI payment view
├── 📄 loan.py                   # Loan management view
├── 📄 fixed_deposit.py          # Fixed deposit view
├── 📄 atm.py                    # ATM card management view
├── 📄 card.py                   # Card services view
├── 📄 beneficiary.py            # Beneficiary management view
├── 📄 mini_statement.py         # Mini statement / passbook view
├── 📄 reports.py                # Reports view
├── 📄 profile.py                # User profile view
├── 📄 change_pin.py             # PIN change view
│
├── 🗄️ database/                 # MySQL schema — all SQL scripts
│   ├── 📄 create_database.sql   # CREATE DATABASE BankDB
│   ├── 📄 create_tables.sql     # All 15+ table definitions (DDL)
│   ├── 📄 constraints.sql       # Foreign key & check constraints
│   ├── 📄 indexes.sql           # Performance indexes
│   ├── 📄 views.sql             # 11 analytical views (v_branch_performance, etc.)
│   ├── 📄 functions.sql         # SQL scalar functions
│   ├── 📄 triggers.sql          # Audit & business rule triggers
│   ├── 📄 stored_procedures.sql # Stored procs (sp_transfer_funds, etc.)
│   └── 📄 sample_data.sql       # Seed data for roles, admin user, initial branches
│
├── 📁 assets/                   # UI assets (icons, images)
├── 📁 exports/                  # Runtime: CSV/PDF/PNG/HTML exports (git-ignored)
├── 📁 reports/                  # Runtime: generated reports (git-ignored)
├── 📁 statements/               # Runtime: account statements (git-ignored)
├── 📁 logs/                     # Runtime: application logs (git-ignored)
├── 📁 tests/                    # Unit & integration tests
│
├── 📄 .env.example              # ← Copy to .env and fill in your DB credentials
├── 📄 .gitignore                # Excludes secrets, venv, logs, exports
├── 📄 requirements.txt          # Python dependencies (pinned)
├── 📄 LICENSE                   # MIT License
└── 📄 README.md                 # ← Start here
```
