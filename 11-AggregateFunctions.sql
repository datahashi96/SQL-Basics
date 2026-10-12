/*
COUNT(*)
SUM() total
MAX() - highest value
MIN() - lowest value */

--FIND the total no. of customers
select 
COUNT(*)
from orders
-- 4.

--find the total sales of all orders
select SUM(sales) as TOTAL,
MAX(sales) as highest,
MIN(sales) as lowest
from orders
-- only add GROUP BY, if we want a breakdown, i.e total sales per customer or country or date
-- and whatever is in GROUP BY, needs to be put under select!

select Country,
Count(*), --total customers for that country
SUM(score), --total sum per country
AVG(score) --avg per country
from customers
GROUP BY Country
