use quickcommercedb;
CREATE TABLE orders (
    Order_ID INT PRIMARY KEY,
    Company VARCHAR(50),
    City VARCHAR(50),
    Customer_Age INT,
    Order_Value DECIMAL(10,2),
    Delivery_Time_Min INT,
    Distance_KM DECIMAL(5,2),
    Items_Count INT,
    Product_Category VARCHAR(50),
    Payment_Method VARCHAR(30),
    Customer_Rating DECIMAL(2,1),
    Discount_Applied VARCHAR(5),
    Delivery_Partner_Rating DECIMAL(2,1)
);
desc orders;

LOAD DATA LOCAL INFILE 'C:\\Users\\Vedant Agarwal\\Desktop\\quick_commerce_data_raw.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
@Order_ID,
@Company,
@City,
@Customer_Age,
@Order_Value,
@Delivery_Time_Min,
@Distance_KM,
@Items_Count,
@Product_Category,
@Payment_Method,
@Customer_Rating,
@Discount_Applied,
@Delivery_Partner_Rating
)
SET
Order_ID = NULLIF(@Order_ID,''),
Company = NULLIF(@Company,''),
City = NULLIF(@City,''),
Customer_Age = NULLIF(@Customer_Age,''),
Order_Value = NULLIF(@Order_Value,''),
Delivery_Time_Min = NULLIF(@Delivery_Time_Min,''),
Distance_KM = NULLIF(@Distance_KM,''),
Items_Count = NULLIF(@Items_Count,''),
Product_Category = NULLIF(@Product_Category,''),
Payment_Method = NULLIF(@Payment_Method,''),
Customer_Rating = NULLIF(@Customer_Rating,''),
Discount_Applied = NULLIF(@Discount_Applied,''),
Delivery_Partner_Rating = NULLIF(@Delivery_Partner_Rating,'');

select * from orders;
