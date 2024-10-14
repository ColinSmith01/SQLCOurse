-- Create a table and fill it to trigger a database size limit alert

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TestTable') DROP TABLE TestTable
GO
CREATE TABLE TestTable (
Col1 varchar(50)
)
GO

SET NOCOUNT ON
WHILE 1 = 1
BEGIN
   INSERT INTO TestTable (Col1)
   SELECT 'Testing error 9002 message alert'
   UNION ALL SELECT Col1 FROM TestTable
END
GO
