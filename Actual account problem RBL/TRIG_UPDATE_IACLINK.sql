CREATE OR REPLACE TRIGGER TRIG_UPDATE_IACLINK
   BEFORE UPDATE OF IACLINK_ACTUAL_ACNUM
   ON IACLINK
   FOR EACH ROW
DECLARE
 PRAGMA AUTONOMOUS_TRANSACTION;
V_COUNT NUMBER ;
BEGIN
   SELECT COUNT(*) 
     INTO V_COUNT
     FROM IACLINK
    WHERE IACLINK_ENTITY_NUM = 1
    AND IACLINK_ACTUAL_ACNUM = :new.IACLINK_ACTUAL_ACNUM;

   IF V_COUNT > 0 THEN
      RAISE_APPLICATION_ERROR (
         -20002,
         'Same account number exists for account number ' || :NEW.IACLINK_ACTUAL_ACNUM || ' Number of AC : '||V_COUNT);
   END IF;

EXCEPTION
    WHEN OTHERS THEN 
      RAISE_APPLICATION_ERROR (
         -20004,
         SQLERRM);
   
END;
/ 