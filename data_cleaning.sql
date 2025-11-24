CREATE TABLE staging_motorcycle_sales (
    date VARCHAR(20),
    time VARCHAR(20),
    year INT,
    customer_age INT,
    customer_gender VARCHAR(10),
    country VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    sub_category VARCHAR(100),
    quantity INT,
    unit_cost NUMERIC,
    revenue NUMERIC,
    payment VARCHAR(50),
    rating NUMERIC
);
select * from staging_motorcycle_sales
---------------------------------------------------
ALTER TABLE staging_motorcycle_sales
ADD COLUMN clean_date DATE;
---------------------------------------------------
-----------------------------------------------------------
UPDATE staging_motorcycle_sales
SET clean_date =
    CASE
        -- For 2-digit year dates like 02-19-16 or 2-20-16
        WHEN date ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$'
            THEN to_date(date, 'MM-DD-YY')
            
        -- For 4-digit year dates like 12-03-2016 or 08-07-2015
        WHEN date ~ '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
            THEN TO_DATE(date, 'MM-DD-YYYY')

        -- Catch any other unknown format (optional)
        ELSE NULL
    END;
-----------------------------------------------------------
select distinct year,count(*) 
from staging_motorcycle_sales
group by year
-- 

select distinct customer_gender,count(*)
from staging_motorcycle_sales
group by customer_gender;
-- 
select distinct country,count(*)
from staging_motorcycle_sales
group by country;
-- 
select distinct state,count(*)
from staging_motorcycle_sales
group by state
-- 
select distinct product_category,count(*)
from staging_motorcycle_sales
group by product_category
-- 
select distinct sub_category,count(*)
from staging_motorcycle_sales
group by sub_category
-- 
select distinct payment,count(*)
from staging_motorcycle_sales
group by payment

-- checking nulls
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE date IS NULL) AS null_date,
    COUNT(*) FILTER (WHERE time IS NULL) AS null_time,
    COUNT(*) FILTER (WHERE customer_age IS NULL) AS null_customer_age,
    COUNT(*) FILTER (WHERE customer_gender IS NULL) AS null_customer_gender,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
    COUNT(*) FILTER (WHERE state IS NULL) AS null_state,
    COUNT(*) FILTER (WHERE product_category IS NULL) AS null_product_category,
    COUNT(*) FILTER (WHERE sub_category IS NULL) AS null_sub_category,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity,
    COUNT(*) FILTER (WHERE unit_cost IS NULL) AS null_unit_cost,
    COUNT(*) FILTER (WHERE revenue IS NULL) AS null_revenue,
    COUNT(*) FILTER (WHERE payment IS NULL) AS null_payment,
    COUNT(*) FILTER (WHERE rating IS NULL) AS null_rating
FROM staging_motorcycle_sales;
-- 

DELETE FROM staging_motorcycle_sales
WHERE date IS NULL
   OR time IS NULL
   OR customer_age IS NULL
   OR customer_gender IS NULL
   OR country IS NULL
   OR state IS NULL
   OR product_category IS NULL
   OR sub_category IS NULL
   OR quantity IS NULL
   OR unit_cost IS NULL
   OR revenue IS NULL
   OR rating IS NULL;

update  staging_motorcycle_sales 
set customer_gender =
    case when customer_gender='F' then 'female'
    when customer_gender='M' then 'male'
	else null
	end;

	-- 

ALTER TABLE staging_motorcycle_sales
ALTER COLUMN time TYPE TIME
USING time::TIME;	
-- 
ALTER TABLE staging_motorcycle_sales
DROP COLUMN date;
-- 
ALTER TABLE staging_motorcycle_sales
RENAME COLUMN clean_date TO date;
   
select * from motorcycle_sales;

-- creating cleaned table

CREATE TABLE motorcycle_sales AS
SELECT
    ROW_NUMBER() OVER () AS sales_id,
	date,
    time,
    year,
    customer_age,
    customer_gender,
    country,
    state,
    product_category,
    sub_category,
    quantity,
    unit_cost,
    revenue,
    payment,
    rating,
    (quantity * unit_cost) AS total_cost,
    (revenue - (quantity * unit_cost)) AS gross_profit
FROM staging_motorcycle_sales
WHERE time IS NOT NULL;
-- 

select * from motorcycle_sales;

-- PROFIT_MARGIN

alter table motorcycle_sales
add column profit_margin numeric;

update motorcycle_sales
set profit_margin = round((gross_profit/revenue)*100,2)
where revenue >0;



--------------------------------------------
-- Derive Date Features (Time Intelligence)
--------------------------------------------

alter table motorcycle_sales
add column month varchar(20),
add column quarter varchar(10),
add column day_of_week varchar(20);

UPDATE motorcycle_sales
SET 
    month = TO_CHAR(date, 'Month'),
    quarter = 'Q' || TO_CHAR(date, 'Q'),
    day_of_week = TO_CHAR(date, 'Day');

-------------------------------------------------------------------------------
	                     -- Exploratory Data analysis
select * 
from motorcycle_sales limit 10;

----------------------------------
-- total rows
SELECT 
    COUNT(*) AS total_rows
FROM motorcycle_sales;

---------------------------------
-- total columns
SELECT 
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'motorcycle_sales';
----------------------------------------
-- Summary statistics (Min, Max, Avg, Median revenue & profit)

SELECT
    ROUND(AVG(CAST(revenue AS NUMERIC)),2) AS avg_revenue,
    MIN(CAST(revenue AS NUMERIC)) AS min_revenue,
    MAX(CAST(revenue AS NUMERIC)) AS max_revenue,
    ROUND(CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(revenue AS NUMERIC)) AS NUMERIC),2) AS median_revenue,
    ROUND(AVG(CAST(gross_profit AS NUMERIC)),2) AS avg_profit,
    MIN(CAST(gross_profit AS NUMERIC)) AS min_profit,
    MAX(CAST(gross_profit AS NUMERIC)) AS max_profit
FROM motorcycle_sales;
-------------------------------------------------------------------
-- gender distribution

SELECT 
    customer_gender,
    COUNT(*) AS total_transactions
FROM motorcycle_sales
GROUP BY customer_gender
ORDER BY total_transactions DESC;

-- payment method distribution
SELECT
    payment,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue),2) AS total_revenue
FROM motorcycle_sales
GROUP BY payment
ORDER BY total_orders DESC;


