/*
WINDOW FUNCTIONS:
Perform calculations on a specific subset of data
w/o losing row details
-- group by lose row details! by aggregating details

Generally GROUP BY for simple data analysis
WINDOW fn for more advanced data analysis */

--find the total sales across all orders
select
sum(sales) as [TotalSales]
from sales.orders

-- find total sales for each product
select productID,
sum(sales) as TotalSales
from sales.orders
group by productID

--find total sales for each product
-- and provide details such as order id & orderdate
-- WINDOW FN required!
select
ProductID,
OrderID,
OrderDate,
	SUM(sales) OVER(PARTITION BY(ProductID)) as TotalSalesByProducts
from sales.orders 
-- use Partition By within Over Clause to do group by in window fn
-- able to add as many columns as we want to provide extra details

/* Syntax Notes
Window Function: 
	Agrregate functions
		AVG/Sum/count/min etc..
	Rank Functions - covered later
		brackets usually empty
		only NTILE() exoresses number)
	Value/Analytical Functions - covered later
		accept any data types
	
	Can be empty for certain functions like RANK()
	Can be a column like AVG(Sales)
	Can be a number like NTEIL(2) covered later
	Or even multiple LEAD(Sales,2,10) covered later
	EVEN Conditional logic SUM(CASE WHEN SALES > 100 THEN 1 ELSE 0 END)
Over Clause - to tell sql we are dealing w/ Window Function
	Partition By: divdes the result into partitions
		if empty: OVER(), SQL use entire dataset to do calculations
		if OVER(PARTITION BY Product)
			divides dataset into product windows and does calculations for each
			Partition By Product is very similar to Group By Product

			can even do multiple e.g.
			Partion By Product, OrderStatus: splits data into combination
			of product and orderstatus
	
	Order By: To sort data within a window,
			Order By Sales Asc/Desc
			If RANK() function preceding, then SQL ranks the data within the window

	Frame: defines a subset of rows w/ each window that is relevant for calculation
		the subset of rows, is like a window within a window

		syntax: ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		CURRENT ROW: frame boundary lower value
		UNBOUNDED FOLLOWING: frame boundary higher value

		must use OrderBy to sort data in window if we want to use Frame Clause
		Lower boundary always come first.
		
		e.g. Sum(sales)
		OVER (ORDER BY Month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)
		lets us same sales for that row and next 2 months only. 
		calculation is 1 row at a time. 

		define boundaries of framme so that only the rows we want are included
		in calculation

		UNBOUNDED PRECEDING - from the first row 
		UNBOUNDED FOLLOWING - all the way to the last row of table
		N PRECEDING - how many rows preceding, for lower boundary
		N FOLLOWING how many rows following, for higher boundary
	*/

-- Partion By Practice: FInd the total sales across all orders and provide order details

select OrderID,
OrderDate,
Sales,
SUM(SALES) OVER () as TotalSales
from sales.orders
-- find total sales for each product, provide order details
select ProductID,
OrderID,
OrderDate,
Sales,
SUM(SALES) OVER (PARTITION BY ProductID) as TotalSales
from sales.orders

-- find total sales and total sales for each product, provide order details
select ProductID,
OrderID,
OrderDate,
Sales,
SUM(SALES) OVER () as TotalSales,
SUM(SALES) OVER (PARTITION BY ProductID) as TotalProductSales
from sales.orders -- provide sales w/ different granuality

-- find total sales afor each combination of product and orderstatus
-- and provide order details
select ProductID,
OrderID,
OrderDate,
OrderStatus,
Sales,
SUM(SALES) OVER (Partition By ProductID,OrderStatus) as [Orderstatus and prod sales]
from sales.orders

-- Order By and Rank Practice w/ windows
-- Rank each order based on their sales from highest to lowest
-- provide order details
select OrderID,
Orderdate,
Sales,
RANK() OVER(ORDER BY sales desc) as SalesRank
from sales.orders -- total sales, dont have divide data w/ partition by


-- FRAME Practice
select ProductID,
OrderID,
OrderDate,
OrderStatus,
Sales,
SUM(SALES) OVER (Partition By OrderStatus ORDER BY OrderDate
ROWS BETWEEN CURRENT ROW and 2 FOLLOWING) as TotalSales
from sales.orders
-- data in 2 windows, delivered and shipped,
-- ranked by their orderdate in window
-- calculation done of sales for current row and next 2 rows

-- WARNING!
-- IF YOU USE ORDER BY IN WINDOW WITHOUT SPECIFYING FRAME
-- THERE WILL BE A HIDDEN FRAME: THAT IS
	-- UNBOUNDED PRECEDING TO CURRENT ROW,. BE CAREFUL!!!


/* Window Function Rules and Limitation - 4 Rules
	1) Can only use window function OVER only in SELECT and Order By
		in select its the standard column: SUM(SALES) OVER () 

		in order by at end of query, to order data
		e.g. Order By Sum(Sales) OVER () Desc

		means cannot use Window functions to filter data
		WHERE SUM(Sales) Over () --> ERROR!
		Group By SUM(Sales) Over () ---> ERROR!
	
	2) cannot use window functions within window functions

	3) SQL executes window functions after WHERE clause filters data
	executed below */


-- Find Total Sales for Each Order Status, only for two products 101 and 102
select OrderStatus,
OrderID,
ProductID,
Sales,
SUM(Sales) OVER (Partition By OrderStatus) as TotalSales
from sales.orders
WHERE ProductID = 101 
OR ProductID = 102 -- better to use IN for a list of no. WHERE ProductID IN (101,102)

/* 4th Rule Window Functions
Allows to use Window Functions with Group By
 need to use aggregate column or Group by column within window function 
 for it to work */

-- Rank customers based on their total sales 
select CustomerID,
SUM(sales) OVER (Partition By CustomerID) as TotalSales
from sales.orders -- have obtained total sales, but now need to rank customers!

--wrong approach. need to use Group By for simple sales aggregation then rank/window

select CustomerID,
SUM(Sales) as TotalCustomerSales,
RANK() OVER(Order By SUM(Sales) desc) as [RANK] -- RANK ALWAYS NEEDS ORDER BY
from sales.orders
GROUP BY CustomerID -- with RANK must use OrderBy
-- able to do on own after Baraa said initial approach wrong

-- so analyse question, use group by first then use window functions
-- otherwise will need to use subqueries

