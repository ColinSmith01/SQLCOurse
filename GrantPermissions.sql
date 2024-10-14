-- Create User account and grant permissions to execute procedure

-- Step 1 - Enable OLE Automation Procedures and create procedure to write to file on file system
USE master
GO
sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
sp_configure 'Ole Automation Procedures', 1
GO
RECONFIGURE
GO

Use AdventureWorks2019
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'uspWriteFile') DROP PROCEDURE uspWriteFile
GO
CREATE PROCEDURE dbo.uspWriteFile
AS
DECLARE @OLE INT
DECLARE @FileID INT
DECLARE @DT DATETIME2
DECLARE @OUTPUT VARCHAR(50)
SET @DT = GETDATE()
SET @OUTPUT = 'Demonstration performed today: ' + CONVERT(VARCHAR(50), @DT) 
EXECUTE [master].dbo.sp_OACreate 'Scripting.FileSystemObject', @OLE OUT
EXECUTE [master].dbo.sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, 'C:\Classfiles\mod09export.txt', 8, 1
EXECUTE [master].dbo.sp_OAMethod @FileID, 'WriteLine', Null, @OUTPUT
EXECUTE [master].dbo.sp_OADestroy @FileID
EXECUTE [master].dbo.sp_OADestroy @OLE
GO

-- Step 2 - Create Logins and User accounts
USE master
GO

IF NOT EXISTS (SELECT * FROM [master].sys.syslogins WHERE name = 'CONTOSO\USER1')  
CREATE LOGIN [CONTOSO\User1] 
FROM WINDOWS 
WITH DEFAULT_DATABASE = AdventureWorks2019
GO
IF NOT EXISTS (SELECT * FROM [master].sys.syslogins WHERE name = 'CONTOSO\USER2')  
CREATE LOGIN [CONTOSO\User2] 
FROM WINDOWS 
WITH DEFAULT_DATABASE = AdventureWorks2019

USE AdventureWorks2019
GO
IF NOT EXISTS (SELECT * FROM sys.sysusers WHERE name = 'CONTOSO\USER1')
CREATE USER [CONTOSO\User1] FOR LOGIN [CONTOSO\User1]
GO
IF NOT EXISTS (SELECT * FROM sys.sysusers WHERE name = 'CONTOSO\USER2')
CREATE USER [CONTOSO\User2] FOR LOGIN [CONTOSO\User2]
GO

-- Step 3 - Grant permissions to execute procedure to first user
USE AdventureWorks2019
GO
GRANT EXECUTE ON dbo.uspWriteFile TO [CONTOSO\User1]
GO

USE Master
GO
GRANT EXECUTE ON dbo.sp_OACreate TO [CONTOSO\User1]
GRANT EXECUTE ON dbo.sp_OAMethod TO [CONTOSO\User1]
GRANT EXECUTE ON dbo.sp_OADestroy TO [CONTOSO\User1]
GO

-- Step 4 - Test test permissions for first and second user
EXECUTE AS LOGIN = 'Contoso\User1'
GO
EXECUTE [AdventureWorks2019].dbo.uspWriteFile
GO
REVERT
GO

EXECUTE AS LOGIN = 'Contoso\User2'
GO
EXECUTE [AdventureWorks2019].dbo.uspWriteFile
GO
REVERT
GO
