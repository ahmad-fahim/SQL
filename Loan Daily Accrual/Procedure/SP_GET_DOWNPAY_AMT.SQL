CREATE OR REPLACE PROCEDURE SP_GET_DOWNPAY_AMT(P_BRN_CODE             IN NUMBER,
                                               P_ACNTS_INTERNAL_ACNUM IN NUMBER,
                                               P_RS_NO                IN NUMBER,
                                               P_PROCESS_DATE         IN DATE,
                                               P_CURR_BUS_DATE        IN DATE,
                                               P_DP_AMT               OUT NUMBER,
                                               P_DP_CALC_TYPE         OUT VARCHAR2,
                                               W_ERROR_MSG            OUT VARCHAR2) IS
  B1              NUMBER;
  Err             VARCHAR2(100);
  V_TIME          VARCHAR2(10);
  V_TEMP_DATE     VARCHAR2(21);
  W_OD_DATE1      VARCHAR2(10);
  W_PRIN_OD_DATE1 VARCHAR2(10);
  W_INT_OD_DATE1  VARCHAR2(10);
  W_CHGS_OD_DATE1 VARCHAR2(10);
  W_SQL           VARCHAR2(1000);
  E_USER_EXCEP EXCEPTION;
  V_ACNTS_INTERNAL_ACNUM NUMBER(14);
  W_PROCESS_DATE         DATE;
  W_CURR_BUS_DATE        TIMESTAMP;
  W_ASON_AC_BAL          NUMBER(18, 3);
  W_ASON_BC_BAL          NUMBER(18, 3);
  W_PRODUCT_CODE         NUMBER(4);
  W_ACNTS_CURR_CODE      VARCHAR2(3);
  W_CAL_OD_AMT           NUMBER(18, 3);
  W_CAL_ASON_BC_BAL      NUMBER(18, 3);

  --=== OD Calc
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
  W_ACC_MIG_DATE    DATE DEFAULT NULL;
  
  
  V_ACNTS_CURR_CODE             VARCHAR2 (3) ;
   W_OPENING_DATE                DATE;
   W_MIG_DATE                    DATE;
   V_ACNTS_PROD_CODE             NUMBER (4);
   V_LNPRD_INT_RECOVERY_OPTION   CHAR (1); 
   W_PRODUCT_FOR_RUN_ACS         VARCHAR (1) ;
   W_LIMIT_EXPIRY_DATE           DATE;
   W_ACASLL_CLINET_NUM           NUMBER (12);
   W_ACASLL_LIMITLINE_NUM        NUMBER (12);
  
  

  -- Testing Purpose Data
  V_MAX_PROD_RS          NUMBER(2) := 0;
  V_RS_NO                NUMBER(2);
  V_MORE_THEN_PROD_ALLOW CHAR(1) := '1';

  TYPE R_DP_PM_LIST IS RECORD(
    LNDPD_PRD_TYPE  CHAR(1),
    LNDPD_PRD_CODE  NUMBER(4),
    LNDP_ACC_NO     NUMBER(14),
    LNDP_RS_NO      NUMBER(2),
    LNDPD_AMT_SLAB  NUMBER(18, 3),
    LNDPD_SL_NUM    NUMBER(2),
    LNDPD_INCLUSIVE CHAR(1),
    LNDPD_OD_PER    NUMBER(3),
    LNDPD_OS_PER    NUMBER(3),
    LNDPD_DP_AMT    NUMBER(18, 3));

  TYPE T_DP_PM_LIST IS TABLE OF R_DP_PM_LIST INDEX BY BINARY_INTEGER;
  V_DP_PM_LIST T_DP_PM_LIST;

  PROCEDURE INIT_PARA IS
  BEGIN

    W_ERROR_MSG            := '';
    W_OS_AMT               := 0;
    W_SANC_LIMIT_AMT       := 0;
    W_DP_AMT               := 0;
    W_LIMIT_AMT            := 0;
    W_OD_AMT               := 0;
    W_OD_DATE1             := '';
    W_PRIN_OD_AMT          := 0;
    W_PRIN_OD_DATE1        := '';
    W_INT_OD_AMT           := 0;
    W_INT_OD_DATE1         := '';
    W_CHGS_OD_AMT          := 0;
    W_CHGS_OD_DATE1        := '';
    W_ACC_MIG_DATE         := '';
    V_ACNTS_PROD_CODE      := 0;
    W_ASON_AC_BAL          := 0;
    W_ASON_BC_BAL          := 0;
    W_PRODUCT_FOR_RUN_ACS  := '0';
    W_ACNTS_CURR_CODE      := '';
    V_MORE_THEN_PROD_ALLOW := 0;
  END INIT_PARA;

  PROCEDURE GET_ACC_LEVEL_PARAM IS

  BEGIN

    SELECT LNACRS_MAX_ALLOWED
      INTO V_MORE_THEN_PROD_ALLOW
      FROM LNACMAXRS
     WHERE LNACMAXRS.LNACRS_ENTITY_NUM = 1
       AND LNACMAXRS.LNACRS_ACC_NO = V_ACNTS_INTERNAL_ACNUM
       AND LNACRS_AUTH_ON IS NOT NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_MORE_THEN_PROD_ALLOW := 0;

  END GET_ACC_LEVEL_PARAM;

  PROCEDURE GET_PROD_LEVEL_MAX_RS_PARAM IS

  BEGIN

    SELECT LNPRDRS_MAX_RS
      INTO V_MAX_PROD_RS
      FROM LNPRDMAXRS
     WHERE LNPRDRS_PRD_CODE = W_PRODUCT_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_MAX_PROD_RS := 0;
      W_ERROR_MSG   := 'MAX RESCHEDULE NO. HAS NOT SET.';
  END GET_PROD_LEVEL_MAX_RS_PARAM;

BEGIN

  PKG_ENTITY.SP_SET_ENTITY_CODE(1);
  INIT_PARA;
  V_ACNTS_INTERNAL_ACNUM := P_ACNTS_INTERNAL_ACNUM;
  W_PROCESS_DATE         := P_PROCESS_DATE;
  W_CURR_BUS_DATE        := P_CURR_BUS_DATE;
  V_RS_NO                := P_RS_NO;
  
  <<ACC_INFO>>

  BEGIN
    SELECT P.PRODUCT_CODE, P.PRODUCT_FOR_RUN_ACS, A.ACNTS_CURR_CODE
      INTO W_PRODUCT_CODE, W_PRODUCT_FOR_RUN_ACS, W_ACNTS_CURR_CODE
      FROM ACNTS A, PRODUCTS P
     WHERE A.ACNTS_ENTITY_NUM = 1
       AND A.ACNTS_PROD_CODE = P.PRODUCT_CODE
       AND A.ACNTS_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ERROR_MSG := 'ERROR IN GETTING PRODUCT INFO.';
      RETURN;
  END ACC_INFO;


  GET_PROD_LEVEL_MAX_RS_PARAM;
  IF W_ERROR_MSG IS NOT NULL THEN
    RETURN;
  END IF;

  IF V_RS_NO > V_MAX_PROD_RS THEN
    GET_ACC_LEVEL_PARAM;
    IF V_MORE_THEN_PROD_ALLOW = '0' THEN
      W_ERROR_MSG := 'NO. OF RESCHEDULE CANNOT BE GREATER THAN PRODUCT WISE SETTINGS. ';
      RETURN;
    ELSE
      V_RS_NO := V_MAX_PROD_RS;
    END IF;
  END IF;

  -- For Running Account, For More then 1 Reschedule, Parameter will taken from Term Loan
  DBMS_OUTPUT.PUT_LINE('XXXXX = '  ||  W_PRODUCT_FOR_RUN_ACS || '  ==  ' || V_RS_NO);
 IF V_RS_NO > 1 AND W_PRODUCT_FOR_RUN_ACS = 1 THEN
   W_PRODUCT_CODE := 0;
   W_PRODUCT_FOR_RUN_ACS := 0;
 END IF;

  -- To Check Account Level Parameter
  W_SQL := 'SELECT *
    FROM LNDPPARAMDTL L
   WHERE L.LNDP_ACC_NO = :1 AND L.LNDP_RS_NO = :2';

  EXECUTE IMMEDIATE W_SQL BULK COLLECT
    INTO V_DP_PM_LIST
    USING V_ACNTS_INTERNAL_ACNUM, V_RS_NO;

  IF V_DP_PM_LIST.COUNT = 0 THEN
    -- To Check Product Level Parameter
    W_SQL := 'SELECT *
    FROM LNDPPARAMDTL L
   WHERE L.LNDPD_PRD_CODE = :1 AND L.LNDP_RS_NO = :2 AND LNDPD_PRD_TYPE = :3' ;

    EXECUTE IMMEDIATE W_SQL BULK COLLECT
      INTO V_DP_PM_LIST
      USING W_PRODUCT_CODE, V_RS_NO,ABS(W_PRODUCT_FOR_RUN_ACS - 2);
  END IF;

  IF V_DP_PM_LIST.COUNT = 0 THEN
    -- To Check Default Parameter
    W_SQL := 'SELECT *
    FROM LNDPPARAMDTL L
   WHERE NVL(L.LNDPD_PRD_CODE,0) = 0
   AND NVL(L.LNDP_ACC_NO,0) = 0 AND L.LNDP_RS_NO = :1 AND LNDPD_PRD_TYPE = :2';

    EXECUTE IMMEDIATE W_SQL BULK COLLECT
      INTO V_DP_PM_LIST
      USING V_RS_NO, ABS(W_PRODUCT_FOR_RUN_ACS - 2);
    DBMS_OUTPUT.PUT_LINE(V_DP_PM_LIST.COUNT);
  END IF;

  IF V_DP_PM_LIST.COUNT = 0 THEN
    P_DP_AMT    := NULL;
    P_DP_CALC_TYPE := '';
    W_ERROR_MSG := 'DOWNPAYMENT PARAMETER HAS NOT SET. ';
    RETURN;
  END IF;
  -- Note: Balance Calculation
  <<GET_OVERDUE>>
  
  
  
  SELECT ACNTS_CURR_CODE,
          ACNTS_OPENING_DATE,
          MIG_END_DATE,
          ACNTS_PROD_CODE,
          LNPRD_INT_RECOVERY_OPTION,
          PRODUCT_FOR_RUN_ACS,
          (SELECT LMTLINE_LIMIT_EXPIRY_DATE
             FROM LIMITLINE, ACASLLDTL
            WHERE     LMTLINE_ENTITY_NUM = ACNTS_ENTITY_NUM
                  AND ACASLLDTL_ENTITY_NUM = ACNTS_ENTITY_NUM
                  AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                  AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                  AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM),
          ACNTS_CLIENT_NUM,
          NVL((SELECT ACASLLDTL_LIMIT_LINE_NUM
             FROM ACASLLDTL
            WHERE     ACASLLDTL_ENTITY_NUM = 1
                  AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM), 0) 
     INTO V_ACNTS_CURR_CODE,
          W_OPENING_DATE,
          W_MIG_DATE,
          V_ACNTS_PROD_CODE,
          V_LNPRD_INT_RECOVERY_OPTION,
          W_PRODUCT_FOR_RUN_ACS,
          W_LIMIT_EXPIRY_DATE,
          W_ACASLL_CLINET_NUM,
          W_ACASLL_LIMITLINE_NUM
     FROM ACNTS,
          PRODUCTS,
          LNPRODPM,
          MIG_DETAIL
    WHERE     ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
          AND ACNTS_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM
          AND ACNTS_PROD_CODE = PRODUCT_CODE
          AND LNPRD_PROD_CODE = PRODUCT_CODE
          AND BRANCH_CODE = ACNTS_BRN_CODE;
  
  
  
  BEGIN
    PKG_LNOVERDUE.SP_LNOVERDUE(PKG_ENTITY.FN_GET_ENTITY_CODE,
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
                               V_ACNTS_CURR_CODE,
                               W_OPENING_DATE,
                               W_MIG_DATE,
                               V_ACNTS_PROD_CODE,
                               V_LNPRD_INT_RECOVERY_OPTION,
                               W_PRODUCT_FOR_RUN_ACS,
                               W_LIMIT_EXPIRY_DATE,
                               W_ACASLL_CLINET_NUM,
                               W_ACASLL_LIMITLINE_NUM,
                               1 );

  EXCEPTION
    WHEN OTHERS THEN
      IF (W_ERROR_MSG IS NULL) THEN
        W_ERROR_MSG := 'ERROR IN SP_GET_OVERDUE.';
      END IF;
      RAISE E_USER_EXCEP;
  END GET_OVERDUE;

  <<GET_ASON_BAL>>
  BEGIN
    GET_ASON_ACBAL(1,
                   V_ACNTS_INTERNAL_ACNUM,
                   W_ACNTS_CURR_CODE,
                   W_PROCESS_DATE,
                   W_CURR_BUS_DATE,
                   W_ASON_AC_BAL,
                   W_ASON_BC_BAL,
                   W_ERROR_MSG);

  EXCEPTION
    WHEN OTHERS THEN
      IF (W_ERROR_MSG IS NULL) THEN
        W_ERROR_MSG := 'ERROR IN GET_ASON_ACBAL.';
      END IF;
      RAISE E_USER_EXCEP;
  END GET_ASON_BAL;

  IF W_ASON_BC_BAL > 0 THEN
    W_ASON_BC_BAL := 0;
  END IF;
  W_ASON_BC_BAL := ABS(W_ASON_BC_BAL);

  --
  FOR M_INDEX IN 1 .. V_DP_PM_LIST.COUNT LOOP

    -- Note: IF Portion is for Slab Wise Calculation
    IF W_PRODUCT_FOR_RUN_ACS = 1 THEN
      IF ((V_DP_PM_LIST(M_INDEX).LNDPD_INCLUSIVE = '0' OR V_DP_PM_LIST(M_INDEX)
         .LNDPD_INCLUSIVE = 'N') AND
         W_ASON_BC_BAL < V_DP_PM_LIST(M_INDEX).LNDPD_AMT_SLAB)

         OR

         ((V_DP_PM_LIST(M_INDEX).LNDPD_INCLUSIVE = '1' OR V_DP_PM_LIST(M_INDEX)
         .LNDPD_INCLUSIVE = 'Y') AND
         W_ASON_BC_BAL <= V_DP_PM_LIST(M_INDEX).LNDPD_AMT_SLAB) THEN

        W_CAL_ASON_BC_BAL := (W_ASON_BC_BAL * V_DP_PM_LIST(M_INDEX)
                             .LNDPD_OS_PER) / 100;
        IF (NVL(V_DP_PM_LIST(M_INDEX).LNDPD_DP_AMT, 0) > 0 AND
           W_CAL_ASON_BC_BAL < NVL(V_DP_PM_LIST(M_INDEX).LNDPD_DP_AMT, 0)) THEN
          W_CAL_ASON_BC_BAL := NVL(V_DP_PM_LIST(M_INDEX).LNDPD_DP_AMT, 0);
        END IF;
        P_DP_AMT := W_CAL_ASON_BC_BAL;
        P_DP_CALC_TYPE := 'Outstanding Balance('|| W_ASON_BC_BAL || ')';
        EXIT;
      END IF;

    ELSE
      -- Note: ELSE Portion is for Percentage Wise Calculation
      W_CAL_OD_AMT      := (W_OD_AMT * V_DP_PM_LIST(M_INDEX).LNDPD_OD_PER) / 100;
      W_CAL_ASON_BC_BAL := (W_ASON_BC_BAL * V_DP_PM_LIST(M_INDEX)
                           .LNDPD_OS_PER) / 100;
      IF W_CAL_OD_AMT <= W_CAL_ASON_BC_BAL THEN
        P_DP_AMT := W_CAL_OD_AMT;
        P_DP_CALC_TYPE :='Overdue Amount('|| W_OD_AMT || ')';
      ELSE
        P_DP_AMT := W_CAL_ASON_BC_BAL;
        P_DP_CALC_TYPE :='Outstanding Balance('|| W_ASON_BC_BAL || ')';
      END IF;
    END IF;
  END LOOP;

 P_DP_AMT :=  ROUND(P_DP_AMT,0);
END SP_GET_DOWNPAY_AMT;
/