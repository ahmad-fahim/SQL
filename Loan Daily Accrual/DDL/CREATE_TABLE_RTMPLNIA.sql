CREATE TABLE RTMPLNIA
(
  RTMPLNIA_RUN_NUMBER        NUMBER(6)          NOT NULL,
  RTMPLNIA_ACNT_NUM          NUMBER(14)         NOT NULL,
  RTMPLNIA_VALUE_DATE        DATE               NOT NULL,
  RTMPLNIA_ACCRUAL_DATE      DATE               NOT NULL,
  RTMPLNIA_ACNT_CURR         VARCHAR2(3 BYTE),
  RTMPLNIA_ACNT_BAL          NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_INT_ON_AMT        NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_OD_PORTION        NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_INT_RATE          NUMBER(8,5)        DEFAULT 0,
  RTMPLNIA_SLAB_AMT          NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_OD_INT_RATE       NUMBER(8,5)        DEFAULT 0,
  RTMPLNIA_LIMIT             NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_DP                NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_INT_AMT           NUMBER(18,9)       DEFAULT 0,
  RTMPLNIA_INT_AMT_RND       NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_OD_INT_AMT        NUMBER(18,9)       DEFAULT 0,
  RTMPLNIA_OD_INT_AMT_RND    NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_NPA_STATUS        NUMBER(1)          DEFAULT 0,
  RTMPLNIA_NPA_AMT           NUMBER(18,3)       DEFAULT 0,
  RTMPLNIA_ARR_OD_INT_AMT    NUMBER(18,3),
  RTMPLNIA_MAX_ACCRUAL_DATE  DATE
)
TABLESPACE TBFES
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;



ALTER TABLE RTMPLNIA ADD (
  PRIMARY KEY
  (RTMPLNIA_RUN_NUMBER, RTMPLNIA_ACNT_NUM, RTMPLNIA_VALUE_DATE, RTMPLNIA_ACCRUAL_DATE)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON RTMPLNIA TO ROLE_ATM;

GRANT DELETE, INSERT, SELECT, UPDATE ON RTMPLNIA TO ROLE_SPFTL;
