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
