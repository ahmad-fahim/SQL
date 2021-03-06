DECLARE
   V_BANK_CODE   VARCHAR2 (10);
BEGIN
   SELECT INS_OUR_BANK_CODE INTO V_BANK_CODE FROM INSTALL;

   IF V_BANK_CODE = '200'
   THEN
      UPDATE EODSODPROCDTL
         SET ESPROCDTL_RUN_FREQ = 'D'
       WHERE     ESPROCDTL_ENTITY_NUM = 1
             AND ESPROCDTL_PROCESS_NAME =
                    'PKG_LOAN_INT_CALC_PROCESS.PROC_BRN_WISE';

      UPDATE EODSODPROCDTL
         SET ESPROCDTL_DISABLED = '1'
       WHERE     ESPROCDTL_ENTITY_NUM = 1
             AND ESPROCDTL_PROCESS_NAME =
                    'PKG_LOAN_INT_CALC_PROCESS_MRR.PROC_BRN';

      UPDATE EODSODPROCDTL
         SET ESPROCDTL_RUN_FREQ = 'D'
       WHERE     ESPROCDTL_ENTITY_NUM = 1
             AND ESPROCDTL_PROCESS_NAME = 'PKG_LNODUPDATE.SP_LNODUPDATE';
   END IF;
END;