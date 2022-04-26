CREATE OR REPLACE PROCEDURE SP_GEN_F12_F42_DATA (
   P_FROM_BRN    NUMBER,
   P_TO_BRN      NUMBER)
IS
   V_CBD           DATE;
   P_ERROR_MSG     VARCHAR2 (1000);
   V_DUMMY_COUNT   NUMBER;
   V_ASON_DATE     DATE;
BEGIN
   --V_ASON_DATE := TRUNC (SYSDATE)-1 ;

   V_ASON_DATE := '30-SEP-2019';

   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP
      DELETE FROM INCOMEEXPENSE
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;

      SP_INCOMEEXPENSE (IDX.BRANCH_CODE,
                        V_ASON_DATE,
                        P_ERROR_MSG,
                        1,
                        1,
                        1,
                        NULL);
      COMMIT;
   END LOOP;



   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP
      DELETE FROM STATMENTOFAFFAIRS
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;

      SP_STATEMENT_OF_AFFAIRS_F12 (IDX.BRANCH_CODE,
                                   V_ASON_DATE,
                                   P_ERROR_MSG,
                                   1,
                                   1,
                                   1,
                                   NULL);
      COMMIT;
   END LOOP;



   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                        AND BRANCH_CODE NOT IN (SELECT BRN_CODE
                                                  FROM GLWISE_AMOUNT
                                                 WHERE RPTDATE = V_ASON_DATE)
               ORDER BY BRANCH_CODE)
   LOOP
      PKG_STATEMENT_OF_AFFAIRS_F12.SP_GET_ASSETS_LIABILITIES (
         'F12',
         1,
         IDX.BRANCH_CODE,
         V_ASON_DATE,
         NULL);
      COMMIT;
   END LOOP;


END SP_GEN_F12_F42_DATA;
/
