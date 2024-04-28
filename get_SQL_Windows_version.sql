CREATE TABLE #msver
(
   [index] int,
   name VARCHAR(50),
   internal_value INT,
   char_value VARCHAR(200)
)

INSERT #msver
EXEC master..xp_msver 

DECLARE @Platform VARCHAR(10),
        @WindowsVersion INT,
        @ProcessorCount INT,
        @PhysicalMemory INT,
        @MaxMemory INT


SELECT @WindowsVersion = SUBSTRING(char_value,1,1) FROM #msver WHERE name = 'WindowsVersion'
SELECT @Platform = char_value FROM #msver WHERE name = 'Platform'
SELECT @ProcessorCount = char_value FROM #msver WHERE name = 'ProcessorCount'
--SELECT @PhysicalMemory = internal_value/1024 FROM #msver WHERE name = 'PhysicalMemory'
SELECT @PhysicalMemory = ROUND(physical_memory_in_bytes/(1024*1024*1024.),0) from sys.dm_os_sys_info
SELECT @MaxMemory = ROUND(CAST(value AS INT)/1024.,0) FROM sys.configurations where name = 'max server memory (MB)'

DROP TABLE #msver

SELECT
 @@servername[SQL_Instance],
 CASE LEFT(CAST(SERVERPROPERTY('productversion')AS VARCHAR),4)
  WHEN '8.00' THEN 'SQL 2000' 
  WHEN '9.00' THEN 'SQL 2005'
  WHEN '10.0' THEN 'SQL 2008'
  WHEN '10.5' THEN 'SQL 2008 R2'
 END [Version],
 SERVERPROPERTY('edition')[Edition], 
 SERVERPROPERTY('productlevel')[Level],
 SERVERPROPERTY('productversion')[Version_Number],
 CASE 
   WHEN @WindowsVersion = 5 THEN 'Windows Server 2003'
   WHEN @WindowsVersion = 6 THEN 'Windows Server 2008'
 END [Windows_Version],
 @Platform[Platform],
 @ProcessorCount[CPU_count],
 CONVERT(VARCHAR,@PhysicalMemory)+'GB'[Memory_size],
 CONVERT(VARCHAR,@MaxMemory)+'GB' [Max_Memory]

DECLARE @IsClustered SQL_VARIANT
SELECT @IsClustered = SERVERPROPERTY('IsClustered')

IF @IsClustered = 1
BEGIN
SELECT  
 CASE
   WHEN @IsClustered = 1 THEN 'YES'
   ELSE 'NO'
 END [Is_SQL_Clustered]
 
SELECT NodeName[ClusterNodes] FROM sys.dm_os_cluster_nodes

SELECT DriveName[ClusteredDiskResource] FROM sys.dm_io_cluster_shared_drives
END

SELECT * FROM sys.dm_os_cluster_nodes
