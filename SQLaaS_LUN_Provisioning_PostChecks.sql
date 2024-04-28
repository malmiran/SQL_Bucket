/* GET DEFAULT DATA AND LOG LOCATION
select * from sys.master_files
E:\DBData\DBAdmin.mdf
E:\DBLog\DBAdmin_log.LDF
*/

/* CREATE TESTLUN DATABASE - Verify permissions of data an log */
/* SAMPLE
USE master;
GO
CREATE DATABASE [TESTLUN] ON  PRIMARY 
(  NAME = N'TESTLUN1', FILENAME = N'h:\DBData\TESTLUN1.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB)
 LOG ON 
( NAME = N'TESTLUN_log', FILENAME = N'H:\DBLog\TLog001\TESTLUN_log.LDF' , SIZE = 5120KB , MAXSIZE = 51200KB , FILEGROWTH = 5120KB )
GO

CREATE DATABASE [TESTLUN] ON  PRIMARY 
(  NAME = N'TESTLUN1', FILENAME = N'J:\DBData\TESTLUN1.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN2', FILENAME = N'J:\DBData\Data002\TESTLUN2.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN3', FILENAME = N'H:\DBData\Data003\TESTLUN3.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN4', FILENAME = N'H:\DBData\Data004\TESTLUN4.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN5', FILENAME = N'H:\DBData\Data005\TESTLUN5.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB)
 LOG ON 
( NAME = N'TESTLUN_log', FILENAME = N'H:\DBLog\TLog001\TESTLUN_log.LDF' , SIZE = 5120KB , MAXSIZE = 51200KB , FILEGROWTH = 5120KB )
GO
*/

USE master;
GO
CREATE DATABASE [TESTLUN] ON  PRIMARY 
(  NAME = N'TESTLUN1', FILENAME = N'I:\DBData\TESTLUN1.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN2', FILENAME = N'I:\DBData\Data002\TESTLUN2.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN3', FILENAME = N'I:\DBData\Data003\TESTLUN3.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN4', FILENAME = N'I:\DBData\Data004\TESTLUN4.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB),
(  NAME = N'TESTLUN5', FILENAME = N'I:\DBData\Data005\TESTLUN5.mdf' , SIZE = 10240KB , MAXSIZE = 102400KB ,   FILEGROWTH = 10240KB)
 LOG ON 
( NAME = N'TESTLUN_log', FILENAME = N'I:\DBLog\TESTLUN_log.LDF' , SIZE = 5120KB , MAXSIZE = 51200KB , FILEGROWTH = 5120KB )
GO



--DROP DATABASE [TESTLUN]
--DELETE FROM DBAdmin..ConfigPlans WHERE DatabaseName = 'TESTLUN'


/* CREATE NEW BACKUP - Verify permissions of SQLBackups */
--SELECT * FROM DBAdmin..ConfigCleanup
BACKUP DATABASE [TESTLUN] TO DISK = 'I:\SQLBackups\SpecialBackups\M324CUAT05\TESTLUN.BAK'
BACKUP DATABASE [TESTLUN] TO DISK = 'I:\SQLAdmin\TESTLUN.BAK'

--EXEC xp_cmdshell 'del /Q I:\SQLBackups\SpecialBackups\M324CUAT05\TESTLUN.BAK'


