--drop all statistics for the config, datamine, and illuminator 

select @@servername[sql_server]
go
select name, is_auto_create_stats_on, is_auto_update_stats_on, is_auto_update_stats_async_on from sys.databases
where name in ('config','datamine','illuminator')

select * from dbadmin..configreorg

sp_helpdb illuminator

/*

USE [master]
GO
ALTER DATABASE [config] SET AUTO_UPDATE_STATISTICS OFF WITH NO_WAIT
GO
ALTER DATABASE [config] SET AUTO_UPDATE_STATISTICS OFF 
GO
ALTER DATABASE [datamine] SET AUTO_UPDATE_STATISTICS OFF WITH NO_WAIT
GO
ALTER DATABASE [datamine] SET AUTO_UPDATE_STATISTICS OFF 
GO
ALTER DATABASE [illuminator] SET AUTO_UPDATE_STATISTICS OFF WITH NO_WAIT
GO
ALTER DATABASE [illuminator] SET AUTO_UPDATE_STATISTICS OFF 
GO

*/
