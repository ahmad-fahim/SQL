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
                     AND ACTYPE_CODE = ACNTS_AC_TYPE
                     AND ACNTS_OPENING_DATE <= :P_TO_DATE 
                     AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > :P_TO_DATE ) )';
                     
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
                     AND ACNTS_OPENING_DATE <= :P_TO_DATE
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
            || CASE
             WHEN GL_BAL >= 0
             THEN
                TRIM (TO_CHAR (NVL (GL_BAL, 0), ''0000000000000000000000.00''))
             ELSE
                TRIM (TO_CHAR (NVL (GL_BAL, 0), ''000000000000000000000.00''))
                END
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
                     || RPAD(NVL(TRIM(RPTHEAD_DESCN2),''000000''),6,''0'')
                     || RPAD (NVL ('''', '' ''), 100, '' '')
                     || LPAD (NVL (NVL (TRIM(RPTHEAD_DESCN3), 0), ''0''), 3, ''0'')
                     || TRIM (TO_CHAR (NVL ('''', 0), ''00.00''))
                     || LPAD (
                           NVL (TO_CHAR (TO_DATE (NULL), ''DDMMYYYY''), '' ''),
                           8,
                           '' '')
                     || LPAD (
                           NVL (TO_CHAR (TO_DATE (NULL), ''DDMMYYYY''), '' ''),
                           8,
                           '' '') TOTAL_DATA,
                     FN_BIS_GET_ASON_GLBAL (
                  GLBBAL_ENTITY_NUM,
                  GLBBAL_BRANCH_CODE,
                  GLBBAL_GLACC_CODE,
                  CASE
                     WHEN TRIM (GLBBAL_CURR_CODE) IS NULL THEN ''BDT''
                     ELSE GLBBAL_CURR_CODE
                  END,
                  :P_TO_DATE,
                  TO_DATE (FN_GET_CURRBUSS_DATE (GLBBAL_ENTITY_NUM, NULL))) GL_BAL,
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