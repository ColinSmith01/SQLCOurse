-- Verify if Instant File Initialization is enabled for this instance of SQL Server

SELECT servicename, service_account, instant_file_initialization_enabled
FROM sys.dm_server_services
WHERE servicename LIKE 'SQL Server (%'



