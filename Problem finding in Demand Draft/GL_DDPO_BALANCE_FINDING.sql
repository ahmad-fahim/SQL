WITH DAY_WISE_DD_PO_BALANCE
        AS (SELECT '134101101' TRAN_GLACC_CODE,
                   DDPOPAYDB_ADVICE_REC_DATE,
                   DEBIT,
                   CREDIT,
                   SERIAL,
                   SUM (CREDIT - DEBIT) OVER (ORDER BY SERIAL) BALANCE,
                   ROW_NUMBER ()
                   OVER (
                      PARTITION BY DDPOPAYDB_ADVICE_REC_DATE
                      ORDER BY
                         DDPOPAYDB_ADVICE_REC_DATE, SERIAL DESC NULLS LAST)
                      SERIAL_DAY
              FROM (SELECT DDPOPAYDB_ADVICE_REC_DATE,
                           DEBIT,
                           CREDIT,
                           ROW_NUMBER ()
                           OVER (
                              ORDER BY DDPOPAYDB_ADVICE_REC_DATE NULLS LAST)
                              SERIAL,
                           SUM (
                              CREDIT - DEBIT)
                           OVER (PARTITION BY DDPOPAYDB_ADVICE_REC_DATE
                                 ORDER BY DDPOPAYDB_ADVICE_REC_DATE)
                              BALANCE
                      FROM (  SELECT DDPOPAYDB_ADVICE_REC_DATE,
                                     SUM (NVL (DDPOPAYDB_INST_AMT, 0)) CREDIT,
                                     0 DEBIT,
                                     COUNT (*) NUMBER_OF_INSTRUMENT_RECIVE,
                                     0 NUMBER_OF_INSTRUMENT_PAY
                                FROM DDPOPAYDB
                               WHERE DDPOPAYDB_ISSUED_ON_BNK = 200
                                     AND NVL (DDPOPAYDB_STATUS, '#') NOT IN
                                            ('C','D', 'R', 'E','L')
                                     AND TO_NUMBER(DDPOPAYDB_ISSUED_ON_BRN) =
                                            :P_BRANCH_CODE -- AND DDPOPAYDB_ISSUED_BRN<>1206
                                     AND DDPOPAYDB_REMIT_CODE IN ('2', '9')
                            GROUP BY DDPOPAYDB_ADVICE_REC_DATE
                            UNION ALL
                              SELECT DDPOPAY_PAY_DATE DDPOPAYDB_ADVICE_REC_DATE,
                                     0 CREDIT,
                                     SUM (DDPOPAY_INST_AMT) DEBIT,
                                     0 NUMBER_OF_INSTRUMENT_RECIVE,
                                     COUNT (*) NUMBER_OF_INSTRUMENT_PAY
                                FROM (SELECT A.DDPOPAY_PAY_DATE,
                                             A.DDPOPAY_INST_AMT,
                                             A.DDPOPAY_INST_NUM,
                                             A.DDPOPAY_INST_PFX
                                        FROM DDPOPAY A, DDPOPAYDB B
                                       WHERE A.DDPOPAY_INST_NUM =
                                                B.DDPOPAYDB_LEAF_NUM
                                             AND A.DDPOPAY_INST_PFX =
                                                    B.DDPOPAYDB_INST_PFX
                                             AND A.DDPOPAY_REMIT_CODE =
                                                    B.DDPOPAYDB_REMIT_CODE
                                             AND A.DDPOPAY_BRN_CODE =
                                                    TO_NUMBER(B.DDPOPAYDB_ISSUED_ON_BRN)
                                             AND NVL (DDPOPAYDB_STATUS, '#') NOT IN
                                                    ('C', 'D', 'R', 'E', 'L')
                                             AND DDPOPAY_REMIT_CODE IN
                                                    ('2', '9')
                                             AND DDPOPAY_REJ_ON IS NULL
                                             AND DDPOPAY_BRN_CODE =
                                                    :P_BRANCH_CODE
                                             --AND B.DDPOPAYDB_ADVICE_REC_DATE IS NOT NULL
                                             )
                            GROUP BY DDPOPAY_PAY_DATE)))
SELECT TRAN_GLACC_CODE,
       DDPOPAYDB_ADVICE_REC_DATE,
       BALANCE DDPO_BALANCE,
       GLBALH_AC_BAL,
       BALANCE - GLBALH_AC_BAL DDPO_MINUS_GL_BALANCE
  FROM DAY_WISE_DD_PO_BALANCE A, GLBALASONHIST B
 WHERE     A.TRAN_GLACC_CODE = B.GLBALH_GLACC_CODE
       AND A.DDPOPAYDB_ADVICE_REC_DATE = B.GLBALH_ASON_DATE
       AND GLBALH_GLACC_CODE = '134101101'
       AND GLBALH_BRN_CODE = :P_BRANCH_CODE
       AND SERIAL_DAY = 1 ;
