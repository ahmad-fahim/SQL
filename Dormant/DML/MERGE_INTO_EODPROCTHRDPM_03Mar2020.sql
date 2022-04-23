MERGE INTO EODPROCTHRDPM e
     USING (SELECT 'PKG_DORINOPMARK.START_BRNWISE' process_name FROM DUAL) h
        ON (e.EODPROCT_PROCESS_NAME = h.process_name)
WHEN MATCHED
THEN
   UPDATE SET e.EODPROCT_NUM_OF_THREADS = 24, e.EODPROCT_THREAD_REQD = '1'
WHEN NOT MATCHED
THEN
   INSERT     (EODPROCT_ENTITY_NUM,
               EODPROCT_SODEOD_FLG,
               EODPROCT_PROCESS_NAME,
               EODPROCT_THREAD_REQD,
               EODPROCT_NUM_OF_THREADS)
       VALUES (1,
               'E',
               'PKG_DORINOPMARK.START_BRNWISE',
               '1',
               24);
               
COMMIT ;
