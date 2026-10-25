/* Subqueries: Query within a query
Main query done after subquery
Subquery output is intermediate step
Then main query interacts with the subquery output (not shown to us)
	- main query can even still interact with original data too
	thus main query has 2 sources of data



Subquery Types
	Non-correlated Subquery

	Correlated subquery


Result output
	Scalar subquery 1 value output
	Row subquery - multiple row, single column output
	Table subquery - returns a table */

/* Syntax
SELECT     -- mainquery
	Col 1,
	Col 2
FROM (
	SELECT   --subquery
	FROM
	WHERE ) AS ALIAS(a must in SQL server, optional in others) */


-- find the products that have a price higher than the average price 
-- of all products

SELECT
* -- this asterisk TAKES ALL THE COLUMNS FROM SUBQUERY, NOT FROM ORIGINAL DATA
FROM (
	select
		ProductID,
		Price,
		AVG(Price) OVER () AvgPrice
	from sales.products
	)t -- this is the ALIAS, t for table. must in SQL server
WHERE Price > AvgPrice -- filter is in main query

-- Rank customers based on their total amount of sales
select *,
RANK() OVER (Order By TtlSale desc) as [RANK]
from(
	select CustomerID,
	SUM(Sales) as TtlSale
	from sales.orders
	Group By CustomerID)t

--above examples are subquery within from clause
-- but subquery can also be within select clause
	--HOWEVER THE output must be scalar


--show product IDs, names, prices and total no. of orders
	--no. of orders is in a different table....
select
	ProductID,
	Product,
	Price
from sales.products;

select 
COUNT(*) as TotalOrders --single output, thus a scalar subquery
from sales.orders;
-- -->now lets do it together 

select --subquery within SELECT. needs to be a scalar query
	ProductID,
	Product,
	Price,
	(SELECT COUNT(*) TotalOrders From sales.orders)Total
from sales.products;

/* Subquery in Joins
Occasionally need to prepare data before doing a Join 

Show all customer details and find total orders for each customer */

SELECT *
from sales.orders;
SELECT *
from sales.customers;
--lets do query for total orders for each customer first, then make it into subquery
SELECT CustomerID,
COUNT(*) as TotalOrders
from sales.orders
GROUP BY CustomerID

-- ok combine and and make intermediate subquery table as right table

SELECT C.customerID,
C.FirstName,
C.LastName,
C.Country,
c. Score,
t.TotalOrders
FROM sales.customers as c -- FROM CLAUSE HAS LEFT TABLE
LEFT JOIN( -- now specify right table, which is table after subquery complete
	SELECT CustomerID,
	COUNT(*) as TotalOrders
	from sales.orders
	GROUP BY CustomerID
)as t
ON c.customerID = t.customerID -- require key to join tables. CustomerID is the key

--Subqueries and WHERE Clause
--used for complex filtering logic and makes query more flexible and dynamic
-- Find the products that have a price higher than the average price
-- of all products

Select ProductID,
Product,
Price
from sales.products
WHERE Price >
	(Select AVG(Price)
	from sales.products) -- single output, doesnt need alias

--Subqueries and Logical Operators
-- IN for filetering multiple values: WHERE CustomerID IN (1,3,4)
-- checks to see if it matches value in list
-- Show the details of orders made by customers in Germany

select *
from sales.orders
WHERE CustomerID IN (
	SELECT CustomerID from sales.customers WHERE Country = 'Germany')
	-- if wanted to change to customer not from Germany
	-- then could either turn IN to NOT IN, or country = to country !=


-- find female employees whose salaries are greater thant he salaries of 
-- any male employees
select EmployeeID,
FirstName,
LastName,
Gender,
Salary
FROM sales.employees
WHERE Gender = 'F' AND Salary >ANY(
	SELECT Salary FROM sales.employees WHERE Gender = 'M')
	-- if task was to find female whose salaries are greater than ALL
	-- male employees, then use ALL instead of ANY!

--Show all customer details and find the total orders for each customer
Select c.*,
o.TotalOrders
FROM sales.customers as c
LEFT JOIN
	(SELECT CustomerID,
	Count(*) as TotalOrders
	from sales.orders 
	GROUP BY CustomerID 
	)o
ON c.CustomerID = o.CustomerID
--- CAN ALSO DO THIS TASK WITH CORRELATED SUBQUERY, ITS LESS EFFICIENT
-- AS IT CALCULATES FOR EACH ROW, see below. 

SELECT *,
	(SELECT Count(*) from sales.orders as o WHERE o.customerID = c.customerID) as TotalSales
from sales.customers c
	--where clause calculates per row...

-- EXISTS
-- for each row in man query, subquery is run	
	--if no result, that row is excluded

--show details of orders made by customers in Germany
select *
from sales.orders as o
WHERE Exists (select 1
			from sales.customers as c
			WHERE Country = 'Germany'
			AND o.CustomerID = c.customerID )
			-- filter only includes result of those where country is germany
			-- and there is matching customerID.
			-- for Exist: the actual values dont matter.