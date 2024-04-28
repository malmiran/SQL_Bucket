
Pankaj Sharma
Andriy Proskuryakov
Steve Mock
Praneet Kothavade

psharma5
aproskur
smock
pkothava

use stf_ny_prd
go

select l.name, u.name
from sys.syslogins l, sys.sysusers u
where l.sid = u.sid
and l.name like '%prapxny_exec%'


create login [NTADMIN\pkothava] from windows
go
create user [NTADMIN\pkothava] from login [NTADMIN\pkothava]
go


SELECT distinct dp.NAME [principal_name] ,dp.type_desc [principal_type_desc]
,o.[name] [object_name] ,p.permission_name ,p.state_desc [permission_state_desc]
FROM sys.database_permissions p
LEFT JOIN sys.all_objects o ON p.major_id = o.OBJECT_ID
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = 'prapxny_exec' -- specify the principal name (db user, role, etc.)
and o.is_ms_shipped <> 1 -- Optional: 1 to display permssions on system objects; otherwise, user-defined
order by object_name

sp_helpuser prapxny_exec

sp_addrolemember 'db_datareader','NTADMIN\pkothava'
go
sp_addrolemember 'db_datawriter','NTADMIN\pkothava'
go

psharma5
aproskur
smock
pkothava

sp_helpuser 'NTADMIN\psharma5'

select l.name[login], u.name[user],DB_NAME()[database], @@SERVERNAME[sql_instance]
from sys.syslogins l, sys.sysusers u
where l.sid = u.sid
and l.name in (
'NTADMIN\psharma5'
,'NTADMIN\aproskur'
,'NTADMIN\smock'
,'NTADMIN\pkothava'
)

select t1.name[user],t3.name[role]
from sys.database_principals t1
inner join sys.database_role_members t2
  on t1.principal_id = t2.member_principal_id
inner join (select name, principal_id from sys.database_principals) t3
  on t2.role_principal_id = t3.principal_id
where t1.name in (
'NTADMIN\psharma5'
,'NTADMIN\aproskur'
,'NTADMIN\smock'
,'NTADMIN\pkothava'
)

sp_help vpnl_summary


SELECT distinct dp.NAME [principal_name] ,dp.type_desc [principal_type_desc]
,o.[name] [object_name] ,p.permission_name ,p.state_desc [permission_state_desc]

select 'GRANT EXECUTE on dbo.' + o.[name] + ' to [' + dp.[name] + ']'
FROM sys.database_permissions p
LEFT JOIN sys.all_objects o ON p.major_id = o.OBJECT_ID
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = 'prapxny_exec' -- specify the principal name (db user, role, etc.)
and o.is_ms_shipped <> 1 -- Optional: 1 to display permssions on system objects; otherwise, user-defined

GRANT EXECUTE on dbo.sp_getSequence to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.getPreviousDate to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.TIMESTR to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.sp_addManualTrade to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.sp_addOrderDetail to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.sp_updateInstData to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.sp_addOrUpdatePNLSummary to [NTADMIN\pkothava]
GRANT EXECUTE on dbo.sp_addOrder to [NTADMIN\pkothava]

'NTADMIN\psharma5'
,'NTADMIN\aproskur'
,'NTADMIN\smock'
,'NTADMIN\pkothava'


SELECT distinct dp.NAME [principal_name] ,dp.type_desc [principal_type_desc]
,o.[name] [object_name] ,p.permission_name ,p.state_desc [permission_state_desc]
FROM sys.database_permissions p
LEFT JOIN sys.all_objects o ON p.major_id = o.OBJECT_ID
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name in (
'NTADMIN\psharma5'
,'NTADMIN\aproskur'
,'NTADMIN\smock'
,'NTADMIN\pkothava'
) -- specify the principal name (db user, role, etc.)
and o.is_ms_shipped <> 1 -- Optional: 1 to display permssions on system objects; otherwise, user-defined
order by 1,2