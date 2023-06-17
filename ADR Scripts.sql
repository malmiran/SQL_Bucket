


/* Check PVS size */
/*
Establish a baseline during peak workload.
Monitor over time. 
If PVS is significantly larger than baseline or close to 50% of DB size, considered large
*/
SELECT DB_Name(database_id), 
 persistent_version_store_size_kb 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = db_id('AdrDemo')

/* Change the location of the PVS to a different filegoup */
/* 1. Turn off ADR */
ALTER DATABASE [MyDatabase] SET ACCELERATED_DATABASE_RECOVERY = OFF;
GO

/* 2. Make sure current PVS is deallocated/emptied */
EXEC sys.sp_persistent_version_cleanup [database name];

/* 3. Confirm it's been emptied */
SELECT DB_Name(database_id), persistent_version_store_size_kb 
FROM sys.dm_tran_persistent_version_store_stats
WHERE database_id = db_id('AdrDemo')

/* 4. Turn on ADR and specify the new location/filegroup */
ALTER DATABASE [MyDatabase] SET ACCELERATED_DATABASE_RECOVERY = ON
(PERSISTENT_VERSION_STORE_FILEGROUP = [New FG]);

/* PVS Stats */
/*
- Check size of PVS vs DB
- Determine which factor is preventing PVS cleanup
- If PVS is large (i.e., from baseline or ~50% of db)...
- Check long running active transactions by getting "oldest_active_transaction_id" and using sys.dm_tran_database_transactions to check how long it's been running
*/
SELECT
 db_name(pvss.database_id) AS DBName,
 pvss.persistent_version_store_size_kb / 1024. / 1024 AS persistent_version_store_size_gb,
 100 * pvss.persistent_version_store_size_kb / df.total_db_size_kb AS pvs_pct_of_database_size,
 df.total_db_size_kb/1024./1024 AS total_db_size_gb,
 pvss.online_index_version_store_size_kb / 1024. / 1024 AS online_index_version_store_size_gb,
 pvss.current_aborted_transaction_count,
 pvss.aborted_version_cleaner_start_time,
 pvss.aborted_version_cleaner_end_time,
 dt.database_transaction_begin_time AS oldest_transaction_begin_time,
 asdt.session_id AS active_transaction_session_id,
 asdt.elapsed_time_seconds AS active_transaction_elapsed_time_seconds,
 pvss.pvs_off_row_page_skipped_low_water_mark,
 pvss.pvs_off_row_page_skipped_min_useful_xts
 --pvss.pvs_off_row_page_skipped_oldest_aborted_xdesid /* SQL Server 2022 only */
FROM sys.dm_tran_persistent_version_store_stats AS pvss
CROSS APPLY (SELECT SUM(size*8.) AS total_db_size_kb FROM sys.database_files WHERE [state] = 0 and [type] = 0 ) AS df 
LEFT JOIN sys.dm_tran_database_transactions AS dt
ON pvss.oldest_active_transaction_id = dt.transaction_id
   AND
   pvss.database_id = dt.database_id
LEFT JOIN sys.dm_tran_active_snapshot_database_transactions AS asdt
ON pvss.min_transaction_timestamp = asdt.transaction_sequence_num
   OR
   pvss.online_index_min_transaction_timestamp = asdt.transaction_sequence_num
WHERE pvss.database_id = DB_ID('AdrDemo');