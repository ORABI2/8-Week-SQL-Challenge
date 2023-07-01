-- Cleaning runners_orders Table
-- I cleaned the NULL values manually but the other columns will do some operations on them with DML
-- Inspecting the data first
-- so we need to trim any measurements units

Drop table if exists cleaned_runner_orders
CREATE TABLE cleaned_runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" smalldatetime,
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);
INSERT INTO cleaned_runner_orders
SELECT 
	order_id,
	runner_id,
	pickup_time,
	CAST(TRIM('km' from distance) AS float),
	CAST(SUBSTRING(duration, 1, 2) as int),
	CASE
        WHEN cancellation in ('null', '') THEN null
        ELSE cancellation
	END as cancellation
from runner_orders;

--inspecting our cleaned results
select *
from cleaned_runner_orders;
---------------------------------



