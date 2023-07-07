-- 1. How many unique nodes are there on the Data Bank system?

select
	COUNT(distinct node_id) unique_nodes
from 
	customer_nodes;


-- 2. What is the number of nodes per region?
/*
select COUNT(node_id)
from customer_nodes; 
--3500 total nodes in customer_nodes table
*/
select
	region_name,
	COUNT(distinct node_id) total_nodes
from 
	regions r 
	JOIN
	customer_nodes cn 
	on r.region_id = cn.region_id
group by region_name;
-- 3. How many customers are allocated to each region?

select
	region_name,
	COUNT(distinct customer_id) total_customers
from 
	customer_nodes cn
	JOIN
	regions r
	on r.region_id = cn.region_id
group by region_name;


-- 4. How many days on average are customers reallocated to a different node?
with ordered_cte as(
	select
		*,
		Rank() over(partition by customer_id, node_id order by start_date) as new_node,
		LEAD(start_date, 1) over(partition by customer_id order by start_date) as different_node_date
	from customer_nodes
),
final_cte as(
	select 
		customer_id,
		node_id,
		start_date,
		CASE WHEN new_node = 1 THEN different_node_date ELSE NULL END as next_node_date
	from ordered_cte
	where new_node = 1
)
select
	AVG(DATEDIFF(DAY, start_date, next_node_date)) as average_days_by_customer
from final_cte
where next_node_date IS NOT NULL;

-- w shokran! :)


-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

-- we will make a small change for the previous query
with ordered_cte as(
	select
		*,
		Rank() over(partition by customer_id, node_id order by start_date) as new_node,
		LEAD(start_date, 1) over(partition by customer_id order by start_date) as different_node_date
	from customer_nodes
),
final_cte as(
	select 
		customer_id,
		node_id,
		region_id,
		start_date,
		CASE WHEN new_node = 1 THEN different_node_date ELSE NULL END as next_node_date
	from ordered_cte
	where new_node = 1
),
metrics_cte as(
select
	AVG(DATEDIFF(DAY, start_date, next_node_date)) as average_days_by_customer
from final_cte
where next_node_date IS NOT NULL
group by region_id
)
select
	percentile_cont(0.5) within group(order by average_days_by_customer) over() as median,
	percentile_cont(0.8) within group(order by average_days_by_customer) over() as percentile_80,
	percentile_cont(0.95) within group(order by average_days_by_customer) over() as percentile_95
from metrics_cte