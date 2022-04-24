/*

SELECT --DDPOPAYDB_INST_PFX, DDPOPAYDB_LEAF_NUM 
COUNT(*) NUMBER_OF_DD, NVL(SUM(DDD.DDPOPAYDB_INST_AMT), 0) DD_BALANCE
  FROM DDPOPAYDB DDD
 WHERE (DDD.DDPOPAYDB_INST_PFX, DDD.DDPOPAYDB_LEAF_NUM,
        DDD.DDPOPAYDB_INST_AMT) IN
       (SELECT DD.DDPOISSDTL_INST_NUM_PFX,
               DD.DDPOISSDTL_INST_NUM,
               DD.DDPOISSDTL_INST_AMT
          FROM DDPOISSDTL DD
         WHERE (DD.DDPOISSDTL_BRN_CODE, DD.DDPOISSDTL_REMIT_CODE,
                DD.DDPOISSDTL_ISSUE_DATE, DD.DDPOISSDTL_DAY_SL) IN
               (SELECT D.DDPOISS_BRN_CODE,
                       D.DDPOISS_REMIT_CODE,
                       D.DDPOISS_ISSUE_DATE,
                       D.DDPOISS_DAY_SL
                  FROM DDPOISS D
                 WHERE D.DDPOISS_ENTD_BY = 'MIG'
                 AND D.DDPOISS_BRN_CODE = :P_BRANCH_CODE 
                 AND D.DDPOISS_REMIT_CODE IN ('2','9')))
   AND DDD.DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
   AND DDD.DDPOPAYDB_REMIT_CODE IN ( '2', '9') ;

    */
    
   
SELECT SUM(DDADVPART_INST_AMT), COUNT(*) FROM DDADVPART , DDADVPARTDTL
WHERE 
DDADVPART_ENTITY_NUM = 1
AND DDADVPART_BRN_CODE = :P_BRANCH_CODE 
AND DDADVPART_ENTD_BY = 'MIG' 
AND DDADVPARTDTL_ENTITY_NUM = 1
AND DDADVPARTDTL_BRN_CODE = DDADVPART_BRN_CODE
AND DDADVPARTDTL_ADVICE_NO = DDADVPART_ADVICE_NO
AND DDADVPARTDTL_ADVICE_DATE = DDADVPART_ADVICE_DATE
AND DDADVPARTDTL_LEAF_PFX = DDADVPART_LEAF_PFX
AND DDADVPARTDTL_LEAF_NUMBER = DDADVPART_LEAF_NUMBER 
AND DDADVPARTDTL_REM_CODE IN ( '2', '9')