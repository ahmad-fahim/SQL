/*

select *
  from mig_nomreg
 where (mig_nomreg.nomreg_ac_num, mig_nomreg.nomreg_cont_num,
        TO_CHAR(mig_nomreg.NOMREG_REG_DATE, 'YYYY'),
        mig_nomreg.nomreg_dtl_sl) in 
  (select n.nomreg_ac_num,
         n.nomreg_cont_num,
         TO_CHAR(n.NOMREG_REG_DATE, 'YYYY'),
         n.nomreg_dtl_sl
          from mig_nomreg n
         group by n.nomreg_ac_num,
            n.nomreg_cont_num,
            TO_CHAR(n.NOMREG_REG_DATE, 'YYYY'),
            n.nomreg_dtl_sl
        having count(*) > 1) for update ;
*/
--  NOMREG_AC_NUM, NOMREG_CONT_NUM, NOMREG_REG_YEAR, NOMREG_REG_SL

INSERT INTO NOMREG
   SELECT A.ACNTOTN_ENTITY_NUM NOMREG_ENTITY_NUM,
          A.ACNTOTN_INTERNAL_ACNUM NOMREG_AC_NUM,
          NVL (
             (SELECT PBDCONT_CONT_NUM
                FROM PBDCONTRACT
               WHERE     PBDCONT_ENTITY_NUM = 1
                     AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                     AND PBDCONT_ENTD_BY = 'MIG'),
             0)
             NOMREG_CONT_NUM,
          TO_CHAR (N.NOMREG_REG_DATE, 'YYYY') NOMREG_REG_YEAR,
          ROW_NUMBER() OVER (PARTITION BY A.ACNTOTN_INTERNAL_ACNUM ORDER BY A.ACNTOTN_INTERNAL_ACNUM)   NOMREG_REG_SL,
          N.NOMREG_REG_DATE NOMREG_REG_DATE,
          NULL NOMREG_MANUAL_REF_NUM,
          NULL NOMREG_CUST_LTR_REF_DATE,
          'MIG' NOMREG_ENTD_BY,
          '20-APR-2017' NOMREG_ENTD_ON,
          NULL NOMREG_LAST_MOD_BY,
          NULL NOMREG_LAST_MOD_ON,
          'MIG' NOMREG_AUTH_BY,
          '20-APR-2017' NOMREG_AUTH_ON,
          NULL NOMREG_CANC_ON,
          NULL TBA_MAIN_KEY,
          NULL NOMREG_ADDR5,
          NULL NOMREG_ADDR4,
          NULL NOMREG_ADDR3,
          NULL NOMREG_ADDR2,
          NULL NOMREG_ADDR1,
          NULL NOMREG_RELATIONSHIP,
          NULL NOMREG_CUST_CODE,
          NULL NOMREG_NOMINEE_NAME,
          NULL NOMREG_DOB,
          NULL NOMREG_GUAR_CUST_CODE,
          NULL NOMREG_GUAR_CUST_NAME,
          NULL NOMREG_NATURE_OF_GUAR
     FROM MIG_NOMREG N, ACNTOTN A, ACNTS
    WHERE     A.ACNTOTN_OLD_ACNT_NUM = N.NOMREG_AC_NUM
          AND A.ACNTOTN_INTERNAL_ACNUM NOT IN
                 (SELECT NOMREG_AC_NUM FROM NOMREG)
          AND ACNTS_INTERNAL_ACNUM = A.ACNTOTN_INTERNAL_ACNUM
          AND ACNTS_CLOSURE_DATE IS NULL
          AND ACNTS_ENTITY_NUM = 1

INSERT INTO NOMREGDTL
  SELECT 1 NOMREGDTL_ENTITY_NUM,
         A.ACNTOTN_INTERNAL_ACNUM NOMREGDTL_AC_NUM,
         NVL (
             (SELECT PBDCONT_CONT_NUM
                FROM PBDCONTRACT
               WHERE     PBDCONT_ENTITY_NUM = 1
                     AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                     AND PBDCONT_ENTD_BY = 'MIG'),
             0) NOMREGDTL_CONT_NUM,
         TO_CHAR(N.NOMREG_REG_DATE, 'YYYY') NOMREGDTL_REG_YEAR,
         ROW_NUMBER() OVER (PARTITION BY A.ACNTOTN_INTERNAL_ACNUM ORDER BY A.ACNTOTN_INTERNAL_ACNUM) NOMREGDTL_REG_SL,
         ROW_NUMBER() OVER (PARTITION BY A.ACNTOTN_INTERNAL_ACNUM ORDER BY A.ACNTOTN_INTERNAL_ACNUM) NOMREGDTL_DTL_SL,
         NULL NOMREGDTL_CUST_CODE,
         N.NOMREG_NOMINEE_NAME NOMREGDTL_NOMINEE_NAME,
         NULL NOMREGDTL_DOB,
         N.NOMREG_ALOTTED_PERCENTAGE NOMREGDTL_ALOTTED_PERCENTAGE,
         NULL NOMREGDTL_GUAR_CUST_CODE,
         NULL NOMREGDTL_GUAR_CUST_NAME,
         NULL NOMREGDTL_NATURE_OF_GUAR,
         NULL NOMREGDTL_RELATIONSHIP,
         N.NOMREG_ADDR NOMREGDTL_ADDR
    FROM MIG_NOMREG N, ACNTOTN A, ACNTS
   WHERE A.ACNTOTN_OLD_ACNT_NUM = N.NOMREG_AC_NUM
   AND ACNTS_INTERNAL_ACNUM = A.ACNTOTN_INTERNAL_ACNUM
          AND ACNTS_CLOSURE_DATE IS NULL
          AND ACNTS_ENTITY_NUM = 1
          AND A.ACNTOTN_INTERNAL_ACNUM NOT IN
                 (SELECT NOMREGDTL_AC_NUM FROM NOMREGDTL)
