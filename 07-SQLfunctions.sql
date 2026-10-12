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
