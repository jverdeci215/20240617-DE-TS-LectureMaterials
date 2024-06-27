/*

Built-in Functions

Categories:
- Aggregation Functions
- Analytics Functions
- Ranking Functions
- Scalar Functions

*/

/*

Aggretion Functions
- AVG
- COUNT
- STDEV/VAR
- APPROX_COUNT_DISTINCT
	- Faster than a full distinct count

*/

SELECT COUNT(DISTINCT Quantity) FROM [Production].[ProductInventory];
SELECT APPROX_COUNT_DISTINCT(Quantity) FROM [Production].[ProductInventory];


/*

Scalar Functions: One input -> One Output

Conversion Functions
- CAST/CONVERT
	- CAST(expression AS datatype); CAST(Revenue AS DECIMAL(18,2))
	- CONVERT(datatype, expression); CONVERT(DECIMAL(18,2), Revenue)
- TRY_CAST/TRY_CONVERT - Returns NULL if unsuccesful

*/

SELECT CAST(10.646 AS INT) trunc1,
		CAST(-10.646 AS INT) trunc2,
		CAST(10.646 AS NUMERIC(5,1)) round1 ,
		CAST(-10.646 AS NUMERIC) round2;

USE retail_db;

SELECT * FROM order_items
WHERE CAST(order_item_subtotal AS INT) LIKE '11%'
ORDER BY order_item_subtotal desc;

-- TRY_CAST
SELECT TRY_CAST('12/31/2024' AS DATETIME2) AS [Date];

SET DATEFORMAT mdy;

/*

Date and Time Functions

*/

SELECT 
	SYSDATETIME(), -- datetime2(7)
	SYSDATETIMEOFFSET(), -- datetimeoffset(7)
	SYSUTCDATETIME(), -- datetime2 converted to UTC time
	CURRENT_TIMESTAMP, -- datetime
	GETDATE(), -- Alias for current_timestamp
	GETUTCDATE() -- datetime converted to UTC

-- Very important to read documentation on Dates/Times
-- If you/someone mess up the datetime formats.
-- ETL Pipeline: SQL (local time) -> DATA LAKE (Datetime with offset) -> Data Warehouse (UTC Time)

-- Construct dates from their individual parts
-- DATEFROMPARTS/TIMEFROMPARTS
SELECT DATEFROMPARTS(2024, 06, 27);
SELECT TIMEFROMPARTS(12, 31, 45, 125234, 7);

-- FORMAT()
SELECT TOP 10 FORMAT(order_date, 'yyyy-MM       /dd') FROM orders;

-- Comparing Dates
-- DATEDIFF()
SELECT DATEDIFF(day, max(order_date), min(order_date)) FROM orders;

-- Add to a date
SELECT TOP 3
	order_date,
	DATEADD(day, 3, order_date) plus_3_days,
	DATEADD(month, 3, order_date) plus_3_months,
	DATEADD(year, 3, order_date) plus_3_years
FROM orders;

-- Edge Cases: Leap Years, Last Day of Month, February

-- EOMONTH
SELECT TOP 3 order_date, EOMONTH(order_date) FROM orders;

-- Convert our date to the datetime with offset
SELECT GETDATE(), TODATETIMEOFFSET(GETDATE(), '-05:00');

/*

Mathematical functions

- ABS(n)
- CIELING(n)
- FLOOR(n)
- PI()
- RAND(seed) - between 0 and 1
- SQRT(float)
- SQUARE(float)
Trig Functions

*/

SELECT RAND();

/*

String Functions

A quick on Collation
	- If I input a string - result will use the input strings collation
	- If I generate a string - result will use the default db collation

*/

-- LEN()
SELECT LEN('Hello World!') AS result;

-- LOWER(), UPPER()

-- Extract data
-- LEFT(str, n), RIGHT(str, n)
SELECT
	LEFT('123 456 789', 3) left_str,
	RIGHT('123 456 789', 3) right_str

-- SUBSTRING()
SELECT SUBSTRING('123 456 789', 5, 3) result;

-- STRING_SPLIT(str, split_char, enable_ordinal)
SELECT * FROM STRING_SPLIT('Lorem ipsum dolor sit amet.', ' ', 1);

-- Concatenate strings with CONCAT()
SELECT CONCAT('Hello', ' ', 'World');

-- CONCAT_WS(ws_char, str1, ...strn)
SELECT CONCAT_WS(' ', 'Hello', 'how', 'are', 'you', 'today?');

-- Compare similarity of strings
SELECT DIFFERENCE('Computer', 'Computation');
SELECT DIFFERENCE('apples', 'oranges');

-- LTRIM, RTRIM, TRIM
SELECT 
    LTRIM('      Hello World      word ') AS [Left Trim],
    RTRIM('      Hello World      ') AS [Right Trim],
    TRIM('      Hello World      ') AS [Trim];

-- REPLACE
SELECT REPLACE('Hello World!', 'World!', 'Tony!');

-- REPLICATE
SELECT REPLICATE('YAY',3);

-- Handling Nulls

-- COALESCE(exp1, exp2, exp3,... expn) -> return the first Not Null Expression
CREATE DATABASE demo;
GO

USE demo;
GO

CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY, -- Identity = auto-generated (starts at 1, increments by 1)
    user_first_name VARCHAR(30) ,
    user_last_name VARCHAR(30) ,
    user_email_id VARCHAR(50) ,
    user_email_validated bit DEFAULT 0, -- bit = boolean 0: false, 1: true
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U', --U and A
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate() -- gets current
);
GO

INSERT INTO users (user_first_name, user_last_name, user_email_id, user_password, user_role, is_active)
VALUES ('Sora', 'Hearts', 'keyblade@master.com', '019he221', 'U', 1);

INSERT INTO users (user_email_id, user_password, user_role, is_active)
VALUES ('minnie@mouse.com', 'fhuih1234', 'U', 1);

INSERT INTO users (is_active)
VALUES (1);

SELECT * FROM users;

SELECT user_id, user_first_name, user_last_name, user_email_id, is_active,
COALESCE(user_first_name, user_last_name, user_email_id) [First Not Null]
FROM users;

-- Order matters
SELECT user_id, user_first_name, user_last_name, user_email_id, is_active,
COALESCE(user_email_id, user_last_name, user_first_name) [First Not Null]
FROM users;

-- Processing Orders
-- 5 dates: order_placed, warehouse_processed, date_shipped, date_delivered, date_returned
-- COALESCE(date_returned, date_delivered, date_shipped, warehouse_proceed, order_placed)
-- SELECT o.status, COALESCE(date_returned, date_delivered, date_shipped, warehouse_proceed, order_placed) [Date]

-- NULLIF(exp1, exp2)
-- Returns NULL if the two expressions are equal, otherwise returns exp1
SELECT NULLIF('Hello','World');
SELECT NULLIF('Hello','hello');
SELECT NULLIF('Hello','Hello');

/*

Logical Functions

*/

-- CHOOSE(index, val1, val2, ...valn)
	-- 1 based indexing
USE retail_db;

SELECT *, CHOOSE(MONTH(order_date),
        'Winter',
        'Winter',
        'Spring',
        'Spring',
        'Spring',
        'Summer',
        'Summer',
        'Summer',
        'Autumn',
        'Autumn',
        'Autumn',
        'Winter') Season
FROM orders;

-- IIF
SELECT *, IIF(order_item_subtotal > 200.0, 'expensive', 'cheap') [Cost] FROM order_items;

-- 'Syntatic Sugar' for our Case statement

/*

CASE STATEMENT

SWITCH STATEMENT

*/

USE AdventureWorks2022;
GO

SELECT ProductNumber,
	ProductLine,
	Category = CASE ProductLine
		WHEN 'R' THEN 'Road'
		WHEN 'M' THEN 'Mountain'
		WHEN 'T' THEN 'Touring'
		WHEN 'S' THEN 'Other'
		ELSE 'Not For Sale'
		END,
	Name
FROM Production.Product
ORDER BY ProductNumber;

/*

Views

- View is just a named query
- View does NOT physically store the Data
- Queries are fine, but modifications are limited
	- Updatable Views: Unaggregated views are generally updateable
	- Not recommended

*/

USE retail_db;
-- Updatable view
CREATE VIEW orders_v AS
SELECT * FROM orders;

SELECT * FROM orders_v;

UPDATE orders_v
SET order_status = lower(order_status);

SELECT * FROM orders_v;
SELECT * FROM orders;

CREATE VIEW orders_v AS
SELECT order_id, order_date, order_customer_id, upper(order_status) order_status FROM orders;

DROP VIEW orders_v;

-- Views are usually report ready
CREATE VIEW orders_v AS
SELECT
	order_id [Order ID],
	FORMAT(order_date, 'yyyy-MM-dd') [Order Date],
	order_customer_id [Customer ID],
	upper(order_status) [Status]
FROM orders;

-- Get the Daily revenue for each product
SELECT
    CAST(o.order_date AS Date) [Order Date],
    p.product_name [Product],
    CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) [Revenue]
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
JOIN products p ON oi.order_item_product_id = p.product_id
GROUP BY p.product_id, o.order_date, p.product_name
ORDER BY [Order Date], Revenue DESC;

drop view daily_product_revenue;

-- Make it a view
CREATE VIEW daily_product_revenue AS
SELECT
    CAST(o.order_date AS Date) [Order Date],
	DATENAME(dw, order_date) [Day of the Week],
    p.product_name [Product],
    CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) [Revenue]
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
JOIN products p ON oi.order_item_product_id = p.product_id
GROUP BY p.product_id, o.order_date, p.product_name;

SELECT * FROM daily_product_revenue;

-- More complex our query, the longer it will take to query the view
-- We write to tables, read from views

-- Query our view
SELECT * FROM daily_product_revenue
WHERE [Day of the Week] = 'Friday'
ORDER BY Revenue DESC;

-- Try and Update the view
UPDATE daily_product_revenue
SET Product = 'Generic';

-- Nesting views is possible, but not recommended

-- Common Table Expression (CTE)
-- Functionally they work as a subqeury
-- WITH <name> AS

WITH order_details_nq AS (
	SELECT * FROM orders o
	JOIN order_items oi ON o.order_id = oi.order_item_order_id
) SELECT * FROM order_details_nq

-- We can use our CTEs to filter by derived and aggregated columns
WITH order_details_nq AS(
SELECT
    CAST(o.order_date AS Date) [Order Date],
	DATENAME(dw, order_date) [Day of the Week],
    p.product_name [Product],
    CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) [Revenue]
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
JOIN products p ON oi.order_item_product_id = p.product_id
GROUP BY p.product_id, o.order_date, p.product_name
)
SELECT * FROM order_details_nq
WHERE Revenue < 100 AND [Day of the Week] = 'Sunday';

SELECT * FROM orders_v;

/*

Subqueries

Queries in the FROM/WHERE clause
Alias is Mandatory if FROM clause

*/

SELECT * FROM
(SELECT * FROM orders WHERE order_status LIKE 'CL%') o
JOIN order_items oi ON o.order_id = oi.order_item_order_id;

-- Same as CTE
SELECT * FROM
(
SELECT
    CAST(o.order_date AS Date) [Order Date],
	DATENAME(dw, order_date) [Day of the Week],
    p.product_name [Product],
    CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) [Revenue]
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
JOIN products p ON oi.order_item_product_id = p.product_id
GROUP BY p.product_id, o.order_date, p.product_name
) sq
WHERE [Day of the Week] = 'Monday';

-- WHERE Clause Subquries
-- Potential performance concerns

-- All of the orders with no items on them
-- A little janky to try and do on a join
SELECT * FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_item_order_id;

-- We can use a subquery
SELECT * FROM orders o
WHERE o.order_id NOT IN (
	SELECT DISTINCT order_item_order_id FROM order_items
);

SELECT * FROM order_items WHERE order_item_order_id = 138;

/*


CTAS - Create Table As Select

Standard Syntax: CREATE TABLE <table> AS SELECT ...
SQL Server Syntax: SELECT <cols> INTO <new_table> FROM <current table>

Creates a full copy into a new table using the results of our query
We do not specify the column names or data types - it is based on the results

Uses cases
- Taking a backup for troubleshooting and debugging
- Migrating schemas
- Historical Analysis (slow and complex queries)

*/

-- Simple backup
SELECT * INTO customers_backup FROM customers;

SELECT * FROM customers;
SELECT * FROM customers_backup;

DROP TABLE customers_backup;
-- Copy the table definition (empty table)
-- Add a false where condition

SELECT * INTO customers_backup FROM customers
WHERE 1 = 2;

SELECT order_id,
	format(order_date, 'yyyy') as order_year,
	format(order_date, 'MM') as order_month,
	format(order_date, 'dd') as order_day,
	order_customer_id,
	order_status
INTO orders_backup
FROM orders;

SELECT * FROM orders_backup;

-- Cleanup after yourself

DROP TABLE orders_backup;

-- INSERT INTO with the results of a query
-- Columns for the specified table need to the query results

CREATE TABLE customer_order_metrics (
	customer_id INT NOT NULL,
	order_month CHAR(7) NOT NULL,
	order_count INT,
	order_revenue FLOAT
)
GO

-- Define a composite PK
ALTER TABLE customer_order_metrics
	ADD PRIMARY KEY (order_month, customer_id);
GO


-- Define the query
SELECT TOP 10
	o.order_customer_id customer_id,
	FORMAT(o.order_date, 'yyyy-MM') order_month,
	COUNT(1) order_count,
	CAST(SUM(oi.order_item_subtotal) AS DECIMAL(18,2)) order_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
GROUP BY o.order_customer_id, FORMAT(o.order_date, 'yyyy-MM')
ORDER BY order_month, order_count DESC;

SELECT COUNT(1)
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id;



-- INSERT INTO
INSERT INTO customer_order_metrics
SELECT
	o.order_customer_id customer_id,
	FORMAT(o.order_date, 'yyyy-MM') order_month,
	COUNT(1) order_count,
	CAST(SUM(oi.order_item_subtotal) AS DECIMAL(18,2)) order_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
GROUP BY o.order_customer_id, FORMAT(o.order_date, 'yyyy-MM')
ORDER BY order_month, order_count DESC;

SELECT * FROM customer_order_metrics;

-- Returning a table is Magnitueds Faster than running a query

SET SHOWPLAN_ALL OFF;

-- UPDATE and DELETE are also posible to do with queries

/*

UPSERT/MERGE

UPSERT = INSERT + UPDATE

SQL Server doesn't hae UPSERT

We use MERGE

Incredibly common in Data Warehouses

Slow way: Develop an UPDATE statement and an INSERT statement and manually check your data for which is which
UPSERT Statement: Best case but not always available
MEREGE Statement

Pros:
	- Gives us absolute control
	- Able to Update, Insert, and Delete all in one statement
Cons:
	- Very verbose

*/

CREATE DATABASE MergeDemo;
GO

USE MergeDemo;
GO

CREATE TABLE SourceProducts(
    ProductID       INT,
    ProductName     VARCHAR(50),
    Price           DECIMAL(9,2)
)
GO

INSERT INTO SourceProducts(ProductID,ProductName,Price) VALUES (1,'Table',100)
INSERT INTO SourceProducts(ProductID,ProductName,Price) VALUES (2,'Desk',80)
INSERT INTO SourceProducts(ProductID,ProductName,Price) VALUES (3,'Chair',50)
INSERT INTO SourceProducts(ProductID,ProductName,Price) VALUES (4,'Computer',300)
GO

CREATE TABLE TargetProducts(
    ProductID       INT,
    ProductName     VARCHAR(50),
    Price           DECIMAL(9,2)
)
GO

INSERT INTO TargetProducts(ProductID,ProductName,Price) VALUES (1,'Table',100)
INSERT INTO TargetProducts(ProductID,ProductName,Price) VALUES (2,'Desk',180)
INSERT INTO TargetProducts(ProductID,ProductName,Price) VALUES (5,'Bed',50)
INSERT INTO TargetProducts(ProductID,ProductName,Price) VALUES (6,'Cupboard',300)
GO

SELECT * FROM SourceProducts;
SELECT * FROM TargetProducts;

-- Merge
MERGE TargetProducts AS Target
USING SourceProducts AS Source
ON Source.ProductID = Target.ProductID

-- For Update
WHEN MATCHED THEN UPDATE SET
	Target.ProductName = Source.ProductName,
	Target.Price = Source.Price

-- For Insert
WHEN NOT MATCHED BY Target THEN
	INSERT (ProductID, ProductName, Price)
	VALUES (Source.ProductID, Source.ProductName, Source.Price);

-- For Delete
WHEN NOT MATCHED BY Target THEN DELETE;

-- Merging is an Idempotent Action
-- We can run it as many times as we want with the exact same results