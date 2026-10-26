/*
Common Table Expressions (CTE)
Intermediate table created after CTE query. Shortlived
Main query can take obtain from it or from database
Easier to read, written from top to bottom
	Subqueries are written bottom to top


Subqueries can only be used Once!
	So often have to rewrite subquery, unlike CTE
CTEs create a virtual table
	Able to be used in Main query
	Can also use it later on query as a Join

CTEs remove some redundancy, less steps required
	A lot more readable. 
	Break code down into modularity
		Can create multiple CTE, each doing a part of a problem
		Then combine at end with main query

CTEs go into Cache, so very fast! 

CTE Types
	1) None-Recursive CTE, Two Subtypes
		-Standalone CTE: Defined and used independently. Slef contained, doesnt
		depend on other CTEs or queries
		
		-Nested CTE: A CTE within a CTE. uses the result of another CTE
			it cannot run independently




CTE Syntax

	WITH CTE_Name AS (name of CT, then require AS) 
		(
		SELECT ...
		FROM ...
		WHERE ...
		)

	SELECT ...		(main query that is querying the CTE in the FROM clause)
	FROM CTE_Name
	WHERE ...


--Now CTE practice, each done sequentially
--Find the total sales per customer 
Step 1 Find the total sales per customer DONE above in CTE
Step 2 Find the last order date per customer
Step 3 Rank Customers based on total sales per customer
Step 4 Segment Customers based on their total sales

*/

WITH CTE_Total_Sales AS 
(
SELECT 
	CustomerID,
	SUM(Sales) as Customer_Sales
FROM sales.orders as o -- CANNOT USE ORDER BY IN CTE!!!!!!
GROUP BY CustomerID
)
, CTE_LastDate AS --- CTE2 LastOrderDate for each customerID
(
SELECT 
	CustomerID,
	MAX(OrderDate) as Last_Date
FROM sales.orders
GROUP BY CustomerID
)
, CTE_Rank AS

(SELECT
	CustomerID,
	Customer_Sales,
	RANK () OVER (Order by Customer_Sales desc) as High_Rank
FROM CTE_Total_Sales
)

, CTE_Segment AS

(SELECT
CustomerID,
Customer_Sales,
CASE WHEN Customer_Sales > 100 THEN 'HIGH'
	WHEN Customer_Sales > 80 THEN 'MEDIUM'
	ELSE 'LOW'
END Customer_Segments
FROM CTE_Total_Sales
)

SELECT
	c.CustomerID,
	c.FirstName,
	c.LastName,
	cts.Customer_Sales,
	ctd.Last_Date,
	ctr.High_Rank,
	ctseg.Customer_Segments
FROM sales.customers as c
LEFT JOIN CTE_Total_Sales as cts -- in the left join, give right table alias
ON c.CustomerID = cts.CustomerID
LEFT JOIN CTE_LastDate as ctd
ON c.CustomerID = ctd.CustomerID
LEFT JOIN CTE_Rank as ctr
ON c.CustomerID = ctr.CustomerID 
LEFT JOIN CTE_Segment as ctseg
ON c.CustomerID = ctseg.CustomerID

/* 
We can also do multiple CTEs
Only First CTE will have WITH clause 
Next CTE just need to have a comm and CTEName2 AS
	Then brackets and CTE query, then close bracket

CTE Best Practices
	1) Rethink CTEs before starting a new one
		Try not to have two CTE if you can do it in 1
		Don't use more than 5-6 CTEs in one query
			Otherwise code will be ahrd to understand and maintain

Second Type of CTE: RECURSIVE CTE
	Self-refering query that repeatedly proceses data until a specific condition
	is met
	Typically used if dealing with a hierarchy structure

Recursive CTE Syntax

WITH CTE_NAME AS
(
	SELECT ...	ANCHOR QUERY
	FROM ...
	WHERE ...

	UNION (combine data but remove duplicates) or UNION ALL (incl duplicate)

	SELECT ...	second select statement within CTE, a RECURSIVE QUERY
	FROM ...
	WHERE ...	define a break condition in order to break loop within CTE
				the loop is by having second FROM clause reference itself
					i.e. the CTE_NAME
)

SELECT FROM CTE_NAME -- standard main query */ 

-- Generate a sequence of numbers from 1-20

WITH Series AS
	(
	SELECT --Anchor query
	1 AS MyNumber

	UNION ALL

	SELECT -- Recursive Query
	MyNumber + 1
	FROM Series
	WHERE MyNumber < 20 --when MyNumber = 20, chain breaks
	)

--Main Query
SELECT *
FROM Series
OPTION (MAXRECURSION 20) -- if wanted a sequence from 1-1000
--SQL puts limit of 100. need to use option clause to set max recursion
--of 1000 to successfully complete task

--Show the employee hierarchy by displasying each employees level within
--the organisation
-- ManagerID shows how many Managers the employee has
--EmployeeID 1 Frank is NULL and he is the boss and has no managers



WITH CTE_Manager AS

(SELECT --Anchor Query 
	EmployeeID,
	FirstName,
	ManagerID,
	1 AS Level
FROM Sales.employees
WHERE ManagerID IS NULL -- speciifying first manager

UNION ALL

SELECT --recursive query
	e.EmployeeID,
	e.FirstName,
	e.ManagerID,
	Level + 1
FROM sales.employees as e 
INNER JOIN CTE_Manager as ceh -- dont need where, as inner join filters data
ON e.ManagerID = ceh.EmployeeID
)

SELECT *
FROM CTE_Manager
OPTION (MAXRECURSION 20)