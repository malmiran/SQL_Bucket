--SAVE USERS
EXEC mpw_cards_prd..sp_mbl_loaddb_save_users 'mpw_cards_prd'

RESTORE FILELISTONLY
FROM DISK = 'H:\SQLBackups\SpecialBackups\MGI_EquityPlus_UAT_INC8898285.BAK'

MGI_EquityPlus_UAT
MGI_EquityPlus_UAT_log

sp_helpdb MGI_EquityPlus_UAT
H:\DBData\Data001\MGI_EquityPlus_UAT_Data.mdf
H:\DBLog\TLog001\MGI_EquityPlus_UAT_Log.ldf

USE master
GO
RESTORE DATABASE MGI_EquityPlus_UAT
FROM DISK = 'H:\SQLBackups\SpecialBackups\MGI_EquityPlus_UAT_INC8898285.BAK'
WITH MOVE 'MGI_EquityPlus_UAT' TO 'H:\DBData\Data001\MGI_EquityPlus_UAT_Data.mdf',
MOVE 'MGI_EquityPlus_UAT_log' TO 'H:\DBLog\TLog001\MGI_EquityPlus_UAT_Log.ldf',
REPLACE

EXEC MGI_EquityPlus_UAT..sp_changedbowner 'sa'
GO
ALTER DATABASE MGI_EquityPlus_UAT SET RECOVERY SIMPLE
GO
ALTER DATABASE MGI_EquityPlus_UAT SET PAGE_VERIFY CHECKSUM WITH NO_WAIT
GO
ALTER DATABASE [MGI_EquityPlus_UAT] SET COMPATIBILITY_LEVEL = 100;
GO
DBCC UPDATEUSAGE ('MGI_EquityPlus_UAT')
GO

--Check MAXSIZE properties
SP_HELPDB MGI_EquityPlus_UAT

--Modify MAXSIZE (*5)
ALTER DATABASE [MGI_EquityPlus_UAT]
MODIFY FILE(NAME=MGI_EquityPlus_UAT, MAXSIZE=2621440)
GO
ALTER DATABASE [MGI_EquityPlus_UAT]
MODIFY FILE(NAME=MGI_EquityPlus_UAT_log, MAXSIZE=1310720)
GO
ALTER DATABASE [MGI_EquityPlus_UAT]
MODIFY FILE(NAME=MGI_EquityPlus_UAT, MAXSIZE=2621440)
GO
ALTER DATABASE [MGI_EquityPlus_UAT]
MODIFY FILE(NAME=MGI_EquityPlus_UAT_log, MAXSIZE=1310720)
GO

--Reinstate Users
EXEC MGI_EquityPlus_UAT.dbo.sp_mbl_loaddb_drop_users 'MGI_EquityPlus_UAT';

EXEC DBAdmin.dbo.mbl_FixUsers 'MGI_EquityPlus_UAT'

--Run the CREATE USER script from sp_mbl_loaddb_save_users above

CREATE LOGIN [EQPTORUA_EXEC] WITH PASSWORD = 0x01007A4467B10A89D5B5BCB858E20F0F3A16EA32FDAE01461659 HASHED, SID = 0x4017AA76EAF7484BB8491BDAE86C6B62, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF

USE MGI_EquityPlus_UAT
GO
CREATE USER  [EQPTORUA_EXEC] FOR LOGIN [EQPTORUA_EXEC]
GO
sp_addrolemember 'db_datareader','EQPTORUA_EXEC'
GO
sp_addrolemember 'db_datawriter','EQPTORUA_EXEC'
GO

CREATE LOGIN [NTADMIN\EQPTORUA_EXEC] FROM WINDOWS WITH DEFAULT_DATABASE = [MGI_EquityPlus_UAT]

USE MGI_EquityPlus_UAT
GO
CREATE USER  [NTADMIN\EQPTORUA_EXEC] FOR LOGIN [NTADMIN\EQPTORUA_EXEC]
GO
sp_addrolemember 'db_datareader','NTADMIN\EQPTORUA_EXEC'
GO
sp_addrolemember 'db_datawriter','NTADMIN\EQPTORUA_EXEC'
GO


declare @db_name varchar(50)
set @db_name = 'MGI_EquityPlus_UAT'
select distinct
      SourceDB    = b.database_name,
      DestinationDB  = destination_database_name,      
      BackupDate  = backup_start_date,
      RestoreDate = restore_date,
      BackupFile = physical_device_name,
      Restored_by = h.[user_name]
from msdb..restorehistory h
inner join msdb..backupset b
      on h.backup_set_id = b.backup_set_id
inner join msdb..backupfile f
      on f.backup_set_id = b.backup_set_id
inner join msdb..backupmediafamily m
      on b.media_set_id = m.media_set_id
where destination_database_name = @db_name
order by RestoreDate desc
go


