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


-- ===================================================
-- PART 3: Intermediate Business Questions (11-20)
-- ===================================================

-- 11. Find Repeat Customers
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

-- 12. Find Customers Who Never Placed an Order
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 13. Find Inactive Customers (No Orders in Last 90 Days)
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '90 days'
    OR MAX(o.order_date) IS NULL;

-- 14. Find the Best-Selling Product Category
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY units_sold DESC
LIMIT 1;

-- 15. Find the Highest Revenue Product
SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 1;

-- 16. Find the Lowest Revenue Product
SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue ASC
LIMIT 1;

-- 17. Calculate Average Products per Order
SELECT
    ROUND(AVG(product_count), 2) AS avg_products_per_order
FROM (
    SELECT
        order_id,
        SUM(quantity) AS product_count
    FROM order_items
    GROUP BY order_id
) t;

-- 18. Find Orders Worth More Than 10,000
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM order_items
GROUP BY order_id
HAVING SUM(quantity * unit_price) > 10000;

-- 19. Find Customers with the Highest Average Order Value
SELECT
    customer_id,
    ROUND(AVG(order_value), 2) AS avg_order_value
FROM (
    SELECT
        o.customer_id,
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
) t
GROUP BY customer_id
ORDER BY avg_order_value DESC;

-- 20. Find the Top 3 Cities by Revenue
SELECT
    c.city,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY revenue DESC
LIMIT 3;