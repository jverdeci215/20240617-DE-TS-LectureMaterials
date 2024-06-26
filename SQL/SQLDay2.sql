CREATE DATABASE demo;

USE demo;

-- Referential Integrity
CREATE TABLE departments(
    department_id INT PRIMARY KEY IDENTITY,
    department_name VARCHAR(30),
    department_phone CHAR(10)
);

drop table users;

-- Setting up a foreign key
CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY, -- Identity = auto-generated (starts at 1, increments by 1)
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, -- bit = boolean 0: false, 1: true
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U', --U and A
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate(), -- gets current 
	department_id INT FOREIGN KEY REFERENCES departments(department_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

INSERT INTO users
    (user_first_name, user_last_name, user_email_id, user_password, user_role, is_active, department_id)
VALUES
    ('Sora', 'Hearts', 'keyblade@master.com', '019he221', 'U', 1, 1),
    ('Minnie', 'Mouse', 'minnie@mouse.com', 'fhuih1234', 'U', 1, 2),
    ('Max', 'Goof', 'max@goof.com', 'j4892hyf1', 'U', 1, 2),
	('Goofy', 'Goof', 'max@goof.com', 'j4892hyf1', 'U', 1, 1);

INSERT INTO departments
	(department_name)
VALUES
	('Marketing'),
	('HR');


SELECT * FROM users;
SELECT * FROM departments;

USE retail_db;
-- Validate data loaded
SELECT TOP 20 * FROM retail_db.dbo.order_items;

/* 

Loading Data
- From a .sql File
- Load data from a Flat File (.csv, Parquet, JSON)
- Backup file (.bak)
- Azure Migration Services: Azure SQL Migration with Azure Data Studio

External Applications
- JDBC/ODBC
	- Type Mappings: Python(strings) -> SQL(varchar)

OLE DB
- Open Linking Embedding
- API to utilize a number of different databases
- Used for uncommon/specific file formats
- OPENROWSET

*/

/* 

Queries

*/

SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_CATALOG = 'retail_db';

-- Best to select top 10 to verify data is loaded
SELECT TOP 10 * FROM order_items;

/*

Projecting/Selecting data

SELECT Statement
- * wildcard selects all
- Can select specific columns
- Aliases to our columns
- DISTINCT - all unique values for the column
- Simple Aggregations - sum(), count(), max()/nin(), avg()

*/

SELECT TOP 10 * FROM orders ORDER BY order_date DESC;

-- Full Syntax
SELECT * FROM orders ORDER BY order_id
OFFSET  0 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Select Percentages
SELECT TOP 25 PERCENT * FROM orders;

-- Modify our columns in our select
SELECT TOP 10
	order_id AS [Order ID#],
	format(order_date, 'yyyy-MM') AS [Order Month],
	order_status AS [Status],
	order_customer_id AS [Customer ID#]
FROM orders;

-- Get the number of dates that products were ordered on
SELECT COUNT(DISTINCT order_date) AS [Days] FROM orders;

-- COUNT(1) or COUNT(*)
-- These are almost identical
-- COUNT(col) counts all non-null rows
SELECT COUNT(1) FROM customers WHERE customer_state = 'TX';

SELECT COUNT(customer_state), COUNT(1) FROM customers;
SELECT COUNT(1) FROM customers;

/*

Filtering Data

WHERE <condition>

Comparators: =, !=, >, <, >=, <=
	LIKE/ILIKE

Combine conditions with OR and AND
Ranges of Data using BETWEEN: BETWEEN X AND Y

Nulls
- Have to use IS/IS NOT NULL
- Cannot use =/!=

*/

-- Filter by a single value
SELECT TOP 10 * FROM orders
WHERE order_customer_id = 333;

SELECT * FROM orders;


-- Select specific rows using primary key
SELECT * FROM orders WHERE order_id = 716;

-- Filter Non-uniques
SELECT DISTINCT order_status FROM orders;

-- Filter by multiple values
SELECT TOP 10 * FROM orders
WHERE order_customer_id = 333
	OR order_customer_id = 127
	OR order_customer_id = 1;

-- Better syntax: using IN
-- >50 vaules in the IN clause is massively expensive
SELECT TOP 10 * FROM orders
WHERE order_customer_id IN (333,127,1);

-- LIKE Operator, ILIKE case insensitive LIKE
-- % - match any number of characer, _- matches a single character
SELECT TOP 10 * FROM orders
WHERE order_status LIKE 'compl%' ;

-- View our collation
SELECT CONVERT (varchar(256), SERVERPROPERTY('collation'));

-- Popular use of LIKE is date matching
SELECT TOP 10 PERCENT * FROM orders
WHERE FORMAT(order_date, 'yyyy-MM-dd') LIKE '2014-01%';

-- Check Nulls
SELECT COUNT(1) FROM orders
WHERE order_date IS NULL;

/*

JOINS

- ANSI and NON-ANSI JOINS
- We will be using ANSI style joins
	- Syntax: <col> JOIN <col2> ON <condition> (col1=col2)
- NON-ANSI Join: SELECT orders.*, order_items.* FROM orders, order_items WHERE order.order_id = order_items.order_id

Types of Joins
- Outer
	- Left outer
	- Right outer
	- Full outer
	- Always preserve at least one table
- Inner
	- Only records that appear in both tables

*/

-- Specify the columns to join on
-- Inner joins by default
SELECT TOP 10 PERCENT o.*, oi.order_item_id, oi.order_item_subtotal
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id;

-- Left Join
-- All orders with items on them + all orders with out items on them
SELECT o.*, oi.order_item_id, oi.order_item_subtotal
FROM orders o
LEFT OUTER JOIN order_items oi ON o.order_id = oi.order_item_order_id;

SELECT o.*, oi.order_item_id, oi.order_item_subtotal
FROM order_items oi
RIGHT OUTER JOIN orders o ON o.order_id = oi.order_item_order_id;

-- How many orders with items on them
SELECT COUNT(1) FROM orders o
WHERE order_id IN (SELECT DISTINCT order_item_order_id FROM order_items);

-- Cross Join AKA Cartesian Join = NxM 20,000 * 20,000 = 400,000,000
-- Full outer join 20,000 + 20,000 = 40,000
-- Self Join(employees: manager_id, employee_id)

-- Filter using WHERE
-- Avoid Ambiguous columns
-- Cannot use derived columns in the filter
SELECT TOP 10 PERCENT o.*, oi.order_item_id, oi.order_item_subtotal
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
WHERE o.order_status LIKE 'Closed%';

SELECT TOP 10 PERCENT o.order_id, format(order_date, 'yyyy-MM') as [order_month], oi.order_item_id, oi.order_item_subtotal
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
WHERE format(order_date, 'yyyy-MM') LIKE '2014-01%';

use retail_db;

/*

Simple Aggregations

Global Aggregations
- Total number of orders
- Average order total
- Max order Total

Aggregations by key
- GROUP BY
- GROUP BY department_id sum(salary): Total Salary per department

Rules
- If we have a non-aggregated column in the results it MUST be in the GROUP BY clause
- We can have derived columns in aggregate function but no aliases
- Cannot use the WHERE clause on aggregated fields
*/

SELECT * FROM order_items;

SELECT order_item_product_id, sum(order_item_subtotal) revenue
FROM order_items
GROUP BY order_item_product_id;

-- Derived columns
SELECT COUNT(1) [Count], format(order_date, 'yyyy-MM') order_month
FROM orders
GROUP BY format(order_date, 'yyyy-MM')
ORDER BY format(order_date, 'yyyy-MM');

-- No where clause, Have to use HAVING
SELECT COUNT(1) num_count, format(order_date, 'yyyy-MM') order_month
FROM orders
GROUP BY format(order_date, 'yyyy-MM')
HAVING COUNT(1) > 5000
ORDER BY order_month;

-- Order of Operations: FROM -> WHERE -> GROUP BY -> SELECT

-- Formatting
SELECT
    order_item_order_id,
    sum(order_item_subtotal) [Revenue],
    max(order_item_subtotal) [Largest Item],
    min(order_item_subtotal) [Smallest Item],
	avg(order_item_subtotal) [Average Item],
    count(order_item_subtotal) [Total # Items]
FROM order_items
GROUP BY order_item_order_id;

-- Cast it to another type
SELECT
    order_item_order_id,
    sum(order_item_subtotal) [Revenue],
    max(order_item_subtotal) [Largest Item],
    min(order_item_subtotal) [Smallest Item],
	cast(avg(order_item_subtotal) AS decimal(6, 2)) [Average Item],
    count(order_item_subtotal) [Total # Items]
FROM order_items
GROUP BY order_item_order_id;

-- round
SELECT
    order_item_order_id,
    sum(order_item_subtotal) [Revenue],
    max(order_item_subtotal) [Largest Item],
    min(order_item_subtotal) [Smallest Item],
	round(avg(order_item_subtotal), 2) [Average Item],
    count(order_item_subtotal) [Total # Items]
FROM order_items
GROUP BY order_item_order_id
ORDER BY [Revenue] desc;

/*

Sorting Data In SQL

Clustered Index: Data is physically sorted in this order
Non-Clustered Index: Tells how to sort along that index
If not using either index, SQL will perform a full table scan
This is incredibly expensive

*/

SELECT * FROM order_items
ORDER BY order_item_subtotal desc;

CREATE INDEX order_item_subtotal_idx ON order_items(order_item_subtotal desc);

-- Check what's going on under the hood
SET SHOWPLAN_ALL OFF;

-- Composite Sorting
SELECT * FROM orders
ORDER BY order_date desc, order_customer_id desc;

CREATE INDEX order_date_id_idx ON orders(order_date desc, order_customer_id desc);