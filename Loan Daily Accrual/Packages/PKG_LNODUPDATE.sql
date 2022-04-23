CREATE OR REPLACE PACKAGE PKG_LNODUPDATE IS

  -- AUTHOR  : VIJAYABASKAR.C
  -- CREATED : 8/8/2007 3:01:38 PM
  -- PURPOSE : STANDARDS FOR UPDATING OVERDUE DETAILS FOR LOAN ACCOUNTS
  --CHANGE BY ARUN 20-SEP-07

  PROCEDURE SP_LNODUPDATE(V_ENTITY_NUM    IN NUMBER,
                          P_BRN_CODE      IN NUMBER DEFAULT 0,
                          P_PROCESS_DATE  IN VARCHAR2 DEFAULT NULL,
                          P_CURR_BUS_DATE IN VARCHAR2 DEFAULT NULL,
                          P_SESS_USER_ID  IN VARCHAR2 DEFAULT NULL);
  --PROCEDURE UPDATE_LNODCNTL_GLOBAL(V_ENTITY_NUM IN NUMBER);

END PKG_LNODUPDATE;
/
CREATE OR REPLACE PACKAGE BODY PKG_LNODUPDATE AS
  V_GLOB_ENTITY_NUM NUMBER(6); -- A GLOBAL VARIABLE FOR ASSIGNING ENTITY NUMBER ( ADDED BY TAMIM )
  W_ACNT_BRN_CODE   NUMBER(6);
  W_PROCESS_DATE    DATE;
  V_SESS_USER_ID    VARCHAR2(8);
  W_COUNT           NUMBER(5) DEFAULT 0;
  W_ERROR_MSG       VARCHAR2(1300);
  E_USER_EXCEP EXCEPTION;
  W_SQL_OD                  VARCHAR2(1300);
  W_SQL                     VARCHAR2(2300);
  W_CBD                     DATE;
  L_LAST_OD_UPDATE_DATE     DATE;
  W_IN_BRANCH_CODE          NUMBER(6);
  W_BRN_CODE                NUMBER(6);
  V_IS_VALID                BOOLEAN; -- ALAM
  V_LNDP_DP_VALID_UPTO_DATE DATE;
  -- FETCH_LOANACNTS CALCULATION FIELDS
  V_ACNTS_INTERNAL_ACNUM      NUMBER(14);
  V_ACNTS_PROD_CODE           NUMBER(4);
  V_ACNTS_CURR_CODE           VARCHAR2(3);
  V_LIMIT_EXPIRY_DATE         DATE;
  V_LIMIT_DP_REQD             VARCHAR2(1);
  V_ACASLL_CLINET_NUM         NUMBER(12);
  V_ACASLL_LIMITLINE_NUM      NUMBER(12);
  W_LIMIT_EXPIRY_DATE         DATE;
  W_LIMIT_DP_REQD             VARCHAR2(1);
  W_ACASLL_CLINET_NUM         NUMBER(12);
  W_ACASLL_LIMITLINE_NUM      NUMBER(12);
  W_OPENING_DATE              DATE;
  W_ENTD_ON                   DATE;
  W_FIN_YEAR                  NUMBER(4);
  W_PRODUCT_FOR_RUN_ACS       VARCHAR(1) := '';
  W_LAST_OD_UPDATE_DATE       DATE;
  W_CURR_BUS_DATE             TIMESTAMP;
  V_LNPRD_INT_RECOVERY_OPTION CHAR(1);
  ----
  W_ASON_DATE        DATE;
  W_ACTUAL_LIMIT_AMT NUMBER(18, 3);
  W_ACTUAL_DP_AMT    NUMBER(18, 3);
  W_ERROR            VARCHAR2(1300);

  --=== OD Calc Related Fields.
  W_OD_CALC_FLG     NUMBER(1);
  W_REPH_ON_AMT     NUMBER(18, 3);
  W_TOT_DISB_AMOUNT NUMBER(18, 3);
  W_OS_AMT          NUMBER(18, 3) DEFAULT 0;
  W_OD_AMT          NUMBER(18, 3) DEFAULT 0;
  W_OD_DATE         DATE DEFAULT NULL;
  W_LIMIT_AMT       NUMBER(18, 3) DEFAULT 0;
  W_SANC_LIMIT_AMT  NUMBER(18, 3) DEFAULT 0;
  W_DP_AMT          NUMBER(18, 3) DEFAULT 0;
  W_PRIN_OD_AMT     NUMBER(18, 3) DEFAULT 0;
  W_PRIN_OD_DATE    DATE DEFAULT NULL;
  W_INT_OD_AMT      NUMBER(18, 3) DEFAULT 0;
  W_INT_OD_DATE     DATE DEFAULT NULL;
  W_CHGS_OD_AMT     NUMBER(18, 3) DEFAULT 0;
  W_CHGS_OD_DATE    DATE DEFAULT NULL;
  W_LIMIT_CHECK_AMT NUMBER(18, 3) DEFAULT 0;
  W_MIG_DATE        DATE;
  R_IDX             NUMBER := 0;

  --===

  TYPE TY_LNOD_REC IS RECORD(
    R_ACNTS_INTERNAL_ACNUM NUMBER(14),
    R_PROCESS_DATE         DATE,
    R_ACNTS_CURR_CODE      VARCHAR2(3 BYTE),
    R_OS_AMT               NUMBER(18, 3),
    R_SANC_LIMIT_AMT       NUMBER(18, 3),
    R_DP_AMT               NUMBER(18, 3),
    R_LIMIT_CHECK_AMT      NUMBER(18, 3),
    R_OD_AMT               NUMBER(18, 3),
    R_OD_DATE              DATE,
    R_PRIN_OD_AMT          NUMBER(18, 3),
    R_PRIN_OD_DATE         DATE,
    R_INT_OD_AMT           NUMBER(18, 3),
    R_INT_OD_DATE          DATE,
    R_CHGS_OD_AMT          NUMBER(18, 3),
    R_CHGS_OD_DATE         DATE,
    R_SESS_USER_ID         VARCHAR2(8),
    R_CURR_BUS_DATE        DATE,
    R_ACTUAL_OD_AMT        NUMBER(18, 3),
    R_REPH_ON_AMT          NUMBER(18, 3),
    R_TOT_DISB_AMOUNT      NUMBER(18, 3));

  TYPE TAB_LNOD_REC IS TABLE OF TY_LNOD_REC INDEX BY PLS_INTEGER;

  IDX_REC_LNOD TAB_LNOD_REC;

  TYPE TY_ACNTS_REC IS RECORD(
    V_INTERNAL_ACNUM      NUMBER(14),
    V_ACNT_BRN_CODE       NUMBER(6),
    V_PROD_CODE           NUMBER(4),
    V_CURR_CODE           VARCHAR2(3),
    V_OPENING_DATE        DATE,
    V_ENTD_ON             DATE,
    V_INT_RECOVERY_OPTION CHAR(1),
    V_PRODUCT_FOR_RUN_ACS VARCHAR(1),
    V_ACASLLDTL_CLIENT_NUM ACASLLDTL.ACASLLDTL_CLIENT_NUM%TYPE,
    V_ACASLLDTL_LIMIT_LINE_NUM ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM%TYPE,
    V_LMTLINE_LIMIT_EXPIRY_DATE DATE);

  TYPE TAB_ACNTS_REC IS TABLE OF TY_ACNTS_REC INDEX BY PLS_INTEGER;

  IDX_REC_ACNTS TAB_ACNTS_REC;

  PROCEDURE INIT_PARA IS
  BEGIN
    W_SQL_OD                  := '';
    W_SQL                     := '';
    W_PROCESS_DATE            := NULL;
    W_CURR_BUS_DATE           := NULL;
    W_LAST_OD_UPDATE_DATE     := NULL;
    W_ERROR_MSG               := '';
    V_SESS_USER_ID            := '';
    V_LNDP_DP_VALID_UPTO_DATE := NULL;
    V_ACNTS_INTERNAL_ACNUM    := 0;
    V_ACNTS_PROD_CODE         := 0;
    V_ACNTS_CURR_CODE         := '';
    V_LIMIT_EXPIRY_DATE       := NULL;
    V_LIMIT_DP_REQD           := '';
    V_ACASLL_CLINET_NUM       := 0;
    V_ACASLL_LIMITLINE_NUM    := 0;
    W_LIMIT_EXPIRY_DATE       := NULL;
    W_LIMIT_DP_REQD           := '';
    W_ACASLL_CLINET_NUM       := 0;
    W_ACASLL_LIMITLINE_NUM    := 0;
    W_COUNT                   := 0;
    W_OS_AMT                  := 0;
    W_OD_AMT                  := 0;
    W_OD_DATE                 := NULL;
    W_LIMIT_AMT               := 0;
    W_SANC_LIMIT_AMT          := 0;
    W_DP_AMT                  := 0;
    W_PRIN_OD_AMT             := 0;
    W_PRIN_OD_DATE            := NULL;
    W_INT_OD_AMT              := 0;
    W_INT_OD_DATE             := NULL;
    W_CHGS_OD_AMT             := 0;
    W_CHGS_OD_DATE            := NULL;
    W_LIMIT_CHECK_AMT         := 0;
    --W_DAYS                    := 0;
    W_CBD                       := NULL;
    W_BRN_CODE                  := 0;
    L_LAST_OD_UPDATE_DATE       := NULL;
    W_FIN_YEAR                  := 0;
    V_LNPRD_INT_RECOVERY_OPTION := NULL;
  END INIT_PARA;

  PROCEDURE CHECK_INPUTS(P_BRN_CODE      IN NUMBER DEFAULT 0,
                         P_PROCESS_DATE  IN VARCHAR2 DEFAULT NULL,
                         P_CURR_BUS_DATE IN VARCHAR2 DEFAULT NULL,
                         P_SESS_USER_ID  IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    W_IN_BRANCH_CODE := 0;
  
    IF NVL(P_BRN_CODE, 0) <> 0 THEN
      W_IN_BRANCH_CODE := P_BRN_CODE;
    END IF;
  
    IF (P_PROCESS_DATE IS NULL) THEN
      W_PROCESS_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
    ELSE
      W_PROCESS_DATE := TO_DATE(P_PROCESS_DATE, 'DD-MM-YYYY');
    END IF;
  
    IF (P_CURR_BUS_DATE IS NULL) THEN
      W_CURR_BUS_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
    ELSE
      W_CURR_BUS_DATE := TO_DATE(P_CURR_BUS_DATE, 'DD-MM-YYYY');
    END IF;
  
    IF (P_CURR_BUS_DATE IS NULL) THEN
      W_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
    ELSE
      W_CBD := TO_DATE(P_CURR_BUS_DATE, 'DD-MM-YYYY');
    END IF;
  
    IF (P_SESS_USER_ID IS NULL) THEN
      V_SESS_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;
    ELSE
      V_SESS_USER_ID := P_SESS_USER_ID;
    END IF;
  
    IF (W_PROCESS_DATE IS NULL) THEN
      W_ERROR_MSG := 'PROCESS DATE IS NOT SPECIFIED';
      RAISE E_USER_EXCEP;
    END IF;
  
    IF (W_CURR_BUS_DATE IS NULL) THEN
      W_ERROR_MSG := 'CURRENT BUSINESS DATE IS NOT SPECIFIED';
      RAISE E_USER_EXCEP;
    END IF;
  
    IF (V_SESS_USER_ID IS NULL) THEN
      W_ERROR_MSG := 'USER ID IS NOT SPECIFIED';
      RAISE E_USER_EXCEP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN CHECK_INPUTS';
      RAISE E_USER_EXCEP;
  END CHECK_INPUTS;

  -- Update Related Tables
  PROCEDURE UPDATE_LNOD IS
  BEGIN
    FORALL IND IN IDX_REC_LNOD.FIRST .. IDX_REC_LNOD.LAST
      INSERT INTO LNOD
        (LNOD_ENTITY_NUM,
         LNOD_INTERNAL_ACNUM,
         LNOD_LATEST_EFF_DATE,
         LNOD_CURR,
         LNOD_OS_BAL,
         LNOD_SANC_LIMIT_AMT,
         LNOD_DP_AMT,
         LNOD_LIMIT_CHK_AMT,
         LNOD_OD_AMT,
         LNOD_OD_DATE,
         LNOD_PRIN_OD_AMT,
         LNOD_PRIN_OD_DATE,
         LNOD_INT_OD_AMT,
         LNOD_INT_OD_DATE,
         LNOD_CHGS_OD_AMT,
         LNOD_CHGS_OD_DATE,
         LNOD_PROC_BY,
         LNOD_PROC_ON,
         LNOD_INT_ACCR_OD_AMT,
         LNOD_ACCR_INT_OD_DATE,
         LNOD_ACTUAL_DUE_AMT,
         LNOD_REPH_ON_AMT,
         LNOD_TOT_DISB_AMOUNT)
      VALUES
        (V_GLOB_ENTITY_NUM,
         IDX_REC_LNOD     (IND).R_ACNTS_INTERNAL_ACNUM,
         IDX_REC_LNOD     (IND).R_PROCESS_DATE,
         IDX_REC_LNOD     (IND).R_ACNTS_CURR_CODE,
         IDX_REC_LNOD     (IND).R_OS_AMT,
         IDX_REC_LNOD     (IND).R_SANC_LIMIT_AMT,
         IDX_REC_LNOD     (IND).R_DP_AMT,
         IDX_REC_LNOD     (IND).R_LIMIT_CHECK_AMT,
         IDX_REC_LNOD     (IND).R_OD_AMT,
         IDX_REC_LNOD     (IND).R_OD_DATE,
         IDX_REC_LNOD     (IND).R_PRIN_OD_AMT,
         IDX_REC_LNOD     (IND).R_PRIN_OD_DATE,
         IDX_REC_LNOD     (IND).R_INT_OD_AMT,
         IDX_REC_LNOD     (IND).R_INT_OD_DATE,
         IDX_REC_LNOD     (IND).R_CHGS_OD_AMT,
         IDX_REC_LNOD     (IND).R_CHGS_OD_DATE,
         IDX_REC_LNOD     (IND).R_SESS_USER_ID,
         IDX_REC_LNOD     (IND).R_CURR_BUS_DATE,
         0,
         NULL,
         IDX_REC_LNOD     (IND).R_ACTUAL_OD_AMT,
         IDX_REC_LNOD     (IND).R_REPH_ON_AMT,
         IDX_REC_LNOD     (IND).R_TOT_DISB_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN UPDATE_LNOD';
      RAISE E_USER_EXCEP;
  END UPDATE_LNOD;

  PROCEDURE UPDATE_LNODHIST IS
  BEGIN
    FORALL IND IN IDX_REC_LNOD.FIRST .. IDX_REC_LNOD.LAST
      INSERT INTO LNODHIST
        (LNODHIST_ENTITY_NUM,
         LNODHIST_INTERNAL_ACNUM,
         LNODHIST_EFF_DATE,
         LNODHIST_CURR,
         LNODHIST_OS_BAL,
         LNODHIST_SANC_LIMIT_AMT,
         LNODHIST_DP_AMT,
         LNODHIST_LIMIT_CHK_AMT,
         LNODHIST_OD_AMT,
         LNODHIST_OD_DATE,
         LNODHIST_PRIN_OD_AMT,
         LNODHIST_PRIN_OD_DATE,
         LNODHIST_INT_OD_AMT,
         LNODHIST_INT_OD_DATE,
         LNODHIST_CHGS_OD_AMT,
         LNODHIST_CHGS_OD_DATE,
         LNODHIST_PROC_BY,
         LNODHIST_PROC_ON,
         LNODHIST_INT_ACCR_OD_AMT,
         LNODHIST_ACCR_INT_OD_DATE,
         LNODHIST_ACTUAL_DUE_AMT,
         LNODHIST_REPH_ON_AMT,
         LNODHIST_TOT_DISB_AMOUNT)
      VALUES
        (V_GLOB_ENTITY_NUM,
         IDX_REC_LNOD     (IND).R_ACNTS_INTERNAL_ACNUM,
         IDX_REC_LNOD     (IND).R_PROCESS_DATE,
         IDX_REC_LNOD     (IND).R_ACNTS_CURR_CODE,
         IDX_REC_LNOD     (IND).R_OS_AMT,
         IDX_REC_LNOD     (IND).R_SANC_LIMIT_AMT,
         IDX_REC_LNOD     (IND).R_DP_AMT,
         IDX_REC_LNOD     (IND).R_LIMIT_CHECK_AMT,
         IDX_REC_LNOD     (IND).R_OD_AMT,
         IDX_REC_LNOD     (IND).R_OD_DATE,
         IDX_REC_LNOD     (IND).R_PRIN_OD_AMT,
         IDX_REC_LNOD     (IND).R_PRIN_OD_DATE,
         IDX_REC_LNOD     (IND).R_INT_OD_AMT,
         IDX_REC_LNOD     (IND).R_INT_OD_DATE,
         IDX_REC_LNOD     (IND).R_CHGS_OD_AMT,
         IDX_REC_LNOD     (IND).R_CHGS_OD_DATE,
         IDX_REC_LNOD     (IND).R_SESS_USER_ID,
         IDX_REC_LNOD     (IND).R_CURR_BUS_DATE,
         0,
         NULL,
         IDX_REC_LNOD     (IND).R_ACTUAL_OD_AMT,
         IDX_REC_LNOD     (IND).R_REPH_ON_AMT,
         IDX_REC_LNOD     (IND).R_TOT_DISB_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN UPDATE_LNODHIST';
      RAISE E_USER_EXCEP;
  END UPDATE_LNODHIST;

  PROCEDURE UPDATE_LNODCNTL IS
  BEGIN
    SELECT COUNT(*)
      INTO W_COUNT
      FROM LNODCNTL
     WHERE LNODCNTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
       AND LNODCNTL_NUM = '1';
  
    IF (W_COUNT = 0) THEN
      INSERT INTO LNODCNTL
      VALUES
        (V_GLOB_ENTITY_NUM, 1, W_PROCESS_DATE, V_SESS_USER_ID);
    ELSE
      UPDATE LNODCNTL
         SET LNODCNTL_LAST_PROC_DATE = W_PROCESS_DATE,
             LNODCNTL_PROC_BY        = V_SESS_USER_ID
       WHERE LNODCNTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LNODCNTL_NUM = '1';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      W_ERROR_MSG := 'ERROR IN UPDATE_LNODCNTL';
      RAISE E_USER_EXCEP;
  END UPDATE_LNODCNTL;

  /*   Calculate Overdue Amount.    */

  PROCEDURE SP_GET_OVERDUE IS
    V_TIME          VARCHAR2(10);
    V_TEMP_DATE     VARCHAR2(21);
    W_OD_DATE1      VARCHAR2(10);
    W_PRIN_OD_DATE1 VARCHAR2(10);
    W_INT_OD_DATE1  VARCHAR2(10);
    W_CHGS_OD_DATE1 VARCHAR2(10);
  BEGIN
    W_OD_CALC_FLG     := 1;
    W_REPH_ON_AMT     := 0;
    W_TOT_DISB_AMOUNT := 0;
  
    PKG_LNOVERDUE.SP_LNOVERDUE(V_GLOB_ENTITY_NUM,
                               V_ACNTS_INTERNAL_ACNUM,
                               TO_CHAR(W_PROCESS_DATE, 'DD-MM-YYYY'),
                               TO_CHAR(W_CURR_BUS_DATE, 'DD-MM-YYYY'),
                               W_ERROR_MSG,
                               W_OS_AMT,
                               W_SANC_LIMIT_AMT,
                               W_DP_AMT,
                               W_LIMIT_AMT,
                               W_OD_AMT,
                               W_OD_DATE1,
                               W_PRIN_OD_AMT,
                               W_PRIN_OD_DATE1,
                               W_INT_OD_AMT,
                               W_INT_OD_DATE1,
                               W_CHGS_OD_AMT,
                               W_CHGS_OD_DATE1,
                               ---- ADDED BY TAMIM
                               V_ACNTS_CURR_CODE,
                               W_OPENING_DATE,
                               W_MIG_DATE,
                               V_ACNTS_PROD_CODE,
                               V_LNPRD_INT_RECOVERY_OPTION,
                               W_PRODUCT_FOR_RUN_ACS,
                               W_LIMIT_EXPIRY_DATE,
                               W_ACASLL_CLINET_NUM,
                               W_ACASLL_LIMITLINE_NUM,
                               1 --- passed as Caller flag
                               );
  
    IF (W_ERROR_MSG IS NOT NULL) THEN
      RAISE E_USER_EXCEP;
    END IF;
  
    W_REPH_ON_AMT     := PKG_LNOVERDUE.P_REPH_ON_AMT;
    W_TOT_DISB_AMOUNT := PKG_LNOVERDUE.P_TOT_DISB_AMOUNT;
    W_OD_DATE         := TO_DATE(W_OD_DATE1, 'DD-MM-RR');
    W_PRIN_OD_DATE    := TO_DATE(W_PRIN_OD_DATE1, 'DD-MM-YYYY');
    W_INT_OD_DATE     := TO_DATE(W_INT_OD_DATE1, 'DD-MM-YYYY');
    W_CHGS_OD_DATE    := TO_DATE(W_CHGS_OD_DATE1, 'DD-MM-YYYY');
  
    IF (W_LIMIT_AMT > W_DP_AMT) THEN
      W_LIMIT_CHECK_AMT := W_DP_AMT;
    ELSE
      W_LIMIT_CHECK_AMT := W_LIMIT_AMT;
    END IF;
  
    <<GET_DATE_FORMAT>>
    BEGIN
      SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') INTO V_TIME FROM DUAL;
    
      V_TEMP_DATE     := TO_CHAR(W_CURR_BUS_DATE, 'DD-MM-YYYY') || ' ' ||
                         V_TIME;
      W_CURR_BUS_DATE := TO_TIMESTAMP(V_TEMP_DATE, 'DD-MM-YYYY HH24:MI:SS');
    END GET_DATE_FORMAT;
  
    /*
      DBMS_OUTPUT.PUT_LINE('********************************************');
      DBMS_OUTPUT.PUT_LINE('W_ERROR_MSG            : = ' || W_ERROR_MSG);
      DBMS_OUTPUT.PUT_LINE('W_OS_AMT               : = ' || W_OS_AMT);
      DBMS_OUTPUT.PUT_LINE('W_SANC_LIMIT_AMT       : = ' || W_SANC_LIMIT_AMT);
      DBMS_OUTPUT.PUT_LINE('W_DP_AMT               : = ' || W_DP_AMT);
      DBMS_OUTPUT.PUT_LINE('W_LIMIT_AMT            : = ' || W_LIMIT_AMT);
      DBMS_OUTPUT.PUT_LINE('W_OD_AMT               : = ' || W_OD_AMT);
      DBMS_OUTPUT.PUT_LINE('W_OD_DATE1             : = ' || W_OD_DATE1);
      DBMS_OUTPUT.PUT_LINE('W_PRIN_OD_AMT          : = ' || W_PRIN_OD_AMT);
      DBMS_OUTPUT.PUT_LINE('W_PRIN_OD_DATE1        : = ' || W_PRIN_OD_DATE1);
      DBMS_OUTPUT.PUT_LINE('W_INT_OD_AMT           : = ' || W_INT_OD_AMT);
      DBMS_OUTPUT.PUT_LINE('W_INT_OD_DATE1         : = ' || W_INT_OD_DATE1);
      DBMS_OUTPUT.PUT_LINE('W_CHGS_OD_AMT          : = ' || W_CHGS_OD_AMT);
      DBMS_OUTPUT.PUT_LINE('W_CHGS_OD_DATE1        : = ' || W_CHGS_OD_DATE1);
      DBMS_OUTPUT.PUT_LINE('********************************************');
    
    */
  
    BEGIN
      R_IDX := R_IDX + 1;
    
      IDX_REC_LNOD(R_IDX).R_ACNTS_INTERNAL_ACNUM := V_ACNTS_INTERNAL_ACNUM;
      IDX_REC_LNOD(R_IDX).R_PROCESS_DATE := W_PROCESS_DATE;
      IDX_REC_LNOD(R_IDX).R_ACNTS_CURR_CODE := V_ACNTS_CURR_CODE;
      IDX_REC_LNOD(R_IDX).R_OS_AMT := W_OS_AMT;
      IDX_REC_LNOD(R_IDX).R_SANC_LIMIT_AMT := W_SANC_LIMIT_AMT;
      IDX_REC_LNOD(R_IDX).R_DP_AMT := W_DP_AMT;
      IDX_REC_LNOD(R_IDX).R_LIMIT_CHECK_AMT := W_LIMIT_CHECK_AMT;
      IDX_REC_LNOD(R_IDX).R_OD_AMT := W_OD_AMT;
      IDX_REC_LNOD(R_IDX).R_OD_DATE := W_OD_DATE;
      IDX_REC_LNOD(R_IDX).R_PRIN_OD_AMT := W_PRIN_OD_AMT;
      IDX_REC_LNOD(R_IDX).R_PRIN_OD_DATE := W_PRIN_OD_DATE;
      IDX_REC_LNOD(R_IDX).R_INT_OD_AMT := W_INT_OD_AMT;
      IDX_REC_LNOD(R_IDX).R_INT_OD_DATE := W_INT_OD_DATE;
      IDX_REC_LNOD(R_IDX).R_CHGS_OD_AMT := W_CHGS_OD_AMT;
      IDX_REC_LNOD(R_IDX).R_CHGS_OD_DATE := W_CHGS_OD_DATE;
      IDX_REC_LNOD(R_IDX).R_SESS_USER_ID := V_SESS_USER_ID;
      IDX_REC_LNOD(R_IDX).R_CURR_BUS_DATE := W_CURR_BUS_DATE;
      IDX_REC_LNOD(R_IDX).R_ACTUAL_OD_AMT := NVL(PKG_LNOVERDUE.P_ACTUAL_OD_AMT,
                                                 0);
      IDX_REC_LNOD(R_IDX).R_REPH_ON_AMT := W_REPH_ON_AMT;
      IDX_REC_LNOD(R_IDX).R_TOT_DISB_AMOUNT := W_TOT_DISB_AMOUNT;
    END;
    --UPDATE_LNOD;
    --UPDATE_LNODHIST;
  EXCEPTION
    WHEN OTHERS THEN
      IF (W_ERROR_MSG IS NULL) THEN
        W_ERROR_MSG := 'ERROR IN SP_GET_OVERDUE';
      END IF;
    
      RAISE E_USER_EXCEP;
  END SP_GET_OVERDUE;

  PROCEDURE CHECKLIMIT_PROC  IS
  BEGIN
    /*   <<READ_ACASLLDTL>>
    BEGIN
      SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
        INTO V_ACASLL_CLINET_NUM, V_ACASLL_LIMITLINE_NUM
        FROM ACASLLDTL
       WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM 
         AND ACASLLDTL_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM;
    
      <<READ_LIMITLINE>>
      BEGIN
        SELECT LMTLINE_LIMIT_EXPIRY_DATE, LMTLINE_DP_REQD
          INTO V_LIMIT_EXPIRY_DATE, V_LIMIT_DP_REQD
          FROM LIMITLINE
         WHERE LMTLINE_ENTITY_NUM = V_GLOB_ENTITY_NUM 
           AND LMTLINE_CLIENT_CODE = V_ACASLL_CLINET_NUM
           AND LMTLINE_NUM = V_ACASLL_LIMITLINE_NUM;
    
           */
    ------ Commented by Tamim
  
    --<<READ_ACASLLDTL_LIMITLINE>> ---- ADDED BY TAMIM
   -- BEGIN
    /*
      SELECT ACASLLDTL_CLIENT_NUM,
             ACASLLDTL_LIMIT_LINE_NUM,
             LMTLINE_LIMIT_EXPIRY_DATE
        INTO W_ACASLL_CLINET_NUM,
             W_ACASLL_LIMITLINE_NUM,
             W_LIMIT_EXPIRY_DATE
        FROM ACASLLDTL, LIMITLINE
       WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND LMTLINE_ENTITY_NUM = V_GLOB_ENTITY_NUM
         AND ACASLLDTL_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM
         AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
         AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM;
    */
      <<COMPARE_DATES>>
      BEGIN
        IF W_PRODUCT_FOR_RUN_ACS = 1 THEN
          --IF W_LAST_OD_UPDATE_DATE IS NOT NULL THEN
          --  IF ((W_LIMIT_EXPIRY_DATE > W_LAST_OD_UPDATE_DATE) AND
          IF (W_LIMIT_EXPIRY_DATE <= W_PROCESS_DATE) THEN
            SP_GET_OVERDUE;
          END IF;
        ELSE
          SP_GET_OVERDUE;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (W_ERROR_MSG IS NULL) THEN
            W_ERROR_MSG := 'ERROR IN COMPARE_DATES';
          END IF;
        
          RAISE E_USER_EXCEP;
      END COMPARE_DATES;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (W_ERROR_MSG IS NULL) THEN
          W_ERROR_MSG := '';
        END IF;
      WHEN OTHERS THEN
        IF (W_ERROR_MSG IS NULL) THEN
          W_ERROR_MSG := 'ERROR IN READ_ACASLLDTL_LIMITLINE';
        END IF;
      
        RAISE E_USER_EXCEP;
   -- END READ_ACASLLDTL_LIMITLINE;
  END CHECKLIMIT_PROC;

  /*    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (W_ERROR_MSG IS NULL) THEN
          W_ERROR_MSG := '';
        END IF;
      WHEN OTHERS THEN
        IF (W_ERROR_MSG IS NULL) THEN
          W_ERROR_MSG := 'ERROR IN READ_LIMITLINE';
        END IF;
        RAISE E_USER_EXCEP;
    END READ_LIMITLINE;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      IF (W_ERROR_MSG IS NULL) THEN
        W_ERROR_MSG := 'ERROR IN READ_ACASLLDTL';
      END IF;
      RAISE E_USER_EXCEP;
  END READ_ACASLLDTL;  */

  ------ Commented by Tamim

  PROCEDURE FETCH_LOANACNTS IS
  BEGIN
    <<READ_ACNTS>>
    BEGIN
      W_SQL := 'SELECT ACNTS_INTERNAL_ACNUM,
                       ACNTS_BRN_CODE,
                       ACNTS_PROD_CODE,
                       ACNTS_CURR_CODE,
                       ACNTS_OPENING_DATE,
                       TRUNC(LNACNT_ENTD_ON) LNACNT_ENTD_ON,
                       LNPRD_INT_RECOVERY_OPTION,
                       PRODUCT_FOR_RUN_ACS,
                       ACASLLDTL_CLIENT_NUM,
                       ACASLLDTL_LIMIT_LINE_NUM,
                       LMTLINE_LIMIT_EXPIRY_DATE
                  FROM LNPRODPM, ACNTS, LOANACNTS, PRODUCTS, ACASLLDTL, LIMITLINE
                       WHERE LNACNT_ENTITY_NUM = :1
                       AND ACNTS_ENTITY_NUM = :2
                       AND ACASLLDTL_ENTITY_NUM = ACNTS_ENTITY_NUM
                       AND LMTLINE_ENTITY_NUM = ACNTS_ENTITY_NUM
                       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                       AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
                       AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
                       AND ACNTS_INTERNAL_ACNUM NOT IN (SELECT L.LNWRTOFF_ACNT_NUM FROM LNWRTOFF L )
                       AND ACNTS_PROD_CODE = PRODUCT_CODE
                       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > :3 )
                       AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
                       AND ACNTS_AUTH_ON IS NOT NULL
                       AND ACNTS_PROD_CODE = LNPRD_PROD_CODE
                       AND LNPRD_INT_APPL_FREQ <> ''I'' 
                       AND ACNTS_BRN_CODE = :W_BRN_CODE
                       ORDER BY ACNTS_INTERNAL_ACNUM ';
    
    
      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO IDX_REC_ACNTS
        USING V_GLOB_ENTITY_NUM, V_GLOB_ENTITY_NUM, W_CBD, W_BRN_CODE;
    
      --  DBMS_OUTPUT.put_line(IDX_REC_ACNTS.COUNT);
    
      IF IDX_REC_ACNTS.FIRST IS NOT NULL THEN
        FOR J IN IDX_REC_ACNTS.FIRST .. IDX_REC_ACNTS.LAST LOOP
          V_ACNTS_INTERNAL_ACNUM      := IDX_REC_ACNTS(J).V_INTERNAL_ACNUM;
          V_ACNTS_PROD_CODE           := IDX_REC_ACNTS(J).V_PROD_CODE;
          W_ACNT_BRN_CODE             := IDX_REC_ACNTS(J).V_ACNT_BRN_CODE;
          V_ACNTS_CURR_CODE           := IDX_REC_ACNTS(J).V_CURR_CODE;
          W_OPENING_DATE              := IDX_REC_ACNTS(J).V_OPENING_DATE;
          W_ENTD_ON                   := IDX_REC_ACNTS(J).V_ENTD_ON;
          V_LNPRD_INT_RECOVERY_OPTION := IDX_REC_ACNTS(J)
                                         .V_INT_RECOVERY_OPTION;
          W_PRODUCT_FOR_RUN_ACS       := IDX_REC_ACNTS(J)
                                         .V_PRODUCT_FOR_RUN_ACS;
          W_LAST_OD_UPDATE_DATE       := L_LAST_OD_UPDATE_DATE;
          W_ACASLL_CLINET_NUM         := IDX_REC_ACNTS(J).V_ACASLLDTL_CLIENT_NUM ;
          W_ACASLL_LIMITLINE_NUM      := IDX_REC_ACNTS(J).V_ACASLLDTL_LIMIT_LINE_NUM;
          W_LIMIT_EXPIRY_DATE         := IDX_REC_ACNTS(J).V_LMTLINE_LIMIT_EXPIRY_DATE ; 
        
          --DBMS_OUTPUT.PUT_LINE(V_ACNTS_INTERNAL_ACNUM  ||  '(' || facno( 1,V_ACNTS_INTERNAL_ACNUM) || ')'  || '>>>' || W_PRODUCT_FOR_RUN_ACS);
          --DBMS_OUTPUT.PUT_LINE('W_OPENING_DATE  : = ' || W_OPENING_DATE );
          CHECKLIMIT_PROC ;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF TRIM(W_ERROR_MSG) IS NULL THEN
          W_ERROR_MSG := 'Error in FETCH_LOANACNTS ' ||
                         SUBSTR(SQLERRM, 1, 700);
        END IF;
      
        W_ERROR_MSG                   := FACNO(V_GLOB_ENTITY_NUM,
                                               V_ACNTS_INTERNAL_ACNUM) || ' ' ||
                                         W_ERROR_MSG;
        PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
    END READ_ACNTS;
  END FETCH_LOANACNTS;

  PROCEDURE SP_LNODUPDATE(V_ENTITY_NUM    IN NUMBER,
                          P_BRN_CODE      IN NUMBER DEFAULT 0,
                          P_PROCESS_DATE  IN VARCHAR2 DEFAULT NULL,
                          P_CURR_BUS_DATE IN VARCHAR2 DEFAULT NULL,
                          P_SESS_USER_ID  IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    V_GLOB_ENTITY_NUM := V_ENTITY_NUM; ----- ENTITY NUMBER VARIABLE ADDED
  
    <<START_PROCEDURE>>
    BEGIN
      INIT_PARA;
      CHECK_INPUTS(P_BRN_CODE,
                   P_PROCESS_DATE,
                   P_CURR_BUS_DATE,
                   P_SESS_USER_ID);
    
      <<READ_LNODCNTL>>
      BEGIN
        W_SQL_OD := 'SELECT LNODCNTL_LAST_PROC_DATE FROM LNODCNTL
                     WHERE LNODCNTL_ENTITY_NUM = :1
                     AND LNODCNTL_NUM = 1';
      
        EXECUTE IMMEDIATE W_SQL_OD
          INTO L_LAST_OD_UPDATE_DATE
          USING V_GLOB_ENTITY_NUM;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_LAST_OD_UPDATE_DATE := NULL;
        WHEN OTHERS THEN
          W_ERROR_MSG := 'ERROR IN READ_LNODCNTL';
          RAISE E_USER_EXCEP;
      END READ_LNODCNTL;
    
      --DBMS_MVIEW.REFRESH('MV_LOAN_ACCOUNT_BAL_OD');
      --COMMIT;
      PKG_LNOVERDUE.V_OVERDUE_EOD_PROC := TRUE;
      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE(V_GLOB_ENTITY_NUM,
                                           W_IN_BRANCH_CODE);
    
      FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT LOOP
        W_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN(IDX).LN_BRN_CODE;
      
        IF W_BRN_CODE IN  (26, 1024, 6064, 10090, 13094, 16063, 16089, 16170, 18093, 27094, 27144, 33167, 36137, 1115, 56275)  THEN
          CONTINUE;
        END IF;
      
        IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED(V_GLOB_ENTITY_NUM,
                                                       W_BRN_CODE) = FALSE THEN
        
          --- Added by Tamim
          R_IDX      := 0;
          W_MIG_DATE := NULL;
        
          SELECT MIG_END_DATE
            INTO W_MIG_DATE
            FROM MIG_DETAIL
           WHERE BRANCH_CODE = W_BRN_CODE;
          ---
        
          FETCH_LOANACNTS;
        
          UPDATE_LNOD;
          UPDATE_LNODHIST;
        
          IDX_REC_LNOD.DELETE;
        
          IF TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL THEN

            PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN(V_GLOB_ENTITY_NUM,
                                                            W_BRN_CODE);
                       
          END IF;
        
          PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS(V_GLOB_ENTITY_NUM);
        
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF TRIM(W_ERROR_MSG) IS NULL THEN
          W_ERROR_MSG := 'Error in SP_LNODUPDATE ' ||
                         SUBSTR(SQLERRM, 1, 700);
        END IF;
      
        PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
        PKG_PB_GLOBAL.DETAIL_ERRLOG(V_GLOB_ENTITY_NUM,
                                    'E',
                                    PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                    ' ',
                                    0);
    END START_PROCEDURE;
  
    IF (TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL) THEN
      IF NVL(W_IN_BRANCH_CODE, 0) = 0 THEN
        UPDATE_LNODCNTL;
        COMMIT;
      END IF;
    END IF;
  END SP_LNODUPDATE;
END PKG_LNODUPDATE;
/