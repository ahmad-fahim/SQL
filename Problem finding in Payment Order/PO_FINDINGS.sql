SELECT TO_CHAR (:P_TRAN_DATE, 'DD-MM-YYYY') MISMATCH_DATE,
       :P_BRANCH_CODE BRANCH_CODE,
       AA.*,
       BB.*,
       NVL (AA.AMOUNT, 0) - NVL (BB.AMOUNT, 0) DIFF
  FROM (SELECT 'DDPOPAYDB' IDENTIFY,
               'C' DBCR,
               COUNT (*) TOTAL_NUMBER_OF_INST,
               NVL (SUM (DDPOPAYDB_INST_AMT), 0) AMOUNT
          FROM DDPOPAYDB
         WHERE     DDPOPAYDB_ENTITY_NUM = 1
               AND DDPOPAYDB_ISSUED_BANK = 200
               AND DDPOPAYDB_INST_DATE = :P_TRAN_DATE
               AND DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
               AND DDPOPAYDB_REMIT_CODE = '1'
        UNION ALL
        SELECT 'DDPOPAYDB' IDENTIFY,
               'D' DBCR,
               COUNT (*) TOTAL_NUMBER_OF_INST,
               NVL (SUM (DDPOPAYDB_INST_AMT), 0) AMOUNT
          FROM DDPOPAYDB
         WHERE     DDPOPAYDB_ENTITY_NUM = 1
               AND DDPOPAYDB_ISSUED_BANK = 200
               AND DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
               AND TRUNC (DDPOPAYDB_PAY_CAN_DUP_DATE) = :P_TRAN_DATE
               AND DDPOPAYDB_REMIT_CODE = '1') AA
       LEFT OUTER JOIN
       (  SELECT 'TRAN' IDENTIFY,
                 TRAN_DB_CR_FLG DBCR,
                 COUNT (*) TOTAL_NUMBER_OF_INST,
                 SUM (TRAN_AMOUNT) AMOUNT
            FROM TRAN2019
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                 AND TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
                 AND TRAN_GLACC_CODE = '134104101'
                 AND TRAN_AUTH_BY IS NOT NULL
                 AND TRAN_AMOUNT <> 0
        GROUP BY TRAN_DB_CR_FLG) BB
          ON (AA.DBCR = BB.DBCR);



------------- ddpopay minus ddpopaydb-----------------

SELECT DDPOPAY_INST_NUM
  FROM DDPOPAY
 WHERE     DDPOPAY_ENTITY_NUM = 1
       AND DDPOPAY_BRN_CODE = :P_BRANCH_CODE
       AND DDPOPAY_PAY_DATE = :P_TRAN_DATE
       AND DDPOPAY_REMIT_CODE = '1'
       AND DDPOPAY_AUTH_BY IS NOT NULL
MINUS
SELECT DDPOPAYDB_LEAF_NUM
  FROM DDPOPAYDB
 WHERE     DDPOPAYDB_ENTITY_NUM = 1
       AND DDPOPAYDB_REMIT_CODE = '1'
       AND DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
       AND TRUNC (DDPOPAYDB_PAY_CAN_DUP_DATE) = :P_TRAN_DATE;



SELECT DDPOPAYDB_LEAF_NUM
  FROM DDPOPAYDB
 WHERE     DDPOPAYDB_ENTITY_NUM = 1
       AND DDPOPAYDB_REMIT_CODE = '1'
       AND DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
       AND DDPOPAYDB_PAY_CAN_DUP_DATE = :P_TRAN_DATE
MINUS
SELECT DDPOPAY_INST_NUM
  FROM DDPOPAY
 WHERE     DDPOPAY_ENTITY_NUM = 1
       AND DDPOPAY_BRN_CODE = :P_BRANCH_CODE
       AND DDPOPAY_PAY_DATE = :P_TRAN_DATE
       AND DDPOPAY_REMIT_CODE = '1'
       AND DDPOPAY_AUTH_BY IS NOT NULL ;
       
       
       
SELECT *
            FROM TRAN2016
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                 AND TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
                 AND TRAN_GLACC_CODE = '134104101'
                 AND TRAN_AUTH_BY IS NOT NULL
                 AND TRAN_AMOUNT <> 0
                 AND TRAN_DB_CR_FLG = 'C' 
                 AND TRAN_INSTR_CHQ_NUMBER = 0;
                 
                 
SELECT *
          FROM DDPOPAYDB
         WHERE     DDPOPAYDB_ENTITY_NUM = 1
               AND DDPOPAYDB_ISSUED_BANK = 200
               AND DDPOPAYDB_INST_DATE = :P_TRAN_DATE
               AND DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
               AND DDPOPAYDB_REMIT_CODE = '1'