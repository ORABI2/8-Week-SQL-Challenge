select week_date
from weekly_sales

---



--- Let's Clean the data 

DROP TABLE IF EXISTS #clean_weekly_sales;
select
	CONVERT(date, week_date, 3) as week_date,
	ceiling(DATEPART(dd, CONVERT(date, week_date, 3))-1)/7 + 1 as week_number,
	datepart(MM, CONVERT(date, week_date, 3)) as month_number,
	datepart(YY, CONVERT(date, week_date, 3)) as calendar_year,
	region,
	platform,
	segment,
	case
		when segment LIKE '%1%' THEN 'Young Adults'
		when segment LIKE '%2%' THEN 'Middle Aged'
		When segment LIKE '%3%' Or segment LIKE '%4%'  Then 'Retirees'
		ELSE 'unknown!' 
		End as age_band,
	Case
		when segment LIKE 'C%' THEN 'Couples'
		when segment LIKE 'F%' THEN 'Families'
		ELSE 'unknown!' 
		End as demographic,
	transactions,
	sales,
	ROUND(cast(sales as float)/transactions, 2) as avg_transaction

INTO ##Clean_weekly_sales
from weekly_sales


select *
from ##Clean_weekly_sales