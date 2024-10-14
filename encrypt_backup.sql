-- Create an encrypted backup of the Customers database on MIA-SQL\SQL2
-- Verify the instance name is SQL2 before proceeding. (e.g. SELECT @@servicename)

Use master
GO

BACKUP DATABASE Customers 
TO  DISK = 'C:\Classfiles\customers_encrypted.bak' 
WITH FORMAT, INIT,  
MEDIANAME = 'Customers Encrypted Backup',  
NAME = 'Customers-Full-Encrypted Database Backup', 
ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [SQL2_Cert]),  STATS = 10
GO

