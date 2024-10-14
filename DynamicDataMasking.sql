-- Module 4 - Dynamic Data Masking

-- Step 1 - create a new table with data masks
USE AdventureWorks2019
GO
CREATE TABLE HumanResources.EmployeePersonalData
(empid int NOT NULL PRIMARY KEY,
salary int  MASKED WITH (FUNCTION = 'default()') NOT NULL,
email_address varchar(255)  MASKED WITH (FUNCTION = 'email()')  NULL,
voice_mail_pin smallint MASKED WITH (FUNCTION = 'random(0, 9)') NULL,
company_credit_card_number varchar(30) MASKED WITH (FUNCTION = 'partial(0,"XXXX-",4)') NULL,
home_phone_number varchar(30) NULL
)
GO

-- Step 2 - grant permission to a low-privilege user
USE master
GO
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'mod04login') 
BEGIN
CREATE LOGIN mod04login WITH PASSWORD = 'Pa$$w0rd'
USE AdventureWorks2019
CREATE USER mod04user FOR LOGIN mod04login
END

USE AdventureWorks2019
GO
GRANT SELECT ON HumanResources.EmployeePersonalData TO mod04user
GO

-- Step 3 - insert test data 
INSERT HumanResources.EmployeePersonalData
(empid, salary, email_address, voice_mail_pin, company_credit_card_number, home_phone_number)
VALUES (1,25000,'emp1@adventure-works.net',9991,'9999-5656-4433-2211', '1234-567890'),
(2,35000,'qx3e@adventure-works.org',1151,'9999-7676-5566-3141', '2345-314253'),
(3,35000,'zn4456@adventure-works.net',6514,'9999-7676-5567-2444', '3456-777266')

-- Step 4 - demonstrate that an adminstrator can see the unmasked data
SELECT * FROM HumanResources.EmployeePersonalData

-- Step 5 - demonstrate that a user with only SELECT permission sees masked data  
EXECUTE AS USER = 'mod04user'
SELECT * FROM HumanResources.EmployeePersonalData

REVERT
GO
-- Step 6 - alter the home_phone_number column to add a mask
ALTER TABLE HumanResources.EmployeePersonalData 
ALTER COLUMN home_phone_number
ADD MASKED WITH (FUNCTION = 'partial(4,"-XXX",0)')
GO

-- Step 7 - demonstrate the new mask  
EXECUTE AS USER = 'mod04user'
SELECT home_phone_number FROM HumanResources.EmployeePersonalData

REVERT
GO

-- Step 8 - remove the mask from the salary column
ALTER TABLE HumanResources.EmployeePersonalData 
ALTER COLUMN salary
DROP MASKED
GO

-- Step 9 - demonstrate that salary is now unmasked 
EXECUTE AS USER = 'mod04user'
SELECT salary FROM HumanResources.EmployeePersonalData

REVERT
GO

-- Step 10 - grant the UNMASK permission to the test user
GRANT UNMASK TO mod04user

-- Step 11 - demonstrate that the UNMASK permission disables masking
EXECUTE AS USER = 'mod04user'
SELECT * FROM HumanResources.EmployeePersonalData

REVERT
GO

-- Step 12 - remove test table and masking permissions
DROP TABLE HumanResources.EmployeePersonalData
GO
REVOKE UNMASK TO mod04user
GO
