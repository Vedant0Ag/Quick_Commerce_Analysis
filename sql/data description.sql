use quickcommercedb;

/*Data description*/
select * from orders;
select count(*) from orders;
desc orders;
select Order_ID ,count(*) from orders group by Order_ID having count(*)>1; /*No duplicates*/
SELECT Discount_Applied,COUNT(*) FROM orders GROUP BY Discount_Applied; /* discount applied?*/
select Payment_Method,count(*) from orders group by Payment_Method;
select count(*) from orders where Payment_Method=null; /* 5 types of payments*/
SELECT Product_Category,COUNT(*) FROM orders GROUP BY Product_Category; /*7 types of products*/
SELECT COUNT(*) FROM orders WHERE Product_Category=NULL;
SELECT Customer_Rating, COUNT(*) FROM orders GROUP BY Customer_Rating ORDER BY Customer_Rating; /* customer ratings- (1-5) and no ratings) */
SELECT Delivery_Partner_Rating,COUNT(*) FROM orders GROUP BY Delivery_Partner_Rating ORDER BY Delivery_Partner_Rating; /* Del Partner Rating (2.5-5) or no rating)*/
select Company,count(*) from orders group by Company; /*instamart,flipkart,dunzo, jiomart, blinkit, amazon now, big basket, zepto */