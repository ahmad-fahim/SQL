UPDATE EODSODPGMLIST
   SET ESPGMLIST_PROCESS_NAME = 'PKG_GLBALTRF.START_BRNWISE'
 WHERE ESPGMLIST_PROCESS_NAME = 'PKG_GLBALTRF.SP_GLBALTRF';

COMMIT;