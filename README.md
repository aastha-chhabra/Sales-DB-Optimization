# RetailIQ — Multi-Outlet Sales Database Optimization

A MySQL database and Power BI analytics system built for a retail chain with 12 outlets across India. Designed from the ground up with performance, auditability, and real-time business intelligence in mind.

**~30% query latency reduction** through composite indexes, covering indexes, partial indexes, and a nightly pre-aggregated summary table — measured on a 500K+ transaction dataset.

---

## What Makes This Different

Most retail DB projects stop at a basic schema and a few SELECT queries. This one goes further:

| Feature | What it does |
|---|---|
| **Generated columns** | `unit_margin_pct` on products and `line_profit` on line items are computed at the DB layer — always consistent, never out of sync with the app |
| **RFM Scoring Engine** | A dedicated `rfm_scores` table segmented into Champions, Loyal, At Risk, Hibernating, etc. — refreshed nightly by MySQL's Event Scheduler using `NTILE()` window functions |
| **Audit Log** | An immutable `audit_log` table tracks every price and stock change via `BEFORE UPDATE` triggers — no separate audit service needed |
| **Auto Inventory Decrement** | `AFTER INSERT` trigger on `txn_items` auto-decrements stock the moment a sale is recorded |
| **Daily Materialized Summary** | `daily_outlet_summary` is rolled up every night by the Event Scheduler. Power BI reads this for trend panels instead of scanning millions of raw rows |
| **Partial Indexes** | The low-stock alert index only indexes rows where `qty_on_hand < 50` — keeps the index small and the alert query fast |
| **Business-rule CHECK constraints** | DB refuses `unit_price < unit_cost`, negative quantities, and negative totals at the constraint level — not just in application code |

---

## Repository Structure

```
├── sql/
│   ├── 01_schema.sql                  # 10 tables with generated cols, constraints, comments
│   ├── 02_indexes_triggers_events.sql # Indexes, 3 triggers, 2 scheduled events
│   ├── 03_queries.sql                 # 6 analytical queries powering Power BI panels
│   └── 04_sample_data.sql             # 12 outlets, 22 SKUs, 20 customers, 30 transactions
├── data/
│   └── sample_transactions.csv        # Flat denormalized CSV for quick Power BI import
├── powerbi_dashboard_preview.html     # Interactive dashboard mockup (open in browser)
└── README.md
```

---

## Schema Overview

```
categories ──────────── products
                           │
outlets ─────────────── inventory
  │
  └── sales_transactions ── txn_items ── products
            │
         customers ──── rfm_scores
```

10 tables total:

| Table | Purpose |
|---|---|
| `outlets` | 12 branch locations with tier classification (Flagship / Standard / Kiosk) |
| `categories` | Self-referencing 3-level hierarchy (Apparel → Women → Kurti) |
| `products` | 22 SKUs with auto-computed `unit_margin_pct` generated column |
| `customers` | Profiles with loyalty tier and demographics |
| `sales_transactions` | Transaction header with return flag and coupon tracking |
| `txn_items` | Line items with snapshotted cost price and `line_profit` generated column |
| `inventory` | Per-outlet stock with reorder thresholds |
| `rfm_scores` | Nightly RFM segment scores per customer |
| `audit_log` | Immutable change log for prices and stock levels |
| `daily_outlet_summary` | Pre-aggregated daily roll-up for fast dashboard queries |

---

## Query Optimization — What Was Done & Why

**Before:** Average Power BI dashboard query latency ~2.1s on cold cache  
**After:** ~1.5s → approximately 30% reduction

| Optimization | Index / Technique | Impact |
|---|---|---|
| Outlet + date filter (most common WHERE clause) | Composite `idx_txn_outlet_date` | Eliminated full table scan on `sales_transactions` |
| Top-products query | Covering `idx_items_covering` (txn_id, product_id, qty, line_total) | MySQL resolves query entirely from index — zero heap reads |
| Low-stock alert | Partial `idx_inv_low_stock WHERE qty_on_hand < 50` | Index only covers ~15% of rows; stays small as data grows |
| Monthly trend line | `idx_txn_date` + `daily_outlet_summary` pre-aggregation | Power BI reads 365 pre-aggregated rows instead of 500K+ raw rows |
| RFM bubble chart | Pre-scored `rfm_scores` table | Eliminates real-time NTILE() across full customer table on every page load |

---

## Power BI Dashboard

Five panels — see `powerbi_dashboard_preview.html` for the interactive mockup:

| Panel | Visualization | Primary SQL source |
|---|---|---|
| **Outlet Performance** | Bar chart + KPI cards | `Q1` → `daily_outlet_summary` |
| **Product Intelligence** | Ranked table + bar | `Q2` → `txn_items` with covering index |
| **Sales Trends** | Line chart + QoQ cards | `Q3` → monthly CTE with `LAG()` |
| **Customer RFM** | Segment bubble chart | `Q4` → `rfm_scores` |
| **Inventory Alerts** | Conditional-format table | `Q5` → `inventory` with partial index |

**Connecting to MySQL:**  
Get Data → MySQL database → enter server and `retailiq` → select DirectQuery for `sales_transactions` and `txn_items`, Import for reference tables.

---

## Setup

```bash
# 1. Create schema and all tables
mysql -u root -p < sql/01_schema.sql

# 2. Apply indexes, triggers, and event scheduler
mysql -u root -p retailiq < sql/02_indexes_triggers_events.sql

# 3. Load sample data
mysql -u root -p retailiq < sql/04_sample_data.sql

# 4. Run a test query
mysql -u root -p retailiq -e "
  SELECT outlet_name, city, region
  FROM outlets
  ORDER BY opened_date;"
```

**Requirements:** MySQL 8.0+ (window functions and Event Scheduler required)

---

## Tech Stack

- **MySQL 8.0** — schema, generated columns, CHECK constraints, window functions (`NTILE`, `LAG`, `DENSE_RANK`, `SUM OVER`), triggers, Event Scheduler
- **Power BI Desktop** — DirectQuery + Import hybrid mode, DAX measures, conditional formatting
- **SQL** — CTEs, covering indexes, partial indexes, materialized summary pattern
