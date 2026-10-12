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

-- FORMAT clause, good use is to format date before aggregating data for report


/*CASTING: change the data type from 1 data type to another
	string -> integer or date --> string or string --> date
		use CAST() or CONVERT()
	syntax CONVERT(data_type, value, [style])
		-data type, is date/string/int/varchar, value is column or static, and style is optional
		-default style is 0. */

select 
convert(INT, '123') as [CONVERT:string to integer],
convert(DATE, '2025-08-20') as [CONVERT:string to date],
CreationTime,
convert(DATE, creationtime) as [CONVERT:datetime to date], -- output:timeinformation removed
convert(VARCHAR, creationtime, 32) as [convert into string in USA Standard,style 32],
convert(VARCHAR, creationtime, 34) as [convert into string in Europestyle 34]
from sales.orders --use Europe Style. 

-- CAST(), similar function to CONVERT
--syntax CAST(value AS datatype)
select
cast('123' as INT) as [string to int],
cast(123 as VARCHAR) as [int to string],
cast('2025-08-20' as DATE) as [string to date],
cast('2025-08-20' as DATETIME) as [string to dateTIME],
creationtime,
cast(creationtime as DATE) as [creationtime to only date]
from sales.orders

/* summary CAST VS CONVERT VS FORMAT
FORMAT: changes to only string in our desired way. use for final reports. 
CAST: changes to any data type. cannot format data.
CONVERT: v. similar to CAST, able to change to any data type. optional style code allow us
to also format datetime information. /*

-- DATES & Mathematic Functions, DATEADD & DATEDIFF
--DATEADD: add or subtract  a timeinterval to/from a date
--syntax(part, interval, date)
--e.g. dateadd(year, 2, Orderdate): add 2 years to column OrderDate
-- dateadd(month, -4, Orderdate): remove 4 months from column Orderdate	
*/
asdf asdf*/

select orderID,
orderDate,
DATEADD(year, 2, OrderDate) as [twoyearslater],
DATEADD(month, -3, OrderDate) as [threemonthearlier],
DATEADD(day, -5, OrderDate) as [fivedaysearlier]
from sales.orders

--DATEDIFF: find the difference between two dates
--specify how many years, month or days different you would like
--syntax(part,start_date,end_date)

--query: calculate age of employees
select *,
DATEDIFF(year, BirthDate, GETDATE()) as AGE --remember its year not years
from sales.employees

--find avg shipping duration in days for each month
select
DATEPART(month,OrderDate) AS [MONTH],
AVG(DATEDIFF(day,OrderDate,ShipDate))
from sales.orders 
GROUP BY DATEPART(month,OrderDate)
--FIND THE NO. of days between each order and previous order
select OrderID,
OrderDate as [CurrentOrderDate],
LAG(OrderDate) over (Order by OrderDate) as [PREVIOUSORDERDATE],
DATEDIFF(day,LAG(OrderDate) over (Order by OrderDate),OrderDate)
from sales.orders -- lag to be covered later in window functions!
--example above is timegap analysis

--ISDATE() checks if a value is a date, output of 1 if string is a valid date
-- checking if value is suitable enough to be a date
select
ISDATE('123') [DATECHECK1], -- not a date
ISDATE('2025-08-20') [DATECHECK2], -- a date
ISDATE('20-08-2025') [DATECHECK3], -- not considered a date, wrong format! 
ISDATE('2024') [DATECHECK4] -- able to understand a year only as a date
/* sql understands year/mm/dd or year only. */

--use ISDATE to confirm valid dates in data, 
--as we need to do checks before manipulating data later
