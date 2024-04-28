/************** PERFORMANCE-RELATED QUERIES *********************/

/************** CURRENT SESSIONS *********************/
--sys.dm_exec_requests
--SQLServerPedia (Brent Ozar)
DECLARE @OpenQueries TABLE (cpu_time INT, logical_reads INT, session_id INT)
INSERT INTO @OpenQueries(cpu_time, logical_reads, session_id)
select r.cpu_time ,r.logical_reads, r.session_id
from sys.dm_exec_sessions as s inner join sys.dm_exec_requests as r 
on s.session_id =r.session_id and s.last_request_start_time=r.start_time
where is_user_process = 1
and s.session_id <> @@SPID

waitfor delay '00:00:01'

select substring(h.text, (r.statement_start_offset/2)+1 , ((case r.statement_end_offset when -1 then datalength(h.text)  else r.statement_end_offset end - r.statement_start_offset)/2) + 1) as text
, r.cpu_time-t.cpu_time as CPUDiff 
, r.logical_reads-t.logical_reads as ReadDiff
, r.wait_type
, r.wait_time
, r.last_wait_type
, r.wait_resource
, r.command
, r.database_id
, r.blocking_session_id
, r.granted_query_memory
, r.session_id
, r.reads
, r.writes, r.row_count, s.[host_name]
, s.program_name, s.login_name
from sys.dm_exec_sessions as s inner join sys.dm_exec_requests as r 
on s.session_id =r.session_id and s.last_request_start_time=r.start_time
left join @OpenQueries as t on t.session_id=s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) h
where is_user_process = 1
and s.session_id <> @@SPID
order by 3 desc

--SESSIONS WAITING FOR A RESOURCE
--sys.dm_os_waiting_tasks
--Jonathan Kehayias
SELECT
     owt.session_id,
     owt.wait_duration_ms,
     owt.wait_type,
     owt.blocking_session_id,
     owt.resource_description,
     es.program_name,
     est.text,
     est.dbid,
     eqp.query_plan,
     es.cpu_time,
     es.memory_usage
 FROM sys.dm_os_waiting_tasks owt
 INNER JOIN sys.dm_exec_sessions es
     ON owt.session_id = es.session_id
 INNER JOIN sys.dm_exec_requests er
     ON es.session_id = er.session_id
 OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
 OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
 WHERE es.is_user_process = 1
 AND es.session_id <> @@spid
 GO 
 

/****************************** WAIT-STATS *********************************/

  --CUMULATIVE WAIT STATISTICS
/* DBCC SQLPERF('sys.dm_os_wait_stats', clear) -- In case you need to clear wait stats */
  
 WITH Waits AS
     (SELECT
         wait_type,
         wait_time_ms / 1000.0 AS WaitS,
         (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
         signal_wait_time_ms / 1000.0 AS SignalS,
         waiting_tasks_count AS WaitCount,
         100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
         ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
     FROM sys.dm_os_wait_stats
     WHERE wait_type NOT IN (
         'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
         'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
         'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
         'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
         'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
         'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
         'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
         'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
         'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK')
     )
 SELECT
     W1.wait_type AS WaitType, 
    CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
     CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
     CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
     W1.WaitCount AS WaitCount,
     CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage,
     CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgWait_S,
     CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgRes_S,
     CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgSig_S
 FROM Waits AS W1
     INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
 GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
 HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
 GO 
 
/************************** EXPENSIVE QUERIES ************************************/
 
 --Top 10 most CPU-intensive queries in the Procedure cache
SELECT TOP 10  SUBSTRING(b.text, (a.statement_start_offset/2) + 1,
              ((CASE statement_end_offset 
                  WHEN -1 THEN DATALENGTH(b.text)
                ELSE a.statement_end_offset 
                END - a.statement_start_offset)/2) + 1) AS statement_text,
              c.query_plan, 
              total_worker_time as CPU_time
FROM sys.dm_exec_query_stats a 
  CROSS APPLY sys.dm_exec_sql_text (a.sql_handle) AS b
  CROSS APPLY sys.dm_exec_query_plan (a.plan_handle) AS c  
ORDER BY total_worker_time DESC

--Top 10 queries executed the most
SELECT TOP 10 b.text AS 'SP Name',
              a.execution_count AS 'Execution Count',
              a.execution_count/DATEDIFF(SECOND, a.creation_time, GETDATE()) AS 'Calls/Second',
              a.total_worker_time/a.execution_count AS 'AvgCPUTime',
              a.total_worker_time AS 'TotalCPUTime',
              a.total_elapsed_time/a.execution_count AS 'AvgElapsedTime',
              a.max_logical_reads,
              a.max_logical_writes,
              a.total_physical_reads,
              DATEDIFF(MINUTE,
              a.creation_time, GETDATE()) AS 'Age in Cache'
FROM sys.dm_exec_query_stats a
 CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) b  
WHERE b.dbid = DB_ID() -- only for current database  
ORDER BY a.execution_count DESC

--Top 10 most recompiled queries
SELECT TOP 10 b.text AS query_text,
               plan_generation_num,
               execution_count,
               DB_NAME(dbid) AS database_name,
               OBJECT_NAME(objectid) AS [object name]
FROM sys.dm_exec_query_stats a
 CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS b  
WHERE plan_generation_num > 1
ORDER BY plan_generation_num DESC

--Top 10 most I/O-intensive queries
SELECT TOP 10 total_logical_reads,
              total_logical_writes,
              execution_count,
              total_logical_reads+total_logical_writes AS [IO_total],
              b.text AS query_text,
              db_name(b.dbid) AS database_name,
              b.objectid AS object_id 
FROM sys.dm_exec_query_stats  a
  CROSS APPLY sys.dm_exec_sql_text(sql_handle) b  
WHERE total_logical_reads+total_logical_writes > 0
ORDER BY [IO_total] DESC

/*************************** I/O RELATED QUERIES **********************************/

/* Virtual File Stats -- from Jonathan Kehayias*/
SELECT DB_NAME(vfs.database_id) AS database_name ,
vfs.database_id ,
vfs.FILE_ID ,
io_stall_read_ms / NULLIF(num_of_reads, 0) AS avg_read_latency ,
io_stall_write_ms / NULLIF(num_of_writes, 0)
AS avg_write_latency ,
io_stall / NULLIF(num_of_reads + num_of_writes, 0)
AS avg_total_latency ,
num_of_bytes_read / NULLIF(num_of_reads, 0)
AS avg_bytes_per_read ,
num_of_bytes_written / NULLIF(num_of_writes, 0)
AS avg_bytes_per_write ,
vfs.io_stall ,
vfs.num_of_reads ,
vfs.num_of_bytes_read ,
vfs.io_stall_read_ms ,
vfs.num_of_writes ,
vfs.num_of_bytes_written ,
vfs.io_stall_write_ms ,
size_on_disk_bytes / 1024 / 1024. AS size_on_disk_mbytes ,
physical_name
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id
AND vfs.FILE_ID = mf.FILE_ID
ORDER BY avg_total_latency DESC

--Virtual file stats - version 2
SELECT DB_NAME(database_id) AS [Database],[file_id], [io_stall_read_ms],[io_stall_write_ms],[io_stall]
FROM sys.dm_io_virtual_file_stats(NULL,NULL) 
ORDER BY  io_stall desc

--Virtual file stats - version 3
SELECT DB_NAME(vfs.DbId) DatabaseName, mf.name,
mf.physical_name, vfs.BytesRead, vfs.BytesWritten,
vfs.IoStallMS, vfs.IoStallReadMS, vfs.IoStallWriteMS,
vfs.NumberReads, vfs.NumberWrites,
(Size*8)/1024 Size_MB
FROM ::fn_virtualfilestats(NULL,NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.DbId
AND mf.FILE_ID = vfs.FileId
ORDER BY vfs.IoStallMS desc

--Check Wait Stats for I/O Wait-types
SELECT wait_type, 
        waiting_tasks_count, 
        wait_time_ms 
FROM    sys.dm_os_wait_stats 
WHERE    wait_type like 'PAGEIOLATCH%' 
ORDER BY 2 desc,3 desc

--Following query shows the number of pending I/Os that are waiting to be completed for the entire SQL Server instance
SELECT SUM(pending_disk_io_count) AS [Number of pending I/Os] FROM sys.dm_os_schedulers 

--Following query gives details about the stalled I/O count reported by the query above
SELECT *  FROM sys.dm_io_pending_io_requests 

/*** BUFFER POOL QUERIES - Identifying which DB and objects are consuming the most space in the BP ***/
--find out how big buffer pool is and determine percentage used by each database
DECLARE @total_buffer INT;
SELECT @total_buffer = cntr_value   FROM sys.dm_os_performance_counters
WHERE RTRIM([object_name]) LIKE '%Buffer Manager'   AND counter_name = 'Total Pages';
;WITH src AS(   SELECT        database_id, db_buffer_pages = COUNT_BIG(*) 
FROM sys.dm_os_buffer_descriptors       --WHERE database_id BETWEEN 5 AND 32766       
GROUP BY database_id)SELECT   [db_name] = CASE [database_id] WHEN 32767        THEN 'Resource DB'        ELSE DB_NAME([database_id]) END,   db_buffer_pages,   db_buffer_MB = db_buffer_pages / 128,   db_buffer_percent = CONVERT(DECIMAL(6,3),        db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;

--then drill down into memory used by objects in database of your choice
USE MGLSpend_prd;
WITH src AS(   SELECT       [Object] = o.name,       [Type] = o.type_desc,       [Index] = COALESCE(i.name, ''),       [Index_Type] = i.type_desc,       p.[object_id],       p.index_id,       au.allocation_unit_id   
FROM       sys.partitions AS p   INNER JOIN       sys.allocation_units AS au       ON p.hobt_id = au.container_id   INNER JOIN       sys.objects AS o       ON p.[object_id] = o.[object_id]   INNER JOIN       sys.indexes AS i       ON o.[object_id] = i.[object_id]       AND p.index_id = i.index_id   WHERE       au.[type] IN (1,2,3)       AND o.is_ms_shipped = 0)
SELECT   src.[Object],   src.[Type],   src.[Index],   src.Index_Type,   buffer_pages = COUNT_BIG(b.page_id),   buffer_mb = COUNT_BIG(b.page_id) / 128
FROM   src
INNER JOIN   sys.dm_os_buffer_descriptors AS b  
 ON src.allocation_unit_id = b.allocation_unit_id
WHERE   b.database_id = DB_ID()
GROUP BY   src.[Object],   src.[Type],   src.[Index],   src.Index_Type
ORDER BY   buffer_pages DESC;

/** MOST PHYSICAL READS **/
SELECT TOP 10 
qs.execution_count, 
AvgPhysicalReads = isnull( qs.total_physical_reads/ qs.execution_count, 0 ), 
MinPhysicalReads = qs.min_physical_reads, 
MaxPhysicalReads = qs.max_physical_reads, 
AvgPhysicalReads_kbsize = isnull( qs.total_physical_reads/ qs.execution_count, 0 ) *8, 
MinPhysicalReads_kbsize = qs.min_physical_reads*8, 
MaxPhysicalReads_kbsize = qs.max_physical_reads*8, 
CreationDateTime = qs.creation_time, 
SUBSTRING(qt.[text], qs.statement_start_offset/2, ( 
CASE 
WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
ELSE qs.statement_end_offset 
END - qs.statement_start_offset)/2 
) AS query_text, 
qt.[dbid], 
qt.objectid, 
tp.query_plan, 
tp.query_plan.exist('declare default element namespace "_http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes') missing_index_info 
FROM 
sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text (qs.[sql_handle]) AS qt 
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp 
ORDER BY AvgPhysicalReads DESC 


SELECT TYPE, SUM(MULTI_PAGES_KB) 
FROM SYS.DM_OS_MEMORY_CLERKS 
WHERE MULTI_PAGES_KB != 0 
GROUP BY TYPE
ORDER BY 2 DESC

LogDate	ProcessInfo	Text
2013-04-26 22:39:24.460	spid1s	A significant part of sql server process memory has been paged out. This may result in a performance degradation. Duration: 0 seconds. Working set (KB): 294132, committed (KB): 764160, memory utilization: 38%.


sp_readerrorlog 0,1,'A significant part'

SELECT TYPE, SUM(single_pages_kb) InternalPressure, SUM(multi_pages_kb) ExtermalPressure
FROM sys.dm_os_memory_clerks
GROUP BY TYPE
ORDER BY SUM(single_pages_kb) DESC, SUM(multi_pages_kb) DESC
GO

select 135872/1024

SELECT  
    EventTime, 
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type], 
    record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') as [IndicatorsProcess], 
    record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') as [IndicatorsSystem], 
    record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [Avail Phys Mem, Kb], 
    record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [Avail VAS, Kb] 
FROM ( 
    SELECT 
        DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime, 
        CONVERT (xml, record) AS record 
    FROM sys.dm_os_ring_buffers 
    CROSS JOIN sys.dm_os_sys_info 
    WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab 
ORDER BY EventTime DESC;


select * from sys.dm_os_ring_buffers 
where ring_buffer_type='RING_BUFFER_SINGLE_PAGE_ALLOCATOR'

select * from sys.dm_os_ring_buffers 
where ring_buffer_type='RING_BUFFER_RESOURCE_MONITOR'

dbcc memorystatus

sp_readerrorlog










select * from dbadmin..configplans
where planname like 'dbc%'

select getdate()
