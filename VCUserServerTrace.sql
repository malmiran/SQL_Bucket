
--Check Trace Status
select @@servername [sql_instance], getdate()[date]
go
SELECT * FROM :: fn_trace_getinfo(default)
where traceid = 2

--Stop and Delete Trace
sp_trace_setstatus 2, 0
sp_trace_setstatus 2, 2

--Viewing results
USE DBAdmin
GO
SELECT * INTO ServerTrace_VCUser 
FROM ::fn_trace_gettable('D:\temp\INC000008757362\vcuser_trace2.trc', DEFAULT) 

SELECT ServerName, DatabaseID, HostName, ApplicationName, LoginName, SPID, StartTime, e.name as EventName
FROM ServerTrace_VCUser t
INNER JOIN sys.trace_events e ON t.eventclass = e.trace_event_id

--DROP TABLE ServerTrace_VCUser
