--ZOMATO DATA ANALYSIS

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS deliveries;


create table customers
	(
		customer_id INT PRIMARY KEY,
		customer_name VARCHAR(25),
		reg_date DATE
	);

CREATE TABLE restaurants 
	(	
		restaurant_id INT PRIMARY KEY,
		restaurant_name VARCHAR(55),
		city VARCHAR(15),
		opening_hours VARCHAR(55)
	);
	
CREATE TABLE orders 
	(
		order_id INT PRIMARY KEY,
		customer_id INT, -- this is coming from customer table 
		restaurant_id INT, -- this is coming from restaurant table 
		order_item VARCHAR(55),
		order_date DATE,
		order_time TIME, 
		order_status VARCHAR(25),
		total_amount FLOAT
	);

--adding FK constraint
ALTER TABLE orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id)
REFERENCES customers (customer_id)

--adding FK constraint
ALTER TABLE orders
ADD CONSTRAINT fk_restaurants
FOREIGN KEY (restaurant_id)
REFERENCES restaurants (restaurant_id)

CREATE TABLE riders 
	(
		rider_id INT PRIMARY KEY,
		rider_name VARCHAR (55),
		sign_up DATE
	);

DROP TABLE IF EXISTS deliveries;
CREATE TABLE deliveries 
(
	delivery_id INT PRIMARY KEY,
	order_id INT,              -- from orders table
	delivery_status VARCHAR(35),
	delivery_time TIME,
	rider_id INT,              -- from riders table
	CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
	CONSTRAINT fk_riders FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);



--EDA

SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;



-- -------------------------------
-- Analysis and reports
-- -------------------------------


-- Q.1
-- Write a query to find top 5 most frequently ordered dishes by customer called Arjun Sharma in the last 1 year.
--
SELECT * 
FROM 
(SELECT 
	c.customer_id,
	c.customer_name,
	o.order_item as dishes,
	count(*) as total_orders,
	DENSE_RANK() OVER(PARTITION BY count(*)) AS rank
FROM orders AS o
JOIN 
customers AS c 
ON 
c.customer_id = o.customer_id 
WHERE 
	o.order_date >= CURRENT_DATE - INTERVAL '1 YEAR'
AND 
	c.customer_name = 'Arjun Sharma'
GROUP BY 1,2,3
ORDER BY 4 DESC) as t1
WHERE rank <= 5



--
--2. Popular Time slots 
-- Question: Identify the time slots during which the most orders are placed. Based on 2 hours intervals. 
SELECT 
	CASE
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
		WHEN EXTRACT (HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
	END AS time_slot,
	COUNT(order_id) AS order_count
	FROM orders
	GROUP BY time_slot
	ORDER BY order_count DESC;

-- 3. Order Value Analysis
-- Question: Find the average order value per customer who has placed more than or equal to 300 orders.
-- Return customer_name and AOV (average order value)

SELECT
	c.customer_name,
	AVG (o.total_amount) AS aov,
	COUNT (o.order_id) AS order_placed
FROM orders AS o
	JOIN customers AS c	 
	on o.customer_id = c.customer_id
GROUP BY 1 
	HAVING COUNT (o.order_id) >= 300

-- 4. City Revenue Leaders  
-- Question: Find the top 3 restaurants in each city based on total revenue.  
-- Return: city, restaurant_name, total_revenue, city_rank  

WITH city_rank AS (
    SELECT 
        r.city,
        r.restaurant_name,
        SUM(o.total_amount) AS total_revenue,
        RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS city_rank
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY r.city, r.restaurant_name
)
SELECT city, restaurant_name, total_revenue, city_rank
FROM city_rank
WHERE city_rank <= 3
ORDER BY city, city_rank;

-- 5. Customer Retention Tracker  
-- Question: Find month-over-month customer retention rates.  
-- Return: current_month, active_customers, retained_customers, retention_rate (%)  

WITH monthly_orders AS (
    SELECT customer_id, DATE_TRUNC('month', order_date) AS month
    FROM orders
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
),
retention_calc AS (
    SELECT 
        a.month AS current_month,
        COUNT(DISTINCT a.customer_id) AS active_customers,
        COUNT(DISTINCT b.customer_id) AS retained_customers
    FROM monthly_orders a
    LEFT JOIN monthly_orders b 
        ON a.customer_id = b.customer_id 
       AND b.month = a.month + INTERVAL '1 month'
    GROUP BY a.month
)
SELECT 
    current_month,
    active_customers,
    retained_customers,
    ROUND((retained_customers::NUMERIC / active_customers) * 100, 2) AS retention_rate
FROM retention_calc
ORDER BY current_month;

-- Q.6
-- Write a query to find restaurants where the average order value is higher than the overall average order value.
SELECT 
	r.restaurant_name,
	AVG(o.total_amount) AS avg_restaurant_value
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name
HAVING AVG(o.total_amount) > (SELECT AVG(total_amount) FROM orders);

-- Q.7
-- Write a query to find the top 3 cities with the highest number of delivered orders.
SELECT 
	r.city,
	COUNT(d.delivery_id) AS total_deliveries
FROM deliveries d
JOIN orders o ON d.order_id = o.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE d.delivery_status = 'Delivered'
GROUP BY r.city
ORDER BY total_deliveries DESC
LIMIT 3;


-- Q.8
-- Write a query to list customers who haven’t placed any orders in the last 6 months.
SELECT 
	c.customer_name
FROM customers c
LEFT JOIN orders o 
	ON c.customer_id = o.customer_id
	AND o.order_date >= CURRENT_DATE - INTERVAL '6 MONTH'
WHERE o.order_id IS NULL;

-- Q.9
-- Write a query to calculate total revenue and total number of cancelled orders per restaurant.
SELECT 
	r.restaurant_name,
	SUM(CASE WHEN o.order_status != 'Cancelled' THEN o.total_amount ELSE 0 END) AS total_revenue,
	SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC;


-- Q.10
-- Write a query to find the percentage of delivered orders for each rider.
SELECT 
	r.rider_name,
	ROUND(
		(SUM(CASE WHEN d.delivery_status = 'Delivered' THEN 1 ELSE 0 END)*100.0) / COUNT(*),
		2
	) AS delivery_success_rate
FROM deliveries d
JOIN riders r ON d.rider_id = r.rider_id
GROUP BY r.rider_name;

-- Q.11
-- Write a query to identify the top 3 restaurants in each city based on total revenue from delivered orders in the last 6 months.

WITH restaurant_revenue AS (
	SELECT 
		r.restaurant_name,
		r.city,
		SUM(o.total_amount) AS total_revenue
	FROM orders o
	JOIN restaurants r ON o.restaurant_id = r.restaurant_id
	JOIN deliveries d ON o.order_id = d.order_id
	WHERE 
		d.delivery_status = 'Delivered'
		AND o.order_date >= CURRENT_DATE - INTERVAL '6 MONTH'
	GROUP BY r.restaurant_name, r.city
)
SELECT 
	city,
	restaurant_name,
	total_revenue
FROM (
	SELECT 
		city,
		restaurant_name,
		total_revenue,
		DENSE_RANK() OVER(PARTITION BY city ORDER BY total_revenue DESC) AS rank
	FROM restaurant_revenue
) ranked
WHERE rank <= 3
ORDER BY city, rank;

-- Q.12
-- Write a query to find the most loyal customers for each restaurant 
-- (the customer who placed the highest number of orders at that restaurant).

WITH customer_orders AS (
	SELECT 
		o.restaurant_id,
		o.customer_id,
		COUNT(o.order_id) AS total_orders
	FROM orders o
	GROUP BY o.restaurant_id, o.customer_id
)
SELECT 
	r.restaurant_name,
	c.customer_name,
	total_orders
FROM (
	SELECT 
		restaurant_id,
		customer_id,
		total_orders,
		RANK() OVER(PARTITION BY restaurant_id ORDER BY total_orders DESC) AS rank
	FROM customer_orders
) ranked
JOIN restaurants r ON ranked.restaurant_id = r.restaurant_id
JOIN customers c ON ranked.customer_id = c.customer_id
WHERE rank = 1
ORDER BY r.restaurant_name;





