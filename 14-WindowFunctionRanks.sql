/* Ranking Window Functions
Integer based Ranking 1/2/3/4/5. distinct discrete values, variable.
	Find Top 3 Products.
		Top/Bottom N Analysis
			ROW_NUMBER()
			RANK()
			DENSE_RANK()
			NTILE()
Percentage-based ranking 0-1. Continous/normal scale
	good for finding e.g. top 20% products
		Distribution Analysis
			CUME_DIST()
			PERCENT_RANK()

Syntax
RANK() -- expression must be empty, similar for all rank functions except NTILE(number)
	OVER ()
		(PARTITION BY OPTIONAL)
		(ORDER BY REQUIRED)
		(FRAME NOT ALLOWED) -- CANNOT CHANGE FRAME DEFINITION IN RANK FUNCTIONS!!!



ROW_NUMBER(): assign a unique no. to each row. ignores ties
	OrderBy control. Rank 1,2,3 ongoing for each row based on order by
	Each no. is unique. Duplicates have different sequential numbers.
	
	Ties are not handled. Given different no. */

--Rank the orders based on their sales from highest to lowest
Select 
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER () OVER (Order By Sales Desc) as [RANK]
from sales.orders

/* RANK (): assings a rank to each row
Handles ties by allowing sharing ranks. 
Have gaps in ranking due to duplicates. aka Rank 1,2,2,4,5 */

Select 
	OrderID,
	ProductID,
	Sales,
	RANK () OVER (Order By Sales Desc) as [RANK]
from sales.orders	

/* DENSE_RANK() Assigns a rank to each row
Handles duplicates by letting them share rank
But unlike RANK(), does not leave gaps in ranking */
Select 
	OrderID,
	ProductID,
	Sales,
	DENSE_RANK () OVER (Order By Sales Desc) as [RANK]
from sales.orders

--Find top highest sales for each product
select *
from(
select
	OrderID,
	ProductID,
	Sales,
	ROW_NUMBER() OVER (Partition By ProductID Order By Sales Desc) as Sales1
	from sales.orders
	)t
WHERE Sales1 = 1

--find the lowest 2 customers based on their total sales
-- read carefully what its asking for. total sales!!

select *
from (
select
CustomerID,
SUM(Sales) as TotalSales,
DENSE_RANK() OVER (Order By SUM(Sales) Asc) as Lowest_rank
from sales.orders
Group By CustomerID
)t
WHERE Lowest_rank IN (1,2)

-- Assign unique IDs to the rows of the 'Orders Archive' Table
-- that table does not have primary key. primary key needs to have no duplicates

select 
ROW_NUMBER() OVER (Order By OrderID, OrderDate asc) as UniqueID
from sales.ordersarchive --good idea to orderby both orderID and orderDate
-- created unique identifier

--identify duplicate rows in the table 'ordersarchive'
--and return a clean result without any duplicates. 
-- orderID should be unique, and creationtime represants last instance of orderupdate
Select
Row_Number() OVER (Partition By OrderID ORDER BY CreationTime Desc) as rn,
* -- partitiion by orderID, as we want to validate it.
--rn rank exceeds 1, show us primary key is not unique
-- our logic, last instance of creationtime most important, so rank 2/3 not needed
from sales.ordersarchive
--now use subquery

select *
from(
Select
Row_Number() OVER (Partition By OrderID ORDER BY CreationTime Desc) as rn,
*
from sales.ordersarchive)t
where rn = 1 --if wanted bad data could do, where rn > 1
 -- results have removed duplicates and generated unique orderID 1-7


/* NTILE() dives the rows into a specified no. of approx equal groups (buckets)
NTILE (n) - integer no. if NTILE(2), then 2 buckets.
SQL then puts the data sequentially into each bucket until the bucket is filled
if odd no, then larger bucket first. larger by 1 row

For Data Analysis: for data segmentation
	-divide dataset into distinct subsets based on certain criteria 

Segment all orders into 3 categories: high medium and low sales */
select *,
CASE 
WHEN BUCKETS = 1 THEN 'HIGH'
WHEN BUCKETS = 2 THEN 'MEDIUM'
WHEN BUCKETS = 3 THEN 'LOW'
END SalesSegment
from (
	select 
		OrderID,
		CustomerID,
		Sales,
		NTILE(3) OVER (Order By Sales Desc) Buckets
	from sales.orders
	)t

/* NTILE(n) For Data Engineer: For ETL and equalising load processing
moving a large table from database A to database B
very large, need to break up table with NTILE(n) then transfer
this doesn't stress the network
then merge table after with union */

--In order to export the data, divide orders into 2 groups
select *,
NTILE(2) OVER(Order By OrderID Asc) as Buckets
from sales.orders -- more clean to Order By the primary Key
-- probably better to have NTILE first column then * for rest of columns

/* Percentage % Based Rank functions
Continous Normalised Scale from 0 - 1 
Typically Order By Column Desc 
	
	CUME_DIST(): calculates distribution of data points within a window
	formula current row position/total no. of rows
		TIE RULE:
			if there is a tie, then shared rows 
			both take the lower! position and not current
	
	PERCENT_RANK(): calculates relative position of each row
	has -1 in formula: current row position - 1/total no. of rows - 1
		TIE RULE is DIFFERENT:
			USES FIRST OCCURENCE OF SAME VALUE

If want to focus on distribution of data points
	then use CUME_DIST()

If want to focus on relative position of each row
	then use PERCENT_RANK() */

-- find products that fall within highest 40% of prices
select *,
CONCAT(PercentPrice * 100, '%') as True
from (
select 
	Product,
	Price,
	CUME_DIST() OVER (Order By Price Desc) as PercentPrice
from sales.products
)t
Where PercentPrice <= 0.4
 -- subquery, then filter for 40%, then clean format