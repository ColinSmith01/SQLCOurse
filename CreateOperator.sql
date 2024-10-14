-- Create an operator account for Student

USE msdb
GO
EXEC msdb.dbo.sp_add_operator @name=N'Student', 
		@enabled=1, 
		@weekday_pager_start_time=60000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=60000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=60000, 
		@sunday_pager_end_time=180000, 
		@pager_days=127, 
		@email_address='student@mia-sql.contoso.com', 
		@pager_address='student@mia-sql.contoso.com'
GO
