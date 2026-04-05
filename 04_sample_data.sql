-- ================================================================
-- RetailIQ: Sample Data
-- File    : 04_sample_data.sql
-- Note    : Fictional data only — safe for public repos
-- ================================================================

USE retailiq;

-- ── Outlets (12 across India) ───────────────────────────────────
INSERT INTO outlets
    (outlet_code, outlet_name, city, state, region, tier, sq_ft, manager_name, opened_date)
VALUES
    ('DL-001','RetailIQ – Connaught Place', 'New Delhi',  'Delhi',          'North',   'Flagship', 4200, 'Priya Sharma',      '2018-03-15'),
    ('DL-002','RetailIQ – Lajpat Nagar',    'New Delhi',  'Delhi',          'North',   'Standard', 1800, 'Rohan Kapoor',      '2019-06-01'),
    ('MH-001','RetailIQ – Bandra West',     'Mumbai',     'Maharashtra',    'West',    'Flagship', 5100, 'Sneha Mehta',       '2017-11-20'),
    ('MH-002','RetailIQ – Andheri',         'Mumbai',     'Maharashtra',    'West',    'Standard', 2200, 'Vivek Joshi',       '2020-02-10'),
    ('KA-001','RetailIQ – Koramangala',     'Bengaluru',  'Karnataka',      'South',   'Flagship', 3900, 'Ananya Rao',        '2018-08-05'),
    ('KA-002','RetailIQ – Indiranagar',     'Bengaluru',  'Karnataka',      'South',   'Standard', 1600, 'Karan Nair',        '2021-01-12'),
    ('TN-001','RetailIQ – T Nagar',         'Chennai',    'Tamil Nadu',     'South',   'Standard', 2100, 'Divya Pillai',      '2019-04-18'),
    ('TL-001','RetailIQ – Jubilee Hills',   'Hyderabad',  'Telangana',      'South',   'Standard', 2400, 'Arjun Reddy',       '2020-09-07'),
    ('WB-001','RetailIQ – Salt Lake',       'Kolkata',    'West Bengal',    'East',    'Standard', 1900, 'Riya Banerjee',     '2018-01-25'),
    ('WB-002','RetailIQ – Park Street',     'Kolkata',    'West Bengal',    'East',    'Kiosk',     900, 'Saurav Das',        '2022-05-30'),
    ('GJ-001','RetailIQ – CG Road',         'Ahmedabad',  'Gujarat',        'West',    'Standard', 2000, 'Hetal Patel',       '2019-10-14'),
    ('UP-001','RetailIQ – Hazratganj',      'Lucknow',    'Uttar Pradesh',  'Central', 'Standard', 1700, 'Mohit Srivastava',  '2021-07-22');


-- ── Categories ──────────────────────────────────────────────────
INSERT INTO categories (category_name, parent_id, depth) VALUES
    ('Apparel',     NULL, 0),  -- 1
    ('Footwear',    NULL, 0),  -- 2
    ('Accessories', NULL, 0),  -- 3
    ('Men',         1,    1),  -- 4
    ('Women',       1,    1),  -- 5
    ('Kids',        1,    1),  -- 6
    ('Men Shoes',   2,    1),  -- 7
    ('Women Shoes', 2,    1),  -- 8
    ('Bags',        3,    1),  -- 9
    ('Belts',       3,    1),  -- 10
    ('Sunglasses',  3,    1);  -- 11


-- ── Products (22 SKUs) ──────────────────────────────────────────
INSERT INTO products
    (sku, product_name, category_id, brand, unit_cost, unit_price, size_variant, color_variant)
VALUES
    ('APP-M-S01', 'Slim Fit Oxford Shirt',        4,  'Urbano',        380,   999,  'M',    'White'),
    ('APP-M-C01', 'Stretch Comfort Chinos',        4,  'Urbano',        540,  1499,  '32',   'Khaki'),
    ('APP-M-J01', 'Quilted Bomber Jacket',         4,  'Roadster',      980,  2799,  'L',    'Olive'),
    ('APP-M-L01', 'Premium Linen Shirt',           4,  'Allen Solly',   420,  1199,  'L',    'Sky Blue'),
    ('APP-W-D01', 'Floral Wrap Midi Dress',        5,  'W',             460,  1299,  'S',    'Coral'),
    ('APP-W-P01', 'High-Rise Palazzo Pants',       5,  'W',             310,   799,  'M',    'Black'),
    ('APP-W-K01', 'Hand-Embroidered Kurti',        5,  'Biba',          460,  1199,  'M',    'Blush Pink'),
    ('APP-W-J01', 'Indigo Denim Jacket',           5,  'Pepe Jeans',    650,  1799,  'S',    'Indigo'),
    ('APP-K-D01', 'Kids Denim Dungaree Set',       6,  'H&M',           340,   899,  '4-5Y', 'Denim Blue'),
    ('APP-K-T01', 'Kids Graphic Oversized Tee',    6,  'H&M',           150,   449,  '6-7Y', 'White'),
    ('APP-K-H01', 'Kids Fleece Hoodie',            6,  'H&M',           420,  1099,  '8-9Y', 'Red'),
    ('SHOE-M-L01','Burnished Leather Loafer',      7,  'Clarks',        840,  2499,  '42',   'Tan Brown'),
    ('SHOE-M-R01','Cushioned Running Trainer',     7,  'Puma',          690,  1999,  '41',   'Grey'),
    ('SHOE-W-H01','Block Heel Strappy Sandal',     8,  'Steve Madden',  610,  1799,  '37',   'Nude'),
    ('SHOE-W-B01','Suede Ballet Flat',             8,  'Mochi',         380,   999,  '38',   'Black'),
    ('ACC-BAG-C01','Large Canvas Tote',            9,  'Caprese',       610,  1599,  NULL,   'Tan'),
    ('ACC-BAG-S01','Quilted Mini Sling Bag',       9,  'Lavie',         460,  1299,  NULL,   'Blush'),
    ('ACC-BAG-L01','Vegan Leather Laptop Bag',     9,  'Wildcraft',     760,  2199,  NULL,   'Black'),
    ('ACC-BELT-M1','Full-Grain Leather Belt M',   10,  'Louis Philippe', 300,   899,  '34',   'Black'),
    ('ACC-BELT-W1','Woven Fabric Belt W',          10,  'Inc.5',         200,   649,  'S',    'Caramel'),
    ('ACC-SUN-M01','Polarised Aviator Sunnies M', 11,  'Ray-Ban',       850,  2899,  NULL,   'Gold Frame'),
    ('ACC-SUN-W01','Cat-Eye Tinted Sunglasses W', 11,  'Fastrack',      340,   999,  NULL,   'Rose');


-- ── Customers (20) ──────────────────────────────────────────────
INSERT INTO customers
    (first_name, last_name, email, phone, city, state, gender,
     loyalty_tier, registered_at)
VALUES
    ('Aarav',    'Sharma',      'aarav.sharma@mail.com',     '9811000001','New Delhi', 'Delhi',          'M','Platinum','2019-01-15 10:30:00'),
    ('Priya',    'Mehta',       'priya.mehta@mail.com',      '9820000002','Mumbai',    'Maharashtra',    'F','Platinum','2018-03-20 14:00:00'),
    ('Rohit',    'Verma',       'rohit.verma@mail.com',      '9830000003','Kolkata',   'West Bengal',    'M','Silver',  '2021-06-10 11:15:00'),
    ('Ananya',   'Rao',         'ananya.rao@mail.com',       '9880000004','Bengaluru', 'Karnataka',      'F','Gold',    '2020-09-05 16:45:00'),
    ('Vivek',    'Joshi',       'vivek.joshi@mail.com',      '9870000005','Ahmedabad', 'Gujarat',        'M','Bronze',  '2022-02-28 09:00:00'),
    ('Sneha',    'Kapoor',      'sneha.kapoor@mail.com',     '9810000006','New Delhi', 'Delhi',          'F','Silver',  '2021-11-12 13:30:00'),
    ('Kiran',    'Nair',        'kiran.nair@mail.com',       '9880000007','Bengaluru', 'Karnataka',      'F','Bronze',  '2023-01-07 10:00:00'),
    ('Divya',    'Pillai',      'divya.pillai@mail.com',     '9840000008','Chennai',   'Tamil Nadu',     'F','Gold',    '2020-05-19 15:00:00'),
    ('Arjun',    'Reddy',       'arjun.reddy@mail.com',      '9850000009','Hyderabad', 'Telangana',      'M','Platinum','2019-08-23 12:00:00'),
    ('Meera',    'Das',         'meera.das@mail.com',        '9830000010','Kolkata',   'West Bengal',    'F','Silver',  '2022-04-14 11:00:00'),
    ('Aditya',   'Patel',       'aditya.patel@mail.com',     '9870000011','Ahmedabad', 'Gujarat',        'M','Bronze',  '2023-03-02 09:30:00'),
    ('Pooja',    'Srivastava',  'pooja.sri@mail.com',        '9870000012','Lucknow',   'Uttar Pradesh',  'F','Silver',  '2021-09-15 14:30:00'),
    ('Rahul',    'Banerjee',    'rahul.ban@mail.com',        '9830000013','Kolkata',   'West Bengal',    'M','Bronze',  '2023-06-20 16:00:00'),
    ('Simi',     'Singh',       'simi.singh@mail.com',       '9810000014','New Delhi', 'Delhi',          'F','Gold',    '2020-07-01 10:45:00'),
    ('Manish',   'Kumar',       'manish.kumar@mail.com',     '9820000015','Mumbai',    'Maharashtra',    'M','Silver',  '2021-12-05 13:00:00'),
    ('Tanvi',    'Desai',       'tanvi.desai@mail.com',      '9870000016','Ahmedabad', 'Gujarat',        'F','Gold',    '2020-10-10 12:00:00'),
    ('Suresh',   'Iyer',        'suresh.iyer@mail.com',      '9880000017','Chennai',   'Tamil Nadu',     'M','Silver',  '2021-03-18 10:00:00'),
    ('Kavya',    'Menon',       'kavya.menon@mail.com',      '9880000018','Bengaluru', 'Karnataka',      'F','Gold',    '2020-08-22 14:00:00'),
    ('Dev',      'Malhotra',    'dev.malhotra@mail.com',     '9810000019','New Delhi', 'Delhi',          'M','Platinum','2018-11-30 09:00:00'),
    ('Ritu',     'Agarwal',     'ritu.agarwal@mail.com',     '9870000020','Lucknow',   'Uttar Pradesh',  'F','Bronze',  '2023-08-14 11:30:00');


-- ── Sales Transactions (30 sample) ──────────────────────────────
INSERT INTO sales_transactions
    (outlet_id, customer_id, txn_date, payment_method, coupon_code,
     discount_amt, tax_amt, total_amt)
VALUES
    (1,  1,  '2024-01-15 11:20:00','Card',   'NEWYEAR10',  99.90,  162.72, 2097.82),
    (1,  6,  '2024-01-22 15:40:00','UPI',    NULL,          0.00,   89.82, 1157.82),
    (3,  2,  '2024-01-18 13:10:00','Card',   'VIP20',      200.00,  214.56, 2768.56),
    (5,  4,  '2024-02-03 10:00:00','UPI',    NULL,          0.00,  119.88, 1546.88),
    (5,  7,  '2024-02-10 17:30:00','Cash',   NULL,          0.00,   63.18,  814.18),
    (7,  8,  '2024-02-14 14:00:00','Card',   'VDAY15',     150.00,  138.24, 1782.24),
    (9,  3,  '2024-03-01 12:15:00','Cash',   NULL,          0.00,   77.94, 1005.94),
    (9,  10, '2024-03-08 11:00:00','Wallet', NULL,          0.00,   95.94, 1237.94),
    (2,  14, '2024-03-20 16:00:00','Card',   NULL,          0.00,  155.34, 2002.34),
    (4,  2,  '2024-04-05 10:30:00','Card',   'MAHA10',     200.00,  185.22, 2388.22),
    (6,  4,  '2024-04-12 14:45:00','UPI',    NULL,          0.00,  104.22, 1344.22),
    (8,  9,  '2024-04-25 13:00:00','Card',   NULL,          0.00,  193.38, 2492.38),
    (11, 5,  '2024-05-02 09:30:00','Cash',   NULL,          0.00,   77.94, 1005.94),
    (12, 12, '2024-05-15 11:15:00','UPI',    'LUCK10',      70.00,  97.02, 1250.02),
    (10, 13, '2024-05-28 15:30:00','Wallet', NULL,          0.00,   69.66,  898.66),
    (1,  19, '2024-06-03 12:00:00','Card',   'VIP20',      300.00,  232.50, 2997.50),
    (3,  2,  '2024-06-10 14:30:00','Card',   NULL,          0.00,  143.64, 1852.64),
    (5,  18, '2024-06-18 11:00:00','UPI',    NULL,          0.00,   93.00, 1199.00),
    (7,  17, '2024-07-04 13:45:00','Cash',   NULL,          0.00,   77.52,  999.52),
    (9,  16, '2024-07-12 10:00:00','Card',   'SALE15',     150.00,  177.96, 2294.96),
    (1,  1,  '2024-07-20 16:00:00','Card',   NULL,          0.00,  219.84, 2834.84),
    (3,  9,  '2024-08-01 11:30:00','Card',   'AUG20',      200.00,  232.50, 2997.50),
    (5,  4,  '2024-08-15 14:00:00','UPI',    NULL,          0.00,  109.26, 1409.26),
    (6,  18, '2024-09-05 10:30:00','Cash',   NULL,          0.00,   77.52,  999.52),
    (8,  9,  '2024-09-18 13:00:00','Card',   NULL,          0.00,  193.38, 2492.38),
    (1,  19, '2024-10-10 11:00:00','Card',   'FEST15',     300.00,  348.00, 4487.00),
    (3,  2,  '2024-10-25 15:30:00','Card',   'FEST10',     200.00,  278.16, 3586.16),
    (5,  1,  '2024-11-05 10:00:00','UPI',    'DIWALI20',   400.00,  348.00, 4488.00),
    (1,  14, '2024-11-20 13:00:00','Card',   NULL,          0.00,  155.34, 2002.34),
    (3,  9,  '2024-12-15 14:00:00','Card',   'XMAS10',     200.00,  278.16, 3586.16);


-- ── Transaction Items ────────────────────────────────────────────
INSERT INTO txn_items
    (txn_id, product_id, qty, sale_price, cost_price, discount_pct, line_total)
VALUES
    -- Txn 1
    (1,  1,  1,   999, 380,  10.00,  899.10),
    (1,  2,  1,  1499, 540,   0.00, 1499.00),
    (1, 19,  1,   899, 300,  10.00,  809.10),
    -- Txn 2
    (2,  7,  1,  1199, 460,   0.00, 1199.00),
    (2,  6,  1,   799, 310,  50.00,  399.50),
    -- Txn 3
    (3,  3,  1,  2799, 980,   0.00, 2799.00),
    (3, 12,  1,  2499, 840,   0.00, 2499.00),
    (3, 16,  1,  1599, 610,  20.00, 1279.20),
    -- Txn 4
    (4,  5,  1,  1299, 460,   0.00, 1299.00),
    (4, 15,  1,   999, 380,   0.00,  999.00),
    -- Txn 5
    (5, 10,  2,   449, 150,   0.00,  898.00),
    (5, 20,  1,   649, 200,  10.00,  584.10),
    -- Txn 6
    (6, 14,  1,  1799, 610,   0.00, 1799.00),
    (6, 17,  1,  1299, 460,   0.00, 1299.00),
    -- Txn 7
    (7, 12,  1,  2499, 840,   0.00, 2499.00),
    -- Txn 8
    (8,  8,  1,  1799, 650,   0.00, 1799.00),
    (8, 19,  1,   899, 300,   0.00,  899.00),
    -- Txn 9
    (9,  3,  1,  2799, 980,   0.00, 2799.00),
    -- Txn 10
    (10, 8,  1,  1799, 650,  10.00, 1619.10),
    (10, 7,  1,  1199, 460,   0.00, 1199.00),
    -- Txn 11
    (11, 5,  1,  1299, 460,   0.00, 1299.00),
    -- Txn 12
    (12,21,  1,  2899, 850,   0.00, 2899.00),
    -- Txn 13
    (13,10,  2,   449, 150,   0.00,  898.00),
    -- Txn 14
    (14, 6,  1,   799, 310,  10.00,  719.10),
    (14, 7,  1,  1199, 460,   0.00, 1199.00),
    -- Txn 15
    (15, 9,  1,   899, 340,   0.00,  899.00),
    -- Txn 16
    (16, 3,  1,  2799, 980,  10.00, 2519.10),
    (16,21,  1,  2899, 850,   0.00, 2899.00),
    -- Txn 17
    (17, 8,  1,  1799, 650,   0.00, 1799.00),
    -- Txn 18
    (18, 7,  1,  1199, 460,   0.00, 1199.00),
    -- Txn 19
    (19,15,  1,   999, 380,   0.00,  999.00),
    -- Txn 20
    (20, 4,  1,  1199, 420,   0.00, 1199.00),
    (20,22,  1,   999, 340,   0.00,  999.00),
    -- Txn 21
    (21, 3,  1,  2799, 980,   0.00, 2799.00),
    -- Txn 22
    (22,21,  1,  2899, 850,  10.00, 2609.10),
    (22,18,  1,  2199, 760,   0.00, 2199.00),
    -- Txn 23
    (23, 5,  1,  1299, 460,   0.00, 1299.00),
    -- Txn 24
    (24,15,  1,   999, 380,   0.00,  999.00),
    -- Txn 25
    (25,12,  1,  2499, 840,   0.00, 2499.00),
    -- Txn 26 (Festive – big basket)
    (26, 3,  1,  2799, 980,  10.00, 2519.10),
    (26,21,  1,  2899, 850,  10.00, 2609.10),
    (26,16,  1,  1599, 610,  10.00, 1439.10),
    -- Txn 27
    (27, 8,  1,  1799, 650,  10.00, 1619.10),
    (27,17,  1,  1299, 460,   0.00, 1299.00),
    (27,18,  1,  2199, 760,  10.00, 1979.10),
    -- Txn 28 (Diwali)
    (28, 3,  1,  2799, 980,  20.00, 2239.20),
    (28, 1,  2,   999, 380,   0.00, 1998.00),
    (28, 7,  2,  1199, 460,   0.00, 2398.00),
    -- Txn 29
    (29, 1,  1,   999, 380,   0.00,  999.00),
    (29, 2,  1,  1499, 540,   0.00, 1499.00),
    -- Txn 30 (Christmas)
    (30, 3,  1,  2799, 980,  10.00, 2519.10),
    (30,21,  1,  2899, 850,  10.00, 2609.10),
    (30,18,  1,  2199, 760,   0.00, 2199.00);


-- ── Inventory ───────────────────────────────────────────────────
INSERT INTO inventory
    (outlet_id, product_id, qty_on_hand, reorder_level, reorder_qty, last_restocked)
VALUES
    (1,  1, 48, 20, 50, '2024-10-01'),(1,  2, 32, 20, 50, '2024-10-01'),
    (1,  3,  6, 15, 30, '2024-09-15'),(1, 21, 18, 10, 20, '2024-10-05'),
    (2,  5, 14, 20, 40, '2024-10-08'),(2,  6, 62, 25, 50, '2024-10-08'),
    (3,  7, 37, 20, 50, '2024-09-20'),(3, 12,  9, 15, 30, '2024-09-20'),
    (3, 16,  4, 15, 30, '2024-08-28'),(4,  8, 24, 20, 40, '2024-10-12'),
    (5,  9, 55, 25, 50, '2024-10-15'),(5, 13, 41, 20, 40, '2024-10-15'),
    (6, 14,  2, 15, 25, '2024-09-01'),(7, 15, 29, 20, 40, '2024-10-20'),
    (8, 17, 21, 15, 30, '2024-10-08'),(9, 18, 13, 20, 40, '2024-09-28'),
    (10, 3,  0, 15, 30, '2024-08-10'),(11, 1, 34, 20, 50, '2024-10-02'),
    (12, 7, 17, 20, 50, '2024-10-18'),(1, 19, 45, 20, 50, '2024-10-01'),
    (3, 22, 28, 15, 30, '2024-10-01'),(5, 20, 19, 20, 40, '2024-09-30');


-- ── Pre-populate daily_outlet_summary (last 7 days sample) ──────
INSERT INTO daily_outlet_summary
    (summary_date, outlet_id, txn_count, units_sold,
     gross_revenue, net_revenue, total_discount, total_profit,
     avg_basket_size, new_customers)
VALUES
    ('2024-12-01', 1, 42, 89,  98500, 93200, 5300, 42100, 2345.24, 3),
    ('2024-12-01', 3, 38, 74,  91200, 86800, 4400, 39600, 2400.00, 2),
    ('2024-12-01', 5, 35, 68,  76400, 72900, 3500, 33200, 2182.86, 4),
    ('2024-12-02', 1, 45, 92, 105200, 99400, 5800, 45100, 2337.78, 2),
    ('2024-12-02', 3, 40, 79,  95800, 91100, 4700, 41500, 2395.00, 3),
    ('2024-12-02', 5, 33, 65,  72100, 68800, 3300, 31400, 2184.85, 1),
    ('2024-12-03', 1, 50, 98, 118600,111200, 7400, 51800, 2372.00, 5),
    ('2024-12-03', 3, 44, 85, 103400, 97900, 5500, 45200, 2350.00, 3);
