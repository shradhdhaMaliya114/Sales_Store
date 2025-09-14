﻿CREATE TABLE sales_store (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);


select * from sales_store
SET DATEFORMAT dmy
bulk insert sales_store
from 'S:\sem 5\study\SQL\sales_store.csv'
with(
	FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
		);


select * from sales_store;

select * into sales from sales_store;

select * from sales;

--revome duplicate

select transaction_id from sales
group by transaction_id
having count(transaction_id)>1;

with CTE as (
	select *,
	ROW_NUMBER() over(partition by transaction_id order by transaction_id) as Row_num
	from sales
	)

     --delete CTE  where Row_num = 2;
select * from CTE
WHERE transaction_id IN ('TXN240646','TXN342128','TXN855235','TXN981773');

--renaming column
exec sp_rename 'sales.quantiy',"Quantity","column";
exec sp_rename 'sales.prce',"Price","column";
exec sp_rename 'sales."Quantity"',"quantity","column";
exec sp_rename 'sales.Price',"price","column";


--DataType

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales'



--to check null count

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

--treating null values 

SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
or
payment_mode is null
or
purchase_date is null
or 
status is null
or 
price is null

DELETE FROM sales 
WHERE  transaction_id IS NULL


SELECT * FROM sales 
Where Customer_name='Ehsaan Ram'

UPDATE sales
SET customer_id='CUST9494'
WHERE transaction_id='TXN977900'

SELECT * FROM sales 
Where Customer_name='Damini Raju'

UPDATE sales
SET customer_id='CUST1401'
WHERE transaction_id='TXN985663'

SELECT * FROM sales 
Where Customer_id='CUST1003'

UPDATE sales
SET customer_name='Mahika Saini',customer_age=35,gender='Male'
WHERE transaction_id='TXN432798'


SELECT * FROM sales

--Data Cleaning

SELECT DISTINCT gender
FROM sales

UPDATE sales
SET gender='M'
WHERE gender='Male'

UPDATE sales
SET gender='F'
WHERE gender='Female'

SELECT DISTINCT payment_mode
FROM sales

UPDATE sales
SET payment_mode='Credit Card'
WHERE payment_mode='CC'

-----------------------------------------------------------------------------------------------------------
--Data Analysis--

--1. What are the top 5 most selling products by quantity?

SELECT * FROM sales
SELECT DISTINCT status
from sales

SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC

-----------------------------------------------------------------------------------------------------------

--2. Which products are most frequently cancelled?

SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC
-----------------------------------------------------------------------------------------------------------


--3. What time of the day has the highest number of purchases?

select * from sales
	
	SELECT 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) AS total_orders
	FROM sales
	GROUP BY 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
ORDER BY total_orders DESC

-----------------------------------------------------------------------------------------------------------

--4. Who are the top 5 highest spending customers?

SELECT * FROM sales

SELECT TOP 5 customer_name,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_spend
FROM sales 
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

-----------------------------------------------------------------------------------------------------------

-- 5 Which product categories generate the highest revenue?

SELECT * FROM sales

SELECT 
	product_category,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS Revenue
FROM sales 
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC

-----------------------------------------------------------------------------------------------------------

--6. What is the return/cancellation rate per product category?

SELECT * FROM sales

SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS cancelled_percent
FROM sales 
GROUP BY product_category
ORDER BY cancelled_percent DESC

--Return
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS returned_percent
FROM sales 
GROUP BY product_category
ORDER BY returned_percent DESC


-----------------------------------------------------------------------------------------------------------
--7. What is the most preferred payment mode?

SELECT * FROM sales

SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales 
GROUP BY payment_mode
ORDER BY total_count desc
-----------------------------------------------------------------------------------------------------------
--8. How does age group affect purchasing behavior?

SELECT * FROM sales
--SELECT MIN(customer_age) ,MAX(customer_age)
--from sales

SELECT 
	CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales 
GROUP BY CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY SUM(price*quantity) DESC

-----------------------------------------------------------------------------------------------------------
--9. What’s the monthly sales trend?

SELECT * FROM sales

SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS Month_Year,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
	SUM(quantity) AS total_quantity
FROM sales 
GROUP BY FORMAT(purchase_date,'yyyy-MM') 

-----------------------------------------------------------------------------------------------------------

--🔎 10. Are certain genders buying more specific product categories?

SELECT * from sales


SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender
