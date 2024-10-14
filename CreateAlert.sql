-- Create an Alert for full transaction logs.  Notify Student

USE msdb
GO
EXEC msdb.dbo.sp_add_alert @name='Log Full Alert', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@job_id='00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name='Log Full Alert', 
		@operator_name='Student', 
		@notification_method = 1
GO
