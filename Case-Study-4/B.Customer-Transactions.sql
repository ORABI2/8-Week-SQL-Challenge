-- 1. What is the unique count and total amount for each transaction type?
select
	txn_type,
	count(txn_type) as Unique_Count ,
	SUM(txn_amount) as Total_amount

from customer_transactions
group by txn_type;



-- 2. What is the average total historical deposit counts and amounts for all customers?

with deposit_cte as(
select 
	customer_id,
	count(txn_type) as Total_deposits,
	sum(txn_amount) as deposit_amounts
from customer_transactions
where txn_type = 'deposit'
group by customer_id
)
select
	AVG(Total_deposits) as avg_total_deposits,
	AVG(deposit_amounts) as avg_deposit_amounts
from deposit_cte;



-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

--- exploring the data
select *
from customer_transactions
order by txn_date;
---
-- getting the count of (deposits, withdrawals, purchases) for each customer per month
with customers_cte as(
	select
		customer_id,
		sum(case when txn_type = 'deposit' then 1 else 0 end) as total_deposits,
		sum(case when txn_type = 'withdrawal' then 1 else 0 end) as total_withdrawals,
		sum(case when txn_type = 'purchase' then 1 else 0 end) as total_purchases,
		DATEPART(MM, txn_date) as monthly
	from customer_transactions
	group by DATEPART(MM, txn_date), customer_id
)
select
	monthly as month,
	COUNT(customer_id) as total_customers

from customers_cte
where total_deposits > 1 and (total_purchases >= 1 OR total_withdrawals >= 1)
group by monthly;



-- 4. What is the closing balance for each customer at the end of the month?

with balance_cte as(
	select
		customer_id,
		txn_date,
		sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as total
	from customer_transactions
	group by customer_id, txn_date
)
select
	customer_id,
	EOMONTH(txn_date) as End_of_Month,
	sum(total) as closing_balance
from balance_cte
group by customer_id, EOMONTH(txn_date)
order by customer_id;



-- 5. What is the percentage of customers who increase their closing balance by more than 5%?

with balance_cte as(
	select
		customer_id,
		txn_date,
		sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as total
	from customer_transactions
	group by customer_id, txn_date
),
closing_balance_cte as (
	select
		customer_id,
		EOMONTH(txn_date) as End_of_Month,
		sum(total) as closing_balance
	from balance_cte
	group by customer_id, EOMONTH(txn_date)
),
next_balance_cte as(
select *, LEAD(closing_balance, 1) over(partition by customer_id order by End_of_Month) as next_balance
from closing_balance_cte

)
select 
	*
from next_balance_cte
order by customer_id
----- TB-Completed




