SELECT A.DDPOPAYDB_ENTITY_NUM,
       B.DDPOPAYDB_ISSUED_BRN,
       (SELECT MIG_END_DATE
          FROM MIG_DETAIL
         WHERE BRANCH_CODE = TO_NUMBER(B.DDPOPAYDB_ISSUED_BRN)) MIG_DATE_ISSUDE,
       B.DDPOPAYDB_INST_DATE,
       TO_NUMBER(A.DDPOPAYDB_ISSUED_ON_BRN) DDPOPAYDB_ISSUED_ON_BRN,
       (SELECT MIG_END_DATE
          FROM MIG_DETAIL
         WHERE BRANCH_CODE = TO_NUMBER(A.DDPOPAYDB_ISSUED_ON_BRN)) MIG_DATE_ISSUDE_ON,
       B.DDPOPAYDB_ADVICE_REC_DATE,
       A.DDPOPAYDB_INST_PFX,
       A.DDPOPAYDB_LEAF_NUM,
       A.DDPOPAYDB_INST_AMT,
       A.DDPOPAYDB_REMIT_CODE
  FROM ( --- CORE TO NON CORE ALL ISSUED DD
        (SELECT DDPOPAYDB_ENTITY_NUM,
                TO_NUMBER(DDPOPAYDB_ISSUED_ON_BRN) DDPOPAYDB_ISSUED_ON_BRN,
                DDPOPAYDB_INST_PFX,
                DDPOPAYDB_LEAF_NUM,
                DDPOPAYDB_INST_AMT,
                DDPOPAYDB_REMIT_CODE
           FROM DDPOPAYDB D, MIG_DETAIL
          WHERE DDPOPAYDB_ISSUED_BRN = BRANCH_CODE
            AND DDPOPAYDB_INST_DATE >= MIG_END_DATE
            AND DDPOPAYDB_REMIT_CODE IN
                ('2', '3', '9', 'DD', 'DDEX', 'DDSBG', 'GDB', 'DDEXR')
            AND EXISTS
          (SELECT 1
                   FROM MIG_DETAIL
                  WHERE MIG_DETAIL.BRANCH_CODE = D.DDPOPAYDB_ISSUED_ON_BRN)
            AND DDPOPAYDB_INST_DATE <
                (SELECT MAX(MIG_END_DATE)
                   FROM MIG_DETAIL
                  WHERE MIG_DETAIL.BRANCH_CODE = D.DDPOPAYDB_ISSUED_ON_BRN)
         MINUS
         ------ CORE TO NON CORE ALREDY RECIVE ADVICE 
         SELECT DAP.DDADVPART_ENTITY_NUM,
                DDADVPART_BRN_CODE,
                DAP.DDADVPART_LEAF_PFX,
                DAP.DDADVPART_LEAF_NUMBER,
                DDADVPARTDTL_INST_AMT,
                DDADVPARTDTL_REM_CODE
           FROM DDADVPART DAP, DDADVPARTDTL DD
          WHERE DD.DDADVPARTDTL_ENTITY_NUM = DAP.DDADVPART_ENTITY_NUM
            AND DD.DDADVPARTDTL_BRN_CODE = DAP.DDADVPART_BRN_CODE
            AND DD.DDADVPARTDTL_LEAF_PFX = DAP.DDADVPART_LEAF_PFX
            AND DD.DDADVPARTDTL_LEAF_NUMBER = DAP.DDADVPART_LEAF_NUMBER
            AND DDADVPART_AUTH_ON IS NOT NULL
            AND DDADVPART_REJ_ON IS NULL) MINUS
        ( ---- MIGRATION DATA 
         SELECT DDPOISSDTL_ENTITY_NUM,
                 DDPOISS_BRN_CODE DDPOPAYDB_ISSUED_ON_BRN,
                 DDPOISSDTL_INST_NUM_PFX,
                 DDPOISSDTL_INST_NUM,
                 DDPOISSDTL_INST_AMT,
                 DDPOISS_REMIT_CODE
           FROM DDPOISS, DDPOISSDTL
          WHERE DDPOISSDTL_DAY_SL = DDPOISS_DAY_SL
            AND DDPOISSDTL_BRN_CODE = DDPOISS_BRN_CODE
            AND DDPOISS_ENTD_BY = 'MIG'
            AND DDPOISS_REMIT_CODE IN ('2'))) A,
       DDPOPAYDB B
 WHERE A.DDPOPAYDB_ENTITY_NUM = B.DDPOPAYDB_ENTITY_NUM
   AND A.DDPOPAYDB_ISSUED_ON_BRN = B.DDPOPAYDB_ISSUED_ON_BRN
   AND A.DDPOPAYDB_INST_PFX = B.DDPOPAYDB_INST_PFX
   AND A.DDPOPAYDB_LEAF_NUM = B.DDPOPAYDB_LEAF_NUM
   AND A.DDPOPAYDB_INST_AMT = B.DDPOPAYDB_INST_AMT;


-------------------------------------------------- Update ---------------------------------

UPDATE DDPOPAYDB
   SET DDPOPAYDB_ADVICE_REC_DATE = NULL
 WHERE DDPOPAYDB_ENTITY_NUM || DDPOPAYDB_ISSUED_BRN || DDPOPAYDB_INST_PFX ||
       DDPOPAYDB_LEAF_NUM || DDPOPAYDB_INST_AMT || DDPOPAYDB_INST_DATE ||
       DDPOPAYDB_REMIT_CODE IN
       (SELECT DDPOPAYDB_ENTITY_NUM || DDPOPAYDB_ISSUED_BRN ||
               DDPOPAYDB_INST_PFX || DDPOPAYDB_LEAF_NUM ||
               DDPOPAYDB_INST_AMT || DDPOPAYDB_INST_DATE ||
               DDPOPAYDB_REMIT_CODE
          FROM (SELECT A.DDPOPAYDB_ENTITY_NUM,
                       B.DDPOPAYDB_ISSUED_BRN,
                       (SELECT MIG_END_DATE
                          FROM MIG_DETAIL
                         WHERE BRANCH_CODE = TO_NUMBER(B.DDPOPAYDB_ISSUED_BRN)) MIG_DATE_ISSUDE,
                       B.DDPOPAYDB_INST_DATE,
                       TO_NUMBER(A.DDPOPAYDB_ISSUED_ON_BRN) DDPOPAYDB_ISSUED_ON_BRN,
                       (SELECT MIG_END_DATE
                          FROM MIG_DETAIL
                         WHERE BRANCH_CODE =
                               TO_NUMBER(A.DDPOPAYDB_ISSUED_ON_BRN)) MIG_DATE_ISSUDE_ON,
                       B.DDPOPAYDB_ADVICE_REC_DATE,
                       A.DDPOPAYDB_INST_PFX,
                       A.DDPOPAYDB_LEAF_NUM,
                       A.DDPOPAYDB_INST_AMT,
                       A.DDPOPAYDB_REMIT_CODE
                  FROM ( --- CORE TO NON CORE ALL ISSUED DD
                        (SELECT DDPOPAYDB_ENTITY_NUM,
                                TO_NUMBER(DDPOPAYDB_ISSUED_ON_BRN) DDPOPAYDB_ISSUED_ON_BRN,
                                DDPOPAYDB_INST_PFX,
                                DDPOPAYDB_LEAF_NUM,
                                DDPOPAYDB_INST_AMT,
                                DDPOPAYDB_REMIT_CODE
                           FROM DDPOPAYDB D, MIG_DETAIL
                          WHERE DDPOPAYDB_ISSUED_BRN = BRANCH_CODE
                            AND DDPOPAYDB_INST_DATE >= MIG_END_DATE
                            AND DDPOPAYDB_REMIT_CODE IN
                                ('2',
                                 '3',
                                 '9',
                                 'DD',
                                 'DDEX',
                                 'DDSBG',
                                 'GDB',
                                 'DDEXR')
                            AND EXISTS
                          (SELECT 1
                                   FROM MIG_DETAIL
                                  WHERE MIG_DETAIL.BRANCH_CODE =
                                        D.DDPOPAYDB_ISSUED_ON_BRN)
                            AND DDPOPAYDB_INST_DATE <
                                (SELECT MAX(MIG_END_DATE)
                                   FROM MIG_DETAIL
                                  WHERE MIG_DETAIL.BRANCH_CODE =
                                        D.DDPOPAYDB_ISSUED_ON_BRN)
                         MINUS
                         ------ CORE TO NON CORE ALREDY RECIVE ADVICE 
                         SELECT DAP.DDADVPART_ENTITY_NUM,
                                DDADVPART_BRN_CODE,
                                DAP.DDADVPART_LEAF_PFX,
                                DAP.DDADVPART_LEAF_NUMBER,
                                DDADVPARTDTL_INST_AMT,
                                DDADVPARTDTL_REM_CODE
                           FROM DDADVPART DAP, DDADVPARTDTL DD
                          WHERE DD.DDADVPARTDTL_ENTITY_NUM =
                                DAP.DDADVPART_ENTITY_NUM
                            AND DD.DDADVPARTDTL_BRN_CODE =
                                DAP.DDADVPART_BRN_CODE
                            AND DD.DDADVPARTDTL_LEAF_PFX =
                                DAP.DDADVPART_LEAF_PFX
                            AND DD.DDADVPARTDTL_LEAF_NUMBER =
                                DAP.DDADVPART_LEAF_NUMBER
                            AND DDADVPART_AUTH_ON IS NOT NULL
                            AND DDADVPART_REJ_ON IS NULL) MINUS
                        ( ---- MIGRATION DATA 
                         SELECT DDPOISSDTL_ENTITY_NUM,
                                 DDPOISS_BRN_CODE DDPOPAYDB_ISSUED_ON_BRN,
                                 DDPOISSDTL_INST_NUM_PFX,
                                 DDPOISSDTL_INST_NUM,
                                 DDPOISSDTL_INST_AMT,
                                 DDPOISS_REMIT_CODE
                           FROM DDPOISS, DDPOISSDTL
                          WHERE DDPOISSDTL_DAY_SL = DDPOISS_DAY_SL
                            AND DDPOISSDTL_BRN_CODE = DDPOISS_BRN_CODE
                            AND DDPOISS_ENTD_BY = 'MIG'
                            AND DDPOISS_REMIT_CODE IN ('2'))) A,
                       DDPOPAYDB B
                 WHERE A.DDPOPAYDB_ENTITY_NUM = B.DDPOPAYDB_ENTITY_NUM
                   AND A.DDPOPAYDB_ISSUED_ON_BRN = B.DDPOPAYDB_ISSUED_ON_BRN
                   AND A.DDPOPAYDB_INST_PFX = B.DDPOPAYDB_INST_PFX
                   AND A.DDPOPAYDB_LEAF_NUM = B.DDPOPAYDB_LEAF_NUM
                   AND A.DDPOPAYDB_INST_AMT = B.DDPOPAYDB_INST_AMT));
