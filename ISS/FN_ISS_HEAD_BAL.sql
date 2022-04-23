/* For ISS report purpose*/
CREATE OR REPLACE FUNCTION FN_ISS_HEAD_BAL (P_BRANCH_CODE      NUMBER,
                                            P_ASON_DATE        DATE,
                                            P_RPT_HEAD_CODE    VARCHAR2,
                                            P_LAYOUT_CODE      VARCHAR2)
   RETURN NUMBER
IS
   V_OUTBAL   NUMBER (18, 2);
BEGIN
   IF P_LAYOUT_CODE = 'F12'
   THEN
      SELECT RPT_HEAD_BAL
        INTO V_OUTBAL
        FROM STATMENTOFAFFAIRS
       WHERE     RPT_BRN_CODE = P_BRANCH_CODE
             AND     (RPT_ENTRY_DATE) =  P_ASON_DATE 
             AND RPT_HEAD_CODE = TRIM (P_RPT_HEAD_CODE);
   ELSIF P_LAYOUT_CODE = 'F42B'
   THEN
      SELECT RPT_HEAD_BAL
        INTO V_OUTBAL
        FROM INCOMEEXPENSE
       WHERE     RPT_BRN_CODE = P_BRANCH_CODE
             AND   (RPT_ENTRY_DATE) = P_ASON_DATE 
             AND RPT_HEAD_CODE = TRIM (P_RPT_HEAD_CODE);
   END IF;

   RETURN V_OUTBAL;
   /*
   SELECT NVL (SUM (GLBALH_BC_BAL, 0)) OUTSTANDING_BALANCE
    FROM GLBALASONHIST,
         RPTHEADGLDTL H,
         EXTGL,
         MBRN
   WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
         AND GLBALH_ENTITY_NUM = 1
         AND GLBALH_BRN_CODE = MBRN_CODE
         AND GLBALH_BRN_CODE = 1065
         AND GLBALH_ASON_DATE = '31-DEC-2018'
         AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
         AND GLBALH_BC_BAL <> 0
         --AND GLBALH_ASON_DATE = '31-AUG-2018'
         AND H.RPTHDGLDTL_CODE IN (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
         AND RPTHDGLDTL_CODE IN ('A0702')
ORDER BY 1
   */

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END;