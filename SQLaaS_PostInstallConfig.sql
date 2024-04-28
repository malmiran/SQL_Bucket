
/* Re-install DBAdmin / Extra DBAdmin SETUP */

-- Run script as a whole in new window (see doco)

/********************************************/


/* Setup SQL Agent DBAInfra Jobs */

use dbadmin
go
exec mbl_ProcessBackups 'POPULATE','BKP','POPULATE'
go
exec mbl_ProcessBackups 'POPULATE','TRN','POPULATE'
go

--Check results
select * from DBAdmin..ConfigPlans where PlanName in ('BKP','TRN')

--Get SVC Account
DECLARE @engineaccount VARCHAR(100), @agentaccount VARCHAR(100)

EXECUTE master.dbo.xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER',
N'ObjectName',
@engineaccount OUTPUT,
N'no_output'

EXECUTE master.dbo.xp_instance_regread 
N'HKEY_LOCAL_MACHINE',
N'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT',
N'ObjectName',
@agentaccount OUTPUT,
N'no_output'

SELECT @engineaccount as SQLServer_ServiceAccount,
       @agentaccount AS SQLAgent_ServiceAccount

--ntadmin\srvc_sql_M324CDRP09

--Add SVC Account on NTSYDDBP1173\MITSPRD20,55550

--TSX.1 Set Encryption level on TSX
--(MSSQL10.<sql instance name> for SQL 2008 instances)
--(MSSQL10_50.<sql instance name> for SQL 2008 R2 instances)
DECLARE @cmd VARCHAR(MAX)
SELECT @@SERVICENAME 
EXEC master..xp_regwrite 
'HKEY_LOCAL_MACHINE'
,'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10_50.M324CDRP09\SQLServerAgent'
,'MsxEncryptChannelOptions'
,'REG_DWORD'
,1;
GO

--TSX.2 Add MSX server account to TSX as sysadmin
USE [master]
GO
CREATE LOGIN [NTADMIN\SRVC_SQL_ITS_PRD] FROM WINDOWS;
GO
EXEC master..sp_addsrvrolemember @loginame = N'NTADMIN\SRVC_SQL_ITS_PRD', @rolename = N'sysadmin'
GO

--TSX.3 Enlist (register) TSX with MSX
EXEC msdb.dbo.sp_msx_enlist N'NTSYDDBP1173\MITSPRD20,55550'
GO

--TSX.4 Remove MSX server account to TSX as sysadmin
DROP LOGIN [NTADMIN\SRVC_SQL_ITS_PRD]
GO

/********************************************/

/* Configure Resource Governor */

-- Run script as a whole in new window (see doco)

/********************************************/

/********************************************/

/* Configure SQL Server Auditing */

-- Run script as a whole in new window (see doco)

/********************************************/


create login [NTADMIN\mssql_dba] from windows;
go
sp_addsrvrolemember 'NTADMIN\mssql_dba','sysadmin'


INSERT INTO DBAdmin..ConfigCleanup 
VALUES ('M:\SQLBackups\SpecialBackups',10,'YES');
GO

select * from  DBAdmin..ConfigCleanup 
 