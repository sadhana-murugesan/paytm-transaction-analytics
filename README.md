# Fintech Transaction Analytics — SQL & Excel

Analysis of 25,000 digital payment transactions (UPI, Wallet, Card, Netbanking) modeled on a
Paytm-style payments platform. Built as a portfolio project to demonstrate SQL and Excel
skills for a Data Analyst role.

## Problem Statement

Digital payment platforms process millions of transactions daily across multiple payment
methods, merchant categories, and cities. This project answers common business questions a
payments analyst would face:

- Which payment methods and merchant categories drive the most volume and value?
- When do transactions peak, and where do failures cluster?
- What does fraud risk look like across transaction type and time of day?
- Who are the highest-value customers, and how can they be segmented?

## Dataset

`data/transactions.csv` — 25,000 rows, synthetically generated to mirror the statistical
patterns of real UPI/wallet transaction data (skewed amount distributions, evening peak
hours, type-specific failure rates, and time/amount-correlated fraud). Generation logic is
in the repo so the process is fully transparent and reproducible.

| Column              | Description                                  |
|---------------------|-----------------------------------------------|
| transaction_id      | Unique transaction identifier                 |
| timestamp           | Date and time of transaction                  |
| sender_id           | Anonymized customer ID                        |
| receiver_id         | Anonymized merchant or peer ID                |
| transaction_type    | UPI / Wallet / Card / Netbanking               |
| merchant_category   | e.g. Recharge, Grocery, Travel, Bill Payment  |
| amount              | Transaction amount (₹)                        |
| status              | Success / Failed                              |
| city                | Transaction origin city                       |
| device_type         | Android / iOS / Web                           |
| is_fraud            | 1 if flagged fraudulent, else 0               |
## Dashboard Screenshots

### Monthly Transaction Value Trend
![Monthly Transaction Value Trend](images/monthly%20transaction%20value%20trend.png)

### Fraud Analysis
![Fraud Analysis](images/fraud%20analysis.png)

### Peak Transaction Hour
![Peak Transaction Hour](images/peak%20transaction%20hour.png)
## Tools Used

- **SQL** (SQLite-compatible, portable to PostgreSQL/MySQL) — aggregation, filtering,
  window functions, CTEs
- **Excel** (openpyxl-built, fully formula-driven) — pivot-style summaries and charts
- **Python/pandas** — dataset generation only

## Repo Structure

```
paytm-transaction-analytics/
├── data/
│   └── transactions.csv          25,000-row dataset
├── sql/
│   └── analysis_queries.sql      18 queries: schema, filters, aggregates, window fns, CTEs
├── excel/
│   └── transaction_dashboard.xlsx  6-sheet workbook with formulas + charts
├── images/
│   └── (dashboard screenshots)
├── README.md
└── insights.md                   Key findings write-up
```

## Key Findings

- Total transaction value analyzed: **₹1.52 crore** across 25,000 transactions.
- **UPI dominates volume** — 55% of all transactions and 55% of total value (₹83.4 lakh),
  consistent with real-world UPI adoption trends.
- **Card transactions fail most often** (7.2% failure rate) vs. Wallet, the most reliable
  method (2.9% failure rate).
- **Fraud is 3.4x more likely during late-night hours (11 PM–5 AM)** than during the rest
  of the day (2.39% vs 0.71% fraud rate) — a clear signal for time-based fraud rules.
- **5 PM is the peak transaction hour**, aligning with post-work bill payments and
  recharges.
- **Travel, Shopping, and P2P Transfer** are the top 3 merchant categories by total value.

Full breakdown in [`insights.md`](insights.md).

## How to Reproduce

1. Load `data/transactions.csv` into any SQL database (schema in `sql/analysis_queries.sql`).
2. Run the queries in `sql/analysis_queries.sql` section by section.
3. Open `excel/transaction_dashboard.xlsx` — all values are live formulas referencing the
   raw data sheet, so they recalculate if data changes.

## About This Project

Built as part of interview preparation for a Data Analyst role, applying SQL fundamentals
(SELECT, filtering, sorting, aggregation, GROUP BY/HAVING, window functions, CTEs) and
Excel dashboarding skills to a realistic fintech dataset.
