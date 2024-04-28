select DatabaseName, upper(substring(bk_dest01,1,1))[drive] from DBAdmin..ConfigPlans 
where DatabaseName = 'OperationsManager' and PlanName = 'BKP'
--h

select * from DBAdmin..ConfigPlans
where planname = 'bkp' and disableplan = 'no'

select t2.databasename, t1.state_desc, t2.planname, t2.disableplan
from sys.databases t1
inner join DBAdmin..ConfigPlans t2 on t1.name=t2.databasename
where t1.database_id > 5
and state_desc <> 'ONLINE'

select *
from sys.databases 

select * from DBAdmin..ConfigPlans where databasename = 'OperationsManager' and PlanName like 'BKP%'
select DatabaseName, bk_dest01 from DBAdmin..ConfigPlans where databasename = 'sokmtprd' and PlanName = 'BKP'



exec  INTEGRITY_UAT..sp_spaceused
34,533,232 KB
--75gb

select @@servername
go
master..xp_fixeddrives

drive	MB free
E	58775
--60

dbcc sqlperf(logspace)

--cleanup
SQL2K5/8
EXEC DBAdmin.dbo.mbl_StartMaintPlans  'ADHOC','LoggingCleanup'

SQL2K
EXEC DBAdmin.dbo.StartMaintPlans ADHOC,LoggingCleanup

--backup
SQL2K5/8
EXEC DBAdmin..mbl_RunBKP 'model','ADHOC', 'BKP'

--TRN
EXEC DBAdmin..mbl_RunTRN 'OperationsManager','ADHOC', 'TRN'

SQL2K
EXEC DBAdmin..startmaintplansforadb 'AdhocBKP',  'pbo32', 'BKP'

/*
SCRIPT #1
declare @db_name varchar(100)
set @db_name = 'taxint_prd'

select database_name, backup_start_date, backup_finish_date, type, physical_device_name
from msdb..backupset t1
inner join msdb..backupmediafamily t2
  on t1.media_set_id = t2.media_set_id
where database_name = @db_name
--and backup_start_date between '2010-05-13' and '2010-05-15 23:59:59.997'
and type = 'd' --check only FULL backups
order by backup_start_date desc

restore verifyonly
from disk = 'G:\SQLBackups\SpecialBackups\restore INC8944429\DT_Archive_M324CPRD03_DB_20130308220214330.BAK'

SCRIPT #2
SELECT TOP 1000 type
,user_name
,database_name
,CONVERT(dec(15, 2), backup_size /1024 /1024) size_mb
--,CONVERT(dec(15, 2), compressed_backup_size /1024 /1024) size_mb
,CONVERT(varchar(16), backup_start_date, 121) last_backup_start
,CONVERT(varchar(16), backup_finish_date, 121) last_backup_finish
,DATEDIFF(minute, backup_start_date, backup_finish_date) duration_mins
FROM msdb.dbo.backupset WITH (NOLOCK)
WHERE database_name = 'ChangeAuditor_Archive_2013'
and type='D'
ORDER BY backup_start_date desc


SCRIPT #3
DECLARE @dbname sysname
SET @dbname = 'taxint_prd' --set this to be whatever dbname you want
SELECT bup.user_name AS [User],
 bup.database_name AS [Database],
 bup.server_name AS [Server],
 bup.backup_start_date AS [Backup Started],
 bup.backup_finish_date AS [Backup Finished]
 ,CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))/3600 AS varchar) + ' hours, ' 
 + CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))/60 AS varchar)+ ' minutes, '
 + CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))%60 AS varchar)+ ' seconds'
 AS [Total Time]
FROM msdb.dbo.backupset bup
WHERE bup.backup_set_id IN
  (SELECT MAX(backup_set_id) FROM msdb.dbo.backupset
  WHERE database_name = ISNULL(@dbname, database_name) --if no dbname, then return all
  AND type = 'D' --only interested in the time of last full backup
  GROUP BY database_name) 
/* COMMENT THE NEXT LINE IF YOU WANT ALL BACKUP HISTORY */
AND bup.database_name IN (SELECT name FROM master.dbo.sysdatabases)
ORDER BY bup.database_name

SCRIPT #4
declare @db_name varchar(50)
set @db_name = 'taxint_prd'
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


--Find out what FULL backup the DIFF backups are dependent on
SELECT backup_set_id, database_name, backup_start_date, type, first_lsn, differential_base_lsn, is_copy_only
from msdb..backupset
where database_name = 'HSDB_3Cj85UB6'
order by backup_start_date desc

/** Stefan Posa's Query **/
use msdb

SELECT      backup_set_id
            ,[database_name]
            ,[server_name]
            ,[database_creation_date]
            ,[backup_start_date]
            ,[backup_finish_date]
            ,CONVERT(varchar(12), DATEADD(ms, DATEDIFF(ms, backup_start_date, backup_finish_date), 0), 114) TimeDiff
            ,cast(backup_size/POWER(1024,3) as decimal(9,2)) as [backup_sizeGB]
            --,cast(compressed_backup_size/POWER(1024,3) as decimal(9,2)) compressed_backup_sizeGB
            ,[type]
            ,[recovery_model]
FROM [msdb].[dbo].[backupset]
where [type] = 'd'  and   --D for DB L for log
            --database_name = 'cards_prd' and
            backup_start_date > GETDATE()-1
--order by backup_start_date
order by [backup_sizeGB] desc

*/


select sum(CONVERT(dec(15, 2), backup_size /1024 /1024/1024)) size_gb
FROM msdb.dbo.backupset
where convert(varchar,backup_start_date,101) = '11/01/2012'
and type = 'D'

select round(sum(CONVERT(dec(15, 2), backup_size /1024 /1024/1024)),0) size_gb
FROM msdb.dbo.backupset
where convert(varchar,backup_start_date,101) = '11/01/2012'
and type = 'D'


select round(sum(CONVERT(dec(15, 2), compressed_backup_size /1024 /1024/1024)),0) size_gb
FROM msdb.dbo.backupset
where backup_start_date between '2012-31-10' and '2012-31-10 23:59:59.997'
and type = 'D'

select * FROM msdb.dbo.backupset
where convert(varchar,backup_start_date,101) = '11/01/2012'


DECLARE @dbname sysname
SET @dbname = NULL --set this to be whatever dbname you want
SELECT bup.user_name AS [User],
 bup.database_name AS [Database],
 bup.server_name AS [Server],
 bup.backup_start_date AS [Backup Started],
 bup.backup_finish_date AS [Backup Finished]
 ,CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))/3600 AS varchar) + ' hours, ' 
 + CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))/60 AS varchar)+ ' minutes, '
 + CAST((CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int))%60 AS varchar)+ ' seconds'
 AS [Total Time]
FROM msdb.dbo.backupset bup
WHERE bup.backup_set_id IN
  (SELECT MAX(backup_set_id) FROM msdb.dbo.backupset
  WHERE database_name = ISNULL(@dbname, database_name) --if no dbname, then return all
  AND type = 'D' --only interested in the time of last full backup
  GROUP BY database_name) 
/* COMMENT THE NEXT LINE IF YOU WANT ALL BACKUP HISTORY */
AND bup.database_name IN (SELECT name FROM master.dbo.sysdatabases)
ORDER BY bup.database_name

SELECT * FROM dbadmin..ConfigPlans
where PlanName like 'bkp%'
and DisablePlan <> 'YES'
--27

select database_name, backup_start_date, backup_finish_date, type, physical_device_name
from msdb..backupset t1
inner join msdb..backupmediafamily t2
  on t1.media_set_id = t2.media_set_id
where backup_start_date between '2012-31-10' and '2012-31-10 23:59:59.997'
and type = 'd' --check only FULL backups
order by backup_start_date desc

select backup_set_id, database_name, backup_size--sum(CONVERT(dec(15, 2), backup_size /1024 /1024))
from msdb..backupset t1
inner join msdb..backupmediafamily t2
  on t1.media_set_id = t2.media_set_id
where backup_start_date between '2012-30-10' and '2012-30-10 23:59:59.997'
and type = 'd' --check only FULL backups
group by database_name
order by 2


