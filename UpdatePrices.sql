USE master
GO

ALTER DATABASE AdventureWorks2019 SET RECOVERY FULL
GO

USE AdventureWorks2019
GO

UPDATE [Production].[Product] SET [ListPrice] = [ListPrice] + 10
GO

