
--Check Trace Status
select @@servername [sql_instance], getdate()[date]
go
SELECT * FROM :: fn_trace_getinfo(default)
where traceid = 2

--Start trace
sp_trace_setstatus 2, 1

--Stop and Delete Trace
sp_trace_setstatus 2, 0
sp_trace_setstatus 2, 2

--Viewing results
USE DBAdmin
GO
SELECT * INTO jerome_test_trace
FROM ::fn_trace_gettable('D:\SQLBackups\SpecialBackups\jerome_login_trace\jerome_login_trace.trc', DEFAULT) 

SELECT ServerName, DatabaseID, HostName, ApplicationName, LoginName, SPID, StartTime, e.name as EventName
FROM mts_finance_pl_05152013 t
INNER JOIN sys.trace_events e ON t.eventclass = e.trace_event_id

--DROP TABLE mts_finance_pl_05152013

SELECT
 NTUserName
,HostName 
,ApplicationName 
,LoginName 
,Duration 
,StartTime 
,EndTime 
,Reads 
,Writes 
,CPU 
,DatabaseName 
,TextData 
,BinaryData 
,Severity 
,State 
,Error 
FROM mts_finance_pl_05152013






