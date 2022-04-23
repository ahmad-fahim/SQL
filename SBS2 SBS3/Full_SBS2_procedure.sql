---------------------- SP_SBS2_DATA_QUERY ------------------
--- This is the main query generator -----------------------

CREATE OR REPLACE PROCEDURE SP_SBS2_DATA_QUERY(P_BRN_CODE NUMBER, P_FROM_DATE DATE , P_UPTO_DATE DATE ,P_DATA OUT CLOB)
IS 
V_DATA CLOB;
V_FIN_YEAR NUMBER ;
BEGIN
V_FIN_YEAR := TO_CHAR(P_FROM_DATE, 'YYYY');
V_DATA := 'SELECT    TOTAL_DATA
             || TRIM (
                   TO_CHAR (NVL (DEBIT_SUM, 0), ''0000000000000000000000.00''))
                SBS2T_DATA
        FROM (SELECT    TO_CHAR (:P_TO_DATE, ''DDMMYYYY'')
                     || SUBSTR (MBRN_BSR_CODE, 3)
                     || CASE
                           WHEN LENGTH (IACLINK_ACTUAL_ACNUM) > 12
                           THEN
                              SUBSTR (IACLINK_ACTUAL_ACNUM, -12, 12)
                           ELSE
                              LPAD (IACLINK_ACTUAL_ACNUM, 12, ''0'')
                        END
                     || RPAD (
                           NVL (
                              TRIM (
                                 REGEXP_REPLACE (
                                    ACNTS_AC_NAME1 || ACNTS_AC_NAME2,
                                    ''[^[:print:]]'',
                                    '' '')),
                              '' ''),
                           100,
                           '' '')
                     || RPAD (
                           NVL (
                              NVL (
                                 (SELECT OCCUPATIONS_DESCN
                                    FROM OCCUPATIONS, INDCLIENTS
                                   WHERE     OCCUPATIONS_CODE =
                                                INDCLIENT_OCCUPN_CODE
                                         AND INDCLIENT_CODE = CLIENTS_CODE),
                                 '' ''),
                              '' ''),
                           50,
                           '' '')
                     || RPAD (NVL (CLIENTS_SEGMENT_CODE, '' ''), 6, ''0'')
                     || RPAD (NVL (PRODUCT_NAME, '' ''), 100, '' '')
                     || LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), ''0''), 3, ''0'')
                     || TRIM (
                           TO_CHAR (
                              NVL (
                                 (CASE
                                     WHEN (SELECT NVL (
                                                     PG.PWGENPARAM_SND_PROD,
                                                     ''0'')
                                             FROM PWGENPARAM PG
                                            WHERE PG.PWGENPARAM_PROD_CODE =
                                                     PRODUCT_CODE) = ''1''
                                     THEN
                                        FN_GET_SND_INT_RATE (
                                           ACNTS_ENTITY_NUM,
                                           ACNTS_BRN_CODE,
                                           ACNTS_INTERNAL_ACNUM,
                                           ''C'',        -- credit interest rate
                                           :P_TO_DATE)
                                     ELSE
                                        FN_GET_INTRATE_RUN_ACS_NEW (
                                           ACNTS_INTERNAL_ACNUM,
                                           PRODUCT_CODE,
                                           ACNTS_CURR_CODE,
                                           ACNTS_AC_TYPE,
                                           ACNTS_AC_SUB_TYPE,
                                           ''C'',        -- credit interest type
                                           :P_TO_DATE)
                                  END),
                                 0),
                              ''00.00''))
                     || LPAD (
                           NVL (
                              TO_CHAR (TO_DATE (ACNTS_OPENING_DATE),
                                       ''DDMMYYYY''),
                              '' ''),
                           8,
                           '' '')
                     || LPAD (
                           NVL (TO_CHAR (TO_DATE (NULL), ''DDMMYYYY''), '' ''),
                           8,
                           '' '')
                     || TRIM (
                     TO_CHAR (
                        (SELECT NVL (
                                     NVL (ACNTBBAL_AC_OPNG_CR_SUM, 0)
                                   - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                   0)
                           FROM ACNTBBAL
                          WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                AND ACNTBBAL_INTERNAL_ACNUM =
                                       ACNTS_INTERNAL_ACNUM
                                AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                AND ACNTBBAL_YEAR =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                AND ACNTBBAL_MONTH =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                        ''0000000000000000000000.00''))
                  TOTAL_DATA,
                       NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                          0)
                     - NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''MM''))),
                          0)
                        DEBIT_SUM
                FROM ACNTS,
                     IACLINK,
                     MBRN,
                     CLIENTS,
                     PRODUCTS,
                     ACTYPES
               WHERE     ACNTS_ENTITY_NUM = :V_ENTITY_NUM
                     AND IACLINK_ENTITY_NUM = :V_ENTITY_NUM
                     AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                     AND ACNTS_BRN_CODE = IACLINK_BRN_CODE
                     AND ACNTS_PROD_CODE = IACLINK_PROD_CODE
                     AND ACNTS_BRN_CODE = :P_BRANCH_CODE
                     AND ACNTS_BRN_CODE = MBRN_CODE
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND PRODUCT_FOR_DEPOSITS = ''1''
                     AND PRODUCT_FOR_RUN_ACS = ''1''
                     AND PRODUCT_CODE = IACLINK_PROD_CODE
                     AND ACTYPE_CODE = ACNTS_AC_TYPE)';
                     
V_DATA := V_DATA || 
        '
        UNION ALL
      SELECT    TOTAL_DATA
             || TRIM (
                   TO_CHAR (NVL (DEBIT_SUM, 0), ''0000000000000000000000.00''))
                SBS2T_DATA
        FROM (SELECT    TO_CHAR (:P_TO_DATE, ''DDMMYYYY'')
                     || SUBSTR (MBRN_BSR_CODE, 3)
                     || CASE
                           WHEN LENGTH (IACLINK_ACTUAL_ACNUM) > 12
                           THEN
                              SUBSTR (IACLINK_ACTUAL_ACNUM, -12, 12)
                           ELSE
                              LPAD (IACLINK_ACTUAL_ACNUM, 12, ''0'')
                        END
                     || RPAD (
                           NVL (
                              TRIM (
                                 REGEXP_REPLACE (
                                    ACNTS_AC_NAME1 || ACNTS_AC_NAME2,
                                    ''[^[:print:]]'',
                                    '' '')),
                              '' ''),
                           100,
                           '' '')
                     || RPAD (
                           NVL (
                              NVL (
                                 (SELECT OCCUPATIONS_DESCN
                                    FROM OCCUPATIONS, INDCLIENTS
                                   WHERE     OCCUPATIONS_CODE =
                                                INDCLIENT_OCCUPN_CODE
                                         AND INDCLIENT_CODE = CLIENTS_CODE),
                                 '' ''),
                              '' ''),
                           50,
                           '' '')
                     || RPAD (NVL (CLIENTS_SEGMENT_CODE, '' ''), 6, ''0'')
                     || RPAD (NVL (PRODUCT_NAME, '' ''), 100, '' '')
                     || LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), ''0''), 3, ''0'')
                     || TRIM (
                           TO_CHAR (NVL (PBDCONT_ACTUAL_INT_RATE, 0),
                                    ''00.00''))
                     || LPAD (
                           NVL (
                              TO_CHAR (TO_DATE (ACNTS_OPENING_DATE),
                                       ''DDMMYYYY''),
                              '' ''),
                           8,
                           '' '')
                     || LPAD (
                           NVL (
                              TO_CHAR (TO_DATE (PBDCONT_MAT_DATE),
                                       ''DDMMYYYY''),
                              '' ''),
                           8,
                           '' '')
                     || TRIM (
                     TO_CHAR (
                        (SELECT NVL (
                                     NVL (ACNTBBAL_AC_OPNG_CR_SUM, 0)
                                   - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                   0)
                           FROM ACNTBBAL
                          WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                AND ACNTBBAL_INTERNAL_ACNUM =
                                       ACNTS_INTERNAL_ACNUM
                                AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                AND ACNTBBAL_YEAR =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                AND ACNTBBAL_MONTH =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                        ''0000000000000000000000.00''))
                  TOTAL_DATA, -----
                       NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                          0)
                     - NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''MM''))),
                          0)
                        DEBIT_SUM
                FROM ACNTS,
                     IACLINK,
                     MBRN,
                     CLIENTS,
                     PRODUCTS,
                     ACTYPES,
                     PBDCONTRACT P
               WHERE     ACNTS_ENTITY_NUM = :V_ENTITY_NUM
                     AND IACLINK_ENTITY_NUM = :V_ENTITY_NUM
                     AND PBDCONT_ENTITY_NUM = :V_ENTITY_NUM
                     AND PBDCONT_DEP_AC_NUM = IACLINK_INTERNAL_ACNUM
                     AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                     AND ACNTS_BRN_CODE = IACLINK_BRN_CODE
                     AND ACNTS_PROD_CODE = IACLINK_PROD_CODE
                     AND ACNTS_BRN_CODE = :P_BRANCH_CODE
                     AND ACNTS_BRN_CODE = MBRN_CODE
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND PRODUCT_FOR_DEPOSITS = ''1''
                     AND PRODUCT_FOR_RUN_ACS = ''0''
                     AND PRODUCT_CODE = IACLINK_PROD_CODE
                     AND ACTYPE_CODE = ACNTS_AC_TYPE
                     AND PBDCONT_EFF_DATE <= :P_TO_DATE
                     AND PBDCONT_CONT_NUM = (SELECT MAX(PP.PBDCONT_CONT_NUM) FROM PBDCONTRACT PP WHERE PP.PBDCONT_ENTITY_NUM = P.PBDCONT_ENTITY_NUM
                     AND PP.PBDCONT_BRN_CODE = P.PBDCONT_BRN_CODE
                     AND PP.PBDCONT_DEP_AC_NUM = P.PBDCONT_DEP_AC_NUM AND PP.PBDCONT_EFF_DATE <= :P_TO_DATE)
                     AND TRIM (PBDCONT_AUTH_ON) IS NOT NULL
                     AND (   PBDCONT_CLOSURE_DATE IS NULL
                          OR PBDCONT_CLOSURE_DATE >= :P_TO_DATE))' ;
                          
                          
V_DATA := V_DATA || 
                '
                UNION ALL
      SELECT    TOTAL_DATA
             || TRIM (
                   TO_CHAR (NVL (DEBIT_SUM, 0), ''0000000000000000000000.00''))
                SBS2T_DATA
        FROM (SELECT    TO_CHAR (:P_TO_DATE, ''DDMMYYYY'')
                     || SUBSTR (MBRN_BSR_CODE, 3)
                     || CASE
                           WHEN LENGTH (IACLINK_ACTUAL_ACNUM) > 12
                           THEN
                              SUBSTR (IACLINK_ACTUAL_ACNUM, -12, 12)
                           ELSE
                              LPAD (IACLINK_ACTUAL_ACNUM, 12, ''0'')
                        END
                     || RPAD (
                           NVL (
                              TRIM (
                                 REGEXP_REPLACE (
                                    ACNTS_AC_NAME1 || ACNTS_AC_NAME2,
                                    ''[^[:print:]]'',
                                    '' '')),
                              '' ''),
                           100,
                           '' '')
                     || RPAD (
                           NVL (
                              NVL (
                                 (SELECT OCCUPATIONS_DESCN
                                    FROM OCCUPATIONS, INDCLIENTS
                                   WHERE     OCCUPATIONS_CODE =
                                                INDCLIENT_OCCUPN_CODE
                                         AND INDCLIENT_CODE = CLIENTS_CODE),
                                 '' ''),
                              '' ''),
                           50,
                           '' '')
                     || RPAD (NVL (CLIENTS_SEGMENT_CODE, '' ''), 6, ''0'')
                     || RPAD (NVL (PRODUCT_NAME, '' ''), 100, '' '')
                     || LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), ''0''), 3, ''0'')
                     || TRIM (
                           TO_CHAR (
                              NVL (
                                 (SELECT LNACIR_APPL_INT_RATE
                                    FROM LNACIR
                                   WHERE     LNACIR_ENTITY_NUM = 1
                                         AND LNACIR_INTERNAL_ACNUM =
                                                ACNTS_INTERNAL_ACNUM),
                                 0),
                              ''00.00''))
                     || LPAD (
                           NVL (
                              TO_CHAR (TO_DATE (ACNTS_OPENING_DATE),
                                       ''DDMMYYYY''),
                              '' ''),
                           8,
                           '' '')
                     || LPAD (
                           NVL (
                              TO_CHAR (
                                 (SELECT LMTLINE_LIMIT_EXPIRY_DATE
                                    FROM LIMITLINE, ACASLLDTL
                                   WHERE     ACASLLDTL_ENTITY_NUM =
                                                ACNTS_ENTITY_NUM
                                         AND LMTLINE_ENTITY_NUM =
                                                ACNTS_ENTITY_NUM
                                         AND ACASLLDTL_CLIENT_NUM =
                                                LMTLINE_CLIENT_CODE
                                         AND ACASLLDTL_LIMIT_LINE_NUM =
                                                LMTLINE_NUM
                                         AND ACASLLDTL_INTERNAL_ACNUM =
                                                ACNTS_INTERNAL_ACNUM),
                                 ''DDMMYYYY''),
                              '' ''),
                           8,
                           '' '')
                     || TRIM (
                     TO_CHAR (
                        (SELECT NVL (
                                     NVL (ACNTBBAL_AC_OPNG_CR_SUM, 0)
                                   - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                   0)
                           FROM ACNTBBAL
                          WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                AND ACNTBBAL_INTERNAL_ACNUM =
                                       ACNTS_INTERNAL_ACNUM
                                AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                AND ACNTBBAL_YEAR =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                AND ACNTBBAL_MONTH =
                                       TO_NUMBER (
                                          TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                        ''0000000000000000000000.00''))
                  TOTAL_DATA, -----
                       NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_TO_DATE + 1, ''MM''))),
                          0)
                     - NVL (
                          (SELECT NVL (ACNTBBAL_AC_OPNG_DB_SUM, 0)
                             FROM ACNTBBAL
                            WHERE     ACNTBBAL_ENTITY_NUM = ACNTS_ENTITY_NUM
                                  AND ACNTBBAL_INTERNAL_ACNUM =
                                         ACNTS_INTERNAL_ACNUM
                                  AND ACNTBBAL_CURR_CODE = ACNTS_CURR_CODE
                                  AND ACNTBBAL_YEAR =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''YYYY''))
                                  AND ACNTBBAL_MONTH =
                                         TO_NUMBER (
                                            TO_CHAR (:P_FROM_DATE, ''MM''))),
                          0)
                        DEBIT_SUM
                FROM ACNTS,
                     IACLINK,
                     MBRN,
                     CLIENTS,
                     PRODUCTS,
                     ACTYPES,
                     LOANACNTS
               WHERE     ACNTS_ENTITY_NUM = :V_ENTITY_NUM
                     AND IACLINK_ENTITY_NUM = :V_ENTITY_NUM
                     AND LNACNT_ENTITY_NUM = :V_ENTITY_NUM
                     AND LNACNT_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                     AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
                     AND ACNTS_BRN_CODE = IACLINK_BRN_CODE
                     AND ACNTS_PROD_CODE = IACLINK_PROD_CODE
                     AND ACNTS_BRN_CODE = :P_BRANCH_CODE
                     AND ACNTS_BRN_CODE = MBRN_CODE
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND PRODUCT_FOR_LOANS = ''1''
                     AND PRODUCT_CODE = IACLINK_PROD_CODE
                     AND ACTYPE_CODE = ACNTS_AC_TYPE
                     AND ACNTS_GLACC_CODE IN
                            (SELECT R.RPTHDGLDTL_GLACC_CODE
                               FROM RPTHEADGLDTL R
                              WHERE R.RPTHDGLDTL_CODE = ''L2607'')
                     AND TRIM (LNACNT_AUTH_ON) IS NOT NULL
                     AND ACNTS_OPENING_DATE <= :P_FROM_DATE
                     AND (   ACNTS_CLOSURE_DATE IS NULL
                          OR ACNTS_CLOSURE_DATE >= :P_TO_DATE)
                     AND FN_REP_GET_ASON_ACBAL (
                            ACNTS_ENTITY_NUM,
                            LNACNT_INTERNAL_ACNUM,
                            ACNTS_CURR_CODE,
                            :P_TO_DATE,
                            TO_DATE (
                               FN_GET_CURRBUSS_DATE (ACNTS_ENTITY_NUM, NULL)),
                            ''C'') > 0)';
                            
                            
                            
V_DATA := V_DATA || 
'
UNION ALL
      SELECT    TOTAL_DATA
             || TRIM (
                   TO_CHAR (NVL (DEBIT_SUM, 0), ''0000000000000000000000.00''))
                SBS2T_DATA
        FROM (SELECT    TO_CHAR (:P_TO_DATE, ''DDMMYYYY'')
                     || SUBSTR (MBRN_BSR_CODE, 3)
                     || CASE
                           WHEN LENGTH (EXTGL_ACCESS_CODE) > 12
                           THEN
                              SUBSTR (EXTGL_ACCESS_CODE, -12, 12)
                           ELSE
                              LPAD (EXTGL_ACCESS_CODE, 12, ''0'')
                        END
                     || RPAD (
                           NVL (
                              TRIM (
                                 REGEXP_REPLACE (EXTGL_EXT_HEAD_DESCN,
                                                 ''[^[:print:]]'',
                                                 '' '')),
                              '' ''),
                           100,
                           '' '')
                     || RPAD (NVL (NVL ( (NULL), '' ''), '' ''), 50, '' '')
                     || ''000000''
                     || RPAD (NVL ('''', '' ''), 100, '' '')
                     || LPAD (NVL (NVL ('''', 0), ''0''), 3, ''0'')
                     || TRIM (TO_CHAR (NVL ('''', 0), ''00.00''))
                     || LPAD (
                           NVL (TO_CHAR (TO_DATE (NULL), ''DDMMYYYY''), '' ''),
                           8,
                           '' '')
                     || LPAD (
                           NVL (TO_CHAR (TO_DATE (NULL), ''DDMMYYYY''), '' ''),
                           8,
                           '' '')
                     || TRIM (
                           TO_CHAR (
                              NVL (
                                 FN_BIS_GET_ASON_GLBAL (
                                    GLBBAL_ENTITY_NUM,
                                    GLBBAL_BRANCH_CODE,
                                    GLBBAL_GLACC_CODE,
                                    CASE
                                       WHEN TRIM (GLBBAL_CURR_CODE) IS NULL
                                       THEN
                                          ''BDT''
                                       ELSE
                                          GLBBAL_CURR_CODE
                                    END,
                                    :P_TO_DATE,
                                    TO_DATE (
                                       FN_GET_CURRBUSS_DATE (
                                          GLBBAL_ENTITY_NUM,
                                          NULL))),
                                 0),
                              ''0000000000000000000000.00''))
                        TOTAL_DATA,
                     NVL (
                        (SELECT NVL (SUM (GLSUM_AC_DB_SUM), 0)
                           FROM GLSUM' || V_FIN_YEAR ||'
                          WHERE     GLSUM_ENTITY_NUM = GLBBAL_ENTITY_NUM
                                AND GLSUM_BRANCH_CODE = GLBBAL_BRANCH_CODE
                                AND GLSUM_GLACC_CODE = GLBBAL_GLACC_CODE
                                AND GLSUM_CURR_CODE = GLBBAL_CURR_CODE
                                AND GLSUM_TRAN_DATE BETWEEN :P_FROM_DATE
                                                        AND :P_TO_DATE),
                        0)
                        DEBIT_SUM
                FROM RPTHEAD H,
                     RPTLAYOUTDTL L,
                     RPTHEADGLDTL D,
                     EXTGL E,
                     GLMAST G,
                     GLBBAL,
                     MBRN
               WHERE     H.RPTHEAD_CODE = L.RPTLAYOUTDTL_RPT_HEAD_CODE
                     AND L.RPTLAYOUTDTL_RPT_HEAD_CODE = D.RPTHDGLDTL_CODE
                     AND D.RPTHDGLDTL_GLACC_CODE = E.EXTGL_ACCESS_CODE
                     AND E.EXTGL_GL_HEAD = G.GL_NUMBER
                     AND L.RPTLAYOUTDTL_RPT_CODE = ''SBS2T''
                     AND G.GL_CLOSURE_DATE IS NULL
                     AND EXTGL_ACCESS_CODE = GLBBAL_GLACC_CODE
                     AND GLBBAL_ENTITY_NUM = :V_ENTITY_NUM
                     AND GLBBAL_BRANCH_CODE = :P_BRANCH_CODE
                     AND MBRN_CODE = GLBBAL_BRANCH_CODE
                     AND GLBBAL_YEAR =
                            TO_NUMBER (TO_CHAR (:P_TO_DATE, ''YYYY'')))';
                            
                            
                     --INSERT INTO SBS2_DATA_CLOB VALUES (V_DATA);
                     --COMMIT ;
                     
                     P_DATA := V_DATA ;
END SP_SBS2_DATA_QUERY;
/





----------------------- PKG_SBS2_DATA package specification ------------------




CREATE OR REPLACE PACKAGE PKG_SBS2_DATA IS
  
  TYPE TY_TEMP_SBS2_DATA IS RECORD(
    TOTAL_DATA VARCHAR2(1000) );

  TYPE TTY_TEMP_SBS2DATA IS TABLE OF TY_TEMP_SBS2_DATA;

  FUNCTION FN_SBS2_DATA(P_ENTITY_NUM NUMBER , P_BRANCH_CODE NUMBER, P_FROM_DATE DATE , P_TO_DATE DATE) RETURN TTY_TEMP_SBS2DATA
    PIPELINED;

END PKG_SBS2_DATA;
/


------------------------- PKG_SBS2_DATA package body --------------------------



CREATE OR REPLACE PACKAGE BODY PKG_SBS2_DATA
IS
   TEMP_TY_SBS2_DATA   PKG_SBS2_DATA.TY_TEMP_SBS2_DATA;
   
   TYPE SBSDATA IS RECORD (TEMP_DATA VARCHAR2(1000));

   TYPE IN_SBSDATA IS TABLE OF SBSDATA
      INDEX BY PLS_INTEGER;

   V_IN_SBSDATA   IN_SBSDATA;
   l_start NUMBER;
   
   V_SL           NUMBER := 0;
   ---V_FILE_DATA    CLOB;
   V_DATA         VARCHAR2 (3000);

   FUNCTION FN_SBS2_DATA (P_ENTITY_NUM NUMBER , P_BRANCH_CODE NUMBER, P_FROM_DATE DATE , P_TO_DATE DATE)
      RETURN TTY_TEMP_SBS2DATA
      PIPELINED
   -- RETURN VARCHAR2
   IS
      TYPE TEMP_SBS2_DATA IS RECORD
      (
         TOTAL_DATA CLOB 
      );

      TYPE TY_SBS2_DATA IS TABLE OF TEMP_SBS2_DATA;

      V_TY_SBS2_DATA   TY_SBS2_DATA;
      V_DATA_QUERY CLOB;
      
   BEGIN
   -- l_start := DBMS_UTILITY.get_time;
   V_SL := 0 ;
      SP_SBS2_DATA_QUERY (P_BRANCH_CODE,
                          P_FROM_DATE,
                          P_TO_DATE,
                          V_DATA_QUERY);

      EXECUTE IMMEDIATE V_DATA_QUERY
         BULK COLLECT INTO V_IN_SBSDATA
         USING P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_FROM_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_TO_DATE,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE;
    
    --DBMS_OUTPUT.put_line('Query Exeecution Time' || (DBMS_UTILITY.get_time - l_start) || ' hsecs');
     l_start := DBMS_UTILITY.get_time;
    
      IF V_IN_SBSDATA.COUNT > 0
      THEN
         FOR I IN V_IN_SBSDATA.FIRST .. V_IN_SBSDATA.LAST
         LOOP
            V_SL := V_SL + 1;
            V_DATA := LPAD (V_SL, 6, '0') || V_IN_SBSDATA (I).TEMP_DATA;

            TEMP_TY_SBS2_DATA.TOTAL_DATA := TO_CHAR(V_DATA) ;
            
            PIPE ROW (TEMP_TY_SBS2_DATA);
            
            --V_FILE_DATA := V_FILE_DATA || (CASE WHEN V_FILE_DATA IS NOT NULL THEN CHR (10) END) || V_DATA;
         --UTL_FILE.PUT (V_FILE, V_DATA);
         --UTL_FILE.NEW_LINE (V_FILE, 1);
         --DBMS_OUTPUT.PUT_LINE(V_IN_SBSDATA.COUNT);
         END LOOP;
         --DBMS_OUTPUT.put_line('Result Time' || (DBMS_UTILITY.get_time - l_start) || ' hsecs');  
         V_IN_SBSDATA.DELETE;
      END IF;
      
    
   END FN_SBS2_DATA;
END PKG_SBS2_DATA;
/





--------------------------------------- FN_GET_SND_INT_RATE  ---------------------------



CREATE OR REPLACE FUNCTION FN_GET_SND_INT_RATE (
   P_ENTITY_NO   IN SBCAIA.SBCAIA_ENTITY_NUM%TYPE,
   P_BRN_CD      IN SBCAIA.SBCAIA_BRN_CODE%TYPE,
   P_INT_ACNUM   IN IACLINK.IACLINK_INTERNAL_ACNUM%TYPE,
   P_DR_CR_FLG   IN SBCAIA.SBCAIA_CR_DB_INT_FLG%TYPE := 'C',
   P_ASON_DATE   IN SBCAIA.SBCAIA_DATE_OF_ENTRY%TYPE)
   RETURN PKG_COMMON_TYPES.int_rate
IS
   W_SND_INT_RATE   PKG_COMMON_TYPES.int_rate := 0.0;
BEGIN
   SELECT NVL (MAX (SBCAIA_INT_RATE), 0)
     INTO W_SND_INT_RATE
     FROM SBCAIA SB
    WHERE     SB.SBCAIA_ENTITY_NUM = P_ENTITY_NO
          AND SB.SBCAIA_BRN_CODE = P_BRN_CD
          AND SB.SBCAIA_INTERNAL_ACNUM = P_INT_ACNUM
          AND SB.SBCAIA_CR_DB_INT_FLG = P_DR_CR_FLG
          AND SB.SBCAIA_INT_ACCR_DB_CR = P_DR_CR_FLG
          AND SB.SBCAIA_DATE_OF_ENTRY =
                 (SELECT MAX (SBCAIA_DATE_OF_ENTRY)
                    FROM SBCAIA
                   WHERE     SB.SBCAIA_ENTITY_NUM = P_ENTITY_NO
                         AND SB.SBCAIA_BRN_CODE = P_BRN_CD
                         AND SBCAIA_INTERNAL_ACNUM = P_INT_ACNUM
                         AND SB.SBCAIA_CR_DB_INT_FLG = P_DR_CR_FLG
                         AND SB.SBCAIA_INT_ACCR_DB_CR = P_DR_CR_FLG
                         AND SBCAIA_DATE_OF_ENTRY <= P_ASON_DATE);
RETURN W_SND_INT_RATE;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      W_SND_INT_RATE := 0.0;
      --- Added by rajib.pradhan for handle multiple rows which was raise on 11/01/2015 for grnerat SBS reports
      --- Removed by Fahim.Ahmad(this part is repaced to the main pl/sql block)
RETURN W_SND_INT_RATE;
END FN_GET_SND_INT_RATE;
/


-------------------------------------- Query ----------------------------------


SELECT * FROM TABLE (PKG_SBS2_DATA.FN_SBS2_DATA(1, 1065, '01-JUL-2016', '30-SEP-2016'))