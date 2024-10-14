-- Test a log full alert (error 9002)

-- Step 1 - Create a test database with a log file that will not grow
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'TestAlertDB') DROP DATABASE TestAlertDB
GO
CREATE DATABASE TestAlertDB
ON
PRIMARY ( NAME = 'TestAlertDB',
FILENAME = 'C:\Data\TestAlertDB.mdf',
SIZE = 100MB,
FILEGROWTH = 1024KB )
LOG ON ( NAME = 'TestAlertDB_log',
FILENAME = 'C:\Log\TestAlertDB_log.ldf',
SIZE = 2048KB , FILEGROWTH = 0);
GO

-- Step 2 - Create a table to be used for logged transactions
USE TestAlertDB
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TestTable') DROP TABLE TestTable
GO
CREATE TABLE TestTable (
Col1 varchar(50)
)
GO

-- Step 3  - Fill the test database table, generating log entries that will fill it up.
-- This will cause error 9002 (full log) to occur, triggering the alert.
USE TestAlertDB
GO

SET NOCOUNT ON
WHILE 1 = 1
BEGIN
   INSERT INTO TestTable (Col1)
   SELECT 'Testing error 9002 message alert'
   UNION ALL SELECT Col1 FROM TestTable
END
GO
