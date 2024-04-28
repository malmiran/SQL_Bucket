/* From Stefan Posa, taken from the following link
http://utilicode.wordpress.com/2012/04/03/get-command-being-run-by-spid/
*/

/* Get processes and choose the SPID*/
--sp_who2 active

/* Pass the SPID to the script below to get complete TSQL */
DECLARE @SPID INT, @Complete BIT; 
SET @SPID = 73  ; 
SET @Complete = 1;
DECLARE @sqlText VARCHAR(MAX),@i INT, --current location in our string               
           @maxLen INT, --Max length of the SQL               
           @returnLocation INT,  --Location of the carriage return in the SQL               
           @DBName VARCHAR(255)   

SELECT @DBName = name 
from sys.sysdatabases 
where dbid in 
(
    select dbid 
    from sys.sysprocesses 
    where spid = @SPID
)

PRINT '/* USE ' + @DBName + '*/'  
IF @Complete = 1 /* returns the complete query or stored procedure */ 
BEGIN 
    SELECT @sqlText = text  
    FROM sys.dm_exec_sql_text
    (        
        (
           SELECT  TOP 1 sql_handle 
           FROM SYS.SYSPROCESSES
           WHERE SPID = @SPID
           ORDER BY SQL_HANDLE DESC
         )
    )
END
ELSE /* just return the current query */ 
BEGIN
    SELECT @sqlText = SUBSTRING(st.text, (r.statement_start_offset/2)+1,((CASE r.statement_end_offset                        WHEN -1 THEN DATALENGTH(st.text)                        ELSE r.statement_end_offset                        END - r.statement_start_offset)/2) + 1)          
    FROM sys.dm_exec_sessions AS s 
    JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
    CROSS apply sys.dm_exec_sql_text(r.sql_handle) AS st 
    WHERE s.session_id = @SPID 
END
SET @i = 0
SELECT @maxLen = LEN(@sqlText)
WHILE @i < @maxLen 
BEGIN
   SET @returnLocation = CHARINDEX(char(10), SUBSTRING(@sqlText, @i, @maxLen))
   IF @returnLocation = 0        
   BEGIN 
   SET @returnLocation = @maxLen - @i + 1        
   END 
PRINT SUBSTRING(@sqlText, @i, @returnLocation)
SET @i = @i + @returnLocation 
END --WHILE @i < @maxLen 
