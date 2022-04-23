CREATE OR REPLACE PROCEDURE SP_GEN_F12_F42_DATA (P_FROM_BRN    NUMBER,
                                                 P_TO_BRN      NUMBER)
IS
   V_CBD           DATE;
   P_ERROR_MSG     VARCHAR2 (1000);
   V_DUMMY_COUNT   NUMBER;
BEGIN
   FOR IDX
      IN (  SELECT *
              FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                        FROM MIG_DETAIL
                    ORDER BY BRANCH_CODE)
             WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                   AND BRANCH_CODE NOT IN
                          (SELECT RPT_BRN_CODE
                             FROM STATMENTOFAFFAIRS
                            WHERE RPT_ENTRY_DATE = TRUNC (SYSDATE) - 1)
          ORDER BY BRANCH_CODE)
   LOOP
      SP_STATEMENT_OF_AFFAIRS_F12 (IDX.BRANCH_CODE,
                                   TRUNC (SYSDATE) - 1,
                                   P_ERROR_MSG,
                                   0,
                                   0,
                                   1,
                                   NULL);
      COMMIT ;
   END LOOP;


   FOR IDX
      IN (  SELECT *
              FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                        FROM MIG_DETAIL
                    ORDER BY BRANCH_CODE)
             WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                   AND BRANCH_CODE NOT IN
                          (SELECT RPT_BRN_CODE
                             FROM INCOMEEXPENSE
                            WHERE RPT_ENTRY_DATE = TRUNC (SYSDATE) - 1)
          ORDER BY BRANCH_CODE)
   LOOP
      SP_INCOMEEXPENSE (IDX.BRANCH_CODE,
                        TRUNC (SYSDATE) - 1,
                        P_ERROR_MSG,
                        0,
                        0,
                        1,
                        NULL);
COMMIT ;
   END LOOP;
END SP_GEN_F12_F42_DATA;
/