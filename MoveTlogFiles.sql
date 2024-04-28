
/* STEPS TO MOVE TLOG FILE OF SMS_SYD TO F:\Tlog */
/* CONNECT TO NTSYDINP160,50553 USING SSMS */
/* RUN THE FOLLOWING T-SQL QUERIES SEQUENTIALLY */

/* #1 - VERIFY THAT DB IS ONLINE AND CURRENT LOG FILE LOCATION  */
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'SMS_SYD')


/* #2 - OFFLINE DB */
ALTER DATABASE SMS_SYD SET OFFLINE
GO

/* #3 - PHYSICALLY MOVE LOG FILE TO F:\TLogs */

/* #4 - UPDATE METADATA FILE LOCATION */
ALTER DATABASE SMS_SYD
MODIFY FILE (NAME=SMS_SYD_log, FILENAME='F:\TLogs\SMS_SYD_log.LDF')
GO

/* #5 - ONLINE DB */
ALTER DATABASE SMS_SYD SET ONLINE
GO

/* #6 - VERIFY THAT DB IS ONLINE AND LOG FILE METADATA LOCATION HAS BEEN UPDATED */
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'SMS_SYD')



