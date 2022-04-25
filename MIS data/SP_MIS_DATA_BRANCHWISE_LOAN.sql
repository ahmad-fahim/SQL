CREATE OR REPLACE PROCEDURE SP_MIS_DATA_BRANCHWISE_LOAN (
   V_ENTITY_NUM    NUMBER,
   P_FROM_DATE     DATE,
   P_TO_DATE       DATE)
IS
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      INSERT INTO BRANCHWISE_DATA_LOAN
           SELECT IDX.BRANCH_CODE,
                  REPORTING_DATE,
                  LOAN_CODE,
                  CLASSIFICATION_CODE,
                  INTERST_RATE,
                  SUM (OUTSTANDING_BALANCE) OUTSTANDING_BALANCE
             FROM (SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          NVL (
                             (SELECT RPTHDGLDTL_CODE
                                FROM RPTHEAD H, RPTLAYOUTDTL, RPTHEADGLDTL D
                               WHERE     H.RPTHEAD_CODE =
                                            RPTLAYOUTDTL_RPT_HEAD_CODE
                                     AND D.RPTHDGLDTL_CODE =
                                            RPTLAYOUTDTL_RPT_HEAD_CODE
                                     AND D.RPTHDGLDTL_GLACC_CODE =
                                            ACNTS_GLACC_CODE
                                     AND RPTLAYOUTDTL_RPT_CODE = 'F12'
                                     AND H.RPTHEAD_CLASSIFICATION = 'A'),
                             '0')
                             LOAN_CODE,
                          NVL (
                             CASE
                                WHEN (SELECT LNACIRS_AC_LEVEL_INT_REQD
                                        FROM LNACIRS
                                       WHERE     LNACIRS_ENTITY_NUM =
                                                    V_ENTITY_NUM
                                             AND LNACIRS_INTERNAL_ACNUM =
                                                    A.ACNTS_INTERNAL_ACNUM) =
                                        '1'
                                THEN
                                   (SELECT LNACIR_APPL_INT_RATE
                                      FROM LNACIR
                                     WHERE     LNACIR_ENTITY_NUM = V_ENTITY_NUM
                                           AND LNACIR_INTERNAL_ACNUM =
                                                  A.ACNTS_INTERNAL_ACNUM)
                                ELSE
                                   (SELECT LL.LNPRODIRDTL_INT_RATE
                                      FROM LNPRODIRDTL LL
                                     WHERE     LNPRODIRDTL_ENTITY_NUM =
                                                  V_ENTITY_NUM
                                           AND LL.LNPRODIRDTL_PROD_CODE =
                                                  A.ACNTS_PROD_CODE
                                           AND LL.LNPRODIRDTL_CURR_CODE =
                                                  A.ACNTS_CURR_CODE
                                           AND LL.LNPRODIRDTL_AC_TYPE =
                                                  A.ACNTS_AC_TYPE
                                           AND LL.LNPRODIRDTL_AC_SUB_TYPE =
                                                  A.ACNTS_AC_SUB_TYPE)
                             END,
                             0)
                             INTERST_RATE,
                          (SELECT NVL (TRIM (ASSETCD_BSR_CODE), ' ')
                             FROM ASSETCLS, ASSETCD
                            WHERE     ASSETCLS_ENTITY_NUM = V_ENTITY_NUM
                                  AND ASSETCLS_INTERNAL_ACNUM =
                                         A.ACNTS_INTERNAL_ACNUM
                                  AND ASSETCD_CODE = ASSETCLS_ASSET_CODE)
                             CLASSIFICATION_CODE,
                          NVL (
                             ABS (
                                (SELECT NVL (
                                             NVL (ACNTBBAL_AC_OPNG_CR_SUM, 0)
                                           - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0),
                                           0)
                                   FROM ACNTBBAL
                                  WHERE     ACNTBBAL_ENTITY_NUM = V_ENTITY_NUM
                                        AND ACNTBBAL_INTERNAL_ACNUM =
                                               A.ACNTS_INTERNAL_ACNUM
                                        AND ACNTBBAL_YEAR =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1,
                                                           'YYYY'))
                                        AND ACNTBBAL_MONTH =
                                               TO_NUMBER (
                                                  TO_CHAR (P_TO_DATE + 1, 'MM'))
                                        AND NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0) > NVL (ACNTBBAL_AC_OPNG_CR_SUM, 0))),
                             0)
                             OUTSTANDING_BALANCE
                     FROM PRODUCTS P, ACNTS A, LOANACNTS
                    WHERE     A.ACNTS_ENTITY_NUM = V_ENTITY_NUM
                          AND LNACNT_ENTITY_NUM = V_ENTITY_NUM
                          AND LNACNT_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                          AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                          AND P.PRODUCT_FOR_LOANS = '1'
                          AND A.ACNTS_AUTH_ON IS NOT NULL
                          AND (   A.ACNTS_CLOSURE_DATE IS NULL
                               OR A.ACNTS_CLOSURE_DATE >= P_TO_DATE)
                          AND A.ACNTS_BRN_CODE = IDX.BRANCH_CODE
                   UNION ALL
                   SELECT TO_CHAR (P_TO_DATE, 'DDMMYYYY') REPORTING_DATE,
                          CASE
                             WHEN E.EXTGL_ACCESS_CODE IN ('211140120')
                             THEN
                                'A0304'
                             ELSE
                                NVL (
                                   (GET_HEAD_CODE_TEMP (E.EXTGL_ACCESS_CODE)),
                                   'F12')
                          END
                             LOAN_CODE,
                          0 INT_RATE,
                          'GL' CLASSIFICATION_CODE,
                          ABS (
                             FN_BIS_GET_ASON_GLBAL (
                                V_ENTITY_NUM,
                                IDX.BRANCH_CODE,
                                E.EXTGL_ACCESS_CODE,
                                CASE
                                   WHEN TRIM (GLBBAL_CURR_CODE) IS NULL
                                   THEN
                                      'BDT'
                                   ELSE
                                      GLBBAL_CURR_CODE
                                END,
                                P_TO_DATE,
                                TO_DATE (
                                   FN_GET_CURRBUSS_DATE (V_ENTITY_NUM, NULL))))
                             OUTSTANDING_BALANCE
                     FROM RPTHEAD H,
                          RPTHEADGLDTL D,
                          EXTGL E,
                          GLMAST G,
                          GLBBAL,
                          MBRN
                    WHERE     D.RPTHDGLDTL_GLACC_CODE = E.EXTGL_ACCESS_CODE
                          AND E.EXTGL_GL_HEAD = G.GL_NUMBER
                          AND D.RPTHDGLDTL_CODE IN ('LSBS3')
                          AND G.GL_CLOSURE_DATE IS NULL
                          AND EXTGL_ACCESS_CODE = GLBBAL_GLACC_CODE
                          AND GLBBAL_ENTITY_NUM = V_ENTITY_NUM
                          AND GLBBAL_BRANCH_CODE = IDX.BRANCH_CODE
                          AND H.RPTHEAD_CODE = D.RPTHDGLDTL_CODE
                          AND MBRN_CODE = GLBBAL_BRANCH_CODE
                          AND GLBBAL_YEAR =
                                 TO_NUMBER (TO_CHAR (P_TO_DATE, 'YYYY')))
         GROUP BY REPORTING_DATE,
                  LOAN_CODE,
                  CLASSIFICATION_CODE,
                  INTERST_RATE
         ORDER BY REPORTING_DATE,
                  LOAN_CODE,
                  CLASSIFICATION_CODE,
                  INTERST_RATE;

      COMMIT;
   END LOOP;
END SP_MIS_DATA_BRANCHWISE_LOAN;
/
