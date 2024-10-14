-- Module 4 - Using SQL Server Audit

-- Step 1 - create an audit
USE master
GO
CREATE SERVER AUDIT MIASQL_Audit 
TO FILE (FILEPATH='C:\Classfiles\Demofiles\Mod04\Audit\')
WITH (QUEUE_DELAY = 5000)
GO

-- Step 2 - enable SQL Server Audit
ALTER SERVER AUDIT MIASQL_Audit WITH (STATE = ON)
GO

-- Step 3 - create a server audit specification
CREATE SERVER AUDIT SPECIFICATION AuditLogins
FOR SERVER AUDIT MIASQL_Audit
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON)
GO

-- Step 4 - create a database audit specification
USE AdventureWorks2019
GO
CREATE DATABASE AUDIT SPECIFICATION AdventureWorks2019_audit_spec
FOR SERVER AUDIT MIASQL_Audit
ADD (INSERT,UPDATE ON DATABASE::AdventureWorks2019 BY public),
ADD (SELECT ON SCHEMA::HumanResources BY public),
ADD (SCHEMA_OBJECT_CHANGE_GROUP)
WITH (STATE = ON)
GO

-- Step 5 - alter the database audit specification
USE AdventureWorks2019
GO
ALTER DATABASE AUDIT SPECIFICATION AdventureWorks2019_audit_spec WITH (STATE = OFF)
GO
ALTER DATABASE AUDIT SPECIFICATION AdventureWorks2019_audit_spec
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON)
GO

-- Step 6 - examine audit metadata
SELECT * FROM sys.server_audits

-- Step 7 - examine server audit specification metadata
SELECT * FROM sys.server_audit_specifications

SELECT * FROM sys.server_audit_specification_details AS sd
JOIN sys.dm_audit_actions AS aa
ON aa.name = sd.audit_action_name COLLATE Latin1_General_CI_AS_KS_WS

-- Step 8 - examine database audit specification metadata
SELECT * FROM sys.database_audit_specifications

SELECT * FROM sys.database_audit_specification_details AS sd
JOIN sys.dm_audit_actions AS aa
ON aa.name = sd.audit_action_name COLLATE Latin1_General_CI_AS_KS_WS
AND aa.class_desc = sd.class_desc COLLATE Latin1_General_CI_AS_KS_WS

-- Step 9 - remove the audit 
USE master
GO
ALTER SERVER AUDIT MIASQL_Audit WITH (STATE = OFF)
DROP SERVER AUDIT MIASQL_Audit
GO

ALTER SERVER AUDIT SPECIFICATION AuditLogins WITH (STATE = OFF)
DROP SERVER AUDIT SPECIFICATION AuditLogins
GO

USE AdventureWorks2019
GO
ALTER DATABASE AUDIT SPECIFICATION AdventureWorks2019_audit_spec WITH (STATE = OFF)
GO
DROP DATABASE AUDIT SPECIFICATION AdventureWorks2019_audit_spec
GO
