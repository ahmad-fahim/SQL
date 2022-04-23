CREATE TABLE DDPOPAYDB_BAK AS
SELECT DDPOPAYDB_REMIT_CODE,
                  DDPOPAYDB_INST_PFX,
                  DDPOPAYDB_LEAF_NUM
             FROM DDPOPAYDB, MIG_DETAIL
            WHERE     BRANCH_CODE = DDPOPAYDB_ISSUED_ON_BRN
                  AND DDPOPAYDB_INST_DATE = MIG_END_DATE
                  AND DDPOPAYDB_REMIT_CODE IN ('2', '9')
                  AND (DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM) NOT IN
                         (SELECT DDADVPARTDTL_REM_CODE,
                                 DDADVPARTDTL_LEAF_PFX,
                                 DDADVPARTDTL_LEAF_NUMBER
                            FROM DDADVPARTDTL)
                  AND DDPOPAYDB_ADVICE_REC_DATE IS NOT NULL
                  AND DDPOPAYDB_ADVICE_REC_DATE = MIG_END_DATE;




UPDATE DDPOPAYDB D
   SET D.DDPOPAYDB_ADVICE_REC_DATE = NULL
 WHERE (D.DDPOPAYDB_REMIT_CODE, D.DDPOPAYDB_INST_PFX, D.DDPOPAYDB_LEAF_NUM) IN
          (SELECT DDPOPAYDB_REMIT_CODE,
                  DDPOPAYDB_INST_PFX,
                  DDPOPAYDB_LEAF_NUM
             FROM DDPOPAYDB, MIG_DETAIL
            WHERE     BRANCH_CODE = DDPOPAYDB_ISSUED_ON_BRN
                  AND DDPOPAYDB_INST_DATE = MIG_END_DATE
                  AND DDPOPAYDB_REMIT_CODE IN ('2', '9')
                  AND (DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM) NOT IN
                         (SELECT DDADVPARTDTL_REM_CODE,
                                 DDADVPARTDTL_LEAF_PFX,
                                 DDADVPARTDTL_LEAF_NUMBER
                            FROM DDADVPARTDTL)
                  AND DDPOPAYDB_ADVICE_REC_DATE IS NOT NULL
                  AND DDPOPAYDB_ADVICE_REC_DATE = MIG_END_DATE) ;
				  
				  
