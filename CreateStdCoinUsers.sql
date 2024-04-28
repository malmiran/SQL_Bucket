DECLARE @db_name varchar(25), @new_db_user varchar(25)
SET @db_name = ''

IF @db_name IS NULL OR @db_name = '' OR @db_name LIKE '% %'                            
BEGIN
RAISERROR('Please supply a valid database name.',16,1)
RETURN;
END

SELECT @new_db_user =  'strategy' + substring(@db_name, charindex('_', @db_name),len(@db_name))

SET QUOTED_IDENTIFIER OFF;    

DECLARE @query VARCHAR(MAX)    
SET @query =                                  
"                                  
IF EXISTS(SELECT name FROM " + @db_name + "..sysusers WHERE name = '" + @new_db_user + "')                                          
BEGIN                                  
  EXEC('USE " + @db_name + "; EXEC sp_change_users_login update_one, " + @new_db_user + ", " + @new_db_user + " ')                                  
  EXEC('USE " + @db_name + "; EXEC sp_addrolemember db_owner, " + @new_db_user + " ')                                  
  PRINT 'The specified new user already exists. User has been sycned and granted db_owner privilege'                                  
END                         
ELSE                               
BEGIN                                  
  EXEC('USE " + @db_name + "; CREATE USER " + @new_db_user + " FOR LOGIN " + @new_db_user + " ')                                  
  EXEC('USE " + @db_name + "; EXEC sp_addrolemember db_owner, " + @new_db_user + " ')                                  
  PRINT '" + @new_db_user + " was successfully created in the database and granted db_owner privilege.'                                  
END                                  
"   
--print @query      
EXECUTE sp_executesql @query     

/*
--Create strategy_user                                             
EXEC (                                            
'                                  
IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''strategy_user'')                                     
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_change_users_login update_one, strategy_user, strategy_user'');                          
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_owner, strategy_user'')                         
  PRINT ''strategy_user was orphaned and has been fixed with db_owner privilege''                                      
END                                              
ELSE                                              
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'CREATE USER strategy_user FOR LOGIN strategy_user'')                                     
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_owner, strategy_user'')                           
  PRINT ''strategy_user user created with db_owner privilege''                                             
END                                              
'                                              
)                                     

--Create coinadmin                                              
EXEC (                                              
'                                              
IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''coinadmin'')                                    
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_change_users_login update_one, coinadmin, coinadmin'');                          
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, coinadmin'')                     
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_denydatawriter, coinadmin'')                          
  PRINT ''coinadmin was orphaned and has been fixed with db_datareader and db_denydatawriter permissions''                                    
END                                              
ELSE                                              
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'CREATE USER coinadmin FOR LOGIN coinadmin'')                                    
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, coinadmin'')                     
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_denydatawriter, coinadmin'')                 
  PRINT ''coinadmin user created and granted db_datareader and db_denydatawriter''                                   
END          
'                                              
)                                    

--Create NTADMIN\Coinadmin                                              
EXEC (                                              
'                                              
IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''NTADMIN\Coinadmin'')                                            
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'ALTER USER [NTADMIN\Coinadmin] WITH LOGIN = [NTADMIN\Coinadmin]'');                      
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\Coinadmin]'')                      
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_denydatawriter, [NTADMIN\Coinadmin]'')                       
  PRINT ''NTADMIN\Coinadmin user has been synced with the login and granted db_datareader and db_denydatawriter''                                            
END                                              
ELSE                                              
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'CREATE USER [NTADMIN\Coinadmin] FROM LOGIN [NTADMIN\Coinadmin]'')                          
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\Coinadmin]'')                        
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_denydatawriter, [NTADMIN\Coinadmin]'')                      
  PRINT ''NTADMIN\Coinadmin user was created and granted db_datareader and db_denydatawriter''                      
END                                              
'                       
)                          

--Create dcm_dbo                                              
EXEC (                                              
'                                              
IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''dcm_dbo'')                            
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_change_users_login update_one, dcm_dbo, dcm_dbo'');                  
 EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_owner, dcm_dbo'')                     
  PRINT ''dcm_dbo was orphaned and has been fixed with db_owner privilege''                           
END                                              
ELSE                                              
BEGIN                                              
  EXEC(''USE ' + @db_name + '; ' + 'CREATE USER dcm_dbo FOR LOGIN dcm_dbo'')                            
  EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_owner, dcm_dbo'')                    
  PRINT ''dcm_dbo user created with db_owner privilege''                                          
END                                              
'               
)                                              

--Create NTADMIN\HostingMaint_User                        
 EXEC (                                    
  '                                              
  IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''NTADMIN\HostingMaint_User'')                                              
  BEGIN                                              
    EXEC(''USE ' + @db_name + '; ' + 'ALTER USER [NTADMIN\HostingMaint_User] WITH LOGIN = [NTADMIN\HostingMaint_User]'');                            
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\HostingMaint_User]'')                         
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datawriter, [NTADMIN\HostingMaint_User]'')      
    EXEC(''USE ' + @db_name + '; ' + 'GRANT ALTER ANY SCHEMA TO [NTADMIN\Coinadmin]'')                           
    PRINT ''NTADMIN\HostingMaint_User user has been synced with the login and granted db_datareader,db_datawriter and ALTER ANY SCHEMA permissions''                                
  END                                              
  ELSE                                              
  BEGIN                                              
    EXEC(''USE ' + @db_name + '; ' + 'CREATE USER [NTADMIN\HostingMaint_User] FROM LOGIN [NTADMIN\HostingMaint_User]'');                        
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\HostingMaint_User]'')                        
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datawriter, [NTADMIN\HostingMaint_User]'')                        
    EXEC(''USE ' + @db_name + '; ' + 'GRANT ALTER ANY SCHEMA TO [NTADMIN\HostingMaint_User]'');                        
    PRINT ''NTADMIN\HostingMaint_User user was created and granted db_datareader, db_datawriter and ALTER ANY SCHEMA permissions''                        
  END                                            '                                              
  )                                    

--Create NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01                  
 EXEC (                                              
  '                                              
  IF EXISTS(SELECT TOP 1 * FROM ' + @db_name + '..sysusers WHERE name = ''NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01'')                                              
  BEGIN                                              
    EXEC(''USE ' + @db_name + '; ' + 'ALTER USER [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01] WITH LOGIN = [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'');                            
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'')                   
    EXEC(''USE ' + @db_name + '; ' + 'GRANT VIEW DEFINITION TO [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'')                           
    PRINT ''NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01 user has been synced with the login and granted db_datareader and VIEW DEFINITION permissions''                                
  END                                              
  ELSE                                              
  BEGIN                                              
    EXEC(''USE ' + @db_name + '; ' + 'CREATE USER [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01] FROM LOGIN [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'');                        
    EXEC(''USE ' + @db_name + '; ' + 'EXEC sp_addrolemember db_datareader, [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'')                
    EXEC(''USE ' + @db_name + '; ' + 'GRANT VIEW DEFINITION TO [NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01]'')                         
    PRINT ''NTADMIN\SGG-SQL-AllDBs-RO-SYDDBP313SQL01 user was created and granted db_datareader and VIEW DEFINITION permissions''                        
  END                                              
  '                                              
  )                    
*/
SET QUOTED_IDENTIFIER ON;    
