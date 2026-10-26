/*
Views: A virtual table (result of query)that shows data without storing it 
in the database
A set of persisting SQL queries in database
Easy to Maintain, can edit it easily by altering query

DDL: a set of commands that allow us to define and manage
the structure of a database
	Create
	Alter
	Drop To remove table/schema/database

Hierarchy can be explored through Object Explorer
	SQL Server
		Databases (SalesDB and other)
			SalesDB
				Sales. - The Schema
					Table: e.g. Sales.Customers
					Sales.Employees ...
						Columns (CustomerID, FirstName....)

To acces schemas
	Go back into Security Then into Schema Folder for a directory of them



3 Level Of Architecture
	Physical Level
		Lowest level
		Actual data stored in physical storage
		Only database administrators have access to this layer

	Logical Level
		Used by app developer or data engineer
		Accessed in order to define structure of data
		Creating tables and defining relationships between them
		Define Views
		Create table indices to optimise performance

	View Level
		First View could be customised for business analysts
		Another set suitable for data visualisation and reports
			e.g. PowerBI
		Make data friendly and easy to consume



Uses for Views
	Central Query Logic: Store central complex query logic
	in the database
		For access by multiple queries. Thus reducing project complexity

Views reduce redundancy in multiple queries
Improve reusability in multiple queries
Persisted Logic
Views need to maintained with Create/Drop
	
	CTEs only reduce redundnacy in 1 query
	Temporarly logic only


VIEW Syntax: Requires DDL commands

CREATE View View_Name AS
(
	SELECT...  
	FROM...
	WHERE...

) */

--Find the running total of sales for each month
-- can add extra things before making it view like count/sum quanity
WITH CTE_Monthly_Summary AS
(
	SELECT
	DATETRUNC(month,OrderDate) Order_Month,
	SUM(Sales) TotalSales,
	COUNT(OrderID) TotalOrders,
	SUM(Quantity) TotalQuantities
	FROM Sales.orders
	GROUP BY DATETRUNC(month,OrderDate)
)

SELECT
Order_Month,
TotalSales,
SUM(TotalSales) OVER (Order BY ORDER_MONTH) AS Running_Total
FROM CTE_Monthly_Summary