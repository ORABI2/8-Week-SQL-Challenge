/*
A. Customer Journey:
	Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

	Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
*/

select
	customer_id,
	p.plan_id,
	plan_name,
	start_date,
	DATEDIFF(DAY, LAG(start_date) over(partition by customer_id order by p.plan_id), start_date) as diff
	
from subscriptions s JOIN plans p on p.plan_id = s.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)

