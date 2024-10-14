-- Module 4 - Using Custom Audit Events

-- Step 1 - create an audit
USE master
GO
CREATE SERVER AUDIT Custom_Audit 
TO FILE (FILEPATH='C:\Classfiles\Demofiles\Mod04\Audit\')
WITH (QUEUE_DELAY = 5000)
GO
ALTER SERVER AUDIT Custom_Audit WITH (STATE = ON)
GO

-- Step 2 - create a server audit specification which includes the 
-- USER_DEFINED_AUDIT_GROUP action group
CREATE SERVER AUDIT SPECIFICATION UserDefinedEvents
FOR SERVER AUDIT Custom_Audit
ADD (USER_DEFINED_AUDIT_GROUP)
WITH (STATE = ON)
GO

-- Step 3 - call sp_audit_write directly
EXEC sp_audit_write @user_defined_event_id = 999, 
                    @succeeded = 1,
                    @user_defined_information = N'Example call to sp_audit_write'


-- Step 4 - demonstrate how a custom event appears in the audit 
SELECT user_defined_event_id, succeeded, user_defined_information
FROM sys.fn_get_audit_file ('C:\Classfiles\Demofiles\Mod04\Audit\Custom_Audit*',default,default)
WHERE user_defined_event_id = 999

-- Step 5 - demonstrate the use of sp_audit_write in a stored procedure
USE AdventureWorks2019
GO

If Exists(SELECT 1 from sys.views WHERE name='vOrderDetails' and type='V') DROP VIEW Sales.vOrderDetails
GO
CREATE VIEW Sales.vOrderDetails
AS
SELECT SalesOrderID as OrderID, ProductID, UnitPriceDiscount as Discount
FROM Sales.SalesOrderDetail
GO

If Exists(SELECT 1 from sys.procedures WHERE name='usp_OrderDetailDiscount' and type='P') DROP PROCEDURE usp_OrderDetailDiscount
GO
CREATE PROCEDURE usp_OrderDetailDiscount
	@orderid int,
	@productid int,
	@discount numeric(4,3)
AS
	SET NOCOUNT ON

	IF @discount > 0.01
	BEGIN
		DECLARE @msg nvarchar(4000) = 
		  CONCAT('Order=',@orderid,':Product=',@productid,
		         ':discount=', @discount)

		
		EXEC sp_audit_write @user_defined_event_id = 998, 
				            @succeeded = 1,
						    @user_defined_information = @msg
	END

	UPDATE Sales.vOrderDetails
	SET discount = @discount
	WHERE orderid = @orderid
	AND productid = @productid
GO

-- Step 6 - call the stored procedure twice
-- the first call should not generate a custom audit event
-- the second call should generate a custom audit event
EXEC dbo.usp_OrderDetailDiscount @orderid = 46616,@productid =	715, @discount = 0.00
EXEC dbo.usp_OrderDetailDiscount @orderid = 46616,@productid =	760, @discount = 0.05

-- Step 7 - examine the audit data
SELECT user_defined_event_id, succeeded, user_defined_information
FROM sys.fn_get_audit_file ('C:\Classfiles\Demofiles\Mod04\Audit\Custom_Audit*',default,default)
WHERE user_defined_event_id = 998

-- Step 8 - drop the audit
USE master
GO
ALTER SERVER AUDIT Custom_Audit WITH (STATE = OFF)
DROP SERVER AUDIT Custom_Audit
GO

ALTER SERVER AUDIT SPECIFICATION UserDefinedEvents WITH (STATE = OFF);
DROP SERVER AUDIT SPECIFICATION UserDefinedEvents
GO
