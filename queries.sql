-- =======================================================
-- PROJECT: E-Commerce Sales Analysis - PostgreSQL
-- Part 1: Business KPIs & Revenue Analysis
-- =======================================================

-- 1. Calculate Total Revenue
SELECT SUM(quantity * unit_price) AS total_revenue
FROM order_items;

-- 2. Count Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- 3. Count Total Customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- 4. Count Total Products
SELECT COUNT(*) AS total_products
FROM products;

-- 5. Calculate Average Order Value (AOV)
SELECT ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;

-- 6. Find Top 5 Selling Products
SELECT p.product_name, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

-- 7. Find Revenue by Product Category
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 8. Find Top 5 Customers by Revenue
SELECT c.customer_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- 9. Calculate Monthly Revenue (PostgreSQL DATE_TRUNC)
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- 10. Find Revenue by City
SELECT c.city, SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY revenue DESC;