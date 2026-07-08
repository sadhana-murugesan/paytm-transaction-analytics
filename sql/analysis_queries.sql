/* =========================================================
   Paytm-Style Transaction Analytics — SQL Analysis
   Dataset: data/transactions.csv (25,000 rows)
   Compatible with: PostgreSQL / MySQL / SQLite
   ========================================================= */

-- ---------------------------------------------------------
-- 1. SCHEMA
-- ---------------------------------------------------------
CREATE TABLE transactions (
    transaction_id      VARCHAR(20) PRIMARY KEY,
    timestamp            DATETIME,
    sender_id             VARCHAR(20),
    receiver_id           VARCHAR(20),
    transaction_type     VARCHAR(20),   -- UPI, Wallet, Card, Netbanking
    merchant_category     VARCHAR(30),
    amount                DECIMAL(12,2),
    status                VARCHAR(10),   -- Success, Failed
    city                  VARCHAR(30),
    device_type           VARCHAR(10),   -- Android, iOS, Web
    is_fraud              INT            -- 0 or 1
);

-- Load data (Postgres example):
-- COPY transactions FROM 'data/transactions.csv' DELIMITER ',' CSV HEADER;


-- ---------------------------------------------------------
-- 2. BASIC EXPLORATION (SELECT, filtering, sorting)
-- ---------------------------------------------------------

-- 2.1 Preview the data
SELECT * FROM transactions LIMIT 10;

-- 2.2 All failed high-value transactions, most recent first
SELECT transaction_id, timestamp, transaction_type, amount, status
FROM transactions
WHERE status = 'Failed' AND amount > 5000
ORDER BY timestamp DESC
LIMIT 20;

-- 2.3 Distinct transaction types and cities covered
SELECT DISTINCT transaction_type FROM transactions;
SELECT DISTINCT city FROM transactions ORDER BY city;


-- ---------------------------------------------------------
-- 3. AGGREGATIONS (GROUP BY / HAVING)
-- ---------------------------------------------------------

-- 3.1 Total volume and value by transaction type
SELECT
    transaction_type,
    COUNT(*)               AS total_transactions,
    ROUND(SUM(amount), 2)  AS total_value,
    ROUND(AVG(amount), 2)  AS avg_ticket_size
FROM transactions
GROUP BY transaction_type
ORDER BY total_value DESC;

-- 3.2 Success vs Failure rate by transaction type
SELECT
    transaction_type,
    status,
    COUNT(*) AS txn_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY transaction_type), 2) AS pct_within_type
FROM transactions
GROUP BY transaction_type, status
ORDER BY transaction_type, status;

-- 3.3 Merchant categories with more than 1,500 transactions (HAVING)
SELECT
    merchant_category,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_value
FROM transactions
GROUP BY merchant_category
HAVING COUNT(*) > 1500
ORDER BY txn_count DESC;

-- 3.4 City-wise revenue ranking
SELECT
    city,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_value,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
WHERE status = 'Success'
GROUP BY city
ORDER BY total_value DESC;


-- ---------------------------------------------------------
-- 4. TIME-BASED ANALYSIS (date functions)
-- ---------------------------------------------------------

-- 4.1 Monthly transaction trend
SELECT
    strftime('%Y-%m', timestamp) AS month,     -- MySQL: DATE_FORMAT(timestamp,'%Y-%m'); Postgres: TO_CHAR(timestamp,'YYYY-MM')
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_value
FROM transactions
GROUP BY month
ORDER BY month;

-- 4.2 Peak transaction hours (0-23)
SELECT
    CAST(strftime('%H', timestamp) AS INTEGER) AS hour_of_day,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY hour_of_day
ORDER BY txn_count DESC;

-- 4.3 Day-of-week pattern
SELECT
    CASE CAST(strftime('%w', timestamp) AS INTEGER)
        WHEN 0 THEN 'Sunday' WHEN 1 THEN 'Monday' WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday' END AS day_name,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_value
FROM transactions
GROUP BY day_name
ORDER BY txn_count DESC;


-- ---------------------------------------------------------
-- 5. FRAUD ANALYSIS
-- ---------------------------------------------------------

-- 5.1 Fraud rate by transaction type
SELECT
    transaction_type,
    COUNT(*) AS total_txns,
    SUM(is_fraud) AS fraud_txns,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 3) AS fraud_rate_pct
FROM transactions
GROUP BY transaction_type
ORDER BY fraud_rate_pct DESC;

-- 5.2 Fraud rate by hour bucket (late night vs day)
SELECT
    CASE
        WHEN CAST(strftime('%H', timestamp) AS INTEGER) BETWEEN 23 AND 24
             OR CAST(strftime('%H', timestamp) AS INTEGER) < 5 THEN 'Late Night (11PM-5AM)'
        ELSE 'Rest of Day'
    END AS time_bucket,
    COUNT(*) AS total_txns,
    SUM(is_fraud) AS fraud_txns,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 3) AS fraud_rate_pct
FROM transactions
GROUP BY time_bucket;

-- 5.3 Average amount: fraud vs non-fraud
SELECT
    is_fraud,
    COUNT(*) AS txn_count,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
GROUP BY is_fraud;


-- ---------------------------------------------------------
-- 6. CUSTOMER-LEVEL ANALYSIS (window functions, CTE)
-- ---------------------------------------------------------

-- 6.1 Top 10 senders by total spend
SELECT
    sender_id,
    COUNT(*) AS txn_count,
    ROUND(SUM(amount), 2) AS total_spend
FROM transactions
WHERE status = 'Success'
GROUP BY sender_id
ORDER BY total_spend DESC
LIMIT 10;

-- 6.2 Customer segmentation: high-value vs frequent low-value (CTE)
WITH customer_stats AS (
    SELECT
        sender_id,
        COUNT(*) AS txn_count,
        ROUND(SUM(amount), 2) AS total_spend,
        ROUND(AVG(amount), 2) AS avg_txn_value
    FROM transactions
    WHERE status = 'Success'
    GROUP BY sender_id
)
SELECT
    sender_id, txn_count, total_spend, avg_txn_value,
    CASE
        WHEN avg_txn_value > 5000 THEN 'High-Value'
        WHEN txn_count > 5 THEN 'Frequent Low-Value'
        ELSE 'Occasional'
    END AS customer_segment
FROM customer_stats
ORDER BY total_spend DESC
LIMIT 20;

-- 6.3 Running monthly total using window function
SELECT
    month,
    monthly_value,
    ROUND(SUM(monthly_value) OVER (ORDER BY month), 2) AS running_total
FROM (
    SELECT
        strftime('%Y-%m', timestamp) AS month,
        SUM(amount) AS monthly_value
    FROM transactions
    WHERE status = 'Success'
    GROUP BY month
) monthly
ORDER BY month;

-- 6.4 Rank each transaction type's top merchant category by value (window function)
SELECT * FROM (
    SELECT
        transaction_type,
        merchant_category,
        SUM(amount) AS category_value,
        RANK() OVER (PARTITION BY transaction_type ORDER BY SUM(amount) DESC) AS rnk
    FROM transactions
    GROUP BY transaction_type, merchant_category
) ranked
WHERE rnk = 1;
