WITH PO_DATA
     AS (SELECT DDPOPAYDB_ENTITY_NUM,
                DDPOPAYDB_REMIT_CODE,
                DDPOPAYDB_INST_PFX,
                DDPOPAYDB_LEAF_NUM,
                DDPOPAYDB_ISSUED_BRN,
                DDPOPAYDB_INST_AMT,
                TO_NUMBER(DDPOPAYDB_ISSUED_ON_BRN),
                DDPOPAYDB_BENEF_NAME1,
                DDPOPAYDB_STATUS,
                DDPOPAYDB_INST_DATE,
                DDPOPAYDB_PAY_CAN_DUP_DATE
           FROM DDPOPAYDB
          WHERE     DDPOPAYDB_ENTITY_NUM = 1
                AND DDPOPAYDB_REMIT_CODE = '1'
                AND DDPOPAYDB_ISSUED_BRN = :P_BRANCH_CODE
                --AND NVL(DDPOPAYDB_STATUS,'#') NOT IN ('C')
                AND TO_NUMBER(DDPOPAYDB_ISSUED_ON_BRN) = :P_BRANCH_CODE),
     DAY_WISE_DD_PO
     AS (  SELECT DDPOPAYDB_INST_DATE DDPOPAYDB_ADVICE_REC_DATE,
                  SUM (NVL (DDPOPAYDB_INST_AMT, 0)) CREDIT,
                  0 DEBIT,
                  COUNT (*) NUMBER_OF_INSTRUMENT_RECIVE,
                  0 NUMBER_OF_INSTRUMENT_PAY
             FROM PO_DATA
             WHERE NVL (DDPOPAYDB_STATUS, '#') <> 'D'
         GROUP BY DDPOPAYDB_INST_DATE
         UNION ALL
           SELECT TRUNC(DDPOPAYDB_PAY_CAN_DUP_DATE) DDPOPAYDB_ADVICE_REC_DATE,
                  0 CREDIT,
                  SUM (NVL (DDPOPAYDB_INST_AMT, 0)) DEBIT,
                  0 NUMBER_OF_INSTRUMENT_RECIVE,
                  COUNT (*) NUMBER_OF_INSTRUMENT_PAY
             FROM PO_DATA
            WHERE NVL (DDPOPAYDB_STATUS, '#') IN ('P', 'C')
            --AND NVL (DDPOPAYDB_STATUS, '#') <> 'D'
         GROUP BY TRUNC(DDPOPAYDB_PAY_CAN_DUP_DATE)),
     DAY_WISE_DD_PO_BALANCE
     AS (SELECT '134104101' TRAN_GLACC_CODE,
                DDPOPAYDB_ADVICE_REC_DATE,
                DEBIT,
                CREDIT,
                SERIAL,
                SUM (CREDIT - DEBIT) OVER (ORDER BY SERIAL) BALANCE,
                ROW_NUMBER ()
                OVER (
                   PARTITION BY DDPOPAYDB_ADVICE_REC_DATE
                   ORDER BY DDPOPAYDB_ADVICE_REC_DATE, SERIAL DESC NULLS LAST)
                   SERIAL_DAY
           FROM (SELECT DDPOPAYDB_ADVICE_REC_DATE,
                        DEBIT,
                        CREDIT,
                        ROW_NUMBER ()
                        OVER (ORDER BY DDPOPAYDB_ADVICE_REC_DATE NULLS LAST)
                           SERIAL,
                        SUM (
                           CREDIT - DEBIT)
                        OVER (PARTITION BY DDPOPAYDB_ADVICE_REC_DATE
                              ORDER BY DDPOPAYDB_ADVICE_REC_DATE)
                           BALANCE
                   FROM DAY_WISE_DD_PO))
SELECT TRAN_GLACC_CODE,
       DDPOPAYDB_ADVICE_REC_DATE,
       BALANCE DDPO_BALANCE,
       GLBALH_AC_BAL,
       BALANCE - GLBALH_AC_BAL DDPO_MINUS_GL_BALANCE
  FROM DAY_WISE_DD_PO_BALANCE A, GLBALASONHIST B
 WHERE     A.TRAN_GLACC_CODE = B.GLBALH_GLACC_CODE
       AND A.DDPOPAYDB_ADVICE_REC_DATE = B.GLBALH_ASON_DATE
       AND GLBALH_GLACC_CODE = '134104101'
       AND GLBALH_BRN_CODE = :P_BRANCH_CODE
       AND SERIAL_DAY = 1 ;