-- operational kpi

create view operations_dashboard_kpis as
with company_summary as (
    select
        Company,
        sum(Order_Value) as revenue,
        round(avg(Customer_Rating),2) as avg_rating,
        round(avg(Delivery_Time_Min),2) as avg_delivery_time,
        rank() over(order by sum(Order_Value) desc) as revenue_rank,
        rank() over(order by avg(Customer_Rating) desc) as rating_rank,
        rank() over(order by avg(Delivery_Time_Min)) as delivery_rank
    from orders
    group by Company
),
company_score as (
    select
        Company, revenue, avg_rating, avg_delivery_time, revenue_rank, rating_rank, delivery_rank, 
        (revenue_rank + rating_rank + delivery_rank) as performance_score
    from company_summary
),
city_summary as (
    select
        City,
        sum(Order_Value) as revenue,
        round(avg(Customer_Rating),2) as avg_rating,
        round(avg(Delivery_Time_Min),2) as avg_delivery_time,
        rank() over(order by sum(Order_Value) desc) as revenue_rank,
        rank() over(order by avg(Customer_Rating) desc) as rating_rank,
        rank() over(order by avg(Delivery_Time_Min)) as delivery_rank
    from orders
    group by City
),
city_score as (
    select
        City, revenue, avg_rating, avg_delivery_time,
        (revenue_rank + rating_rank + delivery_rank) as performance_score
    from city_summary
),
market_share as (
    select
        Company,
        round(sum(Order_Value)*100/
        (select sum(Order_Value) from orders),2) as market_share
    from orders
    group by Company
)
select
/* Best Performing Company */
(
    select Company
    from company_score
    order by performance_score
    limit 1
) as best_company,
(
    select performance_score
    from company_score
    order by performance_score
    limit 1
) as company_score,
/* Best Performing City */
(
    select City
    from city_score
    order by performance_score
    limit 1
) as best_city,
(
    select performance_score
    from city_score
    order by performance_score
    limit 1
) as city_score,

/* Fastest Delivery Company */
(
    select Company
    from company_summary
    order by avg_delivery_time
    limit 1
) as fastest_delivery_company,
(
    select avg_delivery_time
    from company_summary
    order by avg_delivery_time
    limit 1
) as fastest_delivery_time,

/* Highest Market Share */
(
    select Company
    from market_share
    order by market_share desc
    limit 1
) as market_leader,
(
    select market_share
    from market_share
    order by market_share desc
    limit 1
) as market_share_percentage,

/* Highest Rated Company */
(
    select Company
    from company_summary
    order by avg_rating desc
    limit 1
) as highest_rated_company,
(
    select avg_rating
    from company_summary
    order by avg_rating desc
    limit 1
) as highest_company_rating,

/* Highest Revenue Company */
(
    select Company
    from company_summary
    order by revenue desc
    limit 1
) as highest_revenue_company,
(
    select revenue
    from company_summary
    order by revenue desc
    limit 1
) as highest_company_revenue;