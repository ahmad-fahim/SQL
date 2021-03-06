/*Profit loss according to the GL balance.*/
SELECT * FROM(
SELECT GLBALH_BRN_CODE, SUM(EXPE) TOTAL_EXPENCE, SUM(INCOME) TOTAL_INCOME, SUM(INCOME)-SUM(EXPE) PROFIT_OR_LOSS, (CASE WHEN SUM(INCOME)-SUM(EXPE)<0 THEN 'LOSS' ELSE 'PROFIT' END) NARATION
FROM (
SELECT GLBALH_BRN_CODE, (CASE WHEN GL_TYPE='E' THEN ABS(GLBALH_BC_BAL) ELSE 0 END) EXPE, 
(CASE WHEN GL_TYPE='I' THEN ABS(GLBALH_BC_BAL) ELSE 0 END) INCOME
FROM (
SELECT GLBALH_BRN_CODE, GL_TYPE, SUM(GLBALH_BC_BAL) GLBALH_BC_BAL
FROM GLBALASONHIST GL,(
SELECT EXTGL_ACCESS_CODE, GL_TYPE
FROM GLMAST, EXTGL
WHERE GL_NUMBER=EXTGL_GL_HEAD
AND GL_TYPE IN ('I','E')) PL
WHERE PL.EXTGL_ACCESS_CODE=GL.GLBALH_GLACC_CODE
AND GL.GLBALH_ENTITY_NUM = 1
AND GL.GLBALH_ASON_DATE = '31-AUG-2016'
GROUP BY GLBALH_BRN_CODE, GL_TYPE
ORDER BY GLBALH_BRN_CODE, GL_TYPE))
GROUP BY GLBALH_BRN_CODE
ORDER BY 1)
WHERE GLBALH_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL);


SELECT * FROM(
SELECT GLBALH_BRN_CODE, SUM(EXPE) TOTAL_EXPENCE, SUM(INCOME) TOTAL_INCOME, SUM(INCOME)-SUM(EXPE) PROFIT_OR_LOSS, (CASE WHEN SUM(INCOME)-SUM(EXPE)<0 THEN 'LOSS' ELSE 'PROFIT' END) NARATION
FROM (
SELECT GLBALH_BRN_CODE, (CASE WHEN GL_TYPE='E' THEN ABS(GLBALH_BC_BAL) ELSE 0 END) EXPE, 
(CASE WHEN GL_TYPE='I' THEN ABS(GLBALH_BC_BAL) ELSE 0 END) INCOME
FROM (
SELECT GLBALH_BRN_CODE, GL_TYPE, SUM(GLBALH_BC_BAL) GLBALH_BC_BAL
FROM GLBALASONHIST GL,(
SELECT EXTGL_ACCESS_CODE, GL_TYPE
FROM GLMAST, EXTGL
WHERE GL_NUMBER=EXTGL_GL_HEAD
AND GL_TYPE IN ('I','E')) PL
WHERE PL.EXTGL_ACCESS_CODE=GL.GLBALH_GLACC_CODE
AND GL.GLBALH_ENTITY_NUM = 1
AND GL.GLBALH_ASON_DATE = '31-JUL-2016'
GROUP BY GLBALH_BRN_CODE, GL_TYPE
ORDER BY GLBALH_BRN_CODE, GL_TYPE))
GROUP BY GLBALH_BRN_CODE
ORDER BY 1)
WHERE GLBALH_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL  )
ORDER BY GLBALH_BRN_CODE


SELECT * FROM(
SELECT GLBBAL_BRANCH_CODE, SUM(EXPE) TOTAL_EXPENCE, SUM(INCOME) TOTAL_INCOME, SUM(INCOME)-SUM(EXPE) PROFIT_OR_LOSS, (CASE WHEN SUM(INCOME)-SUM(EXPE)<0 THEN 'LOSS' ELSE 'PROFIT' END) NARATION
FROM (
SELECT GLBBAL_BRANCH_CODE, (CASE WHEN GL_TYPE='E' THEN ABS(GLBBAL_AC_BAL) ELSE 0 END) EXPE, 
(CASE WHEN GL_TYPE='I' THEN ABS(GLBBAL_AC_BAL) ELSE 0 END) INCOME
FROM (
SELECT GLBBAL_BRANCH_CODE, GL_TYPE, SUM(GLBBAL_AC_BAL) GLBBAL_AC_BAL
FROM GLBBAL GL,(
SELECT EXTGL_ACCESS_CODE, GL_TYPE
FROM GLMAST, EXTGL
WHERE GL_NUMBER=EXTGL_GL_HEAD
AND GL_TYPE IN ('I','E')) PL
WHERE PL.EXTGL_ACCESS_CODE=GL.GLBBAL_GLACC_CODE
GROUP BY GLBBAL_BRANCH_CODE, GL_TYPE
ORDER BY GLBBAL_BRANCH_CODE, GL_TYPE))
GROUP BY GLBBAL_BRANCH_CODE
ORDER BY 1)
WHERE GLBBAL_BRANCH_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL  )
ORDER BY GLBBAL_BRANCH_CODE