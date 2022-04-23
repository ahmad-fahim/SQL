CREATE OR REPLACE PACKAGE PKG_GLBALTRF
IS
   -- THIS CAN NOT BE RUN IN THREADED MODE I.E. NO BRANCH CODE PARAMETER
   -- BECAUSE BRANCH WISE PROCESSING DOESN'T MAKE MUCH SENSE TO THIS PROCESS
   PROCEDURE SP_GLBALTRF (
      P_ENTITY_NUM     IN NUMBER,
      P_PROCESS_DATE   IN PKG_COMMON_TYPES.DATE_T DEFAULT NULL,
      P_USER_ID        IN USERS.USER_ID%TYPE DEFAULT '',
      P_PNL_TRF        IN BOOLEAN DEFAULT FALSE);

   PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                            P_BRN_CODE      IN NUMBER DEFAULT 0);
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_GLBALTRF
IS
   V_ENTITY_NUM   ENTITYNUM.ENTITYNUM_NUMBER%TYPE;
   V_USER_ID      USERS.USER_ID%TYPE;
   V_CBD          MAINCONT.MN_CURR_BUSINESS_DATE%TYPE;
   V_ERROR        VARCHAR2 (1000);
   V_BRN_CODE     MBRN.MBRN_CODE%TYPE;
   V_BRN_NAME     MBRN.MBRN_NAME%TYPE;


   PROCEDURE SP_GLBALTRF (
      P_ENTITY_NUM     IN NUMBER,
      P_PROCESS_DATE   IN PKG_COMMON_TYPES.DATE_T DEFAULT NULL,
      P_USER_ID        IN USERS.USER_ID%TYPE DEFAULT '',
      P_PNL_TRF        IN BOOLEAN DEFAULT FALSE)
   IS
      V_PNL_TRF        PKG_COMMON_TYPES.SINGLE_CHAR
                          := CASE WHEN P_PNL_TRF = TRUE THEN '1' ELSE '0' END;
      V_PROCESS_DATE   PKG_COMMON_TYPES.DATE_T := P_PROCESS_DATE;
      V_PROC_DAY       PKG_COMMON_TYPES.NUMBER_T;
      V_EOM_PROC_DAY   PKG_COMMON_TYPES.NUMBER_T;
      V_PROC_DATE_QM   PKG_COMMON_TYPES.NUMBER_T;
      V_PROC_DATE_HM   PKG_COMMON_TYPES.NUMBER_T;
      V_PROC_DATE_YM   PKG_COMMON_TYPES.NUMBER_T;
      V_FIN_YEAR       PKG_COMMON_TYPES.NUMBER_T;
      V_BASE_CURR      INSTALL.INS_BASE_CURR_CODE%TYPE
         := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR (V_ENTITY_NUM);

      V_CBD_DAY        PKG_COMMON_TYPES.NUMBER_T
                          := TO_NUMBER (TO_CHAR (V_CBD, 'DD'));
      V_PROCESS_NAME   VARCHAR2 (100)
         := CASE
               WHEN TRIM (PKG_EODSOD_FLAGS.PV_PROCESS_NAME) IS NULL
               THEN
                  'PKG_GLBALTRF'
               ELSE
                  TRIM (PKG_EODSOD_FLAGS.PV_PROCESS_NAME)
            END;
      USR_EXCEP        EXCEPTION;



      PROCEDURE PROCESS (V_GL_CODES IN TYP_GL_ACC_CODES)
      IS
         V_GL_IDX                PLS_INTEGER;
         V_BRN_IDX               PLS_INTEGER;

         V_BALTRF_FREQ           GLBALTRF.GLBALTRF_BALTRF_FREQ%TYPE;
         V_MONTHLY_DAY           GLBALTRF.GLBALTRF_MONTHLY_DAY%TYPE;
         V_QHY_MONTH             GLBALTRF.GLBALTRF_QHY_MONTH%TYPE;
         V_QHY_DAY               GLBALTRF.GLBALTRF_QHY_DAY%TYPE;
         V_PENDING_MORE_MTHS     GLBALTRF.GLBALTRF_PEND_MORE_MTHS%TYPE;
         V_TRF_TO_GLACC_CODE     GLBALTRF.GLBALTRF_TRF_GLACC_CODE%TYPE;
         V_TRF_TO_GL_IBR_GL      GLMAST.GL_INTER_BRN_GL%TYPE;
         V_IBR_RESP_BRN_CODE     GLBALTRF.GLBALTRF_IBR_RESP_BRN%TYPE;
         V_IBR_DR_IBR_CODE       GLBALTRF.GLBALTRF_IBR_TRANCD%TYPE;
         V_IBR_CR_IBR_CODE       GLBALTRF.GLBALTRF_IBR_TRANCD_CR%TYPE;
         V_CORE_ACING_BRN_CODE   GLBALTRF.GLBALTRF_ACING_BRN_CODE%TYPE;
         V_TRF_NARRATION         GLBALTRF.GLBALTRF_TRF_NARRATION%TYPE;
         V_GL_BAL_AC             GLBBAL.GLBBAL_AC_BAL%TYPE;
         V_GL_BAL_BC             GLBBAL.GLBBAL_BC_BAL%TYPE;
         V_BAL_RETR_ERROR        PKG_COMMON_TYPES.STRING_T;
         V_TRN_INDX              PKG_COMMON_TYPES.NUMBER_T := 0;
         V_BATCH_NUMBER          PKG_COMMON_TYPES.NUMBER_T;
         V_ERR_CODE              VARCHAR2 (6) := NULL;
         V_ERR_MSG               VARCHAR2 (1000);


         PROCEDURE PROCESS_BRN_GL (GL_CODE GLBALTRF.GLBALTRF_GLACC_CODE%TYPE)
         IS
            V_IS_BAL_TRF_APPL   BOOLEAN := TRUE;

            FUNCTION CHECK_TRF_APPLICABLE
               RETURN BOOLEAN
            IS
               W_TRF_APPL   BOOLEAN := FALSE;
            BEGIN
               IF V_BALTRF_FREQ = 'D'
               THEN
                  W_TRF_APPL := TRUE;
               ELSIF V_BALTRF_FREQ = 'M'
               THEN
                  IF    (V_MONTHLY_DAY = 0 AND V_EOM_PROC_DAY = V_PROC_DAY)
                     OR (V_MONTHLY_DAY <> 0 AND V_MONTHLY_DAY = V_PROC_DAY)
                  THEN
                     W_TRF_APPL := TRUE;
                  END IF;
               ELSIF V_BALTRF_FREQ = 'Q'
               THEN
                  IF V_QHY_MONTH = V_PROC_DATE_QM
                  THEN
                     IF    (V_QHY_DAY = 0 AND V_EOM_PROC_DAY = V_PROC_DAY)
                        OR (V_QHY_DAY <> 0 AND V_QHY_DAY = V_PROC_DAY)
                     THEN
                        W_TRF_APPL := TRUE;
                     END IF;
                  END IF;
               ELSIF V_BALTRF_FREQ = 'H'
               THEN
                  IF V_QHY_MONTH = V_PROC_DATE_HM
                  THEN
                     IF    (V_QHY_DAY = 0 AND V_EOM_PROC_DAY = V_PROC_DAY)
                        OR (V_QHY_DAY <> 0 AND V_QHY_DAY = V_PROC_DAY)
                     THEN
                        W_TRF_APPL := TRUE;
                     END IF;
                  END IF;
               ELSIF V_BALTRF_FREQ = 'Y'
               THEN
                  IF V_QHY_MONTH = V_PROC_DATE_YM
                  THEN
                     IF    (V_QHY_DAY = 0 AND V_EOM_PROC_DAY = V_PROC_DAY)
                        OR (V_QHY_DAY <> 0 AND V_QHY_DAY = V_PROC_DAY)
                     THEN
                        W_TRF_APPL := TRUE;
                     END IF;
                  END IF;
               END IF;

               RETURN W_TRF_APPL;
            END CHECK_TRF_APPLICABLE;

            PROCEDURE SET_VOUCHER (P_CURR IN GLBBAL.GLBBAL_CURR_CODE%TYPE)
            IS
               V_FIRST_LEG_DR_CR   PKG_COMMON_TYPES.SINGLE_CHAR;
               V_NARRATION         PKG_COMMON_TYPES.STRING_T;
            BEGIN
               V_TRN_INDX := V_TRN_INDX + 1;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_ACING_BRN_CODE :=
                  V_BRN_CODE;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_INTERNAL_ACNUM := 0;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_GLACC_CODE :=
                  GL_CODE;

               IF V_GL_BAL_AC < 0 OR V_GL_BAL_BC < 0
               THEN
                  V_FIRST_LEG_DR_CR := 'C';
               ELSIF V_GL_BAL_AC > 0 OR V_GL_BAL_BC > 0
               THEN
                  V_FIRST_LEG_DR_CR := 'D';
               END IF;

               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_DB_CR_FLG :=
                  V_FIRST_LEG_DR_CR;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_TYPE_OF_TRAN := '1';
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_AMOUNT :=
                  ABS (V_GL_BAL_AC);
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_CURR_CODE := P_CURR;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_BASE_CURR_EQ_AMT :=
                  ABS (V_GL_BAL_BC);
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_BASE_CURR_CODE :=
                  V_BASE_CURR;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL1 :=
                  TRIM (SUBSTR (V_TRF_NARRATION, 1, 35));
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL2 :=
                  TRIM (SUBSTR (V_TRF_NARRATION, 36, 35));
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL3 :=
                  TRIM (SUBSTR (V_TRF_NARRATION, 72, 35));

               -----------

               V_TRN_INDX := V_TRN_INDX + 1;

               IF V_TRF_TO_GL_IBR_GL = '1' OR V_CORE_ACING_BRN_CODE = 0
               THEN
                  PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_ACING_BRN_CODE :=
                     V_BRN_CODE;
               ELSIF V_CORE_ACING_BRN_CODE <> 0
               THEN
                  PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_ACING_BRN_CODE :=
                     V_CORE_ACING_BRN_CODE;
               END IF;

               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_INTERNAL_ACNUM := 0;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_GLACC_CODE :=
                  V_TRF_TO_GLACC_CODE;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_DB_CR_FLG :=
                  CASE WHEN V_FIRST_LEG_DR_CR = 'D' THEN 'C' ELSE 'D' END;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_TYPE_OF_TRAN := '1';
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_AMOUNT :=
                  ABS (V_GL_BAL_AC);
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_CURR_CODE := P_CURR;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_BASE_CURR_EQ_AMT :=
                  ABS (V_GL_BAL_BC);
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_BASE_CURR_CODE :=
                  V_BASE_CURR;

               IF V_TRF_TO_GL_IBR_GL = '1'
               THEN
                  PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_ORIG_RESP := 'O';

                  IF V_GL_BAL_BC > 0
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_IBR_CODE :=
                        V_IBR_CR_IBR_CODE;
                  ELSIF V_GL_BAL_BC < 0
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_IBR_CODE :=
                        V_IBR_DR_IBR_CODE;
                  END IF;

                  PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_IBR_BRN_CODE :=
                     V_IBR_RESP_BRN_CODE;
               END IF;

               V_NARRATION :=
                  V_BRN_CODE || '-' || V_BRN_NAME || ' (' || GL_CODE || ')';

               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL1 :=
                  TRIM (SUBSTR (V_TRF_NARRATION, 1, 35));
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL2 :=
                  CASE
                     WHEN V_CORE_ACING_BRN_CODE <> 0
                     THEN
                        TRIM (SUBSTR (V_NARRATION, 1, 35))
                     ELSE
                        TRIM (SUBSTR (V_TRF_NARRATION, 36, 35))
                  END;
               PKG_AUTOPOST.PV_TRAN_REC (V_TRN_INDX).TRAN_NARR_DTL3 :=
                  CASE
                     WHEN V_CORE_ACING_BRN_CODE <> 0
                     THEN
                        TRIM (SUBSTR (V_NARRATION, 36, 35))
                     ELSE
                        TRIM (SUBSTR (V_TRF_NARRATION, 72, 35))
                  END;
            END SET_VOUCHER;

            PROCEDURE INSERT_GLBALTRFPOST (
               P_CURR   IN GLBBAL.GLBBAL_CURR_CODE%TYPE)
            IS
            BEGIN
               INSERT INTO GLBALTRFPOST (GLBALTRFP_ENTITY_NUM,
                                         GLBALTRFP_BRN_CODE,
                                         GLBALTRFP_GLACC_CODE,
                                         GLBALTRFP_CURR_CODE,
                                         GLBALTRFP_TRF_DATE,
                                         GLBALTRFP_TRF_AC_AMT,
                                         GLBALTRFP_TRF_BC_AMT,
                                         GLBALTRFP_BAL_ASON_DATE,
                                         GLBALTRFP_TRF_ACING_BRN,
                                         GLBALTRFP_TRF_TO_GLACC,
                                         POST_TRAN_BRN,
                                         POST_TRAN_DATE,
                                         POST_TRAN_BATCH_NUM)
                       VALUES (
                                 V_ENTITY_NUM,
                                 V_BRN_CODE,
                                 GL_CODE,
                                 P_CURR,
                                 V_PROCESS_DATE,
                                 V_GL_BAL_AC,
                                 V_GL_BAL_BC,
                                 V_PROCESS_DATE,
                                 CASE
                                    WHEN    V_TRF_TO_GL_IBR_GL = '1'
                                         OR V_CORE_ACING_BRN_CODE = 0
                                    THEN
                                       V_BRN_CODE
                                    WHEN V_CORE_ACING_BRN_CODE <> 0
                                    THEN
                                       V_CORE_ACING_BRN_CODE
                                    ELSE
                                       V_BRN_CODE
                                 END,
                                 V_TRF_TO_GLACC_CODE,
                                 V_BRN_CODE,
                                 V_CBD,
                                 0);
            EXCEPTION
               WHEN OTHERS
               THEN
                  PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                                   'E',
                                                   SUBSTR (SQLERRM, 1, 1000),
                                                   GL_CODE,
                                                   0,
                                                   V_BRN_CODE);
            END INSERT_GLBALTRFPOST;
         BEGIN
            --LOOKUP FOR ANY BRANCH SPECIFIC CONFIG
            BEGIN
               SELECT TRIM (GLBALTRF_BALTRF_FREQ),
                      NVL (GLBALTRF_MONTHLY_DAY, 0),
                      NVL (GLBALTRF_QHY_MONTH, 0),
                      NVL (GLBALTRF_QHY_DAY, 0),
                      NVL (GLBALTRF_PEND_MORE_MTHS, 0),
                      TRIM (GLBALTRF_TRF_GLACC_CODE),
                      (SELECT GL_INTER_BRN_GL
                         FROM EXTGL, GLMAST
                        WHERE     EXTGL_GL_HEAD = GL_NUMBER
                              AND EXTGL_ACCESS_CODE =
                                     TRIM (GLBALTRF_TRF_GLACC_CODE)),
                      NVL (GLBALTRF_IBR_RESP_BRN, 0),
                      TRIM (GLBALTRF_IBR_TRANCD),
                      TRIM (GLBALTRF_IBR_TRANCD_CR),
                      NVL (GLBALTRF_ACING_BRN_CODE, 0),
                      TRIM (GLBALTRF_TRF_NARRATION)
                 INTO V_BALTRF_FREQ,
                      V_MONTHLY_DAY,
                      V_QHY_MONTH,
                      V_QHY_DAY,
                      V_PENDING_MORE_MTHS,
                      V_TRF_TO_GLACC_CODE,
                      V_TRF_TO_GL_IBR_GL,
                      V_IBR_RESP_BRN_CODE,
                      V_IBR_DR_IBR_CODE,
                      V_IBR_CR_IBR_CODE,
                      V_CORE_ACING_BRN_CODE,
                      V_TRF_NARRATION
                 FROM GLBALTRF
                WHERE     GLBALTRF_ENTITY_NUM = V_ENTITY_NUM
                      AND NVL (GLBALTRF_BRN_CODE, 0) = V_BRN_CODE
                      AND NVL (GLBALTRF_AT_PNL_TRF, 0) =
                             DECODE (V_PNL_TRF, '1', 1, 0)
                      AND GLBALTRF_GLACC_CODE = GL_CODE
                      AND GLBALTRF_BALTRF_REQD = '1'
                      AND GLBALTRF_AUTH_ON IS NOT NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  SELECT TRIM (GLBALTRF_BALTRF_FREQ),
                         NVL (GLBALTRF_MONTHLY_DAY, 0),
                         NVL (GLBALTRF_QHY_MONTH, 0),
                         NVL (GLBALTRF_QHY_DAY, 0),
                         NVL (GLBALTRF_PEND_MORE_MTHS, 0),
                         TRIM (GLBALTRF_TRF_GLACC_CODE),
                         (SELECT GL_INTER_BRN_GL
                            FROM EXTGL, GLMAST
                           WHERE     EXTGL_GL_HEAD = GL_NUMBER
                                 AND EXTGL_ACCESS_CODE =
                                        TRIM (GLBALTRF_TRF_GLACC_CODE)),
                         NVL (GLBALTRF_IBR_RESP_BRN, 0),
                         TRIM (GLBALTRF_IBR_TRANCD),
                         TRIM (GLBALTRF_IBR_TRANCD_CR),
                         NVL (GLBALTRF_ACING_BRN_CODE, 0),
                         TRIM (GLBALTRF_TRF_NARRATION)
                    INTO V_BALTRF_FREQ,
                         V_MONTHLY_DAY,
                         V_QHY_MONTH,
                         V_QHY_DAY,
                         V_PENDING_MORE_MTHS,
                         V_TRF_TO_GLACC_CODE,
                         V_TRF_TO_GL_IBR_GL,
                         V_IBR_RESP_BRN_CODE,
                         V_IBR_DR_IBR_CODE,
                         V_IBR_CR_IBR_CODE,
                         V_CORE_ACING_BRN_CODE,
                         V_TRF_NARRATION
                    FROM GLBALTRF
                   WHERE     GLBALTRF_ENTITY_NUM = V_ENTITY_NUM
                         AND NVL (GLBALTRF_BRN_CODE, 0) = 0  -- FOR ALL BRANCH
                         AND NVL (GLBALTRF_AT_PNL_TRF, 0) =
                                DECODE (V_PNL_TRF, '1', 1, 0)
                         AND GLBALTRF_GLACC_CODE = GL_CODE
                         AND GLBALTRF_BALTRF_REQD = '1'
                         AND GLBALTRF_AUTH_ON IS NOT NULL;
            END;

            V_IS_BAL_TRF_APPL := CHECK_TRF_APPLICABLE;

            IF V_IS_BAL_TRF_APPL = TRUE
            THEN
               FOR BAL_CURR_REC
                  IN (SELECT DISTINCT GLBBAL_CURR_CODE
                        FROM GLBBAL
                       WHERE     GLBBAL_ENTITY_NUM = V_ENTITY_NUM
                             AND GLBBAL_YEAR = V_FIN_YEAR
                             AND GLBBAL_BRANCH_CODE = V_BRN_CODE
                             AND GLBBAL_GLACC_CODE = GL_CODE)
               LOOP
                  GET_ASON_GLBAL (V_ENTITY_NUM,
                                  V_BRN_CODE,
                                  GL_CODE,
                                  BAL_CURR_REC.GLBBAL_CURR_CODE,
                                  V_PROCESS_DATE,
                                  V_CBD,
                                  V_GL_BAL_AC,
                                  V_GL_BAL_BC,
                                  V_BAL_RETR_ERROR);

                  IF V_GL_BAL_AC <> 0 OR V_GL_BAL_BC <> 0
                  THEN
                     SET_VOUCHER (BAL_CURR_REC.GLBBAL_CURR_CODE);
                     INSERT_GLBALTRFPOST (BAL_CURR_REC.GLBBAL_CURR_CODE);
                  END IF;
               END LOOP;
            END IF;
         END PROCESS_BRN_GL;


         PROCEDURE SET_TRAN_KEY_VALUES
         IS
         BEGIN
            PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := V_BRN_CODE;
            PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := V_CBD;
            PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
            PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
         END SET_TRAN_KEY_VALUES;

         PROCEDURE SET_TRANBAT_VALUES
         IS
         BEGIN
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'GLBALTRFPOST';

            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY :=
                  V_ENTITY_NUM
               || '|'
               || V_BRN_CODE
               || '|'
               || '0'
               || '|'
               || TO_CHAR (V_CBD, 'DD-MM-YYYY');

            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 :=
               'Balance Trf from branch: ' || V_BRN_CODE;
         END SET_TRANBAT_VALUES;

         PROCEDURE UPDATE_GLBALTRFPOST
         IS
         BEGIN
            UPDATE GLBALTRFPOST
               SET POST_TRAN_BATCH_NUM = V_BATCH_NUMBER
             WHERE     GLBALTRFP_ENTITY_NUM = V_ENTITY_NUM
                   AND GLBALTRFP_BRN_CODE = V_BRN_CODE
                   AND GLBALTRFP_GLACC_CODE MEMBER OF V_GL_CODES
                   AND GLBALTRFP_TRF_DATE = V_PROCESS_DATE
                   AND POST_TRAN_BRN = V_BRN_CODE
                   AND POST_TRAN_DATE = V_CBD
                   AND NVL (POST_TRAN_BATCH_NUM, 0) = 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                                'E',
                                                SUBSTR (SQLERRM, 1, 1000),
                                                '',
                                                0,
                                                V_BRN_CODE);
         END UPDATE_GLBALTRFPOST;
      BEGIN
         V_GL_IDX := V_GL_CODES.FIRST;

         IF V_GL_IDX IS NOT NULL
         THEN
            -- SETTING AUTOPOST BATCH INFORMTION
            -- SETTING LEG COUNT TO ZERO FOR EACH INDIVIDUAL BRANCH
            V_TRN_INDX := 0;
            PKG_APOST_INTERFACE.SP_POSTING_BEGIN (V_ENTITY_NUM);
            PKG_POST_INTERFACE.G_PGM_NAME := V_PROCESS_NAME;
            SET_TRAN_KEY_VALUES;
            SET_TRANBAT_VALUES;

            -- POPULATE LEGS
            WHILE (V_GL_IDX IS NOT NULL)
            LOOP
               PROCESS_BRN_GL (V_GL_CODES (V_GL_IDX));
               V_GL_IDX := V_GL_CODES.NEXT (V_GL_IDX);
            END LOOP;

            -- POST THE TX FOR THIS BRANCH
            IF V_TRN_INDX > 0
            THEN
               PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH (V_ENTITY_NUM,
                                                         'A',
                                                         V_TRN_INDX,
                                                         0,
                                                         V_ERR_CODE,
                                                         V_ERR_MSG,
                                                         V_BATCH_NUMBER);

               IF (V_ERR_CODE <> '0000')
               THEN
                  V_ERROR := FN_GET_AUTOPOST_ERR_MSG (V_ENTITY_NUM);
                  PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                                   'E',
                                                   V_ERROR,
                                                   ' ',
                                                   0,
                                                   V_BRN_CODE);
                  RAISE USR_EXCEP;
               END IF;

               PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (V_ENTITY_NUM);
            END IF;

            V_GL_IDX := V_GL_CODES.FIRST;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                             'E',
                                             SUBSTR (SQLERRM, 1, 1000));
      END PROCESS;
   BEGIN
      V_ENTITY_NUM := P_ENTITY_NUM;
      V_USER_ID := TRIM (P_USER_ID);
      V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NUM);

      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);


      IF V_PROCESS_DATE IS NULL
      THEN
         V_PROCESS_DATE := V_CBD;
      END IF;

      IF V_USER_ID IS NULL
      THEN
         V_USER_ID := TRIM (PKG_EODSOD_FLAGS.PV_USER_ID);
      END IF;

      V_FIN_YEAR := SP_GETFINYEAR (V_ENTITY_NUM, V_PROCESS_DATE);

      V_PROC_DAY := TO_NUMBER (TO_CHAR (V_PROCESS_DATE, 'DD'));
      V_EOM_PROC_DAY := TO_NUMBER (TO_CHAR (LAST_DAY (V_PROCESS_DATE), 'DD'));
      V_PROC_DATE_QM := MOD (TO_NUMBER (TO_CHAR (V_PROCESS_DATE, 'MM')), 3);
      V_PROC_DATE_QM :=
         CASE WHEN V_PROC_DATE_QM = 0 THEN 3 ELSE V_PROC_DATE_QM END;
      V_PROC_DATE_HM := MOD (TO_NUMBER (TO_CHAR (V_PROCESS_DATE, 'MM')), 6);
      V_PROC_DATE_HM :=
         CASE WHEN V_PROC_DATE_HM = 0 THEN 6 ELSE V_PROC_DATE_HM END;
      V_PROC_DATE_YM := MOD (TO_NUMBER (TO_CHAR (V_PROCESS_DATE, 'MM')), 12);
      V_PROC_DATE_YM :=
         CASE WHEN V_PROC_DATE_YM = 0 THEN 12 ELSE V_PROC_DATE_YM END;

      --Tx WILL BE POSTED FOR EACH INDIVIDUAL BRANCH FOR AN ORDERED GROUP OF GLs AT A TIME
      -- SAME GL CAN NOT BE IN DIFFERENT ORDER, OTHERWISE IT MAY MALFUNCTION
      FOR REC
         IN (  SELECT CAST (COLLECT (GLBALTRF_GLACC_CODE) AS TYP_GL_ACC_CODES)
                         GL_CODES
                 FROM (SELECT DISTINCT GLBALTRF_TRF_ORDER, GLBALTRF_GLACC_CODE
                         FROM GLBALTRF
                        WHERE     GLBALTRF_ENTITY_NUM = V_ENTITY_NUM
                              AND NVL (GLBALTRF_AT_PNL_TRF, 0) =
                                     DECODE (V_PNL_TRF, '1', 1, 0)
                              AND GLBALTRF_BALTRF_REQD = '1'
                              AND GLBALTRF_AUTH_ON IS NOT NULL)
             GROUP BY GLBALTRF_TRF_ORDER
             ORDER BY GLBALTRF_TRF_ORDER)
      LOOP
         PROCESS (REC.GL_CODES);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                          'E',
                                          PKG_EODSOD_FLAGS.PV_ERROR_MSG);
         PKG_PB_GLOBAL.DETAIL_ERRLOG_NEW (V_ENTITY_NUM,
                                          'E',
                                          SUBSTR (SQLERRM, 1, 1000));
   END SP_GLBALTRF;


   PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                            P_BRN_CODE      IN NUMBER DEFAULT 0)
   IS
      L_BRN_CODE   NUMBER (6);
   BEGIN
      V_ENTITY_NUM := V_ENTITY_CODE;
      V_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;
      V_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;


      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (V_ENTITY_NUM, P_BRN_CODE);

      FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
      LOOP
         V_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

         BEGIN
            SELECT MBRN_NAME
              INTO V_BRN_NAME
              FROM MBRN
             WHERE MBRN_ENTITY_NUM = V_ENTITY_NUM AND MBRN_CODE = V_BRN_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_BRN_NAME := NULL;
         END;

         IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (V_ENTITY_NUM,
                                                         V_BRN_CODE) = FALSE
         THEN
            SP_GLBALTRF (V_ENTITY_CODE);

            IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
            THEN
               PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (V_ENTITY_NUM,
                                                                V_BRN_CODE);
            END IF;

            PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (V_ENTITY_NUM);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         IF V_ERROR IS NOT NULL
         THEN
            V_ERROR := SUBSTR ('ERROR IN PKG_GLBALTRF ' || SQLERRM, 1, 500);
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
END PKG_GLBALTRF;
/