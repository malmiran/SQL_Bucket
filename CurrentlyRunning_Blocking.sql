
/* Running Queries */
select r.session_id, getdate()[curr_time],r.start_time [request_starttime] /* Date and Time */
      ,r.status, r.command, t.text, r.wait_type, r.wait_resource, db_name(r.database_id)[database] /* Request and Waits */
      ,r.blocking_session_id /* Blocking-specific */
      ,r.cpu_time, r.logical_reads, r.reads, r.writes /* Resources */
      ,s.[host_name], s.[program_name], s.[login_name]
from sys.dm_exec_requests r
cross apply sys.dm_exec_sql_text (r.sql_handle)t
inner join sys.dm_exec_sessions s
 on r.session_id = s.session_id
where r.session_id <> @@spid

/* All Requests currently blocked */
select r.session_id, getdate()[curr_time],r.start_time [request_starttime] /* Date and Time */
      ,r.status, r.command, t.text, r.wait_type, r.wait_resource, db_name(r.database_id)[database] /* Request and Waits */
      ,r.blocking_session_id /* Blocking-specific */
      ,r.cpu_time, r.logical_reads, r.reads, r.writes /* Resources */
      ,s.[host_name], s.[program_name], s.[login_name]
from sys.dm_exec_requests r
cross apply sys.dm_exec_sql_text (r.sql_handle)t
inner join sys.dm_exec_sessions s
 on r.session_id = s.session_id
where blocking_session_id <> 0

/* Root of blocking tree */
select r.session_id, getdate()[curr_time],r.start_time [request_starttime] /* Date and Time */
      ,r.status, r.command, t.text, r.wait_type, r.wait_resource, db_name(r.database_id)[database] /* Request and Waits */
      ,r.cpu_time, r.logical_reads, r.reads, r.writes /* Resource-specific */
      ,s.[host_name], s.[program_name], s.[login_name] /* Session-specific */
from sys.dm_exec_requests r 
inner join sys.dm_exec_sessions s
 on r.session_id = s.session_id
cross apply sys.dm_exec_sql_text (r.sql_handle)t
where r.blocking_session_id = 0
and r.session_id in (
   select blocking_session_id
   from sys.dm_exec_requests
   where blocking_session_id <> 0
)

