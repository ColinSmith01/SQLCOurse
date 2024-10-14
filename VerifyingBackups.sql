-- View backup history

-- Step 1 - Query backup information from msdb database tables
USE master
GO 

SELECT 
CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_start_date, 
msdb.dbo.backupset.backup_finish_date, 
msdb.dbo.backupset.expiration_date, 
CASE msdb..backupset.type 
WHEN 'D' THEN 'Database' 
WHEN 'L' THEN 'Log' 
END AS backup_type, 
msdb.dbo.backupset.backup_size, 
msdb.dbo.backupmediafamily.logical_device_name, 
msdb.dbo.backupmediafamily.physical_device_name, 
msdb.dbo.backupset.name AS backupset_name, 
msdb.dbo.backupset.description 
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 30) 
ORDER BY 
msdb.dbo.backupset.database_name, 
msdb.dbo.backupset.backup_finish_date 

-- Step 2 - Use RESTORE HEADERONLY
RESTORE HEADERONLY 
FROM DISK = 'C:\Classfiles\aw.bak' 
GO

-- Step 3 - Use RESTORE FILELISTONLY
RESTORE FILELISTONLY 
FROM DISK = 'C:\Classfiles\aw.bak'
GO

--Use Step 4 - RESTORE VERIFYONLY
RESTORE VERIFYONLY 
FROM DISK = 'C:\Classfiles\aw.bak'
GO

