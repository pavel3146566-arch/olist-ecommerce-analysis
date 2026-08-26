WITH cheques as (
select 
	order_id,
	SUM(payment_value) as revenue
FROM order_payments
GROUP BY order_id
)

select 
	ROUND(AVG(revenue),2) AS aov,
	DATE_TRUNC('month', o.order_purchase_timestamp) as order_month
from cheques as c
JOIN orders as o
ON c.order_id = o.order_id
WHERE o.order_status not in ('canceled', 'unavailable')
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY order_month ASC
