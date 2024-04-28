USE DBAdmin

SET NOCOUNT ON;

declare	@TotalOrDetail		varchar(10),
		@TargetDatabase		sysname,			--  NULL: all dbs
		@Level				varchar(10),		--  or 'database'
		@Unit				char(2),			--  Megabytes, Kilobytes or Gigabytes
		@UpdateUsage		bit,				--  default no update
		@ColumnOrder		as varchar(50);		--	give column name to order on that column; free,UsedPerc or null.

set	@TotalOrDetail		= 'detail'
set	@TargetDatabase		= NULL			--  NULL: all dbs
set	@Level				= 'file'	--  or 'database'
set	@Unit				= 'MB'			--  Megabytes, Kilobytes or Gigabytes
set	@UpdateUsage		= 0					--  default no update
set	@ColumnOrder		= null	--	give column name to order on that column
--set @ColumnOrder		= 'UsedPerc'
--set @TargetDatabase	= 'mpw_cards_prd'

/**************************************************************************************************
Added by Stefan Posa.

test code:	usp_SpaceMonitor --  default behavior
			usp_SpaceMonitor 'detail','dbadmin'
			usp_SpaceMonitor 'total',NULL, 'file', 0
			usp_SpaceMonitor 'total',NULL, 'database', 'GB', 0
			usp_SpaceMonitor 'detail','dbadmin', 'file', 0
			usp_SpaceMonitor 'detail','dbadmin', 'Database', 0
			usp_SpaceMonitor 'total','dbadmin', 'database', 'kb', 0
			usp_SpaceMonitor 'detail',null, 'File', 'mb', 0
			usp_SpaceMonitor 'detail','dbadmin', 'Database', 'gb', 0
			usp_SpaceMonitor 'detail','tempdb', NULL, 'kb', 0

--shrink only to the last allocated extent
USE databasename
DBCC SHRINKFILE ('databasename', truncateonly)
**************************************************************************************************/

IF OBJECT_ID('tempdb..#Tbl_CombinedInfo') > 0	DROP TABLE #Tbl_CombinedInfo;

--------Create the @drives table to list hard drive space----------------------------------------------------
DECLARE @hr int,
		@fso int,
		@drive char(1),
		@odrive int,
		@TotalSize bigint,	--varchar(20)
		@MB int ; SET @MB = 1048576;

DECLARE @drives TABLE (
		drive char(1) not null,
		FreeSpace int NULL,
		TotalSize int NULL
		)

INSERT @drives(drive,FreeSpace)
EXEC master.dbo.xp_fixeddrives

EXEC @hr=sp_OACreate 'Scripting.FileSystemObject',@fso OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso

SELECT @drive = MIN(drive) FROM @drives where drive in (select	left(filename,1)from	dbo.sysfiles)

WHILE @drive IS NOT NULL
BEGIN

	EXEC @hr = sp_OAMethod @fso,'GetDrive', @odrive OUT, @drive
	IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
	EXEC @hr = sp_OAGetProperty @odrive,'TotalSize', @TotalSize OUT
	IF @hr <> 0 EXEC sp_OAGetErrorInfo @odrive

IF @Unit = 'GB'
	BEGIN
		UPDATE @drives
		SET	FreeSpace = FreeSpace/1024,
			TotalSize = @TotalSize/@MB/1024
		WHERE drive = @drive
	END
	ELSE
	BEGIN
		UPDATE @drives
		SET TotalSize = @TotalSize/@MB
		WHERE drive = @drive
	END

	/* -- next db in the list */
	SELECT @drive = MIN(drive)
	FROM @drives
	WHERE drive > @drive
		AND drive in (select	left(filename,1)from	dbo.sysfiles)

END

EXEC @hr=sp_OADestroy @fso
IF @hr <> 0 EXEC sp_OAGetErrorInfo @fso
------------End Create @drives table---------------------------------------------------------------------

CREATE TABLE dbo.#Tbl_CombinedInfo (
	ServerName sysname null,
	DatabaseName sysname NULL, 
	[type] VARCHAR(10) NULL, 
	LogicalName sysname NULL,
	T dec(9, 2) NULL,
	U dec(9, 2) NULL,
	UsedPerc dec(5, 2) NULL,
	F dec(9, 2) NULL,
	FreePerc dec(5, 2) NULL,
	FileGroup tinyint NULL,
	PhysicalName sysname NULL,
	DynamicOrFixed varchar(50) null,
	GrowthIncrement int,
	MaxSize int,
	DriveLetter char(1),
	DriveFreeSpace int,
	DriveTotalSize int,
	DriveFreePerc dec(5, 2),
	RecoveryModel varchar(25)
	);

DECLARE @Tbl_DbFileStats TABLE(
	Id int identity, 
	DatabaseName sysname NULL, 
	FileId int NULL, 
	FileGroup int NULL, 
	TotalExtents bigint NULL, 
	UsedExtents bigint NULL, 
	Name sysname NULL, 
	FileName varchar(255) NULL
	);
  
DECLARE @Tbl_ValidDbs TABLE(
	ID int identity, 
	Dbname sysname NULL
	);
  
DECLARE @Tbl_Logs TABLE(
	DatabaseName sysname NULL, 
	LogSize dec (10, 2) NULL, 
	LogSpaceUsedPercent dec (5, 2) NULL,
	Status int NULL
	);

DECLARE @DatabaseName sysname, 
        @Ident_last int, 
        @String varchar(2000),
        @BaseString varchar(2000);
        
SELECT @DatabaseName = '', 
       @Ident_last = 0, 
       @String = ''

              
SELECT @BaseString = 
' SELECT @@servername, DB_NAME(), ' + 
' CASE type WHEN 0 THEN ''Data'' WHEN 1 THEN ''Log'' WHEN 4 THEN ''Full-text'' ELSE ''reserved'' END' + 
', name, physical_name, size*8.0/1024.0 '+
	',case max_size
			when 0 then ''No growth is allowed''
			when -1 then ''File will grow until the disk is full''
			else ''Max file size has been set''
			end as MaxSizeInfo ' +
', growth*8.0/1024.0 '+
', max_size*8.0/1024.0 '+
'FROM sys.database_files with (nolock) WHERE state_desc = ''ONLINE''';

INSERT INTO @Tbl_ValidDbs
SELECT	name FROM 
		master.sys.databases with (nolock)
WHERE	HAS_DBACCESS(name) = 1
		and name not in ('master','model','msdb','tempdb','dbadmin')
ORDER BY name ASC;


INSERT INTO @Tbl_Logs EXEC ('DBCC SQLPERF (LOGSPACE) WITH NO_INFOMSGS');

--  For data part
IF @TargetDatabase IS NOT NULL
  BEGIN
    SELECT @DatabaseName = @TargetDatabase;
    IF @UpdateUsage <> 0 AND DATABASEPROPERTYEX (@DatabaseName,'Status') = 'ONLINE' 
          AND DATABASEPROPERTYEX (@DatabaseName, 'Updateability') <> 'READ_ONLY'
      BEGIN
        SELECT @String = 'USE [' + @DatabaseName + '] DBCC UPDATEUSAGE (0)';
        PRINT '*** ' + @String + ' *** ';
        EXEC (@String);
        PRINT '';
      END
      
    SELECT @String = 'INSERT INTO dbo.#Tbl_CombinedInfo (ServerName,DatabaseName, type, LogicalName, PhysicalName, T,DynamicOrFixed,GrowthIncrement,MaxSize) ' + @BaseString; 

    INSERT INTO @Tbl_DbFileStats (FileId, FileGroup, TotalExtents, UsedExtents, Name, FileName)
          EXEC ('USE [' + @DatabaseName + '] DBCC SHOWFILESTATS WITH NO_INFOMSGS');
    EXEC ('USE [' + @DatabaseName + '] ' + @String);
        
    UPDATE @Tbl_DbFileStats SET DatabaseName = @DatabaseName; 
  END
ELSE
  BEGIN
    WHILE 1 = 1
      BEGIN
        SELECT TOP 1 @DatabaseName = Dbname FROM @Tbl_ValidDbs WHERE Dbname > @DatabaseName ORDER BY Dbname ASC;
        IF @@ROWCOUNT = 0
          BREAK;
        IF @UpdateUsage <> 0 AND DATABASEPROPERTYEX (@DatabaseName, 'Status') = 'ONLINE' 
              AND DATABASEPROPERTYEX (@DatabaseName, 'Updateability') <> 'READ_ONLY'
          BEGIN
            SELECT @String = 'DBCC UPDATEUSAGE (''' + @DatabaseName + ''') ';
            PRINT '*** ' + @String + '*** ';
            EXEC (@String);
            PRINT '';
          END
    
        SELECT @Ident_last = ISNULL(MAX(Id), 0) FROM @Tbl_DbFileStats;

        SELECT @String = 'INSERT INTO dbo.#Tbl_CombinedInfo (ServerName,DatabaseName, type, LogicalName, PhysicalName, T,DynamicOrFixed,GrowthIncrement,MaxSize) ' + @BaseString; 

        EXEC ('USE [' + @DatabaseName + '] ' + @String);
      
        INSERT INTO @Tbl_DbFileStats (FileId, FileGroup, TotalExtents, UsedExtents, Name, FileName)
          EXEC ('USE [' + @DatabaseName + '] DBCC SHOWFILESTATS WITH NO_INFOMSGS');

        UPDATE @Tbl_DbFileStats SET DatabaseName = @DatabaseName WHERE Id BETWEEN @Ident_last + 1 AND @@IDENTITY;
      END
  END

--  set used size for data files, do not change total obtained from sys.database_files as it has for log files
UPDATE	dbo.#Tbl_CombinedInfo 
SET		U = s.UsedExtents*8*8/1024.0
		,filegroup = s.FileGroup
FROM	dbo.#Tbl_CombinedInfo t
		JOIN @Tbl_DbFileStats s
		ON t.LogicalName = s.Name AND s.DatabaseName = t.DatabaseName;

--  set used size and % values for log files:
UPDATE dbo.#Tbl_CombinedInfo 
SET	UsedPerc = LogSpaceUsedPercent, 
	U = T * LogSpaceUsedPercent/100.0
FROM dbo.#Tbl_CombinedInfo t JOIN @Tbl_Logs l 
ON l.DatabaseName = t.DatabaseName 
WHERE t.type = 'Log';

UPDATE dbo.#Tbl_CombinedInfo SET F = T - U, UsedPerc = U*100.0/T;

UPDATE dbo.#Tbl_CombinedInfo SET FreePerc = F*100.0/T;

IF UPPER(ISNULL(@Level, 'DATABASE')) = 'FILE'
  BEGIN
    IF @Unit = 'KB'
      UPDATE dbo.#Tbl_CombinedInfo
      SET T = T * 1024, U = U * 1024, F = F * 1024,GrowthIncrement = GrowthIncrement * 1024, MaxSize = MaxSize * 1024;
      
    IF @Unit = 'GB'
      UPDATE dbo.#Tbl_CombinedInfo
      SET T = T / 1024, U = U / 1024, F = F / 1024,GrowthIncrement = GrowthIncrement /1024,MaxSize = MaxSize / 1024;

--Include the hard drive info
UPDATE	c
SET		c.DriveLetter = d.drive,
		c.DriveFreeSpace = d.FreeSpace,
		c.DriveTotalSize = d.TotalSize
FROM	dbo.#Tbl_CombinedInfo c
		inner join @drives d on left(c.PhysicalName,1) = d.drive

UPDATE dbo.#Tbl_CombinedInfo SET DriveFreePerc=(cast(DriveFreeSpace as DEC(9,2))/DriveTotalSize*100);

--Include the Recovery Model
UPDATE	dbo.#Tbl_CombinedInfo
SET		RecoveryModel = recovery_model_desc
FROM	sys.databases d with (nolock)
where	DatabaseName = d.name

IF @TotalOrDetail = 'detail'
		BEGIN
			SELECT	ServerName,
					DatabaseName AS 'Database',
					type AS FileType,
					LogicalName,
					T AS Allocated,
					U AS Used,
					UsedPerc,
					F AS Free,
					FreePerc,
					GrowthIncrement,
					MaxSize,
					cast(MaxSize - U as int) DiffUsedMax,
					case when MaxSize > 0 then cast((MaxSize - U)/MaxSize*100 as decimal(9,2)) end DiffUsedMaxPerc,
					DynamicOrFixed,
					DriveLetter,
					DriveTotalSize,
					DriveFreeSpace,
					DriveFreePerc,
					Filegroup,
					PhysicalName,
					RecoveryModel
			  FROM dbo.#Tbl_CombinedInfo 
			  WHERE DatabaseName LIKE ISNULL(@TargetDatabase, '%') 
					--and DatabaseName not in ('master','model','msdb','tempdb')
				ORDER BY
				CASE	WHEN	@ColumnOrder  = 'Free'		THEN F				END Desc,
				CASE	WHEN	@ColumnOrder  = 'UsedPerc'	THEN UsedPerc		END Desc,
				CASE	WHEN	@ColumnOrder  is null		THEN databaseName	END

		END
		ELSE
		BEGIN
			SELECT	ServerName,
					CASE WHEN @Unit = 'GB' THEN 'GB' WHEN @Unit = 'KB' THEN 'KB' ELSE 'MB' END AS Unit,
					SUM (T) AS Total, SUM (U) AS Used, SUM (F) AS Free,
					SUM (c.MaxSize) AS MaxSizeTotal,
					d.drive Drive,
					d.TotalSize as DriveTotalSize,
					d.TotalSize - SUM (c.t) as DriveMinusAllocated,
					cast((SUM (c.t)/d.TotalSize*100) as smallint) ActualUsedPerc,
					d.TotalSize - SUM (c.MaxSize) as DriveMinusMaxSize,
					cast((SUM (c.MaxSize)/cast(d.TotalSize as dec(9,2))*100) as smallint) MaxUsedPerc
					
			FROM	dbo.#Tbl_CombinedInfo c
					inner join @drives d on left(c.PhysicalName,1) = d.drive
			GROUP BY LEFT(c.PhysicalName,1),d.drive,d.TotalSize,ServerName;
		END
END

IF UPPER(ISNULL(@Level, 'DATABASE')) = 'DATABASE'
  BEGIN
    DECLARE @Tbl_Final TABLE (
		DatabaseName sysname NULL,
		TOTAL dec (10, 2),
		[=] char(1),
		used dec (10, 2),
		[used (%)] dec (5, 2),
		[+] char(1),
		free dec (10, 2),
		[free (%)] dec (5, 2),
		[==] char(2),
		Data dec (10, 2),
		Data_Used dec (10, 2),
		[Data_Used (%)] dec (5, 2),
		Data_Free dec (10, 2),
		[Data_Free (%)] dec (5, 2),
		[++] char(2),
		Log dec (10, 2),
		Log_Used dec (10, 2),
		[Log_Used (%)] dec (5, 2),
		Log_Free dec (10, 2),
		[Log_Free (%)] dec (5, 2)
		);

	INSERT INTO @Tbl_Final
	SELECT x.DatabaseName, 
		x.Data + y.Log AS 'TOTAL', 
		'=' AS '=', 
		x.Data_Used + y.Log_Used AS 'U',
		(x.Data_Used + y.Log_Used)*100.0 / (x.Data + y.Log)  AS 'U(%)',
		'+' AS '+',
		x.Data_Free + y.Log_Free AS 'F',
		(x.Data_Free + y.Log_Free)*100.0 / (x.Data + y.Log)  AS 'F(%)',
		'==' AS '==',
		x.Data, 
		x.Data_Used, 
		x.Data_Used*100/x.Data AS 'D_U(%)',
		x.Data_Free, 
		x.Data_Free*100/x.Data AS 'D_F(%)',
		'++' AS '++', 
		y.Log, 
		y.Log_Used, 
		y.Log_Used*100/y.Log AS 'L_U(%)',
		y.Log_Free, 
		y.Log_Free*100/y.Log AS 'L_F(%)'
	FROM 
      ( SELECT d.DatabaseName, 
               SUM(d.T) AS 'Data', 
               SUM(d.U) AS 'Data_Used', 
               SUM(d.F) AS 'Data_Free' 
          FROM dbo.#Tbl_CombinedInfo d WHERE d.type = 'Data' GROUP BY d.DatabaseName ) AS x
      JOIN 
      ( SELECT l.DatabaseName, 
               SUM(l.T) AS 'Log', 
               SUM(l.U) AS 'Log_Used', 
               SUM(l.F) AS 'Log_Free' 
          FROM dbo.#Tbl_CombinedInfo l WHERE l.type = 'Log' GROUP BY l.DatabaseName ) AS y
      ON x.DatabaseName = y.DatabaseName;
    
	IF @Unit = 'KB'
		UPDATE @Tbl_Final SET TOTAL = TOTAL * 1024,
		used = used * 1024,
		free = free * 1024,
		Data = Data * 1024,
		Data_Used = Data_Used * 1024,
		Data_Free = Data_Free * 1024,
		Log = Log * 1024,
		Log_Used = Log_Used * 1024,
		Log_Free = Log_Free * 1024;
      
	IF @Unit = 'GB'
		UPDATE @Tbl_Final SET TOTAL = TOTAL / 1024,
		used = used / 1024,
		free = free / 1024,
		Data = Data / 1024,
		Data_Used = Data_Used / 1024,
		Data_Free = Data_Free / 1024,
		Log = Log / 1024,
		Log_Used = Log_Used / 1024,
		Log_Free = Log_Free / 1024;
      
	DECLARE	@GrantTotal dec(11, 2);
	SELECT	@GrantTotal = SUM(TOTAL) FROM @Tbl_Final;

	IF @TotalOrDetail = 'detail'
	BEGIN
		SELECT	CONVERT(dec(10, 2), TOTAL*100.0/@GrantTotal) AS WeightPerc, 
				DatabaseName AS 'DATABASE',
				CONVERT(VARCHAR(12), used) + '  (' + CONVERT(VARCHAR(12), [used (%)]) + ' %)' AS TotalUsedPerc,
				--[+],
				CONVERT(VARCHAR(12), free) + '  (' + CONVERT(VARCHAR(12), [free (%)]) + ' %)' AS TotalFreePerc,
				--[=],
				TOTAL, 
				--[=],
				CONVERT(VARCHAR(12), Data) + '  (' + CONVERT(VARCHAR(12), Data_Used) + ',  ' + 
				CONVERT(VARCHAR(12), [Data_Used (%)]) + '%)' AS DataUsedPerc,
				--[+],
				CONVERT(VARCHAR(12), Log) + '  (' + CONVERT(VARCHAR(12), Log_Used) + ',  ' + 
				CONVERT(VARCHAR(12), [Log_Used (%)]) + '%)' AS LogUsedPerc
		FROM @Tbl_Final 
		WHERE DatabaseName LIKE ISNULL(@TargetDatabase, '%')
		ORDER BY DatabaseName ASC;
	END
	ELSE
	BEGIN        
    IF @TargetDatabase IS NULL
		SELECT CASE WHEN @Unit = 'GB' THEN 'GB' WHEN @Unit = 'KB' THEN 'KB' ELSE 'MB' END AS 'SUM', 
			SUM (used) AS 'USED', 
			SUM (free) AS 'FREE', 
			SUM (TOTAL) AS 'TOTAL', 
			SUM (Data) AS 'DATA', 
			SUM (Log) AS 'LOG' 
		FROM @Tbl_Final;
	END
  END

