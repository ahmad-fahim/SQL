CREATE TABLE BRANCHWISE_DATA_DEP
(
   BRANCH_CODE       NUMBER (6),
   REPORTING_DATE    VARCHAR2 (8),
   TYPE_OF_DEPOSIT   VARCHAR2 (10),
   F12               VARCHAR2 (10),
   INT_RATE          NUMBER (18, 3),
   BALANCE           NUMBER (18, 3)
);








CREATE OR REPLACE PROCEDURE SP_MIS_DATA_BRANCHWISE_DEP (V_ENTITY_NUM    NUMBER,
                                                    P_FROM_DATE     DATE,
													P_TO_DATE       DATE)
IS
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      INSERT INTO BRANCHWISE_DATA_DEP
           SELECT IDX.BRANCH_CODE,
                  REPORTING_DATE,
                  TYPE_OF_DEPOSIT,
                  F12,
                  INT_RATE,
                  SUM (BALANCE)
             FROM (SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          CASE
                             WHEN GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2607'
                             THEN
                                LPAD (NVL (NVL (100, 0), '0'), 3, '0')
                             ELSE
                                LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), '0'),
                                      3,
                                      '0')
                          END
                             TYPE_OF_DEPOSIT,
                          NVL (
                             (CASE
                                 WHEN (SELECT NVL (PG.PWGENPARAM_SND_PROD,
                                                   '0')
                                         FROM PWGENPARAM PG
                                        WHERE PG.PWGENPARAM_PROD_CODE =
                                                 PRODUCT_CODE) = '1'
                                 THEN
                                    FN_GET_SND_INT_RATE (ACNTS_ENTITY_NUM,
                                                         ACNTS_BRN_CODE,
                                                         ACNTS_INTERNAL_ACNUM,
                                                         'C',
                                                         P_TO_DATE)
                                 ELSE
                                    FN_GET_INTRATE_RUN_ACS_NEW (
                                       ACNTS_INTERNAL_ACNUM,
                                       PRODUCT_CODE,
                                       ACNTS_CURR_CODE,
                                       ACNTS_AC_TYPE,
                                       ACNTS_AC_SUB_TYPE,
                                       'C',
                                       P_TO_DATE)
                              END),
                             0)
                             INT_RATE,
                          CASE
                             WHEN    ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > P_TO_DATE
                             THEN
                                (SELECT NVL (
                                             NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0)
                                           - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                           0)
                                   FROM ACNTBBAL
                                  WHERE     ACNTBBAL_ENTITY_NUM =
                                               ACNTS_ENTITY_NUM
                                        AND ACNTBBAL_INTERNAL_ACNUM =
                                               ACNTS_INTERNAL_ACNUM
                                        AND ACNTBBAL_CURR_CODE =
                                               ACNTS_CURR_CODE
                                        AND ACNTBBAL_YEAR =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1,
                                                           'YYYY'))
                                        AND ACNTBBAL_MONTH =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1, 'MM')))
                             ELSE
                                0
                          END
                             BALANCE,
                          CASE
                             WHEN ACNTS_AC_TYPE IN ('SD')
                             THEN
                                'L2107'
                             ELSE
                                NVL ( (GET_F12_CODE (ACNTS_GLACC_CODE)), 'F12')
                          END
                             F12
                     FROM ACNTS,
                          MBRN,
                          CLIENTS,
                          PRODUCTS,
                          ACTYPES
                    WHERE     ACNTS_ENTITY_NUM = V_ENTITY_NUM
                          AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                          AND ACNTS_BRN_CODE = MBRN_CODE
                          AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                          AND PRODUCT_FOR_DEPOSITS = '1'
                          AND PRODUCT_FOR_RUN_ACS = '1'
                          AND PRODUCT_CODE = ACNTS_PROD_CODE
                          AND ACTYPE_CODE = ACNTS_AC_TYPE
                          AND ACNTS_OPENING_DATE <= P_TO_DATE
                          AND (   ACNTS_CLOSURE_DATE IS NULL
                               OR ACNTS_CLOSURE_DATE >= P_FROM_DATE)
                   UNION ALL
                   SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          CASE
                             WHEN GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2607'
                             THEN
                                LPAD (NVL (NVL (100, 0), '0'), 3, '0')
                             WHEN     GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2001'
                                  AND PDBCONT_DEP_PRD_MONTHS = 3
                             THEN
                                LPAD (NVL (NVL (171, 0), '0'), 3, '0')
                             WHEN     GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2001'
                                  AND PDBCONT_DEP_PRD_MONTHS = 6
                             THEN
                                LPAD (NVL (NVL (172, 0), '0'), 3, '0')
                             WHEN     GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2001'
                                  AND PDBCONT_DEP_PRD_MONTHS = 12
                             THEN
                                LPAD (NVL (NVL (173, 0), '0'), 3, '0')
                             WHEN     GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2001'
                                  AND PDBCONT_DEP_PRD_MONTHS = 24
                             THEN
                                LPAD (NVL (NVL (174, 0), '0'), 3, '0')
                             WHEN     GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2001'
                                  AND PDBCONT_DEP_PRD_MONTHS >= 36
                             THEN
                                LPAD (NVL (NVL (175, 0), '0'), 3, '0')
                             ELSE
                                LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), '0'),
                                      3,
                                      '0')
                          END
                             TYPE_OF_DEPOSIT,
                          NVL (PBDCONT_ACTUAL_INT_RATE, 0) INT_RATE,
                          CASE
                             WHEN    ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > P_TO_DATE
                             THEN
                                (SELECT NVL (
                                             NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0)
                                           - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                           0)
                                   FROM ACNTBBAL
                                  WHERE     ACNTBBAL_ENTITY_NUM =
                                               ACNTS_ENTITY_NUM
                                        AND ACNTBBAL_INTERNAL_ACNUM =
                                               ACNTS_INTERNAL_ACNUM
                                        AND ACNTBBAL_CURR_CODE =
                                               ACNTS_CURR_CODE
                                        AND ACNTBBAL_YEAR =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1,
                                                           'YYYY'))
                                        AND ACNTBBAL_MONTH =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1, 'MM')))
                             ELSE
                                0
                          END
                             BALANCE,
                          NVL ( (GET_F12_CODE (ACNTS_GLACC_CODE)), 'F12') F12
                     FROM ACNTS,
                          MBRN,
                          CLIENTS,
                          PRODUCTS,
                          ACTYPES,
                          PBDCONTRACT P
                    WHERE     ACNTS_ENTITY_NUM = V_ENTITY_NUM
                          AND PBDCONT_ENTITY_NUM = V_ENTITY_NUM
                          AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                          AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                          AND ACNTS_BRN_CODE = MBRN_CODE
                          AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                          AND PRODUCT_FOR_DEPOSITS = '1'
                          AND PRODUCT_FOR_RUN_ACS = '0'
                          AND PRODUCT_CODE = ACNTS_PROD_CODE
                          AND ACTYPE_CODE = ACNTS_AC_TYPE
                          AND PBDCONT_EFF_DATE <= P_TO_DATE
                          AND PBDCONT_CONT_NUM =
                                 (SELECT MAX (PP.PBDCONT_CONT_NUM)
                                    FROM PBDCONTRACT PP
                                   WHERE     PP.PBDCONT_ENTITY_NUM =
                                                P.PBDCONT_ENTITY_NUM
                                         AND PP.PBDCONT_BRN_CODE =
                                                P.PBDCONT_BRN_CODE
                                         AND PP.PBDCONT_DEP_AC_NUM =
                                                P.PBDCONT_DEP_AC_NUM
                                         AND PP.PBDCONT_EFF_DATE <= P_TO_DATE)
                          AND TRIM (PBDCONT_AUTH_ON) IS NOT NULL
                          AND (   PBDCONT_CLOSURE_DATE IS NULL
                               OR PBDCONT_CLOSURE_DATE >= P_FROM_DATE)
                   UNION ALL
                   SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          CASE
                             WHEN GET_F12_CODE (ACNTS_GLACC_CODE) = 'L2607'
                             THEN
                                LPAD (NVL (NVL (100, 0), '0'), 3, '0')
                             ELSE
                                LPAD (NVL (NVL (ACTYPE_BSR_AC_TYPE, 0), '0'),
                                      3,
                                      '0')
                          END
                             TYPE_OF_DEPOSIT,
                          NVL (
                             (SELECT LNACIR_APPL_INT_RATE
                                FROM LNACIR
                               WHERE     LNACIR_ENTITY_NUM = 1
                                     AND LNACIR_INTERNAL_ACNUM =
                                            ACNTS_INTERNAL_ACNUM),
                             0)
                             INT_RATE,
                          CASE
                             WHEN    ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > P_TO_DATE
                             THEN
                                (SELECT NVL (
                                             NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0)
                                           - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                           0)
                                   FROM ACNTBBAL
                                  WHERE     ACNTBBAL_ENTITY_NUM =
                                               ACNTS_ENTITY_NUM
                                        AND ACNTBBAL_INTERNAL_ACNUM =
                                               ACNTS_INTERNAL_ACNUM
                                        AND ACNTBBAL_CURR_CODE =
                                               ACNTS_CURR_CODE
                                        AND ACNTBBAL_YEAR =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1,
                                                           'YYYY'))
                                        AND ACNTBBAL_MONTH =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1, 'MM')))
                             ELSE
                                0
                          END
                             BALANCE,
                          NVL ( (GET_F12_CODE (ACNTS_GLACC_CODE)), 'F12') F12
                     FROM ACNTS,
                          MBRN,
                          CLIENTS,
                          PRODUCTS,
                          ACTYPES,
                          LOANACNTS
                    WHERE     ACNTS_ENTITY_NUM = V_ENTITY_NUM
                          AND LNACNT_ENTITY_NUM = V_ENTITY_NUM
                          AND LNACNT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                          AND ACNTS_BRN_CODE = MBRN_CODE
                          AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                          AND PRODUCT_FOR_LOANS = '1'
                          AND PRODUCT_CODE = ACNTS_PROD_CODE
                          AND ACTYPE_CODE = ACNTS_AC_TYPE
                          AND ACNTS_GLACC_CODE IN
                                 (SELECT R.RPTHDGLDTL_GLACC_CODE
                                    FROM RPTHEADGLDTL R
                                   WHERE R.RPTHDGLDTL_CODE = 'L2607')
                          AND TRIM (LNACNT_AUTH_ON) IS NOT NULL
                          AND ACNTS_OPENING_DATE <= P_TO_DATE
                          AND (   ACNTS_CLOSURE_DATE IS NULL
                               OR ACNTS_CLOSURE_DATE >= P_FROM_DATE)
                          AND FN_REP_GET_ASON_ACBAL (
                                 ACNTS_ENTITY_NUM,
                                 LNACNT_INTERNAL_ACNUM,
                                 ACNTS_CURR_CODE,
                                 P_TO_DATE,
                                 TO_DATE (
                                    FN_GET_CURRBUSS_DATE (ACNTS_ENTITY_NUM,
                                                          NULL)),
                                 'C') > 0
                   UNION ALL
                   SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          'GL' TYPE_OF_DEPOSIT,
                          0 INT_RATE,
                          CASE
                             WHEN    NVL (
                                        (GET_F12_CODE (E.EXTGL_ACCESS_CODE)),
                                        'F12') IN
                                        ('L2607')
                                  OR FN_BIS_GET_ASON_GLBAL (
                                        GLBBAL_ENTITY_NUM,
                                        GLBBAL_BRANCH_CODE,
                                        GLBBAL_GLACC_CODE,
                                        CASE
                                           WHEN TRIM (GLBBAL_CURR_CODE) IS NULL
                                           THEN
                                              'BDT'
                                           ELSE
                                              GLBBAL_CURR_CODE
                                        END,
                                        P_TO_DATE,
                                        TO_DATE (
                                           FN_GET_CURRBUSS_DATE (
                                              GLBBAL_ENTITY_NUM,
                                              NULL))) < 0
                             THEN
                                0
                             ELSE
                                FN_BIS_GET_ASON_GLBAL (
                                   GLBBAL_ENTITY_NUM,
                                   GLBBAL_BRANCH_CODE,
                                   GLBBAL_GLACC_CODE,
                                   CASE
                                      WHEN TRIM (GLBBAL_CURR_CODE) IS NULL
                                      THEN
                                         'BDT'
                                      ELSE
                                         GLBBAL_CURR_CODE
                                   END,
                                   P_TO_DATE,
                                   TO_DATE (
                                      FN_GET_CURRBUSS_DATE (GLBBAL_ENTITY_NUM,
                                                            NULL)))
                          END
                             BALANCE,
                          NVL ( (GET_F12_CODE (E.EXTGL_ACCESS_CODE)), 'F12')
                             F12
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
                          AND L.RPTLAYOUTDTL_RPT_CODE = 'SBS2T'
                          AND G.GL_CLOSURE_DATE IS NULL
                          AND EXTGL_ACCESS_CODE = GLBBAL_GLACC_CODE
                          AND GLBBAL_ENTITY_NUM = V_ENTITY_NUM
                          AND GLBBAL_BRANCH_CODE = IDX.BRANCH_CODE
                          AND MBRN_CODE = GLBBAL_BRANCH_CODE
                          AND GLBBAL_YEAR =
                                 TO_NUMBER (TO_CHAR (P_TO_DATE, 'YYYY')))
         GROUP BY REPORTING_DATE,
                  TYPE_OF_DEPOSIT,
                  F12,
                  INT_RATE
         ORDER BY REPORTING_DATE,
                  F12,
                  TYPE_OF_DEPOSIT,
                  INT_RATE;

      COMMIT;
   END LOOP;
END SP_MIS_DATA_BRANCHWISE_DEP;