DECLARE @threshold DECIMAL(8,2)  
SET threshold = 
  
CREATE TABLE #tmp_log_usage  
(  
   [DatabaseName] VARCHAR(100),  
   [Log Size (MB)] DECIMAL(8,2),  
   [Percent_Usage] DECIMAL(8,2),  
   [Status] int  
)  
  
INSERT #tmp_log_usage  
  EXEC('DBCC SQLPERF(logspace)')  
  
SELECT * FROM #tmp_log_usage  
WHERE Percent_Usage > @threshold  
--ORDER BY Percent_Usage DESC
--and DatabaseName in (select name from DBAdmin.dbo.z_CHG379853_temp)  

  
DROP TABLE #tmp_log_usage  
  
