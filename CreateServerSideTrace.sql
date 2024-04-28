/***********************************************/ 
/* Server Side Trace                           */ 
/***********************************************/ 
-- Declare variables 
DECLARE @rc INT 
DECLARE @TraceID INT 
DECLARE @maxFileSize bigint 
DECLARE @fileName NVARCHAR(128) 
DECLARE @on bit 

-- Set values 
SET @maxFileSize = 5000 
SET @fileName = N'M:\SQLBackups\SpecialBackups\mts_finance_pl_05152013_trace' 
SET @on = 1 

-- Create trace 
-- Refer to http://msdn.microsoft.com/en-us/library/ms190362.aspx
EXEC @rc = sp_trace_create @TraceID output, 2, @fileName, @maxFileSize, NULL  

-- If error end process 
IF (@rc != 0) GOTO error 

-- Set the events and data to collect 
-- Refer to http://msdn.microsoft.com/en-us/library/ms186265.aspx

--RPC:Completed
EXEC sp_trace_setevent @TraceID, 10,  6, @on 
EXEC sp_trace_setevent @TraceID, 10,  8, @on 
EXEC sp_trace_setevent @TraceID, 10,  10, @on 
EXEC sp_trace_setevent @TraceID, 10,  11, @on 
EXEC sp_trace_setevent @TraceID, 10,  13, @on 
EXEC sp_trace_setevent @TraceID, 10,  14, @on 
EXEC sp_trace_setevent @TraceID, 10,  15, @on 
EXEC sp_trace_setevent @TraceID, 10,  16, @on 
EXEC sp_trace_setevent @TraceID, 10,  17, @on 
EXEC sp_trace_setevent @TraceID, 10,  18, @on 
EXEC sp_trace_setevent @TraceID, 10,  35, @on 
EXEC sp_trace_setevent @TraceID, 10,  1, @on 
EXEC sp_trace_setevent @TraceID, 10,  2, @on 
EXEC sp_trace_setevent @TraceID, 10,  20, @on 
EXEC sp_trace_setevent @TraceID, 10,  30, @on 
EXEC sp_trace_setevent @TraceID, 10,  31, @on 

--SP:Completed
EXEC sp_trace_setevent @TraceID, 43,  6, @on 
EXEC sp_trace_setevent @TraceID, 43,  8, @on 
EXEC sp_trace_setevent @TraceID, 43,  10, @on 
EXEC sp_trace_setevent @TraceID, 43,  11, @on 
EXEC sp_trace_setevent @TraceID, 43,  13, @on 
EXEC sp_trace_setevent @TraceID, 43,  14, @on 
EXEC sp_trace_setevent @TraceID, 43,  15, @on 
EXEC sp_trace_setevent @TraceID, 43,  16, @on 
EXEC sp_trace_setevent @TraceID, 43,  17, @on 
EXEC sp_trace_setevent @TraceID, 43,  18, @on 
EXEC sp_trace_setevent @TraceID, 43,  35, @on 
EXEC sp_trace_setevent @TraceID, 43,  1, @on 
EXEC sp_trace_setevent @TraceID, 43,  2, @on 
EXEC sp_trace_setevent @TraceID, 43,  20, @on 
EXEC sp_trace_setevent @TraceID, 43,  30, @on 
EXEC sp_trace_setevent @TraceID, 43,  31, @on 

--SP:StmtCompleted
EXEC sp_trace_setevent @TraceID, 45,  6, @on 
EXEC sp_trace_setevent @TraceID, 45,  8, @on 
EXEC sp_trace_setevent @TraceID, 45,  10, @on 
EXEC sp_trace_setevent @TraceID, 45,  11, @on 
EXEC sp_trace_setevent @TraceID, 45,  13, @on 
EXEC sp_trace_setevent @TraceID, 45,  14, @on 
EXEC sp_trace_setevent @TraceID, 45,  15, @on 
EXEC sp_trace_setevent @TraceID, 45,  16, @on 
EXEC sp_trace_setevent @TraceID, 45,  17, @on 
EXEC sp_trace_setevent @TraceID, 45,  18, @on 
EXEC sp_trace_setevent @TraceID, 45,  35, @on 
EXEC sp_trace_setevent @TraceID, 45,  1, @on 
EXEC sp_trace_setevent @TraceID, 45,  2, @on 
EXEC sp_trace_setevent @TraceID, 45,  20, @on 
EXEC sp_trace_setevent @TraceID, 45,  30, @on 
EXEC sp_trace_setevent @TraceID, 45,  31, @on 

--SQL:BatchCompleted
EXEC sp_trace_setevent @TraceID, 12,  6, @on 
EXEC sp_trace_setevent @TraceID, 12,  8, @on 
EXEC sp_trace_setevent @TraceID, 12,  10, @on 
EXEC sp_trace_setevent @TraceID, 12,  11, @on 
EXEC sp_trace_setevent @TraceID, 12,  13, @on 
EXEC sp_trace_setevent @TraceID, 12,  14, @on 
EXEC sp_trace_setevent @TraceID, 12,  15, @on 
EXEC sp_trace_setevent @TraceID, 12,  16, @on 
EXEC sp_trace_setevent @TraceID, 12,  17, @on 
EXEC sp_trace_setevent @TraceID, 12,  18, @on 
EXEC sp_trace_setevent @TraceID, 12,  35, @on 
EXEC sp_trace_setevent @TraceID, 12,  1, @on 
EXEC sp_trace_setevent @TraceID, 12,  2, @on 
EXEC sp_trace_setevent @TraceID, 12,  20, @on 
EXEC sp_trace_setevent @TraceID, 12,  30, @on 
EXEC sp_trace_setevent @TraceID, 12,  31, @on 

--Exception
EXEC sp_trace_setevent @TraceID, 33,  6, @on 
EXEC sp_trace_setevent @TraceID, 33,  8, @on 
EXEC sp_trace_setevent @TraceID, 33,  10, @on 
EXEC sp_trace_setevent @TraceID, 33,  11, @on 
EXEC sp_trace_setevent @TraceID, 33,  13, @on 
EXEC sp_trace_setevent @TraceID, 33,  14, @on 
EXEC sp_trace_setevent @TraceID, 33,  15, @on 
EXEC sp_trace_setevent @TraceID, 33,  16, @on 
EXEC sp_trace_setevent @TraceID, 33,  17, @on 
EXEC sp_trace_setevent @TraceID, 33,  18, @on 
EXEC sp_trace_setevent @TraceID, 33,  35, @on 
EXEC sp_trace_setevent @TraceID, 33,  1, @on 
EXEC sp_trace_setevent @TraceID, 33,  2, @on 
EXEC sp_trace_setevent @TraceID, 33,  20, @on 
EXEC sp_trace_setevent @TraceID, 33,  30, @on 
EXEC sp_trace_setevent @TraceID, 33,  31, @on 

--SQL:StmtCompleted
EXEC sp_trace_setevent @TraceID, 41,  6, @on 
EXEC sp_trace_setevent @TraceID, 41,  8, @on 
EXEC sp_trace_setevent @TraceID, 41,  10, @on 
EXEC sp_trace_setevent @TraceID, 41,  11, @on 
EXEC sp_trace_setevent @TraceID, 41,  13, @on 
EXEC sp_trace_setevent @TraceID, 41,  14, @on 
EXEC sp_trace_setevent @TraceID, 41,  15, @on 
EXEC sp_trace_setevent @TraceID, 41,  16, @on 
EXEC sp_trace_setevent @TraceID, 41,  17, @on 
EXEC sp_trace_setevent @TraceID, 41,  18, @on 
EXEC sp_trace_setevent @TraceID, 41,  35, @on 
EXEC sp_trace_setevent @TraceID, 41,  1, @on 
EXEC sp_trace_setevent @TraceID, 41,  2, @on 
EXEC sp_trace_setevent @TraceID, 41,  20, @on 
EXEC sp_trace_setevent @TraceID, 41,  30, @on 
EXEC sp_trace_setevent @TraceID, 41,  31, @on 

--OLE DB Errors
EXEC sp_trace_setevent @TraceID, 61,  8, @on 
EXEC sp_trace_setevent @TraceID, 61,  10, @on 
EXEC sp_trace_setevent @TraceID, 61,  11, @on 
EXEC sp_trace_setevent @TraceID, 61,  13, @on 
EXEC sp_trace_setevent @TraceID, 61,  14, @on 
EXEC sp_trace_setevent @TraceID, 61,  15, @on 
EXEC sp_trace_setevent @TraceID, 61,  16, @on 
EXEC sp_trace_setevent @TraceID, 61,  17, @on 
EXEC sp_trace_setevent @TraceID, 61,  18, @on 
EXEC sp_trace_setevent @TraceID, 61,  35, @on 
EXEC sp_trace_setevent @TraceID, 61,  1, @on 
EXEC sp_trace_setevent @TraceID, 61,  2, @on 
EXEC sp_trace_setevent @TraceID, 61,  20, @on 
EXEC sp_trace_setevent @TraceID, 61,  30, @on 
EXEC sp_trace_setevent @TraceID, 61,  31, @on 

/*
--Showplan All
EXEC sp_trace_setevent @TraceID, 97,  6, @on 
EXEC sp_trace_setevent @TraceID, 97,  8, @on 
EXEC sp_trace_setevent @TraceID, 97,  10, @on 
EXEC sp_trace_setevent @TraceID, 97,  11, @on 
EXEC sp_trace_setevent @TraceID, 97,  13, @on 
EXEC sp_trace_setevent @TraceID, 97,  14, @on 
EXEC sp_trace_setevent @TraceID, 97,  15, @on 
EXEC sp_trace_setevent @TraceID, 97,  16, @on 
EXEC sp_trace_setevent @TraceID, 97,  17, @on 
EXEC sp_trace_setevent @TraceID, 97,  35, @on 
EXEC sp_trace_setevent @TraceID, 97,  1, @on 
EXEC sp_trace_setevent @TraceID, 97,  2, @on 
*/

-- Set Filters 
-- Refer to http://msdn.microsoft.com/en-us/library/ms174404.aspx
--EXEC sp_trace_setfilter @TraceID, 11, 0, 6, N'%XDUser%' 
-- filter2 exclude application SQL Profiler 
EXEC sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler' 
EXEC sp_trace_setfilter @TraceID, 35, 0, 6, N'mts_finance_pl' 

-- Start the trace 
-- Refer to http://msdn.microsoft.com/en-us/library/ms176034.aspx
EXEC sp_trace_setstatus @TraceID, 1
  
-- display trace id for future references  
SELECT TraceID=@TraceID  
GOTO finish  

-- error trap 
error:  
SELECT ErrorCode=@rc  

-- exit 
finish:  
GO