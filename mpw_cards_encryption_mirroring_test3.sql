
select * from sys.master_files

F:\SQLBackups\SpecialBackups

restore filelistonly
from disk = 'E:\SQLBackups\SpecialBackups\mpw_cards_test_mir.BAK'


restore database mpw_cards_test_mir
from disk = 'h:\SQLBackups\SpecialBackups\mpw_cards_test_mir.BAK'
with move 'mpw_cards_test_mir' to 'h:\DBData\mpw_cards_test_mir.mdf',
move 'mpw_cards_test_mir_log' to 'h:\DBLog\mpw_cards_test_mir.ldf'

use mpw_cards_test_mir;
SELECT top 100 acct_encr_nbr,
CONVERT(varchar, DecryptByKeyAutoAsymKey ( AsymKey_ID('cardsAsymKey') , NULL ,acct_encr_nbr)) 
FROM stage_account_consolidated_mnthly_02;

backup database mpw_cards_test_mir
to disk = 'H:\SQLBackups\SpecialBackups\mpw_cards_test_mir.BAK'
go
backup log mpw_cards_test_mir
to disk = 'H:\SQLBackups\SpecialBackups\mpw_cards_test_mir_1.TRN'
go
backup log mpw_cards_test_mir
to disk = 'H:\SQLBackups\SpecialBackups\mpw_cards_test_mir_2.TRN'
go

sp_helpdb mpw_cards_test_mir

alter database mpw_cards_test_mir
set partner = 'TCP://NTSYDDBR324V4.pc.internal.macquarie.com:60295'

use master;
alter database mpw_cards_test_mir set partner failover

use master;
alter database mpw_cards_test_mir set partner off

select * from sys.master_key_passwords

sp_control_dbmasterkey_password @db_name = N'mpw_cards_test_mir', 
@password = N'password', @action = N'drop';


select * from dbadmin..configplans
--UPDATE dbadmin..configplans SET disableplan = 'YES'
where planname = 'TRN'
and databasename = 'mpw_cards_test_mir'



  CREATE LOGIN [NTADMIN\mcsetlprd] FROM WINDOWS WITH DEFAULT_DATABASE = [mpw_cards_prd]; 
CREATE LOGIN mcssqlprd WITH PASSWORD = 0x0100B56B4723F43A9FD7B3046379BDD6C2FEC0B3C03C803C849B HASHED, SID = 0xA86D94CD4DB9994B8B51FBCE92ABBFDA, DEFAULT_DATABASE = [mpw_cards_prd];  
  
create user [NTADMIN\mcsetlprd] for login [NTADMIN\mcsetlprd];
create user mcssqlprd for login mcssqlprd


BACKUP SERVICE MASTER KEY
TO FILE = 'H:\SQLBackups\SpecialBackups\servicemasterkey'
    ENCRYPTION BY PASSWORD = 'password';
GO 

USE mpw_cards_test_mir;
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'password';
BACKUP MASTER KEY TO FILE = 'H:\SQLBackups\SpecialBackups\databasemasterkey' 
    ENCRYPTION BY PASSWORD = 'password';
GO 

use master;
alter database mpw_cards_test_mir set partner failover

sp_who2 active


OPEN SYMMETRIC KEY cardsSymKey DECRYPTION BY ASYMMETRIC KEY cardsAsymKey;
go
insert into  mpw_cards_test_mir..stage_account_consolidated_mnthly_02 ([acct_encr_nbr])
VALUES (EncryptByKey( Key_GUID('cardsSymKey'), CONVERT(varchar,'9012345612345678') ) );    
GO 10

use mpw_cards_test_mir;
SELECT top 100 acct_encr_nbr,
CONVERT(varchar, DecryptByKeyAutoAsymKey ( AsymKey_ID('cardsAsymKey') , NULL ,acct_encr_nbr)) 
FROM stage_account_consolidated_mnthly_02;
