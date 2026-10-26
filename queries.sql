-- ===================================================
-- E-COMMERCE SALES ANALYSIS - 40 QUERIES COMPLETE
-- ===================================================

-- 1. Show all customers
SELECT * FROM customers;

-- 2. Show all orders with delivered status
SELECT * FROM orders WHERE status = 'Delivered';

-- 3. Find total number of customers
SELECT COUNT(*) AS total_customers FROM customers;

-- 4. Find total number of orders
SELECT COUNT(*) AS total_orders FROM orders WHERE status='Delivered';

-- 5. Find total revenue
SELECT SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status='Delivered';

-- 6. Find top 5 customers by orders
SELECT customer_id, COUNT(*) AS order_count FROM orders WHERE status='Delivered' GROUP BY customer_id ORDER BY order_count DESC LIMIT 5;

-- 7. Find revenue by city
SELECT c.city, SUM(oi.quantity * oi.unit_price) AS revenue
FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status='Delivered' GROUP BY c.city ORDER BY revenue DESC;

-- 8. Find average order value
SELECT AVG(order_value) AS avg_order_value FROM (SELECT SUM(quantity*unit_price) AS order_value FROM orders o JOIN order_items oi ON o.order_id=oi.order_id WHERE o.status='Delivered' GROUP BY o.order_id) t;

-- 9. Find total products sold
SELECT SUM(quantity) AS total_sold FROM order_items oi JOIN orders o ON oi.order_id=o.order_id WHERE o.status='Delivered';

-- 10. Find orders by month
SELECT DATE_TRUNC('month', order_date) AS month, COUNT(*) AS orders FROM orders WHERE status='Delivered' GROUP BY month ORDER BY month;

-- 11. Revenue by Category
SELECT p.category, SUM(oi.quantity * oi.unit_price) AS revenue FROM products p JOIN order_items oi ON p.product_id=oi.product_id JOIN orders o ON oi.order_id=o.order_id WHERE o.status='Delivered' GROUP BY p.category ORDER BY revenue DESC;

-- 12. Top 5 Selling Products
SELECT p.product_name, SUM(oi.quantity) AS total_sold FROM products p JOIN order_items oi ON p.product_id=oi.product_id JOIN orders o ON oi.order_id=o.order_id WHERE o.status='Delivered' GROUP BY p.product_name ORDER BY total_sold DESC LIMIT 5;

-- 13. Customers with High Spending
SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS total_spent FROM orders o JOIN order_items oi ON o.order_id=oi.order_id WHERE o.status='Delivered' GROUP BY o.customer_id HAVING SUM(oi.quantity*oi.unit_price) > 10000;

-- 14. Orders with more than 2 products
SELECT order_id, COUNT(*) AS product_count FROM order_items GROUP BY order_id HAVING COUNT(*) > 2;

-- 15. Find customers who never returned (One-time)
SELECT customer_id FROM orders WHERE status='Delivered' GROUP BY customer_id HAVING COUNT(*)=1;

-- 16. Monthly Revenue Trend
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id=oi.order_id WHERE o.status='Delivered' GROUP BY month ORDER BY month;

-- 17. Top City by Orders
SELECT c.city, COUNT(*) AS orders FROM customers c JOIN orders o ON c.customer_id=o.customer_id WHERE o.status='Delivered' GROUP BY c.city ORDER BY orders DESC LIMIT 1;

-- 18. Product Price Range
SELECT MIN(price) AS min_price, MAX(price) AS max_price, AVG(price) AS avg_price FROM products;

-- 19. Customers with Failed Orders
SELECT * FROM orders WHERE status != 'Delivered';

-- 20. Most Valuable Customer
SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id=oi.order_id WHERE o.status='Delivered' GROUP BY o.customer_id ORDER BY revenue DESC LIMIT 1;

-- 21. Rank Customers by Total Revenue
WITH customer_revenue AS (SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status='Delivered' GROUP BY o.customer_id)
SELECT customer_id, revenue, DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank FROM customer_revenue;

-- 22. Find the Top Selling Product in Each Category
WITH product_sales AS (SELECT p.category, p.product_name, SUM(oi.quantity) AS total_sold FROM products p JOIN order_items oi ON p.product_id = oi.product_id JOIN orders o ON oi.order_id=o.order_id WHERE o.status='Delivered' GROUP BY p.category, p.product_name)
SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sold DESC) AS rn FROM product_sales) t WHERE rn = 1;

-- 23. Calculate Running Revenue by Order Date
WITH daily_sales AS (SELECT o.order_date, SUM(oi.quantity * oi.unit_price) AS daily_revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status='Delivered' GROUP BY o.order_date)
SELECT order_date, daily_revenue, SUM(daily_revenue) OVER (ORDER BY order_date) AS running_revenue FROM daily_sales;

-- 24. Find the Previous Order Date for Each Customer
SELECT customer_id, order_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date FROM orders WHERE status='Delivered';

-- 25. Find the Next Order Date for Each Customer
SELECT customer_id, order_id, order_date, LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date FROM orders WHERE status='Delivered';

-- 26. Calculate Days Between Consecutive Orders
SELECT customer_id, order_date, order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_between_orders FROM orders WHERE status='Delivered';

-- 27. Find the Top 3 Customers by Revenue
WITH customer_revenue AS (SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status='Delivered' GROUP BY o.customer_id)
SELECT * FROM (SELECT *, DENSE_RANK() OVER (ORDER BY revenue DESC) AS rnk FROM customer_revenue) t WHERE rnk <= 3;

-- 28. Find Each Product's Contribution to Total Revenue
WITH product_revenue AS (SELECT p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue FROM products p JOIN order_items oi ON p.product_id = oi.product_id JOIN orders o ON oi.order_id=o.order_id WHERE o.status='Delivered' GROUP BY p.product_name)
SELECT product_name, revenue, ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_percentage FROM product_revenue ORDER BY revenue DESC;

-- 29. Find Monthly Revenue Growth
WITH monthly_sales AS (SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(oi.quantity * oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status='Delivered' GROUP BY DATE_TRUNC('month', o.order_date))
SELECT month, revenue, LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue, ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS growth_percentage FROM monthly_sales;

-- 30. Find the Highest Value Order for Each Customer
WITH order_values AS (SELECT o.customer_id, o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status='Delivered' GROUP BY o.customer_id, o.order_id)
SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_value DESC) AS rn FROM order_values) t WHERE rn = 1;

-- 31. Calculate Customer Lifetime Value (CLV)
SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS customer_lifetime_value FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status = 'Delivered' GROUP BY o.customer_id ORDER BY customer_lifetime_value DESC;

-- 32. Calculate Repeat Purchase Rate
WITH customer_orders AS (SELECT customer_id, COUNT(*) AS total_orders FROM orders WHERE status = 'Delivered' GROUP BY customer_id)
SELECT ROUND(100.0 * COUNT(CASE WHEN total_orders > 1 THEN 1 END) / COUNT(*), 2) AS repeat_purchase_rate FROM customer_orders;

-- 33. Find New vs Returning Customers
WITH first_order AS (SELECT customer_id, MIN(order_date) AS first_order_date FROM orders WHERE status='Delivered' GROUP BY customer_id)
SELECT CASE WHEN o.order_date = f.first_order_date THEN 'New Customer' ELSE 'Returning Customer' END AS customer_type, COUNT(*) AS total_orders FROM orders o JOIN first_order f ON o.customer_id = f.customer_id WHERE o.status = 'Delivered' GROUP BY customer_type;

-- 34. Find Customer Retention by Month
WITH monthly_orders AS (SELECT DISTINCT customer_id, DATE_TRUNC('month', order_date) AS order_month FROM orders WHERE status='Delivered')
SELECT order_month, COUNT(DISTINCT customer_id) AS active_customers FROM monthly_orders GROUP BY order_month ORDER BY order_month;

-- 35. Find Customers Who Purchased from Multiple Categories
SELECT o.customer_id, COUNT(DISTINCT p.category) AS categories_purchased FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.status = 'Delivered' GROUP BY o.customer_id HAVING COUNT(DISTINCT p.category) > 1;

-- 36. Find the Most Frequently Purchased Product Pair
SELECT oi1.product_id AS product_1, oi2.product_id AS product_2, COUNT(*) AS purchase_count FROM order_items oi1 JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id JOIN orders o ON oi1.order_id = o.order_id WHERE o.status = 'Delivered' GROUP BY oi1.product_id, oi2.product_id ORDER BY purchase_count DESC LIMIT 10;

-- 37. Calculate Average Days Between Orders
WITH customer_orders AS (SELECT customer_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order FROM orders WHERE status='Delivered')
SELECT customer_id, ROUND(AVG(order_date - previous_order), 2) AS avg_days_between_orders FROM customer_orders WHERE previous_order IS NOT NULL GROUP BY customer_id;

-- 38. Find the Fastest Growing Product Category
WITH monthly_category_sales AS (SELECT DATE_TRUNC('month', o.order_date) AS month, p.category, SUM(oi.quantity * oi.unit_price) AS revenue FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.status='Delivered' GROUP BY month, p.category)
SELECT month, category, revenue, revenue - LAG(revenue) OVER (PARTITION BY category ORDER BY month) AS revenue_growth FROM monthly_category_sales;

-- 39. Identify Customers at Risk of Churn
SELECT customer_id, MAX(order_date) AS last_order_date FROM orders GROUP BY customer_id HAVING MAX(order_date) < CURRENT_DATE - INTERVAL '90 days';

-- 40. Perform RFM Analysis
SELECT customer_id, CURRENT_DATE - MAX(o.order_date) AS recency, COUNT(o.order_id) AS frequency, SUM(oi.quantity * oi.unit_price) AS monetary FROM orders o JOIN order_items oi ON o.order_id = oi.order_id WHERE o.status = 'Delivered' GROUP BY customer_id ORDER BY monetary DESC;

-- 41. BONUS - Cohort Retention Analysis
WITH first_purchase AS (SELECT customer_id, DATE_TRUNC('month', MIN(order_date)) AS cohort_month FROM orders WHERE status='Delivered' GROUP BY customer_id),
monthly_orders AS (SELECT DISTINCT customer_id, DATE_TRUNC('month', order_date) AS order_month FROM orders WHERE status='Delivered')
SELECT f.cohort_month, m.order_month, COUNT(DISTINCT m.customer_id) AS retained_customers FROM first_purchase f JOIN monthly_orders m ON f.customer_id = m.customer_id GROUP BY f.cohort_month, m.order_month ORDER BY f.cohort_month;