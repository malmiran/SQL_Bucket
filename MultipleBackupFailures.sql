/* CHECKING FIXING MULTIPLE BACKP FAILURES */

declare @success_date datetime
       ,@curr_date datetime
       ,@bk_start_time datetime
       ,@drive_letter char(1)

set @success_date = '03/02/2011'
set @curr_date = '03/03/2010'
set @bk_start_time = '19:00'
set @drive_letter = 'H'

/* DO NOT CHANGE ANYTHING BEYOND THIS POINT */
declare @success_start_date datetime, @success_@end_date datetime
       ,@curr_start_date datetime, @curr_end_date datetime

select @success_start_date = @success_date + @bk_start_time
select @success_@end_date = @success_start_date + '23:59:59.997' --plus 24 hours
--select @success_start_date, @success_@end_date
       
select @curr_start_date = @curr_date + @bk_start_time
select @curr_end_date = @curr_start_date + '23:59:59.997'
--select @curr_start_date, @curr_end_date

create table #db_list
(
   db_name varchar(50)
) 

insert #db_list (db_name) 
select distinct DatabaseName
from DBAdmin..DBBackupHistory
where Backup_Start_DateTime between @success_start_date and @success_@end_date
and DatabaseName not in
(
   select DatabaseName from DBAdmin..DBBackupHistory
   where Backup_Start_DateTime between @curr_start_date  and @curr_end_date 
)

select COUNT(*)[# of backups that failed] from #db_list

select sum(CONVERT(dec(15, 2), backup_size /1024 /1024)) [est_total_size_of_backups_mb]
--select database_name
FROM msdb.dbo.backupset
where backup_start_date between @success_start_date and @success_@end_date
and type = 'D'
and database_name in (select DB_NAME from #db_list)

drop table #db_list

create table #drive_space
(
   backup_drive char(1),
   free_space_mb int
)

insert #drive_space (backup_drive, free_space_mb) exec master..xp_fixeddrives

select * from #drive_space where backup_drive = @drive_letter

drop table #drive_space


select  'EXEC DBAdmin..mbl_RunBKP ' + '''' + DatabaseName + ''',' + '''ADHOC''' + ',' + '''BKP''' [adhoc_backup_statements]
from DBAdmin..DBBackupHistory
where Backup_Start_DateTime between @success_start_date and @success_@end_date
and DatabaseName not in
(
   select DatabaseName from DBAdmin..DBBackupHistory
   where Backup_Start_DateTime between @curr_start_date  and @curr_end_date 
)

