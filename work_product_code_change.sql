CREATE OR REPLACE PROCEDURE SP_GLMAST_UPDATE_TO_0 (
P_NEW_GL IN VARCHAR2,
P_PREVIOUS_GL IN VARCHAR2
 ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   UPDATE GLMAST
      SET GL_CUST_AC_ALLOWED = 0
    WHERE GL_NUMBER IN (SELECT EXTGL_GL_HEAD
                          FROM EXTGL
                         WHERE EXTGL_ACCESS_CODE = P_NEW_GL
                        UNION ALL
                        SELECT EXTGL_GL_HEAD
                          FROM EXTGL
                         WHERE EXTGL_ACCESS_CODE = P_PREVIOUS_GL);

   COMMIT;
END;
/





CREATE OR REPLACE PROCEDURE SP_GLMAST_UPDATE_TO_1 (
P_NEW_GL IN VARCHAR2,
P_PREVIOUS_GL IN VARCHAR2
 ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   UPDATE GLMAST
      SET GL_CUST_AC_ALLOWED = 1
    WHERE GL_NUMBER IN (SELECT EXTGL_GL_HEAD
                          FROM EXTGL
                         WHERE EXTGL_ACCESS_CODE = P_NEW_GL
                        UNION ALL
                        SELECT EXTGL_GL_HEAD
                          FROM EXTGL
                         WHERE EXTGL_ACCESS_CODE = P_PREVIOUS_GL);

   COMMIT;
END;
/







CREATE OR REPLACE PROCEDURE SP_PRODUCT_CODE_CHANGE (
   P_BRANCH_CODE                 IN     NUMBER,
   P_ACCTUAL_ACCOUNT_NUMBER      IN     VARCHAR2,
   P_PREVIOUS_ACCOUNT_TYPE       IN     VARCHAR2,
   P_NEW_ACCOUNT_TYPE            IN     VARCHAR2,
   P_PREVIOUS_ACCOUNT_SUB_TYPE   IN     VARCHAR2,
   P_NEW_ACCOUNT_SUB_TYPE        IN     VARCHAR2,
   P_PREVIOUS_PRODUCT_CODE       IN     NUMBER,
   P_NEW_PRODUCT_CODE            IN     NUMBER,
   P_NARRATION                   IN     VARCHAR2,
   W_BATCH                          OUT NUMBER,
   W_PREVIOUS_ACCRUAL_BATCH         OUT NUMBER,
   W_NEW_ACCRUAL_BATCH              OUT NUMBER,
   W_ERR                            OUT VARCHAR2)
IS
   W_SQL                           VARCHAR2 (3000);
   W_BRANCH_CODE                   NUMBER (5) := P_BRANCH_CODE;
   W_ACCTUAL_ACCOUNT_NUMBER        VARCHAR2 (25) := P_ACCTUAL_ACCOUNT_NUMBER;
   W_PREVIOUS_ACCOUNT_TYPE         VARCHAR2 (5) := P_PREVIOUS_ACCOUNT_TYPE;
   W_NEW_ACCOUNT_TYPE              VARCHAR2 (5) := P_NEW_ACCOUNT_TYPE;
   W_PREVIOUS_ACCOUNT_SUB_TYPE     VARCHAR2 (5) := P_PREVIOUS_ACCOUNT_SUB_TYPE;
   W_NEW_ACCOUNT_SUB_TYPE          VARCHAR2 (5) := P_NEW_ACCOUNT_SUB_TYPE;
   W_PREVIOUS_PRODUCT_CODE         NUMBER (4) := P_PREVIOUS_PRODUCT_CODE;
   W_NEW_PRODUCT_CODE              NUMBER (4) := P_NEW_PRODUCT_CODE;
   W_NARRATION                     VARCHAR2 (200) := P_NARRATION;
   W_INTERNAL_ACCOUNT_NUMBER       NUMBER (14);
   W_SUBTYPE_REQURED               VARCHAR2 (1);
   W_ACSUB_ACTYPE_CODE             VARCHAR2 (5);
   W_PREVIOUS_GL                   VARCHAR2 (15);
   W_NEW_GL                        VARCHAR2 (15);

   W_PREVIOUS_ACCRUAL_GL           VARCHAR2 (15);
   W_PREVIOUS_INCOME_GL            VARCHAR2 (15);

   W_NEW_ACCRUAL_GL                VARCHAR2 (15);
   W_NEW_INCOME_GL                 VARCHAR2 (15);
   W_ACSEQ_NUMBER                  NUMBER (6);
   W_PRE_PROD_AC_NUMBER            NUMBER (20);
   W_NEW_PROD_AC_NUMBER            NUMBER (20);

   W_CURR_BAL                      NUMBER (18, 3);

   W_TOT_IA_FROM_LOANIA            NUMBER (18, 3);
   W_TOT_IA_FROM_LOANIAMRR         NUMBER (18, 3);
   W_LATEST_ACC_DATE_FROM_LOANIA   DATE;
   W_TOT_IA                        NUMBER (18, 3);
   W_COUNTER                       NUMBER;
   W_CBD                           DATE;
BEGIN
   IF W_PREVIOUS_ACCOUNT_SUB_TYPE IS NULL
   THEN
      W_PREVIOUS_ACCOUNT_SUB_TYPE := '0';
   END IF;

   IF W_NEW_ACCOUNT_SUB_TYPE IS NULL
   THEN
      W_NEW_ACCOUNT_SUB_TYPE := '0';
   END IF;

  <<ACCOUNT_VALIDATE>>
   BEGIN
      SELECT IACLINK_INTERNAL_ACNUM
        INTO W_INTERNAL_ACCOUNT_NUMBER
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = 1
             AND IACLINK_ACTUAL_ACNUM = W_ACCTUAL_ACCOUNT_NUMBER
             AND IACLINK_BRN_CODE = W_BRANCH_CODE;


   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR :=
            'INVALID ACCOUNT NUMBER OR THIS ACCOUNT NUMBER IS NOT ASSIGNED IN THIS BRANCH';
         RETURN;
   END ACCOUNT_VALIDATE;

  <<ACCOUNT_TYPE_VALIDATE>>
   BEGIN
      SELECT ACNTS_INTERNAL_ACNUM
        INTO W_INTERNAL_ACCOUNT_NUMBER
        FROM ACNTS A
       WHERE     ACNTS_ENTITY_NUM = 1
             AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
             AND ACNTS_AC_TYPE = W_PREVIOUS_ACCOUNT_TYPE;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR := 'THE ACCOUNT TYPE IS NOT ASSIGNED IN THIS ACCOUNT';
         RETURN;
   END ACCOUNT_TYPE_VALIDATE;

  <<ACCOUNT_SUBTYPE_VALIDATE>>
   BEGIN
      SELECT ACNTS_INTERNAL_ACNUM
        INTO W_INTERNAL_ACCOUNT_NUMBER
        FROM ACNTS A
       WHERE     ACNTS_ENTITY_NUM = 1
             AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
             AND ACNTS_AC_SUB_TYPE = W_PREVIOUS_ACCOUNT_SUB_TYPE;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR := 'THE ACCOUNT SUB TYPE IS NOT ASSIGNED IN THIS ACCOUNT';

         RETURN;
   END ACCOUNT_SUBTYPE_VALIDATE;

  <<ACCOUNT_PRODUCT_VALIDATE>>
   BEGIN
      SELECT ACNTS_INTERNAL_ACNUM
        INTO W_INTERNAL_ACCOUNT_NUMBER
        FROM ACNTS A
       WHERE     ACNTS_ENTITY_NUM = 1
             AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
             AND ACNTS_PROD_CODE = W_PREVIOUS_PRODUCT_CODE;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR := 'THE PRODUCT CODE IS NOT ASSIGNED IN THIS ACCOUNT';

         RETURN;
   END ACCOUNT_PRODUCT_VALIDATE;

  <<NEW_ACCOUNT_INFO_VALIDATE>>
   BEGIN
      SELECT ACTYPE_SUB_TYPE_REQD
        INTO W_SUBTYPE_REQURED
        FROM ACTYPES A
       WHERE     ACTYPE_CODE = W_NEW_ACCOUNT_TYPE
             AND ACTYPE_PROD_CODE = W_NEW_PRODUCT_CODE;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR := 'THE PRODUCT CODE IS NOT ASSIGNED IN THIS ACCOUNT TYPE';
         RETURN;
   END NEW_ACCOUNT_INFO_VALIDATE;

   IF W_SUBTYPE_REQURED = '1' AND W_NEW_ACCOUNT_SUB_TYPE = '0'
   THEN
      W_ERR := 'SUBTYPE IS REQUIRED. BUT IT CAN NOT BE EMPTY OR ZERO';
      RETURN;
   END IF;

   IF W_SUBTYPE_REQURED <> '0'
   THEN
     <<NEW_ACSUBTYPE_VALIDATE>>
      BEGIN
         SELECT ACSUB_ACTYPE_CODE
           INTO W_NEW_ACCOUNT_TYPE
           FROM ACSUBTYPES A
          WHERE     ACSUB_ACTYPE_CODE = W_NEW_ACCOUNT_TYPE
                AND ACSUB_SUBTYPE_CODE = W_NEW_ACCOUNT_SUB_TYPE;

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_ERR :=
               'THE ACCOUNT SUBTYPE IS NOT ASSIGNED IN THIS ACCOUNT TYPE';

            RETURN;
      END NEW_ACSUBTYPE_VALIDATE;
   END IF;

  <<NEW_ACTYPE_SUBTYPE_VALIDATION>>
   BEGIN
      IF W_NEW_ACCOUNT_SUB_TYPE <> '0'
      THEN
         SELECT ACSUB_ACTYPE_CODE
           INTO W_ACSUB_ACTYPE_CODE
           FROM ACSUBTYPES
          WHERE     ACSUB_ACTYPE_CODE = W_NEW_ACCOUNT_TYPE
                AND ACSUB_SUBTYPE_CODE = W_NEW_ACCOUNT_SUB_TYPE;

      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERR :=
            'THE NEW ACCOUNT SUBTYPE IS NOT ASSIGNED IN THIS ACCOUNT TYPE';

         RETURN;
   END NEW_ACTYPE_SUBTYPE_VALIDATION;


  <<LOAN_AC_DETAIL_INFO>>
   BEGIN
      SELECT PRODUCT_GLACC_CODE
        INTO W_PREVIOUS_GL
        FROM PRODUCTS
       WHERE PRODUCT_CODE = W_PREVIOUS_PRODUCT_CODE;

      SELECT PRODUCT_GLACC_CODE
        INTO W_NEW_GL
        FROM PRODUCTS
       WHERE PRODUCT_CODE = W_NEW_PRODUCT_CODE;

      SELECT LNPRDAC_INT_ACCR_GL, LNPRDAC_INT_INCOME_GL
        INTO W_PREVIOUS_ACCRUAL_GL, W_PREVIOUS_INCOME_GL
        FROM LNPRODACPM
       WHERE LNPRDAC_PROD_CODE = W_PREVIOUS_PRODUCT_CODE;

      SELECT LNPRDAC_INT_ACCR_GL, LNPRDAC_INT_INCOME_GL
        INTO W_NEW_ACCRUAL_GL, W_NEW_INCOME_GL
        FROM LNPRODACPM
       WHERE LNPRDAC_PROD_CODE = W_NEW_PRODUCT_CODE;


   END LOAN_AC_DETAIL_INFO;

  -------------------- ACNTLINK ---------------------

  <<UPDATE_ACNTLINK>>
   BEGIN
      UPDATE ACNTLINK
         SET ACNTLINK_AC_SEQ_NUM =
                W_NEW_PRODUCT_CODE || SUBSTR (ACNTLINK_AC_SEQ_NUM, 5, 2),
             ACNTLINK_ACCOUNT_NUMBER =
                   SUBSTR (ACNTLINK_ACCOUNT_NUMBER, 1, 17)
                || W_NEW_PRODUCT_CODE
                || SUBSTR (ACNTLINK_ACCOUNT_NUMBER, 22, 2)
       WHERE     ACNTLINK_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
             AND ACNTLINK_ENTITY_NUM = 1;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE ACNTLINK
            SET ACNTLINK_AC_SEQ_NUM =
                        W_NEW_PRODUCT_CODE
                     || SUBSTR (ACNTLINK_AC_SEQ_NUM, 5, 1)
                     || SUBSTR (ACNTLINK_AC_SEQ_NUM, 6, 1)
                   + 1,
                ACNTLINK_ACCOUNT_NUMBER =
                      SUBSTR (ACNTLINK_ACCOUNT_NUMBER, 1, 17)
                   || W_NEW_PRODUCT_CODE
                   || SUBSTR (ACNTLINK_ACCOUNT_NUMBER, 22, 2)
          WHERE     ACNTLINK_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
                AND ACNTLINK_ENTITY_NUM = 1;
   END UPDATE_ACNTLINK;

   SELECT ACNTLINK_AC_SEQ_NUM
     INTO W_ACSEQ_NUMBER
     FROM ACNTLINK
    WHERE     ACNTLINK_ENTITY_NUM = 1
          AND ACNTLINK_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER;

   ------------------ IACLINK -----------------------------

   UPDATE IACLINK
      SET IACLINK_ACCOUNT_NUMBER =
                SUBSTR (IACLINK_ACCOUNT_NUMBER, 1, 17)
             || W_NEW_PRODUCT_CODE
             || SUBSTR (IACLINK_ACCOUNT_NUMBER, 22, 2),
          IACLINK_PROD_CODE = W_NEW_PRODUCT_CODE,
          IACLINK_AC_SEQ_NUM = W_ACSEQ_NUMBER
    WHERE     IACLINK_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
          AND IACLINK_ENTITY_NUM = 1;

   UPDATE ACNTS
      SET ACNTS_ACCOUNT_NUMBER =
                SUBSTR (ACNTS_ACCOUNT_NUMBER, 1, 17)
             || W_NEW_PRODUCT_CODE
             || SUBSTR (ACNTS_ACCOUNT_NUMBER, 22, 2),
          ACNTS_PROD_CODE = W_NEW_PRODUCT_CODE,
          ACNTS_AC_TYPE = W_NEW_ACCOUNT_TYPE,
          ACNTS_AC_SUB_TYPE = W_NEW_ACCOUNT_SUB_TYPE,
          ACNTS_GLACC_CODE = W_NEW_GL,
          ACNTS_AC_SEQ_NUM = W_ACSEQ_NUMBER
    WHERE     ACNTS_ENTITY_NUM = 1
          AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER;



   UPDATE LIMITLINE
      SET LMTLINE_PROD_CODE = W_NEW_PRODUCT_CODE
    WHERE (LMTLINE_ENTITY_NUM, LMTLINE_CLIENT_CODE, LMTLINE_NUM) IN
             (SELECT ACASLLDTL_ENTITY_NUM,
                     ACASLLDTL_CLIENT_NUM,
                     ACASLLDTL_LIMIT_LINE_NUM
                FROM ACASLLDTL
               WHERE     ACASLLDTL_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
                     AND ACASLLDTL_ENTITY_NUM = 1);



  <<ACSEQGEN_UPDATE>>
   BEGIN
      UPDATE ACSEQGEN
         SET ACSEQGEN_LAST_NUM_USED = ACSEQGEN_LAST_NUM_USED - 1
       WHERE     ACSEQGEN_BRN_CODE = W_BRANCH_CODE
             AND ACSEQGEN_PROD_CODE = W_PREVIOUS_PRODUCT_CODE;

      SELECT ACSEQGEN_LAST_NUM_USED
        INTO W_NEW_PROD_AC_NUMBER
        FROM ACSEQGEN
       WHERE     ACSEQGEN_BRN_CODE = W_BRANCH_CODE
             AND ACSEQGEN_PROD_CODE = W_NEW_PRODUCT_CODE
             AND ACSEQGEN_ENTITY_NUM = 1
             AND ACSEQGEN_CIF_NUMBER = 0
             AND ACSEQGEN_SEQ_NUMBER = 0;

      UPDATE ACSEQGEN
         SET ACSEQGEN_LAST_NUM_USED = ACSEQGEN_LAST_NUM_USED + 1
       WHERE     ACSEQGEN_BRN_CODE = W_BRANCH_CODE
             AND ACSEQGEN_PROD_CODE = W_NEW_PRODUCT_CODE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         INSERT INTO ACSEQGEN (ACSEQGEN_ENTITY_NUM,
                               ACSEQGEN_BRN_CODE,
                               ACSEQGEN_CIF_NUMBER,
                               ACSEQGEN_PROD_CODE,
                               ACSEQGEN_SEQ_NUMBER,
                               ACSEQGEN_LAST_NUM_USED)
              VALUES (1,
                      W_BRANCH_CODE,
                      0,
                      W_NEW_PRODUCT_CODE,
                      0,
                      1);
   END ACSEQGEN_UPDATE;

   SELECT ACNTBAL_BC_BAL
     INTO W_CURR_BAL
     FROM ACNTBAL
    WHERE     ACNTBAL_ENTITY_NUM = 1
          AND ACNTBAL_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER;

   IF W_NEW_GL <> W_PREVIOUS_GL
   THEN
      SP_GLMAST_UPDATE_TO_0 (W_NEW_GL, W_PREVIOUS_GL);

      IF W_CURR_BAL < 0
      THEN
         DECLARE
            V_BATCH_NUMBER   NUMBER;
         BEGIN
            SP_AUTOPOST_TRANSACTION_MANUAL (
               W_BRANCH_CODE,                                   -- branch code
               W_NEW_GL,                                           -- debit gl
               W_PREVIOUS_GL,                                     -- credit gl
               ABS (W_CURR_BAL),                               -- debit amount
               ABS (W_CURR_BAL),                              -- credit amount
               0,                                             -- debit account
               0,                                        -- DR contract number
               0,                                        -- CR contract number
               0,                                            -- credit account
               0,                                          -- advice num debit
               NULL,                                      -- advice date debit
               0,                                         -- advice num credit
               NULL,                                     -- advice date credit
               'BDT',                                              -- currency
               '127.0.0.1',                                     -- terminal id
               'INTELECT',                                             -- user
               'PRODUCT CODE CHANGE...  ' || W_NARRATION,         -- narration
               V_BATCH_NUMBER                                  -- BATCH NUMBER
                             );
            W_BATCH := V_BATCH_NUMBER;
         END;
      ELSIF W_CURR_BAL > 0 THEN
         DECLARE
            V_BATCH_NUMBER   NUMBER;
         BEGIN
            SP_AUTOPOST_TRANSACTION_MANUAL (
               W_BRANCH_CODE,                                   -- branch code
               W_PREVIOUS_GL,                                      -- debit gl
               W_NEW_GL,                                          -- credit gl
               ABS (W_CURR_BAL),                               -- debit amount
               ABS (W_CURR_BAL),                              -- credit amount
               0,                                             -- debit account
               0,                                        -- DR contract number
               0,                                        -- CR contract number
               0,                                            -- credit account
               0,                                          -- advice num debit
               NULL,                                      -- advice date debit
               0,                                         -- advice num credit
               NULL,                                     -- advice date credit
               'BDT',                                              -- currency
               '127.0.0.1',                                     -- terminal id
               'INTELECT',                                             -- user
               'PRODUCT CODE CHANGE...  ' || W_NARRATION,         -- narration
               V_BATCH_NUMBER                                  -- BATCH NUMBER
                             );

            W_BATCH := V_BATCH_NUMBER;
         END;
      END IF;

      SP_GLMAST_UPDATE_TO_1 (W_NEW_GL, W_PREVIOUS_GL);
   ELSE
       
         
         W_ERR:= 'THE GLS ARE SAME... SO NO TRANSACTION IS NEEDED' ;
        
   END IF;



   ---- W_TOT_IA_FROM_LOANIA


   IF W_PREVIOUS_ACCRUAL_GL <> W_NEW_ACCRUAL_GL
   THEN
     <<ACCRUAL_FROM_LOANIA>>
      BEGIN
           SELECT NVL (ROUND (ABS (SUM (LOANIA_TOTAL_NEW_INT_AMT)), 2), 0),
                  MAX (LOANIA_VALUE_DATE)
             INTO W_TOT_IA_FROM_LOANIA, W_LATEST_ACC_DATE_FROM_LOANIA
             FROM LOANIA, LOANACNTS
            WHERE     LNACNT_ENTITY_NUM = 1
                  AND LNACNT_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER
                  AND LOANIA_ENTITY_NUM = 1
                  AND LOANIA_BRN_CODE = W_BRANCH_CODE
                  AND LOANIA_ACNT_NUM = W_INTERNAL_ACCOUNT_NUMBER
                  AND LOANIA_ACNT_NUM = LNACNT_INTERNAL_ACNUM
                  AND LOANIA_VALUE_DATE > LNACNT_INT_APPLIED_UPTO_DATE
                  AND LOANIA_NPA_STATUS = 0
         GROUP BY LOANIA_BRN_CODE, LOANIA_ACNT_NUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_TOT_IA_FROM_LOANIA := 0;

            SELECT ACNTS_OPENING_DATE
              INTO W_LATEST_ACC_DATE_FROM_LOANIA
              FROM ACNTS
             WHERE     ACNTS_ENTITY_NUM = 1
                   AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACCOUNT_NUMBER;
      END ACCRUAL_FROM_LOANIA;

     <<ACCRUAL_FROM_LOANIAMRR>>
      BEGIN
           SELECT NVL (ROUND (ABS (SUM (LOANIAMRR_TOTAL_NEW_INT_AMT)), 2), 0)
             INTO W_TOT_IA_FROM_LOANIAMRR
             FROM LOANIAMRR
            WHERE     LOANIAMRR_ENTITY_NUM = 1
                  AND LOANIAMRR_BRN_CODE = W_BRANCH_CODE
                  AND LOANIAMRR_ACNT_NUM = W_INTERNAL_ACCOUNT_NUMBER
                  AND LOANIAMRR_VALUE_DATE > W_LATEST_ACC_DATE_FROM_LOANIA
                  AND LOANIAMRR_NPA_STATUS = 0
         GROUP BY LOANIAMRR_ACNT_NUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_TOT_IA_FROM_LOANIAMRR := 0;
      END ACCRUAL_FROM_LOANIAMRR;

      W_TOT_IA := W_TOT_IA_FROM_LOANIA + W_TOT_IA_FROM_LOANIAMRR;


      IF W_TOT_IA <> 0
      THEN
         DECLARE
            V_BATCH_NUMBER   NUMBER;
         BEGIN
            SP_AUTOPOST_TRANSACTION_MANUAL (
               W_BRANCH_CODE,                                   -- branch code
               W_PREVIOUS_INCOME_GL,                               -- debit gl
               W_PREVIOUS_ACCRUAL_GL,                             -- credit gl
               W_TOT_IA,                                       -- debit amount
               W_TOT_IA,                                      -- credit amount
               0,                                             -- debit account
               0,                                        -- DR contract number
               0,                                        -- CR contract number
               0,                                            -- credit account
               0,                                          -- advice num debit
               NULL,                                      -- advice date debit
               0,                                         -- advice num credit
               NULL,                                     -- advice date credit
               'BDT',                                              -- currency
               '127.0.0.1',                                     -- terminal id
               'INTELECT',                                             -- user
                  'PRODUCT CODE CHANGE....ACCRUAL REVARSAL OF ACCOUNT '
               || W_ACCTUAL_ACCOUNT_NUMBER,                       -- narration
               V_BATCH_NUMBER                                  -- BATCH NUMBER
                             );

            W_PREVIOUS_ACCRUAL_BATCH := V_BATCH_NUMBER;
             
         END;



         DECLARE
            V_BATCH_NUMBER   NUMBER;
         BEGIN
            SP_AUTOPOST_TRANSACTION_MANUAL (
               W_BRANCH_CODE,                                   -- branch code
               W_NEW_ACCRUAL_GL,                                   -- debit gl
               W_NEW_INCOME_GL,                                   -- credit gl
               W_TOT_IA,                                       -- debit amount
               W_TOT_IA,                                      -- credit amount
               0,                                             -- debit account
               0,                                        -- DR contract number
               0,                                        -- CR contract number
               0,                                            -- credit account
               0,                                          -- advice num debit
               NULL,                                      -- advice date debit
               0,                                         -- advice num credit
               NULL,                                     -- advice date credit
               'BDT',                                              -- currency
               '127.0.0.1',                                     -- terminal id
               'INTELECT',                                             -- user
                  'PRODUCT CODE CHANGE....ACCRUAL REVARSAL OF ACCOUNT '
               || W_ACCTUAL_ACCOUNT_NUMBER,                       -- narration
               V_BATCH_NUMBER                                  -- BATCH NUMBER
                             );

            W_NEW_ACCRUAL_BATCH := V_BATCH_NUMBER;
 
         END;
      END IF;
   END IF;


   SELECT COUNT (*) + 1
     INTO W_COUNTER
     FROM PRODUCT_CHANGE_HIST
    WHERE ACCTUAL_ACCOUNT_NUMBER = W_ACCTUAL_ACCOUNT_NUMBER;

   SELECT MN_CURR_BUSINESS_DATE INTO W_CBD FROM MAINCONT;
   
   
   <<INSERT_HIST_TABLE>>

    BEGIN
   INSERT INTO PRODUCT_CHANGE_HIST (BRANCH_CODE,
                                         ACCTUAL_ACCOUNT_NUMBER,
                                         INTERNAL_ACCOUNT_NUMBER,
                                         ACCOUNT_PRODUCT_CHANGE_SL,
                                         PREVIOUS_ACCOUNT_TYPE,
                                         NEW_ACCOUNT_TYPE,
                                         PREVIOUS_ACCOUNT_SUB_TYPE,
                                         NEW_ACCOUNT_SUB_TYPE,
                                         PREVIOUS_PRODUCT_CODE,
                                         NEW_PRODUCT_CODE,
                                         DATE_OF_CHANGE,
                                         CURRENT_BUSINESS_DATE,
                                         BALANCE_TRANSFER_BATCH,
                                         PREVIOUS_ACCRUAL_BATCH,
                                         NEW_ACCRUAL_BATCH,
                                         REMARKS)
        VALUES (W_BRANCH_CODE,
                W_ACCTUAL_ACCOUNT_NUMBER,
                W_INTERNAL_ACCOUNT_NUMBER,
                W_COUNTER,
                W_PREVIOUS_ACCOUNT_TYPE,
                W_NEW_ACCOUNT_TYPE,
                W_PREVIOUS_ACCOUNT_SUB_TYPE,
                W_NEW_ACCOUNT_SUB_TYPE,
                W_PREVIOUS_PRODUCT_CODE,
                W_NEW_PRODUCT_CODE,
                SYSDATE,
                W_CBD,
                W_BATCH,
                W_PREVIOUS_ACCRUAL_BATCH,
                W_NEW_ACCRUAL_BATCH,
                W_NARRATION);
                
                
        EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN 
      
        DBMS_OUTPUT.PUT_LINE('THIS ACCOUNT''S PRODUCT CODE IS ALREADY CHANGED');
        END ;
        
                
END SP_PRODUCT_CODE_CHANGE;
/













BEGIN
  FOR IDX IN (SELECT P.ACCTUAL_ACCOUNT_NUMBER,
                     A.ACNTS_AC_TYPE,
                     A.ACNTS_AC_SUB_TYPE,
                     A.ACNTS_PROD_CODE
                FROM PRODUCT_CHANGE P, IACLINK I, ACNTS A
               WHERE A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
                 AND P.ACCTUAL_ACCOUNT_NUMBER = I.IACLINK_ACTUAL_ACNUM) LOOP
    UPDATE PRODUCT_CHANGE PP
       SET PP.PREVIOUS_ACCOUNT_TYPE     = IDX.ACNTS_AC_TYPE,
           PP.PREVIOUS_ACCOUNT_SUB_TYPE = IDX.ACNTS_AC_SUB_TYPE,
           PP.PREVIOUS_PRODUCT_CODE     = IDX.ACNTS_PROD_CODE
     WHERE PP.ACCTUAL_ACCOUNT_NUMBER = IDX.ACCTUAL_ACCOUNT_NUMBER;
  END LOOP;
END;














DECLARE
  V_BATCH_NUMBER           NUMBER;
  V_BALANCE_TRANSFER_BATCH NUMBER; -- BATCH NUMBER
  V_PREVIOUS_ACCRUAL_BATCH NUMBER; -- BATCH NUMBER
  V_NEW_ACCRUAL_BATCH      NUMBER;
  V_ERROR_MSG              VARCHAR2(1000);
BEGIN
  FOR IND IN (SELECT BRANCH_CODE,
                     ACCTUAL_ACCOUNT_NUMBER,
                     PREVIOUS_ACCOUNT_TYPE,
                     NEW_ACCOUNT_TYPE,
                     PREVIOUS_ACCOUNT_SUB_TYPE,
                     NEW_ACCOUNT_SUB_TYPE,
                     PREVIOUS_PRODUCT_CODE,
                     NEW_PRODUCT_CODE,
                     REMARKS
                FROM PRODUCT_CHANGE
               WHERE BALANCE_TRANSFER_BATCH IS NULL
                 AND PREVIOUS_ACCRUAL_BATCH IS NULL
                 AND NEW_ACCRUAL_BATCH IS NULL
                 AND ERRORMSG IS NULL
               ORDER BY ACCTUAL_ACCOUNT_NUMBER) LOOP
    SP_PRODUCT_CODE_CHANGE(IND.BRANCH_CODE, -- BRANCH CODE
                           IND.ACCTUAL_ACCOUNT_NUMBER, --  
                           IND.PREVIOUS_ACCOUNT_TYPE, --   
                           IND.NEW_ACCOUNT_TYPE, --  
                           IND.PREVIOUS_ACCOUNT_SUB_TYPE, --   
                           IND.NEW_ACCOUNT_SUB_TYPE, --  
                           IND.PREVIOUS_PRODUCT_CODE, --  
                           IND.NEW_PRODUCT_CODE, --  
                           IND.REMARKS,
                           V_BALANCE_TRANSFER_BATCH, --  
                           V_PREVIOUS_ACCRUAL_BATCH, --  
                           V_NEW_ACCRUAL_BATCH,
                           V_ERROR_MSG --  
                           );

    UPDATE PRODUCT_CHANGE P
       SET P.BALANCE_TRANSFER_BATCH = V_BALANCE_TRANSFER_BATCH,
           P.PREVIOUS_ACCRUAL_BATCH = V_PREVIOUS_ACCRUAL_BATCH,
           P.NEW_ACCRUAL_BATCH      = V_NEW_ACCRUAL_BATCH,
           P.ERRORMSG                = V_ERROR_MSG
     WHERE P.ACCTUAL_ACCOUNT_NUMBER = IND.ACCTUAL_ACCOUNT_NUMBER;
  
  END LOOP;
END;
/

















INSERT INTO PRODUCT_CHANGE
SELECT A.ACNTS_BRN_CODE BRANCH_CODE,
       I.IACLINK_ACTUAL_ACNUM ACCTUAL_ACCOUNT_NUMBER,
       A.ACNTS_AC_TYPE PREVIOUS_ACCOUNT_TYPE,
       'KNDAL' NEW_ACCOUNT_TYPE,
       A.ACNTS_AC_SUB_TYPE PREVIOUS_ACCOUNT_SUB_TYPE,
       2 NEW_ACCOUNT_SUB_TYPE,
       A.ACNTS_PROD_CODE PREVIOUS_PRODUCT_CODE,
       2501 NEW_PRODUCT_CODE,
       NULL ERROR_MSG,
       NULL BALANCE_TRANSFER_BATCH,
       NULL PREVIOUS_ACCRUAL_BATCH,
       NULL NEW_ACCRUAL_BATCH,
       'ISSUE | 2450' REMARKS,
       NULL ERRORMSG
  FROM IACLINK I, ACNTS A
 WHERE I.IACLINK_ACTUAL_ACNUM IN ('5006263000029', '5006263000028')
   AND A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM ; 