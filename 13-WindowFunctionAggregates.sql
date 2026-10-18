-- WINDOW AGGREGATE FUNCTIONS

/* COUNT(): no of rows in each window
	Count(*): gives no. of rows, including NULLs.
	Count(column), no. of rows, but excludes NULL in column
	any data type allowed */


-- Find the total no. of orders
select count(*) as TotalOrders
from sales.orders --quick snapshot of entire dataset

--find total no. of orders and provide orderid and orderdate
select OrderID,
OrderDate,
count(*) OVER () as TotalOrders
from sales.orders

-- find total orders for each customers
select customerID,
Count(*) as totalcustomerorder
from sales.orders
group by customerID

-- find total orders for each customers w/ extra order details
select OrderID,
OrderDate,
CustomerID,
count(*) OVER (PARTITION BY CustomerID) as TotalCustomerOrders
from sales.orders

-- findtotal no. of customers and provide all customer details
select *,
COUNT(CustomerID) OVER() as TotalCustomers
from sales.customers
--find total no. of scores for the customers
select *,
Count(*) OVER () TotalCustomers,
COUNT(Score) OVER() as TOTALSCORE
from sales.customers -- only 4 scores, as we have a null in score column.
-- dont want to include the NULL so use count(column)
-- dataquality check, compare total customers to total scores w/ count
	-- diff of 1 show there is a NULL

/* DATA Quality Issue
Duplicates lead to inaccuracies in data analysis
COUNT() can be used to identify duplicates

Query: Check whether the table 'orders' contains any duplicate rows */
-- need to find primary key first, so check data model
--primary KEY: OrdersID. primarykey typically unique and has no duplicates
select OrderID,
COUNT(*) OVER (Partition By OrderID) as CheckPK -- primary key check
from sales.orders
-- result should be maximum 1. we have partitioned into windows for each
-- orderid, so if the count is more than 1, then we have a duplicate for orderID!
-- output of 1 for each, thus orderID is unique and no duplicates.

select OrderID,
COUNT(*) OVER (Partition By OrderID) as CheckPK -- primary key check
from sales.ordersarchive
--checkPK has outputs of 2 and 3,
-- our primarykey has duplicates. this is a problem!
-- lets isolate w/ subquery
select *
FROM (
	select OrderID,
		COUNT(*) OVER (Partition By OrderID) as CheckPK -- primary key check
	from sales.ordersarchive
	)t WHERE CHECKPK > 1
-- orderID 4 has output of 2, and orderID 6 has output of 6
-- they are duplicates and triplicates. 
--------------------------------------------------------
/* SUM: sum of all values within window
Ignores NULL
Only allows integers data type
*/
-- find total sales across all orders,
-- and total sales for each product
--provide details such as orderID, orderdate

select 
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER() as TotalSales,
	SUM(Sales) OVER(PARTITION BY ProductID) as TotalProductSales
from sales.orders

/* Comparison Analysis for Aggregate Functions
Compare current value to aggregated value of window functions
for example, compare March Sales to Total Sales
	or March to max month, or compare to avg(month)
part to whole analysis 

find the % contribution of each product sales to total sales */
select 
	OrderID,
	OrderDate,
	ProductID,
	SUM(Sales) OVER() as TotalSales,
	Sales/(SUM(Sales) OVER()) * 100, -- output of 0, datatype are integers
	CAST(Sales as Float)/(SUM(Sales) OVER()) * 100, --cast into float
	ROUND(CAST(Sales as Float)/(SUM(Sales) OVER()) * 100,2) --round to 2 decimals
from sales.orders 
-- need to make into float so can have decimals in %.

/* AVG(): avg of values within window
NULLs ignored
For business purposes, for accurate average, need to handle NULLs
before aggregation -- thus coalesce! 

TASK:
Find average sales across all orders, avg sales for each product
and provide details */

Select
OrderID,
OrderDate,
Sales,
ProductID,
AVG(SALES) OVER () as SalesAvg,
AVG(Sales) OVER(PARTITION BY ProductID) as ProductAvgotal
from sales.orders

-- find the avg scores of customers
-- provide details such as customerID and lastname
select CustomerID,
LastName,
Score,
AVG(COALESCE(Score,0)) OVER() as AvgScore --null turned into zero, then column avg'd
from sales.customers

-- find all orders where sales are higher than the avg sales across all orders
select *
From(
Select
	OrderID,
	ProductID,
	Sales,
	AVG(Sales) OVER() AvgSales
from sales.orders
)t WHERE Sales > AvgSales
 -- did everything in subquery first, then in main query did window function
 -- did this as cannot use window functions in where clause. 


 /* MIN/MAX Functions: returns lowest or max value within a window
 Ignores NULLs obviously. use coalesce to turn into 0 for business purposes

 find highest lowest sales across all orders
 highest sales for eahc product
 provide order ID and orderdate */

 select
	 OrderID,
	 OrderDate,
	 ProductID,
	 Sales,
	 MIN(Sales) OVER() as SalesMin,
	 MAX(Sales) OVER() as SalesMax,
	 MIN(Sales) OVER(PARTITION BY ProductID) as SalesProductMIN,
	 MAX(Sales) OVER(PARTITION BY ProductID) as SalesProductMAX
 from sales.orders

 --show the employees who have the highest salaries
 select *
 FROM
 (select *,
 MAX(Salary) OVER () as EmployeeMax
 from sales.employees)t
 WHERE Salary = EmployeeMax

 --find the deviaition of each sales from min and max sales amount
  select
	 OrderID,
	 OrderDate,
	 ProductID,
	 Sales,
	 MIN(Sales) OVER() as SalesMin,
	 MAX(Sales) OVER() as SalesMax,
	 Sales - MIN(Sales) OVER() as MinDeviation, --compare to extremes!
	 MAX(Sales) OVER() - Sales as MaxDeviation	--compare to extremes!
 from sales.orders

 /* Running Total: aggregates all values from the beginning up to the current
 without droppping off older data
 
 Rolling Total: Aggregates all values within a fixed time window
	 as new data is added, the oldest data point is dropped


Running Total Syntax: SUM(Sales) OVER (Order By MONTH)
-- remember this has a default frame
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- generates the running total

Rolling Total
SUM(Sales) OVER (ORDER BY MONTH
and specify frame: ROWS BETWEEN 2 PRECDING AND CURRENT ROW)
-- DIFFERENCE WITH ROLLING IS THE FRAME CLAUSE IS SPECIFIED!!!!!!!! */

--Calculate the moving average of sales for each product over time
 