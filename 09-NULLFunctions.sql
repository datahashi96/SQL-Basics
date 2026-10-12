--SQL Queries

--Find the average score of customers
Select customerID,
Score
From sales.customers --last value has null

Select customerID,
Score,
avg(score) OVER() avgScores -- 4 values average, NULL not included
From sales.customers -- OVER function let us see aggregate without deleting


Select customerID,
Score,
AVG(Score) OVER() AvgScores,-- average and NULL completely ignored
AVG(COALESCE(Score,0)) OVER () AvgScores_2-- NULL dealt with, then average determined
From sales.customers
-- transformed Null, then averaged it!
--use function within function
--if want to clean a value before aggregating, the CLEANING FUNCTION
--MUST GO INSIDE THE AGGREGATE FUNCTION!

--NULL and mathematical operators
--NULL + 5 = NULL, this is a problem
--Unknown + 5 is still Unknown!!
-- need to transform NULLs.

--Query: Display the full name of customers in a single field by merging the first and last names and add 10 bonus points to each customer’s score. 
SELECT CustomerID,
FirstName,
LastName,
Score,
FirstName + ' ' + LastName AS FullName --problem Mary + NULL = NULL!!
From sales.customers

SELECT CustomerID,
FirstName,
LastName,
Score,
COALESCE(LastName,'') AS LastName2, -- no space in between, an empty string
FirstName + '' + LastName AS FullName --problem Mary + NULL = NULL!!
From sales.customers  --when execute, empty string created instead of NULL

--Now concatenate

SELECT CustomerID,
FirstName,
LastName,
Score,
FirstName + ' '+ COALESCE(LastName, '') AS FullName,
Score + 10 -- last row has a NULL, we need to fix it. 
From sales.customers

SELECT CustomerID,
FirstName,
LastName,
Score,
FirstName + '' + COALESCE(LastName, '') AS FullName,
COALESCE(Score,0) + 10 AS BonusScore --fixed!
From sales.customers

--Joins + NULL. 
--need to eliminate NULLs in keys before joining tables, otherwise can leading to missing data
--use ISNULL or COALESCE within the join

/*Query
Select
A.year, a.type, a.orders, b. Sales
FROM Table 1 as A
JOIN Table 2 as B
ON a.year = b. Year
AND ISNULL (a.type, ‘ ‘) = ISNULL(b.type, ‘ ‘) – key, the NULL is dealt within the JOIN, but 
The NULL still present in SELECT, so when join complete, NULL still appears correctly in the combined table.
– in the Join, its an empty string, so tables are able to be matched correctly.
– in output, select was original data, so NULL maintained - not an empty string */


--NULL and Sorting Data w/ Order By
--Query: Sort the customers from lowest to highest score with NULLs appearing last
Select CustomerID,
Score
From sales.customers
ORDER BY COALESCE(Score, 99999) asc -- my attempt, not right

--Lazy way, replace NULL w/ very large no. :
Select CustomerID,
Score,
COALESCE(Score, 99999999)
From sales.customers
ORDER BY COALESCE(Score,99999999)
--job done, but not professional. NULL isnt shown 

--BEST WAY
SELECT CustomerID,
Score,
CASE WHEN Score IS NULL THEN 1 Else 0 END FLAG 
From sales.customers
ORDER BY CASE WHEN Score IS NULL THEN 1 Else 0 END, Score
--SQL sorts by flag first, so NULL is at bottom, then SQL sorts by score

SELECT CustomerID,
Score
From sales.customers --dont need flag w/ Select. 
ORDER BY CASE WHEN Score IS NULL THEN 1 Else 0 END, Score -- asc default
-- SQL sorts by flag first, so NULL is at bottom, then SQL sorts by score
-------------------------
/* NULLIF, compares two expressurs:
NULL output if two values are equal
And First Value if not equal
Syntax: NULLIF(value1,value2) - can have column or static value
Useful as NULL can be a flag for when things are equal between our data
E.g. if original and discount price are the same, then output will be NULL and we notice it. 
NULLIF also prevents the error of diving by zeroexample*/

--Query: Finds the sales price for each order by dividing the sales by the quantity
Select OrderID,
Sales, 
Quantity --Quantity for OrderID 10 is 0!!!
From Sales.Orders
 
Select OrderID,
Sales, 
Quantity,
Sales/Quantity AS PRICE -- Divide by zero error encountered as Quantity has a zero!
From Sales.Orders 

Select OrderID,
Sales, 
Quantity,
Sales/NULLIF(Quantity, 0) AS PRICE 
from sales.orders
--for OrderID 10, quantity = 0 which is the same as value specified in NULLIF, so output is NULL. dividing by NULL gives a NULL OUTPUT!

/*
ISNULL =output is true if value is NULL, output is FALSE if value something else
ISNOTNULL =output is true if value is NOT NULL, output is FALSE if value is NULL
Syntax Value IS NULL, Value IS NOT NULL
– very useful as it lets us search for NULLs. If present, then we clean our data by dealing with the NULLs

Query, Identify the customers who have no scores. Only want to see customers w/ no scores. */
Select *
From sales.customers
WHERE Score IS NULL -- no equal sign. That is enough. 

--Query: list customer who have scores
Select *
From sales.customers
WHERE Score IS NOT NULL

--Left Anti Joins – all rows from left w/o matching rows. 
--Use LEFTJOIN + IS NULL (WHERE)


--Query: List all details for customers who have not placed any orders
Select *
From sales.customers as c;
Select *
From sales.orders as o;

Select *
From sales.customers as c --left table
LEFT JOIN sales.orders as o --right table
ON  c.customerid = o.customerID

Select c.*,  --shows all columns from customers,
o.orderID
From sales.customers as c --;left table
LEFT JOIN sales.orders as o --right table
ON  c.customerid = o.customerID --output shows customer ID 1,2,3 with multiple orders and customer ID 4 with 1. customerID 5 is NULL. so customer ID 5 did not place an order. 

Select c.*, -- shows all columns from customers,
o.OrderID
From sales.customers as c -- left table
LEFT JOIN sales.orders as o -- right table
ON  c.customerid = o.customerID
WHERE o.customerID IS NULL -- correct, use key from join. Make sure it matches what we want!


/*NULLs = unknown, Empty Strings = string value that has zero characters – known with an empty value
Empty Spaces = string value that has 1 or more space characters. 
Known with space value
– makes it hard to tell data quality issues
– need to determine length of string to determine whether it is an empty string or an empty space
– clause DATALENGTH(nameofcolumn), if output 0 then empty string. If more than zero an empty space. If NULL then NULL
–empty string and blank space, they take memory. NULL has best performance. 
To find NULL use IS NULL
To find empty string = ‘’ no space between apostrophes
To find empty space = ‘   ‘ matching no. of spaces. 

Data Policies : set of rules that defines how data should be handled

Only use NULLs and empty strings, but avoid blank spaces (AVOID)
To remove leading/trailing spaces use function TRIM()
TRIM(Category) AS Policy1. Use datalength to be confident that trim has worked
OR
Only use NULLs and avoid both empty strings and blank spaces (Consider, less storage and queries will be quick) - optimised storage and performance
Transform empty strings and trim blank spaces
TRIM(Category) Step 1 – empty spaces dealt with
Step 1 + 2: Then NULLIF(TRIM(Category), ‘’) – empty string turned into NULL

OR,  use default value ‘unknown’ and avoid using nulls, empty strings and blank spaces Consider for data preparation before using in report. IMPROVES READABILITY AND REDUCES CONFUSION!
COALESCE(NULLIF(TRIM(Category),’’), ‘unknown’) - Step 1,2,3 combined
Could also use ISNULL */
