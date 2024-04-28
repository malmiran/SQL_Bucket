
/** SQL 2005 AND 2008 only **/

--GET DR_LOADER
declare @dbname varchar(50)
set @dbname = 'Recfind_MFG' -- paste database name here

select backupsetid, drfilename, backup_start_datetime, status, prodfilename
from DBAdmin..dr_loader
where planname = 'TRN'
and databasename = @dbname
and backupsetid >= 
(
  select max(backupsetid)
  from DBAdmin..DR_Loader 
  where planname = 'TRN'
  and status = 'Y'
  and databasename = @dbname
)
order by 1


--WORKSPACE

/*
H:\SQLBackups\DR_Dumps\MMCADRP01\imanage_web8_del_prd_MMCAPRD09_TRN_20111016043002913.TRN --y
H:\SQLBackups\DR_Dumps\MMCADRP01\imanage_web8_del_prd_MMCAPRD09_TRN_20111016050004010.TRN --e

\\NTDELDBP103\d\SQLBackups\ScheduledBackups\MMCAPRD09\

RESTORE LOG "imanage_web8_del_prd" FROM  DISK='H:\SQLBackups\DR_Dumps\MMCADRP01\imanage_web8_del_prd_MMCAPRD09_TRN_20111016044504220.TRN' WITH NORECOVERY 

*/

--UPDATE DR_LOADER
/*
declare @dbname varchar(50)
set @dbname = 'imanage_web8_del_prd' -- paste database name here

update DBAdmin..dr_loader set status = 'N'
--select backupsetid, drfilename, backup_start_datetime, status, prodfilename from DBAdmin..dr_loader
where planname = 'TRN'
and databasename = @dbname
and status in ('E')
and backupsetid >= 
(
  select max(backupsetid)
  from DBAdmin..DR_Loader 
  where planname = 'TRN'
  and status = 'Y'
  and databasename = @dbname
)

--UPDATE 1 RECORD
select  backupsetid, drfilename, backup_start_datetime, status, prodfilename from DBAdmin..DR_Loader
--UPDATE DBAdmin..DR_Loader set Status = 'Y'
where BackupSetID = 20110516134802977
--and databasename = 'audit_actions_prd'
and DRFileName = 'H:\SQLBackups\DR_Dumps\MRMGDRP01\audit_actions_prd_MRMGPRD01_TRN_20110516131805443.TRN'
order by 1

*/


/* SQL 2000

declare @dbname varchar(50)
set @dbname = 'SnS_PRD' -- paste database name here

select DRFileName, ProdDumpEndDate, Status, ProdFileName from DBAdmin..DR_LOADER
where DumpType = 'TRN'
and DBname = @dbname
and ProdDumpEndDate >=
(
  select max(ProdDumpEndDate)
  from DBAdmin..DR_LOADER
  where DumpType = 'TRN'
  and Status = 'Y'
  and DBname = @dbname
)
order by 2

d:\SQLBackups\DR_Dumps\MMFGDRP03\portiaapo_tlog_201103051850.TRN   
d:\SQLBackups\DR_Dumps\MMFGDRP03\portiaapo_tlog_201103051910.TRN   
portiaapo_tlog_201103051910
\\NTLAXDBP105\d$\SQLBackups\ScheduledBackups\MMFGPRD03\galdat_tlog_201103070005.TRN   

d:\SQLBackups\DR_Dumps\MMFGDRP03\portiaapo_tlog_201103051950.TRN   

Restore Log "portiaapo" 
From Disk='d:\SQLBackups\DR_Dumps\MMFGDRP03\portiaapo_tlog_201103072350.TRN'
WITH NORECOVERY 


update DBAdmin..DR_LOADER set Status = 'N'
where DumpType = 'TRN'
and DBname = @dbname
and Status in('E')
and ProdDumpEndDate >=
(
  select max(ProdDumpEndDate)
  from DBAdmin..DR_LOADER
  where DumpType = 'TRN'
  and Status = 'Y'
  and DBname = @dbname
)

*/