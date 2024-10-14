-- Create a partially contained database
-- Enable contained databases on the instance
USE master
GO
EXEC sp_configure 'show advanced', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'contained database authentication', 1
GO
RECONFIGURE
GO
-- Remove the containeddb database if it already exist and then create it
IF DB_ID('containeddb') IS NOT NULL
BEGIN
ALTER DATABASE containeddb SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE containeddb
END
GO
CREATE DATABASE containeddb
GO
-- Use the containeddb database to create a sample table (verify permissions).
-- Attempt to create user accounts with a password (will fail because the contained database setting is "NONE" by default).
USE containeddb
GO
SELECT BusinessEntityID as ID, FirstName,LastName,JobTitle,PhoneNumber,PhoneNumberType,EmailAddress 
INTO dbo.employees 
FROM AdventureWorks2019.HumanResources.vEmployee
GO
CREATE USER containedUser1 WITH PASSWORD = 'Pa$$w0rd'
CREATE USER containedUser2 WITH PASSWORD = 'Pa$$w0rd'
GO
-- Alter the containeddb database to use a contained database setting of "PARTIAL".  This will allow the addition of database user accounts with passwords.
use master 
GO
ALTER DATABASE containeddb SET CONTAINMENT = PARTIAL WITH NO_WAIT
GO
-- Create database user accounts and allow one user to read table records
Use containeddb
GO
CREATE USER containedUser1 WITH PASSWORD = 'Pa$$w0rd'
CREATE USER containedUser2 WITH PASSWORD = 'Pa$$w0rd'
GO
ALTER ROLE db_datareader ADD MEMBER containedUser1
GO
-- Verify database settings and database user accounts
SELECT name, containment_desc FROM sys.databases
GO
SELECT name,type_desc FROM sys.database_principals 
GO
SELECT * FROM employees

