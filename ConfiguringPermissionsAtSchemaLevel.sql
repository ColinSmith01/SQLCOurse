--Module 03 - Configure Permissions at the Schema Level

-- Step 1: Use the AdventureWorks database.
USE AdventureWorks2019
GO

-- Step 2: Revoke Mod03User's permission to execute dbo.uspGetManagerEmployees
REVOKE EXECUTE ON dbo.uspGetManagerEmployees FROM Mod03User
GO

-- Step 3: Check if the Mod03Login can execute the procedure.
--         Note that execution is denied.
EXECUTE AS USER = 'Mod03User'
GO

EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 2
GO

REVERT
GO

-- Step 4: Grant EXECUTE on the dbo schema to Mod03Login.
GRANT EXECUTE ON SCHEMA::dbo TO Mod03User
GO

-- Step 5: Check if the Mod03Login can execute the procedure.
EXECUTE AS USER = 'Mod03User'
GO
EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 2
GO

REVERT
GO

-- Step 6: Deny execution on dbo.uspGetManagerEmployees.
DENY EXECUTE ON dbo.uspGetManagerEmployees TO Mod03Login
GO

-- Question: Which permission setting will prevail?
-- EXECUTE at the schema level or DENY at the procedure level?


-- Step 7: Check if the Mod03Login can execute the procedure.
--         Note that execution is not permitted.
EXECUTE AS USER = 'Mod03User'
GO

EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 2
GO

REVERT
GO

-- Step 8: Use the tempdb database.
USE tempdb
GO

-- Step 9: Create the ImplyingPermissions function (from BOL)
CREATE FUNCTION dbo.ImplyingPermissions (@class nvarchar(64), @permname nvarchar(64))
RETURNS TABLE
AS
RETURN (
   WITH 
   class_hierarchy(class_desc, parent_class_desc)
   AS
   (
   SELECT DISTINCT class_desc, parent_class_desc 
      FROM sys.fn_builtin_permissions('')
   ),
   PermT(class_desc, permission_name, covering_permission_name,
      parent_covering_permission_name, parent_class_desc)
   AS
   (
   SELECT class_desc, permission_name, covering_permission_name,
      parent_covering_permission_name, parent_class_desc
      FROM sys.fn_builtin_permissions('')
   ),
   permission_covers(permission_name, class_desc, level,
      inserted_as)
   AS
    (
    SELECT permission_name, class_desc, 0, 0
       FROM PermT
       WHERE permission_name = @permname AND
       class_desc = @class
    UNION ALL
    SELECT covering_permission_name, class_desc, 0, 1
       FROM PermT 
       WHERE class_desc = @class AND 
          permission_name = @permname AND
          len(covering_permission_name) > 0
    UNION ALL
    SELECT PermT.covering_permission_name, 
       PermT.class_desc, permission_covers.level,
       permission_covers.inserted_as + 1
       FROM PermT, permission_covers WHERE
       permission_covers.permission_name =
       PermT.permission_name AND
       permission_covers.class_desc = PermT.class_desc 
       AND len(PermT.covering_permission_name) > 0
    UNION ALL
    SELECT PermT.parent_covering_permission_name,
       PermT.parent_class_desc,
       permission_covers.level + 1,
       permission_covers.inserted_as + 1
       FROM PermT, permission_covers, class_hierarchy
       WHERE permission_covers.permission_name =
       PermT.permission_name AND 
       permission_covers.class_desc = PermT.class_desc
       AND permission_covers.class_desc = class_hierarchy.class_desc
       AND class_hierarchy.parent_class_desc =
       PermT.parent_class_desc AND
       len(PermT.parent_covering_permission_name) > 0
    )
  SELECT DISTINCT permission_name, class_desc, 
     level, max(inserted_as) AS mia 
     FROM permission_covers
     GROUP BY class_desc, permission_name, level)
GO

-- Step 10: Explore which permissions imply the ability to SELECT from a schema.
SELECT * FROM dbo.ImplyingPermissions('schema', 'select')
GO

-- Step 11: Explore which permissions imply the ability to view the definition of an object.
SELECT * FROM dbo.ImplyingPermissions('object', 'view definition')
GO

-- Step 12: Explore which permissions imply the ability to SELECT from an object.
SELECT * FROM dbo.ImplyingPermissions('object', 'select')
GO

-- Step 13: Drop the Mod03Login user and login.
USE AdventureWorks2019
GO
DROP USER Mod03User
GO

USE master
GO
DROP LOGIN Mod03Login
GO


