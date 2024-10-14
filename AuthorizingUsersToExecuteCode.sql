--Module 03 - Authorizing Users to Execute Code

-- Step 1: Use the AdventureWorks database.
USE AdventureWorks2019
GO

-- Step 2: Change execution context to Mod03User.
EXECUTE AS USER = 'Mod03User'
GO

-- Step 3: Try to execute a stored procedure without granting permissions.
EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 2
GO

-- Step 4: Revert to Administrator security context.
REVERT
GO

-- Step 5: Grant EXECUTE on the stored procedure to Mod03Login.
GRANT EXECUTE ON dbo.uspGetManagerEmployees TO Mod03User
GO

-- Step 6: Change execution context to Mod03Login.
EXECUTE AS USER = 'Mod03User'
GO

-- Step 7: Try to execute a stored procedure with permissions granted.
EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 2
GO

-- Step 8: While still Mod03User, try to SELECT a value from a function. 
-- Note: EXECUTE permissions are needed for scalar functions as with procedures.
SELECT dbo.ufnGetStock(2)
GO

-- Step 9: Revert to Administrator security context.
REVERT
GO

-- Step 10: Grant execute permission on the function. 
GRANT EXECUTE ON dbo.ufnGetStock TO public
GO

-- Step 11: Attempt to access the function as Mod03User again.
EXECUTE AS USER = 'Mod03User'
GO

SELECT dbo.ufnGetStock(2)
GO

REVERT
GO

