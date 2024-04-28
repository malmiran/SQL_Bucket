
--Add files
alter database MOSS_MigrationTest
add file(name=MOSS_MigrationTest_Data002,size=400MB,filegrowth=100MB,
filename='D:\SQLFiles\MSSQL.1\MSSQL\Data002\MOSS_MigrationTest_Data002.NDF')

alter database MOSS_MigrationTest
add file(name=c,size=400MB,filegrowth=100MB,
filename='D:\SQLFiles\MSSQL.1\MSSQL\Data003\MOSS_MigrationTest_Data003.NDF')

alter database MOSS_MigrationTest
add file(name=MOSS_MigrationTest_DataTemp,size=400MB,filegrowth=100MB,
filename='D:\SQLFiles\MSSQL.1\MSSQL\Data003\MOSS_MigrationTest_DataTemp.NDF')

--Shrink file
use MOSS_MigrationTest
go
dbcc shrinkfile('MOSS_MigrationTest_DataTemp',EMPTYFILE)

use MOSS_MigrationTest
go
dbcc shrinkfile('MOSS_MigrationTest_Data',400)

dbcc shrinkfile('AdventureWorks2008R2_DataTemp',EMPTYFILE)

--Remove file
alter database MOSS_MigrationTest
remove file MOSS_MigrationTest_DataTemp

checkpoint

USE MOSS_MigrationTest;
GO
DBCC UPDATEUSAGE (MOSS_MigrationTest) WITH NO_INFOMSGS; 
GO





USE MASTER
GO
alter database WSS_Content_1234 
modify file(name=WSS_Content_1234_PRIMARY_DATA003,size=30MB)

--Data distribution
use AdventureWorks
go
dbcc showfilestats

1376
1523
1492

--Create table with 1st million rows
SET NOCOUNT ON;
DECLARE @UpperLimit INT;SET @UpperLimit = 1000000;
WITH n AS
(
SELECT 
   x = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
FROM sys.objects AS s1 
CROSS JOIN sys.objects AS s2
CROSS JOIN sys.objects AS s3
)
SELECT [Number] = x  INTO dbo.NumberTest11
FROM n  WHERE x BETWEEN 1 AND @UpperLimit;
GO 

--Insert succeeding million
SET NOCOUNT ON;
DECLARE @LowerLimit INT, @UpperLimit INT;
SET @LowerLimit = 0
SET @UpperLimit = 50000000;
WITH n AS
(
SELECT 
   x = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
FROM sys.objects AS s1 
CROSS JOIN sys.objects AS s2
CROSS JOIN sys.objects AS s3
)
INSERT INTO dbo.NumberTest
SELECT [Number] = x  FROM n  
WHERE x BETWEEN @LowerLimit AND @UpperLimit;
GO 

truncate table dbo.NumberTest
select COUNT(*) from dbo.NumberTest

use AdventureWorks
go
dbcc checkdb
