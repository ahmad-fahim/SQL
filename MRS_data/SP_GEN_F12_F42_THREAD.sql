CREATE OR REPLACE PROCEDURE SP_GEN_F12_F42_THREAD AS
  ln_dummy number;
begin
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(1,100); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(101,200); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(201,300); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(301,400); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(401,500); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(501,600); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(601,700); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(701,800); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(801,900); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(901,1000); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(1001,1100); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(1101,1200); end;');
  DBMS_JOB.SUBMIT(ln_dummy, 'begin SP_GEN_F12_F42_DATA(1201,1300); end;'); 
  COMMIT;
end;
