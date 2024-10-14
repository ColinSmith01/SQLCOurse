-- Create SQL Server Agent Job that uses a security context in a job step 

USE msdb
GO
DECLARE @jobId BINARY(16)

EXEC  msdb.dbo.sp_add_job 
		@job_name='Write_To_File', 
		@enabled=1, 
		@description='Write information to a text file using a stored procedure', 
		@owner_login_name='CONTOSO\Administrator', 
		@job_id = @jobId OUTPUT

SELECT @jobId
GO
EXEC msdb.dbo.sp_add_jobserver 
		@job_name='Write_To_File', 
		@server_name = 'MIA-SQL'
GO

USE msdb
GO
EXEC msdb.dbo.sp_add_jobstep 
		@job_name='Write_To_File', 
		@step_name='Step1', 
		@step_id=1, 
		@subsystem='TSQL', 
		@command='EXECUTE dbo.uspWriteFile', 
		@database_name='AdventureWorks2019', 
		@database_user_name='CONTOSO\User1'
GO

USE msdb
GO
EXEC msdb.dbo.sp_update_job 
		@job_name='Write_To_File', 
		@enabled=1, 
		@start_step_id=1, 
		@description='Write information to a text file using a stored procedure', 
		@owner_login_name='CONTOSO\Administrator'
GO
