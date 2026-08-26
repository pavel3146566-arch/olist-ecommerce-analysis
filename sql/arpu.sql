with succesfull_orders as (
select 
	order_id,
	customer_id,
	order_purchase_timestamp
from orders 
where 
	order_status = 'delivered'),

payment as (
select
	a.order_id,
	a.customer_id,
	a.order_purchase_timestamp,
	b.payment_value
from succesfull_orders as a
JOIN order_payments as b
ON a.order_id = b.order_id
),

final_customers as (
select 
	t1.order_id,
	t1.customer_id,
	t1.order_purchase_timestamp,
	t1.payment_value,
	t2.customer_unique_id
from payment as t1
JOIN customers as t2
ON t1.customer_id = t2.customer_id
)


select
	DATE_TRUNC('month', order_purchase_timestamp) as order_month,
	SUM(payment_value) as GMV,
	COUNT(DISTINCT customer_unique_id) as unique_count,
	ROUND(SUM(payment_value)::numeric/COUNT(customer_unique_id),2) as ARPU
from final_customers
GROUP BY DATE_TRUNC('month',order_purchase_timestamp)
ORDER BY order_month
