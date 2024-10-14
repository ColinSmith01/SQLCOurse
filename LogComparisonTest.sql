-- Full Recovery Model test

-- Step 1 - Create a test table in the AW database
USE aw
GO

CREATE TABLE tLogTest (
col1 int )
GO

-- Step 2 - Verify aw database recovery model (Full)
SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases

-- Step 3 - View log space used and save for later reference
DBCC SQLPERF(logspace) 
GO

-- Step 4 - Insert records into test table
DECLARE @num INT;
SET @num=10001;
WHILE @num < 20000
BEGIN 
    INSERT tLogTest(col1) 
    VALUES(@num); 
    SET @num = @num + 1;
END

-- Step 5 - View log space used again and compare to previous reference
DBCC SQLPERF(logspace) 
GO

-- Step 6 - Verify log status before and after checkpoint
SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases
GO

CHECKPOINT

SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases
GO

-- Step 7 - Perform a log backup.
-- Will only work for Full or Bulk-Logged recovery models
BACKUP LOG aw
TO DISK = 'C:\Classfiles\aw.trn'
   WITH FORMAT, DESCRIPTION = 'aw log backup';
GO

-- Step 8 - Verify the reduced "Log Space Used" after truncation caused by backup 
DBCC SQLPERF(logspace) 

-- Step 9 - Check log status
SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases

-- Step 10 - Change the AW recovery model to simple and try the steps again to note the difference in log file behavior
USE master
ALTER DATABASE aw SET RECOVERY SIMPLE WITH NO_WAIT
GO

-- ALTER DATABASE aw SET RECOVERY FULL WITH NO_WAIT
