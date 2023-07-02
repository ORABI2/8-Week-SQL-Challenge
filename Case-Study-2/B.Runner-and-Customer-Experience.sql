-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select
	datepart(ww, registration_date) as week_period,
	count(runner_id) as total_runners
	
from
	runners

group by datepart(ww, registration_date);



-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select
	runner_id,
	AVG(DATEDIFF(MINUTE, order_time, pickup_time)) avg_time
from
	cleaned_runner_orders r JOIN
	customer_orders c on r.order_id = c.order_id
group by runner_id;



-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

select
	r.order_id,
	COUNT(pizza_id) as num_of_pizzas,
	DATEDIFF(MINUTE, order_time, pickup_time) as time_to_be_prepared

from
	cleaned_runner_orders r 
	JOIN
	customer_orders c
	on 
	r.order_id = c.order_id
where 
	pickup_time IS NOT NULL 
	AND 
	order_time IS NOT NULL
group by 
	r.order_id,
	DATEDIFF(MINUTE, order_time, pickup_time)
order by r.order_id;

--*** Yes!!, there is a positive relationship, when number of pizzas get bigger also the 'time_to_be_prepared' 



-- 4. What was the average distance travelled for each customer?

select
	customer_id,
	ROUND(AVG(CAST(distance AS float)),2) average_distance_travelled_per_customer
from
	customer_orders c, cleaned_runner_orders r
where 
	r.order_id = c.order_id 
	AND 
	distance IS NOT NULL
group by 
	customer_id;



-- 5. What was the difference between the longest and shortest delivery times for all orders?

select
	MAX(duration) - MIN(duration) as diff_between_longest_and_shortest_delivery_times
from
	cleaned_runner_orders;

/*
with time_cte as(
	select
		DATEDIFF(MINUTE, order_time, pickup_time) as delivery_times
	from customer_orders c, cleaned_runner_orders r
	where c.order_id = r.order_id AND pickup_time IS NOT NULL
)
*/



-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- speed = distance/Time
select
	r.order_id,
	runner_id,
	COUNT(pizza_id) as no_of_pizzas,
	ROUND(AVG(cast(distance as float)/cast(duration as int)*60),2) as 'Speed: Km/H'
from
	cleaned_runner_orders r,
	customer_orders c
where 
	r.order_id = c.order_id
	AND 
	distance IS NOT NULL
group by 
	runner_id,
	r.order_id
order by [Speed: Km/H] desc;

/*
Notices a trend which the most fastest runner carrying 1 pizza only
and the slowest runner was carrying 3 Pizzas.
*/




-- 7. What is the successful delivery percentage for each runner?

with total_cte as(
	select
		runner_id,
		COUNT(runner_id) as total_orders
	from cleaned_runner_orders
	group by runner_id
),
successful_cte as(
	select
		runner_id,
		COUNT(runner_id) as successful_orders
	from cleaned_runner_orders
	where cancellation IS NULL
	group by runner_id
)

select
	t.runner_id,
	Concat((successful_orders*100/total_orders), '%') as delivery_percentage
from
	total_cte t ,
	successful_cte s 
where t.runner_id = s.runner_id

--##################
