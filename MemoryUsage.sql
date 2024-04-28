

SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads DESC -- logical reads
-- ORDER BY qs.total_logical_writes DESC -- logical writes
-- ORDER BY qs.total_worker_time DESC -- CPU time


dbcc memorystatus

select 23756800 + 294172
select 24,050,972/1024

select 96452/1024


select top 10 pro.program_name,pro.cpu,pro.spid,
pro.memusage,pro.physical_io,db.name,pro.status,
pro.last_batch 
from sysprocesses pro,sysdatabases db 
order by memusage desc

where 
--spid > 50 
cpu > 50 
and memusage > 500
and pro.dbid = db.dbid 

select spid, loginame, cmd, hostname, program_name, cpu, memusage, physical_io, login_time, last_batch, sql_handle
from sysprocesses
where spid <> @@spid and loginame <> system_user
--order by cpu desc
order by memusage desc
--order by physical_io desc

select getdate()
--2011-01-20 16:24:16.360
--2011-01-20 16:38:50.790

dbcc memorystatus
Memory Manager	 KB 
VM Committed	178156

SELECT physical_memory_in_bytes/1024 AS physical_memory_in_kb,
       virtual_memory_in_bytes/1024 AS vm_in_kb,
       bpool_committed AS buffer_cache_committed
FROM sys.dm_os_sys_info
go

select counter_name, cntr_value  
FROM sys.dm_os_performance_counters
WHERE counter_name in ('Target Server Memory (KB)','Total Server Memory (KB)')object_name = 'MSSQL$MMSGPRD117:Memory Manager'
and 
go

physical_memory_in_kb	vm_in_kb	buffer_cache_committed
2,096,584	            2,097,024	12,496

SELECT * FROM sys.dm_os_performance_counters

SELECT cntr_value AS 'Page Life Expectancy'
FROM sys.dm_os_performance_counters
WHERE object_name = 'MSSQL$MMSGPRD117:Buffer Manager'
AND counter_name = 'Page life expectancy'


SELECT TOP (10) type, sum(single_pages_kb) AS [SPA Mem, Kb]
FROM sys.dm_os_memory_clerks
GROUP BY type
ORDER BY SUM(single_pages_kb) DESC




SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 [BufferCacheHitRatio] 
FROM 
(
   SELECT *, 1 x FROM sys.dm_os_performance_counters   
   WHERE counter_name = 'Buffer cache hit ratio'
   AND object_name = 'MSSQL$MMSGPRD117:Buffer Manager'
)a,
(
   SELECT *, 1 x FROM sys.dm_os_performance_counters   
   WHERE counter_name = 'Buffer cache hit ratio base'
   and object_name = 'MSSQL$MMSGPRD117:Buffer Manager'
) b



select counter_name, cntr_value/1024/1024[Memory_GB]
FROM sys.dm_os_performance_counters
WHERE counter_name in ('Target Server Memory (KB)','Total Server Memory (KB)')

select distinct object_name
from sys.dm_os_performance_counters
where counter_name = 'Available MBytes'

select *
from sys.dm_os_performance_counters
where object_name in ('MSSQL$MCAGPRD20:Memory Manager', 'MSSQL$MCAGPRD20:Buffer Manager')                                      

Buffer cache hit ratio         
Free list stalls/sec                                                                                                                                Free pages     
Lazy writes/sec                                                                                                                                     Page life expectancy                                                                                                                                Memory Grants Pending                                                                                                                               
                                                                                                                                  
SELECT (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio
FROM sys.dm_os_performance_counters  a
JOIN  (SELECT cntr_value,OBJECT_NAME 
    FROM sys.dm_os_performance_counters  
    WHERE counter_name = 'Buffer cache hit ratio base'
        AND OBJECT_NAME = 'SQLServer:Buffer Manager') b ON  a.OBJECT_NAME = b.OBJECT_NAME
WHERE a.counter_name = 'Buffer cache hit ratio'
AND a.OBJECT_NAME = 'SQLServer:Buffer Manager'

SELECT *
FROM sys.dm_os_performance_counters  
WHERE counter_name = 'Page life expectancy'
AND OBJECT_NAME = 'SQLServer:Buffer Manager'


select counter_name, cntr_value/1024/1024[Memory_GB]
FROM sys.dm_os_performance_counters
WHERE counter_name in ('Target Server Memory (KB)','Total Server Memory (KB)')


counter_name	cntr_value
Target Server Memory (KB)                                                                                                       	1117624
Total Server Memory (KB)                                                                                                        	64336


dbcc memorystatus


--Current Memory stats (how much sql is using total andn for bufferpool)
dbcc memorystatus

MEM
VM Reserved	4281240
VM Committed	3575280

BUFFER
 VM Reserved	4214784
 VM Committed	3512168

--Most expensive queries 
SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads, qs.total_logical_writes DESC -- memory
-- ORDER BY qs.total_logical_writes DESC -- logical writes
-- ORDER BY qs.total_worker_time DESC -- CPU time

SELECT TOP 10 SESSION_ID, LOGIN_TIME, HOST_NAME,
PROGRAM_NAME, LOGIN_NAME, NT_DOMAIN, 
NT_USER_NAME, STATUS, CPU_TIME, MEMORY_USAGE, 
TOTAL_SCHEDULED_TIME, TOTAL_ELAPSED_TIME, 
LAST_REQUEST_START_TIME,
LAST_REQUEST_END_TIME, READS, WRITES, 
LOGICAL_READS, TRANSACTION_ISOLATION_LEVEL, 
LOCK_TIMEOUT, DEADLOCK_PRIORITY, ROW_COUNT, 
PREV_ERROR FROM SYS.DM_EXEC_SESSIONS ORDER
BY MEMORY_USAGE DESC 



SELECT (SUM(single_pages_kb) + SUM(multi_pages_kb) ) / (1024.0 * 1024.0) AS 'Plan Cache Size(GB)'
FROM sys.dm_os_memory_cache_counters
WHERE type in ('CACHESTORE_SQLCP','CACHESTORE_OBJCP')--,'CACHESTORE_PHDR')
--0.013801574707gb as of 2011-02-23 21:27:37.050



select name, type, single_pages_kb, multi_pages_kb from sys.dm_os_memory_cache_counters 


select top 10 pro.program_name,pro.cpu,pro.spid,
pro.memusage,pro.physical_io,db.name,pro.status,
pro.last_batch 
from sysprocesses pro,sysdatabases db 
order by memusage desc
select table_name, last_analyzed from dba_tables where owner='SCDAT' and table_name='SECURITIES'

grant select on scdat.pfcholdings to jellis1;
revoke select on scdat.pfcholdings to jellis1;
sp_who2 active

dbcc inputbuffer(102)

sp_readerrorlog

select * from sys.sysdatabases

select getdate()

use PMI_Operations
go

select * from sys.sysobjects
where id = 432720594


/** 
FROM http://social.msdn.microsoft.com/Forums/en-US/sqlsetupandupgrade/thread/2682d6c6-b4a4-4bee-b6e4-019186bfd8b1
**/
-- Good basic information about OS memory amounts and state
SELECT total_physical_memory_kb, available_physical_memory_kb, 
       total_page_file_kb, available_page_file_kb, 
       system_memory_state_desc
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);
-- You want to see "Available physical memory is high"
-- This indicates that you are not under external memory pressure
-- SQL Server Process Address space info 
--(shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb,locked_page_allocations_kb, 
       page_fault_count, memory_utilization_percentage, 
       available_commit_limit_kb, process_physical_memory_low, 
       process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);
-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low
-- This indicates that you are not under internal memory pressure
-- Page Life Expectancy (PLE) value for current instance
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Manager%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);
-- PLE is a good measurement of memory pressure.
-- Higher PLE is better. Watch the trend, not the absolute value.
-- Memory Grants Outstanding value for current instance
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Outstanding]                                                                                                      
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Outstanding' OPTION (RECOMPILE);
-- Memory Grants Outstanding above zero for a sustained period is a very strong indicator of memory pressure
-- Memory Grants Pending value for current instance
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);
-- Memory Grants Pending above zero for a sustained period is a very strong indicator of memory pressure
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------