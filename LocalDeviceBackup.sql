USE aw
GO
BACKUP DATABASE aw 
TO DISK = 'c:\classfiles\aw_local.bak'
WITH FORMAT, MEDIANAME = 'FullBackups', NAME = 'aw FULL Backup'
GO

