                                       -- Phase-3 [Customer Behavior & Segmentation]


-- 11.Do older customers (30+) spend more on safety gear compared to younger buyers?     

select 
       case when customer_age < 30 then 'Younger (<30)'
	   else 'Older (<40+)'
	   end as age_group,
	   sum(revenue) as total_safety_gear_spending,
	   round(avg(revenue),2) as avg_ord_value
from motorcycle_sales
where sub_category in ('Helmets','Gloves','Vests','caps')
group by age_group
order by total_safety_gear_spending desc;

-- 12.Which customer segment (Age × Gender × Location) generates **highest revenue per order**? 

select 
       case 
	       when customer_age between 18 and 25 then 'Younger(18-25)'
	       when customer_age between 26 and 39 then 'Adult(26-39)'
	       when customer_age between 40 and 55 then 'Mature(40-55)'
		   else 'Older(55+)'
		   end as age_group,
		   customer_gender as gender,
		   state,
		   round(avg(revenue),2) as avg_revenue_per_order,
		   count(*) as total_orders,
		   sum(revenue) as sales
from motorcycle_sales
group by age_group,gender,state
order by avg_revenue_per_order desc , sales desc;

-- 13.Which group gives **higher product ratings**?

select 
       case 
	       when customer_age between 18 and 25 then 'Younger(18-25)'
	       when customer_age between 26 and 39 then 'Adult(26-39)'
	       when customer_age between 40 and 55 then 'Mature(40-55)'
		   else 'Older(55+)'
		   end as age_group,
		   round(avg(rating),2) as avg_rating
from motorcycle_sales
group by age_group
order by avg_rating desc

                           -- End OF THIS PROJECT