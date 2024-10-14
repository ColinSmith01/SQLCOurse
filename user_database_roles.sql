-- Module 2 - Demo 3 (User-defined database roles)

-- Step 1 - create database users for use in this demo
USE AdventureWorks2019;
GO
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'jack_login')
	CREATE LOGIN jack_login WITH PASSWORD = 'Pa$$w0rd';
GO
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'jill_login')
	CREATE LOGIN jill_login WITH PASSWORD = 'Pa$$w0rd';
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jack_user')
	DROP USER jack_user
GO
CREATE USER jack_user FOR LOGIN jack_login;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jill_user')
	DROP USER jill_user
GO
CREATE USER jill_user FOR LOGIN jill_login;
GO

-- Step 2 - create a user-defined database role and grant SELECT permissions on the HumanResources schema to it
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'human_resources_reader' AND type = 'R')
	DROP ROLE human_resources_reader;
CREATE ROLE human_resources_reader;
GO
GRANT SELECT ON SCHEMA::HumanResources TO human_resources_reader;
GO

-- Step 3 - verify role permissions
SELECT	dpr.name AS principal_name, dpe.permission_name, dpe.class_desc, sch.name AS object_name
FROM sys.database_permissions AS dpe
JOIN sys.database_principals AS dpr
ON dpr.principal_id = dpe.grantee_principal_id
LEFT JOIN sys.schemas AS sch
ON sch.schema_id = dpe.major_id
AND dpe.class = 3
WHERE dpr.name = 'human_resources_reader';
GO

-- Step 4 - add one user to the human_resources_reader role
ALTER ROLE human_resources_reader ADD MEMBER jill_user;
GO

-- Step 5 - verify role membership
SELECT rdp.name AS role_name, rdm.name AS member_name
FROM sys.database_role_members AS rm
JOIN sys.database_principals AS rdp
ON rdp.principal_id = rm.role_principal_id
JOIN sys.database_principals AS rdm
ON rdm.principal_id = rm.member_principal_id
WHERE rdp.name = 'human_resources_reader'
ORDER BY role_name, member_name;
GO

-- Step 6 - Verify that one user has access to the HumanResources schema and the other does not
-- The first user will not have access to the table.  He is not a member of the human_resources_reader role
-- (This query will fail)
EXECUTE AS USER = 'jack_user';
SELECT SUSER_SNAME(); 
SELECT TOP (5) * FROM HumanResources.Employee
GO
REVERT
SELECT SUSER_SNAME(); 
GO
-- The second user will have access to the table because of membership in the human_resources_reader role
-- (This query will succeed)
EXECUTE AS USER = 'jill_user';
SELECT SUSER_SNAME(); 
SELECT TOP (5) * FROM HumanResources.Employee
GO
REVERT
SELECT SUSER_SNAME(); 
GO

-- Step 7 - clean up demonstration objects
ALTER ROLE human_resources_reader DROP MEMBER jack_user;
GO
ALTER ROLE human_resources_reader DROP MEMBER jill_user;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'human_resources_reader' AND type = 'R')
	DROP ROLE human_resources_reader;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jack_user')
	DROP USER jack_user
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jill_user')
	DROP USER jill_user
GO
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'jack_login')
	DROP LOGIN jack_login
GO
IF EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'jill_login')
	DROP LOGIN jill_login
GO




