-- Basic health check script MSSQL
-- Checks sql server service, sql agent service, and sql browser service 
-- Checks status of db mirroring if databases are mirrored
-- Checks which databases are offline or online

set nocount on

/* CHECK SQL SERVER AND AGENT SERVICE */
if(substring(convert(varchar(32),serverproperty('ProductVersion')),1,1)) = '8' --> SQL 2000
begin
print ''
print 'Checking MSSQLSERVER service...' 
exec master..xp_servicecontrol 'QueryState', 'MSSQLSERVER' 
print ''
print 'Checking SQLSERVERAGENT service...' 
exec master..xp_servicecontrol 'QueryState', 'SQLSERVERAGENT' 
print ''
end

if(substring(convert(varchar(10),serverproperty('ProductVersion')),1,1)) = '9' --> SQL 2005
OR (substring(convert(varchar(10),serverproperty('ProductVersion')),1,2)) = '10' --> SQL 2008
begin
print ''
print 'Checking DB engine in ' + @@servername 
exec master..xp_servicecontrol 'QueryState', 'MSSQL' 
--print ''
print 'Checking SQLAgent in ' + @@servername 
exec master..xp_servicecontrol 'QueryState', 'SQLAgent' 
--print ''
print 'Checking SQL Browser in ' + @@servername
exec master..xp_servicecontrol 'QueryState', 'SQLBROWSER' 
--print ''
print 'Checking SSIS in ' + @@servername
exec master..xp_servicecontrol N'querystate',N'msdtc'
--print ''
/*
print 'Checking SSRS in ' + @@servername
exec master..xp_servicecontrol N'querystate',N'ReportServer'
print ''
*/
end


/* CHECK LAST TIME SQL SERVER WAS RESTARTED */
select getdate() as CURRENT_DATETIME, crdate as [LAST_SQLSERVER_RESTART] from master..sysdatabases where name = 'tempdb'
print ''

/* CHECK IF DBs ARE ALL ONLINE */

print ''
SELECT name[Database],CASE WHEN status & 960 = 0 AND DATABASEPROPERTY(name, 'issingleuser') = 0 and (has_dbaccess(name) = 1 OR status & 32 <> 0) THEN 'ONLINE' ELSE 'OFFLINE' END [Status] FROM master..sysdatabases ORDER BY 1


/* CHECK IF DBs ARE MIRRORED AND SYNCHRONIZED */
if(substring(convert(varchar(10),serverproperty('ProductVersion')),1,1)) = '9' --> SQL 2005
OR (substring(convert(varchar(10),serverproperty('ProductVersion')),1,2)) = '10' --> SQL 2008
begin
if exists (
select top 1 m.*
from sys.sysdatabases b
inner join sys.database_mirroring m on b.name = db_name(m.database_id)
where m.mirroring_state is not null and mirroring_state <> 4
) 
begin
print ''
print 'The following databases are mirrored but are not synchronized: '
print ''
select b.name, m.mirroring_state_desc
from sys.sysdatabases b
inner join sys.database_mirroring m on b.name = db_name(m.database_id)
where m.mirroring_state is not null and mirroring_state <> 4
end
end
