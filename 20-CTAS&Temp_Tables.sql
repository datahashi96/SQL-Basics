/* CTAS & Temp Tables

Database Notes:

A database table is a strucutured collection of data,
	similar to spreadsheet or grid
	stored in files in database in disc storage

Table Types
	1) Permanent Tables
		created by
			1) CREATE or SELECT: classical way
				Define structure of table
					With DDL command, CREATE
				Then insert data into table
					INSERT clause from CSV or another database or an app
			2) CTAS: Create Table As Select
				creates a table based on SQL query
	2) Temporary Table'=
		- deleted after session ends


CTAS vs VIEWS
CTAS leads to a table with data - query executed and results stored into table
VIEWS is a virtual table - query not executed yet. 

Querying VIEWS is slower than querying CTAS.
	Need to VIEWS query to be complete. 

If an update happens
	CTAS not affected as query already completed
	VIEW will be updated as query happens when triggered


Create Table Syntax
1) DDL Statement to Create TABLE
CREATE TABLE Table_Name
(
	ID INT,					-- name of Column and then datatype
	Name VARCHAR(50)
)

2) Insert Data into Table
INSERT INTO Table_Name
Values (1, 'Frank')


NOW, CTAS Syntax: Put Query Within a DDL Statement
e.g.

CREATE TABLE Table_1 AS -- very similar to creating VIEW. just table instead
(
	SELECT...
	FROM...
	WHERE...
) -- for most SQL software

for SQL Server however: - insert command after select to create CTAS
SELECT ...
	INTO New_Table -- INTO IS JUST BEFORE FROM!!!
FROM ...
WHERE ...


When to use CTAS
	If you have complicated query, VIEW could take a long time
	Each user has to wait 30 mins....
	Then in that case better to do CTAS */


--Create table for total no. of orders for each month

SELECT 
		DATENAME(Month,OrderDate) OrderMonth, 
		COUNT(OrderID) as Total_Orders
	INTO Sales.MonthlyOrders -- must give AS for columns
from sales.orders
GROUP BY DATENAME(Month,OrderDate) 

DROP TABLE Sales.monthlyorders -- now droppped
-- if want to update CTAS Table, need to drop and re-execute the query
-- that made it

-- can make it faster by using T-SQL logic so it does it repeatedly.

IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrders;
GO -- this checks to see if table exists, if it does then gets dropped
-- put this code above other query and execute
-- so the CTAS from yesterday gets deleted and a new CTAS 
-- with updated information is created


-- can use CTAS to create physical DataMart
-- rather than VIEWS
-- this is faster than VIEWS which are virtual and query always nneed to be done
-- better to start with VIEWS
	-- if later the DataMarts are getting slow, then turn into CTAS


/* Temp(Temporary) Tables
Store intermediate results in temp storage within database during session
All temp tables are dropped after the session ends
	i.e. when disconnecting from database

Stored under system databases
	TempDB
		Temporary Tables
Temp Table Syntax
SELECT ...
	INTO #New_Table --just add # before name of table to make it temp
FROM ...
WHERE.. */

SELECT *
INTO #Orders
FROM sales.orders

select *
from #Orders -- works, but will have to create to access it later on when
-- session ends

-- because its temporary, lets delete stuff from it as it doesnt matter

DELETE
FROM #Orders
WHERE OrderStatus = 'Delivered' -- delete all delivered orders

select * -- only shipped orders remaining
from #Orders
-- now if we liked this and wanted to keep it, turn into table

SELECT *
	INTO Sales.OrderTest
From #Orders

select *
FROM sales.ordertest --lets delete it now

-- Temp Table Use
	--Once data loaded into database
	--Need temp table to do transformations on, not on source data
	-- Then final product turn into table and move into database

-- Baraa Opinion on Temp Tables
	-- DOESNT USE
	-- Intermediate results through CTE
	-- If important, put in VIEWS or permanent Table