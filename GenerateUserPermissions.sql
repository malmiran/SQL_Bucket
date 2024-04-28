-- Generate permissions SQL Script
WITH    perms_cte as
(
        select dp. default_schema_name AS                default_schema_name_for_principal_name,
        SUSER_SNAME(dp .sid) AS principal_login_name ,
        USER_NAME(p .grantee_principal_id) AS principal_name ,
        dp .principal_id,
        dp .type_desc AS principal_type_desc,
        p .class_desc,
        OBJECT_NAME(p .major_id) AS object_name,
        OBJECT_SCHEMA_NAME (p. major_id) AS object_schema_name,
        SCHEMA_NAME(p .major_id) AS schema_name,
        p .permission_name,
        p .state_desc AS permission_state_desc

        from    sys.database_permissions p
        inner   JOIN sys.database_principals dp
        on     p. grantee_principal_id = dp .principal_id
)
--Create user statements
SELECT
CASE p. principal_type_desc
WHEN 'SQL_USER' THEN 'CREATE USER [' + p.principal_name + '] FOR LOGIN [' + p.principal_login_name + '] WITH DEFAULT_SCHEMA = [' + p.default_schema_name_for_principal_name + '];'
WHEN 'WINDOWS_USER' THEN 'CREATE USER [' + p.principal_name + '] FOR LOGIN [' + p. principal_login_name + '] WITH DEFAULT_SCHEMA = [' + p.default_schema_name_for_principal_name + '];'
ELSE 'CREATE USER [' + p .principal_name + '] FOR LOGIN [' + p.principal_login_name + '];'
END COLLATE database_default
FROM    perms_cte p
WHERE  p. permission_name = 'CONNECT' and p.principal_name <> 'dbo'

UNION

-- individual user permissions
SELECT
CASE p. class_desc
WHEN 'DATABASE' THEN 'GRANT ' + p.permission_name + ' TO [' + p .principal_name + '];'
WHEN 'OBJECT_OR_COLUMN' THEN 'GRANT ' + p.permission_name + ' ON OBJECT::[' + p.[object_schema_name] + '].[' + p. [object_name] + '] TO [' + p.principal_name + '];'
WHEN 'SCHEMA' THEN 'GRANT ' + p.permission_name + ' ON SCHEMA::[' + p.[schema_name] + '] TO [' + p. principal_name + '];'
ELSE '-- #### The script for permissions class = ' +p. class_desc+' has NOT been generated. PLEASE create your own SQL script'
END COLLATE database_default
FROM    perms_cte p
WHERE  principal_type_desc <> 'DATABASE_ROLE'
and principal_name <> 'dbo'

UNION

-- role members
SELECT 'exec sp_addrolemember ''' + rm. role_name + ''' , [' + rm.member_principal_name + '];'
FROM    perms_cte p
right outer JOIN (
    select role_principal_id, dp.type_desc as principal_type_desc, member_principal_id,user_name( member_principal_id) as member_principal_name,user_name( role_principal_id) as role_name
    from    sys.database_role_members rm
    INNER   JOIN sys.database_principals dp
    ON     rm. member_principal_id = dp .principal_id
       and   dp. name <> 'dbo'
) rm
ON     rm. role_principal_id = p .principal_id
order by 1
