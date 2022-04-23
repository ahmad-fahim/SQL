SELECT BRANCH_LIST, (REGEXP_COUNT (BRANCH_LIST, ',') + 1) AS cnt
  FROM (SELECT LISTAGG (BRANCH_CODE, ',') WITHIN GROUP (ORDER BY BRANCH_CODE)
                  AS BRANCH_LIST
          FROM (SELECT BRANCH_CODE
                  FROM (SELECT DISTINCT BRANCH_CODE
                          FROM MIG_DETAIL
                         WHERE     MIG_END_DATE <= :1
                               AND BRANCH_CODE IN (    SELECT MBRN_CODE
                                                         FROM MBRN
                                                   START WITH MBRN_CODE = :2
                                                   CONNECT BY PRIOR MBRN_CODE =
                                                                 MBRN_PARENT_ADMIN_CODE)
                        MINUS
                        SELECT DISTINCT RPT_BRN_CODE
                          FROM STATMENTOFAFFAIRS
                         WHERE RPT_ENTRY_DATE = :3)));