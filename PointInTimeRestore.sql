-- Point in time restore

-- Step 1 - Create a test table in the AW database
USE master
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'aw') DROP DATABASE aw
GO
CREATE DATABASE aw
GO
USE aw
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RestoreTest') DROP TABLE RestoreTest
GO
CREATE TABLE RestoreTest (
ID INT NOT NULL PRIMARY KEY,
notes VARCHAR(100) NOT NULL,
dt1 DATETIME NOT NULL DEFAULT getdate()
)

-- Step 2 - Verify the aw database recovery model is set to full.  If not, alter the database so it is.
-- ALTER DATABASE aw SET RECOVERY FULL WITH NO_WAIT
SELECT name, recovery_model_desc, log_reuse_wait_desc 
FROM sys.databases

-- Step 3 - Perform a full backup of the database
BACKUP DATABASE aw
TO DISK = 'C:\Classfiles\awbackups.bak'
WITH FORMAT,
MEDIANAME = 'awBackups',
NAME = 'AW Database backups'
GO

-- Step 4 - First insertion of records into the test table.  Verify that the operation succeeded.  Wait three (3) minutes before going to the next step.
-- There should be ten (10) records in the table after this.
INSERT INTO RestoreTest (ID, notes) VALUES (1, 'value1')
INSERT INTO RestoreTest (ID, notes) VALUES (2, 'value2')
INSERT INTO RestoreTest (ID, notes) VALUES (3, 'value3')
INSERT INTO RestoreTest (ID, notes) VALUES (4, 'value4')
INSERT INTO RestoreTest (ID, notes) VALUES (5, 'value5')
INSERT INTO RestoreTest (ID, notes) VALUES (6, 'value6')
INSERT INTO RestoreTest (ID, notes) VALUES (7, 'value7')
INSERT INTO RestoreTest (ID, notes) VALUES (8, 'value8')
INSERT INTO RestoreTest (ID, notes) VALUES (9, 'value9')
INSERT INTO RestoreTest (ID, notes) VALUES (10, 'value10')
GO

SELECT * FROM RestoreTest

-- Step 5 - Wait three (3) minutes after completing the previous step to do this one.  Second insertion of records into the test table.  Verify that the operation succeeded.
-- There should be twenty (20) records in the table after this.
INSERT INTO RestoreTest (ID, notes) VALUES (11, 'value11')
INSERT INTO RestoreTest (ID, notes) VALUES (12, 'value12')
INSERT INTO RestoreTest (ID, notes) VALUES (13, 'value13')
INSERT INTO RestoreTest (ID, notes) VALUES (14, 'value14')
INSERT INTO RestoreTest (ID, notes) VALUES (15, 'value15')
INSERT INTO RestoreTest (ID, notes) VALUES (16, 'value16')
INSERT INTO RestoreTest (ID, notes) VALUES (17, 'value17')
INSERT INTO RestoreTest (ID, notes) VALUES (18, 'value18')
INSERT INTO RestoreTest (ID, notes) VALUES (19, 'value19')
INSERT INTO RestoreTest (ID, notes) VALUES (20, 'value20')
GO

SELECT * FROM RestoreTest

-- Step 6 - Backup the transaction log.  
BACKUP LOG aw
TO DISK = 'C:\Classfiles\awbackups.bak'
GO

-- Step 7 - View the backups in the backup file and make a note of the file numbers
RESTORE HEADERONLY   
FROM DISK = 'C:\Classfiles\awBackups.bak' 
GO  

-- Step 8 - Restore the database going back to the point in time right after the first insert operation.
-- Change the time in the log restore operation to be one (1) minute after the first record insertions.
USE master
GO

-- First step of any restore is always a tail-log backup if possible.
BACKUP LOG aw
TO DISK = 'C:\Classfiles\awbackups.bak'
WITH NORECOVERY
GO

RESTORE DATABASE aw  
FROM DISK = 'C:\Classfiles\awBackups.bak'  
WITH FILE=1, 
NORECOVERY 
GO

RESTORE LOG aw  
FROM DISK = 'C:\Classfiles\awBackups.bak'  
WITH FILE=2, 
RECOVERY, STOPAT = 'Mar 30, 2022 11:43 AM'  -- Change the time to be one (1) minute after the first insertion of records. 
GO

-- Step 9 - Verify the restore was done to the correct time stamp
-- There should be only ten (10) records in the test table
USE aw
GO

SELECT * FROM RestoreTest

