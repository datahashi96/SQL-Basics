/* Comparison of
Subquery
	Storage: Cache, Fast
	Temporary
	Only Lasts For Single Query
	Not Reusable. Have to be written again
	Fresh upto date data - logic executed now!
CTE
	Storage: Cache, Fast
	Temporary
	Only Lasts For Single Query
	Can reuse in same query in multiple places
	Fresh upto date data - logic executed now!
TEMP
	Storage: Disk
	Temporary
	Only Lasts For Session
	Can be accessed by Multiple Queries - temporary thought
	Not fresh, executed and saved from before
CTAS
	Storage: Disk
	Permanent
	Removed with DROP
	Can be accessed by Multiple Queries - Max Reusabiltity
	Not fresh, executed and saved from before
VIEW
	No Storage
	Permanent
	Removed with DROP
	Can be accessed by Multiple Queries -  - Max Reusabiltity
	Fresh upto date data - logic executed now!


Baraa Favourite
	1) VIEWS
	2) CTEs, dont use too many, max 5 in one query!
	3) Subquery
	4) CTAS if VIEWS are slow
	5) Temp Tables - rarely used.