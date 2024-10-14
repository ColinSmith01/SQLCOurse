--- Create Credential and Proxy Account.
--- Note:  If the Credentials exercises was done separately, step 1 may be skipped.
--- Note:  Before running this job, delete all *.bak files from the C:\Backup folder

-- Step 1 - Create Credential
USE master
GO
CREATE CREDENTIAL FileSystemAccess 
WITH IDENTITY = 'CONTOSO\User1', 
SECRET = 'Pa$$w0rd'
GO

-- Step 2 - Create Proxy
USE msdb
GO
EXECUTE msdb.dbo.sp_add_proxy 
@proxy_name = 'FileSystemAccessProxy',
@credential_name = 'FileSystemAccess', 
@enabled = 1
GO
EXECUTE msdb.dbo.sp_grant_proxy_to_subsystem 
@proxy_name = 'FileSystemAccessProxy', 
@subsystem_id = 3
GO
EXECUTE msdb.dbo.sp_grant_proxy_to_subsystem 
@proxy_name = 'FileSystemAccessProxy', 
@subsystem_id = 12
GO

-- Step 3 - Create Job that uses the proxy account to copy backup files to the C:\Backup folder
USE msdb
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name='CopyBackupFiles', 
		@enabled=1, 
		@job_id = @jobId OUTPUT

SELECT @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name='CopyBackupFiles', 
		@server_name = 'MIA-SQL'
GO
USE msdb
GO
EXEC msdb.dbo.sp_add_jobstep @job_name='CopyBackupFiles', 
		@step_name='Step1', 
		@step_id=1, 
		@subsystem='CmdExec', 
		@command='copy C:\Classfiles\*.bak C:\Backup\', 
		@database_name='master', 
		@flags=0, 
		@proxy_name='FileSystemAccessProxy'
GO

USE msdb
GO
EXEC msdb.dbo.sp_update_job @job_name='CopyBackupFiles', 
		@enabled=1, 
		@start_step_id=1 
GO

-- Step 4 - Go to Object Explorer and verify that the CopyBackupFiles job is using a proxy acount (check Step 1).  
-- Execute the job.  Open the C:\Backup folder to verify that the *.bak files have been copied there.

