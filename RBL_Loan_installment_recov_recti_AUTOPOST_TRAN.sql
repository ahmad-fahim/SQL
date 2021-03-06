/*For a customer, we had problems for the loan auto installment process. We had to reverse that whole thansaction and stop the process from then.*/
SELECT DENSE_RANK() OVER (ORDER BY TRAN_BRN_CODE) BATCH_SL,
       ROW_NUMBER() OVER (PARTITION BY TRAN_BRN_CODE ORDER BY TRAN_BRN_CODE) LEG_SL,
       NULL TRAN_DATE,
       NULL VALUE_DATE,
       NULL SUPP_TRAN,
       TRAN_BRN_CODE BRN_CODE,
       TRAN_ACING_BRN_CODE ACING_BRN_CODE,
       'D' DR_CR,
       NULL GLACC_CODE,
       LNINSTRECV_INTERNAL_ACNUM INT_AC_NO,
       NULL CONT_NO,
       TRAN_CURR_CODE CURR_CODE,
       TRAN_AMOUNT AC_AMOUNT,
       TRAN_BASE_CURR_EQ_AMT BC_AMOUNT,
       TRANADV_PRIN_BC_AMT PRINCIPAL,
       TRANADV_INTRD_BC_AMT INTEREST,
       TRANADV_CHARGE_BC_AMT CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'Auto Loan Installment Recovery Reversal' LEG_NARRATION,
       'Auto Loan Installment Recovery Reversal'BATCH_NARRATION,
       'SPFTL3' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG,
       NULL DEPT_CODE
  FROM LNINSTRECV, TRANADV2019, TRAN2019
 WHERE     TRAN_ENTITY_NUM = 1
       AND TRAN_BRN_CODE = TRANADV_BRN_CODE
       AND TRAN_DATE_OF_TRAN = TRANADV_DATE_OF_TRAN
       AND TRAN_BATCH_NUMBER = TRANADV_BATCH_NUMBER
       AND TRAN_BATCH_SL_NUM = TRANADV_BATCH_SL_NUM
       AND TRAN_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM
       AND TRANADV_ENTITY_NUM = 1
       AND LNINSTRECV_ENTITY_NUM = 1
       AND POST_TRAN_BRN = TRAN_BRN_CODE
       AND POST_TRAN_DATE = TRAN_DATE_OF_TRAN
       AND POST_TRAN_BATCH_NUM = TRAN_BATCH_NUMBER
       AND TRAN_DATE_OF_TRAN = '19-OCT-2019'
       ORDER BY TRAN_BRN_CODE	
	   
	   
	   
SELECT DENSE_RANK() OVER (ORDER BY TRAN_BRN_CODE) BATCH_SL,
       ROW_NUMBER() OVER (PARTITION BY TRAN_BRN_CODE ORDER BY TRAN_BRN_CODE) LEG_SL,
       NULL TRAN_DATE,
       NULL VALUE_DATE,
       NULL SUPP_TRAN,
       TRAN_BRN_CODE BRN_CODE,
       (SELECT ACNTS_BRN_CODE FROM ACNTS WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = LNINSTRECV_RECOV_FROM_ACNT) ACING_BRN_CODE,
       'C' DR_CR,
       NULL GLACC_CODE,
       LNINSTRECV_RECOV_FROM_ACNT INT_AC_NO,
       NULL CONT_NO,
       TRAN_CURR_CODE CURR_CODE,
       TRAN_AMOUNT AC_AMOUNT,
       TRAN_BASE_CURR_EQ_AMT BC_AMOUNT,
       NULL PRINCIPAL,
       NULL INTEREST,
       NULL CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'Auto Loan Installment Recovery Reversal' LEG_NARRATION,
       'Auto Loan Installment Recovery Reversal'BATCH_NARRATION,
       'SPFTL3' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG,
       NULL DEPT_CODE
  FROM LNINSTRECV, TRANADV2019, TRAN2019
 WHERE     TRAN_ENTITY_NUM = 1
       AND TRAN_BRN_CODE = TRANADV_BRN_CODE
       AND TRAN_DATE_OF_TRAN = TRANADV_DATE_OF_TRAN
       AND TRAN_BATCH_NUMBER = TRANADV_BATCH_NUMBER
       AND TRAN_BATCH_SL_NUM = TRANADV_BATCH_SL_NUM
       AND TRAN_INTERNAL_ACNUM = LNINSTRECV_INTERNAL_ACNUM
       AND TRANADV_ENTITY_NUM = 1
       AND LNINSTRECV_ENTITY_NUM = 1
       AND POST_TRAN_BRN = TRAN_BRN_CODE
       AND POST_TRAN_DATE = TRAN_DATE_OF_TRAN
       AND POST_TRAN_BATCH_NUM = TRAN_BATCH_NUMBER
       AND TRAN_DATE_OF_TRAN = '19-OCT-2019'
       ORDER BY TRAN_BRN_CODE