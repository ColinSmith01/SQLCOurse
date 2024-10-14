-- Restore the Customers database from MIA-SQL\SQL2 to MIA-SQL using an encrypted backup
-- Verify you are using the default instance (MSSQLSERVER) before proceeding. (e.g. SELECT @@servicename)

-- Step 1 - Create a folder for the Customers database using xp_cmdshell
USE master
GO
EXECUTE sp_configure 'show advanced options', 1
GO  
RECONFIGURE 
GO  
EXECUTE sp_configure 'xp_cmdshell', 1
GO  
RECONFIGURE  
GO  
EXECUTE xp_cmdshell 'mkdir c:\customers'
GO

-- Step 2 - Try to restore the database without the certificate
-- You will get an error message for the missing certificate
USE master
GO

RESTORE DATABASE Customers  
FROM DISK = 'C:\Classfiles\customers_encrypted.bak'  
WITH MOVE 'Customers' TO 'C:\customers\Customers_Data.mdf',
MOVE 'Customers_Log' TO 'C:\customers\Customers_Log.ldf',
RECOVERY

-- Step 3 - Restore the master key and certificate from the MIA-SQL\SQL2 instance backups 
RESTORE MASTER KEY
FROM FILE = 'C:\Classfiles\SQL2_master.key'
DECRYPTION BY PASSWORD = 'Pa$$w0rd'
ENCRYPTION BY PASSWORD = 'Pa$$w0rd'

CREATE CERTIFICATE SQL2_Cert 
FROM FILE ='C:\Classfiles\SQL2_Cert.cer'
WITH PRIVATE KEY (FILE = 'C:\Classfiles\SQL2_Cert.pvk', DECRYPTION BY PASSWORD = 'Pa$$w0rd')

-- Step 4 - Try again to restore the database 
-- It should work since the correct certificates are now installed to decrypt the backup
RESTORE DATABASE Customers  
FROM DISK = 'C:\Classfiles\customers_encrypted.bak'  
WITH MOVE 'Customers' TO 'C:\customers\Customers_Data.mdf',
MOVE 'Customers_Log' TO 'C:\customers\Customers_Log.ldf',
RECOVERY
