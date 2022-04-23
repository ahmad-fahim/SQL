CREATE OR REPLACE PROCEDURE SP_RODLIST(V_ENTITY_NUM IN NUMBER,
                                       P_BRN_CODE   NUMBER,
                                       P_PROD_CODE  NUMBER,
                                       P_ACTYPE     VARCHAR2,
                                       P_CUST_CODE  NUMBER,
                                       P_FROM_OD    NUMBER,
                                       P_UPTO_OD    NUMBER,
                                       P_CURR_CODE  VARCHAR2,
                                       P_FROM_AMT   NUMBER,
                                       P_UPTO_AMT   NUMBER,
                                       P_ASON_DATE  DATE,
                                       P_TEMP_SER   OUT NUMBER,
                                       P_ERR_MSG    OUT VARCHAR2)

  -- AUTHOR   : R.SENTHIL KUMAR
  -- DATE     : 26-AUG-2009
  -- PURPOSE  : LIST OF OVERDUE ACCOUNTS REPORT

 IS
 -- W_BRN_CODE    NUMBER(3);
 --changed by gunasekhar p for sonali
  W_BRN_CODE    NUMBER(6);
  W_PROD_CODE   NUMBER(4);
  W_PROD_NAME   VARCHAR2(50);
  W_ACTYPE      VARCHAR2(5);
  W_CUST_CODE   NUMBER(12);
  W_FROM_OD     NUMBER(5);
  W_UPTO_OD     NUMBER(5);
  W_CURR_CODE   VARCHAR2(3);
  W_FROM_AMT    NUMBER(18, 3);
  W_UPTO_AMT    NUMBER(18, 3);
  W_ASON_DATE   DATE;
  W_PROC_ACNUM  NUMBER(14);
  W_PROC_ACTUAL VARCHAR2(20);
  W_ACNAME      VARCHAR2(100);
  W_SANC_LIMIT  NUMBER(18, 3);
  W_DP_AMT      NUMBER(18, 3);
  W_OD_AMT      NUMBER(18, 3);
  W_OD_DATE     DATE;
  W_NO_OF_INSTALLMENT NUMBER(5); --SHALINI ADD 19022013
  W_IGN         NUMBER(18, 3);
  W_NOD         NUMBER(8);
  W_PRIN_BAL    NUMBER(18, 3);
  W_INT_BAL     NUMBER(18, 3);
  W_CHG_BAL     NUMBER(18, 3);
  W_AC_BAL      NUMBER(18, 3);
  W_ASON_AC_BAL NUMBER(18, 3);
  W_ASON_BC_BAL NUMBER(18, 3);
  W_TEMP_SER    NUMBER(7);
  W_ERR_MSG     VARCHAR2(2300);
  W_SQL         VARCHAR2(3300);
  W_CBD         DATE;
  -- Add Guna 14/10/2010 start
  W_DUMMY_V         VARCHAR2(15);
  W_DUMMY_N         NUMBER(18,3);
  W_ERROR           VARCHAR2(250);
  W_OD_DATE_V       VARCHAR2(25);
  W_ASSET_CODE      VARCHAR2(2);
  W_REPAY_FROM_DATE DATE;
  W_INSTALL_AMOUNT  NUMBER(18, 3);
  W_ASON_AC_SUS_BAL NUMBER(18, 3);
  W_GSM_NUM         VARCHAR2(15);
  W_RES_TEL         VARCHAR2(15);
  W_OFF_TEL         VARCHAR2(15);
  W_OFF_EXTN        NUMBER(5);
  -- Add Guna 14/10/2010 end
  W_STD_ASSET_CODE    VARCHAR2(2) := ''; -- Poorani-Chn-04/04/2011
  MYEXCEPTION EXCEPTION;
  TYPE V_ACNTS IS RECORD(
    ACNTS_INTERNAL_ACNUM    NUMBER(14),
    ACNTS_AC_NAME1          VARCHAR2(100),
    PRODUCT_CODE            NUMBER(4),
    PRODUCT_NAME            VARCHAR2(50),
    ACNTS_CURR_CODE         VARCHAR2(3),
    LNODHIST_SANC_LIMIT_AMT NUMBER(18, 3),
    LNODHIST_DP_AMT         NUMBER(18, 3),
    LNODHIST_OD_AMT         NUMBER(18, 3),
    LNODHIST_OD_DATE        DATE,
    LNACRSDTL_NO_OF_INSTALLMENT NUMBER(5),
    ACNTS_OPENING_DATE DATE ,
    MIG_DATE DATE ,
    PRODUCT_FOR_RUN_ACS VARCHAR2(1),
    EXPIRY_DATE DATE ,
    CLIENT_NUMBER NUMBER,
    LMTLINE_NUM NUMBER
    ); --SHALINI - ADD - 19/02/2013
  TYPE IN_ACNTS IS TABLE OF V_ACNTS INDEX BY PLS_INTEGER;
  V_AC IN_ACNTS;
  -- Fetching BALANCE
  PROCEDURE FETCH_BALANCE IS
    W_TOT_PRIN_DB_AC NUMBER(18, 3);
    W_TOT_PRIN_CR_AC NUMBER(18, 3);
    W_TOT_PRIN_DB_BC NUMBER(18, 3);
    W_TOT_PRIN_CR_BC NUMBER(18, 3);
    W_TOT_INT_DB_AC  NUMBER(18, 3);
    W_TOT_INT_CR_AC  NUMBER(18, 3);
    W_TOT_INT_DB_BC  NUMBER(18, 3);
    W_TOT_INT_CR_BC  NUMBER(18, 3);
    W_TOT_CHG_DB_AC  NUMBER(18, 3);
    W_TOT_CHG_CR_AC  NUMBER(18, 3);
    W_TOT_CHG_DB_BC  NUMBER(18, 3);
    W_TOT_CHG_CR_BC  NUMBER(18, 3);
  BEGIN
    SP_LNTRANSUM(PKG_ENTITY.FN_GET_ENTITY_CODE,
                 W_PROC_ACNUM,
                 W_ASON_DATE,
                 W_CBD,
                 NULL,
                 NULL,
                 W_ERR_MSG,
                 W_TOT_PRIN_DB_AC,
                 W_TOT_PRIN_CR_AC,
                 W_TOT_PRIN_DB_BC,
                 W_TOT_PRIN_CR_BC,
                 W_TOT_INT_DB_AC,
                 W_TOT_INT_CR_AC,
                 W_TOT_INT_DB_BC,
                 W_TOT_INT_CR_BC,
                 W_TOT_CHG_DB_AC,
                 W_TOT_CHG_CR_AC,
                 W_TOT_CHG_DB_BC,
                 W_TOT_CHG_CR_BC);
    IF TRIM(W_ERR_MSG) IS NULL THEN
      W_PRIN_BAL := W_TOT_PRIN_CR_AC - W_TOT_PRIN_DB_AC;
      W_INT_BAL  := W_TOT_INT_CR_AC - W_TOT_INT_DB_AC;
      W_CHG_BAL  := W_TOT_CHG_CR_AC - W_TOT_CHG_DB_AC;
    ELSE
      W_ERR_MSG := 'ERROR IN FETCH_BALANCE  ' || SQLERRM;
      RAISE MYEXCEPTION;
    END IF;
  END FETCH_BALANCE;
  -- Fetching Actual Balance - AsonDate = CBD
  PROCEDURE FETCH_ASON_EQ_CBDBAL IS
  BEGIN
    GET_ASON_ACBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,
                   W_PROC_ACNUM,
                   W_CURR_CODE,
                   W_ASON_DATE,
                   W_CBD,
                   W_ASON_AC_BAL,
                   W_ASON_BC_BAL,
                   W_ERR_MSG);
    IF TRIM(W_ERR_MSG) IS NULL THEN
      -- CHN Guna 14/10/2010 start
      --W_AC_BAL := ABS(W_ASON_AC_BAL);
      W_AC_BAL := W_ASON_AC_BAL;
      -- CHN Guna 14/10/2010 end
    ELSE
      W_ERR_MSG := 'ERROR IN FETCH_ASON_NEQ_CBDBAL  ' || SQLERRM;
      RAISE MYEXCEPTION;
    END IF;
  END FETCH_ASON_EQ_CBDBAL;
  -- Fetching Actual Balance - AsonDate <> CBD
  PROCEDURE FETCH_ASON_NEQ_CBDBAL IS
  BEGIN
    PKG_AVLBAL_WRAPPER.SP_AVLBAL_WRAP(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                      W_PROC_ACNUM);
    -- CHN Guna 14/10/2010 start
    -- W_AC_BAL := ABS(PKG_AVLBAL_WRAPPER.P_AC_AUTH_BAL);
    W_AC_BAL := PKG_AVLBAL_WRAPPER.P_AC_AUTH_BAL;
    -- CHN Guna 14/10/2010 end
  EXCEPTION
    WHEN OTHERS THEN
      W_ERR_MSG := 'ERROR IN FETCH_ASON_NEQ_CBDBAL  ' || SQLERRM;
  END FETCH_ASON_NEQ_CBDBAL;
  -- TEMP TABLE UPDATION
  -- Add Guna 14/10/2010 start
  PROCEDURE INITIALIZE_VARIABLE AS
  BEGIN
    W_ASSET_CODE      := '';
    W_REPAY_FROM_DATE := NULL;
    W_INSTALL_AMOUNT  := 0;
    W_ASON_AC_SUS_BAL := 0;
    W_GSM_NUM         := '';
    W_RES_TEL         := '';
    W_OFF_TEL         := '';
    W_OFF_EXTN        := 0;
  END;

  PROCEDURE FETCH_ASSETCODE AS
  BEGIN
    W_SQL := 'SELECT  ASSETCLSH_ASSET_CODE FROM ASSETCLSHIST
           WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND ASSETCLSH_INTERNAL_ACNUM = :1 AND
           ASSETCLSH_EFF_DATE = (SELECT MAX( ASSETCLSH_EFF_DATE ) FROM ASSETCLSHIST
           WHERE ASSETCLSH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ASSETCLSH_INTERNAL_ACNUM = :2
           AND  ASSETCLSH_EFF_DATE <= :3)';
    EXECUTE IMMEDIATE W_SQL
      INTO W_ASSET_CODE
      USING W_PROC_ACNUM, W_PROC_ACNUM, W_ASON_DATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --Poorani-Chn-04/04/2011 -  W_ASSET_CODE := '';
          W_ASSET_CODE := W_STD_ASSET_CODE;
    WHEN OTHERS THEN
      IF TRIM(W_ERR_MSG) IS NULL THEN
        W_ERR_MSG := 'Error in FETCH_ASSETCODE' || SUBSTR(SQLERRM, 1, 100);
      END IF;
      RAISE MYEXCEPTION;
  END FETCH_ASSETCODE;

  PROCEDURE FETCH_SUSP_BAL AS
    W_ERROR_MSG VARCHAR2(1000);
    W_DUMMY     NUMBER(18, 3);
  BEGIN
    PKG_LNSUSPASON.SP_LNSUSPASON(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                 W_PROC_ACNUM,
                                 W_CURR_CODE,
                                 TO_CHAR(W_ASON_DATE, 'DD-MM-YYYY'),
                                 W_ERROR_MSG,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_ASON_AC_SUS_BAL,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY,
                                 W_DUMMY);
    IF TRIM(W_ERROR_MSG) IS NOT NULL THEN
      W_ERR_MSG := W_ERROR_MSG;
      RAISE MYEXCEPTION;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF TRIM(W_ERROR_MSG) IS NULL THEN
        W_ERR_MSG := 'Error in FETCH_SUSP_BAL' || SUBSTR(SQLERRM, 1, 100);
      END IF;
      RAISE MYEXCEPTION;
  END FETCH_SUSP_BAL;

  PROCEDURE FETCH_INSTALL_AMOUNT AS
  BEGIN
    W_SQL := 'SELECT LNACRSHDTL_REPAY_FROM_DATE, LNACRSHDTL_REPAY_AMT
  FROM LNACRSHDTL B
 WHERE LNACRSHDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
   AND LNACRSHDTL_INTERNAL_ACNUM = :1
   AND LNACRSHDTL_EFF_DATE =
       (SELECT MAX(LNACRSHDTL_EFF_DATE)
          FROM LNACRSHDTL
         WHERE LNACRSHDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
           AND LNACRSHDTL_INTERNAL_ACNUM = :2
           AND LNACRSHDTL_EFF_DATE <= :3)
   AND LNACRSHDTL_SL_NUM =
       (SELECT MAX(LNACRSHDTL_SL_NUM)
          FROM LNACRSHDTL
         WHERE LNACRSHDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND LNACRSHDTL_INTERNAL_ACNUM = :4
           AND LNACRSHDTL_EFF_DATE = B.LNACRSHDTL_EFF_DATE
           AND LNACRSHDTL_REPAY_FROM_DATE <= :5)  ORDER BY B.LNACRSHDTL_SL_NUM';
    EXECUTE IMMEDIATE W_SQL
      INTO W_REPAY_FROM_DATE, W_INSTALL_AMOUNT
      USING W_PROC_ACNUM, W_PROC_ACNUM, W_ASON_DATE, W_PROC_ACNUM, W_ASON_DATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_REPAY_FROM_DATE := NULL;
      W_INSTALL_AMOUNT  := 0;
    WHEN OTHERS THEN
      IF TRIM(W_ERR_MSG) IS NULL THEN
        W_ERR_MSG := 'Error in FETCH_INSTALL_AMOUNT' ||
                     SUBSTR(SQLERRM, 1, 100);
      END IF;
      RAISE MYEXCEPTION;
  END FETCH_INSTALL_AMOUNT;

  PROCEDURE FETCH_CONTACT_DTLS AS
    W_ERROR_MSG      VARCHAR2(1000);
    W_DUMMY_TEMP_SER NUMBER(6);
  BEGIN
    sp_getaccontact(PKG_ENTITY.FN_GET_ENTITY_CODE,
                    W_PROC_ACNUM,
                    W_ERROR_MSG,
                    W_DUMMY_TEMP_SER);
    IF TRIM(W_ERROR_MSG) IS NOT NULL THEN
      W_ERR_MSG := W_ERROR_MSG;
      RAISE MYEXCEPTION;
    ELSE
      W_SQL := ' SELECT RTMPACCONT_GSM_NUM,RTMPACCONT_RES_TEL_NUM,RTMPACCONT_OFF_TEL_NUM,RTMPACCONT_OFF_EXTN_NUM
     FROM RTMPACNTCONTACT WHERE  RTMPACCONT_TEMP_SL=:1 AND  RTMPACCONT_INTERNAL_ACNUM=:2 AND RTMPACCONT_DTL_SL=1';
      EXECUTE IMMEDIATE W_SQL
        INTO W_GSM_NUM, W_RES_TEL, W_OFF_TEL, W_OFF_EXTN
        USING W_DUMMY_TEMP_SER, W_PROC_ACNUM;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      IF TRIM(W_ERR_MSG) IS NULL THEN
        W_ERR_MSG := 'Error in FETCH_CONTACT_DTLS' ||
                     SUBSTR(SQLERRM, 1, 100);
      END IF;
      RAISE MYEXCEPTION;
  END FETCH_CONTACT_DTLS;
  -- Add Guna 14/10/2010 end

  -- Poorani-Chn-04/04/2011 -Beg
  PROCEDURE GET_DEFAULT_ASSET_CODE IS
    BEGIN
          SELECT ASSETCDMAP_STD_ASSET
                INTO W_STD_ASSET_CODE
                FROM ASSETCDMAP
                WHERE ASSETCDMAP_KEY = 'ACM';

    END GET_DEFAULT_ASSET_CODE;
  -- Poorani-Chn-04/04/2011 -End

  PROCEDURE UPDATE_RTMPOD IS
    -- CHN Guna 14/10/2010 start
  BEGIN
    FETCH_ASSETCODE;
    FETCH_SUSP_BAL;
    FETCH_INSTALL_AMOUNT;
    FETCH_CONTACT_DTLS;
    /*  INSERT INTO RTMPOD
      (RTMPOD_TMP_SER,
       RTMPOD_BRN_CODE,
       RTMPOD_PROD_CODE,
       RTMPOD_INTERNAL_ACNUM,
       RTMPOD_ACNT_NUM,
       RTMPOD_ACNT_NAME,
       RTMPOD_PROD_NAME,
       RTMPOD_CURR_CODE,
       RTMPOD_SANC_LIMIT,
       RTMPOD_DP,
       RTMPOD_ACNT_BAL,
       RTMPOD_OD_AMT,
       RTMPOD_OD_DATE,
       RTMPOD_PRIN_BAL,
       RTMPOD_INT_BAL,
       RTMPOD_CHG_BAL,
       RTMPOD_NOD)
    VALUES
      (W_TEMP_SER,
       W_BRN_CODE,
       W_PROD_CODE,
       W_PROC_ACNUM,
       W_PROC_ACTUAL,
       W_ACNAME,
       W_PROD_NAME,
       W_CURR_CODE,
       W_SANC_LIMIT,
       W_DP_AMT,
       W_AC_BAL,
       W_OD_AMT,
       W_OD_DATE,
       W_PRIN_BAL,
       W_INT_BAL,
       W_CHG_BAL,
       W_NOD); */
             if w_proc_acnum = 1001100036783 then
                dbms_output.put_line(W_OD_AMT);
                dbms_output.put_line(W_ASON_AC_SUS_BAL);
       end if;

    W_SQL := '
    INSERT INTO RTMPOD
      (RTMPOD_TMP_SER,
       RTMPOD_BRN_CODE,
       RTMPOD_PROD_CODE,
       RTMPOD_INTERNAL_ACNUM,
       RTMPOD_ACNT_NUM,
       RTMPOD_ACNT_NAME,
       RTMPOD_PROD_NAME,
       RTMPOD_CURR_CODE,
       RTMPOD_SANC_LIMIT,
       RTMPOD_DP,
       RTMPOD_ACNT_BAL,
       RTMPOD_OD_AMT,
       RTMPOD_OD_DATE,
       RTMPOD_PRIN_BAL,
       RTMPOD_INT_BAL,
       RTMPOD_CHG_BAL,
       RTMPOD_NOD,
       RTMPOD_ACNT_SUS_BAL,
       RTMPOD_INSTALL_AMOUNT,
       RTMPOD_ASSET_CODE,
       RTMPOD_GSM_NUMBER,
       RTMPOD_RES_TEL,
       RTMPOD_OFF_TEL,
       RTMPOD_OFF_EXTN_NUM,
       RTMPOD_NO_OF_INSTALLMENT
       )
    VALUES
      (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25)';
      --SHALINI - CHN - ADDED - 19/02/2013 - 25
    -- CHN Guna 14/10/2010 end     24
    EXECUTE IMMEDIATE W_SQL
      USING W_TEMP_SER, W_BRN_CODE, W_PROD_CODE, W_PROC_ACNUM, W_PROC_ACTUAL, W_ACNAME, W_PROD_NAME, W_CURR_CODE, W_SANC_LIMIT, W_DP_AMT, W_AC_BAL, W_OD_AMT, W_OD_DATE, W_PRIN_BAL, W_INT_BAL, W_CHG_BAL, W_NOD, W_ASON_AC_SUS_BAL, W_INSTALL_AMOUNT, W_ASSET_CODE, W_GSM_NUM, W_RES_TEL, W_OFF_TEL, W_OFF_EXTN,W_NO_OF_INSTALLMENT;
  END UPDATE_RTMPOD;
BEGIN
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
  PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
  SELECT PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE)
    INTO W_TEMP_SER
    FROM DUAL;
  SELECT MN_CURR_BUSINESS_DATE
    INTO W_CBD
    FROM MAINCONT
   WHERE MN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE;
  IF P_BRN_CODE IS NULL THEN
    W_ERR_MSG := 'Branch Code Not Passed';
    RAISE MYEXCEPTION;
  ELSE
    W_BRN_CODE := P_BRN_CODE;
  END IF;
  IF P_PROD_CODE IS NOT NULL THEN
    W_PROD_CODE := P_PROD_CODE;
  ELSE
    W_PROD_CODE := 0;
  END IF;
  IF P_ACTYPE IS NOT NULL THEN
    W_ACTYPE := P_ACTYPE;
  END IF;
  IF P_CUST_CODE IS NOT NULL THEN
    W_CUST_CODE := P_CUST_CODE;
  END IF;
  IF P_CURR_CODE IS NOT NULL THEN
    W_CURR_CODE := P_CURR_CODE;
  END IF;
  IF P_ASON_DATE IS NULL THEN
    W_ERR_MSG := 'Ason Date Not Passed';
    RAISE MYEXCEPTION;
  ELSE
    W_ASON_DATE := P_ASON_DATE;
  END IF;
  IF P_FROM_OD IS NULL THEN
    W_FROM_OD := 0;
    W_UPTO_OD := 0;
  ELSE
    W_FROM_OD := P_FROM_OD;
    IF P_UPTO_OD IS NULL THEN
      W_UPTO_OD := 0;
    ELSE
      W_UPTO_OD := P_UPTO_OD;
    END IF;
  END IF;
  IF P_FROM_AMT IS NULL THEN
    W_FROM_AMT := 0;
    W_UPTO_AMT := 0;
  ELSE
    W_FROM_AMT := P_FROM_AMT;
    IF P_UPTO_AMT IS NULL THEN
      W_UPTO_AMT := 0;
    ELSE
      W_UPTO_AMT := P_UPTO_AMT;
    END IF;
  END IF;

  GET_DEFAULT_ASSET_CODE ; -- Poorani-Chn-04/04/2011
  W_SQL := 'SELECT ACNTS_INTERNAL_ACNUM,
                          ACNTS_AC_NAME1,
                          PRODUCT_CODE,
                          PRODUCT_NAME,
                          ACNTS_CURR_CODE,
                          LMTLINE_SANCTION_AMT,
                          0,
                          0,
                          NULL ,
                          LNACRSDTL_NUM_OF_INSTALLMENT,
                          ACNTS_OPENING_DATE,
                          MIG_END_DATE,
                          PRODUCT_FOR_RUN_ACS,
                          LMTLINE_LIMIT_EXPIRY_DATE,
                          ACNTS_CLIENT_NUM,
                          LMTLINE_NUM
                          FROM ACNTS, LOANACNTS, PRODUCTS,LNACRSDTL,LIMITLINE,ACASLLDTL, MIG_DETAIL
                           WHERE  LNACNT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                            AND LMTLINE_ENTITY_NUM=PKG_ENTITY.FN_GET_ENTITY_CODE AND ACASLLDTL_ENTITY_NUM=PKG_ENTITY.FN_GET_ENTITY_CODE
                             AND LMTLINE_CLIENT_CODE=ACASLLDTL_CLIENT_NUM
                             AND ACASLLDTL_CLIENT_NUM=ACNTS_CLIENT_NUM AND ACASLLDTL_LIMIT_LINE_NUM=LMTLINE_NUM AND ACASLLDTL_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                           AND  ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
                           AND BRANCH_CODE = ACNTS_BRN_CODE
                          AND ACNTS_PROD_CODE = PRODUCT_CODE AND  LNACRSDTL_ENTITY_NUM  = PKG_ENTITY.FN_GET_ENTITY_CODE AND LNACRSDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND PRODUCT_FOR_LOANS=' || CHR(39) || 1 ||
           CHR(39) || '
                          AND ACNTS_BRN_CODE = ' || W_BRN_CODE ||
           ' AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > ' ||
           CHR(39) || W_ASON_DATE || CHR(39) || ')';
           --SHALINI - ADD - 19/02/2013 -LNACRSDTL
  IF W_PROD_CODE <> 0 THEN
    W_SQL := W_SQL || ' AND ACNTS_PROD_CODE = ' || W_PROD_CODE;
  END IF;
  IF W_CURR_CODE IS NOT NULL THEN
    W_SQL := W_SQL || ' AND ACNTS_CURR_CODE = ' || CHR(39) || W_CURR_CODE ||
             CHR(39);
  END IF;
  IF W_CUST_CODE <> 0 THEN
    W_SQL := W_SQL || ' AND ACNTS_CLIENT_NUM = ' || W_CUST_CODE;
  END IF;
  IF W_ACTYPE IS NOT NULL THEN
    /*W_SQL := W_SQL || ' AND ACNTS_AC_TYPE = ' || CHR(39) || W_CUST_CODE ||
    CHR(39);*/ -- Indra Suneetha S - CHN - 07/JAN/2011 REM
    W_SQL := W_SQL || ' AND ACNTS_AC_TYPE = ' || CHR(39) || W_ACTYPE ||
             CHR(39); -- Indra Suneetha S - CHN - 07/JAN/2011 ADD
  END IF;
   dbms_output.put_line(w_sql);
  EXECUTE IMMEDIATE W_SQL BULK COLLECT
    INTO V_AC;
  IF V_AC.COUNT > 0 THEN
    FOR IDX IN V_AC.FIRST .. V_AC.LAST LOOP
      INITIALIZE_VARIABLE; -- Add Guna 14/10/2010

      W_PROC_ACNUM  := V_AC(IDX).ACNTS_INTERNAL_ACNUM;
      W_PROC_ACTUAL := FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE, W_PROC_ACNUM);
      W_ACNAME      := V_AC(IDX).ACNTS_AC_NAME1;
      W_PROD_CODE   := V_AC(IDX).PRODUCT_CODE;
      W_PROD_NAME   := V_AC(IDX).PRODUCT_NAME;
      W_CURR_CODE   := V_AC(IDX).ACNTS_CURR_CODE;
      W_SANC_LIMIT  := V_AC(IDX).LNODHIST_SANC_LIMIT_AMT;
      W_DP_AMT      := V_AC(IDX).LNODHIST_DP_AMT;
      W_OD_AMT      := V_AC(IDX).LNODHIST_OD_AMT;
      W_OD_DATE     := V_AC(IDX).LNODHIST_OD_DATE;
      W_NO_OF_INSTALLMENT := V_AC(IDX).LNACRSDTL_NO_OF_INSTALLMENT;   --SHALINI - ADDED - 19/02/2013
      W_IGN         := 0;
      W_NOD         := 0;
         PKG_LNOVERDUE.SP_LNOVERDUE(PKG_ENTITY.FN_GET_ENTITY_CODE,
                               W_PROC_ACNUM,
                               TO_CHAR(W_ASON_DATE, 'DD-MM-YYYY'),
                               TO_CHAR(W_CBD, 'DD-MM-YYYY'),
                               W_ERROR,
                               W_DUMMY_N,
                               W_DUMMY_N,
                               W_DUMMY_N,
                               W_DUMMY_N,
                               W_OD_AMT,
                               W_OD_DATE_V,
                               W_DUMMY_N,
                               W_DUMMY_V,
                               W_DUMMY_N,
                               W_DUMMY_V,
                               W_DUMMY_N,
                               W_DUMMY_V,
                               W_CURR_CODE,
                               V_AC(IDX).ACNTS_OPENING_DATE,
                               V_AC(IDX).MIG_DATE,
                               W_PROD_CODE,
                               '0',
                               V_AC(IDX).PRODUCT_FOR_RUN_ACS ,
                               V_AC(IDX).EXPIRY_DATE,
                               V_AC(IDX).CLIENT_NUMBER,
                               V_AC(IDX).LMTLINE_NUM,
                               1 );
                               
      W_OD_DATE :=TO_DATE(W_OD_DATE_V,'DD-MM-YYYY');
      IF W_OD_AMT > 0 AND W_OD_DATE IS NOT NULL AND
         W_OD_DATE <= W_ASON_DATE THEN
        IF W_OD_AMT = 0 THEN
          W_IGN := 1;
        END IF;
        IF W_FROM_AMT > 0 THEN
          IF W_FROM_AMT > W_OD_AMT THEN
            W_IGN := 1;
          END IF;
        END IF;
        IF W_UPTO_AMT > 0 THEN
          IF W_UPTO_AMT < W_OD_AMT THEN
            W_IGN := 1;
          END IF;
        END IF;
        W_NOD := ABS(W_ASON_DATE - W_OD_DATE);
        IF W_UPTO_OD > 0 THEN
          IF W_UPTO_OD < W_NOD THEN
            W_IGN := 1;
          END IF;
        END IF;
        IF W_FROM_OD > 0 THEN
          IF W_FROM_OD > W_NOD THEN
            W_IGN := 1;
          END IF;
        END IF;
        IF W_IGN = 0 THEN
          FETCH_BALANCE;
          --Poorani - Chn-23/12/2010 - IF W_ASON_DATE = W_CBD THEN
          IF W_ASON_DATE <> W_CBD THEN
            FETCH_ASON_EQ_CBDBAL;
          ELSE
            FETCH_ASON_NEQ_CBDBAL;
          END IF;
          UPDATE_RTMPOD;
        END IF;
      END IF;
    END LOOP;
  END IF;
  P_TEMP_SER := W_TEMP_SER;
EXCEPTION
  WHEN MYEXCEPTION THEN
    P_TEMP_SER := 0;
    P_ERR_MSG  := W_ERR_MSG;
    ROLLBACK;
  WHEN OTHERS THEN
    W_ERR_MSG := SQLERRM;
    P_ERR_MSG := W_ERR_MSG;
    ROLLBACK;
END SP_RODLIST;
/
