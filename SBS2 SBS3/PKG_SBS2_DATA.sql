CREATE OR REPLACE PACKAGE PKG_SBS2_DATA IS
  
  TYPE TY_TEMP_SBS2_DATA IS RECORD(
    TOTAL_DATA VARCHAR2(1000) );

  TYPE TTY_TEMP_SBS2DATA IS TABLE OF TY_TEMP_SBS2_DATA;

  FUNCTION FN_SBS2_DATA(P_ENTITY_NUM NUMBER , P_BRANCH_CODE NUMBER, P_FROM_DATE DATE , P_TO_DATE DATE) RETURN TTY_TEMP_SBS2DATA
    PIPELINED;

END PKG_SBS2_DATA;
/



CREATE OR REPLACE PACKAGE BODY PKG_SBS2_DATA
IS
   TEMP_TY_SBS2_DATA   PKG_SBS2_DATA.TY_TEMP_SBS2_DATA;
   
   TYPE SBSDATA IS RECORD (TEMP_DATA VARCHAR2(1000));

   TYPE IN_SBSDATA IS TABLE OF SBSDATA
      INDEX BY PLS_INTEGER;

   V_IN_SBSDATA   IN_SBSDATA;
   l_start NUMBER;
   
   V_SL           NUMBER := 0;
   ---V_FILE_DATA    CLOB;
   V_DATA         VARCHAR2 (3000);

   FUNCTION FN_SBS2_DATA (P_ENTITY_NUM NUMBER , P_BRANCH_CODE NUMBER, P_FROM_DATE DATE , P_TO_DATE DATE)
      RETURN TTY_TEMP_SBS2DATA
      PIPELINED
   -- RETURN VARCHAR2
   IS
      TYPE TEMP_SBS2_DATA IS RECORD
      (
         TOTAL_DATA CLOB 
      );

      TYPE TY_SBS2_DATA IS TABLE OF TEMP_SBS2_DATA;

      V_TY_SBS2_DATA   TY_SBS2_DATA;
      V_DATA_QUERY CLOB;
      
   BEGIN
   -- l_start := DBMS_UTILITY.get_time;
   V_SL := 0 ;
      SP_SBS2_DATA_QUERY (P_BRANCH_CODE,
                          P_FROM_DATE,
                          P_TO_DATE,
                          V_DATA_QUERY);

      EXECUTE IMMEDIATE V_DATA_QUERY
         BULK COLLECT INTO V_IN_SBSDATA
         USING P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_FROM_DATE,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_TO_DATE,
               P_FROM_DATE,
               P_TO_DATE,
               P_ENTITY_NUM,
               P_BRANCH_CODE,
               P_TO_DATE;
    
    --DBMS_OUTPUT.put_line('Query Exeecution Time' || (DBMS_UTILITY.get_time - l_start) || ' hsecs');
     --l_start := DBMS_UTILITY.get_time;
    
      IF V_IN_SBSDATA.COUNT > 0
      THEN
         FOR I IN V_IN_SBSDATA.FIRST .. V_IN_SBSDATA.LAST
         LOOP
            V_SL := V_SL + 1;
            V_DATA := LPAD (V_SL, 6, '0') || V_IN_SBSDATA (I).TEMP_DATA;

            TEMP_TY_SBS2_DATA.TOTAL_DATA := TO_CHAR(V_DATA) ;
            
            PIPE ROW (TEMP_TY_SBS2_DATA);
            
            --V_FILE_DATA := V_FILE_DATA || (CASE WHEN V_FILE_DATA IS NOT NULL THEN CHR (10) END) || V_DATA;
         --UTL_FILE.PUT (V_FILE, V_DATA);
         --UTL_FILE.NEW_LINE (V_FILE, 1);
         --DBMS_OUTPUT.PUT_LINE(V_IN_SBSDATA.COUNT);
         END LOOP;
         --DBMS_OUTPUT.put_line('Result Time' || (DBMS_UTILITY.get_time - l_start) || ' hsecs');  
         V_IN_SBSDATA.DELETE;
      END IF;
      
    
   END FN_SBS2_DATA;
END PKG_SBS2_DATA;
/
