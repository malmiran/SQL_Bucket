USE [illuminator]
GO
DECLARE @ObjectName sysname
DECLARE @StatsName sysname
DECLARE StatsCursor CURSOR FAST_FORWARD
FOR
SELECT 
'['+OBJECT_NAME(object_id)+']' as 'ObjectName', 
'['+[name]+']' as 'StatsName' 
FROM sys.stats
WHERE 
(INDEXPROPERTY(object_id, [name], 'IsAutoStatistics') = 1 
OR INDEXPROPERTY(object_id, [name], 'IsStatistics') = 1)
AND OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
OPEN StatsCursor
FETCH NEXT FROM StatsCursor
INTO @ObjectName, @StatsName
WHILE @@FETCH_STATUS = 0
BEGIN
PRINT 'DROP STATISTICS ' + @ObjectName + '.' + @StatsName
FETCH NEXT FROM StatsCursor
INTO @ObjectName, @StatsName
END
CLOSE StatsCursor
DEALLOCATE StatsCursor
GO
