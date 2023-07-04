-- 1.What are the standard ingredients for each pizza?

with toppings_cte as(
	select
	pizza_id,
	Trim(value) as topping_id,
	topping_name
	from pizza_recipes r
	Cross APPLY string_split(cast(toppings AS VARCHAR), ',')
	JOIN pizza_toppings t on t.topping_id = value
)
select
	n.pizza_name,
	STRING_AGG(CAST(c.topping_name as varchar), ', ') as ingredients
from toppings_cte c, pizza_names n
where n.pizza_id = c.pizza_id
group by n.pizza_name;


-- 2.What was the most commonly excluded extra?

with extra_cte as(
	select
		value as extra
	from customer_orders
	cross apply string_split(extras, ',')
),
count_extras as(
	select 
		extra, COUNT(extra) as most_excluded
	from extra_cte
	group by extra
)
select 
	top(1)
	topping_name,
	most_excluded as Times_excluded
from count_extras c, pizza_toppings p
where c.extra = p.topping_id
order by most_excluded desc;



-- 3.What was the most common exclusion?

with exclusion_cte as(
	select
		value as exclusion
	from customer_orders
	cross apply string_split(exclusions, ',')
),
count_exclusions as(
	select 
		exclusion, COUNT(exclusion) as most_excluded
	from exclusion_cte
	group by exclusion
)
select 
	top(1)
	topping_name,
	most_excluded as Times_excluded
from count_exclusions c, pizza_toppings p
where c.exclusion = p.topping_id
order by most_excluded desc;

-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
	--  Meat Lovers
	--  Meat Lovers - Exclude Beef
	--  Meat Lovers - Extra Bacon


SELECT
	CONCAT( 
	pn.pizza_name,
	CASE
		WHEN co.exclusions IS NOT NULL THEN 
		CONCAT(' - Exclude ',
		(SELECT STRING_AGG(CAST(exclusion.topping_name AS varchar), ', ') 
		FROM pizza_toppings as exclusion
		WHERE exclusion.topping_id IN ( SELECT value FROM STRING_SPLIT(co.exclusions, ',') ) ))
	ELSE ''
	END,
	CASE
		WHEN co.extras IS NOT NULL THEN 
		CONCAT(' - Extra ',
		(SELECT STRING_AGG(CAST(extra.topping_name AS varchar), ', ') 
		FROM pizza_toppings as extra 
		WHERE extra.topping_id IN ( SELECT value FROM STRING_SPLIT(co.extras, ',') ) ))
	ELSE ''
	END) AS order_details
FROM
	customer_orders co
	JOIN
	pizza_names pn
	ON
	co.pizza_id = pn.pizza_id;

--Bad thinking INCOMING !!!!
/*
with extra_cte as(
	select
		c.record,
		trim(value) as extra
	from customer_orders c
	cross apply string_split(extras, ',')
),
exclusion_cte as(
	select
		c.record,
		trim(value) as exclusion
	from customer_orders c
	cross apply string_split(exclusions, ',')
)
SELECT
	co.order_id,
	CONCAT(
		n.pizza_name,
		CASE
			WHEN extras is not null THEN CONCAT(' - Extra ',STRING_AGG(CAST(p.topping_name as varchar), ','))
			else '' 
		end,
		CASE
			WHEN exclusions IS not null then CONCAT(' - Exclude ',STRING_AGG(CAST(p.topping_name as varchar), ','))
			else ''
		end
) as Order_Details
from customer_orders co
	JOIN pizza_names n on co.pizza_id = n.pizza_id
	LEFT JOIN pizza_toppings p on p.topping_id IN (select extra from extra_cte)
	LEFT JOIN pizza_toppings p2 on p2.topping_id IN ( SELECt exclusion from exclusion_cte )

group by co.order_id, co.extras, co.exclusions, n.pizza_name;
*/




-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza 
--   order from the customer_orders table and add a 2x in front of any relevant ingredients
--   For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
