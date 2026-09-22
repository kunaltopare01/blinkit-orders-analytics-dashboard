/*
===============================================================
 Blinkit Orders Analytics Dashboard - SQL Analysis
 Dialect: MySQL 8.0+
 Project: Blinkit Orders Analytics Dashboard
===============================================================

Data sources:
  blinkit_orders
  blinkit_order_items
  blinkit_customers
  blinkit_products
  blinkit_delivery_performance
  blinkit_customer_feedback
  blinkit_inventory
  blinkit_marketing_performance

Important:
- The dashboard's Average Delivery Time is calculated as:
      actual_delivery_time - order_date
  This matches the dashboard value (~19.43 min).
- Product Revenue = SUM(quantity * unit_price)
- Average Selling Price = Product Revenue / Units Sold
*/

CREATE DATABASE IF NOT EXISTS blinkit_analytics;
USE blinkit_analytics;

-- ============================================================
-- 1. TABLE DEFINITIONS
-- ============================================================

DROP TABLE IF EXISTS blinkit_customer_feedback;
DROP TABLE IF EXISTS blinkit_delivery_performance;
DROP TABLE IF EXISTS blinkit_order_items;
DROP TABLE IF EXISTS blinkit_orders;
DROP TABLE IF EXISTS blinkit_customers;
DROP TABLE IF EXISTS blinkit_products;
DROP TABLE IF EXISTS blinkit_inventory;
DROP TABLE IF EXISTS blinkit_marketing_performance;

CREATE TABLE blinkit_orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATETIME NOT NULL,
    promised_delivery_time DATETIME,
    actual_delivery_time DATETIME,
    delivery_status VARCHAR(50),
    order_total DECIMAL(12,2),
    payment_method VARCHAR(50),
    delivery_partner_id BIGINT,
    store_id BIGINT,
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_date (order_date),
    INDEX idx_orders_status (delivery_status),
    INDEX idx_orders_payment (payment_method)
);

CREATE TABLE blinkit_order_items (
    order_id BIGINT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    INDEX idx_items_product (product_id)
);

CREATE TABLE blinkit_customers (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(150),
    email VARCHAR(255),
    phone VARCHAR(30),
    address VARCHAR(500),
    area VARCHAR(100),
    pincode VARCHAR(20),
    registration_date DATE,
    customer_segment VARCHAR(50),
    total_orders INT,
    avg_order_value DECIMAL(12,2),
    INDEX idx_customers_area (area),
    INDEX idx_customers_segment (customer_segment)
);

CREATE TABLE blinkit_products (
    product_id BIGINT PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(100),
    brand VARCHAR(150),
    price DECIMAL(12,2),
    mrp DECIMAL(12,2),
    margin_percentage DECIMAL(6,2),
    shelf_life_days INT,
    min_stock_level INT,
    max_stock_level INT,
    INDEX idx_products_category (category),
    INDEX idx_products_name (product_name)
);

CREATE TABLE blinkit_delivery_performance (
    order_id BIGINT PRIMARY KEY,
    delivery_partner_id BIGINT,
    promised_time DATETIME,
    actual_time DATETIME,
    delivery_time_minutes DECIMAL(8,2),
    distance_km DECIMAL(8,2),
    delivery_status VARCHAR(50),
    reasons_if_delayed VARCHAR(255),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_delivery_distance (distance_km)
);

CREATE TABLE blinkit_customer_feedback (
    feedback_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    customer_id BIGINT,
    rating DECIMAL(3,2),
    feedback_text TEXT,
    feedback_category VARCHAR(100),
    sentiment VARCHAR(50),
    feedback_date DATE,
    INDEX idx_feedback_order (order_id),
    INDEX idx_feedback_customer (customer_id),
    INDEX idx_feedback_date (feedback_date)
);

CREATE TABLE blinkit_inventory (
    product_id BIGINT,
    inventory_date DATE,
    stock_received INT,
    damaged_stock INT,
    PRIMARY KEY (product_id, inventory_date),
    INDEX idx_inventory_date (inventory_date)
);

CREATE TABLE blinkit_marketing_performance (
    campaign_id BIGINT,
    campaign_name VARCHAR(150),
    marketing_date DATE,
    target_audience VARCHAR(100),
    channel VARCHAR(100),
    impressions INT,
    clicks INT,
    conversions INT,
    spend DECIMAL(14,2),
    revenue_generated DECIMAL(14,2),
    roas DECIMAL(8,2),
    PRIMARY KEY (campaign_id, marketing_date, channel),
    INDEX idx_marketing_channel (channel),
    INDEX idx_marketing_date (marketing_date)
);

-- ============================================================
-- 2. DATA QUALITY CHECKS
-- ============================================================

-- Row counts
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM blinkit_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM blinkit_order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM blinkit_customers
UNION ALL
SELECT 'products', COUNT(*) FROM blinkit_products
UNION ALL
SELECT 'delivery_performance', COUNT(*) FROM blinkit_delivery_performance
UNION ALL
SELECT 'customer_feedback', COUNT(*) FROM blinkit_customer_feedback
UNION ALL
SELECT 'inventory', COUNT(*) FROM blinkit_inventory
UNION ALL
SELECT 'marketing_performance', COUNT(*) FROM blinkit_marketing_performance;

-- Duplicate / orphan checks
SELECT order_id, COUNT(*) AS duplicate_count
FROM blinkit_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT oi.order_id
FROM blinkit_order_items oi
LEFT JOIN blinkit_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT oi.product_id
FROM blinkit_order_items oi
LEFT JOIN blinkit_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Null checks for core fields
SELECT
    SUM(order_id IS NULL) AS null_order_id,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(order_total IS NULL) AS null_order_total
FROM blinkit_orders;

-- ============================================================
-- 3. CORE KPI QUERIES
-- ============================================================

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM blinkit_orders;

-- Total Revenue
SELECT ROUND(SUM(order_total), 2) AS total_revenue
FROM blinkit_orders;

-- Average Order Value
SELECT ROUND(AVG(order_total), 2) AS average_order_value
FROM blinkit_orders;

-- Delivered Orders
SELECT COUNT(*) AS delivered_orders
FROM blinkit_orders
WHERE delivery_status = 'On Time';

-- Cancellation Rate
-- The supplied dataset contains no "Cancelled" orders.
SELECT
    ROUND(
        100.0 * SUM(delivery_status = 'Cancelled') / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM blinkit_orders;

-- Average Delivery Time from order placement to actual delivery
SELECT
    ROUND(
        AVG(TIMESTAMPDIFF(SECOND, order_date, actual_delivery_time)) / 60,
        2
    ) AS avg_delivery_time_minutes
FROM blinkit_orders;

-- Average Rating
SELECT ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_customer_feedback;

-- Total Feedback
SELECT COUNT(*) AS total_feedback
FROM blinkit_customer_feedback;

-- On-time delivery rate
SELECT
    ROUND(
        100.0 * SUM(delivery_status = 'On Time') / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct
FROM blinkit_orders;

-- Average delivery distance
SELECT ROUND(AVG(distance_km), 2) AS avg_distance_km
FROM blinkit_delivery_performance;

-- ============================================================
-- 4. ORDERS & REVENUE ANALYSIS
-- ============================================================

-- Orders by delivery status
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM blinkit_orders
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Orders by payment method
SELECT
    payment_method,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS order_share_pct
FROM blinkit_orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Orders by customer segment
SELECT
    c.customer_segment,
    COUNT(*) AS total_orders
FROM blinkit_orders o
JOIN blinkit_customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_orders DESC;

-- Revenue by category
SELECT
    p.category,
    ROUND(SUM(o.order_total), 2) AS total_revenue
FROM blinkit_orders o
JOIN blinkit_order_items oi
    ON o.order_id = oi.order_id
JOIN blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Orders by category
SELECT
    p.category,
    COUNT(*) AS total_orders
FROM blinkit_orders o
JOIN blinkit_order_items oi
    ON o.order_id = oi.order_id
JOIN blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_orders DESC;

-- Top 10 areas by orders
SELECT
    c.area,
    COUNT(*) AS total_orders
FROM blinkit_orders o
JOIN blinkit_customers c
    ON o.customer_id = c.customer_id
GROUP BY c.area
ORDER BY total_orders DESC
LIMIT 10;

-- Top 5 products by orders
SELECT
    p.product_name,
    COUNT(*) AS total_orders
FROM blinkit_orders o
JOIN blinkit_order_items oi
    ON o.order_id = oi.order_id
JOIN blinkit_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC
LIMIT 5;

-- Orders over time (daily)
SELECT
    DATE(order_date) AS order_date,
    COUNT(*) AS total_orders
FROM blinkit_orders
GROUP BY DATE(order_date)
ORDER BY order_date;

-- Orders by hour of day
SELECT
    HOUR(order_date) AS order_hour,
    COUNT(*) AS total_orders
FROM blinkit_orders
GROUP BY HOUR(order_date)
ORDER BY order_hour;

-- Order value distribution
SELECT
    CASE
        WHEN order_total < 500 THEN '₹0–₹499'
        WHEN order_total < 1000 THEN '₹500–₹999'
        WHEN order_total < 1500 THEN '₹1,000–₹1,499'
        WHEN order_total < 2000 THEN '₹1,500–₹1,999'
        WHEN order_total < 2500 THEN '₹2,000–₹2,499'
        WHEN order_total < 3000 THEN '₹2,500–₹2,999'
        WHEN order_total < 4000 THEN '₹3,000–₹3,999'
        WHEN order_total < 5000 THEN '₹4,000–₹4,999'
        ELSE '₹5,000+'
    END AS order_value_bucket,
    COUNT(*) AS total_orders
FROM blinkit_orders
GROUP BY order_value_bucket
ORDER BY MIN(order_total);

-- Monthly orders and average order value
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_total), 2) AS average_order_value
FROM blinkit_orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year_month;

-- Monthly revenue
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    ROUND(SUM(order_total), 2) AS monthly_revenue
FROM blinkit_orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year_month;

-- Monthly revenue growth
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS year_month,
        SUM(order_total) AS revenue
    FROM blinkit_orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    year_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY year_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0),
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY year_month;

-- ============================================================
-- 5. CUSTOMER ANALYSIS
-- ============================================================

-- Total customers
SELECT COUNT(*) AS total_customers
FROM blinkit_customers;

-- Customer distribution by segment
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM blinkit_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Average customer order value from customer master
SELECT ROUND(AVG(avg_order_value), 2) AS avg_customer_order_value
FROM blinkit_customers;

-- Customer registration trend by month
SELECT
    DATE_FORMAT(registration_date, '%Y-%m') AS registration_month,
    COUNT(*) AS new_customers
FROM blinkit_customers
GROUP BY DATE_FORMAT(registration_date, '%Y-%m')
ORDER BY registration_month;

-- Top 10 customers by revenue
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM blinkit_customers c
JOIN blinkit_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 20 areas by customer count
SELECT
    area,
    COUNT(*) AS total_customers
FROM blinkit_customers
GROUP BY area
ORDER BY total_customers DESC
LIMIT 20;

-- Customer rating and sentiment
SELECT
    sentiment,
    COUNT(*) AS feedback_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_customer_feedback
GROUP BY sentiment
ORDER BY feedback_count DESC;

-- ============================================================
-- 6. PRODUCT ANALYSIS
-- ============================================================

-- Product KPI summary
SELECT
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS average_selling_price,
    ROUND(AVG(p.margin_percentage), 2) AS average_margin_pct,
    ROUND(AVG(p.max_stock_level), 2) AS avg_max_stock_level
FROM blinkit_products p
JOIN blinkit_order_items oi
    ON p.product_id = oi.product_id;

-- Average margin by category
SELECT
    category,
    ROUND(AVG(margin_percentage), 2) AS average_margin_pct
FROM blinkit_products
GROUP BY category
ORDER BY average_margin_pct DESC;

-- Top 10 products by units sold
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM blinkit_products p
JOIN blinkit_order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC
LIMIT 10;

-- Product price vs margin
SELECT
    product_name,
    price,
    margin_percentage
FROM blinkit_products
ORDER BY price;

-- Category-level product metrics
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_revenue,
    ROUND(AVG(p.price), 2) AS avg_price,
    ROUND(AVG(p.margin_percentage), 2) AS avg_margin_pct
FROM blinkit_products p
JOIN blinkit_order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY product_revenue DESC;

-- ============================================================
-- 7. DELIVERY ANALYSIS
-- ============================================================

-- Delivery status distribution
SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM blinkit_delivery_performance
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Average delivery time by delivery status
SELECT
    delivery_status,
    ROUND(AVG(
        TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time)
    ) / 60, 2) AS avg_delivery_time_minutes
FROM blinkit_delivery_performance d
JOIN blinkit_orders o
    ON d.order_id = o.order_id
GROUP BY delivery_status
ORDER BY avg_delivery_time_minutes DESC;

-- Average delivery time by distance range
SELECT
    CASE
        WHEN distance_km < 1 THEN '0–1 km'
        WHEN distance_km < 2 THEN '1–2 km'
        WHEN distance_km < 3 THEN '2–3 km'
        WHEN distance_km < 4 THEN '3–4 km'
        ELSE '4–5 km'
    END AS distance_range,
    COUNT(*) AS total_orders,
    ROUND(AVG(
        TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time)
    ) / 60, 2) AS avg_delivery_time_minutes
FROM blinkit_delivery_performance d
JOIN blinkit_orders o
    ON d.order_id = o.order_id
GROUP BY distance_range
ORDER BY MIN(distance_km);

-- Promised vs actual delivery time
SELECT
    o.delivery_status,
    ROUND(AVG(
        TIMESTAMPDIFF(SECOND, o.order_date, o.promised_delivery_time)
    ) / 60, 2) AS avg_promised_delivery_minutes,
    ROUND(AVG(
        TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time)
    ) / 60, 2) AS avg_actual_delivery_minutes
FROM blinkit_orders o
GROUP BY o.delivery_status
ORDER BY avg_actual_delivery_minutes;

-- Delay reason analysis
SELECT
    reasons_if_delayed,
    COUNT(*) AS delayed_orders
FROM blinkit_delivery_performance
WHERE delivery_status <> 'On Time'
  AND reasons_if_delayed IS NOT NULL
GROUP BY reasons_if_delayed
ORDER BY delayed_orders DESC;

-- ============================================================
-- 8. MARKETING PERFORMANCE
-- ============================================================

-- Marketing KPI summary
SELECT
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue_generated,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS overall_roas,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(conversions) AS conversions
FROM blinkit_marketing_performance;

-- Marketing spend vs revenue by channel
SELECT
    channel,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS revenue_generated,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS roas
FROM blinkit_marketing_performance
GROUP BY channel
ORDER BY revenue_generated DESC;

-- Marketing performance by campaign
SELECT
    campaign_name,
    channel,
    ROUND(SUM(spend), 2) AS spend,
    ROUND(SUM(revenue_generated), 2) AS revenue_generated,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS roas,
    SUM(conversions) AS conversions
FROM blinkit_marketing_performance
GROUP BY campaign_name, channel
ORDER BY revenue_generated DESC;

-- ============================================================
-- 9. INVENTORY ANALYSIS
-- ============================================================

-- Inventory receipt and damage summary
SELECT
    p.category,
    SUM(i.stock_received) AS stock_received,
    SUM(i.damaged_stock) AS damaged_stock,
    ROUND(
        100.0 * SUM(i.damaged_stock) / NULLIF(SUM(i.stock_received), 0),
        2
    ) AS damage_rate_pct
FROM blinkit_inventory i
JOIN blinkit_products p
    ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY damage_rate_pct DESC;

-- Product inventory activity
SELECT
    p.product_name,
    SUM(i.stock_received) AS stock_received,
    SUM(i.damaged_stock) AS damaged_stock
FROM blinkit_inventory i
JOIN blinkit_products p
    ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY stock_received DESC;

-- ============================================================
-- 10. REUSABLE VIEWS FOR POWER BI / BI TOOLS
-- ============================================================

DROP VIEW IF EXISTS vw_order_analytics;

CREATE VIEW vw_order_analytics AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    DATE(o.order_date) AS order_day,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    HOUR(o.order_date) AS order_hour,
    o.delivery_status,
    o.order_total,
    o.payment_method,
    o.delivery_partner_id,
    o.store_id,
    c.customer_name,
    c.area,
    c.customer_segment,
    oi.product_id,
    p.product_name,
    p.category,
    p.brand,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS item_revenue,
    d.distance_km,
    ROUND(
        TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time) / 60,
        2
    ) AS delivery_time_minutes,
    f.rating,
    f.feedback_category,
    f.sentiment
FROM blinkit_orders o
LEFT JOIN blinkit_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN blinkit_order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN blinkit_products p
    ON oi.product_id = p.product_id
LEFT JOIN blinkit_delivery_performance d
    ON o.order_id = d.order_id
LEFT JOIN blinkit_customer_feedback f
    ON o.order_id = f.order_id;

DROP VIEW IF EXISTS vw_product_performance;

CREATE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    p.mrp,
    p.margin_percentage,
    p.shelf_life_days,
    p.min_stock_level,
    p.max_stock_level,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS product_revenue
FROM blinkit_products p
LEFT JOIN blinkit_order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    p.mrp,
    p.margin_percentage,
    p.shelf_life_days,
    p.min_stock_level,
    p.max_stock_level;

DROP VIEW IF EXISTS vw_customer_performance;

CREATE VIEW vw_customer_performance AS
SELECT
    c.customer_id,
    c.customer_name,
    c.area,
    c.customer_segment,
    c.registration_date,
    COUNT(o.order_id) AS actual_orders,
    ROUND(COALESCE(SUM(o.order_total), 0), 2) AS total_revenue,
    ROUND(COALESCE(AVG(o.order_total), 0), 2) AS actual_average_order_value,
    ROUND(COALESCE(AVG(f.rating), 0), 2) AS average_rating
FROM blinkit_customers c
LEFT JOIN blinkit_orders o
    ON c.customer_id = o.customer_id
LEFT JOIN blinkit_customer_feedback f
    ON o.order_id = f.order_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.area,
    c.customer_segment,
    c.registration_date;

DROP VIEW IF EXISTS vw_delivery_performance;

CREATE VIEW vw_delivery_performance AS
SELECT
    o.order_id,
    o.order_date,
    o.delivery_status,
    d.distance_km,
    ROUND(
        TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time) / 60,
        2
    ) AS actual_delivery_minutes,
    ROUND(
        TIMESTAMPDIFF(SECOND, o.order_date, o.promised_delivery_time) / 60,
        2
    ) AS promised_delivery_minutes,
    d.reasons_if_delayed
FROM blinkit_orders o
LEFT JOIN blinkit_delivery_performance d
    ON o.order_id = d.order_id;

DROP VIEW IF EXISTS vw_marketing_performance;

CREATE VIEW vw_marketing_performance AS
SELECT
    marketing_date,
    campaign_id,
    campaign_name,
    target_audience,
    channel,
    impressions,
    clicks,
    conversions,
    spend,
    revenue_generated,
    roas
FROM blinkit_marketing_performance;

-- ============================================================
-- 11. FINAL DASHBOARD KPI QUERY
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    ROUND(AVG(o.order_total), 2) AS average_order_value,
    SUM(o.delivery_status = 'On Time') AS on_time_orders,
    ROUND(
        100.0 * SUM(o.delivery_status = 'On Time') / COUNT(*),
        2
    ) AS on_time_delivery_rate_pct,
    ROUND(
        AVG(TIMESTAMPDIFF(SECOND, o.order_date, o.actual_delivery_time)) / 60,
        2
    ) AS average_delivery_time_minutes,
    ROUND(AVG(f.rating), 2) AS average_rating,
    COUNT(DISTINCT oi.product_id) AS total_products,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_revenue,
    ROUND(AVG(d.distance_km), 2) AS avg_distance_km
FROM blinkit_orders o
LEFT JOIN blinkit_order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN blinkit_delivery_performance d
    ON o.order_id = d.order_id
LEFT JOIN blinkit_customer_feedback f
    ON o.order_id = f.order_id;

-- ============================================================
-- END
-- ============================================================
