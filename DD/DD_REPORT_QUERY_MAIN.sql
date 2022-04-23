SELECT DD.DDPOPAYDB_ADVICE_REC_DATE,
       DD.DDPOPAYDB_PAY_CAN_DUP_DATE,
       DD.DDPOPAYDB_STATUS,
       DD.DDPOPAYDB_REMIT_CODE,
       DD.DDPOPAYDB_INST_PFX,
       LPAD (DD.DDPOPAYDB_LEAF_NUM, 7, '0') DDPOPAYDB_LEAF_NUM,
       DD.DDPOPAYDB_INST_CURRENCY,
       DD.DDPOPAYDB_INST_AMT,
       DD.DDPOPAYDB_BENEF_NAME1,
       DD.DDPOPAYDB_INST_DATE,
       DD.DDPOPAYDB_ADVICE_NO
  FROM DDPOPAYDB DD,
       (SELECT DDPOPAYDB_ENTITY_NUM,
               TO_NUMBER (DDPOPAYDB_ISSUED_ON_BRN) DDPOPAYDB_ISSUED_ON_BRN,
               DDPOPAYDB_REMIT_CODE,
               DDPOPAYDB_INST_PFX,
               DDPOPAYDB_LEAF_NUM,
               DDPOPAYDB_INST_AMT
          FROM DDPOPAYDB
         WHERE     DDPOPAYDB_ENTITY_NUM = :P_ENTITY_NUMBER
               AND DDPOPAYDB_REMIT_CODE IN ('2', '9')
               AND TO_NUMBER (DDPOPAYDB_ISSUED_ON_BRN) = :P_BRANCH_CODE
               AND NVL (DDPOPAYDB_STATUS, '#') NOT IN ('C', 'R', 'E', 'L', 'D')
               AND DDPOPAYDB_ADVICE_REC_DATE <= :P_ASON_DATE
        MINUS
        SELECT DDPOPAY_ENTITY_NUM,
               DDPOPAY_BRN_CODE,
               DDPOPAY_REMIT_CODE,
               DDPOPAY_INST_PFX,
               DDPOPAY_INST_NUM,
               DDPOPAY_INST_AMT
          FROM DDPOPAY A, DDPOPAYDB B
         WHERE     A.DDPOPAY_INST_NUM = B.DDPOPAYDB_LEAF_NUM
               AND A.DDPOPAY_INST_PFX = B.DDPOPAYDB_INST_PFX
               AND A.DDPOPAY_REMIT_CODE = B.DDPOPAYDB_REMIT_CODE
               AND DDPOPAY_REMIT_CODE IN ('2', '9')
               AND TO_NUMBER( DDPOPAYDB_ISSUED_ON_BRN) = :P_BRANCH_CODE
               AND TO_NUMBER( DDPOPAY_BRN_CODE) = :P_BRANCH_CODE
               AND NVL (DDPOPAYDB_STATUS, '#') NOT IN ('C', 'R', 'E', 'L', 'D')
               AND DDPOPAY_REJ_ON IS NULL
               AND DDPOPAY_PAY_DATE <= :P_ASON_DATE) OUTS
 WHERE     OUTS.DDPOPAYDB_ENTITY_NUM = DD.DDPOPAYDB_ENTITY_NUM
       AND OUTS.DDPOPAYDB_REMIT_CODE = DD.DDPOPAYDB_REMIT_CODE
       AND OUTS.DDPOPAYDB_INST_PFX = DD.DDPOPAYDB_INST_PFX
       AND OUTS.DDPOPAYDB_LEAF_NUM = DD.DDPOPAYDB_LEAF_NUM
       AND OUTS.DDPOPAYDB_ISSUED_ON_BRN = DD.DDPOPAYDB_ISSUED_ON_BRN  