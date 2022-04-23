-----------------------------ACNTBAL------------------------------------------
CREATE TABLE TAB_ACNT_BAL AS 
WITH ACCOUNT_WISE_TOTAL_BALANCE
     AS ( ------------------- FORMONTHS WISE TRANSACTION SUMMATION --------------------
         SELECT   TRAN_INTERNAL_ACNUM,
                  SUM (CREDIT_AMOUNT) ACCOUNT_WISE_CREDIT_SUM,
                  SUM (DEBIT_AMOUNT) ACCOUNT_WISE_DEBIT_SUM,
                  SUM (CREDIT_TRANSACTION) ACCOUNT_WISE_CREDIT_TRAN,
                  SUM (DEBIT_TRANSACTION) ACCOUNT_WISE_DEBIT_TRAN
             FROM ( (SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_INTERNAL_ACNUM,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2014 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                            AND TR.TRAN_INTERNAL_ACNUM IN
                                   (SELECT IACLINK_INTERNAL_ACNUM
                                      FROM ACTUAL_ACCOUNT_UPDATE)
                            AND TR.TRAN_INTERNAL_ACNUM <> 0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_INTERNAL_ACNUM,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2015 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                            AND TR.TRAN_INTERNAL_ACNUM IN
                                   (SELECT IACLINK_INTERNAL_ACNUM
                                      FROM ACTUAL_ACCOUNT_UPDATE)
                            AND TR.TRAN_INTERNAL_ACNUM <> 0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_INTERNAL_ACNUM,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2016 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                            AND TR.TRAN_INTERNAL_ACNUM IN
                                   (SELECT IACLINK_INTERNAL_ACNUM
                                      FROM ACTUAL_ACCOUNT_UPDATE)
                            AND TR.TRAN_INTERNAL_ACNUM <> 0
                            AND TR.TRAN_AMOUNT <> 0
                     UNION ALL
                     SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                           TR.TRAN_INTERNAL_ACNUM,
                            TR.TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM,
                            TRAN_DB_CR_FLG,
                            TRAN_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'D'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               DEBIT_AMOUNT,
                            (CASE
                                WHEN TRAN_DB_CR_FLG = 'C'
                                THEN
                                   NVL (TRAN_AMOUNT, 0)
                                ELSE
                                   0
                             END)
                               CREDIT_AMOUNT,
                            (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END)
                               CREDIT_TRANSACTION,
                            (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END)
                               DEBIT_TRANSACTION
                       FROM TRAN2017 TR
                      WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                            AND TR.TRAN_INTERNAL_ACNUM IN
                                   (SELECT IACLINK_INTERNAL_ACNUM
                                      FROM ACTUAL_ACCOUNT_UPDATE)
                            AND TR.TRAN_INTERNAL_ACNUM <> 0
                            AND TR.TRAN_AMOUNT <> 0))
         GROUP BY TRAN_INTERNAL_ACNUM)
SELECT TT.TRAN_INTERNAL_ACNUM,
       TT.ACCOUNT_WISE_CREDIT_SUM,
       TT.ACCOUNT_WISE_DEBIT_SUM,
       ACCOUNT_WISE_CREDIT_SUM - ACCOUNT_WISE_DEBIT_SUM CURRENT_BALANCE
  FROM ACCOUNT_WISE_TOTAL_BALANCE TT ;
  
-------------QUERY------------------------ 

 
SELECT TRAN_INTERNAL_ACNUM,
       ACCOUNT_WISE_CREDIT_SUM - ACNTBAL_AC_CUR_CR_SUM ACNTBAL_AC_CUR_CR_SUM,
       ACCOUNT_WISE_DEBIT_SUM - ACNTBAL_AC_CUR_DB_SUM ACNTBAL_AC_CUR_DB_SUM,
       CURRENT_BALANCE - ACNTBAL_AC_BAL CURRENT_BALANCE
  FROM tab_acnt_bal, ACNTBAL
 WHERE     ACNTBAL_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM 
and ACNTBAL_ENTITY_NUM = 1
and (ACCOUNT_WISE_CREDIT_SUM - ACNTBAL_AC_CUR_CR_SUM <> 0 or ACCOUNT_WISE_DEBIT_SUM - ACNTBAL_AC_CUR_DB_SUM <> 0 or CURRENT_BALANCE - ACNTBAL_AC_BAL <> 0)

---------------ACNTBBAL-----------------
CREATE TABLE MONTHS_WISE_AC_BALANCE
(
  INT_AC_NO           NUMBER(14),
  TRANSACTION_YEAR    VARCHAR2(4 BYTE),
  TRANSACTION_MONTHS  VARCHAR2(2 BYTE),
  MW_CR_SUM           NUMBER,
  MW_DR_SUM           NUMBER,
  SL                  NUMBER
) ;


CREATE OR REPLACE PROCEDURE SP_MONTHWISE_DR_CR_SUM
IS
   V_ACNUM        NUMBER (14);
   V_YEAR         NUMBER (4);
   V_MONTH        NUMBER (2);
   V_CBD_YEAR     NUMBER (4);
   V_CBD_MONTH    NUMBER (2);
   V_CR_SUM       NUMBER (18, 3);
   V_DR_SUM       NUMBER (18, 3);
   V_SQL          VARCHAR2 (200);
   V_CBD          DATE;
   V_START_DATE   DATE;
   V_END_DATE     DATE;
   V_COUNT        NUMBER;
BEGIN
   V_SQL := 'TRUNCATE TABLE MONTHS_WISE_AC_BALANCE';

   EXECUTE IMMEDIATE V_SQL;


   INSERT INTO MONTHS_WISE_AC_BALANCE
      WITH MONTHS_WISE_AC_BALANCE
           AS ( ------------------- FORMONTHS WISE TRANSACTION SUMMATION --------------------
               SELECT   TRAN_INTERNAL_ACNUM,
                        TRANSACTION_YEAR,
                        TRANSACTION_MONTHS,
                        SUM (CREDIT_AMOUNT) MONTHS_WISE_CREDIT_SUM,
                        SUM (DEBIT_AMOUNT) MONTHS_WISE_DEBIT_SUM,
                        SUM (CREDIT_TRANSACTION) MONTHS_WISE_CREDIT_TRAN,
                        SUM (DEBIT_TRANSACTION) MONTHS_WISE_DEBIT_TRAN 
                   FROM ( (SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
      TR.TRAN_INTERNAL_ACNUM,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'MM')
          TRANSACTION_MONTHS,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'YYYY')
          TRANSACTION_YEAR,
       TRAN_BATCH_NUMBER,
       TRAN_BATCH_SL_NUM,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          DEBIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          CREDIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END) CREDIT_TRANSACTION,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END) DEBIT_TRANSACTION
  FROM TRAN2014 TR
 WHERE     TR.TRAN_AUTH_ON IS NOT NULL
       AND TR.TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE)
       AND TR.TRAN_INTERNAL_ACNUM <> 0
       AND TR.TRAN_AMOUNT <> 0
       UNION ALL
                    ------------------- FORMONTHS WISE TRANSACTION SELECTION --------------------
                           SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
      TR.TRAN_INTERNAL_ACNUM,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'MM')
          TRANSACTION_MONTHS,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'YYYY')
          TRANSACTION_YEAR,
       TRAN_BATCH_NUMBER,
       TRAN_BATCH_SL_NUM,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          DEBIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          CREDIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END) CREDIT_TRANSACTION,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END) DEBIT_TRANSACTION
  FROM TRAN2015 TR
 WHERE     TR.TRAN_AUTH_ON IS NOT NULL
       AND TR.TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE)
       AND TR.TRAN_INTERNAL_ACNUM <> 0
       AND TR.TRAN_AMOUNT <> 0
                         UNION ALL
                         SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
      TR.TRAN_INTERNAL_ACNUM,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'MM')
          TRANSACTION_MONTHS,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'YYYY')
          TRANSACTION_YEAR,
       TRAN_BATCH_NUMBER,
       TRAN_BATCH_SL_NUM,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          DEBIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          CREDIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END) CREDIT_TRANSACTION,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END) DEBIT_TRANSACTION
  FROM TRAN2016 TR
 WHERE     TR.TRAN_AUTH_ON IS NOT NULL
       AND TR.TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE)
       AND TR.TRAN_INTERNAL_ACNUM <> 0
       AND TR.TRAN_AMOUNT <> 0
                                 UNION ALL
                                 SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
      TR.TRAN_INTERNAL_ACNUM,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'MM')
          TRANSACTION_MONTHS,
       TO_CHAR (ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1), 'YYYY')
          TRANSACTION_YEAR,
       TRAN_BATCH_NUMBER,
       TRAN_BATCH_SL_NUM,
       TRAN_DB_CR_FLG,
       TRAN_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          DEBIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN NVL (TRAN_AMOUNT, 0) ELSE 0 END)
          CREDIT_AMOUNT,
       (CASE WHEN TRAN_DB_CR_FLG = 'C' THEN 1 ELSE 0 END) CREDIT_TRANSACTION,
       (CASE WHEN TRAN_DB_CR_FLG = 'D' THEN 1 ELSE 0 END) DEBIT_TRANSACTION
  FROM TRAN2017 TR
 WHERE     TR.TRAN_AUTH_ON IS NOT NULL
       AND TR.TRAN_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE)
       AND TR.TRAN_INTERNAL_ACNUM <> 0
       AND TR.TRAN_AMOUNT <> 0
       ))
               GROUP BY TRAN_INTERNAL_ACNUM,
                        TRANSACTION_YEAR,
                        TRANSACTION_MONTHS)
      SELECT INT_AC_NO,
             TRANSACTION_YEAR,
             TRANSACTION_MONTHS,
             SUM (
                MW_CR_SUM)
             OVER (PARTITION BY INT_AC_NO
                   ORDER BY INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                MW_CR_SUM,
             SUM (
                MW_DR_SUM)
             OVER (PARTITION BY INT_AC_NO
                   ORDER BY INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                MW_DR_SUM,
             ROW_NUMBER ()
             OVER (PARTITION BY INT_AC_NO
                   ORDER BY INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                SL
        FROM (SELECT TRAN_INTERNAL_ACNUM INT_AC_NO,
                     TRANSACTION_YEAR,
                     TRANSACTION_MONTHS,
                     MONTHS_WISE_CREDIT_TRAN MW_NO_OF_CR,
                     MONTHS_WISE_DEBIT_TRAN MW_NO_OF_DR,
                     CREDIT_TRAN_SUMMATION TOT_NO_OF_CR,
                     DEBIT_TRAN_SUMMATION TOT_NO_OF_DR,
                     MONTHS_WISE_CREDIT_SUM MW_CR_SUM,
                     MONTHS_WISE_DEBIT_SUM MW_DR_SUM,
                     --CREDIT_OPENING_BALANCE, DEBIT_OPENING_BALANCE,
                     NVL (
                        LAG (
                           ACCOUNT_CURRENT_BALANCE)
                        OVER (
                           PARTITION BY TRAN_INTERNAL_ACNUM
                           ORDER BY
                              TRAN_INTERNAL_ACNUM,
                              TRANSACTION_YEAR,
                              TRANSACTION_MONTHS),
                        0)
                        MW_OP_BAL,
                     ACCOUNT_CURRENT_BALANCE MW_CLS_BAL 
                FROM ( ------------------ START SELECT QUERY FROM MONTHS WISE ACCOUNT BALANCE ---------------------
                      SELECT   TRAN_INTERNAL_ACNUM,
                               TRANSACTION_YEAR,
                               TRANSACTION_MONTHS,
                               MONTHS_WISE_CREDIT_TRAN,
                               MONTHS_WISE_DEBIT_TRAN,
                               SUM (
                                  MONTHS_WISE_CREDIT_TRAN)
                               OVER (
                                  PARTITION BY TRAN_INTERNAL_ACNUM
                                  ORDER BY
                                     TRAN_INTERNAL_ACNUM,
                                     TRANSACTION_YEAR,
                                     TRANSACTION_MONTHS)
                                  CREDIT_TRAN_SUMMATION,
                               SUM (
                                  MONTHS_WISE_DEBIT_TRAN)
                               OVER (
                                  PARTITION BY TRAN_INTERNAL_ACNUM
                                  ORDER BY
                                     TRAN_INTERNAL_ACNUM,
                                     TRANSACTION_YEAR,
                                     TRANSACTION_MONTHS)
                                  DEBIT_TRAN_SUMMATION,
                               MONTHS_WISE_CREDIT_SUM,
                               MONTHS_WISE_DEBIT_SUM,
                               SUM (
                                  MONTHS_WISE_CREDIT_SUM)
                               OVER (
                                  PARTITION BY TRAN_INTERNAL_ACNUM
                                  ORDER BY
                                     TRAN_INTERNAL_ACNUM,
                                     TRANSACTION_YEAR,
                                     TRANSACTION_MONTHS)
                                  CREDIT_OPENING_BALANCE,
                               SUM (
                                  MONTHS_WISE_DEBIT_SUM)
                               OVER (
                                  PARTITION BY TRAN_INTERNAL_ACNUM
                                  ORDER BY
                                     TRAN_INTERNAL_ACNUM,
                                     TRANSACTION_YEAR,
                                     TRANSACTION_MONTHS)
                                  DEBIT_OPENING_BALANCE,
                               SUM (
                                    MONTHS_WISE_CREDIT_SUM
                                  - MONTHS_WISE_DEBIT_SUM)
                               OVER (
                                  PARTITION BY TRAN_INTERNAL_ACNUM
                                  ORDER BY
                                     TRAN_INTERNAL_ACNUM,
                                     TRANSACTION_YEAR,
                                     TRANSACTION_MONTHS)
                                  ACCOUNT_CURRENT_BALANCE 
                          FROM MONTHS_WISE_AC_BALANCE
                      ORDER BY TRAN_INTERNAL_ACNUM,
                               TRANSACTION_YEAR,
                               TRANSACTION_MONTHS));


   SELECT MN_CURR_BUSINESS_DATE INTO V_CBD FROM MAINCONT;

   V_CBD_YEAR := TO_CHAR (V_CBD, 'YYYY');
   V_CBD_MONTH := TO_CHAR (V_CBD, 'MM');

   FOR IDX IN (SELECT *
                 FROM MONTHS_WISE_AC_BALANCE
                WHERE SL = 1)
   LOOP
      V_YEAR := IDX.TRANSACTION_YEAR;
      V_MONTH := IDX.TRANSACTION_MONTHS;
      V_START_DATE :=
         TO_DATE ('01-' || V_MONTH || '-' || V_YEAR, 'DD-MM-YYYY');
      V_END_DATE :=
         TO_DATE ('01-' || V_CBD_MONTH || '-' || V_CBD_YEAR, 'DD-MM-YYYY');

      WHILE (V_START_DATE <= V_END_DATE)
      LOOP
         SELECT COUNT (*)
           INTO V_COUNT
           FROM MONTHS_WISE_AC_BALANCE
          WHERE     INT_AC_NO = IDX.INT_AC_NO
                AND TRANSACTION_YEAR = TO_CHAR (V_START_DATE, 'YYYY')
                AND TRANSACTION_MONTHS = TO_CHAR (V_START_DATE, 'MM');

         IF V_COUNT = 0
         THEN
            INSERT INTO MONTHS_WISE_AC_BALANCE (INT_AC_NO,
                                                TRANSACTION_YEAR,
                                                TRANSACTION_MONTHS,
                                                MW_CR_SUM,
                                                MW_DR_SUM,
                                                SL)
                 VALUES (
                           IDX.INT_AC_NO,
                           TO_CHAR (V_START_DATE, 'YYYY'),
                           TO_CHAR (V_START_DATE, 'MM'),
                           (SELECT MW_CR_SUM
                              FROM MONTHS_WISE_AC_BALANCE
                             WHERE     INT_AC_NO = IDX.INT_AC_NO
                                   AND TRANSACTION_YEAR =
                                          TO_CHAR (
                                             ADD_MONTHS (V_START_DATE, - 1),
                                             'YYYY')
                                   AND TRANSACTION_MONTHS =
                                          TO_CHAR (
                                             ADD_MONTHS (V_START_DATE, - 1),
                                             'MM')),
                           (SELECT MW_DR_SUM
                              FROM MONTHS_WISE_AC_BALANCE
                             WHERE     INT_AC_NO = IDX.INT_AC_NO
                                   AND TRANSACTION_YEAR =
                                          TO_CHAR (
                                             ADD_MONTHS (V_START_DATE, - 1),
                                             'YYYY')
                                   AND TRANSACTION_MONTHS =
                                          TO_CHAR (
                                             ADD_MONTHS (V_START_DATE, - 1),
                                             'MM')),
                           0);
                           COMMIT ;
         END IF;

         SELECT ADD_MONTHS (V_START_DATE, 1) INTO V_START_DATE FROM DUAL;
      END LOOP;
   END LOOP;
END SP_MONTHWISE_DR_CR_SUM;

------------QUERY--------------------------------

SELECT ACNTBBAL_INTERNAL_ACNUM, ACNTBBAL_YEAR, ACNTBBAL_MONTH,ACNTBBAL_AC_OPNG_CR_SUM-MW_CR_SUM,ACNTBBAL_BC_OPNG_DB_SUM-MW_DR_SUM
  FROM MONTHS_WISE_AC_BALANCE, ACNTBBAL
 WHERE     ACNTBBAL_ENTITY_NUM = 1
       AND INT_AC_NO = ACNTBBAL_INTERNAL_ACNUM
       AND TRANSACTION_MONTHS = ACNTBBAL_MONTH
       AND TRANSACTION_YEAR = ACNTBBAL_YEAR
       AND (ACNTBBAL_AC_OPNG_CR_SUM-MW_CR_SUM<>0 OR ACNTBBAL_BC_OPNG_DB_SUM-MW_DR_SUM<>0)
       ORDER BY ACNTBBAL_INTERNAL_ACNUM, ACNTBBAL_YEAR, ACNTBBAL_MONTH