/*

SQL Server Basics

SQL Syntax
- UPPERCASE - T-SQL Keyword
	- SELECT, UPDATE, DELETE, WHERE
	- Uppercase is not required
- italics = user defined parameter
- bold = Database object
- [] = Allows us to use spaces and special characters ([Movie Title])
- ; = end line

Fully Qualified Name
[server].[database].[schema].[table]


*/

-- Single Comment

-- Fully Qualified Name
SELECT * FROM [JV-PC].master.dbo.MSreplication_options;
-- Line2
-- Line3
GO

-- We can leave off the server, cause we are already connected
SELECT * FROM master.dbo.MSreplication_options;
GO
-- We can leave off the database if we switch contexts
USE master;
SELECT * FROM dbo.MSreplication_options;
GO
-- We can leave off the Schema if it's dbo
SELECT * FROM MSreplication_options;
GO
-- We can let the interpretor fill in the blanks with '.'

-- SELECT * FROM [JV-PC]...MSreplication_options;


-- Batch Operations
-- End of the batch: GO
-- DDL - Create Tables
-- Employess and Departments - What would happen if Employees table got created first? Wouldn't work
/*
CREATE Departments;
GO

CREATE Employees;
GO
*/
-- This does not define different Transactions, This is for scripting purposes

/*

Other ways to interact with the Server

CLI - sqlcmd
Programmatically with a Programming language

JDBC

We can use Python with the pymssql library
*/

-- DML/CRUD Applications
-- DML = Changing, updating data

/*

Database Operations
- DDL
	- CREATE/ALTER/DROP tables/views/sequences
- DML
	- INSERT/SELECT/DELETE/UPDATE
- TCL
	- COMMIT/ROLLBACK/BEGIN TRAN
	- Default: Auto-Commit
	- Transaction: Processes what is highlighted by default

*/

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

/*

CRUD

CREATE - INSERT INTO
READ - SELECT
UPDATE - UPDATE
DELETE - DELETE

*/

CREATE DATABASE demo;

use demo;

-- CREATE TABLE creates a table
-- By default it will put in into the dbo schema
-- We can put it into a different Schema, but we will have to create the Schema first
CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY, -- Identity is a surrogate key. Identity starts at 1 and counts up
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, -- bit = boolean
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U',
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate() -- gives us the current date
);

-- Typically our Applications will not perform the DDL Part, we will connect to already established dbs
-- CRUD

-- (C)REATE - INSERT
-- Syntax: INSERT INTO <table> (col1, col2, col3) VALUES (val1, val2, val3)
INSERT INTO users (user_first_name, user_last_name, user_email_id)
VALUES ('Scott','Tiger','scott@tiger.com');

INSERT INTO users (user_first_name, user_last_name, user_email_id)
VALUES ('Donald','Duck','donald@duck.com');

INSERT INTO users (user_first_name, user_last_name, user_email_id, user_role, is_active)
VALUES ('Mickey','Mouse','mickey@mouse.com', 'U', 1);

SELECT * FROM users;

-- Multiple inserts in the same command
-- Faster on the backend
INSERT INTO users
    (user_first_name, user_last_name, user_email_id, user_password, user_role, is_active)
VALUES
    ('Sora', 'Hearts', 'keyblade@master.com', '019he221', 'U', 1),
    ('Minnie', 'Mouse', 'minnie@mouse.com', 'fhuih1234', 'U', 1),
    ('Max', 'Goof', 'max@goof.com', 'j4892hyf1', 'U', 1);

-- (R)EAD - SELECT
-- SELECT <col1, col2,... coln> FROM <table> WHERE <condition>

SELECT user_first_name, user_last_name, user_email_id FROM users;

-- * Wildcard operator
SELECT * FROM users WHERE is_active = 1;

-- T-SQL we can use the TOP keyword
SELECT TOP 2 * FROM users WHERE is_active = 1;

-- (U)PDATE - UPDATE
-- Syntax: UPDATE <table> SET col1=val1, col2=val2 WHERE <condition>
-- If WHERE is left out, UPDATE will occur on every row
UPDATE users
SET
	user_role = 'A',
	user_email_validated = 1;

SELECT * FROM users;

-- DDL
DROP TABLE users;

-- (D)ELETE - DELETE
-- Syntax: DELETE FROM <table> WHERE <condition>
-- Best Practice: use TRUNCATE to empty table

DELETE FROM users WHERE user_password IS NULL;

-- TCL Basics
BEGIN TRAN transaction1;

UPDATE users
SET user_email_id = upper(user_email_id)
WHERE user_first_name = 'Mickey';

SAVE TRAN savepoint;
UPDATE users
SET user_email_validated = 1;

ROLLBACK TRAN savepoint;
COMMIT;
-- Clean up after yourself
use master;
DROP DATABASE demo;

/*

DDL = Data Definition Language

DDL Scripts - .sql file with table definitons, constraints, indexes, and views

Common Task
- CREATE TABLE
- Creating Indexes (performance)
- Altering tables (Constraints)

Uncommon tasks
- Adding a new column
- TRUNCATE tableS
- Remove constraints

Avoids
- Removing columns
	- Create a new column, and tell applications to switch over on their own
- Changing our data types
	- Exception: Natural conversions INT -> BIGINT

*/

CREATE DATABASE demo;
GO

USE demo;
GO

CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY, -- Identity is a surrogate key. Identity starts at 1 and counts up
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, -- bit = boolean
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U',
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate() -- gives us the current date
);

-- Document our Database objects
-- Create a Table Comment

-- Extended property (SQL Server specific)
-- Level0 - schema, level1 - table, level2 - column
EXEC sp_addextendedproperty
@name = 'Description',
@value = 'This is my table comment',
@level0type = N'Schema', @level0name='dbo',
@level1type = N'Table', @level1name='users'

-- Add a comment to the user_role column
EXEC sp_addextendedproperty
@name = 'User Roles',
@value = 'Valid values are U and A',
@level0type = N'Schema', @level0name='dbo',
@level1type = N'Table', @level1name='users',
@level2type = N'Column', @level2name = 'user_role'

/*

Data types in 30 seconds (5 minutes)

INT
VARCHAR
BIGINT
bit
DATETIME
Text - deprecated

Exact Numerics
- BIGINT - 8 Bytes
- INT - 4 Bytes
- SMALLINT - 2 Bytes
- TINYINT - 1 Byte
- NUMERIC/DECIMAL(precision, scale): Numeric(5, 2) -> 151.24
- MONEY (Specify the default currency)

Approximate Numerics
- FLOAT(n) - n is the number of bits for the mantisswa of the float for scientific notation (1.234 * 10^5)

Date and Time
- DATE - YYYY-MM-DD format, 0001-9999
- TIME - no-timezone - hh:mm:ss.nnnnnnn
- DATETIME - YYYY-MM-DD hh:mm:ss.mmmm
- DATETIME2 - YYYY-MM-DD hh:mm:ss.nnnnnnn
- DATETIMEOFFSET - DATETIME2 + Timezone from UTC

Strings
- CHAR(n) - Fixed length string; CHAR(5) 'XXXXX'
- VARCHAR(n) - Variable length string - number of bytes
- Text - deprecated

- COLLATION = Default character encoding + extra stuff for our database
	- Our Default Collation 1 char = 1 byte
	- 1 char = 4 bytes, VARCHAR(40) -> 10 characters

Binary String
- (VAR)BINARY - binary string
- IMAGE (2^31 - 1) ~ 2.1 GB
	- Most other dbs will call this a BLOB
	- Common Design Pattern: store a reference to that image file/url

Other Types
- SPATIAL GEOGRAPHY TYPES
- SPATIAL GEOMETRY TYPES
- HIERARCHYID
- XML

Not a Type in T-SQL: JSON
- We store JSON in a VARCHAR(n) + System stored procedure
*/

/*

CONSTRAINTS

- NOT NULL
- CHECK <condition>
- DEFAULT
- UNIQUE
	- Composite Columns also unique - UNIQUE(full_name, email)
- PRIMARY KEY
	- UNIQUE, NOT NULL
	- 1 per table
	- Surrogate Key (Artificial Key)
		- IDENTITY(start, increment)
	- Creates a Clustered Index (rows are physicall sorted based on that index)
- FORIGN KEY
	- Establish links between tables
	- Most often references other PKs
		- Can reference any UNIQUE column
	- Must reference the same db
	- Does not automatically create an index (it is recommended)
	- Referential integrity
		- Cannot delete data that is referenced by a foreign key
		- Cascading RI
			- Action that is taken when a user tries to delete/update a referenced field
				- NO ACTION - it rejects and sends an error (default)
				- CASCADE - FK Update/delete corresponding referenced rows
					- Very dangerous
				- SET DEFAULT - Update the FK to the default value


def do_something()
	cursor.execute('SELECT col1, col4, col8, FROM db.table1)
	pass
*/
DROP TABLE users;

-- 3 Ways for us to define constraints

-- Inline
CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY, 
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, 
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U', 
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate() 
);

-- Define all of our contraints at the end of the CREATE TABLE Statement
-- Allows us to name our constraints
CREATE TABLE users (
    user_id int IDENTITY, 
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, 
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U', 
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate(),
	CONSTRAINT pk_users_user_id PRIMARY KEY CLUSTERED (user_id)
);

-- Add it afterwords
-- Preferred way with our DDL Scripts
CREATE TABLE users (
    user_id int IDENTITY, 
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated bit DEFAULT 0, 
    user_password VARCHAR(200),
    user_role VARCHAR(30) NOT NULL DEFAULT 'U', 
    is_active bit DEFAULT 0,
    last_updated_ts DATETIME DEFAULT getdate()
);

ALTER TABLE users
ADD CONSTRAINT pk_users_user_id PRIMARY KEY CLUSTERED (user_id);

/*

Loading and Dumping Data

Loading Data
- .sql
- Data Files (CSV, Parquet, JSON)
- Backup File (.bak)

Backups
- Data
- Transaction Log
- Uses
	- Restoration and Recovery
	- Migration/export data
	- In a production system, we will have primary node (writer), and secondary nodes (read replicas)

Recovery Models
- Full
	- Representative of the database and all data at the time of backup
	- Expensive
- Differential Backup
	- Contains the changes since the last backup
	- Run the full backup and then all differentials in sequence
	- Common Strategy: Full Backup during off hours (1:00-3:00AM) Diff backup every 6 hours or so
- Logs
	- Backup the transaction logs since last full backup
	- Replay every transaction in the log
- Data
	- Export your tables as files
	- Just keep the data files

Restore/Recovery
- Multi-phase process that copies the data and the logs. Roll forward all of our transactions.
- Types
	- Full
	- Incremental
	- Manual

*/

BACKUP DATABASE demo
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\demo.bak'


use hr_db;

drop database demo;

RESTORE DATABASE[demo]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\demo.bak';