-- Comparison Operators
-- retrieve all customers from germanya
 select * 
 from customers
where country = 'Germany'
-- other operators !=, >, < and >=,  <=

-- Logical operators
-- AND = all condiitions must be true, OR = at least 1 condition true
-- NOT = excludes rows that met that condition, not comes after where
-- example. e.g. retrieve all customers from USA and score > 500

select *
from customers
where country = 'USA' AND score > 500
select *
from customers
where not country = 'USA'

-- BETWEEN/RANGE operator, to check if value is witihn range
-- boundaries are inclusive
-- retrieve customers with scores between 100 and 500
select *
from customers
where score between 100 and 500

-- MEMBERSHIP operator in/not in, to check if value included in list
select *
from customers 
where country IN ('Germany', 'USA')

-- LIKE/Search Operator, to search for pattern in text
-- M%	saying the first character must be letter M = so Maria fulfills pattern
--		the % means the second character can be any character or nothing
--		Maria, Ma, M, meet requirement. Emma does not.
-- %in  means last two characters must be in, Martin, Vin and in matches pattern
-- %r%  anything that has r, Maria, Peter, Ryan all match.
-- __b% means char1, char2, LETTER B, anything

-- find all cust name starts w/ letter m
select *
from customers
where first_name like '__r%'