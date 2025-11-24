select * from motorcycle_sales;
-----------------
-- Solutions----- -------------
                  -- Phase - 1
----------------- -- ----------

-- 1.Which product categories show **consistent revenue growth** over time (YoY / MoM)?
with cte as 
(select  month,
        sum(revenue) as total_revenue
from motorcycle_sales
group by month)

select month,
       total_revenue,
	   lag(total_revenue) over(order by month) as prev_month_rev,
	    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0)) * 100, 2
    ) AS revenue_growth_pct
from cte	
-----------------------------------------
WITH cte AS (
    SELECT 
        year,
        product_category,
        SUM(revenue) AS total_revenue
    FROM motorcycle_sales
    GROUP BY product_category, year
)
SELECT 
    product_category,
    year,
    total_revenue,
    LAG(total_revenue) OVER(PARTITION BY product_category ORDER BY year) AS prev_year_value,
    ROUND(
        (
            (total_revenue - LAG(total_revenue) OVER(PARTITION BY product_category ORDER BY year))
            / NULLIF(LAG(total_revenue) OVER(PARTITION BY product_category ORDER BY year), 0)
        ) * 100
    , 2) AS yoy_growth_pct
FROM cte;

-- 2.Which states are **emerging markets** (high growth % but low total sales)? 
WITH state_monthly AS (
    SELECT 
        state,
        month,
        SUM(revenue) AS revenue
    FROM motorcycle_sales
    GROUP BY state, month
),

state_growth AS (
    SELECT 
        state,
        month,
        revenue,
        LAG(revenue) OVER (
            PARTITION BY state 
            ORDER BY TO_DATE(month, 'Month')
        ) AS prev_month_revenue
    FROM state_monthly
),

state_stat AS (
    SELECT 
        state,
        AVG(revenue) AS avg_revenue,
        AVG(
            ROUND(
                ((revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0)) * 100, 2
            )
        ) AS avg_mom_growth_pct
    FROM state_growth
    WHERE prev_month_revenue IS NOT NULL
    GROUP BY state
)

SELECT
    state,
    ROUND(avg_revenue, 2) AS avg_monthly_revenue,
    ROUND(avg_mom_growth_pct, 2) AS avg_mom_growth_pct
FROM state_stat
WHERE avg_revenue < 5000          -- Low revenue
  AND avg_mom_growth_pct > 10     -- High growth %
ORDER BY avg_mom_growth_pct DESC;

-- 3.Which product subcategories show **declining demand**, and in which regions? 
with cte as 
(select state,
       sub_category,
	   month,
	   sum(revenue) as revenue_monthly
from motorcycle_sales
GROUP BY state, sub_category, month),
cte2 as 
(select state,
       sub_category,
	   month,
	   revenue_monthly,
	   lag(revenue_monthly) over(partition by state, sub_category order by month) as prv_month_revenue
from cte)
select state,
       sub_category,
	   month,
	   revenue_monthly,
	   prv_month_revenue,
	   round(
	   (revenue_monthly - prv_month_revenue)
	   /nullif(prv_month_revenue,0)*100,2) as growth_pct,
	   case when revenue_monthly < prv_month_revenue then 'Decline'
	   else 'growing'
	    END AS demand_trend
from cte2
ORDER BY demand_trend DESC, state, sub_category, month;

-- 4.Which **seasonal trends** impact sales (Spring riding season? Holiday spikes)?     

                       -- Month-wise Revenue Trend (Seasonal Pattern)

select month,
       sum(revenue) as sales,
	   round(avg(revenue),2) as avg_ord_value
from motorcycle_sales
group by month
order by TO_DATE(month, 'Month');

----------------------------------------------------
                        -- Quarter-wise Revenue Trends (Seasonal Business View)

select quarter,
       sum(revenue) as sales,
	   round(avg(revenue),2) as avg_ord_value
from motorcycle_sales
group by quarter
order by quarter;
-------------------------------------------------------

                         -- Month + Category Seasonal Demand

select month,
       product_category,
       sum(revenue) as sales,
	   round(avg(revenue),2) as avg_ord_value
from motorcycle_sales
group by month,product_category
order by TO_DATE(month, 'Month'),sales desc;


-- 5.What is the **time-based revenue contribution** (Weekend vs Weekday, peak hours)?

select  
        case when trim(day_of_week) in ('Saturday', 'Sunday') then 'Weekend'
		else 'Weekday'
		end as day_type,
		sum(revenue) as sales,
		round(avg(revenue),2) as avg_ord_value
from motorcycle_sales
group by day_type;

------------------------------------
SELECT
    EXTRACT(HOUR FROM time) AS hour_of_day,
    COUNT(*) AS total_orders,
    SUM(revenue) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_order_value
FROM motorcycle_sales
GROUP BY hour_of_day
ORDER BY total_revenue DESC;
