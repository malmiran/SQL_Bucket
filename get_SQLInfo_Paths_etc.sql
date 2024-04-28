declare @RegPathParams sysname
                declare @Arg sysname
                declare @Param sysname
                declare @MasterPath nvarchar(512)
                declare @LogPath nvarchar(512)
                declare @ErrorLogPath nvarchar(512)
                declare @n int

                select @n=0
                select @RegPathParams=N'Software\Microsoft\MSSQLServer\MSSQLServer'+'\Parameters'
                select @Param='dummy'
                while(not @Param is null)
                begin
                    select @Param=null
                    select @Arg='SqlArg'+convert(nvarchar,@n)

                    exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', @RegPathParams, @Arg, @Param OUTPUT
                    if(@Param like '-d%')
                    begin
                        select @Param=substring(@Param, 3, 255)
                        select @MasterPath=substring(@Param, 1, len(@Param) - charindex('\', reverse(@Param)))
                    end
                    else if(@Param like '-l%')
                    begin
                        select @Param=substring(@Param, 3, 255)
                        select @LogPath=substring(@Param, 1, len(@Param) - charindex('\', reverse(@Param)))
                    end
                    else if(@Param like '-e%')
                    begin
                        select @Param=substring(@Param, 3, 255)
                        select @ErrorLogPath=substring(@Param, 1, len(@Param) - charindex('\', reverse(@Param)))
                    end

                    select @n=@n+1
                end

                declare @SmoRoot nvarchar(512)
                exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @SmoRoot OUTPUT

SELECT
CAST(FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS bit) AS [IsFullTextInstalled],
@LogPath AS [MasterDBLogPath],
@MasterPath AS [MasterDBPath],
@ErrorLogPath AS [ErrorLogPath],
@SmoRoot AS [RootDirectory],
CAST(case when 'a' <> 'A' then 1 else 0 end AS bit) AS [IsCaseSensitive],
@@MAX_PRECISION AS [MaxPrecision],
SERVERPROPERTY(N'ProductVersion') AS [VersionString],
CAST(SERVERPROPERTY(N'Edition') AS sysname) AS [Edition],
CAST(SERVERPROPERTY(N'ProductLevel') AS sysname) AS [ProductLevel],
CAST(SERVERPROPERTY('IsSingleUser') AS bit) AS [IsSingleUser],
CAST(SERVERPROPERTY('EngineEdition') AS int) AS [EngineEdition],
convert(sysname, serverproperty(N'collation')) AS [Collation],
CAST(SERVERPROPERTY('IsClustered') AS bit) AS [IsClustered],
CAST(SERVERPROPERTY(N'MachineName') AS sysname) AS [NetName],
SERVERPROPERTY(N'BuildClrVersion') AS [BuildClrVersionString],
SERVERPROPERTY(N'ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS],
SERVERPROPERTY(N'ResourceVersion') AS [ResourceVersionString],
SERVERPROPERTY(N'ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
SERVERPROPERTY(N'CollationID') AS [CollationID],
SERVERPROPERTY(N'ComparisonStyle') AS [ComparisonStyle],
SERVERPROPERTY(N'SqlCharSet') AS [SqlCharSet],
SERVERPROPERTY(N'SqlCharSetName') AS [SqlCharSetName],
SERVERPROPERTY(N'SqlSortOrder') AS [SqlSortOrder],
SERVERPROPERTY(N'SqlSortOrderName') AS [SqlSortOrderName]