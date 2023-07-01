-- 1. How many pizzas were ordered?

select count(*) as num_of_orders
from customer_orders



-- 2. How many unique customer orders were made?

select count(distinct order_id) as unique_orders
from customer_orders



-- 3. How many successful orders were delivered by each runner?

select
	runner_id,
	COUNT(runner_id) as orders
from cleaned_runner_orders
where cancellation is Null
group by runner_id



-- 4. How many of each type of pizza was delivered?

select
	pizza_name,
	COUNT (c.order_id) as Delivered

from cleaned_runner_orders r, customer_orders c, pizza_names p

where 
	r.cancellation IS null 
	AND
	c.order_id = r.order_id 
	AND
	c.pizza_id = p.pizza_id
group by pizza_name



-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select
	customer_id,
	pizza_name,
	COUNT(p.pizza_id) ordered

from
	customer_orders c, pizza_names p
where
	c.pizza_id = p.pizza_id
group by 
	customer_id,
	pizza_name
order by customer_id



-- 6. What was the maximum number of pizzas delivered in a single order?

select
	TOP(1)
	order_id,
	no_of_pizzas
from
	(
		select
			order_id,
			COUNT(order_id) as no_of_pizzas
		from customer_orders
		group by order_id
	) as single_order
order by no_of_pizzas desc;



-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select
	c.customer_id,
	sum(case
			when exclusions is not null
			or extras is not null then 1
			else 0
		end
		) as at_least_1_change ,
	sum(case
			when exclusions is null
			and extras is null then 1
			else 0
		end
		) as no_changes

from
	customer_orders c, cleaned_runner_orders r
where 
	r.order_id = c.order_id 
	and
	r.cancellation is null
group by c.customer_id



-- 8. How many pizzas were delivered that had both exclusions and extras?

select
	SUM(case
			WHEN exclusions IS NOT null
			AND extras IS NOT NULL THEN 1
			ELSE 0
		end
		) as changed_orders
from customer_orders c, cleaned_runner_orders r
where 
	cancellation Is NULL AND
	c.order_id = r.order_id



-- 9. What was the total volume of pizzas ordered for each hour of the day?

select DATEPART(HOUR, order_time) as daily_hour,
	COUNT(*) orders_per_hour
from customer_orders
group by DATEPART(HOUR, order_time)



-- 10. What was the volume of orders for each day of the week?

select 
	DATENAME(WEEKDAY, order_time) day_of_week,
	count(*) as total_orders
from customer_orders 
group by DATENAME(WEEKDAY, order_time)