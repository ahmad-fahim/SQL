/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_DORINOPMARK
IS
   -- Author  : MohanaKrishnan L
   -- Created : 13-09-2007
   -- Purpose : End of day process for marking Dormant / In-operative Accounts
   -- Hint    : SP_MarkAcDormantInop done for Mct was taken as base / Reuse

   /*
   .
   .
   .
    Modification Date            Modified By             Reason for Modification
    02-FEB-2020                  Fahim Ahmad             Need to make the process branchwise.
                                                         Maximum SQL changed because of the optimization.

    */

   PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                            P_BRN_CODE      IN NUMBER DEFAULT 0);
END PKG_DORINOPMARK;
/

/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE BODY PKG_DORINOPMARK
IS
   -- Author  : MohanaKrishnan L
   -- Created : 13-09-2007
   -- Purpose : End of day process for marking Dormant / In-operative Accounts
   -- Hint    : SP_MarkAcDormantInop done for Mct was taken as base / Reuse

   /*
   .
   .
   .
   Modification Date            Modified By             Reason for Modification
   02-FEB-2020                  Fahim Ahmad             Need to make the process branchwise.
                                                        Maximum SQL changed because of the optimization.

   */
   V_ENTITY_NUM   NUMBER (5);
   V_USER_ID      VARCHAR2 (8);
   V_CBD          DATE;
   V_ERROR        VARCHAR2 (1000);
   
   PROCEDURE SP_DORINOPMARK (V_BRN_CODE NUMBER)
   IS
      TYPE R_RAPARAM IS RECORD
      (
         AC_TYPE               VARCHAR2 (5),
         DORMANT_CUTOFF_DATE   DATE,
         INOP_CUTOFF_DATE      DATE
      );

      TYPE R_ACNT_INOP IS RECORD
      (
         INTERNAL_ACNUM         NUMBER (14),
         CLIENT_CODE            NUMBER (12),
         CLIENT_DATE_OF_BIRTH   DATE,
         LOAN_PRODUCT           VARCHAR2 (2),
         DORMANT_INOP_DATE      DATE,
         DORMANT_ACNT           CHAR (1),
         INOP_ACNT              CHAR (1)
      );

      TYPE R_ACNT_STATUS_CHECK IS RECORD
      (
         INTERNAL_ACNUM   NUMBER (14),
         STATUS           VARCHAR2 (1)
      );

      TYPE IT_ACNT_INOP IS TABLE OF R_ACNT_INOP;

      TYPE IT_RAPARAM IS TABLE OF R_RAPARAM
         INDEX BY PLS_INTEGER;

      TYPE IT_ACNTS IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      TYPE IT_ACNTS_STATUS IS TABLE OF VARCHAR2 (1)
         INDEX BY PLS_INTEGER;

      TYPE IT_DORMANT_ACNT IS TABLE OF VARCHAR2 (1)
         INDEX BY PLS_INTEGER;

      TYPE IT_INOP_ACNT IS TABLE OF VARCHAR2 (1)
         INDEX BY PLS_INTEGER;

      TYPE IT_ACNT_STATUS_CHECK IS TABLE OF R_ACNT_STATUS_CHECK
         INDEX BY VARCHAR2 (14);

      T_RAPARAM                      IT_RAPARAM;
      T_ACNTS                        IT_ACNTS;
      T_ACNTS_STATUS                 IT_ACNTS_STATUS;
      T_DORMANT_ACNT                 IT_DORMANT_ACNT;
      T_INOP_ACNT                    IT_INOP_ACNT;
      T_ACNTS_FOR_UPDATE             IT_ACNT_INOP;
      T_ACNTS_STATUS_CHECK           IT_ACNT_STATUS_CHECK;
      T_ACNTS_STATUS_INSERT_STATUS   IT_ACNTS_STATUS;
      T_ACNTS_STATUS_UPDATE_STATUS   IT_ACNTS_STATUS;
      T_ACNTS_STATUS_INSERT_ACNO     IT_ACNTS;
      T_ACNTS_STATUS_UPDATE_ACNO     IT_ACNTS;
      V_ACNTSTATUS_INSERT_IND        NUMBER;
      V_ACNTSTATUS_UPDATE_IND        NUMBER;
      V_USERID                       VARCHAR2 (8);
      V_SQL                          VARCHAR2 (4300);
      V_IND                          NUMBER;
      V_ERR_MSG                      VARCHAR2 (1000);
      --Added by Suganthi for Dormant Non-Marking

      W_TEST_ACNUM                   VARCHAR2 (60);               --Delete L8r
      W_TEST_ACNUM_PREV              VARCHAR2 (60);               --Delete L8r
      W_INTERNAL_ACNUM               VARCHAR2 (18);
      V_MAJ_AGE                      NUMBER (3);
      V_DIFF                         NUMBER (20);
      V_CORP_QUAL                    VARCHAR2 (5);
      V_STATUS                       NUMBER (5);
      V_CLIENT_DATE                  DATE;
      V_AGE                          NUMBER (7);
      V_CURR_DATE                    DATE;
      V_CUR_DATE                     DATE;
      V_DOR_CUTOFF_DATE              VARCHAR2 (20);
      V_INOP_CUTOFF_DATE             VARCHAR2 (20);
      --End by Suganthi



      E_USEREXCEP                    EXCEPTION;
   BEGIN
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
      --PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
      V_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
      V_USERID := V_USER_ID;

      V_SQL :=
         'SELECT ACNTSTATUS_INTERNAL_ACNUM FROM ACNTS, ACNTSTATUS
                         WHERE ACNTS_ENTITY_NUM = :V_ENTITY_NUM
                         AND ACNTSTATUS_ENTITY_NUM = :V_ENTITY_NUM
                         AND ACNTS_INTERNAL_ACNUM = ACNTSTATUS_INTERNAL_ACNUM
                         AND ACNTS_BRN_CODE = :BRN_CODE 
                         AND ACNTSTATUS_EFF_DATE =:V_CBD 
                         AND ACNTSTATUS_FLG = ''O'' 
                         AND ACNTS_CLOSURE_DATE IS NULL ';
  
      EXECUTE IMMEDIATE V_SQL
         BULK COLLECT INTO T_ACNTS
         USING V_ENTITY_NUM, V_ENTITY_NUM, V_BRN_CODE, V_CBD;

      IF T_ACNTS.EXISTS (1) = TRUE
      THEN
         FOR IDX IN 1 .. T_ACNTS.COUNT
         LOOP
            T_ACNTS_STATUS_CHECK (T_ACNTS (IDX)).INTERNAL_ACNUM :=
               T_ACNTS (IDX);
            T_ACNTS_STATUS_CHECK (T_ACNTS (IDX)).STATUS := 'O';
         END LOOP;

         T_ACNTS.DELETE;
      END IF;

      -- fetch raparam details for a account type

      V_SQL :=
         'SELECT 
              RAPARAM_AC_TYPE,
              CASE RAPARAM_DORMANT_AC_PRD_FLG
                  WHEN ''D'' THEN (TO_DATE(:1,''DD-MON-YYYY'') - RAPARAM_DORMANT_AC_PRD)
                  WHEN ''M'' THEN ADD_MONTHS(:2,-1* RAPARAM_DORMANT_AC_PRD)
                  ELSE  NULL
              END DORMANT_CUTOFF_DATE,
              CASE RAPARAM_INOP_AC_PRD_FLG
                  WHEN ''D'' THEN (TO_DATE(:3,''DD-MON-YYYY'') - RAPARAM_INOP_AC_PRD)
                  WHEN ''M'' THEN ADD_MONTHS(:4, -1* RAPARAM_INOP_AC_PRD)
                  ELSE NULL
              END INOPER_CUTOFF_DATE
              FROM RAPARAM';

      EXECUTE IMMEDIATE V_SQL
         BULK COLLECT INTO T_RAPARAM
         USING V_CBD,
               V_CBD,
               V_CBD,
               V_CBD;

      -- fetch all accounts satisfying the dormant and inop condition for an account type
      -- into the accounts collection

      V_IND := 1;
      V_ACNTSTATUS_INSERT_IND := 1;
      V_ACNTSTATUS_UPDATE_IND := 1;

      FOR IDX IN 1 .. T_RAPARAM.COUNT
      LOOP
         V_DOR_CUTOFF_DATE :=
            TO_DATE (T_RAPARAM (IDX).DORMANT_CUTOFF_DATE, 'DD-MON-YYYY'); --ADDED BY PRATIK 28-08-2013
         V_INOP_CUTOFF_DATE :=
            TO_DATE (T_RAPARAM (IDX).INOP_CUTOFF_DATE, 'DD-MON-YYYY'); --ADDED BY PRATIK 28-08-2013

         IF    T_RAPARAM (IDX).DORMANT_CUTOFF_DATE < V_CBD
            OR T_RAPARAM (IDX).INOP_CUTOFF_DATE < V_CBD
         THEN
            V_SQL :=
               'SELECT ACNTS_INTERNAL_ACNUM,
                         ACNTS_CLIENT_NUM ,
                         ((SELECT  INDCLIENT_BIRTH_DATE  FROM  INDCLIENTS C
                            WHERE ACNTS_CLIENT_NUM = INDCLIENT_CODE  )) CLIENT_DATE ,
                         PRODUCT_FOR_LOANS ,
                         CASE
                             WHEN ACNTS_NONSYS_LAST_DATE IS NULL THEN ACNTS_OPENING_DATE
                             ELSE ACNTS_NONSYS_LAST_DATE
                         END DORMANT_DATE,
                            NVL(ACNTS_DORMANT_ACNT,''0''), NVL(ACNTS_INOP_ACNT,''0'')
                         FROM ACNTS, PRODUCTS
                         WHERE ACNTS_ENTITY_NUM = :ENTITY_NUM
                               AND ACNTS_BRN_CODE = :BRN_CODE 
                               AND ACNTS_PROD_CODE = PRODUCT_CODE 
                               AND  (( ACNTS_AC_TYPE = :1 AND ACNTS_DORMANT_ACNT <> ''1'' AND ((ACNTS_NONSYS_LAST_DATE IS NULL AND ACNTS_OPENING_DATE < :2) 
                                       OR
                                    (ACNTS_NONSYS_LAST_DATE IS NOT NULL AND ACNTS_NONSYS_LAST_DATE < :3)))
                                    OR
                                    ( ACNTS_AC_TYPE = :4 AND ACNTS_INOP_ACNT <> ''1'' AND ((ACNTS_NONSYS_LAST_DATE IS NULL AND ACNTS_OPENING_DATE < :5 ) 
                                       OR
                                    (ACNTS_NONSYS_LAST_DATE IS NOT NULL AND ACNTS_NONSYS_LAST_DATE < :6))))
                               AND ACNTS_CLOSURE_DATE IS NULL';

            -- CHN Guna 28/07/2011 end

            EXECUTE IMMEDIATE V_SQL
               BULK COLLECT INTO T_ACNTS_FOR_UPDATE
               USING V_ENTITY_NUM,
                     V_BRN_CODE,
                     T_RAPARAM (IDX).AC_TYPE,
                     V_DOR_CUTOFF_DATE,
                     V_DOR_CUTOFF_DATE,
                     T_RAPARAM (IDX).AC_TYPE,
                     V_INOP_CUTOFF_DATE,
                     V_INOP_CUTOFF_DATE;          --ADDED BY PRATIK 28-08-2013
                     
            SELECT MAJAGE_MAJ_AGE
                       INTO V_MAJ_AGE
                       FROM MAJAGE
                      WHERE MAJAGE_EFF_DATE =
                               (SELECT MAX (MAJAGE_EFF_DATE) FROM MAJAGE);

            FOR IDXACNTS IN 1 .. T_ACNTS_FOR_UPDATE.COUNT
            LOOP
               V_STATUS := T_ACNTS_FOR_UPDATE (IDXACNTS).LOAN_PRODUCT;
               V_AGE := '';
               V_CURR_DATE := V_CBD;

               V_CUR_DATE := TO_CHAR (V_CURR_DATE, 'DD-MON-YYYY');

               V_CLIENT_DATE :=
                  T_ACNTS_FOR_UPDATE (IDXACNTS).CLIENT_DATE_OF_BIRTH;

               --Minor Accounts non-marking
               BEGIN
                  IF V_STATUS <> 1
                  THEN
                     V_AGE := (ABS(V_CUR_DATE - V_CLIENT_DATE)) / 365 ;

                     -- IF V_AGE <18 THEN
                     IF V_AGE < V_MAJ_AGE
                     THEN             --Modified By venugopal.M on 04-Jun-2013
                        V_STATUS := 1;
                     END IF;

                     IF V_CLIENT_DATE IS NULL
                     THEN
                        V_STATUS := 0;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     V_STATUS := 0;
               END;

               --Corp Clients Non-Marking
               BEGIN
                  IF V_STATUS <> 1
                  THEN
                     SELECT CORPCL_ORGN_QUALIFIER
                       INTO V_CORP_QUAL
                       FROM CORPCLIENTS
                      WHERE CORPCL_CLIENT_CODE =
                               T_ACNTS_FOR_UPDATE (IDXACNTS).CLIENT_CODE;

                     IF V_CORP_QUAL <> 'O'
                     THEN
                        V_STATUS := 1;
                     ELSE
                        V_STATUS := 0;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     V_STATUS := 0;
               END;

               --End
               IF V_STATUS <> 1
               THEN                               --Added By Suganthi Begin If
                  --Mohan-Rem     IF p_Markinop = 1 THEN
                  IF T_ACNTS_FOR_UPDATE (IDXACNTS).INOP_ACNT <> '1'
                  THEN
                     IF T_RAPARAM (IDX).INOP_CUTOFF_DATE < V_CBD
                     THEN
                        --Mohan-add to handle if cutoff prd is not specified
                        IF     T_ACNTS_FOR_UPDATE (IDXACNTS).DORMANT_INOP_DATE <
                                  V_INOP_CUTOFF_DATE
                           AND (   (V_DOR_CUTOFF_DATE IS NULL)
                                OR (    V_DOR_CUTOFF_DATE <= V_CBD
                                    AND T_ACNTS_FOR_UPDATE (IDXACNTS).DORMANT_INOP_DATE <=
                                           V_DOR_CUTOFF_DATE))
                        THEN
                           T_ACNTS (V_IND) :=
                              T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                           T_INOP_ACNT (V_IND) := '1';

                           IF T_ACNTS_STATUS_CHECK.EXISTS (
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM) =
                                 TRUE
                           THEN
                              T_ACNTS_STATUS_UPDATE_ACNO (
                                 V_ACNTSTATUS_UPDATE_IND) :=
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                              T_ACNTS_STATUS_UPDATE_STATUS (
                                 V_ACNTSTATUS_UPDATE_IND) :=
                                 'I';
                              V_ACNTSTATUS_UPDATE_IND :=
                                 V_ACNTSTATUS_UPDATE_IND + 1;
                           ELSE
                              T_ACNTS_STATUS_INSERT_ACNO (
                                 V_ACNTSTATUS_INSERT_IND) :=
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                              T_ACNTS_STATUS_INSERT_STATUS (
                                 V_ACNTSTATUS_INSERT_IND) :=
                                 'I';
                              V_ACNTSTATUS_INSERT_IND :=
                                 V_ACNTSTATUS_INSERT_IND + 1;
                           END IF;
                        /*ELSE
                        v_inop_acnt(v_ind) :='0' ;  */
                        END IF;
                     END IF;
                  END IF;
               END IF;                                       --End By Suganthi

               IF V_STATUS <> 1
               THEN                               --Added By Suganthi Begin If
                  --Mohan-Rem      IF P_MarkDormant = 1  THEN
                  IF T_ACNTS_FOR_UPDATE (IDXACNTS).DORMANT_ACNT <> '1'
                  THEN
                     IF T_RAPARAM (IDX).DORMANT_CUTOFF_DATE < V_CBD
                     THEN
                        --Mohan-add to handle if cutoff prd is not specified
                        IF T_ACNTS_FOR_UPDATE (IDXACNTS).DORMANT_INOP_DATE <
                              V_DOR_CUTOFF_DATE
                        THEN
                           T_ACNTS (V_IND) :=
                              T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                           T_DORMANT_ACNT (V_IND) := '1';

                           IF T_ACNTS_STATUS_CHECK.EXISTS (
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM) =
                                 TRUE
                           THEN
                              T_ACNTS_STATUS_UPDATE_ACNO (
                                 V_ACNTSTATUS_UPDATE_IND) :=
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                              T_ACNTS_STATUS_UPDATE_STATUS (
                                 V_ACNTSTATUS_UPDATE_IND) :=
                                 'D';
                              V_ACNTSTATUS_UPDATE_IND :=
                                 V_ACNTSTATUS_UPDATE_IND + 1;
                           ELSE
                              T_ACNTS_STATUS_CHECK (
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM).INTERNAL_ACNUM :=
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                              T_ACNTS_STATUS_CHECK (
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM).STATUS :=
                                 'D';
                              T_ACNTS_STATUS_INSERT_ACNO (
                                 V_ACNTSTATUS_INSERT_IND) :=
                                 T_ACNTS_FOR_UPDATE (IDXACNTS).INTERNAL_ACNUM;
                              T_ACNTS_STATUS_INSERT_STATUS (
                                 V_ACNTSTATUS_INSERT_IND) :=
                                 'D';
                              V_ACNTSTATUS_INSERT_IND :=
                                 V_ACNTSTATUS_INSERT_IND + 1;
                           END IF;
                        /* ELSE
                        v_dormant_acnt(v_ind) :='0' ; */
                        END IF;
                     END IF;
                  END IF;
               END IF;                                       --End By Suganthi


               IF T_ACNTS.EXISTS (V_IND)
               THEN
                  IF T_DORMANT_ACNT.EXISTS (V_IND) = FALSE
                  THEN
                     T_DORMANT_ACNT (V_IND) :=
                        T_ACNTS_FOR_UPDATE (IDXACNTS).DORMANT_ACNT;
                  ELSIF T_INOP_ACNT.EXISTS (V_IND) = FALSE
                  THEN
                     T_INOP_ACNT (V_IND) :=
                        T_ACNTS_FOR_UPDATE (IDXACNTS).INOP_ACNT;
                  END IF;

                  V_IND := V_IND + 1;
               END IF;
            END LOOP;
         END IF;                                                -- Mohan added
      END LOOP;

      -- update acnts and acntsstatus tables
      IF T_ACNTS.COUNT > 0
      THEN
         FORALL IDXACNTS IN 1 .. T_ACNTS.COUNT
            UPDATE ACNTS
               SET ACNTS_DORMANT_ACNT = T_DORMANT_ACNT (IDXACNTS),
                   ACNTS_INOP_ACNT = T_INOP_ACNT (IDXACNTS)
             WHERE     ACNTS_ENTITY_NUM = V_ENTITY_NUM
                   AND ACNTS_INTERNAL_ACNUM = T_ACNTS (IDXACNTS);

         IF T_ACNTS_STATUS_INSERT_ACNO.EXISTS (1) = TRUE
         THEN
            FOR IDXACNTS IN 1 .. T_ACNTS_STATUS_INSERT_ACNO.COUNT
            LOOP
               W_TEST_ACNUM :=
                     T_ACNTS_STATUS_INSERT_ACNO (IDXACNTS)
                  || ' '
                  || T_ACNTS_STATUS_INSERT_STATUS (IDXACNTS);

               INSERT INTO ACNTSTATUS (ACNTSTATUS_ENTITY_NUM,
                                       ACNTSTATUS_INTERNAL_ACNUM,
                                       ACNTSTATUS_EFF_DATE,
                                       ACNTSTATUS_FLG,
                                       ACNTSTATUS_REMARKS1,
                                       ACNTSTATUS_REMARKS2,
                                       ACNTSTATUS_REMARKS3,
                                       ACNTSTATUS_ENTD_BY,
                                       ACNTSTATUS_ENTD_ON)
                    VALUES (V_ENTITY_NUM,
                            T_ACNTS_STATUS_INSERT_ACNO (IDXACNTS),
                            V_CBD,
                            T_ACNTS_STATUS_INSERT_STATUS (IDXACNTS),
                            'Auto Classification ',
                            ' ',
                            ' ',
                            V_USERID,
                            SYSDATE);

               W_TEST_ACNUM_PREV :=
                     T_ACNTS_STATUS_INSERT_ACNO (IDXACNTS)
                  || ' '
                  || T_ACNTS_STATUS_INSERT_STATUS (IDXACNTS);
            END LOOP;
         END IF;

         IF T_ACNTS_STATUS_UPDATE_ACNO.EXISTS (1) = TRUE
         THEN
            FORALL IDXACNTS IN 1 .. T_ACNTS_STATUS_UPDATE_ACNO.COUNT
               UPDATE ACNTSTATUS
                  SET ACNTSTATUS_INTERNAL_ACNUM =
                         T_ACNTS_STATUS_UPDATE_ACNO (IDXACNTS),
                      ACNTSTATUS_FLG = T_ACNTS_STATUS_UPDATE_STATUS (IDXACNTS),
                      ACNTSTATUS_REMARKS1 = 'Auto Classification',
                      ACNTSTATUS_LAST_MOD_BY = V_USERID,
                      ACNTSTATUS_LAST_MOD_ON = SYSDATE
                WHERE     ACNTSTATUS_ENTITY_NUM = V_ENTITY_NUM
                      AND ACNTSTATUS_INTERNAL_ACNUM =
                             T_ACNTS_STATUS_UPDATE_ACNO (IDXACNTS)
                      AND ACNTSTATUS_EFF_DATE = V_CBD;
         END IF;
      END IF;

      T_DORMANT_ACNT.DELETE;
      T_INOP_ACNT.DELETE;
      T_ACNTS.DELETE;
      T_ACNTS_STATUS.DELETE;
      T_RAPARAM.DELETE;
      T_ACNTS_FOR_UPDATE.DELETE;
      T_ACNTS_STATUS_CHECK.DELETE;
      T_ACNTS_STATUS_INSERT_ACNO.DELETE;
      T_ACNTS_STATUS_UPDATE_ACNO.DELETE;
      T_ACNTS_STATUS_INSERT_STATUS.DELETE;
      T_ACNTS_STATUS_UPDATE_ACNO.DELETE;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF TRIM (V_ERR_MSG) IS NULL
         THEN
            V_ERR_MSG := 'ERROR IN SP_DORINOPMARK';
            DBMS_OUTPUT.PUT_LINE (SQLERRM);
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERR_MSG;
         V_ERROR := V_ERR_MSG ;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'E',
                                      PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                      '',
                                      0);
         PKG_PB_GLOBAL.DETAIL_ERRLOG (
            V_ENTITY_NUM,
            'E',
               SUBSTR (SQLERRM, 1, 1000)
            || ' '
            || W_TEST_ACNUM_PREV
            || ' '
            || W_TEST_ACNUM,
            ' ',
            0);
   -- RAISE E_USEREXCEP;  -- REM Guna 28/07/2011
   END SP_DORINOPMARK;

   PROCEDURE CHECK_INPUT_VALUES
   IS
   BEGIN
      IF V_ENTITY_NUM = 0
      THEN
         V_ERROR := 'Entity Number is not specified';
      END IF;

      IF V_USER_ID IS NULL
      THEN
         V_ERROR := 'User ID is not specified';
      END IF;

      IF V_CBD IS NULL
      THEN
         V_ERROR := 'Current Business Date is not specified';
      END IF;
   END;


   PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                            P_BRN_CODE      IN NUMBER DEFAULT 0)
   IS
      L_BRN_CODE   NUMBER (6);
   BEGIN
      V_ENTITY_NUM := V_ENTITY_CODE;
      V_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;
      V_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

      CHECK_INPUT_VALUES;

      IF V_ERROR IS NULL
      THEN
         PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (V_ENTITY_NUM, P_BRN_CODE);

         FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
         LOOP
            L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

            IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (V_ENTITY_NUM,
                                                            L_BRN_CODE) =
                  FALSE
            THEN
               SP_DORINOPMARK (L_BRN_CODE);

               IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
               THEN
                  PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (
                     V_ENTITY_NUM,
                     L_BRN_CODE);
               END IF;

               PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (V_ENTITY_NUM);
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         IF V_ERROR IS NOT NULL
         THEN
            V_ERROR := SUBSTR ('ERROR IN PKG_DORINOPMARK ' || SQLERRM, 1, 500);
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERROR;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'E',
                                      PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                      ' ',
                                      0);
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'E',
                                      SUBSTR (SQLERRM, 1, 1000),
                                      ' ',
                                      0);
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'X',
                                      V_ENTITY_NUM,
                                      ' ',
                                      0);
   END;
END PKG_DORINOPMARK;
/