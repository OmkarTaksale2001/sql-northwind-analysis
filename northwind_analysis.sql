-- ============================================================
-- Sales & Customer Analytics | Northwind Database
-- Author: Omkar Milind Taksale
-- Tool: MySQL 8.0 | MySQL Workbench
-- Dataset: Northwind (mywind) — retail sales, customers,
--          products, suppliers, order transactions
--
-- Purpose: Exploratory business analysis to identify
-- revenue patterns, customer behaviour, and product
-- performance across a simulated retail operation.
-- Techniques used: aggregations, multi-table joins,
-- subqueries, conditional logic, date analysis,
-- and window functions.
-- ============================================================

USE northwind;

-- ============================================================
-- 1. HIGH-COST SHIPMENTS
-- Identifying orders where shipping costs exceeded €50.
-- Useful for flagging logistics inefficiencies or
-- reviewing freight contracts with carriers.
-- ============================================================
SELECT 
    id AS order_id,
    order_date,
    ship_city,
    ship_country_region,
    shipping_fee
FROM orders
WHERE shipping_fee > 50
ORDER BY shipping_fee DESC;


-- ============================================================
-- 2. PREMIUM PRODUCT OVERVIEW
-- Top 10 most expensive products by list price.
-- A quick reference for pricing strategy discussions
-- or identifying high-margin product lines.
-- ============================================================
SELECT 
    product_name,
    category,
    list_price
FROM products
ORDER BY list_price DESC
LIMIT 10;


-- ============================================================
-- 3. ORDER FREQUENCY BY CUSTOMER
-- How many orders has each customer placed?
-- Helps segment customers by activity level —
-- a starting point for retention or loyalty analysis.
-- ============================================================
SELECT 
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;


-- ============================================================
-- 4. REVENUE BREAKDOWN BY PRODUCT CATEGORY
-- Total revenue generated per category, calculated
-- as quantity × unit price across all order lines.
-- Useful for portfolio analysis and budget allocation.
-- ============================================================
SELECT 
    p.category,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue
FROM order_details od
JOIN products p ON od.product_id = p.id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. REPEAT CUSTOMERS (MORE THAN 3 ORDERS)
-- Filtering to customers who have placed over 3 orders.
-- These are the high-engagement accounts worth
-- prioritising for account management or upsell efforts.
-- ============================================================
SELECT 
    customer_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING total_orders > 3
ORDER BY total_orders DESC;


-- ============================================================
-- 6. ORDER HISTORY WITH CUSTOMER DETAILS
-- Joining orders with customer names and locations.
-- Converts raw transaction IDs into a readable report
-- suitable for sharing with sales or ops teams.
-- ============================================================
SELECT 
    o.id AS order_id,
    c.company AS customer_name,
    c.city,
    o.order_date,
    o.shipping_fee
FROM orders o
JOIN customers c ON o.customer_id = c.id
ORDER BY o.order_date DESC;


-- ============================================================
-- 7. INACTIVE CUSTOMERS — NO ORDERS PLACED
-- Customers registered in the system but with zero
-- order history. Relevant for CRM hygiene, reactivation
-- campaigns, or data quality audits.
-- ============================================================
SELECT 
    c.id AS customer_id,
    c.company,
    c.city,
    c.country_region
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;


-- ============================================================
-- 8. FULL ORDER LINE DETAIL — CUSTOMER, PRODUCT, SUPPLIER
-- A consolidated view joining four tables to show
-- exactly what was ordered, by whom, at what price,
-- and from which supplier. Mirrors a typical sales
-- detail report requested by finance or operations.
-- ============================================================
SELECT 
    o.id AS order_id,
    c.company AS customer,
    p.product_name,
    p.category,
    s.company AS supplier,
    od.quantity,
    od.unit_price,
    ROUND(od.quantity * od.unit_price, 2) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_details od ON o.id = od.order_id
JOIN products p ON od.product_id = p.id
JOIN suppliers s ON p.id = s.id
ORDER BY o.id;


-- ============================================================
-- 9. ABOVE-AVERAGE PRICED PRODUCTS
-- Using a subquery to dynamically calculate the average
-- list price and filter products above that threshold.
-- Avoids hardcoding values — the result updates
-- automatically as product data changes.
-- ============================================================
SELECT 
    product_name,
    category,
    list_price
FROM products
WHERE list_price > (
    SELECT AVG(list_price) FROM products
)
ORDER BY list_price DESC;


-- ============================================================
-- 10. ORDERS FROM HIGH-DENSITY MARKETS
-- Identifies orders placed by customers in countries
-- with more than 2 registered customers — focusing
-- analysis on markets with sufficient customer base
-- to draw meaningful conclusions.
-- ============================================================
SELECT 
    o.id AS order_id,
    c.company,
    c.country_region,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE c.country_region IN (
    SELECT country_region
    FROM customers
    GROUP BY country_region
    HAVING COUNT(*) > 2
)
ORDER BY c.country_region;
