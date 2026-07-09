-- platform summary
create view platform_summary as 
select 
Company,
Count(*) as Orders, 
sum(Order_Value) as Revenue,
Round(avg(Order_Value),2) as Avg_Order_Value,
Round(avg(Customer_Rating),2) as Avg_Customer_Rating,
Round(avg(Delivery_Time_Min),2) as Avg_Delivery_Time,
Round(avg(Distance_KM),2) as Avg_Distance_KM 
from orders group by Company;

-- city summary
create view city_summary as 
select 
City,
Count(*) as Orders, 
sum(Order_Value) as Revenue,
Round(avg(Order_Value),2) as Avg_Order_Value,
Round(avg(Customer_Rating),2) as Avg_Customer_Rating,
Round(avg(Delivery_Time_Min),2) as Avg_Delivery_Time,
Round(avg(Distance_KM),2) as Avg_Distance_KM 
from orders group by City;

-- customer purchase behaviour
create view customer_purchase_behavior as
with customer_seg as(
select CASE
when Customer_Age<18 THEN 'Below 18'
WHEN Customer_Age BETWEEN 18 AND 25 THEN '18-25'
WHEN Customer_Age BETWEEN 26 AND 35 THEN '26-35'
WHEN Customer_Age BETWEEN 36 AND 45 THEN '36-45'
ELSE 'Above 45' end as age_group, case  
when Order_Value<=500 then "Low Order Value"
when Order_Value<=1000 then "Mid Order Value"
when Order_Value>1000 then "High Order Value" end as range_of_orderVal from orders)
select age_group,range_of_orderVal,count(*) as Orders,round(count(*)*100/sum(count(*)) over(partition by age_group),2) as percentage
from customer_seg group by age_group,range_of_orderVal order by age_group,range_of_orderVal;

-- product summary
create view product_summary as 
select 
Product_Category,
Count(*) as Orders, 
sum(Order_Value) as Revenue,
Round(avg(Order_Value),2) as Avg_Order_Value,
Round(avg(Customer_Rating),2) as Avg_Customer_Rating
from orders group by Product_Category;

create view customer_segment as
select case
when Customer_Age<18 then 'Below 18'
when Customer_Age between 18 and 25 then '18-25'
when Customer_Age between 26 and 35 then '26-35'
when Customer_Age between 36 and 45 then '36-45'
else 'Above 45'
end as Age_group,
count(*) as Orders,
sum(Order_Value) as Revenue,
round(avg(Order_Value),2) as Avg_Order_Value,
round(avg(Customer_Rating),2) as Avg_Customer_Rating
from orders group by Age_group;

-- company market share
create view company_Market_share as
select 
Company,
sum(Order_Value) as Revenue,
round(sum(Order_Value)*100/sum(sum(Order_Value)) over(),2) as market_share
from orders group by Company;

-- company efficiency score
create view company_efficiency_score as
with scores as(
Select
Company,
SUM(Order_Value) Revenue,
AVG(Customer_Rating) Rating,
AVG(Delivery_Time_Min) Delivery,
rank() over(order by sum(Order_Value) desc) Revenue_Rank,
rank() over(order by avg(Customer_Rating) desc) Rating_Rank,
rank() over(order by avg(Delivery_Time_Min)) Delivery_Rank
from Orders
group by Company)
select *,
Revenue_Rank+Rating_Rank+Delivery_Rank as Total_Score
from scores;

-- product summary
create view pro_summary as
with product_summary as
(select Product_Category,count(*) as Total_Orders, sum(Order_Value) as Revenue,avg(Order_Value) as Avg_Order_Value from orders group by Product_Category),
company_rank as
(select Product_Category,Company,
round(Count(*) * 100/ sum(count(*)) over(Partition by Product_Category),2) as Company_Percentage, 
rank() over(partition by Product_Category order by count(*) desc) as rk
from orders group by Product_Category,Company),  
payment_rank as
(select Product_Category,count(*) as Total_orders,Payment_Method,
round(Count(*) * 100/ sum(count(*)) over(Partition by Product_Category),2) as payment_Percentage, 
rank() over(partition by Product_Category order by count(*) desc) as rk
from orders group by Product_Category,Payment_Method)
select 
p.Product_Category, p.Revenue,p.Avg_Order_Value,c.Company as Top_Company, c.Company_Percentage, pm.Payment_Method as Most_Used_Payment, pm.payment_Percentage 
from product_summary p left join company_rank c
on p.Product_Category = c.Product_Category and c.rk=1
left join  payment_rank pm 
on c.Product_Category = pm.Product_Category and pm.rk=1
order by Revenue desc;


-- which city performs best based on a combined score of revenue , customer ratings and delivery time taken
create view city_performance_analysis as 
with scores as
(select City,sum(Order_Value) as Revenue, avg(Customer_Rating) as Avg_Rating, avg(Delivery_Time_Min) as Avg_Delivery,
rank() over(order by sum(Order_Value) desc) as revenue_rk,
rank() over(order by avg(Customer_Rating) desc) as rating_rk,
rank() over(order by avg(Delivery_Time_Min) asc) as delivery_rk 
from orders group by City),
totals as
(select *,(revenue_rk+ rating_rk + delivery_rk) as Total_score from scores)
select *,
case when Total_score<=10 then "Excellent" 
when Total_score<=20 then "Good"
when Total_score>20 then "Needs Improvement" end as Performance_status
from totals order by Total_score;

