
--CREATE LOGIN (WINDOWS-AUTH)
create login [] from windows
go

--CREATE LOGIN (SQL-AUTH)
create login [cguillotte] with password = 'cX8dy$qv3'
go

--CREATE USER
create user [] for login []
go

--GRANT USER DB ROLE MEMBERSHIP
sp_addrolemember 'rolename','username'
go

--REVOKE USER DB ROLE MEMBERSHIP
sp_droprolemember 'rolename','username'
go

--GRANT LOGIN SERVER ROLE MEMBERSHIP
sp_addsrvrolemember @rolename='sysadmin',@loginame='test1'
go

--REVOKE LOGIN SERVER ROLE MEMBERSHIP
sp_dropsrvrolemember  @rolename='sysadmin',@loginame='test1'
go


--DISPLAY SERVER PERMISSIONS EXPLICITLY GRANTED
select @@SERVERNAME[instance], GETDATE()[current_time]
go
select pr.name, pm.permission_name, pm.state_desc
from sys.server_principals pr
inner join sys.server_permissions pm
  on pr.principal_id = pm.grantee_principal_id
where pr.name in (
'Login'
)

--DISPLAY DB PERMISSIONS EXPLICITLY GRANTED
select DB_NAME()[db], GETDATE()[current_time]
go
select pr.name, pm.permission_name, pm.state_desc
from sys.database_principals pr
inner join sys.database_permissions pm
  on pr.principal_id = pm.grantee_principal_id
where pr.name in (
'UserOrRole'
)  

--DISPLAY A USER'S DB ROLE
select DB_NAME()[db], GETDATE()[current_time]
go
select t1.name[user],t3.name[role]
from sys.database_principals t1
inner join sys.database_role_members t2
  on t1.principal_id = t2.member_principal_id
inner join (select name, principal_id from sys.database_principals) t3
  on t2.role_principal_id = t3.principal_id
where t1.name in  (
'User'
)  

--DISPLAY A USER'S OWNED SCHEMA
select DB_NAME()[db], GETDATE()[current_time]
go
select t1.name[schema], t2.name[owner]
from sys.schemas t1
inner join sys.database_principals t2
 on t1.principal_id = t2.principal_id
where t2.name = 'NTADMIN\SGG-MFG-DocFinSupport-X-Accts'

--DISPLAY EFFECTIVE PERMISSIONS (doesn't work with Windows groups)
--SERVER LEVEL
EXECUTE AS user = 'test1'
SELECT * FROM fn_my_permissions(NULL,'SERVER')
--REVERT

--DB LEVEL
EXECUTE AS user = 'test1'
SELECT * FROM fn_my_permissions(NULL,'DATABASE')
--REVERT

--SYSTEM STORED PROCS FOR SECURITY
sp_helplogins @LoginNamePattern = 'test1'
sp_helpuser @name_in_db = 'test1'
sp_helprolemember @rolename = ''
sp_helpsrvrolemember @srvrolename = ''


/*

select * from sys.server_permissions

select @@SERVERNAME[instance], GETDATE()[current_time]
go
select pr.name, pm.permission_name, pm.state_desc
from sys.server_principals pr
inner join sys.server_permissions pm
  on pr.principal_id = pm.grantee_principal_id
where pr.name in (
'NTADMIN\SGG-MFG-DocFinSupport-X-Accts'
)

select DB_NAME()[db]
go
select t1.name[user],t3.name[role]
from sys.database_principals t1
inner join sys.database_role_members t2
  on t1.principal_id = t2.member_principal_id
inner join (select name, principal_id from sys.database_principals) t3
  on t2.role_principal_id = t3.principal_id
where t1.name in  (
'NTADMIN\SGG-MFG-DocFinSupport-X-Accts'
)  

select pr.name, pm.permission_name, pm.state_desc
from sys.database_principals pr
inner join sys.database_permissions pm
  on pr.principal_id = pm.grantee_principal_id
where pr.name in (
'NTADMIN\SGG-MFG-DocFinSupport-X-Accts'
)  

execute as user = 'NTADMIN\SGG-MFG-DocFinSupport-X-Accts'
go
select * from fn_my_permissions(NULL,'SERVER')

*/