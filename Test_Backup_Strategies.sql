-- Test Backup Strategies

-- Step 1 - Create a test table in the aw database
Use aw7
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RestoreTest') DROP TABLE dbo.RestoreTest
CREATE TABLE RestoreTest (
ID INT NOT NULL PRIMARY KEY,
notes VARCHAR(100) NOT NULL,
dt1 DATETIME NOT NULL DEFAULT getdate()
)

-- Step 2 - Add records into the table and do a full backup and a log backup
INSERT INTO RestoreTest (ID, notes) VALUES (1, 'value1')
GO

BACKUP DATABASE aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH INIT, FORMAT,
MEDIANAME = 'aw7Backups',
NAME = 'AW7 FULL Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (2, 'value2')
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

-- Step 3 - Add records into the table and do a differential and multiple log backups 
INSERT INTO RestoreTest (ID, notes) VALUES (3, 'value3')
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (4, 'value4')
GO

BACKUP DATABASE aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH DIFFERENTIAL,
NAME = 'AW7 DIFFERENTIAL Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (5, 'value5')
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

-- Step 4 - Add records into the table and do a full, two differential and multiple log backups 
INSERT INTO RestoreTest (ID, notes) VALUES (6, 'value6')
GO

BACKUP DATABASE aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 FULL Backup'
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (7, 'value7')
GO

BACKUP DATABASE aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH DIFFERENTIAL,
NAME = 'AW7 DIFFERENTIAL Backup'
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (8, 'value8')
GO

BACKUP DATABASE aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH DIFFERENTIAL,
NAME = 'AW7 DIFFERENTIAL Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (9, 'value9')
GO

BACKUP LOG aw7
TO DISK = 'C:\Classfiles\aw7_backups.bak'
WITH NAME = 'AW7 LOG Backup'
GO

INSERT INTO RestoreTest (ID, notes) VALUES (10, 'value10')
GO

-- Step 5 -- Review table information and backup set
-- There should be ten (10) records
SELECT * FROM RestoreTest
GO

RESTORE HEADERONLY
FROM DISK = 'C:\Classfiles\aw7_backups.bak'
GO

-- Step 6 -- For discussion:
-- What backups would you need to restore up to record number 8?
-- What backups would you need to restore up to record number 6?
-- What backups would you need to restore up to record number 4?
-- Are there any backups here that would never be needed to restore up to a specific record?



