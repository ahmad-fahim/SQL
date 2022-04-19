------ create table tranlegacy



create table TRANLEGACY
(
       
  tranbrncode         NUMBER(6) ,
  transactionno       NUMBER(18) default 0,
  transactiondate     DATE ,
  backvaluedate       DATE,
  accounttypecode     VARCHAR2(2 ),
  accountno           VARCHAR2(10) ,
  ledgerno            NUMBER(5) default 0 ,
  transactionmode     VARCHAR2(2) ,
  tranmode            VARCHAR2(50),
  transactiontypecode VARCHAR2(2 ) default '0',
  trantype             VARCHAR2(100),
  
  vouchertype         VARCHAR2(20) ,
  chequeno            VARCHAR2(25) default '0' ,
  chequedate          DATE,
  batchno             VARCHAR2(10) default '0' ,
  ibttype             VARCHAR2(1 ) default '0' ,
  ibtcodedesc         VARCHAR2(100) ,
  ibtdate             DATE,
  ibtbranchcode       VARCHAR2(10 ) default '0' ,
  ibtadviceno         VARCHAR2(20 ) default '0' ,
  branchcode          VARCHAR2(10 ) default '0' ,
  debit               NUMBER(18,2) default 0 ,
  credit              NUMBER(18,2) default 0 ,
  description         VARCHAR2(100 ) default '0' ,
  debitinterest       NUMBER(18,2) default 0 ,
  creditinterest      NUMBER(18,2) default 0 ,
  noticegiven         NUMBER(1) default 0 ,
  tellerid            VARCHAR2(10 ) ,
  verified            NUMBER(1) default 0 ,
  verifiedby          VARCHAR2(10 ) default '0' ,
  reversaled          NUMBER(1) default 0 ,
  dishonorcode        VARCHAR2(2 ) default '0' ,
  posted              VARCHAR2(1 ) default '0' ,
  chkdigit            INTEGER default 0,
  secondmanverify     NUMBER(1) default 0,
  instrumentno        VARCHAR2(50 ) default '0',
  billno              VARCHAR2(30 ) default '0',
  accountstatuscode   VARCHAR2(2 ) default '1',
  accountstatusdetail VARCHAR2(100) ,
  availablebalance    NUMBER(18,2) default 0 ,
  ibttrancode         VARCHAR2(15 ) default '0' ,
  accountcode         VARCHAR2(10 ) default '0' ,
  transmark           VARCHAR2(25 ),
  foliono             INTEGER default 0,
  trackaccno          VARCHAR2(30 ) default '0',
  jointverifiedby     VARCHAR2(10 ),
  daysdiff            INTEGER default 0 ,
  remitype            VARCHAR2(2 ) default '0',
  trntime             DATE default CURRENT_TIMESTAMP ,
  autotran            NUMBER(1) default 0 ,
  revtrnuser          VARCHAR2(50 ),
  revreason           VARCHAR2(150 ),
  zonalexp            NUMBER(1) default 0 
) ;


-------------------------------------------------------------------------
-------------------------------------------------------------------------

----  Prepare transhistory_dummy from  union all tables

create table transhistory_bak as select * from transhistory ;
create table transhistory_dummy as select * from transhistory where 1=2 ;


---

select * from user_tables t where t.TABLE_NAME like 'TRANSHISTORY%';


insert into transhistory_dummy ( 
select * from transhistory
union all
select * from transhistory2016
union all
select * from transhistory2015
union all
select * from transhistory2014
union all
select * from transhistory2013
union all
select * from transhistory2010
union all
select * from transhistory20..... 


---- union all the availabale tranhistory table . this is important .
---- double check before inserting. please put all the previous tranhistory table starting from current year

)


-------------------------------------------------------------------------
-------------------------------------------------------------------------


----  insert data into tranlegacy

INSERT INTO TRANLEGACY
  (TRANSACTIONNO,
   TRANSACTIONDATE,
   BACKVALUEDATE,
   ACCOUNTTYPECODE,
   ACCOUNTNO,
   LEDGERNO,
   TRANSACTIONMODE,
   TRANSACTIONTYPECODE,
   VOUCHERTYPE,
   CHEQUENO,
   CHEQUEDATE,
   BATCHNO,
   IBTTYPE,
   IBTDATE,
   IBTBRANCHCODE,
   IBTADVICENO,
   BRANCHCODE,
   DEBIT,
   CREDIT,
   DESCRIPTION,
   DEBITINTEREST,
   CREDITINTEREST,
   NOTICEGIVEN,
   TELLERID,
   VERIFIED,
   VERIFIEDBY,
   REVERSALED,
   DISHONORCODE,
   POSTED,
   CHKDIGIT,
   SECONDMANVERIFY,
   INSTRUMENTNO,
   BILLNO,
   ACCOUNTSTATUSCODE,
   AVAILABLEBALANCE,
   IBTTRANCODE,
   ACCOUNTCODE,
   TRANSMARK,
   FOLIONO,
   TRACKACCNO,
   JOINTVERIFIEDBY,
   DAYSDIFF,
   REMITYPE,
   TRNTIME,
   AUTOTRAN,
   REVTRNUSER,
   REVREASON,
   ZONALEXP)
  SELECT TRIM(TRANSACTIONNO),
         TRIM(TRANSACTIONDATE),
         TRIM(BACKVALUEDATE),
         TRIM(ACCOUNTTYPECODE),
         TRIM(ACCOUNTNO),
         TRIM(LEDGERNO),
         TRIM(TRANSACTIONMODE),
         TRIM(TRANSACTIONTYPECODE),
         TRIM(VOUCHERTYPE),
         TRIM(CHEQUENO),
         TRIM(CHEQUEDATE),
         TRIM(BATCHNO),
         TRIM(IBTTYPE),
         TRIM(IBTDATE),
         TRIM(IBTBRANCHCODE),
         TRIM(IBTADVICENO),
         TRIM(BRANCHCODE),
         TRIM(DEBIT),
         TRIM(CREDIT),
         TRIM(DESCRIPTION),
         TRIM(DEBITINTEREST),
         TRIM(CREDITINTEREST),
         TRIM(NOTICEGIVEN),
         TRIM(TELLERID),
         TRIM(VERIFIED),
         TRIM(VERIFIEDBY),
         TRIM(REVERSALED),
         TRIM(DISHONORCODE),
         TRIM(POSTED),
         TRIM(CHKDIGIT),
         TRIM(SECONDMANVERIFY),
         TRIM(INSTRUMENTNO),
         TRIM(BILLNO),
         TRIM(ACCOUNTSTATUSCODE),
         TRIM(AVAILABLEBALANCE),
         TRIM(IBTTRANCODE),
         TRIM(ACCOUNTCODE),
         TRIM(TRANSMARK),
         TRIM(FOLIONO),
         TRIM(TRACKACCNO),
         TRIM(JOINTVERIFIEDBY),
         TRIM(DAYSDIFF),
         TRIM(REMITYPE),
         TRIM(TRNTIME),
         TRIM(AUTOTRAN),
         TRIM(REVTRNUSER),
         TRIM(REVREASON),
         TRIM(ZONALEXP)
    FROM transhistory_dummy;
               
         
---------- update  transaction description

begin
  for idx in (
              
              select t.rowid, t.transactionmode, tm.transactiondescription
                from TRanlegacy t, transactionmode tm
               where t.transactionmode = trim(tm.transactionmode)) loop
    update tranlegacy tp
       set tp.tranmode = idx.transactiondescription
     where tp.rowid = idx.rowid;
  end loop;
end; --- press commit after completion


------------- update transation type


begin
  for idx in (
              
              select t.rowid, t.transactiontypecode, tm.typedescription
                from TRanlegacy t, transactiontype tm
               where t.transactiontypecode = trim(tm.transactiontypecode)) loop
    update tranlegacy tp
       set tp.trantype = idx.typedescription
     where tp.rowid = idx.rowid;
  end loop;
end;   --- press commit after completion


-------- update branch code

update tranlegacy t set t.tranbrncode = &branch_code; ---- put the branch code of the respective branch here





create table tranlegacy_backup as select distinct * from tranlegacy ;
truncate table tranlegacy;
insert into tranlegacy select * from tranlegacy_backup ;
commit;



delete from tranlegacy t
 where trim(t.transactionno) = 0
   and t.accountno in
       (select a.accountno from accountlegacy a where a.product_type = 4)
 commit;

 
 
 
 
 ----------------------------------------------------------------
 
 
 
/*   after completing tranlegacy and accountlegacy update for each migrated branch,
login to HISTORY_MIGRATION_30JUN16 
and run  these below scripts :  */
 
insert into tranlegacy
select * from schema_name.Tranlegacy; ---- replace schema_name with migrated branch's schema name
commit;

insert into accountlegacy
select * from schema_name.accountlegacy; ---- replace schema_name with migrated branch's schema name
commit;

         
         