
use mpw_cards_test_mir;
DROP SYMMETRIC KEY cardsSymKey;
DROP ASYMMETRIC KEY cardsAsymKey;
DROP MASTER KEY;

RESTORE SERVICE MASTER KEY 
    FROM FILE = 'H:\SQLBackups\SpecialBackups\servicemasterkey' 
    DECRYPTION BY PASSWORD = 'password'
    FORCE
GO

USE mpw_cards_test_mir;
RESTORE MASTER KEY 
    FROM FILE = 'H:\SQLBackups\SpecialBackups\databasemasterkey' 
    DECRYPTION BY PASSWORD = 'password'
    ENCRYPTION BY PASSWORD = 'password'
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'password' 

CREATE ASYMMETRIC KEY cardsAsymKey
       WITH ALGORITHM = RSA_2048;

CREATE SYMMETRIC KEY cardsSymKey
  WITH ALGORITHM = AES_128
  ENCRYPTION BY ASYMMETRIC KEY cardsAsymKey;

GRANT ALTER ON SYMMETRIC KEY::cardsSymKey TO [NTADMIN\mcsetlprd]
GRANT CONTROL ON ASYMMETRIC KEY::cardsAsymKey TO [NTADMIN\mcsetlprd]

GRANT ALTER ON SYMMETRIC KEY::cardsSymKey TO mcssqlprd
GRANT CONTROL ON ASYMMETRIC KEY::cardsAsymKey TO mcssqlprd  


OPEN SYMMETRIC KEY cardsSymKey DECRYPTION BY ASYMMETRIC KEY cardsAsymKey;
go
insert into  mpw_cards_test_mir..stage_account_consolidated_mnthly_02 ([acct_encr_nbr])
VALUES (EncryptByKey( Key_GUID('cardsSymKey'), CONVERT(varchar,'9012345612345678') ) );    
GO 10

use mpw_cards_test_mir;
SELECT top 100 acct_encr_nbr,
CONVERT(varchar, DecryptByKeyAutoAsymKey ( AsymKey_ID('cardsAsymKey') , NULL ,acct_encr_nbr)) 
FROM stage_account_consolidated_mnthly_02;
