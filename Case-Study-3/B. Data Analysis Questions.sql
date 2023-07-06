-- 1. How many customers has Foodie-Fi ever had?

select
	count(distinct(customer_id)) total_customers
from
	subscriptions



-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select
	DATEPART(mm, start_date) Month,
	COUNT(customer_id) monthly_trial_subs
from
	subscriptions s
where plan_id = 0
group by DATEPART(MM, start_date)
order by Month;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select
	plan_name,
	COUNT(plan_name) as total
from subscriptions s JOIN plans p on p.plan_id = s.plan_id
where start_date > '2020-12-31'
group by plan_name;



-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with customer_cte as(
	select
		COUNT(customer_id) as total
	from 
		subscriptions
	where
		plan_id = 4
),
all_cte as(
select
	COUNT(distinct customer_id) total_customers
from
	subscriptions
)
select 
	total,
	round((cast(total as float)*100)/total_customers, 2) as percentage
from all_cte, customer_cte;



-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with churned_cte as(
	select 
		customer_id,
		plan_id,
		start_date,
		Lead(plan_id,1) over(partition by customer_id order by start_date)as ss,
		Case
			WHEN plan_id = 0 AND Lead(plan_id,1) over(partition by customer_id order by start_date) = 4 THEN 1
			ELSE 0
		END as churned_customers
	from
		subscriptions
)
select
	SUM(churned_customers) as total_straight_churners,
	FLOOR (SUM(churned_customers)/Cast(COUNT(distinct customer_id)as float) * 100) as percentage
from churned_cte;



-- 6. What is the number and percentage of customer plans after their initial free trial?

with plans_cte as(
	select 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) as plan_order
	from
		subscriptions 
	where plan_id <> 0
)
select
	plan_name,
	COUNT(pc.plan_id) as total_plans_after_trial,
	COUNT(pc.plan_id) / cast ((SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS float) * 100 as percentage
from plans_cte pc join plans p on pc.plan_id = p.plan_id
where pc.plan_order = 1
group by plan_name;
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with plans_cte as(
	select 
		customer_id,
		plan_id,
		start_date,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date desc) as plan_order
	from
		subscriptions 
	where start_date <= '2020-12-31'
)
select
	plan_name,
	COUNT(pc.customer_id) as total_plans,
	COUNT(pc.customer_id) / cast ((SELECT COUNT(DISTINCT customer_id) FROM subscriptions where start_date <= '2020-12-31') AS float) * 100 as percentage
from plans_cte pc join plans p on pc.plan_id = p.plan_id
where pc.plan_order = 1
group by plan_name;


-- 8. How many customers have upgraded to an annual plan in 2020?

select
	COUNT(customer_id) as total_customers
from subscriptions
where plan_id = 3 AND start_date <= '2020-12-31' and start_date >= '2020-01-01';


-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with cte as(
	select *
	from subscriptions
	where plan_id =3
)
select AVG(DATEDIFF(DAY, s.start_date, c.start_date)) as avg_days
from cte c JOIN subscriptions s on s.customer_id = c.customer_id
where s.plan_id = 0;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with join_date_cte as(
	select customer_id, start_date as join_date
	from subscriptions
	where plan_id = 0
),
pro_plan_date as(
	select customer_id, start_date as pro_date
	from subscriptions
	where plan_id = 3
),
periods_cte as(
	select 
		j.customer_id,
		join_date,
		pro_date,
		DATEDIFF(DAY, join_date, pro_date)/30 + 1 as bin --creating monthly bins of 30 days period
	from pro_plan_date p JOIN join_date_cte j on j.customer_id = p.customer_id

)
select 
	case
		when bin = 1 THEN CONCAT(bin-1,'-', bin*30, ' days')
		else CONCAT((bin-1)*30,'-', bin*30,' days' )
	end as Periods,
	COUNT(customer_id) as total_customers,
	cast(AVG(DATEDIFF(DAY, join_date, pro_date)*1.0)AS decimal(6,2)) as avg_days
from periods_cte
group by bin;



-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with downgraded_cte as(
	select 
		customer_id,
		plan_id,
		start_date,
		Lead(plan_id,1) over(partition by customer_id order by start_date)as ss,
		Case
			WHEN plan_id = 2 AND Lead(plan_id,1) over(partition by customer_id order by start_date) = 1 THEN 1
			ELSE 0
		END as downgraded_customers
	from
		subscriptions
)
select sum(downgraded_customers) as Downgraded_customers
from downgraded_cte;
