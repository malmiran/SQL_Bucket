use tempdb
--operationsmanager
--tempdb

DECLARE @DBName VARCHAR(50)
SET @DBName = 'tempdb'

select SERVERPROPERTY('servername'), GETDATE()[date]

select   
db_name() [Database Name]
,convert(dec(15, 2), sum(size) * 8.0 / 1024) [Data Size (MB)]
,convert(dec(15, 2), sum(fileproperty(name,'SpaceUsed')) * 8.0 / 1024) [Data Used (MB)]
,convert(dec(15, 2), sum(fileproperty(name,'SpaceUsed')) * 1.0 / sum(size) * 100) [% Data Used]
from    dbo.sysfiles
where   groupid <> 0

select  db_name() [Database Name]
,convert(dec(15, 2), sum(size) * 8.0 / 1024) [Log Size (MB)]
,convert(dec(15, 2), sum(fileproperty(name,'SpaceUsed')) * 8.0 / 1024) [Log Used (MB)]
,convert(dec(15, 2), sum(fileproperty(name,'SpaceUsed')) * 1.0 / sum(size) * 100) [% Log Used]
from    dbo.sysfiles
where   groupid = 0

select  a.groupid ID
,case when groupname is NULL then 'N/A' else groupname end [Group Name]
,substring(filename, 1, 1) Drive
,[name] AS 'Logical Name'
,[filename] AS 'File Name'
,convert(dec(15, 2), size * 8.0 / 1024) [File Size (MB)]
,convert(dec(15, 2), fileproperty(name,'SpaceUsed') * 8.0 / 1024) [File Used (MB)]
,convert(dec(15, 2), fileproperty(name,'SpaceUsed') * 1.0 / size * 100) [% File Used]            
,case when growth = 0 then 'N/A'
when growth < 128 then convert(varchar, growth) + '%'
else convert(varchar, convert(dec, growth * 8.0 / 1024)) end [Growth Size (MB)]
,case when growth = 0 then 'N/A'
when maxsize = -1 then 'UNLIMITED'
else convert(varchar, convert(dec, maxsize * 8.0 / 1024))
end [Max Size (MB)]      
from    dbo.sysfiles a
left join dbo.sysfilegroups b on a.groupid = b.groupid
order by a.groupid 

select name, recovery_model_desc from sys.databases
where name = @DBName;

EXEC master..xp_fixeddrives


/* OTHER QUERIES 

alter database tempdb
modify file(name=templog,size=1000,maxsize=4000)

use DBAdmin;
go
dbcc shrinkfile (DBAdmin_log,100)


*/
/* 

--Another query to get size properties of a particular database
SELECT name, physical_name, state_desc, (size*8)/1024[size_mb], (max_size*8)/1024[maxsize_mb], (growth*8)/1024[filegrowth_mb] FROM sys.master_files
WHERE DB_NAME(database_id) = 'tempdb'
AND type_desc = 'Rows';
GO

--Query to get Log size and usage of all databases
CREATE TABLE #tmp_log_usage  
(  
   [DatabaseName] VARCHAR(100),  
   [Log Size (MB)] DECIMAL(8,2),  
   [Percent_Usage] DECIMAL(8,2),  
   [Status] int  
)  

INSERT #tmp_log_usage  
EXEC('DBCC SQLPERF(logspace)');  
  
SELECT * 
FROM #tmp_log_usage 
WHERE DatabaseName LIKE 'HPC%' 
ORDER BY Percent_Usage DESC;

DROP TABLE #tmp_log_usage;
GO

alter database  CCR_DATA_STORE_UAT
modify file (name=CCR_DATA_STORE_DEV,size=62000)



select  * from sys.databases
where name like 'HPC%'

SELECT name, physical_name, state_desc, (size*8)/1024[size_mb], (max_size*8)/1024[maxsize_mb], (growth*8)/1024[filegrowth_mb] 

select  name, physical_name, state_desc, (size*8)/1024[size_mb], (max_size*8)/1024[maxsize_mb], (growth*8)/1024[filegrowth_mb] 

select name, physical_name, state_desc, (size*8)/1024[size_mb],
case when growth = 0 then 'N/A'
when growth < 128 then convert(varchar, growth) + '%'
else convert(varchar, convert(dec, growth * 8.0 / 1024)) end [Growth Size (MB)]
,case when growth = 0 then 'N/A'
when max_size = -1 then 'UNLIMITED'
else convert(varchar, convert(dec, max_size * 8.0 / 1024))
end [Max Size (MB)]      
FROM sys.master_files
WHERE DB_NAME(database_id) like 'HPC%'
AND type_desc = 'LOG';
GO

*/





/* GET FILE PROPERTIES (SIZE, USAGE, etc.) OF MULTIPLE DBs 

CREATE TABLE ##ALL_DB_Files (
dbname SYSNAME,
fileid smallint,
groupid smallint,
[file_size_mb] float NOT NULL,
[space_used_mb] float not null,
[space_used_%] float not null,
[maxsize] INT NOT NULL,
growth INT NOT NULL,
status INT,
perf INT,
[name] SYSNAME NOT NULL,
[filename] NVARCHAR(260) NOT NULL)

-- loop over all databases and collect the information from sysfiles
-- to the ALL_DB_Files tables using the sp_MsForEachDB system procedure
EXEC sp_MsForEachDB
@command1='use [$];Insert into ##ALL_DB_Files 
select db_name(),
fileid,
groupid,
convert(dec(15, 2), size * 8.0 / 1024)[file_size_mb],
convert(dec(15, 2), fileproperty(name,''SpaceUsed'') * 8.0 / 1024)[space_used_mb],
convert(dec(15, 2), fileproperty(name,''SpaceUsed'') * 1.0 / size * 100) [space_used_%], 
[maxsize],
[growth],
[status],
[perf],
[name],
[filename]
from sysfiles',
@replacechar = '$'

-- output the results
SELECT 
[dbname] AS DatabaseName,
[name] AS dbFileLogicalName,
[filename] AS dbFilePhysicalFilePath,
[file_size_mb],
[space_used_mb],
[space_used_%]
FROM ##ALL_DB_Files
WHERE [filename] like 'E:\SQLFiles\MSSQL10.MBFSPRD08\MSSQL\DATA004\%' /* You can filter for specific mount points */
ORDER BY [file_size_mb] DESC

DROP TABLE ##ALL_DB_Files










sp_who2 active




select * from sys.dm_exec_requests

*/