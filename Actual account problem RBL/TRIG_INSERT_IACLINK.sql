CREATE OR REPLACE TRIGGER TRIG_INSERT_IACLINK
   BEFORE INSERT
   ON IACLINK
   FOR EACH ROW
DECLARE
V_COUNT NUMBER ;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   SELECT COUNT(*) 
     INTO V_COUNT
     FROM IACLINK
    WHERE IACLINK_ENTITY_NUM = 1
    AND IACLINK_ACTUAL_ACNUM = :new.IACLINK_ACTUAL_ACNUM;

   IF V_COUNT > 0 THEN
      RAISE_APPLICATION_ERROR (
         -20001,
         'Same account number exists for account number ' || :NEW.IACLINK_ACTUAL_ACNUM|| ' Number of AC : '||V_COUNT);
   END IF;

EXCEPTION
    WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR (
         -20003,
         'Same account number exists for account number ' || :NEW.IACLINK_ACTUAL_ACNUM|| ' Number of AC : '||V_COUNT||SQLERRM);
   
END;
/
