# Power BI Real-Time Dashboard Integration Guide

This guide explains how to connect **Power BI Desktop** or **Power BI Service** to your **Bank Management System (`BankDB`)** for real-time analytics.

---

## 🚀 Quick Start (Option 1: DirectQuery Mode - Recommended)

### 1. Open the PBIDS File
Double-click [exports/BankDB_DirectQuery.pbids](file:///c:/Users/giras/Bank%20management%20system/exports/BankDB_DirectQuery.pbids). Power BI Desktop will open automatically with pre-configured settings:
- **Server**: `localhost` (or your MySQL Server IP)
- **Database**: `BankDB`
- **Data Connectivity Mode**: `DirectQuery`

### 2. Enter Database Credentials
When prompted by Power BI:
1. Select **Database** on the left menu.
2. User Name: `root` (or your `DB_USER` from `.env`).
3. Password: *(Your MySQL root password)*.
4. Click **Connect**.

---

## 📊 Recommended Tables & Views for Power BI

Select the following tables/views when building your Power BI reports:

| Table / View Name | Purpose in Power BI | Real-Time Usage |
| :--- | :--- | :--- |
| `transactions` / `v_transaction_detail` | **Fact Table** (Amount, Tx Type, Date, Channel, Status) | Live Transaction Flow & Volume |
| `accounts` / `v_account_summary` | **Dimension Table** (Account Balances, Types, Status) | Total Deposits & Active Accounts |
| `customers` | **Dimension Table** (Customer Details, Demographics) | Customer Count & Portfolio |
| `branches` / `v_branch_performance` | **Dimension Table** (Branch Balances & Loans) | Regional & Branch KPIs |

---

## ⚡ Enabling Real-Time Dashboard Auto-Refresh in Power BI

To make your visuals update in **real-time** whenever transactions occur:

1. Open your report in **Power BI Desktop**.
2. Click on a page canvas background (ensure no visual is selected).
3. Open the **Format Page** pane on the right menu.
4. Expand **Page Refresh** (or **Automatic Page Refresh**).
5. Toggle it **ON**.
6. Set the refresh interval (e.g., **Every 1 second** or **Every 5 seconds**).
7. Now, every change in the MySQL database will reflect on your dashboard live!

---

## 🧪 Testing Real-Time Data Flow (Simulator)

You can run the built-in real-time simulator to watch transactions flow live into your Power BI dashboard:

```bash
python powerbi_streamer.py --simulate --interval 2.0 --count 20
```

This command will inject 20 live transactions (deposits, withdrawals, transfers) into `BankDB`. If your Power BI report has **Page Refresh** enabled, you will see the total volume, balances, and charts update in real-time!

---

## 🌐 Option 2: Power BI REST API Real-Time Streaming

If you want to stream data directly into Power BI Service without DirectQuery:

1. Log into [Power BI Service](https://app.powerbi.com/).
2. Navigate to **My Workspace** -> **New** -> **Streaming dataset**.
3. Choose **API** as the data source.
4. Name the dataset `BankDB_RealTimeStream` and define fields (`timestamp`, `today_volume`, `today_transactions`, `total_deposits`).
5. Copy the generated **Push URL**.
6. Run the streamer script with your Push URL:

```bash
python powerbi_streamer.py --simulate --stream-url "https://api.powerbi.com/beta/..."
```

---

## 📁 Key Project Files

- **Streamer Module**: [powerbi_streamer.py](file:///c:/Users/giras/Bank%20management%20system/powerbi_streamer.py)
- **Power BI Data Source File**: [exports/BankDB_DirectQuery.pbids](file:///c:/Users/giras/Bank%20management%20system/exports/BankDB_DirectQuery.pbids)
- **Database Configuration**: [db_config.py](file:///c:/Users/giras/Bank%20management%20system/db_config.py)
