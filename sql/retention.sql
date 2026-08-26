WITH cohort AS (
SELECT 
	c.customer_unique_id,
    MIN(DATE_TRUNC('month', o.order_purchase_timestamp)) AS cohort_month
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
),

orders_history AS (
SELECT 
    DATE_TRUNC('month', t1.order_purchase_timestamp) AS order_month, 
    t2.customer_unique_id,
    t3.cohort_month
FROM orders AS t1
JOIN customers AS t2
    ON t1.customer_id = t2.customer_id
JOIN cohort AS t3
    ON t3.customer_unique_id = t2.customer_unique_id
WHERE t1.order_status = 'delivered'
),

lifetime_calc AS (
SELECT
     cohort_month, 
     customer_unique_id,
     (EXTRACT(year FROM order_month) - EXTRACT(year FROM cohort_month)) * 12
        + (EXTRACT(month FROM order_month) - EXTRACT(month FROM cohort_month)) AS lifetime_month
FROM orders_history
),

cohort_size as (
SELECT
	COUNT(DISTINCT customer_unique_id) as count_customers,
	lifetime_month,
	cohort_month
FROM lifetime_calc
GROUP BY 2,3)


SELECT 
    cohort_month,
    lifetime_month,
    count_customers,
	FIRST_VALUE(count_customers) OVER (
        PARTITION BY cohort_month 
        ORDER BY lifetime_month
    ) AS initial_size,
    ROUND(count_customers::numeric / FIRST_VALUE(count_customers) OVER (PARTITION BY cohort_month ORDER BY lifetime_month
     ) * 100, 2) AS retention_rate_pct
FROM cohort_size
ORDER BY cohort_month, lifetime_month
