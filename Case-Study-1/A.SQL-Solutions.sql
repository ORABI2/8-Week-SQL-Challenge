-- 1- What is the total amount each customer spent at the restaurant?
SELECT 
	customer_id,
	SUM(price) as Customer_spendings
FROM 
	menu m 
	Join sales s 
	on s.product_id = m.product_id
group by 
	customer_id


-- 2- How many days has each customer visited the restaurant?
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) as num_of_visits
FROM 
	sales
GROUP BY 
	customer_id;


-- 3- What was the first item from the menu purchased by each customer?
With CTE as(
	select
		customer_id,
		order_date,
		product_name,
		ROW_NUMBER() over (Partition BY customer_id order by order_date) as numbering
	from
		sales s JOIN menu m
		on m.product_id = s.product_id
)
SELECT
	customer_id,
	product_name as First_purchased_product
FROM
	CTE
WHERE numbering = 1


-- 4- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	Top(1)
	product_name,
	COUNT(s.product_id) as purchases
from 
	sales s
	join
	menu m
	on m.product_id = s.product_id
GROUP BY
	product_name
ORDER BY purchases DESC



-- 5- Which item was the most popular for each customer?
WITH CTE as(
	SELECT
		customer_id,
		product_name as item,	
		COUNT(s.product_id) as purchase_times,
		RANK() over(partition by customer_id order by COUNT(s.product_id) desc) as ranking
	FROM 
		sales s JOIN
		menu m on m.product_id = s.product_id
	group by 
		product_name,
		customer_id
)
select
	customer_id,
	item,
	purchase_times
From 
	CTE
WHERE ranking = 1;


-- 6- Which item was purchased first by the customer after they became a member?
with CTE as(
	SELECT
		s.customer_id,
		product_id,
		order_date,
		row_number() over (Partition by s.customer_id order by order_date) ranking
	from 
		sales s JOIN members m on s.customer_id  = m.customer_id
	WHERE
		order_date >= join_date
)
SELECT
	customer_id,
	product_name
FROM
	CTE c JOIN menu m on c.product_id = m.product_id
WHERE
	ranking = 1;



-- 7- Which item was purchased just before the customer became a member?
with CTE as(
	SELECT
		s.customer_id,
		product_id,
		order_date,
		join_date,
		row_number() over (Partition by s.customer_id order by order_date desc ) ranking
	from 
		sales s JOIN members m on s.customer_id  = m.customer_id
	WHERE
		order_date < join_date
)
SELECT
	customer_id,
	product_name,
	order_date,
	join_date
FROM
	CTE c JOIN menu m on c.product_id = m.product_id
WHERE
	ranking = 1



-- 8- What is the total items and amount spent for each member before they became a member?
SELECT
	b.customer_id as Member,
	COUNT(s.product_id) as Total_items,
	SUM(m.price) as Amount_spent

from 
	sales s JOIN
	menu m on s.product_id = m.product_id
	JOIN members b on b.customer_id = s.customer_id
WHERE
	order_date < join_date 
Group by b.customer_id



-- 9- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
	customer_id,
	SUM (Case 
			WHEN product_name = 'sushi' then price * 20
			ELSE price * 10
		END 
		) AS points
from
	sales s JOIN menu m on s.product_id = m.product_id
group by customer_id;



-- 10- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi how many points do customer A and B have at the end of January?
SELECT
	s.customer_id,
	SUM (
			case
				WHEN s.product_id = 1 THEN price*20
				WHEN s.order_date BETWEEN DATEADD(DAY, 6, join_date) AND join_date THEN price*20
				ELSE price * 10
			end 
		) as points
FROM
	members b 
	JOIN sales s
	on s.customer_id = b.customer_id
	join menu m 
	on m.product_id = s.product_id
WHERE s.order_date <= EOMONTH('2021-01-1')
group by s.customer_id;

-------------------------------------------------*******************************************
