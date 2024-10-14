--Module 03 - Authorizing User Access to Objects
-- Step 1: Use the AdventureWorks2019 database and create a user for the demonstration.
USE master
GO
CREATE LOGIN Mod03Login WITH PASSWORD = 'Pa$$w0rd'
GO

USE AdventureWorks2019
GO
CREATE USER Mod03User FOR LOGIN Mod03Login
GO

-- Step 2: Query the full list of server principals. 
SELECT * FROM sys.server_principals
GO

-- Step 3: Query the full list of database principals. 
SELECT * FROM sys.database_principals
GO

-- Step 4: Grant SELECT permission on the Production.Product table to Mod03User.
GRANT SELECT ON Production.Product TO Mod03User
GO

-- Step 5: Change the execution context to the Mod03User context.
SELECT SUSER_NAME(), USER_NAME()
GO

EXECUTE AS USER = 'Mod03User';
SELECT SUSER_NAME(), USER_NAME()


-- Step 6: Try to SELECT from the Production.Product and Production.ProductInventory tables. 
SELECT * FROM Production.Product
SELECT * FROM Production.ProductInventory
GO

-- Step 7: Revert to the orignal security context.
REVERT
SELECT SUSER_NAME(), USER_NAME()
GO

-- Step 8: Grant SELECT only on the Shelf and Bin columns in Production.ProductInventory to Mod03User.
GRANT SELECT ON Production.ProductInventory (Shelf, Bin) TO Mod03User
GO

-- Step 9: Change the execution context to the Mod03User context.
EXECUTE AS USER = 'Mod03User'
GO

-- Step 10: Try to SELECT Shelf, Bin and other columns from Production.ProductInventory
SELECT DISTINCT Shelf, Bin FROM Production.ProductInventory
GO

SELECT * FROM Production.ProductInventory
GO

-- Step 11: Revert to original security context.
REVERT
GO
SELECT SUSER_NAME(), USER_NAME()

SELECT * FROM Production.ProductInventory
GO

