-- ============================================================
-- Pizza Sales Analytics: Analysis Queries (MySQL)
-- Database: pizza_sales_db
-- Run pizza_sales_db_full.sql first to create and fill the tables.
-- Aggregate functions used: SUM, COUNT, AVG, MIN, MAX + GROUP BY, HAVING
-- ============================================================

USE pizza_sales_db;

-- 1) Overall KPIs: revenue, orders, quantity, average order value
SELECT
    ROUND(SUM(od.quantity * p.price), 2)                              AS total_revenue,
    COUNT(DISTINCT od.order_id)                                       AS total_orders,
    SUM(od.quantity)                                                  AS total_quantity,
    ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT od.order_id), 2) AS avg_order_value
FROM order_details od
JOIN pizzas p ON od.pizza_name_id = p.pizza_name_id;

-- 2) Revenue, orders and average order value per city
SELECT
    b.city,
    COUNT(DISTINCT o.order_id)                                        AS total_orders,
    ROUND(SUM(od.quantity * p.price), 2)                              AS total_revenue,
    ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN branches b       ON o.branch_id = b.branch_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p         ON od.pizza_name_id = p.pizza_name_id
GROUP BY b.city
ORDER BY total_revenue DESC;

-- 3) Monthly revenue (all cities)
SELECT
    MONTH(o.order_date)                    AS month_num,
    MONTHNAME(o.order_date)                AS month_name,
    ROUND(SUM(od.quantity * p.price), 2)   AS monthly_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p         ON od.pizza_name_id = p.pizza_name_id
GROUP BY MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY month_num;

-- 4) Monthly revenue per city
SELECT
    b.city,
    MONTH(o.order_date)                    AS month_num,
    ROUND(SUM(od.quantity * p.price), 2)   AS monthly_revenue
FROM orders o
JOIN branches b       ON o.branch_id = b.branch_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p         ON od.pizza_name_id = p.pizza_name_id
GROUP BY b.city, MONTH(o.order_date)
ORDER BY b.city, month_num;

-- 5) Top 5 pizzas by quantity sold
SELECT
    pt.name,
    SUM(od.quantity) AS total_quantity_sold
FROM order_details od
JOIN pizzas p       ON od.pizza_name_id = p.pizza_name_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 6) Top 5 pizzas by revenue
SELECT
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p       ON od.pizza_name_id = p.pizza_name_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 5;

-- 7) Category share: quantity and % of total
SELECT
    pt.category,
    SUM(od.quantity) AS quantity_sold,
    ROUND(100 * SUM(od.quantity) / (SELECT SUM(quantity) FROM order_details), 2) AS pct_of_total
FROM order_details od
JOIN pizzas p       ON od.pizza_name_id = p.pizza_name_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY quantity_sold DESC;

-- 8) Category mix per city
SELECT
    b.city,
    pt.category,
    SUM(od.quantity) AS quantity_sold
FROM orders o
JOIN branches b       ON o.branch_id = b.branch_id
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p         ON od.pizza_name_id = p.pizza_name_id
JOIN pizza_types pt   ON p.pizza_type_id = pt.pizza_type_id
GROUP BY b.city, pt.category
ORDER BY b.city, quantity_sold DESC;

-- 9) Orders by hour of the day (peak times)
SELECT
    HOUR(o.order_time)        AS hour_of_day,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
GROUP BY HOUR(o.order_time)
ORDER BY hour_of_day;

-- 10) Order value statistics: average, smallest and largest order
SELECT
    ROUND(AVG(order_total), 2) AS avg_order_value,
    MIN(order_total)           AS smallest_order,
    MAX(order_total)           AS largest_order
FROM (
    SELECT od.order_id, ROUND(SUM(od.quantity * p.price), 2) AS order_total
    FROM order_details od
    JOIN pizzas p ON od.pizza_name_id = p.pizza_name_id
    GROUP BY od.order_id
) AS order_totals;

-- 11) Pizza sizes that bring in more than $50,000 (HAVING example)
SELECT
    p.size,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_name_id = p.pizza_name_id
GROUP BY p.size
HAVING SUM(od.quantity * p.price) > 50000
ORDER BY revenue DESC;
