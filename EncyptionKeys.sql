-- Create encryption keys and backups 
-- Verify the instance name is SQL2 before proceeding. (e.g. SELECT @@servicename)

USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
GO
SELECT * FROM sys.symmetric_keys

--Backup the database master key
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Pa$$w0rd'
BACKUP MASTER KEY TO FILE = 'C:\Classfiles\SQL2_master.key'
ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
GO

--Create a certificate
CREATE CERTIFICATE SQL2_Cert
WITH SUBJECT = 'SQL2 Certificate'

--Backup the certificate and its private key
BACKUP CERTIFICATE SQL2_Cert 
TO FILE = 'C:\Classfiles\SQL2_Cert.cer'
WITH PRIVATE KEY (file = 'C:\Classfiles\SQL2_Cert.pvk' ,
encryption by password = 'Pa$$w0rd')
GO



