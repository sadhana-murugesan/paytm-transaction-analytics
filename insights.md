# Key Insights

## 1. Volume & Value by Payment Method

| Type       | Share of Value | Avg Ticket Size (₹) |
|------------|-----------------|----------------------|
| UPI        | 54.7%           | 607.68               |
| Wallet     | 19.7%           | 605.19               |
| Card       | 14.8%           | 598.94               |
| Netbanking | 10.8%           | 650.61               |

UPI is the dominant rail by both count and value, mirroring real-world UPI adoption in
India. Average ticket sizes are similar across methods (₹599–₹651), suggesting payment
method choice is driven more by convenience/context than transaction size.

## 2. Reliability: Where Failures Cluster

| Type       | Failure Rate |
|------------|--------------|
| Card       | 7.23%        |
| Netbanking | 5.98%        |
| UPI        | 3.89%        |
| Wallet     | 2.88%        |

Card and Netbanking fail roughly 2x more often than UPI/Wallet — likely due to
bank-side authentication steps (OTP timeouts, gateway redirects) that UPI/Wallet flows
avoid. **Recommendation:** prioritize UX improvements (retry flows, better error
messaging) on Card and Netbanking checkout paths.

## 3. Fraud Risk Is Strongly Time-Dependent

- Overall fraud rate: **0.80%**
- Late night (11 PM–5 AM): **2.39%**
- Rest of day: **0.71%**

Fraud is **3.4x more likely** during late-night hours. Combined with the fact that fraud
probability was also modeled to increase with transaction amount, this supports a
risk-scoring rule that flags high-amount + late-night + Card transactions for extra
verification.

## 4. Peak Activity

- **Peak hour: 5 PM (17:00)** — consistent with users making payments after work hours.
- Transaction volume builds steadily from 6 AM, peaks in the early evening, and tapers
  off after 10 PM.

## 5. Top Merchant Categories by Value

1. Travel — ₹32.1 lakh
2. Shopping — ₹29.4 lakh
3. P2P Transfer — ₹29.2 lakh
4. Insurance — ₹13.5 lakh
5. Bill Payment — ₹12.9 lakh

High-ticket categories (Travel, Insurance) contribute disproportionately to total value
despite lower transaction counts than categories like Recharge or Grocery.

## 6. Geographic Spread

Value is fairly evenly distributed across the top 5 cities (Hyderabad, Lucknow,
Ahmedabad, Kolkata, Mumbai all within ₹15.3–16.2 lakh), suggesting the (synthetic)
customer base has no single dominant metro — useful as a baseline before overlaying
real regional demand patterns.

## 7. Device Usage

- Android: 68.0%
- iOS: 25.2%
- Web: 6.8%

Mobile-first usage pattern (93.2% combined) reflects typical fintech app behavior —
web/desktop checkout is a minority use case.

## 8. Customer Segmentation

Using the CTE in `sql/analysis_queries.sql` (section 6.2), customers are segmented into:
- **High-Value**: avg transaction value > ₹5,000
- **Frequent Low-Value**: more than 5 transactions but lower average ticket
- **Occasional**: everyone else

The top spender in the dataset had a total spend of ~₹51,589 across their transactions —
useful for identifying VIP customer cohorts for retention campaigns.

---
*All figures generated from `data/transactions.csv` using the queries in
`sql/analysis_queries.sql` and cross-checked in `excel/transaction_dashboard.xlsx`.*
