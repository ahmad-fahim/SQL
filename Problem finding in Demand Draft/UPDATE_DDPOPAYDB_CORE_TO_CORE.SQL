UPDATE DDPOPAYDB
   SET DDPOPAYDB_ADVICE_REC_DATE = DDPOPAYDB_INST_DATE
 WHERE DDPOPAYDB_ENTITY_NUM || DDPOPAYDB_ISSUED_BRN || DDPOPAYDB_INST_PFX ||
       DDPOPAYDB_LEAF_NUM || DDPOPAYDB_INST_AMT || DDPOPAYDB_INST_DATE ||
       DDPOPAYDB_REMIT_CODE IN
       (SELECT DDPOPAYDB_ENTITY_NUM || DDPOPAYDB_ISSUED_BRN ||
               DDPOPAYDB_INST_PFX || DDPOPAYDB_LEAF_NUM ||
               DDPOPAYDB_INST_AMT || DDPOPAYDB_INST_DATE ||
               DDPOPAYDB_REMIT_CODE
          FROM (SELECT DDPOPAYDB_ENTITY_NUM,
                       DDPOPAYDB_ISSUED_BRN,
                       DDPOPAYDB_ISSUED_ON_BRN,
                       BRANCH_CODE,
                       MIN(MIG_END_DATE) OVER(PARTITION BY DDPOPAYDB_ISSUED_ON_BRN) ISSUED_ON_BRN_MIGDATE,
                       MIG_END_DATE ISSUED_BRN_MIGDATE,
                       DDPOPAYDB_INST_DATE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM,
                       DDPOPAYDB_INST_AMT,
                       DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_ISSUED_ON_BRN
                  FROM DDPOPAYDB D, MIG_DETAIL M
                 WHERE DDPOPAYDB_ISSUED_BRN = BRANCH_CODE
                   AND EXISTS
                 (SELECT 1
                          FROM MIG_DETAIL
                         WHERE MIG_DETAIL.BRANCH_CODE = D.DDPOPAYDB_ISSUED_BRN)
                   AND EXISTS (SELECT 1
                          FROM MIG_DETAIL
                         WHERE MIG_DETAIL.BRANCH_CODE =
                               D.DDPOPAYDB_ISSUED_ON_BRN)
                   AND EXISTS
                 (SELECT 1
                          FROM MIG_DETAIL
                         WHERE MIG_DETAIL.MIG_END_DATE <=
                               D.DDPOPAYDB_INST_DATE
                           AND (MIG_DETAIL.BRANCH_CODE =
                               D.DDPOPAYDB_ISSUED_ON_BRN OR
                               MIG_DETAIL.BRANCH_CODE =
                               D.DDPOPAYDB_ISSUED_BRN))
                   AND DDPOPAYDB_REMIT_CODE IN
                       ('2', '3', '9', 'DD', 'DDEX', 'DDSBG', 'GDB', 'DDEXR')
                   AND DDPOPAYDB_ADVICE_REC_DATE IS NULL
                   AND DDPOPAYDB_INST_DATE >
                       (SELECT MAX(MIG_END_DATE)
                          FROM MIG_DETAIL
                         WHERE BRANCH_CODE IN
                               (DDPOPAYDB_ISSUED_ON_BRN, DDPOPAYDB_ISSUED_BRN))
                   AND DDPOPAYDB_STATUS NOT IN( 'E', 'C' )
                 ORDER BY DDPOPAYDB_ISSUED_BRN, DDPOPAYDB_INST_DATE))
