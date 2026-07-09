/* ---------------EDA (Exploratory Data Analysis------------------  */

-- KPIs
SELECT
COUNT(*) Orders,
SUM(Order_Value),
AVG(Order_Value),
AVG(Customer_Rating),
AVG(Delivery_Time_Min),
AVG(Distance_KM)
FROM orders;


-- Which platform generates the highest revenue, handles the most orders, and delivers the highest average order value?
select Company, count(*) as Total_orders, sum(Order_Value) as Revenue, avg(Order_Value) as Average_Order_Value from orders group by Company order by Revenue desc; 

-- what payment method contributes the most to the revenue and what does cutomer payment behaviour reveal?
select Payment_Method, count(*) as Total_orders, sum(Order_Value) as Revenue from orders group by Payment_Method order by Revenue;

-- does offering discounts increase the revenue, average order value and customer satisfaction?
select Discount_Applied, count(*) as Total_orders, sum(Order_Value) as Revenue ,Avg(Customer_Rating) as Avg_Customer_Rating, Avg(Order_Value) as Avg_Order_Value
 from orders group by Discount_Applied order by Revenue desc;
 
 -- which product category generates the highest revenue, and has maximum customer satisfaction
SELECT Product_Category, COUNT(*) AS Total_Orders, SUM(Order_Value) AS Revenue, ROUND(AVG(Order_Value),2) AS Avg_Order_Value, ROUND(AVG(Customer_Rating),2) AS Avg_Rating
FROM orders GROUP BY Product_Category order by Revenue desc;

-- which city generates the highest revenue, and their performance based on customer ratings and delivery time
select City, count(*) as Total_orders, sum(Order_Value) as Revenue ,Avg(Customer_Rating) as Avg_Customer_Rating, avg(Delivery_Time_Min) as Avg_Delivery_Time_min 
from orders group by City order by Revenue desc;

-- Which customer age groups contribute the most revenue and how does customer satisfaction vary across age segments? 
SELECT CASE
when Customer_Age<18 THEN 'Below 18'
WHEN Customer_Age BETWEEN 18 AND 25 THEN '18-25'
WHEN Customer_Age BETWEEN 26 AND 35 THEN '26-35'
WHEN Customer_Age BETWEEN 36 AND 45 THEN '36-45'
ELSE 'Above 45'
END Age_Group, SUM(Order_Value) as Revenue, AVG(Customer_Rating) as Avg_Customer_Rating FROM orders GROUP BY Age_Group;

-- Which platform dominates each product category and their percentage market share hold?
with company_rank as
(select Product_Category,count(*) as Total_orders,Company,
round(Count(*) * 100/ sum(count(*)) over(Partition by Product_Category),2) as Company_Percentage, 
rank() over(partition by Product_Category order by count(*) desc) as rk
from orders group by Product_Category,Company)
select * from company_rank where rk=1;

-- Which company is preferred for each payment method and how dominant is its share?
with company_rank as 
(select Payment_Method, count(*) as t_orders,Company,
round(count(*) * 100/sum(count(*)) over(partition by Payment_Method),2) as company_percentage,
rank() over(partition by Payment_Method order by count(*) desc) as rk
from orders group by Payment_Method,Company)
select * from company_rank where rk=1;

-- For each product category, which company leads the market, which payment method is preferred, and what insights can be derived?
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


-- Which cities generate high revenue despite having lower customer ratings indicating to potential operational issues?
select City,sum(Order_Value) as Revenue,AVG(Customer_Rating),MIN(Customer_Rating),MAX(Customer_Rating),STDDEV(Customer_Rating),avg(Delivery_Time_Min) as Avg_Delivery_Time, avg(Distance_KM) as avg_Distance
from orders group by City; 

-- Which company dominates each city's market, and what percentage of total city revenue does it control?
with company_rank as 
(select City, Company, sum(Order_Value) as Revenue, count(*) as Orders,
round(sum(Order_Value)*100/sum(sum(Order_Value)) over(partition by City),2) as Market_Share,
rank() over (partition by City order by sum(Order_Value) desc) as rk 
from orders group by City,Company)
select * from company_rank where rk=1 order by Revenue desc;

-- which city performs best based on a combined score of revenue , customer ratings and delivery time taken
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

-- what is the range of ordder values ordered by the customers
select max(Order_Value), min(Order_Value),stddev(Order_Value),avg(Order_Value) from orders;

-- which customer age group tend to buy more premium(high order value) products and low budget products?
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

