/*

Partitioning
3 main strategies:
- Hash
- List
- Range

SQL Server only supports range

0. Optitional - Create our filegroups
1. Create our partition function
2. Create our partition scheme
3. Create or alter our tables to specify the partition column

*/

-- Partition Function
-- RANGE RIGHT OR LEFT
CREATE DATABASE partition_demo;
GO

USE partition_demo;
GO

CREATE PARTITION FUNCTION myRangePF1 (datetime2(0))
	AS RANGE RIGHT FOR VALUES ('2022-04-01', '2022-05-01', '2022-06-01')
GO

ALTER PARTITION FUNCTION myRangePF1 ()
SPLIT RANGE('2022-07-01');

CREATE PARTITION SCHEME myRangePS1
	AS PARTITION myRangePF1
	ALL TO ('PRIMARY');
GO

CREATE TABLE dbo.PartitionTable (col1 INT PRIMARY KEY, col2 char(20))
	ON myRangePS2(col1);
GO

SELECT * FROM PartitionTable;

CREATE PARTITION FUNCTION myRangePF2 (INT)
	AS RANGE RIGHT FOR VALUES (1, 100, 1000);
GO

CREATE PARTITION SCHEME myRangePS2
	AS PARTITION myRangePF2
	ALL TO ('PRIMARY');
GO

ALTER PARTITION FUNCTION myRangePF2 ()
MERGE RANGE(1);

ALTER PARTITION FUNCTION myRangePF2 ()
SPLIT RANGE(500);


DROP TABLE PartitionTable;



SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, *   
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
JOIN sys.partition_schemes ps   
    ON i.data_space_id = ps.data_space_id   
WHERE t.name = 'PartitionTable';   
GO

SELECT SCHEMA_NAME(t.schema_id) AS SchemaName, t.name AS TableName, i.name AS IndexName, 
    p.partition_number, p.partition_id, i.data_space_id, f.function_id, f.type_desc, 
    r.boundary_id, r.value AS BoundaryValue   
FROM sys.tables AS t  
JOIN sys.indexes AS i  
    ON t.object_id = i.object_id  
JOIN sys.partitions AS p  
    ON i.object_id = p.object_id AND i.index_id = p.index_id   
JOIN  sys.partition_schemes AS s   
    ON i.data_space_id = s.data_space_id  
JOIN sys.partition_functions AS f   
    ON s.function_id = f.function_id  
LEFT JOIN sys.partition_range_values AS r   
    ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
WHERE 
    t.name = 'PartitionTable' 
    AND i.type <= 1  
ORDER BY SchemaName, t.name, i.name, p.partition_number;


SELECT   
    t.[object_id] AS ObjectID
    , SCHEMA_NAME(t.schema_id) AS SchemaName
    , t.name AS TableName   
    , ic.column_id AS PartitioningColumnID   
    , c.name AS PartitioningColumnName
    , i.name as IndexName
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
    AND i.[type] <= 1 -- clustered index or a heap   
JOIN sys.partition_schemes AS ps   
    ON ps.data_space_id = i.data_space_id   
JOIN sys.index_columns AS ic   
    ON ic.[object_id] = i.[object_id]   
    AND ic.index_id = i.index_id   
    AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column   
JOIN sys.columns AS c   
    ON t.[object_id] = c.[object_id]   
    AND ic.column_id = c.column_id   
WHERE t.name = 'PartitionTable';   
GO

/*

Analytics Functions

Window Functions

Types
- GLOBAL: func() OVER (ORDER BY <col>)
- Aggregations: func() OVER (PARTITION BY <col>)
- Local: func() OVER (PARTITION BY <col> ORDER BY <col>)

*/

USE hr_db;

-- Get all of the total salaries of each department
SELECT department_id, SUM(salary) dept_salary
FROM employees
GROUP BY department_id;

-- Compare each employees salary to the average salary of their department

-- Full Subquery
SELECT TOP 10 e.employee_id, e.department_id, e.salary,
    ae.department_salary_expense,
    ae.avg_salary_expense,
    ROUND(e.salary/ae.department_salary_expense * 100, 2) pct_salary
FROM employees e JOIN (
    SELECT department_id,
        SUM(salary) as department_salary_expense,
        ROUND(AVG(salary), 2) AS avg_salary_expense
    FROM employees
    GROUP BY department_id
) ae
ON e.department_id = ae.department_id
ORDER BY department_id, salary;


USE hr_db;
-- Rewrite it with window functions
SELECT
	employee_id,
	department_id,
	salary,
	SUM(salary) OVER (PARTITION BY department_id ORDER BY department_id DESC) total_dept_salary,
	AVG(salary) OVER (PARTITION BY department_id) avg_dept_salary,
	salary/SUM(salary) OVER (PARTITION BY department_id) pct_dept_salary
FROM employees;

USE retail_db;


-- Daily Revenue Table CTAS
SELECT
	o.order_date,
	CAST(SUM(oi.order_item_subtotal) AS DECIMAL(18,2)) revenue
INTO daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETED','CLOSED')
GROUP BY o.order_date;

-- Daily Product Revenue table
SELECT
	o.order_date,
	oi.order_item_product_id,
	CAST(SUM(oi.order_item_subtotal) AS DECIMAL(18,2)) revenue
INTO daily_product_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETED','CLOSED')
GROUP BY o.order_date, oi.order_item_product_id;

SELECT TOP 10 * FROM daily_revenue;
SELECT TOP 10 * FROM daily_product_revenue
ORDER BY order_item_product_id;

-- Now we can analyze based off window functions
SELECT *,
	SUM(revenue) OVER (PARTITION BY order_date) total_daily_revenue,
	MIN(revenue) OVER (PARTITION BY order_date) min_daily_revenue,
	MAX(revenue) OVER (PARTITION BY order_date) max_daily_revenue
FROM daily_product_revenue
ORDER BY order_item_product_id, order_date;

SELECT *,
	SUM(revenue) OVER (PARTITION BY order_date) total_daily_revenue,
	MIN(revenue) OVER (PARTITION BY order_date) min_daily_revenue,
	MAX(revenue) OVER (PARTITION BY order_date) max_daily_revenue,
	AVG(revenue) OVER (PARTITION BY order_item_product_id) avg_product_revenue
FROM daily_product_revenue
ORDER BY order_item_product_id, order_date;


-- Cumulative Aggregation vs Moving Aggregation

-- Cumulative Aggretion: Running Total
-- Moving Aggregation: Looks at a window of time
	-- I.E., Avergae sales over the last 7 days, 30 days, 90 days

-- ROWS BETWEEN clause
	-- ROWS BETWEEN X AND Y
	-- UNBOUNDED PROCEDING/UNBOUNDED FOLLOWING
	-- 3 PRECEDING/3 FOLLOWING
	-- CURRENT ROW

-- Compare each daily product revenue to the average for that product over the last week

-- It will only take into account the data it has
SELECT *,
	AVG(revenue) OVER (
		PARTITION BY order_item_product_id 
		ORDER BY order_date 
		ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) last_wk_avg
FROM daily_product_revenue
ORDER BY order_item_product_id, order_date;

-- Compare the current days revenue to the total revenue so far
SELECT *,
	SUM(revenue) OVER (
		ORDER BY order_date DESC 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) cumulative_total_revenue
FROM daily_revenue;

-- Compare our monthly revenue
SELECT *,
	SUM(revenue) OVER (
		PARTITION BY FORMAT(order_date, 'yyyy-MM')
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) cumulative_monthly_revenue
FROM daily_revenue
ORDER BY order_date;

-- Average revenue in a 5 day moving window
SELECT *,
	AVG(revenue) OVER (
		ORDER BY order_date
		ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
	) five_day_avg
FROM daily_revenue
ORDER BY order_date;

-- lead(col, #), lag(col, #), first_value(), last_value()
-- MUST CONTAIN ORDER BY
SELECT *,
	LAG(revenue, 1) OVER (ORDER BY order_date) prior_day_revenue,
	LEAD(revenue, 1) OVER (ORDER BY order_date) next_day_revenue
FROM daily_revenue;

SELECT *,
	FIRST_VALUE(order_date) OVER (
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) first_day,
	LAST_VALUE(order_date) OVER (
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) last_day
FROM daily_revenue;

-- View first day product was ordered and last day product was ordered
SELECT *,
	FIRST_VALUE(order_date) OVER (
		PARTITION BY order_item_product_id
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) first_day,
	LAST_VALUE(order_date) OVER (
		PARTITION BY order_item_product_id
		ORDER BY order_date
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) last_day
FROM daily_product_revenue;

SELECT * FROM daily_product_revenue;

-- rank(), dense_rank(), row_number()

USE hr_db;

SELECT
	employee_id,
	first_name,
	last_name,
	department_id,
	salary,
	rank() OVER (
		PARTITION BY department_id
		ORDER BY salary DESC
	) [Rank],
	dense_rank() OVER (
		PARTITION BY department_id
		ORDER BY salary DESC
	) [Dense Rank],
	row_number() OVER (
		PARTITION BY department_id
		ORDER BY salary desc, last_name desc
	) [Row Number]
FROM employees
ORDER BY department_id, salary DESC;

/* 
ORDER OF OPERATIONS

When we write a query:
SELECT
FROM
JOIN - ON
WHERE
GROUP BY - HAVING
ORDER BY

SQL will execute in the following order:
FROM
JOIN - ON
WHERE
GROUP BY
SELECT
ORDER BY


*/

-- CTE
SELECT * FROM (
	SELECT
		employee_id,
		first_name,
		last_name,
		department_id,
		salary,
		rank() OVER (
			PARTITION BY department_id
			ORDER BY salary DESC
		) [Rank]
	FROM employees
) nq
WHERE nq.[Rank] <= 5;

/*

Variables and Stored Proceedures
Variables are Local objects
- Exist only for the block that they are in
- DECLARE @name <Type>;
- Mainly used in Scripts and Proceedures

Stored Procedures
Pros:
- Reduced server/client network traffic
- Stronger Security
- DRY code, reuseable
- Easier Maintence
- Improved Performance
	- Optimizes on first run

Types:
- System defined
- Temporary
- User-Defined
- Extended-user-defined

*/

DECLARE @MyNum DECIMAL(18,2);
DECLARE @FirstName VARCHAR(30), @LastName VARCHAR(30);

SET @MyNum = 11516.91;

SELECT * FROM daily_revenue
WHERE revenue = @MyNum;
GO

SELECT * FROM daily_revenue
WHERE revenue = @MyNum;


USE AdventureWorks2022;
GO

CREATE PROCEDURE HumanResources.uspGetEmployeesTest
	@LastName NVARCHAR(50),
	@FirstName NVARCHAR(50)
AS
	SET NOCOUNT ON;

	SELECT FirstName, LastName, Department
	FROM HumanResources.vEmployeeDepartmentHistory
	WHERE FirstName = @FirstName AND LastName = @LastName
	AND EndDate IS NULL;
GO

-- Use SP by using the EXECUTE command (EXEC)

EXECUTE HumanResources.uspGetEmployeesTest N'Ackerman',N'Pilar';
-- OR
EXEC HumanResources.uspGetEmployeesTest @LastName=N'Ackerman', @FirstName=N'Pilar';
-- OR
EXEC HumanResources.uspGetEmployeesTest @FirstName=N'Pilar', @LastName=N'Ackerman'; 

SELECT * FROM HumanResources.Employee;

EXEC uspGetEmployeeManagers 123;

/*
Triggers

Types:
- LOGON
- DDL
- DML

LOGON
- Fire in response LOGON event
- Happens after authentication but before the session is established
- Will not fire if authentication fails

DDL Triger
- Fires in response to DDL events
- CREATE, ALTER, DROP, GRANT, DENY, REVOKE, OR UPDATE STATICS
- Use cases:
	- Safety: prevent changes to schema or tables
	- Automate actions in response to schema changes
	- Record database schema changes

DML Trigger
- Fire in response to DML Events
- INSERT, UPDATE, DELETE
- Use Cases:
	- Enforcing Data Integrity Policies
	- Query Tables
	- Complex T-SQL Statements
*/
USE demo;
GO

CREATE TRIGGER safety
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
	PRINT 'You must disable Trigger "Safety" before dropping or altering tables'
	ROLLBACK;
GO

CREATE TRIGGER getTable
ON users
AFTER INSERT, UPDATE, DELETE
AS
	SELECT * FROM users;
GO

SELECT * FROM users;

INSERT INTO users (user_first_name, user_last_name, user_email_id)
VALUES ('Test', 'Bob', 'Bob@Test.com');

CREATE SCHEMA Test ;  
GO

CREATE SEQUENCE Test.CountBy1  
    START WITH 1  
    INCREMENT BY 1 ;  
GO
CREATE SEQUENCE Test.TestSequence ;
SELECT * FROM sys.sequences WHERE name = 'CountBy1' ;

SELECT NEXT VALUE FOR Test.CountBy1 AS FirstUse;  
SELECT NEXT VALUE FOR Test.CountBy1 AS SecondUse;