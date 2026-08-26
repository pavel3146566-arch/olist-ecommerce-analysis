with customers_u as (
select
	customer_id,
	customer_unique_id
FROM customers
),

cohort as (
SELECT
	t1.customer_unique_id,
	DATE_TRUNC('month', MIN(t2.order_purchase_timestamp)) as cohort_month
FROM customers as t1
JOIN orders as t2
ON t1.customer_id = t2.customer_id
WHERE order_status not in ('canceled','unavailable')
GROUP BY t1.customer_unique_id
),

user_ltv as (
select
	c.customer_unique_id,
	COUNT(DISTINCT o.order_id) as total_orders,
	ROUND(SUM(p.payment_value),2) AS LTV
FROM customers_u as c
JOIN orders as o 
	ON c.customer_id = o.customer_id
JOIN order_payments as p
	ON o.order_id = p.order_id
WHERE order_status not in ('canceled','unavailable')
GROUP BY 1
ORDER BY LTV DESC
)


select 
	cc.cohort_month,
	COUNT(DISTINCT cc.customer_unique_id) AS cohort_size,
	ROUND(AVG(uu.LTV),2) AS avg_cohort_ltv
FROM cohort as cc
JOIN user_ltv as uu
ON cc.customer_unique_id = uu.customer_unique_id 
GROUP BY cc.cohort_month
ORDER BY cc.cohort_month ASC
