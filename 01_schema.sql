-- ================================================================
-- RetailIQ: Multi-Outlet Sales Intelligence Database
-- File    : 01_schema.sql
-- Engine  : MySQL 8.0+
-- Author  : Aastha Chhabra
--
-- Design highlights:
--   • Generated columns for margin & profit (no app-layer math)
--   • RFM (Recency, Frequency, Monetary) scoring table for
--     customer segmentation — drives Power BI loyalty panel
--   • Audit log table capturing every price/stock change
--   • Materialized daily summary table refreshed by Event Scheduler
--   • CHECK constraints enforcing business rules at DB level
-- ================================================================

CREATE DATABASE IF NOT EXISTS retailiq
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE retailiq;

-- ----------------------------------------------------------------
-- 1. OUTLETS
-- ----------------------------------------------------------------
CREATE TABLE outlets (
    outlet_id       SMALLINT      NOT NULL AUTO_INCREMENT,
    outlet_code     CHAR(6)       NOT NULL UNIQUE,   -- e.g. 'DL-001'
    outlet_name     VARCHAR(120)  NOT NULL,
    city            VARCHAR(80)   NOT NULL,
    state           VARCHAR(80)   NOT NULL,
    region          ENUM('North','South','East','West','Central') NOT NULL,
    tier            ENUM('Flagship','Standard','Kiosk')          NOT NULL DEFAULT 'Standard',
    sq_ft           SMALLINT      NULL,
    manager_name    VARCHAR(100),
    opened_date     DATE          NOT NULL,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (outlet_id)
) COMMENT='Physical retail locations';


-- ----------------------------------------------------------------
-- 2. CATEGORY HIERARCHY  (self-referencing, up to 3 levels)
-- ----------------------------------------------------------------
CREATE TABLE categories (
    category_id     TINYINT       NOT NULL AUTO_INCREMENT,
    category_name   VARCHAR(80)   NOT NULL,
    parent_id       TINYINT       NULL,
    depth           TINYINT       NOT NULL DEFAULT 0, -- 0=root,1=sub,2=leaf
    PRIMARY KEY (category_id),
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
) COMMENT='Three-level product taxonomy';


-- ----------------------------------------------------------------
-- 3. PRODUCTS / SKUs
--    unit_margin is a generated column — always consistent
-- ----------------------------------------------------------------
CREATE TABLE products (
    product_id      INT           NOT NULL AUTO_INCREMENT,
    sku             VARCHAR(20)   NOT NULL UNIQUE,
    product_name    VARCHAR(200)  NOT NULL,
    category_id     TINYINT       NOT NULL,
    brand           VARCHAR(80),
    unit_cost       DECIMAL(10,2) NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    -- Generated column: margin % stored, always in sync
    unit_margin_pct DECIMAL(5,2)
        GENERATED ALWAYS AS (
            ROUND((unit_price - unit_cost) / unit_price * 100, 2)
        ) STORED,
    size_variant    VARCHAR(20),
    color_variant   VARCHAR(40),
    weight_grams    SMALLINT      NULL,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT chk_price_gt_cost CHECK (unit_price >= unit_cost)
) COMMENT='Product master with auto-computed margin';


-- ----------------------------------------------------------------
-- 4. CUSTOMERS
-- ----------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT           NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(60)   NOT NULL,
    last_name       VARCHAR(60)   NOT NULL,
    email           VARCHAR(160)  UNIQUE,
    phone           VARCHAR(15),
    city            VARCHAR(80),
    state           VARCHAR(80),
    gender          ENUM('M','F','Other','Undisclosed') NOT NULL DEFAULT 'Undisclosed',
    dob             DATE          NULL,
    loyalty_tier    ENUM('Bronze','Silver','Gold','Platinum')     NOT NULL DEFAULT 'Bronze',
    registered_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id)
) COMMENT='Customer master with demographic info';


-- ----------------------------------------------------------------
-- 5. SALES TRANSACTIONS  (header)
-- ----------------------------------------------------------------
CREATE TABLE sales_transactions (
    txn_id          INT           NOT NULL AUTO_INCREMENT,
    outlet_id       SMALLINT      NOT NULL,
    customer_id     INT           NULL,     -- NULL = anonymous walk-in
    txn_date        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method  ENUM('Cash','Card','UPI','Wallet','BNPL')     NOT NULL,
    coupon_code     VARCHAR(20)   NULL,
    discount_amt    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tax_amt         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amt       DECIMAL(10,2) NOT NULL,
    return_flag     TINYINT(1)    NOT NULL DEFAULT 0,   -- 1 = full return
    CONSTRAINT chk_total_positive CHECK (total_amt >= 0),
    PRIMARY KEY (txn_id),
    FOREIGN KEY (outlet_id)   REFERENCES outlets(outlet_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) COMMENT='Transaction header; one row per checkout';


-- ----------------------------------------------------------------
-- 6. TRANSACTION LINE ITEMS
--    line_profit is generated — revenue minus cost at time of sale
-- ----------------------------------------------------------------
CREATE TABLE txn_items (
    item_id         INT           NOT NULL AUTO_INCREMENT,
    txn_id          INT           NOT NULL,
    product_id      INT           NOT NULL,
    qty             SMALLINT      NOT NULL,
    sale_price      DECIMAL(10,2) NOT NULL,   -- price at time of sale
    cost_price      DECIMAL(10,2) NOT NULL,   -- cost snapshotted at sale
    discount_pct    DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
    line_total      DECIMAL(10,2) NOT NULL,
    -- Generated: profit contribution of this line
    line_profit     DECIMAL(10,2)
        GENERATED ALWAYS AS (
            ROUND((sale_price - cost_price) * qty, 2)
        ) STORED,
    CONSTRAINT chk_qty_positive CHECK (qty > 0),
    PRIMARY KEY (item_id),
    FOREIGN KEY (txn_id)     REFERENCES sales_transactions(txn_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) COMMENT='Line items; includes snapshotted cost for profit tracking';


-- ----------------------------------------------------------------
-- 7. INVENTORY  (per outlet, per product)
-- ----------------------------------------------------------------
CREATE TABLE inventory (
    inv_id          INT           NOT NULL AUTO_INCREMENT,
    outlet_id       SMALLINT      NOT NULL,
    product_id      INT           NOT NULL,
    qty_on_hand     INT           NOT NULL DEFAULT 0,
    reorder_level   SMALLINT      NOT NULL DEFAULT 20,
    reorder_qty     SMALLINT      NOT NULL DEFAULT 50,
    last_restocked  DATE          NULL,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_outlet_product UNIQUE (outlet_id, product_id),
    CONSTRAINT chk_qty_non_neg   CHECK  (qty_on_hand >= 0),
    PRIMARY KEY (inv_id),
    FOREIGN KEY (outlet_id)  REFERENCES outlets(outlet_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) COMMENT='Live stock levels; partial index used for low-stock alerts';


-- ----------------------------------------------------------------
-- 8. RFM SCORES  — refreshed nightly by the Event Scheduler
--    Drives the customer segmentation panel in Power BI
-- ----------------------------------------------------------------
CREATE TABLE rfm_scores (
    customer_id     INT           NOT NULL,
    scored_on       DATE          NOT NULL DEFAULT (CURRENT_DATE),
    -- Raw values
    days_since_last_purchase INT  NOT NULL,
    purchase_frequency       INT  NOT NULL,
    monetary_value  DECIMAL(12,2) NOT NULL,
    -- Quintile scores 1-5 (5 = best)
    r_score         TINYINT       NOT NULL,
    f_score         TINYINT       NOT NULL,
    m_score         TINYINT       NOT NULL,
    -- Composite label derived from quintiles
    rfm_segment     VARCHAR(30)   NOT NULL,  -- e.g. 'Champions', 'At Risk'
    PRIMARY KEY (customer_id, scored_on),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) COMMENT='RFM segmentation refreshed nightly for Power BI loyalty panel';


-- ----------------------------------------------------------------
-- 9. PRICE / STOCK AUDIT LOG  — immutable change history
-- ----------------------------------------------------------------
CREATE TABLE audit_log (
    log_id          BIGINT        NOT NULL AUTO_INCREMENT,
    table_name      VARCHAR(40)   NOT NULL,
    record_id       INT           NOT NULL,
    field_changed   VARCHAR(60)   NOT NULL,
    old_value       VARCHAR(200)  NULL,
    new_value       VARCHAR(200)  NULL,
    changed_by      VARCHAR(80)   NOT NULL DEFAULT 'system',
    changed_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    INDEX idx_audit_table_record (table_name, record_id)
) COMMENT='Immutable audit trail for price and stock changes';


-- ----------------------------------------------------------------
-- 10. DAILY OUTLET SUMMARY  — materialized by Event Scheduler
--     Power BI reads this for the trend panels instead of
--     aggregating millions of rows at query time
-- ----------------------------------------------------------------
CREATE TABLE daily_outlet_summary (
    summary_date    DATE          NOT NULL,
    outlet_id       SMALLINT      NOT NULL,
    txn_count       INT           NOT NULL DEFAULT 0,
    units_sold      INT           NOT NULL DEFAULT 0,
    gross_revenue   DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    net_revenue     DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_discount  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total_profit    DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    avg_basket_size DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    new_customers   SMALLINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (summary_date, outlet_id),
    FOREIGN KEY (outlet_id) REFERENCES outlets(outlet_id)
) COMMENT='Pre-aggregated daily totals; refreshed by Event Scheduler';
