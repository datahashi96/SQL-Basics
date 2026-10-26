

CREATE VIEW Sales.V_MonthlySummary AS
( -- as no schema was specified, it defaults to dbo.v_monthlysummary
-- lets make it sales schema by sales.V_monthlysummary
	SELECT
		DATETRUNC(month,OrderDate) Order_Month,
		SUM(Sales) TotalSales,
		COUNT(OrderID) TotalOrders,
		SUM(Quantity) TotalQuantities
	FROM Sales.orders
	GROUP BY DATETRUNC(month,OrderDate)
)
SELECT
Order_Month,
TotalSales,
SUM(TotalSales) OVER (Order BY ORDER_MONTH) AS Running_Total
FROM V_MonthlySummary -- can query saved view now. 
--in object explorer under views

-- lets drop the dbo. view with DROP VIEW V_monthlysummary - default dbo w/o specifying
--schema. done, and removed.

--Altering View
-- Two ways in SQL server
--Method 1, copy syntax, make edits, then DROP VIEW and then CREATE VIEW
--or
--Method 2
IF OBJECT_ID('Sales.V_MonthlySummary', 'V') IS NOT NULL
	DROP VIEW Sales.V_MonthlySummary
GO
CREATE VIEW Sales.V_MonthlySummary AS
( --method 2 just need to add edits)
	SELECT
		DATETRUNC(month,OrderDate) Order_Month,
		SUM(Sales) TotalSales,
		COUNT(OrderID) TotalOrders,
		SUM(Quantity) TotalQuantities
	FROM Sales.orders
	GROUP BY DATETRUNC(month,OrderDate)
)



--Provide a view that combines details from orders, products,
-- customers and employees

CREATE VIEW Sales.V_Order_Details AS ( --created!
SELECT 
	o.OrderID,
	o.OrderDate,
	p.Product,
	p.Category,
	COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName,'') as CustomerName,
	c.Country as CustomerCountry,
	COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName,'') as EmployeeName,
	e.Department,
	o.Sales,
	o.Quantity
FROM Sales.Orders as o
LEFT JOIN Sales.Products as p
ON o.ProductID = p.productID
LEFT JOIN Sales.Customers as c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.employees as e
ON o.salespersonID = e.employeeID
)

select *
from sales.V_Order_Details

--Views can be used to enforce security and protect sensitive data
-- Columns and rows can be hidden. Choose what is to be shared in the view

--Providie a view for the EU Sales Team
-- that combines details from All Tables
-- And Excludes Data related to the USA

--filter original view, then create new view with different name

CREATE VIEW sales.V_Order_Details_EU AS (
SELECT 
	o.OrderID,
	o.OrderDate,
	p.Product,
	p.Category,
	COALESCE(c.FirstName,'') + ' ' + COALESCE(c.LastName,'') as CustomerName,
	c.Country as CustomerCountry,
	COALESCE(e.FirstName,'') + ' ' + COALESCE(e.LastName,'') as EmployeeName,
	e.Department,
	o.Sales,
	o.Quantity
FROM Sales.Orders as o
LEFT JOIN Sales.Products as p
ON o.ProductID = p.productID
LEFT JOIN Sales.Customers as c
ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.employees as e
ON o.salespersonID = e.employeeID
WHERE c.country != 'USA'
) --job done

SELECT *
from sales.V_Order_Details_EU

/* Views as a Data Mart in Data Warehouse System
They provide a flexible and efficient way to present data

Split datawarehouse into topics/datamart
	e.g. 1 could be Sales Mart - use views not tables!
	Another could be Finance Mart - use views not tables!

	Both originate from Data Warehouse