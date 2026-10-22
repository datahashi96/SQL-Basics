/* VALUE WINDOW FUNCTIONS
let you obtain values from other row, and present on same row
so that they can be compared

LAG() - previous
LEAD() following
FIRST_VALUE() - obtains first value
LAST_VALUE() - obtains last value
requires order by to sort data

Syntax
	Expression - any data type
	Partition - optional
	Order By - REQUIRED
	Frame
		Lead/Lag - NOT ALLOWED!
		First/Last_value: optional to design frame
			Recommended for last value 

Lead/Lag Expression Syntax
	LEAD(Sales, 2, 10)
		Expression (sales), any data type
		Offset - no. of rows forward (or back for LAG( )) from current row
			its optional, default is 1
		Default value, specifies what to return if next/previous row not available
			optional. if not specified then get NULL */

-- Analyse the month-over-month (MoM) performance by finding the percentage
--change in sales between the current and previous month
--THINK CRITICALLY, need to calculate total sales column, then order by month
-- and use lag
-- orderdate is in days --- need month information

select
	MONTH(OrderDate) OrderMonth, -- need month information only, not date
	SUM(Sales) CurrentMonthSales,
	LAG(SUM(Sales)) OVER (Order by MONTH(OrderDate)) PrevMonthSales
from sales.orders
Group By 
	MONTH(OrderDate)  -- need group by, as window function to do lag analysis
	-- then to find % change, need subquery and subtract sales 

select *,
CurrentMonthSales - PrevMonthSales as MoMchange,
ROUND(CAST((CurrentMonthSales - PrevMonthSales) AS FLOAT)/PrevMonthSales * 100, 1)  [%change]-- percet change
from ( -- need to use CAST to make interger
select
	MONTH(OrderDate) OrderMonth, -- need month information only, not date
	SUM(Sales) CurrentMonthSales,
	LAG(SUM(Sales)) OVER (Order by MONTH(OrderDate)) PrevMonthSales
from sales.orders
Group By 
	MONTH(OrderDate)
	)t --okay, example of MoM analysis!

-- Customer Retention Analysis
-- Analyse customer loyalty by ranking customers based on the average no.
-- of days between orders.
-- key is to recognise we need to order the data by orderate and customer ID

select CustomerID,
RANK () OVER (Order By AVG(Daygap)) as FinalRank
from(
select 
OrderID,
CustomerID,
OrderDate,
LAG(OrderDate) OVER(Partition By CustomerID Order By OrderDate) as PreviousOrder,
DATEDIFF(DAY,LAG(OrderDate) OVER(Partition By CustomerID Order By OrderDate),OrderDate) as Daygap
from sales.orders
)t
GROUP BY CustomerID
-- customer 4, only 1 order, so techinically 0 days between orders
-- if want can treat differently just need to deal with NULL

/*
First Value lets you access first row within window
Last Vlaue lets you access last row within window
Need to specify Row Expression
Both have default frame from unbounded preceding to CURRENT ROW!
	Works fine For First Value
	But for last value, get repeated current row
		So need to change default frame to CURRENT ROW AND UNBOUNDED FOLLOWING
		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
*/

-- Find the lowest and highest sales for each product
select 
OrderID,
ProductID,
Sales,
First_Value(Sales) OVER (Partition BY ProductID Order By Sales) as Lowest,
Last_Value(Sales) OVER (Partition By ProductID Order By Sales 
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as Highest
from sales.orders
-- more efficient to use First_value and order by desc
-- to obtain highest rather than use Last_value and having to specify frame
-- heck even could use min/max and partition by productID - even easier!

/* Value Function Use Cases
	1. Timeseries analysis: MoM or YoY analysis
		month over month, year over year
	2. Timegaps Analysis: Customer Retention
		Average days between two orders
	3. COmparison Analysis:compare current to extreme(highest/lowest sales)