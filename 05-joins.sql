-- 05 Joins
-- Combing columns of tables, 4 types, inner, full, left, right
-- when combining, determine combine rows (set operator) or columns (joins)

-- find column that exists on both tables left/right so SQL can connect information in query
-- 1. recombine data: combine tables so SQL can see big picture and query it
-- 2. enrich data: with information from second table
-- 3. filtering data: can also filter data based off second table, look up table

-- when combining tables, 3 situations, imagine venn diagram, 
--matching data intersection only, data from 1 circle entirely, or unmatching data

--  No Join - when there is no matching data
--	returns data from table w/o combining them
-- 2 queries below
select * 
from customers;
select * 
from orders;

-- Inner Joins - return only matching rows from both tables
select *
from customers 
inner join orders -- if write just join only, defaults to inner. best to specify type
on id = customer_id --key from table a = key from table b

-- issue is so many columns created, with redundant information, rewrite query with only columns i want
select id,
first_name,
order_id,
sales
from customers
inner join orders
on id = customer_id
-- sometimes tables have can same name for columns. in that case sql
-- won't know where data comes from. to make it easier for sql, can we specify
-- which table the column came from under selecct. see below

select customers.id,
customers.first_name, -- specified each table column is from. remember comma
orders.order_id,
orders.sales
from customers
inner join orders
on customers.id = orders.customer_id -- can even do the same for the JOIN condition

-- rewriting what table is can be long, can assign aliases for table. see below
select c.id,
c.first_name, -- specified each table column is from. remember comma
o.order_id,
o.sales
from customers as c -- alias assigned for customers
inner join orders as o -- alias assigned for orders
on c.id = o.customer_id	 -- can include alias on Join condition
-- inner join: recombines and filters data

-- LEFT JOIN. includes all rows from left table and in addition matching rows from right table
-- similar syntax: 
select c.id,
c. first_name,
o.order_id,
o.sales
from customers as c -- LEFT TABLE IN FROM CLAUSE. everything in rows included
left join orders as o -- RIGHT TABLE IN JOIN CLAUSE. ONLY MATCHING DATA INCLUDED, no matches are null
on id = customer_id

-- DO NOT FORGET, FROM CLAUSE --- LEFT TABLE, JOIN CLAUSE RIGHT TABLE!!!!!!
-- left join for recombining data, data enrichment and 

-- Right join, all rows from right and only matching from left
select c.id,
c.first_name,
o.order_id,
o.sales
from orders as o -- LEFT TABLE
right join customers as c -- RIGHT TABLE
on customer_id = id -- SAME OUTPUT

-- get all orders including orders w/ no customers. 
select c.id,
c.first_name,
o.order_id,
o.order_date,
o.sales
from customers as c -- left table. as right join, only matching customers w/ orders
right join orders as o -- right table. right join includes all orders - and the one w/o cust.
on id = customer_id 

-- lets do above task with left join. so set all orders as left table. 
select c.id,
c.first_name,
o.order_id,
o.order_date,
o.sales
from orders as o
left join customers as c
on id = customer_id 

--- full join. combine entire a and b tables. 
select c.id,
c.first_name,
o.order_id,
o.order_date
from customers as c
full join orders as o
on c.id = o.customer_id

-- now AntiJoins, return rows from A that do not have a match w/ B\
-- no special clause on sql for this, need to use left join then filter with where
-- so: where right table key is NULL. CANNOT USE EQUALS SIGN AS NULL IS UNKNOWN
-- that gives me true antijoin, as there isnt a match.

select *
from customers;
select *
from orders;

select c.id,
c.first_name,
o.order_id,
o.order_date
from customers as c
left join orders as o
on c.id = o.customer_id
where o.customer_id is NULL -- this is antijoin done correctly.

-- antijoin useful as it helps with checking for/filtering for non-existence

-- right antijoin, will never use but to ensure i know:
select *
from customers as c
right join orders as o
on c.id = o.customer_id
where c.id IS NULL -- key for right antijoin is LEFT.tablekey IS NULL
-- above query gives me all orders w/o matching customers

select * 
from orders as o
left join customers as c
on o.customer_id = c.id
where c.id IS NULL -- doing same task as above but using left join for completeness

-- now FULL antijoin, so basically full join with matching data removed
select * 
from orders as o
full join customers as c
on o.customer_id = c.id
where o.customer_id IS NULL
or c.id IS NULL --- have two conditions that we want either one. use OR clause, do not use AND!


-- challeng q: get all customers along w/ their orders but only for customers
-- who have placed an orders. not allowed to use inner join

select * 
from customers as c
left join orders as o
on c.id = o.customer_id
where not o.customer_id is NULL -- this was my attempt. answer is below. 

select * 
from customers as c
left join orders as o
on c.id = o.customer_id
where o.customer_id is not NULL -- i was close enough lol. can control what we want
-- to see with joins. 

-- Cross Joins. to combine every row from left w/ every row from right.
-- this lets us see all combinations possible. w/ cross joins - dont care about matching data
-- if row A has 2 rows, and B has 3 rows, then 4
-- total rows of cross join will be multiplication = 6

select *
from customers
cross join orders -- don't care about matching so no ON condition
-- this generates all possible combinations of customers and orders

-- Multiple Table Join
-- select * 
-- from a
-- left join b on 
-- left join c on 
-- then to control what i want to see at the end, e.g. if i want to a different join
-- for a particular table -- then use where clause

-- q: using salesdb, retrieve a list of all orders along w/ related  customer,
-- product, employee details
-- for each order, display order ID, customer_name, product name, sales amount,
-- product price and salesperson name

select 
o.orderID,
c.firstname,
c.lastname,
o.sales,
p.product,
p.price,
e.FirstName as Sellname
from sales.orders as o
left join sales.customers as c
on o.customerID = c.customerID
left join sales.products as p
on o.productid = p.productid
left join sales.employees as e
on o.SalesPersonID = e.employeeID
-- did above on my own without watching video
-- would compare main table orders to 1st matching table, find name of columns than use left join
-- keep doing that sequentially. determine what columns are keys for each left join
-- be careful as some columns have same name, need to relabel w/ as
-- i manually changed database at top of SSMS, Baraa instead does use clause to change database

