/* CASE Statements
Evaluates a list of conditions and returns 
a value when the first condition is met 

Syntax:
CASE- start of logic
WHEN-condition 1 to be evaluated
THEN- show result if condition1 is true
if condn1 fails, then goes to condition2below
then can do WHEN condn2 THEN result 2-- add more conditions

ELSE: default value that is output if all above conditions fail
	ELSE IS OPTIONAL!
END-end of logic */
-- IF MEETS FIRST CONDTION, THEN GET OUTPUT
	--OTHER CONDITIONS ARE NOT ACTIONED!

--NULL can get transformed by ELSE in CASE to get a string output

--CASE:FUNDAMENTAL FOR DATA ANALYSIS
--1)main use is for data transformation and derive new information
--create new columns based on existing data
--2) group the data into different categoriese based on certain conditions

--Query, Generate a report showing the total sales for each category
-- HIGH if sales >50, medium between 2 and 50, low if less than 20
--sort categories from highest sales to lowest
select OrderID,
Sales,
CASE 
	WHEN SALES > 50 THEN 'HIGH'
	WHEN SALES > 20 THEN 'MEDIUM'
	ELSE 'LOW'
END as [Category] -- label for column w/ END
from sales.orders
-- sale of 50 as medium, which matches query
-- first part done. now below we do sorting through subquery.

select
Category,
SUM(Sales) as [TotalSales]
FROM(
	select OrderID,
	Sales,
	CASE 
		WHEN SALES > 50 THEN 'HIGH'
		WHEN SALES > 20 THEN 'MEDIUM'
		ELSE 'LOW'
	END as [Category] -- label for column w/ END
	from sales.orders
)t
GROUP BY Category
ORDER BY TotalSales desc
-- solved w/subquery

--CASE outputs through THEN clause, must be matching data type for each condition
-- as well as the ELSE Clause too.

--CASE to MAP Vaules
--transofrm the values from one form to another
-- data stored frequently as 0/1 to optimise database performance
-- other forms like active/inactive is more readable
-- so use case to transform. 

--Retrieve employee details w/ gender displayed as full text
select EmployeeID,
FirstName,
LastName,
Gender,
CASE
WHEN Gender = 'M' THEN 'Male'
WHEN Gender = 'F' THEN 'Female'
ELSE 'N/A'
END as [Gender!]
from sales.employees

--retrieve customers details w/ abbreievated coutnry code
-- cant just look at output, need to obtain distinct list of country codes

select DISTINCT Country
from sales.customers;

select CustomerID,
FirstName,
LastName,
CASE
WHEN Country = 'Germany' THEN 'DE'
WHEN Country = 'USA' THEN 'US'
ELSE 'N/A'
END as [Abb Country]
from sales.customers

--quick form for CASE when only focusing on 1 column
/* CASE COUNTRY
WHEN 'Germany' Then 'DE'
WHEN 'INDIA' Then 'IN'
...
ELSE 'n/a'
END
lets us skip constantly writing country and = */

-- better to use full format. 

-- CASE and NULLs
-- query, find the avg score of customers and treat Nulls as 0

select customerID,
LastName,
Score,
CASE
	WHEN Score IS NULL THEN 0
	ELSE SCORE -- need to add, otherwise normal scores will be null
END as Cleanscore,
AVG(CASE
	WHEN Score IS NULL THEN 0
	ELSE SCORE -- need to add, otherwise normal scores will be null
END) OVER () Averagecustomer
from sales.customers

--Conditional Aggregations: 
--Apply aggregative functions (SUM/AVG) only on subsets of data that
--fullfil certain conditions

--Count how many times each customer has made an order w/ sales greater than 30
/* determine orders w/ sales greater than 30
use flag, then count it */

SELECT
OrderID,
customerID,
Sales,
CASE
	WHEN Sales > 30 THEN 1
	ELSE 0
	END SalesFlag
From Sales.orders
ORDER BY CustomerID --step 1

SELECT
customerID,
SUM(CASE
	WHEN Sales > 30 THEN 1
	ELSE 0
	END) HighSales, -- no. of orders above 30 for each customerID
Count(*) as TOTALORDERS -- separate to sum, gives total orders
From Sales.orders
GROUP BY customerID -- summarised flag, so now have achieved task
-- conditional aggregation with CASE statement achieved. 