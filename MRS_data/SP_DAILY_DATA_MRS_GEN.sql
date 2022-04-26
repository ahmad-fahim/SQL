CREATE OR REPLACE PROCEDURE         SP_DAILY_DATA_MRS_GEN (P_ASON_DATE DATE)
AS
   V_NO_OF_BRN            NUMBER := 0;
   V_TOTAL_BRN            NUMBER := 0;
   V_ERROR_MSG            VARCHAR2 (1000);
   V_EXCEPTION            EXCEPTION;
   V_WEEK_DAY             VARCHAR2 (100);
   V_TOTAL_CLIENTS        NUMBER;
   V_INVALID_MOBILE       NUMBER;
   V_TOTAL_REGI_CLIENTS   NUMBER;
   V_VALID_MOBILE         NUMBER;
   V_VALID_MOB_NOT_REGI   NUMBER;
   W_SQL   VARCHAR2(3000);
BEGIN
   SELECT COUNT (DISTINCT RPT_BRN_CODE)
     INTO V_NO_OF_BRN
     FROM STATMENTOFAFFAIRS
    WHERE RPT_ENTRY_DATE = P_ASON_DATE AND CASHTYPE = '1';

   SELECT COUNT (*)
     INTO V_TOTAL_BRN
     FROM MBRN_CORE
    WHERE NONCORE = '0' AND MIG_DATE <= P_ASON_DATE;

   SELECT TO_CHAR (P_ASON_DATE, 'DAY') INTO V_WEEK_DAY FROM DUAL;

   IF V_NO_OF_BRN < V_TOTAL_BRN
   THEN
      V_ERROR_MSG :=
         'All branches data for affairs is not prepared yet. First you need to generate all F12 data from PROGRESS screen';
      RAISE_APPLICATION_ERROR (-20001, V_ERROR_MSG);
   END IF;

   SELECT COUNT (DISTINCT RPT_BRN_CODE)
     INTO V_NO_OF_BRN
     FROM INCOMEEXPENSE
    WHERE RPT_ENTRY_DATE = P_ASON_DATE;


   IF V_NO_OF_BRN < V_TOTAL_BRN
   THEN
      V_ERROR_MSG :=
         'All branches data for income and expense is not prepared yet. First you need to generate all F42 data from PROGRESS screen';
      RAISE_APPLICATION_ERROR (-20001, V_ERROR_MSG);
   END IF;

   DELETE FROM F12_HEADWISE;

   COMMIT;

   DELETE FROM F12_HEADWISE_TEMP;

   COMMIT;

   DELETE FROM F42_HEADWISE_TEMP;

   COMMIT;

   DELETE FROM F42_HEADWISE;

   COMMIT;

   DELETE FROM BRNWISE_PROFIT_LOSS;

   COMMIT;

   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      INSERT INTO F12_HEADWISE_TEMP
           SELECT RPT_HEAD_CODE,
                  SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
                  SUM (NUM_OF_ACCOUNT) HEAD_NUMBER_OF_ACCOUNT,
                  RPT_ENTRY_DATE,
                  RPT_BRN_CODE
             FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                            'F12',
                            IDX.BRANCH_CODE,
                            P_ASON_DATE,
                            1))
         GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE, RPT_BRN_CODE;

      COMMIT;

      INSERT INTO F42_HEADWISE_TEMP
           SELECT RPT_HEAD_CODE,
                  SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
                  RPT_ENTRY_DATE,
                  RPT_BRN_CODE
             FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                            'F42',
                            IDX.BRANCH_CODE,
                            P_ASON_DATE,
                            1))
         GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE, RPT_BRN_CODE;

      COMMIT;

      INSERT INTO BRNWISE_PROFIT_LOSS
           SELECT RPT_BRN_CODE BRCODE,
                  P_ASON_DATE REPORTING_DATE,
                  SUM (INCOME) TOTAL_INCOME,
                  SUM (EXPENSE) TOTAL_EXPENSE,
                  CASE
                     WHEN SUM (INCOME) - SUM (EXPENSE) > 0 THEN 'Profit'
                     WHEN SUM (INCOME) - SUM (EXPENSE) < 0 THEN 'Loss'
                     ELSE 'No Balance'
                  END
                     STATUS,
                  SUM (INCOME) - SUM (EXPENSE) AMOUNT
             FROM (SELECT RPT_BRN_CODE,
                          CASE
                             WHEN RPTHEAD_CLASSIFICATION = 'I'
                             THEN
                                RPT_HEAD_BAL
                             ELSE
                                0
                          END
                             INCOME,
                          CASE
                             WHEN RPTHEAD_CLASSIFICATION = 'E'
                             THEN
                                RPT_HEAD_BAL
                             ELSE
                                0
                          END
                             EXPENSE
                     FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                                    'F42',
                                    IDX.BRANCH_CODE,
                                    P_ASON_DATE,
                                    1)))
         GROUP BY RPT_BRN_CODE;

      COMMIT;
   END LOOP;


   DELETE FROM OPEN_ACCOUNT_DATA;

   COMMIT;

   INSERT INTO OPEN_ACCOUNT_DATA
        SELECT ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE,
               COUNT (*),
               SUM (TRANSACTION_AMOUNT),
               P_ASON_DATE
          FROM (SELECT ACNTS_INTERNAL_ACNUM,
                       ACNTS_BRN_CODE,
                       PO_BRANCH,
                       GMO_BRANCH,
                       PARENT_BRANCH,
                       ACNTS_PROD_CODE,
                       ACNTS_AC_TYPE,
                       ACNTS_OPENING_DATE,
                       PROD_TYPE,
                       --DUMMY_TRAN_AMOUNT,
                       SUBSTR (DUMMY_TRAN_AMOUNT, 1, 1) TRANSACTION_TYPE,
                       TO_NUMBER (
                          SUBSTR (DUMMY_TRAN_AMOUNT,
                                  3,
                                  LENGTH (DUMMY_TRAN_AMOUNT) - 2))
                          TRANSACTION_AMOUNT
                  FROM (SELECT ACNTS_INTERNAL_ACNUM,
                               ACNTS_BRN_CODE,
                               PO_BRANCH,
                               GMO_BRANCH,
                               PARENT_BRANCH,
                               ACNTS_PROD_CODE,
                               ACNTS_AC_TYPE,
                               ACNTS_OPENING_DATE,
                               PROD_TYPE,
                               (SELECT TRAN_DB_CR_FLG || '@' || TRAN_AMOUNT
                                  FROM TRAN2022 T4
                                 WHERE     T4.TRAN_ENTITY_NUM = 1
                                       AND T4.TRAN_INTERNAL_ACNUM =
                                              ACNTS_INTERNAL_ACNUM
                                       AND T4.TRAN_AUTH_BY IS NOT NULL
                                       AND (T4.TRAN_DATE_OF_TRAN,
                                            T4.TRAN_BATCH_NUMBER,
                                            T4.TRAN_BATCH_SL_NUM,
                                            T4.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                           T3.TRAN_DATE_OF_TRAN),
                                                                        MIN (
                                                                           T3.TRAN_BATCH_NUMBER),
                                                                        MIN (
                                                                           T3.TRAN_BATCH_SL_NUM),
                                                                        MIN (
                                                                           T3.TRAN_AUTH_ON)
                                                                   FROM TRAN2022 T3
                                                                  WHERE     T3.TRAN_ENTITY_NUM =
                                                                               1
                                                                        AND T3.TRAN_INTERNAL_ACNUM =
                                                                               ACNTS_INTERNAL_ACNUM
                                                                        AND T3.TRAN_AUTH_BY
                                                                               IS NOT NULL
                                                                        AND (T3.TRAN_DATE_OF_TRAN,
                                                                             T3.TRAN_BATCH_NUMBER,
                                                                             T3.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                                                            T2.TRAN_DATE_OF_TRAN),
                                                                                                         MIN (
                                                                                                            T2.TRAN_BATCH_NUMBER),
                                                                                                         MIN (
                                                                                                            T2.TRAN_AUTH_ON)
                                                                                                    FROM TRAN2022 T2
                                                                                                   WHERE     T2.TRAN_ENTITY_NUM =
                                                                                                                1
                                                                                                         AND T2.TRAN_INTERNAL_ACNUM =
                                                                                                                ACNTS_INTERNAL_ACNUM
                                                                                                         AND T2.TRAN_AUTH_BY
                                                                                                                IS NOT NULL
                                                                                                         AND (T2.TRAN_DATE_OF_TRAN,
                                                                                                              T2.TRAN_AUTH_ON) IN (SELECT MIN (
                                                                                                                                             T1.TRAN_DATE_OF_TRAN),
                                                                                                                                          MIN (
                                                                                                                                             T1.TRAN_AUTH_ON)
                                                                                                                                     FROM TRAN2022 T1
                                                                                                                                    WHERE     T1.TRAN_ENTITY_NUM =
                                                                                                                                                 1
                                                                                                                                          AND T1.TRAN_INTERNAL_ACNUM =
                                                                                                                                                 ACNTS_INTERNAL_ACNUM
                                                                                                                                          AND T1.TRAN_AUTH_BY
                                                                                                                                                 IS NOT NULL))))
                                  DUMMY_TRAN_AMOUNT
                          FROM ACNTS,
                               MBRN_TREE1,
                               (SELECT CASE
                                          WHEN PRODUCT_FOR_LOANS = 1
                                          THEN
                                             'LOAN'
                                          WHEN PRODUCT_FOR_DEPOSITS = 1
                                          THEN
                                             CASE
                                                WHEN PRODUCT_FOR_RUN_ACS = 1
                                                THEN
                                                   'SAVING/CURRENT'
                                                ELSE
                                                   CASE
                                                      WHEN PRODUCT_CONTRACT_ALLOWED =
                                                              1
                                                      THEN
                                                         'FD'
                                                      ELSE
                                                         'RD'
                                                   END
                                             END
                                          ELSE
                                             'OTHERS'
                                       END
                                          PROD_TYPE,
                                       PRODUCT_CODE
                                  FROM PRODUCTS) PROD_CODE_TYPE
                         WHERE     ACNTS_ENTITY_NUM = 1
                               AND PROD_CODE_TYPE.PRODUCT_CODE =
                                      ACNTS_PROD_CODE
                               AND ACNTS_OPENING_DATE = P_ASON_DATE
                               AND BRANCH = ACNTS_BRN_CODE --AND ACNTS_BRN_CODE = :P_BRN_CODE
                                                          ))
      GROUP BY ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE
      ORDER BY ACNTS_BRN_CODE,
               PO_BRANCH,
               GMO_BRANCH,
               PARENT_BRANCH,
               PROD_TYPE,
               TRANSACTION_TYPE;


   COMMIT;

   DELETE FROM BRNWISE_PROFIT_LOSS
         WHERE BRCODE IN (SELECT DISTINCT MBRN_PARENT_ADMIN_CODE
                            FROM MBRN
                           WHERE MBRN_PARENT_ADMIN_CODE <> 0);

   COMMIT;

   INSERT INTO F12_HEADWISE
        SELECT F12_CODE,
               SUM (AMOUNT) AMOUNT,
               SUM (NO_OF_AC) NO_OF_AC,
               REPORT_DATE
          FROM F12_HEADWISE_TEMP
      GROUP BY F12_CODE, REPORT_DATE;

   COMMIT;

   INSERT INTO F42_HEADWISE
        SELECT F42_CODE, SUM (AMOUNT) AMOUNT, REPORT_DATE
          FROM F42_HEADWISE_TEMP
      GROUP BY F42_CODE, REPORT_DATE;

   COMMIT;

   DELETE FROM FOREIGN_REMIT;

   COMMIT;

   INSERT INTO FOREIGN_REMIT
        SELECT REMCSP_BRN_CODE,
               P_ASON_DATE,
               SUM (TO_NUMBER (REMCSP_TRAN_AMOUNT)) AMOUNT,
               COUNT (*) NO_OF_TRAN
          FROM REMCASHPAY
         WHERE     REMCSP_ENTITY_NUM = 1
               AND REMCSP_TRAN_DATE = P_ASON_DATE
               AND REMCSP_AUTH_BY IS NOT NULL
      GROUP BY REMCSP_BRN_CODE
      ORDER BY 1;

   COMMIT;

   DELETE FROM F12_BRANCHWISE;

   COMMIT;

   DELETE FROM F42_BRANCHWISE;

   COMMIT;

   INSERT INTO F12_BRANCHWISE
      SELECT F12_CODE,
             AMOUNT,
             NO_OF_AC,
             BRANCH_CODE,
             REPORT_DATE
        FROM F12_HEADWISE_TEMP;

   COMMIT;

   INSERT INTO F42_BRANCHWISE
      SELECT F42_CODE,
             AMOUNT,
             BRANCH_CODE,
             REPORT_DATE
        FROM F42_HEADWISE_TEMP;

   COMMIT;

   DELETE FROM F12_HEADWISE_TEMP;

   COMMIT;

   DELETE FROM F42_HEADWISE_TEMP;

   COMMIT;

   DELETE FROM TF_DATA;

   COMMIT;

   INSERT INTO TF_DATA
        SELECT TENOR_TYPE,
               MATURITY_DATE,
               CURRENCY,
               SUM (NVL (FC_AMOUNT, 0)) FC_AMOUNT,
               OLC_BRN_CODE,
               P_ASON_DATE
          FROM (  SELECT OLC_BRN_CODE,
                         DECODE (OT.OLCT_TENOR_TYPE,
                                 'S', 'Sight',
                                 'U', 'Usance',
                                 OT.OLCT_TENOR_TYPE)
                            TENOR_TYPE,
                         CASE
                            WHEN OT.OLCT_TENOR_TYPE = 'S'
                            THEN
                               O.OLC_LAST_DATE_OF_NEG
                            ELSE
                               IBA.IBACC_ACC_DUE_DATE
                         END
                            MATURITY_DATE,
                         CASE
                            WHEN OT.OLCT_TENOR_TYPE = 'S' THEN OLC_LC_CURR_CODE
                            ELSE IB.IBILL_BILL_CURR
                         END
                            CURRENCY,
                         CASE
                            WHEN OT.OLCT_TENOR_TYPE = 'S'
                            THEN
                                 SUM (OLC_LC_AMOUNT)
                               + NVL (
                                    SUM (
                                       DECODE (
                                          OLCA_ENHANCEMNT_REDUCN,
                                          'E', OA.OLCA_EN_RED_AMT_WITHOUT_DEV,
                                          -OA.OLCA_EN_RED_AMT_WITHOUT_DEV)),
                                    0)
                            ELSE
                               NVL (SUM (IB.IBILL_BILL_AMOUNT), 0)
                         END
                            FC_AMOUNT
                    FROM OLC O
                         INNER JOIN OLCTENORS OT
                            ON (    O.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM
                                AND O.OLC_BRN_CODE = OT.OLCT_BRN_CODE
                                AND O.OLC_LC_TYPE = OT.OLCT_LC_TYPE
                                AND O.OLC_LC_YEAR = OT.OLCT_LC_YEAR
                                AND O.OLC_LC_SL = OT.OLCT_LC_SL)
                         LEFT JOIN OLCAMD OA
                            ON (    O.OLC_ENTITY_NUM = OA.OLCA_ENTITY_NUM
                                AND O.OLC_BRN_CODE = OA.OLCA_BRN_CODE
                                AND O.OLC_LC_TYPE = OA.OLCA_LC_TYPE
                                AND O.OLC_LC_YEAR = OA.OLCA_LC_YEAR
                                AND O.OLC_LC_SL = OA.OLCA_LC_SL
                                AND OA.OLCA_AUTH_BY IS NOT NULL)
                         LEFT JOIN IBILL IB
                            ON (    OLC_ENTITY_NUM = IB.IBILL_ENTITY_NUM
                                AND OLC_BRN_CODE = IB.IBILL_BRN_CODE
                                AND OLC_LC_TYPE = IB.IBILL_OLC_TYPE
                                AND OLC_LC_YEAR = IB.IBILL_OLC_YEAR
                                AND OLC_LC_SL = IB.IBILL_OLC_SL
                                AND IB.IBILL_AUTH_BY IS NOT NULL)
                         LEFT JOIN IBILLACC IBA
                            ON (    IB.IBILL_ENTITY_NUM = IBA.IBACC_ENTITY_NUM
                                AND IB.IBILL_BRN_CODE = IBA.IBACC_BRN_CODE
                                AND IB.IBILL_BILL_TYPE = IBA.IBACC_BILL_TYPE
                                AND IB.IBILL_BILL_YEAR = IBA.IBACC_BILL_YEAR
                                AND IB.IBILL_BILL_SL = IBA.IBACC_BILL_SL
                                AND IBA.IBACC_AUTH_BY IS NOT NULL)
                   WHERE     OLC_ENTITY_NUM = 1
                         AND O.OLC_AUTH_ON IS NOT NULL
                         AND (O.OLC_ENTITY_NUM,
                              O.OLC_BRN_CODE,
                              O.OLC_LC_TYPE,
                              O.OLC_LC_YEAR,
                              O.OLC_LC_SL) NOT IN (SELECT OLCCN_ENTITY_NUM,
                                                          OLCCN_BRN_CODE,
                                                          OLCCN_LC_TYPE,
                                                          OLCCN_LC_YEAR,
                                                          OLCCN_LC_SL
                                                     FROM OLCCAN
                                                    WHERE OLCCN_AUTH_ON
                                                             IS NOT NULL)
                GROUP BY OT.OLCT_TENOR_TYPE,
                         O.OLC_LAST_DATE_OF_NEG,
                         IBACC_ACC_DUE_DATE,
                         OLC_LC_CURR_CODE,
                         IBILL_BILL_CURR,
                         OLC_BRN_CODE)
         WHERE     CURRENCY IS NOT NULL
               AND MATURITY_DATE BETWEEN P_ASON_DATE + 1 AND P_ASON_DATE + 31
      GROUP BY TENOR_TYPE,
               MATURITY_DATE,
               CURRENCY,
               OLC_BRN_CODE
      ORDER BY OLC_BRN_CODE,
               TENOR_TYPE,
               MATURITY_DATE,
               CURRENCY;


   COMMIT;

   IF LAST_DAY (P_ASON_DATE - 1) = P_ASON_DATE - 1
   THEN
      ---------- Monthly data


      DELETE FROM F12_BACK_PAGE;

      COMMIT;

      DELETE FROM WRITE_OFF_DATA;

      COMMIT;

      DELETE FROM RECOVERY_DETAIL;

      COMMIT;

      INSERT INTO F12_BACK_PAGE
           SELECT ACNTS_BRN_CODE,
                  RPTHDGLDTL_CODE,
                  SUM (ACNTBBAL_BC_OPNG_CR_SUM - ACNTBBAL_BC_OPNG_DB_SUM)
                     BALANCE,
                  COUNT (*) NO_OF_AC,
                  P_ASON_DATE REPORT_DATE,
                  ACNTS_PROD_CODE,
                  ACNTS_AC_TYPE,
                  ACNTS_AC_SUB_TYPE
             FROM ACNTS, ACNTBBAL, GLWISE_AMOUNT
            WHERE     ACNTS_ENTITY_NUM = 1
                  AND ACNTS_PROD_CODE IN (1000,
                                          1020,
                                          1030,
                                          1040,
                                          1060)
                  AND (   ACNTS_CLOSURE_DATE IS NULL
                       OR ACNTS_CLOSURE_DATE > P_ASON_DATE)
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_INTERNAL_ACNUM = ACNTBBAL_INTERNAL_ACNUM
                  AND RPTHDGLDTL_ACNT_NO = ACNTBBAL_INTERNAL_ACNUM
                  AND RPTDATE = P_ASON_DATE
                  AND ACNTBBAL_ENTITY_NUM = 1
                  AND ACNTBBAL_YEAR =
                         TO_NUMBER (TO_CHAR (P_ASON_DATE + 1, 'YYYY'))
                  AND ACNTBBAL_MONTH =
                         TO_NUMBER (TO_CHAR (P_ASON_DATE + 1, 'MM'))
         GROUP BY ACNTS_BRN_CODE,
                  RPTHDGLDTL_CODE,
                  ACNTS_PROD_CODE,
                  ACNTS_AC_TYPE,
                  ACNTS_AC_SUB_TYPE;

      COMMIT;

      INSERT INTO WRITE_OFF_DATA
         SELECT TEMP_DATA.ACNTS_BRN_CODE BRCODE,
                TEMP_DATA.ACCOUNT_NUMBER ACNO,
                TEMP_DATA.ACNTS_AC_NAME1 ACNAME,
                TEMP_DATA.ADDRESS ADDRESS,
                TEMP_DATA.SANCTION_DATE SANC_DT,
                TEMP_DATA.SANCTION_AMOUNT SANC_AMT,
                NULL COLLATERAL_SECDESC,
                NULL COLLATERAL_SECVALUE,
                TEMP_DATA.LNWRTOFF_SANC_BY APP_AUTHORITY,
                TEMP_DATA.LNWRTOFF_WRTOFF_DATE WRTOFF_DATE,
                TEMP_DATA.PRI_OS PRINCIPAL_AMT,
                TEMP_DATA.INT_OS INTEREST_AMT,
                TEMP_DATA.CHG_OS OTHERS_AMT_CHARGES,
                NULL SUIT_REFNO,
                NULL SUIT_NUMBER,
                TEMP_DATA.NID NID,
                TEMP_DATA.SECTORCODE SECTORCODE,
                TEMP_DATA.REMARKS REMARKS,
                NULL APP_DT,
                TEMP_DATA.ACNTS_PROD_CODE PRODUCT_CODE,
                TEMP_DATA.ACNTS_AC_TYPE ACTYPE_CODE,
                TEMP_DATA.ACNTS_AC_SUB_TYPE ACSUBTYPE_CODE,
                NULL BLOCKAMT
           FROM (SELECT A.ACNTS_BRN_CODE,
                        IACLINK_ACTUAL_ACNUM ACCOUNT_NUMBER,
                        A.ACNTS_AC_NAME1,
                           ACNTS_AC_ADDR1
                        || ACNTS_AC_ADDR2
                        || ACNTS_AC_ADDR3
                        || ACNTS_AC_ADDR4
                        || ACNTS_AC_ADDR5
                           ADDRESS,
                        A.ACNTS_PROD_CODE,
                        A.ACNTS_AC_TYPE,
                        A.ACNTS_AC_SUB_TYPE,
                        LNWRTOFF_WRTOFF_DATE,
                        NVL (TRIM (R.LNWRTOFF_SANC_BY), '01')
                           LNWRTOFF_SANC_BY,
                        (SELECT LMTLINE_DATE_OF_SANCTION
                           FROM ACASLLDTL, LIMITLINE
                          WHERE     ACASLLDTL_ENTITY_NUM = 1
                                AND ACASLLDTL_CLIENT_NUM =
                                       LMTLINE_CLIENT_CODE
                                AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                                AND ACASLLDTL_INTERNAL_ACNUM =
                                       A.ACNTS_INTERNAL_ACNUM
                                AND LMTLINE_ENTITY_NUM = 1)
                           SANCTION_DATE,
                        (SELECT LMTLINE_SANCTION_AMT
                           FROM ACASLLDTL, LIMITLINE
                          WHERE     ACASLLDTL_ENTITY_NUM = 1
                                AND ACASLLDTL_CLIENT_NUM =
                                       LMTLINE_CLIENT_CODE
                                AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                                AND ACASLLDTL_INTERNAL_ACNUM =
                                       A.ACNTS_INTERNAL_ACNUM
                                AND LMTLINE_ENTITY_NUM = 1)
                           SANCTION_AMOUNT,
                        NVL (
                           (SELECT SUM (TRANSTL_AMT_BY_CASH)
                              FROM LNWRTOFFRECOV, TRANSTLMNT
                             WHERE     LNWRTOFFREC_ENTITY_NUM = 1
                                   AND A.ACNTS_INTERNAL_ACNUM =
                                          LNWRTOFFREC_LN_ACNUM
                                   AND LNWRTOFFREC_AUTH_BY IS NOT NULL
                                   AND TRANSTL_INV_NUM =
                                          LNWRTOFFREC_TRANSTLMNT_INV_NUM
                                   --AND LNWRTOFFREC_ENTRY_DATE > '31-DEC-2017'
                                   AND LNWRTOFFREC_ENTRY_DATE <= P_ASON_DATE),
                           0)
                           TOTAL_CASH_RECOVERY,
                          NVL (R.LNWRTOFF_PRIN_WRTOFF_AMT, 0)
                        - NVL (
                             (SELECT SUM (LNWRTOFFREC_PRIN)
                                FROM LNWRTOFFRECOV
                               WHERE     LNWRTOFFREC_ENTITY_NUM = 1
                                     AND A.ACNTS_INTERNAL_ACNUM =
                                            LNWRTOFFREC_LN_ACNUM
                                     AND LNWRTOFFREC_AUTH_BY IS NOT NULL
                                     AND LNWRTOFFREC_ENTRY_DATE <=
                                            P_ASON_DATE),
                             0)
                           AS PRI_OS,
                        NVL (
                             NVL (R.LNWRTOFF_INT_WRTOFF_AMT, 0)
                           - NVL (
                                (SELECT SUM (LNWRTOFFREC_INT_ACCR)
                                   FROM LNWRTOFFRECOV
                                  WHERE     LNWRTOFFREC_ENTITY_NUM = 1
                                        AND A.ACNTS_INTERNAL_ACNUM =
                                               LNWRTOFFREC_LN_ACNUM
                                        AND LNWRTOFFREC_AUTH_BY IS NOT NULL
                                        AND LNWRTOFFREC_ENTRY_DATE <=
                                               P_ASON_DATE),
                                0),
                           0)
                           AS INT_OS,
                        NVL (
                             NVL (LNWRTOFF_CHG_WRTOFF_AMT, 0)
                           - NVL (
                                (SELECT SUM (LNWRTOFFREC_PENAL_INT_ACCR)
                                   FROM LNWRTOFFRECOV
                                  WHERE     LNWRTOFFREC_ENTITY_NUM = 1
                                        AND A.ACNTS_INTERNAL_ACNUM =
                                               LNWRTOFFREC_LN_ACNUM
                                        AND LNWRTOFFREC_AUTH_BY IS NOT NULL
                                        AND LNWRTOFFREC_ENTRY_DATE <=
                                               P_ASON_DATE),
                                0),
                           0)
                           AS CHG_OS,
                           LNWRTOFF_REMARKS1
                        || LNWRTOFF_REMARKS2
                        || LNWRTOFF_REMARKS3
                           REMARKS,
                        (SELECT PIDDOCS_DOCID_NUM
                           FROM PIDDOCS
                          WHERE     PIDDOCS_SOURCE_KEY =
                                       TO_CHAR (ACNTS_CLIENT_NUM)
                                AND PIDDOCS_PID_TYPE = 'NID'
                                AND PIDDOCS_DOC_SL =
                                       (SELECT MIN (PIDDOCS_DOC_SL)
                                          FROM PIDDOCS
                                         WHERE     PIDDOCS_SOURCE_KEY =
                                                      TO_CHAR (
                                                         ACNTS_CLIENT_NUM)
                                               AND PIDDOCS_PID_TYPE = 'NID'))
                           NID,
                        (SELECT CLIENTS_SEGMENT_CODE
                           FROM CLIENTS
                          WHERE CLIENTS_CODE = ACNTS_CLIENT_NUM)
                           SECTORCODE
                   FROM ACNTS A, LNWRTOFF R, IACLINK
                  WHERE     A.ACNTS_ENTITY_NUM = 1
                        AND LNWRTOFF_ENTITY_NUM = 1
                        AND R.LNWRTOFF_AUTH_BY IS NOT NULL
                        AND IACLINK_ENTITY_NUM = 1
                        AND IACLINK_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                        --AND A.ACNTS_BRN_CODE = 34
                        AND A.ACNTS_INTERNAL_ACNUM = R.LNWRTOFF_ACNT_NUM)
                TEMP_DATA
         UNION ALL
         SELECT GLBALH_BRN_CODE BRCODE,
                GLBALH_GLACC_CODE,
                EXTGL_EXT_HEAD_DESCN,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                GLBALH_BC_BAL PRINCIPAL_AMT,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
           FROM GLBALASONHIST GB, EXTGL
          WHERE     GLBALH_ENTITY_NUM = 1
                AND GLBALH_GLACC_CODE = '516101102'
                AND GLBALH_ASON_DATE = P_ASON_DATE
                AND GLBALH_BC_BAL <> 0
                --AND GLBALH_BRN_CODE = 34
                AND EXTGL_ACCESS_CODE = GLBALH_GLACC_CODE
         ORDER BY 1;

      COMMIT;

      INSERT INTO RECOVERY_DETAIL
         SELECT ACNTS_BRN_CODE BRANCH_CODE,
                IACLINK_ACTUAL_ACNUM ACCOUNT_NUMBER,
                LNWRTOFFREC_ENTRY_DATE RECOVERY_DATE,
                LNWRTOFFREC_PRIN PRINCIPLE_RECOVERY,
                LNWRTOFFREC_INT_ACCR INTEREST_RECOVERY,
                LNWRTOFFREC_PENAL_INT_ACCR OTHER_RECOVERY,
                  LNWRTOFFREC_PRIN
                + LNWRTOFFREC_INT_ACCR
                + LNWRTOFFREC_PENAL_INT_ACCR
                   TOTAL_RECOVERY
           FROM ACNTS,
                LNWRTOFF,
                LNWRTOFFRECOV,
                IACLINK
          WHERE     ACNTS_ENTITY_NUM = 1
                AND ACNTS_INTERNAL_ACNUM = LNWRTOFF_ACNT_NUM
                AND LNWRTOFF_ENTITY_NUM = 1
                AND LNWRTOFF_ACNT_NUM = LNWRTOFFREC_LN_ACNUM
                AND LNWRTOFFREC_ENTITY_NUM = 1
                AND TO_CHAR (LNWRTOFFREC_ENTRY_DATE, 'MM-YYYY') =
                       TO_CHAR (P_ASON_DATE, 'MM-YYYY')
                AND LNWRTOFFREC_ENTRY_DATE <= P_ASON_DATE
                AND IACLINK_ENTITY_NUM = 1
                AND IACLINK_INTERNAL_ACNUM = LNWRTOFF_ACNT_NUM
                AND LNWRTOFFREC_AUTH_BY IS NOT NULL;

      COMMIT;
   END IF;

  <<TF_DASHBOARD_DATA>>
   BEGIN
 W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_1';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_2';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_3';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_4';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_5';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_6';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_7';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_8';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_9';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_10';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_11';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_12';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_13';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE TF_DESHBOARD_DATA_19';

   EXECUTE IMMEDIATE W_SQL;

      COMMIT;

      INSERT INTO TF_DESHBOARD_DATA_1
         SELECT * FROM DASHBOARD_1;

      INSERT INTO TF_DESHBOARD_DATA_2
         SELECT * FROM DASHBOARD_2;

      INSERT INTO TF_DESHBOARD_DATA_3
         SELECT * FROM DASHBOARD_3;

      INSERT INTO TF_DESHBOARD_DATA_4
         SELECT * FROM DASHBOARD_4;

      INSERT INTO TF_DESHBOARD_DATA_5
         SELECT * FROM DASHBOARD_5;

      INSERT INTO TF_DESHBOARD_DATA_6
         SELECT * FROM DASHBOARD_6;

      INSERT INTO TF_DESHBOARD_DATA_7
         SELECT * FROM DASHBOARD_7;

      INSERT INTO TF_DESHBOARD_DATA_8
         SELECT * FROM DASHBOARD_8;

      INSERT INTO TF_DESHBOARD_DATA_9
         SELECT * FROM DASHBOARD_9;
         
      INSERT INTO TF_DESHBOARD_DATA_10
         SELECT * FROM DASHBOARD_10;

      INSERT INTO TF_DESHBOARD_DATA_11
         SELECT * FROM DASHBOARD_11;

      INSERT INTO TF_DESHBOARD_DATA_12
         SELECT * FROM DASHBOARD_12;

      INSERT INTO TF_DESHBOARD_DATA_13
         SELECT * FROM DASHBOARD_13;

      INSERT INTO TF_DESHBOARD_DATA_19
         SELECT * FROM DASHBOARD_19;
         commit;
   END;

   COMMIT;
END;
/

GRANT EXECUTE ON SP_DAILY_DATA_MRS_GEN TO SYSTEM;
