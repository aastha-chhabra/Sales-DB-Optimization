-- ================================================================
-- RetailIQ: Analytical Queries (Power BI Data Sources)
-- File    : 03_queries.sql
-- Engine  : MySQL 8.0+
--
-- Each query is named after the Power BI panel it feeds.
-- Parameters use :start_date / :end_date notation.
-- ================================================================

USE retailiq;


-- ================================================================
-- Q1. REVENUE BY OUTLET
--     Panel: "Outlet Performance" bar + map
--     Reads from: daily_outlet_summary (pre-aggregated)
--     Why pre-aggregated: avoids scanning millions of txn rows
--     on every Power BI page load. Event Scheduler keeps it fresh.
-- ================================================================
SELECT
    o.outlet_code,
    o.outlet_name,
    o.city,
    o.region,
    o.tier,
    SUM(s.txn_count)                            AS total_transactions,
    SUM(s.units_sold)                           AS total_units,
    SUM(s.gross_revenue)                        AS gross_revenue,
    SUM(s.net_revenue)                          AS net_revenue,
    SUM(s.total_discount)                       AS discounts_given,
    SUM(s.total_profit)                         AS gross_profit,
    ROUND(SUM(s.total_profit) /
          NULLIF(SUM(s.gross_revenue), 0) * 100, 2)   AS profit_margin_pct,
    ROUND(SUM(s.avg_basket_size * s.txn_count) /
          NULLIF(SUM(s.txn_count), 0), 2)             AS avg_basket_size,
    DENSE_RANK() OVER (ORDER BY SUM(s.net_revenue) DESC)       AS overall_rank,
    DENSE_RANK() OVER (PARTITION BY o.region
                       ORDER BY SUM(s.net_revenue) DESC)       AS regional_rank
FROM daily_outlet_summary s
JOIN outlets o ON s.outlet_id = o.outlet_id
WHERE s.summary_date BETWEEN :start_date AND :end_date
  AND o.is_active = 1
GROUP BY
    o.outlet_id, o.outlet_code, o.outlet_name,
    o.city, o.region, o.tier
ORDER BY net_revenue DESC;


-- ================================================================
-- Q2. TOP-SELLING PRODUCTS  (with profit contribution)
--     Panel: "Product Intelligence" ranked table
--     Uses covering index idx_items_covering — no heap reads
-- ================================================================
SELECT
    p.sku,
    p.product_name,
    c.category_name,
    p.brand,
    p.unit_margin_pct,                          -- generated column
    SUM(ti.qty)                                 AS units_sold,
    SUM(ti.line_total)                          AS revenue,
    SUM(ti.line_profit)                         AS profit,
    ROUND(SUM(ti.line_profit) /
          NULLIF(SUM(ti.line_total), 0) * 100, 2)     AS realised_margin_pct,
    -- Revenue share using window function (no subquery needed)
    ROUND(SUM(ti.line_total) /
          SUM(SUM(ti.line_total)) OVER () * 100, 2)   AS revenue_share_pct,
    -- Rank within category
    DENSE_RANK() OVER (PARTITION BY c.category_name
                       ORDER BY SUM(ti.qty) DESC)     AS category_rank
FROM txn_items ti
JOIN products p          ON ti.product_id = p.product_id
JOIN categories c        ON p.category_id = c.category_id
JOIN sales_transactions st ON ti.txn_id   = st.txn_id
WHERE st.txn_date BETWEEN :start_date AND :end_date
  AND st.return_flag = 0
GROUP BY
    p.product_id, p.sku, p.product_name,
    c.category_name, p.brand, p.unit_margin_pct
ORDER BY units_sold DESC
LIMIT 30;


-- ================================================================
-- Q3. MONTHLY & QUARTERLY TRENDS  (with growth rates)
--     Panel: "Sales Trends" line + column chart
--     Uses idx_txn_date; LAG() computes growth without self-join
-- ================================================================
WITH monthly AS (
    SELECT
        YEAR(txn_date)                          AS yr,
        QUARTER(txn_date)                       AS qtr,
        MONTH(txn_date)                         AS mth,
        DATE_FORMAT(txn_date, '%Y-%m')          AS yr_month,
        COUNT(DISTINCT txn_id)                  AS transactions,
        SUM(total_amt)                          AS gross_revenue,
        SUM(total_amt - discount_amt)           AS net_revenue,
        SUM(discount_amt)                       AS discounts
    FROM sales_transactions
    WHERE return_flag = 0
    GROUP BY yr, qtr, mth, yr_month
)
SELECT
    yr,
    qtr,
    mth,
    yr_month,
    transactions,
    gross_revenue,
    net_revenue,
    discounts,
    ROUND(
        (net_revenue - LAG(net_revenue) OVER (ORDER BY yr, mth)) /
        NULLIF(LAG(net_revenue) OVER (ORDER BY yr, mth), 0) * 100
    , 2)                                        AS mom_growth_pct,
    -- Quarterly total using SUM as window function
    SUM(net_revenue) OVER (
        PARTITION BY yr, qtr
        ORDER BY mth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                           AS qtd_revenue
FROM monthly
ORDER BY yr, mth;


-- ================================================================
-- Q4. RFM CUSTOMER SEGMENTATION
--     Panel: "Customer Intelligence" segment bubble chart
--     Reads from rfm_scores (pre-scored by Event Scheduler)
-- ================================================================

-- 4a. Segment distribution (latest scored_on date)
SELECT
    r.rfm_segment,
    COUNT(*)                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 2)             AS segment_share_pct,
    ROUND(AVG(r.monetary_value), 2)             AS avg_monetary_value,
    ROUND(AVG(r.purchase_frequency), 1)         AS avg_frequency,
    ROUND(AVG(r.days_since_last_purchase), 0)   AS avg_recency_days,
    c.loyalty_tier,
    COUNT(CASE WHEN c.loyalty_tier = 'Platinum' THEN 1 END) AS platinum_count
FROM rfm_scores r
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.scored_on = (SELECT MAX(scored_on) FROM rfm_scores)
GROUP BY r.rfm_segment, c.loyalty_tier
ORDER BY avg_monetary_value DESC;


-- 4b. Top 15 customers (Champions segment detail)
SELECT
    CONCAT(c.first_name, ' ', c.last_name)      AS customer_name,
    c.loyalty_tier,
    c.city,
    r.rfm_segment,
    r.monetary_value                            AS lifetime_value,
    r.purchase_frequency                        AS total_visits,
    r.days_since_last_purchase                  AS days_since_last_visit,
    r.r_score, r.f_score, r.m_score
FROM rfm_scores r
JOIN customers c ON r.customer_id = c.customer_id
WHERE r.scored_on   = (SELECT MAX(scored_on) FROM rfm_scores)
  AND r.rfm_segment IN ('Champions', 'Loyal Customers')
ORDER BY r.monetary_value DESC
LIMIT 15;


-- ================================================================
-- Q5. INVENTORY ALERT DASHBOARD
--     Panel: "Inventory Health" flagged table
--     Uses partial index idx_inv_low_stock
-- ================================================================
SELECT
    o.outlet_code,
    o.outlet_name,
    o.city,
    p.sku,
    p.product_name,
    c.category_name,
    i.qty_on_hand,
    i.reorder_level,
    i.reorder_qty,
    i.last_restocked,
    DATEDIFF(CURRENT_DATE, i.last_restocked)    AS days_since_restock,
    -- Estimated days of stock remaining (based on 30-day sales avg)
    ROUND(i.qty_on_hand /
          NULLIF(
              (SELECT SUM(ti.qty)
               FROM   txn_items ti
               JOIN   sales_transactions st ON ti.txn_id = st.txn_id
               WHERE  st.outlet_id  = i.outlet_id
                 AND  ti.product_id = i.product_id
                 AND  st.txn_date  >= CURRENT_DATE - INTERVAL 30 DAY
              ) / 30.0
          , 0)
    , 1)                                        AS est_days_remaining,
    CASE
        WHEN i.qty_on_hand  = 0                         THEN 'OUT OF STOCK'
        WHEN i.qty_on_hand  < i.reorder_level * 0.5     THEN 'CRITICAL'
        WHEN i.qty_on_hand  < i.reorder_level           THEN 'LOW'
        ELSE 'OK'
    END                                         AS stock_status
FROM inventory i
JOIN outlets    o ON i.outlet_id  = o.outlet_id
JOIN products   p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE i.qty_on_hand < i.reorder_level
  AND o.is_active   = 1
  AND p.is_active   = 1
ORDER BY
    FIELD(stock_status, 'OUT OF STOCK', 'CRITICAL', 'LOW'),
    i.qty_on_hand ASC;


-- ================================================================
-- Q6. PAYMENT METHOD MIX  (for payment-split donut chart)
-- ================================================================
SELECT
    payment_method,
    COUNT(*)                                    AS transaction_count,
    SUM(total_amt)                              AS revenue,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 2)             AS txn_share_pct,
    ROUND(SUM(total_amt) * 100.0 /
          SUM(SUM(total_amt)) OVER (), 2)       AS revenue_share_pct,
    ROUND(AVG(total_amt), 2)                    AS avg_txn_value
FROM sales_transactions
WHERE txn_date BETWEEN :start_date AND :end_date
  AND return_flag = 0
GROUP BY payment_method
ORDER BY transaction_count DESC;
