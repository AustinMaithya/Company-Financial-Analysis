select * from financials;
show columns from financials;
-- Renaming columns by adding hyphens for easy access during querying 
alter  table financials
rename column `Discount Band` to `Discount_Band`,
rename column `Units_Sold` to `Units_Sold`,
rename column `Manufacturing Price` to `Manufacturing_Price`,
rename column `Sale Price` to `Sales_Price`,
rename column `Gross Sales` to `Gross_Sales`,
rename column `Month Name` to `Month_Name`;

-- Dropping Column Month Number as it is not necessary since we have the month name 
alter  table financials
drop column `Month Number`;

select * from financials;

-- Converting Date from text format to date format 

select Date,  str_to_date(Date , '%d/%m/%Y') as New_Date
from financials;

-- Adding the new date column and dropping the existing one that was in text format 
alter table financials
add column New_Date Date;

update financials
set New_Date  = str_to_date(Date , '%d/%m/%Y');

select * from financials;


alter table financials
drop column Date;

-- BUSINESS QUESTIONS 
-- General Financial Performance
-- What is the total revenue for the year/month/quarter?
select * from financials;

Select sum(Sales) as Total_Revenue,
		year(New_Date) as Year,
        monthname(New_Date) as Month,
        quarter(New_Date) as Quarter
from financials
group by year(New_Date) , monthname(New_Date),quarter(New_Date)
order by quarter(New_Date),sum(Sales),monthname(New_Date) desc;

-- How has net profit evolved over time (trend)?
select * from financials;

select sum(Profit) as Total_Profit,
		monthname(New_Date) as Month,
		year(New_Date) as Year
		
from financials
group by  monthname(New_Date),year(New_Date)
order by  sum(Profit)  desc;

-- What is the profit margin (%) and how does it vary by product or department

select * from financials;

Select (sum(Profit) / sum(Sales)) * 100 as profit_margin_percentage, 
		Product,
		Country
from financials
group by Product,Country
order by (sum(Profit) / sum(Sales)) * 100 , Country ;
-- Which months or quarters were the most/least profitable?
select sum(Profit) as Total_Profit,		
		monthname(New_Date) as Month,
        quarter(New_Date) as Yearly_Quarter
        
from financials 
group by monthname(New_Date),quarter(New_Date)
order by  sum(Profit) desc ;
        
        
-- What is the YoY or MoM revenue growth rate?
with yearly as 
( select year(New_Date) as year,
		sum(Sales) as Revenue
from financials 
group by year(New_Date) 
		
)
select year,
		Revenue,
        lag(Revenue) over(order by year) as previous_year_revenue,
        round((revenue - lag(Revenue) over(order by year)) / lag(Revenue) over(order by year) * 100,2) as yoy_growth_rate
from yearly;


with monthly as 
( select month(New_Date) as month_number,
		monthname(New_Date) as month_name,
		sum(Sales) as Revenue
from financials 
group by monthname(New_Date) , month(New_Date)
		
)
select month_name,
		month_number,
		Revenue,
        lag(Revenue) over(order by month_name) as previous_month_revenue,
        round((revenue - lag(Revenue) over(order by month_name)) / lag(Revenue) over(order by month_name) * 100,2) as mom_growth_rate
from monthly
group by month_number,month_name
order by  month_number asc;
        

-- Revenue & Sales Analysis
-- What are the top 10 products or services by revenue?
select * from financials;

select Product,
		sum(Sales) as Revenue
from financials
group by Product
order by Revenue desc
limit 10;

-- Which customers or segments generate the most revenue?
select * from financials;

select Segment,
		sum(Sales) as Revenue
from financials
group by Segment
order by Revenue desc
limit 10;


-- What is the average sales value per transaction?

select * from financials;

select sum(Sales) /  count(Segment) as Avg_Sales_Per_Transaction
from financials;



-- What is the revenue breakdown by region or sales channel?
select * from financials ;

select Country, sum(Sales) as Revenue
from financials 
group by Country
order by Revenue desc;






-- Is there a correlation between expenses and revenue growth?

select * from financials;
select 
    (
        COUNT(*) * SUM(COGS * Sales) - SUM(COGS) * SUM(Sales)
    ) /
    SQRT(
        (COUNT(*) * SUM(COGS * COGS) - POW(SUM(COGS), 2)) *
        (COUNT(*) * SUM(Sales * Sales) - POW(SUM(Sales), 2))
    ) as correlation
from financials;




-- Product/Service Profitability
-- What is the gross profit per product/service?
select Product , sum(Profit) as Total_Profit
from financials
group by Product 
order by Total_Profit desc;

-- Which products have the highest/lowest profit margins?

select Product ,
	 (sum(Profit) / sum(Sales))* 100 as profit_margin
from financials
group by Product
order by profit_margin desc;
 






