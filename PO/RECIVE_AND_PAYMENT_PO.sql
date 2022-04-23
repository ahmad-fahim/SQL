WITH PO_DATA AS
(SELECT DDPOPAYDB_ENTITY_NUM, DDPOPAYDB_REMIT_CODE, DDPOPAYDB_INST_PFX, DDPOPAYDB_LEAF_NUM, DDPOPAYDB_ISSUED_BRN, DDPOPAYDB_INST_AMT, 
DDPOPAYDB_ISSUED_ON_BRN,DDPOPAYDB_BENEF_NAME1, DDPOPAYDB_STATUS,DDPOPAYDB_INST_DATE, DDPOPAYDB_PAY_CAN_DUP_DATE
FROM DDPOPAYDB
WHERE DDPOPAYDB_ENTITY_NUM=1
AND DDPOPAYDB_REMIT_CODE='1'
AND DDPOPAYDB_ISSUED_BRN=:P_BRANCH_CODE
--AND NVL(DDPOPAYDB_STATUS,'#') NOT IN ('C')
AND DDPOPAYDB_ISSUED_ON_BRN=:P_BRANCH_CODE),
DAY_WISE_DD_PO
AS(
SELECT DDPOPAYDB_INST_DATE DDPOPAYDB_ADVICE_REC_DATE, SUM(NVL(DDPOPAYDB_INST_AMT,0)) CREDIT,0 DEBIT, COUNT(*) NUMBER_OF_INSTRUMENT_RECIVE,0 NUMBER_OF_INSTRUMENT_PAY
FROM PO_DATA
GROUP BY DDPOPAYDB_INST_DATE
UNION ALL
SELECT DDPOPAYDB_PAY_CAN_DUP_DATE DDPOPAYDB_ADVICE_REC_DATE, 0 CREDIT,SUM(NVL(DDPOPAYDB_INST_AMT,0)) DEBIT, 0 NUMBER_OF_INSTRUMENT_RECIVE, COUNT(*) NUMBER_OF_INSTRUMENT_PAY
FROM PO_DATA
WHERE NVL(DDPOPAYDB_STATUS,'#') in ('P','C')
GROUP BY DDPOPAYDB_PAY_CAN_DUP_DATE),
DAY_WISE_DD_PO_BALANCE AS
(
SELECT '134104101' TRAN_GLACC_CODE, DDPOPAYDB_ADVICE_REC_DATE, DEBIT DEBIT_PAY ,NUMBER_OF_INSTRUMENT_RECIVE,CREDIT CREDIT_RECIVE, NUMBER_OF_INSTRUMENT_PAY,
SERIAL,SUM(CREDIT - DEBIT) OVER(ORDER BY SERIAL) BALANCE,
ROW_NUMBER( ) OVER (PARTITION BY DDPOPAYDB_ADVICE_REC_DATE ORDER BY DDPOPAYDB_ADVICE_REC_DATE,SERIAL DESC
NULLS LAST) SERIAL_DAY
FROM (SELECT DDPOPAYDB_ADVICE_REC_DATE, DEBIT , CREDIT,ROW_NUMBER( ) OVER (ORDER BY DDPOPAYDB_ADVICE_REC_DATE
NULLS LAST) SERIAL,SUM(NUMBER_OF_INSTRUMENT_RECIVE) OVER(PARTITION BY DDPOPAYDB_ADVICE_REC_DATE) NUMBER_OF_INSTRUMENT_RECIVE,
SUM(NUMBER_OF_INSTRUMENT_PAY) OVER(PARTITION BY DDPOPAYDB_ADVICE_REC_DATE) NUMBER_OF_INSTRUMENT_PAY,
SUM(CREDIT - DEBIT) OVER(PARTITION BY DDPOPAYDB_ADVICE_REC_DATE
                        ORDER BY DDPOPAYDB_ADVICE_REC_DATE) BALANCE  
                         FROM DAY_WISE_DD_PO))
SELECT TR.TR_NUMBER_OF_INSTRUMENT_RECIVE-DD.NUMBER_OF_INSTRUMENT_RECIVE TRAN_MINUS_DD_RECIVE, TR.TOTAL_RECIVE_AMOUNT-DD.ADVICE_RECIVE_AMOUNT TRAN_MINUS_DD_RECIVE_AMT,
 TR.TR_NUMBER_OF_INSTRUMENT_PAY-DD.NUMBER_OF_INSTRUMENT_PAY TRAN_MINUS_DD_PAY,TR.TOTAL_PAY_AMOUNT-DD.ADVICE_PAY_AMOUNT TRAN_MINUS_DD_PAY_AMT FROM 
 (
---- day wise receive payment 
SELECT DDPOPAYDB_ADVICE_REC_DATE,SUM(CREDIT_RECIVE) ADVICE_RECIVE_AMOUNT, SUM(DEBIT_PAY) ADVICE_PAY_AMOUNT,
SUM(NUMBER_OF_INSTRUMENT_RECIVE) NUMBER_OF_INSTRUMENT_RECIVE, SUM(NUMBER_OF_INSTRUMENT_PAY) NUMBER_OF_INSTRUMENT_PAY
 FsROM DAY_WISE_DD_PO_BALANCE
 GROUP BY DDPOPAYDB_ADVICE_REC_DATE)  DD,
(SELECT TRAN_DATE_OF_TRAN, SUM(RECIVE_AMOUNT) TOTAL_RECIVE_AMOUNT,SUM(NUMBER_OF_INSTRUMENT_RECIVE) TR_NUMBER_OF_INSTRUMENT_RECIVE,  SUM(PAY_AMOUNT) TOTAL_PAY_AMOUNT, 
SUM(NUMBER_OF_INSTRUMENT_PAY) TR_NUMBER_OF_INSTRUMENT_PAY
FROM(
SELECT TRAN_DATE_OF_TRAN, TRAN_BRN_CODE,TRAN_DB_CR_FLG, (CASE WHEN TRAN_DB_CR_FLG='C' THEN TRAN_AMOUNT ELSE 0 END) RECIVE_AMOUNT,
(CASE WHEN TRAN_DB_CR_FLG='C' THEN 1 ELSE 0 END) NUMBER_OF_INSTRUMENT_RECIVE,
(CASE WHEN TRAN_DB_CR_FLG='D' THEN 1 ELSE 0 END) NUMBER_OF_INSTRUMENT_PAY,
 (CASE WHEN TRAN_DB_CR_FLG='D' THEN TRAN_AMOUNT ELSE 0 END) PAY_AMOUNT,TRAN_NARR_DTL1, TRAN_NARR_DTL2 INSTRUMENT_NUMBER
FROM TRAN2015
WHERE TRAN_GLACC_CODE = '134104101'
AND TRAN_DATE_OF_TRAN=:TRAN_DATE
AND TRAN_AC_CANCEL_AMT=0
AND TRAN_ACING_BRN_CODE=:P_BRANCH_CODE)
GROUP BY TRAN_DATE_OF_TRAN) TR
WHERE TR.TRAN_DATE_OF_TRAN=DD.DDPOPAYDB_ADVICE_REC_DATE
AND (DD.ADVICE_RECIVE_AMOUNT<>TR.TOTAL_RECIVE_AMOUNT 
    OR DD.ADVICE_PAY_AMOUNT<>TR.TOTAL_PAY_AMOUNT
    OR DD.NUMBER_OF_INSTRUMENT_RECIVE<>TR.TR_NUMBER_OF_INSTRUMENT_RECIVE
    OR DD.NUMBER_OF_INSTRUMENT_PAY<>TR.TR_NUMBER_OF_INSTRUMENT_PAY);
    
SELECT *
FROM TRAN2015
WHERE TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
AND TRAN_DATE_OF_TRAN = :TRAN_DATE
AND TRAN_GLACC_CODE = '134104101'


SELECT TO_NUMBER(REPLACE(REGEXP_REPLACE(TRAN_NARR_DTL2,'[a-zA-Z'']',''),'-'))
FROM TRAN2014
WHERE TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
AND TRAN_DATE_OF_TRAN = :TRAN_DATE
AND TRAN_GLACC_CODE = '134104101'
UNION ALL
SELECT TO_NUMBER(REPLACE(REGEXP_REPLACE(TRAN_NARR_DTL2,'[a-zA-Z'']',''),'-'))
FROM TRAN2015
WHERE TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
AND TRAN_DATE_OF_TRAN = :TRAN_DATE
AND TRAN_GLACC_CODE = '134104101'
MINUS
SELECT DDPOPAYDB_LEAF_NUM
FROM DDPOPAYDB
WHERE DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
AND DDPOPAYDB_ADVICE_REC_DATE = :TRAN_DATE
AND DDPOPAYDB_STATUS<>'C'
AND DDPOPAYDB_REMIT_CODE IN ('2','9');


SELECT * FROM DDPOPAYDB
WHERE DDPOPAYDB_LEAF_NUM IN (SELECT TO_NUMBER(REPLACE(REGEXP_REPLACE(TRAN_NARR_DTL2,'[a-zA-Z'']',''),'-'))
FROM TRAN2014
WHERE TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
AND TRAN_DATE_OF_TRAN = :TRAN_DATE
AND TRAN_GLACC_CODE = '134104101'
UNION ALL
SELECT TO_NUMBER(REPLACE(REGEXP_REPLACE(TRAN_NARR_DTL2,'[a-zA-Z'']',''),'-'))
FROM TRAN2015
WHERE TRAN_ACING_BRN_CODE = :P_BRANCH_CODE
AND TRAN_DATE_OF_TRAN = :TRAN_DATE
AND TRAN_GLACC_CODE = '134104101'
MINUS
SELECT DDPOPAYDB_LEAF_NUM
FROM DDPOPAYDB
WHERE DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
AND DDPOPAYDB_ADVICE_REC_DATE = :TRAN_DATE
AND DDPOPAYDB_STATUS<>'C'
AND DDPOPAYDB_REMIT_CODE IN ('2','9'));

SELECT DDPOPAYDB_LEAF_NUM,DDPOPAYDB_STATUS
FROM DDPOPAYDB
WHERE DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
AND DDPOPAYDB_ADVICE_REC_DATE = :TRAN_DATE
AND DDPOPAYDB_REMIT_CODE IN ('2','9')
AND DDPOPAYDB_STATUS IN ('C','R');

SELECT *
FROM DDADVPARTDTL
WHERE DDADVPARTDTL_BRN_CODE = :P_BRANCH_CODE
AND DDADVPARTDTL_ADV_REC_DATE = :TRAN_DATE
AND DDADVPARTDTL_REM_CODE IN ('2','9')
AND DDADVPARTDTL_LEAF_NUMBER IN (SELECT DDPOPAYDB_LEAF_NUM
FROM DDPOPAYDB
WHERE DDPOPAYDB_ISSUED_ON_BRN = :P_BRANCH_CODE
AND DDPOPAYDB_ADVICE_REC_DATE = :TRAN_DATE
AND DDPOPAYDB_REMIT_CODE IN ('2','9')
AND DDPOPAYDB_STATUS IN ('C','R'));