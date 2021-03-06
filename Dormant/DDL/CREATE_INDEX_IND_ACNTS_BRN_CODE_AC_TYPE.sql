CREATE INDEX IND_ACNTS_BRN_CODE_AC_TYPE ON ACNTS
(ACNTS_ENTITY_NUM, ACNTS_BRN_CODE, ACNTS_AC_TYPE)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


ALTER INDEX IND_ACNTS_BRN_CODE_AC_TYPE
REBUILD
NOCOMPRESS
NOPARALLEL
TABLESPACE TBFES
STORAGE (
         INITIAL     64K
         NEXT        1M
        );
        
        