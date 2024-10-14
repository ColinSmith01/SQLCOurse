--- Create Credential.  If the Credentials and Proxy exercises are being done together, use the Proxy.sql script instead.
--- Note:  Before running this job, delete all *.bak files from the D:\Backup folder

-- Step 1 - Create Credential
USE master
GO
CREATE CREDENTIAL FileSystemAccess 
WITH IDENTITY = 'CONTOSO\User1', 
SECRET = 'Pa$$w0rd'
GO

