CREATE OR REPLACE PROCEDURE SP_DAILY_DATA_MRS_GEN (P_ASON_DATE DATE)
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
BEGIN
   SELECT COUNT (DISTINCT RPT_BRN_CODE)
     INTO V_NO_OF_BRN
     FROM STATMENTOFAFFAIRS
    WHERE RPT_ENTRY_DATE = P_ASON_DATE;

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

   INSERT INTO F12_HEADWISE
        SELECT RPT_HEAD_CODE,
               SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
               SUM (NUM_OF_ACCOUNT) HEAD_NUMBER_OF_ACCOUNT,
               RPT_ENTRY_DATE
          FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                         'F12',
                         0,
                         P_ASON_DATE,
                         1))
      GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE;



   DELETE FROM F42_HEADWISE;

   INSERT INTO F42_HEADWISE
        SELECT RPT_HEAD_CODE,
               SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
               RPT_ENTRY_DATE
          FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                         'F42',
                         0,
                         P_ASON_DATE,
                         1))
      GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE;

   DELETE FROM FOREIGN_REMIT;

   INSERT INTO FOREIGN_REMIT
        SELECT POST_TRAN_BRN,
               P_ASON_DATE,
               SUM (TO_NUMBER (REMCSP_TRAN_AMOUNT)) AMOUNT,
               COUNT (*) NO_OF_TRAN
          FROM REMCASHPAY
         WHERE     REMCSP_ENTITY_NUM = 1
               AND REMCSP_TRAN_DATE = P_ASON_DATE
               AND REMCSP_AUTH_BY IS NOT NULL
      GROUP BY POST_TRAN_BRN
      ORDER BY 1;

   IF TRIM (V_WEEK_DAY) = 'SUNDAY'
   THEN
      --------- Weekly data
      --------- Mobile number
      BEGIN
         SELECT COUNT (CLIENTS_CODE) INTO V_TOTAL_CLIENTS FROM CLIENTS;

         SELECT COUNT (ADDRDTLS_MOBILE_NUM)
           INTO V_INVALID_MOBILE
           FROM ADDRDTLS, CLIENTS
          WHERE     (   NOT REGEXP_LIKE ( (ADDRDTLS_MOBILE_NUM), '^[0-9]+$')
                     OR ADDRDTLS_MOBILE_NUM IS NULL)
                AND LENGTH (ADDRDTLS_MOBILE_NUM) < 11
                AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM;


         SELECT COUNT (DISTINCT CLIENT_NUM)
           INTO V_TOTAL_REGI_CLIENTS
           FROM MOBILEREG
          WHERE ACTIVE = '0';


         SELECT COUNT (ADDRDTLS_MOBILE_NUM)
           INTO V_VALID_MOBILE
           FROM (SELECT (ADDRDTLS_MOBILE_NUM)
                   FROM ADDRDTLS, CLIENTS
                  WHERE     ADDRDTLS_MOBILE_NUM IS NOT NULL
                        AND REGEXP_LIKE (TRIM (ADDRDTLS_MOBILE_NUM),
                                         '^[[:digit:]]+$')
                        AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM)
          WHERE LENGTH (ADDRDTLS_MOBILE_NUM) = 11;


         SELECT COUNT (CLIENTS_CODE)
           INTO V_VALID_MOB_NOT_REGI
           FROM (SELECT CLIENTS_CODE, (ADDRDTLS_MOBILE_NUM)
                   FROM ADDRDTLS, CLIENTS
                  WHERE     ADDRDTLS_MOBILE_NUM IS NOT NULL
                        AND REGEXP_LIKE (TRIM (ADDRDTLS_MOBILE_NUM),
                                         '^[[:digit:]]+$'))
          WHERE     LENGTH (ADDRDTLS_MOBILE_NUM) = 11
                AND CLIENTS_CODE NOT IN (SELECT CLIENT_NUM
                                           FROM MOBILEREG
                                          WHERE ACTIVE = '0');

         DELETE FROM MOBILE_INFO;

         INSERT INTO MOBILE_INFO (TOTAL_CLIENTS,
                                  INVALID_MOBILE,
                                  TOTAL_REGI_CLIENTS,
                                  VALID_MOBILE,
                                  VALID_MOB_NOT_REGI)
              VALUES (V_TOTAL_CLIENTS,
                      V_INVALID_MOBILE,
                      V_TOTAL_REGI_CLIENTS,
                      V_VALID_MOBILE,
                      V_VALID_MOB_NOT_REGI);
      END;
   END IF;


   IF LAST_DAY (P_ASON_DATE) = P_ASON_DATE
   THEN
      ---------- Monthly data
      DELETE FROM F12_BRANCHWISE;

      DELETE FROM F42_BRANCHWISE;

      DELETE FROM F12_BACK_PAGE;

      INSERT INTO F12_BRANCHWISE
           SELECT RPT_HEAD_CODE,
                  SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
                  SUM (NUM_OF_ACCOUNT) HEAD_NUMBER_OF_ACCOUNT,
                  RPT_BRN_CODE,
                  RPT_ENTRY_DATE
             FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                            'F12',
                            0,
                            P_ASON_DATE,
                            1))
         GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE, RPT_BRN_CODE;


      INSERT INTO F42_BRANCHWISE
           SELECT RPT_HEAD_CODE,
                  SUM (NVL (RPT_HEAD_BAL, 0)) HEAD_BALANCE,
                  RPT_BRN_CODE,
                  RPT_ENTRY_DATE
             FROM TABLE (PKG_F12_F42_HEAD_WISE_DATA.SP_F12_F42_HEADDATA (
                            'F42',
                            0,
                            P_ASON_DATE,
                            1))
         GROUP BY RPT_HEAD_CODE, RPT_ENTRY_DATE, RPT_BRN_CODE;

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
                  AND ACNTS_PROD_CODE IN (1000, 1020, 1030, 1040, 1060)
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
                        AND A.ACNTS_INTERNAL_ACNUM = R.LNWRTOFF_ACNT_NUM) TEMP_DATA
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
   END IF;

   COMMIT;
END;
/
