UPDATE EODSODPROCDTL
   SET ESPROCDTL_PROCESS_NAME = 'PKG_GLBALTRF.START_BRNWISE'
 WHERE ESPROCDTL_PROCESS_NAME = 'PKG_GLBALTRF.SP_GLBALTRF';

COMMIT;