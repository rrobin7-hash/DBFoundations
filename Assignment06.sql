--*************************************************************************--
-- Title: Assignment06
-- Author: RRobinson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-15-11,RRobinson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_RRobinson')
	 Begin 
	  Alter Database [Assignment06DB_RRobinson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_RRobinson;
	 End
	Create Database Assignment06DB_RRobinson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_RRobinson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
-- Question 1

CREATE VIEW dbo.vCategories
WITH SCHEMABINDING
AS
SELECT
    CategoryID,
    CategoryName
FROM dbo.Categories;
GO

CREATE VIEW dbo.vProducts
WITH SCHEMABINDING
AS
SELECT
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice
FROM dbo.Products;
GO

CREATE VIEW dbo.vEmployees
WITH SCHEMABINDING
AS
SELECT
    EmployeeID,
    EmployeeFirstName,
    EmployeeLastName,
    ManagerID
FROM dbo.Employees;
GO

CREATE VIEW dbo.vInventories
WITH SCHEMABINDING
AS
SELECT
    InventoryID,
    InventoryDate,
    EmployeeID,
    ProductID,
    [Count]
FROM dbo.Inventories;
GO


SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Remove SELECT permissions from tables
DENY SELECT ON dbo.Categories TO public;
DENY SELECT ON dbo.Products TO public;
DENY SELECT ON dbo.Employees TO public;
DENY SELECT ON dbo.Inventories TO public;

-- Allow SELECT permissions on views
GRANT SELECT ON dbo.vCategories TO public;
GRANT SELECT ON dbo.vProducts TO public;
GRANT SELECT ON dbo.vEmployees TO public;
GRANT SELECT ON dbo.vInventories TO public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
CREATE VIEW dbo.vCategoryProducts
AS
SELECT
    C.CategoryName,
    P.ProductName,
    P.UnitPrice
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID;
GO

SELECT *
FROM dbo.vCategoryProducts
ORDER BY CategoryName, ProductName;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW dbo.vProductInventories
AS
SELECT
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.Products AS P
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID;
GO

SELECT *
FROM dbo.vProductInventories
ORDER BY ProductName, InventoryDate, Count;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
CREATE VIEW dbo.vInventoryDatesByEmployee
AS
SELECT DISTINCT
    I.InventoryDate,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Inventories AS I
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID;
GO

SELECT *
FROM dbo.vInventoryDatesByEmployee
ORDER BY InventoryDate;
GO

CREATE VIEW dbo.vInventoryDatesByEmployee
AS
SELECT DISTINCT
    I.InventoryDate,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Inventories AS I
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID;
GO

SELECT *
FROM dbo.vInventoryDatesByEmployee
ORDER BY InventoryDate;
GO

--TEST SCRIPT--
SELECT TOP 5 *
FROM dbo.Employees;

SELECT TOP 5 *
FROM dbo.Inventories;

--TEST SCRIPT 2--
SELECT *
FROM dbo.vInventoryDatesByEmployee
ORDER BY InventoryDate;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
CREATE VIEW dbo.vCategoryProductInventories
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID;
GO

SELECT *
FROM dbo.vCategoryProductInventories
ORDER BY
    CategoryName,
    ProductName,
    InventoryDate,
    Count;
GO

--TEST 2--
SELECT *
FROM dbo.vCategoryProductInventories
ORDER BY
    CategoryName,
    ProductName,
    InventoryDate,
    Count;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW dbo.vCategoryProductInventoriesByEmployee
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID;
GO

SELECT *
FROM dbo.vCategoryProductInventoriesByEmployee
ORDER BY
    InventoryDate,
    CategoryName,
    ProductName,
    EmployeeName;
GO
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW dbo.vChaiAndChangInventories
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID
WHERE P.ProductName IN ('Chai', 'Chang');
GO

SELECT *
FROM dbo.vChaiAndChangInventories
ORDER BY
    InventoryDate,
    CategoryName,
    ProductName,
    EmployeeName;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW dbo.vEmployeesByManager
AS
SELECT
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName,
    M.EmployeeFirstName + ' ' + M.EmployeeLastName AS ManagerName
FROM dbo.Employees AS E
INNER JOIN dbo.Employees AS M
    ON E.ManagerID = M.EmployeeID;
GO

SELECT *
FROM dbo.vEmployeesByManager
ORDER BY ManagerName;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW dbo.vCompleteInventoryReport
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryID,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName,
    M.EmployeeFirstName + ' ' + M.EmployeeLastName AS ManagerName
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID
LEFT JOIN dbo.Employees AS M
    ON E.ManagerID = M.EmployeeID;
GO

SELECT *
FROM dbo.vCompleteInventoryReport
ORDER BY
    CategoryName,
    ProductName,
    InventoryID,
    EmployeeName;
GO
/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]


--test A--
SELECT name
FROM sys.views
ORDER BY name;

--test b--
Select * 
From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

DROP VIEW dbo.vCategoryProducts;
GO

CREATE VIEW dbo.vProductsByCategories
AS
SELECT
    C.CategoryName,
    P.ProductName,
    P.UnitPrice
FROM dbo.Categories AS C
INNER JOIN dbo.Products AS P
    ON C.CategoryID = P.CategoryID;
GO

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

CREATE VIEW dbo.vInventoriesByProductsByDates
AS
SELECT
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.Products AS P
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID;
GO

ALTER VIEW dbo.vInventoriesByProductsByDates
AS
SELECT
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.Products AS P
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID;
GO

SELECT name
FROM sys.views
ORDER BY name;

CREATE VIEW dbo.vInventoriesByProductsByDates
AS
SELECT
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.Products AS P
INNER JOIN dbo.Inventories AS I
    ON P.ProductID = I.ProductID;
GO

CREATE VIEW dbo.vInventoriesByEmployeesByDates
AS
SELECT DISTINCT
    I.InventoryDate,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Inventories AS I
INNER JOIN dbo.Employees AS E
    ON I.EmployeeID = E.EmployeeID;
GO

CREATE VIEW dbo.vInventoriesByProductsByEmployees
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Categories C
JOIN dbo.Products P
    ON C.CategoryID = P.CategoryID
JOIN dbo.Inventories I
    ON P.ProductID = I.ProductID
JOIN dbo.Employees E
    ON I.EmployeeID = E.EmployeeID;
GO

CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Categories C
JOIN dbo.Products P
    ON C.CategoryID = P.CategoryID
JOIN dbo.Inventories I
    ON P.ProductID = I.ProductID
JOIN dbo.Employees E
    ON I.EmployeeID = E.EmployeeID
WHERE P.ProductName IN ('Chai','Chang');
GO

CREATE VIEW dbo.vInventoriesByProductsByCategoriesByEmployees
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryID,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName,
    M.EmployeeFirstName + ' ' + M.EmployeeLastName AS ManagerName
FROM dbo.Categories C
JOIN dbo.Products P
    ON C.CategoryID = P.CategoryID
JOIN dbo.Inventories I
    ON P.ProductID = I.ProductID
JOIN dbo.Employees E
    ON I.EmployeeID = E.EmployeeID
LEFT JOIN dbo.Employees M
    ON E.ManagerID = M.EmployeeID;
GO

SELECT name
FROM sys.views
WHERE name = 'vInventoriesByProductsByCategories';

SELECT DB_NAME() AS CurrentDatabase;

SELECT name
FROM sys.views
ORDER BY name;

CREATE VIEW dbo.vInventoriesByProductsByCategories
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count
FROM dbo.vCategories AS C
INNER JOIN dbo.vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.vInventories AS I
    ON P.ProductID = I.ProductID;
GO

SELECT TOP 5 *
FROM dbo.vInventoriesByProductsByCategories;
GO

CREATE VIEW dbo.vInventoriesByProductsByEmployees
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.vCategories AS C
INNER JOIN dbo.vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.vInventories AS I
    ON P.ProductID = I.ProductID
INNER JOIN dbo.vEmployees AS E
    ON I.EmployeeID = E.EmployeeID;
GO

CREATE VIEW dbo.vInventoriesForChaiAndChangByEmployees
AS
SELECT
    C.CategoryName,
    P.ProductName,
    I.InventoryDate,
    I.Count,
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.vCategories AS C
INNER JOIN dbo.vProducts AS P
    ON C.CategoryID = P.CategoryID
INNER JOIN dbo.vInventories AS I
    ON P.ProductID = I.ProductID
INNER JOIN dbo.vEmployees AS E
    ON I.EmployeeID = E.EmployeeID
WHERE P.ProductName IN ('Chai', 'Chang');
GO

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]


/***************************************************************************************/