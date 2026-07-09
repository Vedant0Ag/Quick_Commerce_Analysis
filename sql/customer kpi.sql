-- kpi views

-- customer behaviour 
create view customer_kpis as
with age_summary as (
    select
        case
            when Customer_Age < 18 then 'Below 18'
            when Customer_Age between 18 and 25 then '18-25'
            when Customer_Age between 26 and 35 then '26-35'
            when Customer_Age between 36 and 45 then '36-45'
            else 'Above 45'
        end as age_group,
        sum(Order_Value) as revenue,
        round(avg(Customer_Rating),2) as avg_rating,
        count(*) as total_orders,
        sum(case when Order_Value > 1000 then 1 else 0 end) as premium_orders
    from orders
    group by age_group
),

payment_summary as (
    select
        Payment_Method,
        count(*) as total_orders,
        round(count(*) * 100 / (select count(*) from orders),2) as usage_percentage
    from orders
    group by Payment_Method
),

category_summary as (
    select
        Product_Category,
        round(avg(Customer_Rating),2) as avg_rating
    from orders
    group by Product_Category
),

discount_summary as (
    select
        round(
            sum(case when Discount_Applied = 'Yes' then 1 else 0 end)
            *100/count(*),2
        ) as discount_usage_percentage
    from orders
)

select

/* Highest Spending Age Group */

(
    select age_group
    from age_summary
    order by revenue desc
    limit 1
) as highest_spending_age_group,

/* Highest Rated Age Group */
(
    select age_group
    from age_summary
    order by avg_rating desc
    limit 1
) as highest_rated_age_group,
(
    select avg_rating
    from age_summary
    order by avg_rating desc
    limit 1
) as highest_age_rating,

/* Most Preferred Payment Method */
(
    select Payment_Method
    from payment_summary
    order by total_orders desc
    limit 1
) as preferred_payment_method,
(
    select usage_percentage
    from payment_summary
    order by total_orders desc
    limit 1
) as payment_usage_percentage,

/* Discount Usage */
(
    select discount_usage_percentage
    from discount_summary
) as discount_usage_percentage,

/* Highest Rated Product Category */
(
    select Product_Category
    from category_summary
    order by avg_rating desc
    limit 1
) as highest_rated_category,
(
    select avg_rating
    from category_summary
    order by avg_rating desc
    limit 1
) as highest_category_rating,

/* Premium Customer Segment */

(
    select age_group
    from age_summary
    order by premium_orders / total_orders desc
    limit 1
) as premium_customer_segment,
(
    select round((premium_orders * 100.0) / total_orders,2)
    from age_summary
    order by premium_orders / total_orders desc
    limit 1
) as premium_customer_percentage;