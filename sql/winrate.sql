with delivery_status as (
select
	order_id,
	order_estimated_delivery_date,
	order_delivered_customer_date,
 	CASE 
 	WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'late'
	 ELSE 'On time'
	END as delivery_status
FROM orders
WHERE order_status = 'delivered' and order_delivered_customer_date IS NOT NULL),

reviews as (
select
	d.order_id,
	d.delivery_status,
	r.review_score
FROM order_reviews as r
JOIN delivery_status as d
ON r.order_id = d.order_id
ORDER BY r.review_score ASC)


select 
	review_score,
	COUNT(order_id) as total_orders,
	SUM(
CASE
WHEN delivery_status = 'late' then 1 else 0 end) as late_orders,
ROUND(
        SUM(CASE WHEN LOWER(delivery_status) = 'late' THEN 1 ELSE 0 END) * 100.0 
    / COUNT(order_id)
, 2) AS late_share_pct
FROM reviews
GROUP BY review_score
ORDER BY review_score ASC






	

