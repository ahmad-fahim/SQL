SELECT *
  FROM (SELECT GLBALH_BRN_CODE,
               GLBALH_BC_BAL,
               TRAN_ACING_BRN_CODE,
               NVL (TRAN_AMT, 0),
               GLBALH_BC_BAL + NVL (TRAN_AMT, 0) BAL_ON_11_OCT
          FROM (SELECT GLBALH_BRN_CODE, GLBALH_BC_BAL
                  FROM GLBALASONHIST
                 WHERE     GLBALH_ENTITY_NUM = 1
                       AND GLBALH_GLACC_CODE = '217101101'
                       AND GLBALH_ASON_DATE = :P_TRAN_DATE - 1) A
               FULL OUTER JOIN
               (  SELECT TRAN_ACING_BRN_CODE,
                         SUM (CREDIT_AMT),
                         SUM (DEBIT_AMT),
                         SUM (CREDIT_AMT) - SUM (DEBIT_AMT) TRAN_AMT
                    FROM (SELECT TRAN_ACING_BRN_CODE,
                                 TRAN_DB_CR_FLG,
                                 CASE
                                    WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                                    ELSE 0
                                 END
                                    CREDIT_AMT,
                                 CASE
                                    WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                                    ELSE 0
                                 END
                                    DEBIT_AMT
                            FROM TRAN2015
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                                 AND TRAN_GLACC_CODE = '217101101'
                                 AND TRAN_AUTH_BY IS NOT NULL)
                GROUP BY TRAN_ACING_BRN_CODE) B
                  ON (A.GLBALH_BRN_CODE = B.TRAN_ACING_BRN_CODE)) AA FULL OUTER JOIN 
       (SELECT G.GLBALH_BRN_CODE, G.GLBALH_BC_BAL
          FROM GLBALASONHIST G
         WHERE     G.GLBALH_ENTITY_NUM = 1
               AND G.GLBALH_GLACC_CODE = '217101101'
               AND G.GLBALH_ASON_DATE = :P_TRAN_DATE) BB
                 ON (AA.GLBALH_BRN_CODE = BB.GLBALH_BRN_CODE)
                 WHERE AA.BAL_ON_11_OCT <> BB.GLBALH_BC_BAL ;









  SELECT T.TRAN_ENTITY_NUM,
         T.TRAN_BRN_CODE,
         T.TRAN_DATE_OF_TRAN,
         T.TRAN_BATCH_NUMBER,
         COUNT (DISTINCT  TRAN_ACING_BRN_CODE),
         TO_CHAR(wm_concat (DISTINCT  TRAN_ACING_BRN_CODE)),
         (SELECT SUM(TRAN_AMOUNT)
               FROM TRAN2018
              WHERE     TRAN_ENTITY_NUM = 1
                    AND TRAN_GLACC_CODE = '217101101'
                    AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE
                    AND TRAN_BRN_CODE = T.TRAN_BRN_CODE 
                    AND TRAN_BATCH_NUMBER = T.TRAN_BATCH_NUMBER) AMOUNT
    FROM TRAN2018 T
   WHERE (T.TRAN_ENTITY_NUM,
          T.TRAN_BRN_CODE,
          T.TRAN_DATE_OF_TRAN,
          T.TRAN_BATCH_NUMBER) IN
            (SELECT TRAN_ENTITY_NUM,
                    TRAN_BRN_CODE,
                    TRAN_DATE_OF_TRAN,
                    TRAN_BATCH_NUMBER
               FROM TRAN2018
              WHERE     TRAN_ENTITY_NUM = 1
                    AND TRAN_GLACC_CODE = '217101101'
                    AND TRAN_DATE_OF_TRAN = :P_TRAN_DATE--AND TRAN_AMOUNT = 500
            )
GROUP BY T.TRAN_ENTITY_NUM,
         T.TRAN_BRN_CODE,
         T.TRAN_DATE_OF_TRAN,
         T.TRAN_BATCH_NUMBER
         having COUNT (DISTINCT  TRAN_ACING_BRN_CODE) < 2  ;
		 
		 
		 


CREATE OR REPLACE FUNCTION FN_GET_F12_CODE (P_GL_CODE    VARCHAR2,
                                            P_IDENT      VARCHAR2)
   RETURN VARCHAR2
IS
   V_F12_CODE   VARCHAR2 (20);
BEGIN
   BEGIN
      SELECT RPTHDGLDTL_CODE
        INTO V_F12_CODE
        FROM (  SELECT RPTHDGLDTL_CODE, ROWNUM ROW_ID
                  FROM RPTHEADGLDTL
                 WHERE     RPTHDGLDTL_GLACC_CODE = P_GL_CODE
                       AND SUBSTR (RPTHDGLDTL_CODE, 1, 1) = P_IDENT
              ORDER BY RPTHDGLDTL_CODE)
       WHERE ROW_ID = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_F12_CODE := NULL;
   END;

   RETURN V_F12_CODE;
END FN_GET_F12_CODE;









  SELECT BRANCH_CODE, F12_CODE, SUM (REPORT_BAL)
    FROM (SELECT BRANCH_CODE,
                 GLACC_CODE,
                 BC_BAL,
                 RPTHDGLDTL_ACNT_PARTIAL_SEL,
                 REPORT_BAL,
                 CASE WHEN REPORT_BAL > 0 THEN 'L' ELSE 'A' END IDENT,
                 FN_GET_F12_CODE (
                    GLACC_CODE,
                    CASE WHEN REPORT_BAL > 0 THEN 'L' ELSE 'A' END)
                    F12_CODE
            FROM (SELECT DISTINCT
                         GLBBAL_BRANCH_CODE BRANCH_CODE,
                         GLBBAL_GLACC_CODE GLACC_CODE,
                         GLBBAL_BC_BAL BC_BAL,
                         RPTHDGLDTL_ACNT_PARTIAL_SEL
                            RPTHDGLDTL_ACNT_PARTIAL_SEL,
                         CASE
                            WHEN RPTHDGLDTL_ACNT_PARTIAL_SEL = 0
                            THEN
                               FN_BIS_GET_ASON_GLBAL (GLBBAL_ENTITY_NUM,
                                                      GLBBAL_BRANCH_CODE,
                                                      GLBBAL_GLACC_CODE,
                                                      GLBBAL_CURR_CODE,
                                                      :P_ASON_DATE,
                                                      :P_CBD)
                            ELSE
                               (SELECT NVL (
                                          SUM (
                                             FN_BIS_GET_ASON_ACBAL (
                                                ACNTS_ENTITY_NUM,
                                                ACNTS_INTERNAL_ACNUM,
                                                ACNTS_CURR_CODE,
                                                :P_ASON_DATE,
                                                :P_CBD)),
                                          0)
                                          AC_BAL
                                  FROM ACNTS
                                 WHERE     ACNTS_ENTITY_NUM = 1
                                       AND ACNTS_BRN_CODE = :P_BRN_CODE
                                       AND ACNTS_GLACC_CODE = GLBBAL_GLACC_CODE
                                       AND ACNTS_CLOSURE_DATE IS NULL)
                         END
                            REPORT_BAL
                    FROM GLBBAL,
                         RPTHEADGLDTL,
                         EXTGL,
                         GLMAST
                   WHERE     RPTHDGLDTL_GLACC_CODE = GLBBAL_GLACC_CODE
                         AND GLBBAL_ENTITY_NUM = 1
                         AND EXTGL_ACCESS_CODE = RPTHDGLDTL_GLACC_CODE
                         AND EXTGL_GL_HEAD = GL_NUMBER
                         --AND GL_TYPE IN  ('A', 'L')
                         AND GLBBAL_BRANCH_CODE = :P_BRN_CODE
                         AND GLBBAL_YEAR = 2017
                         AND SUBSTR (RPTHDGLDTL_CODE, 1, 1) IN ('A', 'L')--ORDER BY GLBBAL_GLACC_CODE
                 )
           WHERE REPORT_BAL <> 0)
GROUP BY BRANCH_CODE, F12_CODE
ORDER BY BRANCH_CODE, F12_CODE
--HAVING F12_CODE IS NOT NULL