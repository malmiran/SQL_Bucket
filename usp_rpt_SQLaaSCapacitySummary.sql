CREATE PROCEDURE [SQLaaS].[usp_rpt_SQLaaSCapacitySummary]  
AS  
BEGIN  

  
--temp table to store all SQLaaS SQL Instances along with Business Alignment and Environment value(s) if set  
CREATE TABLE #temp_tb1  
 (ReconciliationIdentity VARCHAR(30),  
 BusinessAlignment VARCHAR(10),  
 SystemRole VARCHAR(10),  
 SQLInstanceName VARCHAR(150),  
 SQLPort varchar(10),  
 SQLVersion varchar(20))  
  
--temp table to store SQLaaS SQL Instances realtionships with Clusters  
CREATE TABLE #temp_tb2  
 (ReconciliationIdentity VARCHAR(30),  
 SQLInstanceName VARCHAR(150),   
 ClusterName VARCHAR(150))  
  
DECLARE @tsql VARCHAR(8000)  
DECLARE @_businessalignment VARCHAR(10)  
SET @_businessalignment = 'ALL'  
--SET @_businessalignment = 'ALL'  
  
-----  
--STEP 1: fetch all SQLaaS SQL Instances along with Business Alignment and Environment value(s) if set  
-----  
SET @tsql = 'SELECT * FROM OPENQUERY (REMEDYDB,  
 ''WITH  
 input_data AS (  
  SELECT cost_center, name, item, label, display_value, reconciliation_identity, system_role, model  
  FROM ARADMIN.AST_DATABASE   
  LEFT JOIN ARADMIN.AST_ADDITIONALDATA ON ARADMIN.AST_DATABASE.reconciliation_identity = ARADMIN.AST_ADDITIONALDATA.reconciliationidentity  
 ),  
 ba AS (  
  SELECT cost_center, name, item, display_value as ba_value, reconciliation_identity  
  FROM input_data  
  WHERE label = ''''BusinessAlignment''''  
 ),  
 sp AS (  
  SELECT cost_center, name, item, display_value as sp_value, reconciliation_identity  
  FROM input_data  
  WHERE label = ''''SQLPort''''  
 ),  
 sv AS (  
  SELECT cost_center, name, item, display_value as sv_value, reconciliation_identity  
  FROM input_data  
  WHERE label = ''''SQLVersion''''  
 )  
 SELECT DISTINCT input_data.reconciliation_identity, ba_value, system_role, input_data.name, sp_value, sv_value  
 FROM input_data   
 LEFT JOIN ba ON ba.reconciliation_identity = input_data.reconciliation_identity  
 LEFT JOIN sp ON sp.reconciliation_identity = input_data.reconciliation_identity  
 LEFT JOIN sv ON sv.reconciliation_identity = input_data.reconciliation_identity  
 WHERE input_data.item = ''''SQL Server'''' AND input_data.model = ''''SQL Server Instance'''' AND input_data.cost_center= ''''SQLAAS'''''  
  
IF @_businessalignment != 'ALL'   
SET @tsql = @tsql +  ' AND ba_value = ''''' + @_businessalignment + ''''''  
  
SET @tsql = @tsql + ''')'  
  
--PRINT @tsql  
INSERT INTO #temp_tb1  
EXEC(@tsql)  
  
-----  
--STEP 2: fetch all SQLaaS SQL Instances realtionships with Clusters (that haven't been deleted)  
----  
SET @tsql = 'SELECT * FROM OPENQUERY (REMEDYDB,  
 ''SELECT c.reconciliation_identity, c.name AS "Child", b.name AS "Parent"  
 FROM ARADMIN.BMC_CORE_BMC_IMPACT_D a  
 JOIN ARADMIN.AST_CLUSTER b ON b.reconciliation_identity = a.source_reconciliationidentity  
 JOIN ARADMIN.AST_DATABASE c ON c.reconciliation_identity = a.destination_reconciliationiden  
 WHERE a.MARKASDELETED IS NULL AND c.cost_center = ''''SQLAAS'''''')'  
  
--PRINT @tsql  
INSERT INTO #temp_tb2  
EXEC(@tsql)  
  
--SELECT * FROM #temp_tb1 ORDER BY SQLInstanceName  
--SELECT * FROM #temp_tb2 ORDER BY SQLInstanceName  
  
--SET @_delimiter CHAR(1) = '-'  
--SET @_businessalignment = 'ALL'  
  
-----  
--STEP 3: Join collected data using reconciliation identity  
----  

CREATE TABLE #temp_tb3
(
   Cluster VARCHAR(20),
   Provisioned_Storage DECIMAL(15,1),
   Used_Storage DECIMAL(15,1)
)

INSERT INTO #temp_tb3
SELECT cluster, SUM(MaxSizeMB)/1024/1024 AS 'Provisioned Storage (TB)', SUM(MaxSpaceUsedMB)/1024/1204 AS 'Used Storage (TB)'
FROM
(
SELECT 
     CASE 
        WHEN a.PhyHost LIKE 'NTSYDDBD%' THEN 'ntsyddbd324c'
        WHEN a.PhyHost LIKE 'NTSYDDBU%' THEN 'ntsyddbu324c'
        WHEN a.PhyHost LIKE 'NTSYDDBR%' THEN 'ntsyddbr324c'
        WHEN a.PhyHost LIKE 'NTSYDDBP%' THEN 'ntsyddbp324c'
     END AS Cluster
    ,Mount  
    ,Label
    ,MAX(CurrentSize) AS MaxSizeMB  
    ,MAX(CurrentSize - UnusedSize) AS MaxSpaceUsedMB  
  FROM dbo.DiskDrive  
  INNER JOIN (SELECT      DISTINCT cdb.HostName DBHost, svr.HostName PhyHost  
     FROM  ServersCfg cdb  
     LEFT JOIN ServersInfo svr ON cdb.ServerName=svr.ServerName  
     WHERE  cdb.ServerName IN (SELECT ServerName FROM vw_ServersRmdy where Status='Deployed' and ProdName='SQL Server Instance' and CostCenter='SQLAAS')        
     ) a ON HostName=a.DBHost   
  WHERE TimeTaken > DATEADD(dd, -7, GETDATE())
  AND (Label NOT LIKE '%_Q' AND Label NOT IN ('SYSTEM','DATA') AND Label NOT LIKE '%RootDrive')
  GROUP BY a.PhyHost  
    ,Mount
    ,Label  
)t
GROUP BY Cluster


CREATE TABLE #temp_tb4
(
   Cluster VARCHAR(20),
   Environment VARCHAR(4),
   NodeCount INT,
   TotalMemory INT,
   TotalMemoryUsed INT,
   TotalStorage DEC(2,1),
   TotalStorageUsed DEC(2,1)
)   

INSERT INTO #temp_tb4 (Cluster, Environment, TotalStorage, TotalStorageUsed)
SELECT DISTINCT b.ClusterName, a.SystemRole, c.Provisioned_Storage, c.Used_Storage
FROM #temp_tb1 a   
LEFT JOIN #temp_tb2 b ON a.ReconciliationIdentity = b.ReconciliationIdentity
INNER JOIN #temp_tb3 c ON b.ClusterName = c.Cluster
WHERE SystemRole NOT IN ('Pre-prod','Build')

DROP TABLE #temp_tb1  
DROP TABLE #temp_tb2   
DROP TABLE #temp_tb3


--NODE COUNT
DECLARE @cluster_name VARCHAR(20), @node_count INT

CREATE TABLE #temp_tb5 (node_path VARCHAR(200))

DECLARE db_cursor CURSOR FOR
SELECT Cluster FROM #temp_tb4
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @cluster_name
WHILE @@FETCH_STATUS = 0
BEGIN
   INSERT INTO #temp_tb5
   EXEC SQLaaS.usp_getClusterNodes @cluster_name
   SELECT @node_count = COUNT(*) FROM #temp_tb5
   UPDATE #temp_tb4 SET NodeCount = @node_count
   WHERE Cluster = @cluster_name
   TRUNCATE TABLE #temp_tb5
   
   FETCH NEXT FROM db_cursor INTO @cluster_name
END
CLOSE db_cursor
DEALLOCATE db_cursor
   
/*
--MEMORY
CREATE TABLE #temp_tb6 
(
   [Path] VARCHAR(200), 
   PhysicalMemory INT,
   TotalAssignedMemory INT,
   TotalFreeMemory INT,
   PercentFreeMemory INT
)

SET @cluster_name = NULL

DECLARE db_cursor CURSOR FOR
SELECT Cluster FROM #temp_tb4
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @cluster_name
WHILE @@FETCH_STATUS = 0
BEGIN
   INSERT INTO #temp_tb6
   EXEC SQLaaS.usp_getAssignedMemoryPerNode @cluster_name
   UPDATE #temp_tb6 SET [Path] = LOWER(SUBSTRING([Path],1,11)) + 'c'
   UPDATE tb4
   SET tb4.TotalMemory = tb6.PhysicalMemory, tb4.TotalMemoryUsed = tb6.TotalAssignedMemory
   FROM #temp_tb4 tb4
   INNER JOIN #temp_tb6 tb6 ON tb4.Cluster = tb6.[Path]
   TRUNCATE TABLE #temp_tb6
END
CLOSE db_cursor
DEALLOCATE db_cursor
*/
   
SELECT * FROM #temp_tb4


DROP TABLE #temp_tb4
DROP TABLE #temp_tb5
--DROP TABLE #temp_tb6
















END