

SELECT * FROM msdb.dbo.syssubsystems 
WHERE start_entry_point ='PowerShellStart'


C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\SQLPS.exe

Use msdb
go
SP_CONFIGURE 'allow updates', 1 
RECONFIGURE WITH OVERRIDE 

begin tran
update msdb.dbo.syssubsystems
set agent_exe = 'D:\SQLFiles\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\SQLPS.exe'
WHERE start_entry_point ='PowerShellStart'

select * from msdb.dbo.syssubsystems

sp_configure 'allow updates', 0 
RECONFIGURE WITH OVERRIDE 

SELECT * FROM msdb.dbo.syssubsystems WHERE start_entry_point ='PowerShellStart'

sp_helpdb msdb

restore database msdb2
from disk = 'G:\SQLBackups\ScheduledBackups\MTACPRD13\msdb_MTACPRD13_DB_20130304010542533.BAK'
with move 'MSDBData' to 'E:\SQLFiles\MSSQL10.MTACPRD13\MSSQL\DATA\MSDBData2.mdf',
move 'MSDBLog' to 'E:\SQLFiles\MSSQL10.MTACPRD13\MSSQL\DATA\MSDBLog2.ldf'

name	fileid	filename
MSDBData	1	E:\SQLFiles\MSSQL10.MTACPRD13\MSSQL\DATA\MSDBData.mdf
MSDBLog	2	E:\SQLFiles\MSSQL10.MTACPRD13\MSSQL\DATA\MSDBLog.ldf

use msdb
go
select * from syssubsystems


update msdb.dbo.syssubsystems
set agent_exe = 
where subsystem_id = 1

begin tran
select t1.subsystem, t1.agent_exe, t2.agent_exe
--update t1 set t1.agent_exe = t2.agent_exe
from msdb.dbo.syssubsystems t1
inner join msdb2.dbo.syssubsystems t2
 on t1.subsystem_id = t2.subsystem_id
commit tran
 
 
exec msdb.dbo.fn_syspolicy_is_automation_enabled()

select *  FROM msdb.dbo.syspolicy_configuration 
        WHERE name = 'Enabled' 

sp_helptext fn_syspolicy_is_automation_enabled
