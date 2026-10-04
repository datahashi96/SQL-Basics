--Set Operators
-- Purpose: to combine rows. Joins done previously are for columns
/*
select FirstName,
LastName
from sales.customers
join ...                can make a complicated query
where ...
group ... 
UNION					combine rows. however no. of columns of query above below must be same
select FirstName,
LastName
from sales.employees
join...					complicated query
where ... 

order by FirstName		used at end, only once. */

select FirstName,
LastName -- 2 columns
from sales.customers
UNION -- combines all distinct rows from both queries
select FirstName,
LastName -- 2 columns. order of columns is the same
from sales.employees
-- data types of columns need to be compatible
-- use object explorer to left, open up columns of each table and ensure they match to 
-- corresponding column in second table.
-- e.g. for above they are both varchar
-- name of columns for results is based off first select query and names of its columns
-- if want to give alias through AS clause - do it on first query so it shows in results


-- Union: combines all distinct rows from both queries
-- this means it removes all duplicate rows from results. 1 of each.

--combine the data of employees and customers into one table
select FirstName,
LastName
from sales.customers
UNION -- so only getting 1 unique result, those w/ same names removed
select FirstName,
LastName
from sales.employees --- doesnt makek sense to include customerID and employeeID - NOT THE SAME

-- UNION ALL. combines all rows, so there may duplicates or triplicates
-- union all is a lot faster than union
-- so if i know there is no duplicates, use union all as you will get better performance4

-- EXCEPT, similar to antijoin in a way
-- EXCEPT: returns all rows in first query that are not found in second query

-- find employees who are not customers at the same time
select FirstName,
LastName
from sales.employees
EXCEPT
select FirstName,
LastName
from sales.customers -- kevin and mary in query 1 excluded as they are in table 2.

-- INTERSECT: returns rows common in both queries
select FirstName,
LastName
from sales.employees
INTERSECT
select FirstName,
LastName
from sales.customers

/* USING set operators
1) Combining similar information before analysing data

TASK: 
Orders are stored in separate tables (orders and ordersarchive), combine all
orders into one report without duplicates */

select OrderDate,
ShipDate,
Quantity,
Sales
from sales.orders

UNION

select OrderDate,
ShipDate,
Quantity,
Sales
from sales.ordersarchive
-- problem. what i did was correct, but i didnt check data type of column and whether all 
-- columns in both tables were the same, which they are. i could have combined all columns.

-- also, can create column to tell us where data comes from
-- under select write: 'name of source' as Source Table, see below. dontforget comma

select 'Orders' As SourceTable,
OrderDate,
ShipDate,
Quantity,
Sales
from sales.orders

UNION

select 'Orders.Archive' As SourceTable,
OrderDate,
ShipDate,
Quantity,
Sales
from sales.ordersarchive

/* for data engineering, except is very useful
if you have source data that you need to add to warehouse each day
then you only want to add the new data from the source and not redundant data 
already in warehouse.

so if source is table 1, and warehouse is table 2
combine tables with except, that lets new information be added, which is table1 and moved 
into warheouse

also can use except to check for data completeness
when moving data from 1 database to another, want to ensure no data is missing
use except, ensure difference is empty
need to make sure to do it both ways to ensure no new data is in database 2 thats not in database 1