-- 07 SQL Functions Intro - for data analysis, manipulation, cleaning and transformation
/* two categories 1. single row functions - 1 value in and 1 value out and
2. multirow function - summarises row and gives 1 output

Multiple functions can be used together
'Maria' --> Left(2) --> 'Ma' output --> Lower() --> 'ma'
Syntax will be like algebra/bodmas, first functione executed is one in parenthesis
above exmaple Len(lower((left('maria',2)))

Single functions include string, numeric, date/time, null
-- single row typically used to prepare and manipulate for later mutltirow functions
-- used by data engineers
Multirow functions include aggregate and window
-- used by data analysts */

/* String Functions, either manipulation/calculation/string extraction*/
--concat/upper/lower/trim/replace
---------------------------------------------------------------------------------------
-- DATA Manipulation with clause CONCAT
-- Combines multiple strings into one
--e.g. have two columns with first name and last name - combine with concat so have
-- 1 column with first last name

--q. concatenate firstname and country into one column
select first_name,
country,
concat (first_name, country) as name_country -- comma at end of column for new function clause
from customers -- issue is output doesnt have space between name and country so do below:

select first_name,
country,
concat (first_name,' ',country) as name_country -- added space in ' ' and concatenated the 3
from customers -- could use dash or . instead of space

-- UPPER and LOWER, turn values into upper or lower case respectively
-- convert the first name to lower case:
select first_name,
LOWER (first_name)
from customers 

-- TRIM function: removes leading and trailing spaces
-- spaces like '   John' or 'John   '  or '    John   '
-- find customers whose first name contains leading or trailing spaces 

select first_name,
trim (first_name)
from customers  -- this trims it, but doesn't tell me customers whose first name has those spaces

--so:
select first_name
from customers
where first_name != TRIM(first_name) ---answer is John to double check:

select first_name,
len(first_name)
from customers -- John which is 4 letters has a length of 5 characters. leading space of 1

-- now lets trim first name, then check length
select first_name,
len(trim(first_name))
from customers -- now John is 4 characters

-- easiest way to detect white spaces is use where and trim


--Replace, replace  a specific character with a new character
--can also be used to remove if not specifiying a replacement character

select '123-456-789' AS PHONE, -- a static value
replace ('123-456-789', '-', '') as clean_phone
--syntax above replace ('value', 'what we want to replace', 'new character or empty to remove')
 
 -- replace file type from txt to csv
 select 'report.txt',
 replace ('replace.txt','.txt','.csv')
 ------------------------------------------------------------------------
 -- DATA CALCULATIOn with len - counts no. of characters
 -- can be used for any data type even date. will give no. of characters

 select first_name,
 len(first_name)
 from customers
 ---------------------------------------------------------------------------
 --STRING extraction with left and right and substring
 -- left extracts specific no. of characters from the start
 -- right extracts specific no. of characters from the end
 -- syntax left(value, no. of characters)

 -- retrieve first two characters of each first name
 select first_name,
 left(first_name,2) as First_2 -- syntax left(column,no.of characters)
 from customers
 -- if we want to fix John, then apply it, as John has a leading space.

 select first_name,
 left(trim(first_name),2) as First_2,
 right(first_name,2) as Last_2
 from customers
 
 --Substirng: extracts a part of string at a specified position
 --syntax (value, no. position of charcater start, length)
 --ex: after the 2nd character, extract 2 characters. so for Maria - start from R
 -- if you wanted to extract everything after the start character, need dynamic length
 ----- need to use len() as it will let you get all characters after the start.
 ------- function within function

 -- retrieve a list of customers first names after removing the first character
 select first_name,
 SUBSTRING(first_name,2,len(first_name)) -- len() finds length of entire name, which is max 
 --which is going to be more than the first_name after a character is missing
 from customers

 ----------------------------------------------------------------------------
 -- NUMBER FUNCTIONS
 -- Round 1, rounds to 1 decimal. round2 - rounds to 2 decimalplaces etc..
 -- round 0 - rounds to nearest 1, so no decimal place
 -- syntax round (value, no. of decimal places)
 select 3.516,
 round (3.516, 2) as round_2, -- dont forget _ when alias
 round (3.516, 1) as round_1,
 round (3.516, 0) as round_0
 5.21
 -- ABS, converts negative interger into positive, aka magnitude
 select -10,
 abs (-10)
 -- useful to fix mistakes in data, aka a sale cant be negative so turn it into positive
 ------------------
 -- DATE & TIME FUNCTIONS (date: year/month/day) (time hr/min/secs) --> both high to low order
 --if both combined becomes timestamp (date/time)
 --in SQL server called datetime not timestamp
 select OrderID, 
 OrderDate, --date information
 '2025-08-20', --hardcoded dates
 ShipDate,
 CreationTime, --datetime information
 GETDATE() Today -- time given is the time when query activated
 from sales.orders

 --GETDATE() function: returns current date/time when query executed
 /* overall 3 sources of date information, either column data, or hardcoded '2025' or through
 GETDATE()*/
 
 --- Manipulating Date information
 --		extracting year/month or day (part extracting clauses)
 --		altering format (format and casting clauses)
 --		calculatings - add or subtracting time (dateadd and datediff)
 --		validating date if sql understands it, aka is it a real date? (ISDATE)

 --PART Extraction
 --DAY date) extracts day, MONTH(date) extracts month, YEAR(date) extracts year from date
 --DATEPART 
 -- both function types give us integers
select OrderDate,
creationTime,
MONTH(creationtime) as MONTH -- can do for year/month/day
from sales.orders

--DATEPART, lets us extract what quarter/week/hour or even year and month
--syntax (part,date)
select OrderDate,
creationTime,
DATEPART(year,creationtime) year_dp,
DATEPART(week,creationtime) week_dp,
DATEPART(hour,creationtime) hour_dp,
DATEPART(day,creationtime) day_dp,
DATEPART(quarter,creationtime) quarter_dp 
from sales.orders --datepart lets us extract more data than year/month/day functions

--DATENAME(), returns name of date part useful for month or name of day - wednesday
--- DATENAME() OUTPUT ARE STRINGS NOT INTERGERS!
select OrderDate,
creationTime,
DATENAME (month,creationtime) as month_dp, -- output is a string, not an integer
DATENAME (weekday,creationtime) as weekday_dp -- HAS TO BE WEEKDAY, NOT DAY!!!
DATENAME (weekday,creationtime) as weekday_dp -- if we use day, no. output but its a string!!!
from sales.orders

--DATETRUNC: truncate date to level of information we want, has same structure
-- for example, remove day or time
--datetrunc(minute,value) - keeps info from year to minute, seconds beyond that reset
-- not really removing, rather resets!!
select OrderDate,
creationtime,
DATETRUNC (month,creationtime) as month_dp, -- days reset to 1, mins/sec/hours set to 0
DATETRUNC (year,creationtime) as year_dp, -- only year information remained.
DATETRUNC (day,creationtime) as yday_dp
from sales.orders

--advantage of DATETRUNC
--lets us count no. of orders by resetting to day/month that we want, otherwise
-- as the datetime information is very precise - each order is discrete

select creationtime,
count (creationtime)
from sales.orders
group by creationtime -- forgot this!, groupby lets us combine rows with same specified value,
-- combine through function applied to column
-- because datetime column is very precise, each value is distinct -- cannot be grouped.
-- therefore by truncating, we can make it less precise and group based off our need.
-- so if we want all orders in a month then:

select
DATETRUNC(month,creationtime),
count(*) as total
from sales.orders
group by DATETRUNC(month,creationtime) -- successfully reset to nearest month, 
-- which lets us count orders in that month

--now order by year
select
DATETRUNC(year,creationtime),
count(*) as total
from sales.orders
group by DATETRUNC(year,creationtime) -- successfully reset to nearest month, 
-- which lets us count orders in that 

-- EOMONTH, end of month
--funciton is to change the day of month to the last day either 30/31 or 28 in Feb
--e.g. 2025/08/26 --> 2025/08/31
-- syntax EOMONTH(date)

select creationtime,
eomonth(creationtime) AS ENDOFMONTH
from sales.orders
-- if you wanted firstofmonth need to use datetrunc
select creationtime,
eomonth(creationtime) AS ENDOFMONTH,
datetrunc(month,creationtime) AS startmonth 
-- datetrunc resetting to month, so 1st day = start of month
from sales.orders

--how many orders were placed each year

select datetrunc(year,creationtime), -- answer is right but also could use year function
count(*)
from sales.orders
group by datetrunc(year,creationtime)

-- how many orders each month
select datetrunc(month,creationtime),
count(*) as month_orders
from sales.orders
group by datetrunc(month,creationtime)
order by datetrunc(month,creationtime) asc

select month(OrderDate),-- alternative answer with month function
count(*)
from sales.orders
group by month(orderdate)  --> but better to have cleaner output so use datename:
select datename(month,orderdate),-- alternative answer with month function
count(*)
from sales.orders
group by datename(month,orderdate)

-- show all orders placed during month of february
select datename(month,Orderdate),
orderstatus
from sales.orders
where datename(month,Orderdate) = 'February' 
/* DATENAME IS A LOT MORE SLOW AND INEFFICIENT COMPARED TO SEARCHING FOR AN INTEGER
THEREFORE BETTER TO USE YEAR/MONTH/DAY FUNCTIONS OR DATETRUNC */

select *
from sales.orders
where month(orderdate) = 2 -- cleaner/faster way to find orders in February

/* day/month/year/datepart - outputs are integers
datename - output string
EOMONTH - OUTPUT IS DATE
DATETRUNC output is DATETIME 

now, how to know which date/time function to use?
	which part to extract?
		if day or month->
			do we want integer? then day,month
			or if we want full name as string then use datename()
		if year->
			year()
		if want other parts of date ->
			datepart - week or quarter

PART EXTRACTION COMPLETE*/

--FORMAT & CASTING:
--------------------------------------
/* DATETIME FORMAT 2025-08-20  18:55:45
DATE FORMAT		   YYYY-MM-dd  HH:mm:ss   MM is month, little mm is minutes
	SQL uses the above datetime formart which is the international standard

FORMAT: changing the formart of a value from 1 format to another*/
--syntax FORMAT(value,format, {culture - optional to add}) culture - a region's particular style
select OrderDate,
format(OrderDate, 'dd/MM/yyyy') -- uses default culture en-US
from sales.orders;

select OrderDate, -- example, w/ culture, not used often. 
format(OrderDate, 'dd/MM/yyyy', 'ja-JP')
from sales.orders

select CreationTime,
format(CreationTime, 'dd') as daiofweek,
format(CreationTime, 'ddd') as letterofweek, -- looks pretty useful
format(CreationTime, 'dddd') as fullday, -- even more useful!
format(CreationTime, 'dd/MM/yyyy')	as ddate,
format(CreationTime, 'MM') as monthofyear,
format(CreationTime, 'MMM') as month2ofyear,
format(CreationTime, 'MMMM') as month3ofyear -- extending dd or mm by 1 or 2 letters lets us 
	--lengthen it
from sales.orders

-- Show CreationTime using the following format
-- Day Wed Jan Q1 2025 12:35:56 PM
select creationtime,
'Day' -- Step 1 create column with static string Day
from sales.orders

select creationtime,
'Day ' +  FORMAT(creationtime, 'ddd') as CustomFormat
-- + function to concatenate the string value
-- adding trailing space so there is a gap between day and Wednesday
from sales.orders

select creationtime,
'Day ' +  FORMAT(creationtime, 'ddd MMM') +
' Q' + DATENAME(quarter,creationtime)as CustomFormat -- adding static Q with leading space
-- DATENAME function to tell us what quarter it is
from sales.orders

select creationtime,
'Day ' +  FORMAT(creationtime, 'ddd MMM') +
' Q' + DATENAME(quarter,creationtime) +
FORMAT(creationtime,' yyyy HH:mm:ss') as CustomFormat 
from sales.orders -- understand now, all thats left is PM
-- to add PM need to add tt

select creationtime,
'Day ' +  FORMAT(creationtime, 'ddd MMM') +
' Q' + DATENAME(quarter,creationtime) +
FORMAT(creationtime,' yyyy HH:mm:ss tt') as CustomFormat 
from sales.orders -- Question completed











/*CASTING: change the data type from 1 data type to another
	string -> integer or date --> string or string --> date
		use CAST() or CONVERT()
