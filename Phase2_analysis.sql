                                             ----------------------------------
                                                        -- Phase - 2
                                             ----------------------------------
-- 6.Which products generate **high revenue but low profit margin** (loss leaders)?   

WITH revenue_stats AS (
    SELECT 
        ROUND(AVG(revenue),2) AS avg_revenue
    FROM motorcycle_sales
)
SELECT 
    sub_category,
    SUM(revenue) AS total_revenue,
    SUM(gross_profit) AS total_profit,
    ROUND(AVG(profit_margin),2) AS avg_profit_margin
FROM motorcycle_sales, revenue_stats
GROUP BY sub_category, avg_revenue
HAVING 
    SUM(revenue) > avg_revenue      -- High revenue (business benchmark)
    AND AVG(profit_margin) < 20     -- Low profit margin 
ORDER BY avg_profit_margin ASC, total_revenue DESC;


-- 7.Which warehouses have the **highest operational inefficiency** (low profit despite high sales)?	        

WITH warehouse_stats AS (
    SELECT
        state,
        SUM(revenue) AS total_revenue,
        SUM(gross_profit) AS total_profit,
        ROUND((SUM(gross_profit) / NULLIF(SUM(revenue), 0)) * 100, 2) AS profit_margin_pct
    FROM motorcycle_sales
    GROUP BY state
),

thresholds AS (
    SELECT
        ROUND(AVG(total_revenue), 2) AS avg_revenue,
        ROUND(AVG(profit_margin_pct), 2) AS avg_profit_margin
    FROM warehouse_stats
)

SELECT 
    w.state,
    w.total_revenue,
    w.total_profit,
    w.profit_margin_pct,
    CASE
        WHEN w.total_revenue > t.avg_revenue
         AND w.profit_margin_pct < t.avg_profit_margin
        THEN 'Operationally Inefficient'
        ELSE 'Efficient/Normal'
    END AS efficiency_status
FROM warehouse_stats w
JOIN thresholds t ON TRUE
ORDER BY w.profit_margin_pct ASC, w.total_revenue DESC;

-- 8.Which payment methods are **associated with lower returns and higher ratings**? 
select payment,
       round(sum(revenue),2) as sales,
	   round(avg(rating),2) as avg_rating
from motorcycle_sales
group by 1
order by 3 desc

-- 9.What is the **discount vs revenue relationship**? Is discounting effective or harmful? 
                                
								------ correlation -------
                                --------------------------
SELECT 
      CORR(profit_margin, revenue) AS margin_revenue_corr
FROM motorcycle_sales;
-------------------------------------------------------------------------------------------------
        ---------------------Find Loss Leader Products (high revenue, low profit margin)-----
		-----------------------------------------------------------------------------------------
select sub_category,
       round(sum(revenue),2) as sales,
	   round(sum(gross_profit),2) as total_pofit,
	   round(avg(profit_margin),2) as avg_profit_margin
from motorcycle_sales
group by 1
having avg(profit_margin) < 15
and sum(revenue) > (select avg(revenue) from motorcycle_sales)
order by avg_profit_margin asc

-------------------------------------------------------------------------------------------------
        ---------------------Does low profit margin hurt or improve customer satisfaction?-----
		-----------------------------------------------------------------------------------------
SELECT 
    sub_category,
    ROUND(AVG(profit_margin),2) AS avg_profit_margin,
    ROUND(AVG(rating),2) AS avg_rating
FROM motorcycle_sales
GROUP BY sub_category
ORDER BY avg_rating DESC;

-- 10. What is the **ROI per category**, after considering cost, returns, and discount impact? 

select product_category,
        sum(revenue) as total_revenue,
       sum(gross_profit) as total_profit,
	   sum(total_cost) as total_cost,
      round((sum(gross_profit) / nullif(sum(total_cost),0)) *100,2) as roi_pct
from motorcycle_sales
group by 1
order by roi_pct desc;
----------------------------------------------------------------------------------------------------
