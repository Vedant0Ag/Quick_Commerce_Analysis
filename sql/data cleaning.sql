/* -------------------Data cleaning-----------------------*/

/* discount applied- yes or no*/
UPDATE orders 
SET Discount_Applied = CASE
WHEN Discount_Applied='1' THEN 'Yes'
WHEN Discount_Applied='0' THEN 'No'
END;

/*updating customer ratings */
UPDATE orders
SET Customer_Rating=NULL
WHERE Customer_Rating=0;

/*updating Delivery partner ratings*/
UPDATE orders
SET Delivery_Partner_Rating=NULL
WHERE Delivery_Partner_Rating=0;

/*updating product category*/
UPDATE orders
SET Product_Category='Unknown'
WHERE Product_Category IS NULL;

SELECT *
FROM orders
WHERE City IS NULL
   OR Order_Value IS NULL
   OR Distance_KM IS NULL
   OR Delivery_Time_Min IS NULL;

/* categorizing unknown cities*/
UPDATE orders 
SET City='Unknown'
WHERE City is null;

/*NULLs by column*/
SELECT
    SUM(Items_Count IS NULL) AS Items_Nulls,
    SUM(Customer_Rating IS NULL) AS CustomerRating_Nulls,
    SUM(Delivery_Partner_Rating IS NULL) AS PartnerRating_Nulls
FROM orders;