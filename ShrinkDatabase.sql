-- Shrink Database

-- Step 1 - Create two and verify their initial sizes.  This is inherited from the model database.
USE master
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'aw1') DROP DATABASE aw1
GO
CREATE DATABASE aw1
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'aw2') DROP DATABASE aw2
GO
CREATE DATABASE aw2
GO

USE aw1
EXEC sp_spaceused @oneresultset = 1

USE aw2
EXEC sp_spaceused @oneresultset = 1
GO

-- Step 2 - Populate each database with two tables.
-- This step may take a few minutes to generate data for the second table.
USE aw1
GO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Contacts')
SELECT BusinessEntityID as ID,FirstName,LastName INTO aw1.dbo.Contacts FROM AdventureWorks2019.Person.Person
GO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SizeTest')
CREATE TABLE SizeTest (
numbers int )
GO
DECLARE @num INT
SET @num=1
WHILE @num < 500000
BEGIN 
    INSERT SizeTest(numbers) 
    VALUES(@num)
    SET @num = @num + 1
END

USE aw2
GO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Contacts')
SELECT BusinessEntityID as ID,FirstName,LastName INTO aw2.dbo.Contacts FROM AdventureWorks2019.Person.Person
GO
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SizeTest')
CREATE TABLE SizeTest (
numbers int )
GO
DECLARE @num INT
SET @num=1
WHILE @num < 500000
BEGIN 
    INSERT SizeTest(numbers) 
    VALUES(@num)
    SET @num = @num + 1
END

-- Step 3 - Verify the size of databases aw1 and aw2.
-- They should be identical.
USE aw1
EXEC sp_spaceused @oneresultset = 1

USE aw2
EXEC sp_spaceused @oneresultset = 1
GO

-- Step 4 - Delete the large table from aw1 and compare its size to aw2 again.
-- They will still be identical.  The space used by the deleted table is still allocated to the database.
USE aw1
GO
DROP TABLE SizeTest
GO
EXEC sp_spaceused @oneresultset = 1

USE aw2
EXEC sp_spaceused @oneresultset = 1
GO

-- Step 5 - Shrink the size of the aw2 database and leave 10% free space.
DBCC SHRINKDATABASE (aw1, 10)

-- Step 6 - Compare the size of the databases again.
-- aw1 should be smaller than aw2.
USE aw1
EXEC sp_spaceused @oneresultset = 1

USE aw2
EXEC sp_spaceused @oneresultset = 1
GO

-- Step 7 - Attempt to shrink the size of the aw1 database file to 25MB.
USE aw1
GO
DBCC SHRINKFILE (aw1,25)

-- Step 8 - Compare the size of the databases again.
-- DBCC SHRINKFILE allowed you to shrink the aw1 data file below its initial size.
USE aw1
EXEC sp_spaceused @oneresultset = 1

USE aw2
EXEC sp_spaceused @oneresultset = 1
GO

-- Step 9 - DROP both databases
USE master
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'aw1') DROP DATABASE aw1
GO
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'aw2') DROP DATABASE aw2
GO


