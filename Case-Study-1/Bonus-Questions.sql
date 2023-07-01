/*1- Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights
without needing to join the underlying tables using SQL.
Recreate the following table output using the available data: */
select
	s.customer_id,
	order_date,
	product_name,
	price,
	(
		Case
			WHEN order_date >= join_date then 'Y'
			ELSE 'N'
		END
	) as member
from 
	sales s JOIN menu m on s.product_id = m.product_id
	LEFT JOIN members b on s.customer_id = b.customer_id


------------------------------


with Cte as(
		select
		s.customer_id,
		order_date,
		product_name,
		price,
		Case
			WHEN order_date >= join_date then 'Y'
			ELSE 'N'
		END as member
		from 
		sales s JOIN menu m on s.product_id = m.product_id
		LEFT JOIN members b on s.customer_id = b.customer_id
	)
select *,
	(
		Case
			WHEN member = 'Y' then RANK() OVER (PARTITION BY customer_id, member order by order_date)
			ELSE NULL
		END
	) as member
from 
	Cte