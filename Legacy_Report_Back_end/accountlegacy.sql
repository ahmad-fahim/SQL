------------ Create table accountlegacy



create table ACCOUNTLEGACY
(
  branch_code                NUMBER(6),
  accountno                  VARCHAR2(10) not null,
  customerid                 VARCHAR2(10) not null,
  customer_name              VARCHAR2(100),
  customer_address           VARCHAR2(100),
  accounttypecode            VARCHAR2(2) not null,
  product_name               VARCHAR2(100),
  operationmode              VARCHAR2(2),
  accountopendate            DATE,
  introduceraccountno        VARCHAR2(10) default '0' not null,
  introducername             VARCHAR2(50),
  residence                  NUMBER(1) default 0 not null,
  accountstatuscode          VARCHAR2(2) default '0' not null,
  accountstatusdate          DATE not null,
  accountstatusref           VARCHAR2(50) default 'Nil' not null,
  ledgerno                   NUMBER(5) default 0 not null,
  term                       NUMBER(5) default 0 not null,
  principalamount            NUMBER(18,2) default 0 not null,
  receiptno                  VARCHAR2(15),
  depositinstalment          NUMBER(18,2) default 0 not null,
  interestrate               NUMBER(6,2) default 0 not null,
  repaymenttype              VARCHAR2(1),
  paidpensionamount          NUMBER(18,2) default 0 not null,
  transferredfrom            VARCHAR2(50),
  transferreddate            DATE,
  transferredamount          NUMBER(18,2) default 0 not null,
  interestamount             NUMBER(18,2) default 0 not null,
  instalmentpensionpayment   NUMBER(18,2) default 0 not null,
  lastinstalpensionpaydate   DATE,
  noofirregularities         NUMBER(3) default 0 not null,
  interestprovision          NUMBER(18,2) default 0 not null,
  productamount              NUMBER(18,2) default 0 not null,
  fcbalance                  NUMBER(18,2) default 0 not null,
  availablebalance           NUMBER(18,2) default 0 not null,
  shadowcredit               NUMBER(18,2) default 0 not null,
  financingsoruce            VARCHAR2(50),
  servicetype                VARCHAR2(2),
  holdingbalance             NUMBER(18,2) default 0 not null,
  lastrenewaldate            DATE,
  lastrenewalamount          NUMBER(18,2) default 0 not null,
  renewalnumber              NUMBER(3) default 0 not null,
  lastanniversarydate        DATE,
  anniversarynumber          NUMBER(3) default 0 not null,
  lastanniversaryamount      NUMBER(18,2) default 0 not null,
  interestwithdrawalamount   NUMBER(18,2) default 0 not null,
  lastinterestwithdrawaldate DATE,
  duplicatereceiptno         VARCHAR2(15),
  duplicatereceiptissuedate  DATE,
  lasttransdate              DATE not null,
  lastsystransdate           DATE,
  laststatprintdate          DATE,
  totaldebit                 NUMBER(18,2) default 0 not null,
  totalcredit                NUMBER(18,2) default 0 not null,
  totaldebitvoucher          INTEGER default 0 not null,
  totalcreditvoucher         INTEGER default 0 not null,
  advancetypecode            VARCHAR2(1),
  dpamount                   NUMBER(18,2) default 0 not null,
  limitamount                NUMBER(18,2) default 0 not null,
  limitexpdate               DATE,
  minbalance                 NUMBER(18,2) default 0 not null,
  maxbalance                 NUMBER(18,2) default 0 not null,
  sanctiondate               DATE,
  sanctionno                 NUMBER(5) default 0 not null,
  sanctionamount             NUMBER(18,2) default 0 not null,
  sanctionby                 VARCHAR2(50),
  expiredate                 DATE,
  margin                     NUMBER(18,2) default 0 not null,
  economicpurposecode        VARCHAR2(4),
  lastdisbursedate           DATE,
  interestinstalment         NUMBER(18,2) default 0 not null,
  graceperiod                NUMBER(5) default 0 not null,
  noofdisbursement           NUMBER(3) default 0 not null,
  firstinstalmentdate        DATE,
  lastinstalmentdate         DATE,
  productionstartdate        DATE,
  noofinstalment             NUMBER(5) default 0 not null,
  instalmentperiod           NUMBER(5) default 0 not null,
  loantype                   VARCHAR2(10) default '0' not null,
  lastinterestcreditdate     DATE,
  totaldishonorcheque        NUMBER(3) default 0 not null,
  noofdebitperweek           NUMBER(3) default 0 not null,
  monthlyproductact          NUMBER(3) default 1 not null,
  borrowercode               VARCHAR2(10),
  linkaccountno              VARCHAR2(10),
  userid                     VARCHAR2(10),
  lastupdate                 DATE default CURRENT_TIMESTAMP,
  shadowdebit                NUMBER(18,2) default 0 not null,
  lastdebittransdate         DATE,
  lastcredittransdate        DATE,
  loancaseno                 VARCHAR2(100) default '0',
  loanduestatus              NUMBER(3) default 0,
  loandebitintrest           NUMBER(18,2) default 0 not null,
  previousinterestpaid       NUMBER(18,2) default 0,
  previousinterest           NUMBER(18,2) default 0,
  contactualintact           NUMBER(1) default 0 not null,
  dproduct                   NUMBER(18,2) default 0,
  interestfree               NUMBER(1) default 0 not null,
  exdutyfree                 NUMBER(1) default 0 not null,
  icfree                     NUMBER(1) default 0 not null,
  servicechargefree          NUMBER(1) default 0 not null,
  fxnumber                   VARCHAR2(20) default '0',
  oldaccountno               VARCHAR2(10),
  noofprint                  INTEGER default 0 not null,
  product_type               VARCHAR2(1),
  account_status             VARCHAR2(40)
) ;





------------------------------------------------------------------------------
------------------------------------------------------------------------------


---- INSERT ACCOUNTINFORMATION INTO ACCOUNTLEGACY ----


INSERT INTO ACCOUNTLEGACY
  (ACCOUNTNO,
   CUSTOMERID,
   ACCOUNTTYPECODE,
   OPERATIONMODE,
   ACCOUNTOPENDATE,
   INTRODUCERACCOUNTNO,
   INTRODUCERNAME,
   RESIDENCE,
   ACCOUNTSTATUSCODE,
   ACCOUNTSTATUSDATE,
   ACCOUNTSTATUSREF,
   LEDGERNO,
   TERM,
   PRINCIPALAMOUNT,
   RECEIPTNO,
   DEPOSITINSTALMENT,
   INTERESTRATE,
   REPAYMENTTYPE,
   PAIDPENSIONAMOUNT,
   TRANSFERREDFROM,
   TRANSFERREDDATE,
   TRANSFERREDAMOUNT,
   INTERESTAMOUNT,
   INSTALMENTPENSIONPAYMENT,
   LASTINSTALPENSIONPAYDATE,
   NOOFIRREGULARITIES,
   INTERESTPROVISION,
   PRODUCTAMOUNT,
   FCBALANCE,
   AVAILABLEBALANCE,
   SHADOWCREDIT,
   FINANCINGSORUCE,
   SERVICETYPE,
   HOLDINGBALANCE,
   LASTRENEWALDATE,
   LASTRENEWALAMOUNT,
   RENEWALNUMBER,
   LASTANNIVERSARYDATE,
   ANNIVERSARYNUMBER,
   LASTANNIVERSARYAMOUNT,
   INTERESTWITHDRAWALAMOUNT,
   LASTINTERESTWITHDRAWALDATE,
   DUPLICATERECEIPTNO,
   DUPLICATERECEIPTISSUEDATE,
   LASTTRANSDATE,
   LASTSYSTRANSDATE,
   LASTSTATPRINTDATE,
   TOTALDEBIT,
   TOTALCREDIT,
   TOTALDEBITVOUCHER,
   TOTALCREDITVOUCHER,
   ADVANCETYPECODE,
   DPAMOUNT,
   LIMITAMOUNT,
   LIMITEXPDATE,
   MINBALANCE,
   MAXBALANCE,
   SANCTIONDATE,
   SANCTIONNO,
   SANCTIONAMOUNT,
   SANCTIONBY,
   EXPIREDATE,
   MARGIN,
   ECONOMICPURPOSECODE,
   LASTDISBURSEDATE,
   INTERESTINSTALMENT,
   GRACEPERIOD,
   NOOFDISBURSEMENT,
   FIRSTINSTALMENTDATE,
   LASTINSTALMENTDATE,
   PRODUCTIONSTARTDATE,
   NOOFINSTALMENT,
   INSTALMENTPERIOD,
   LOANTYPE,
   LASTINTERESTCREDITDATE,
   TOTALDISHONORCHEQUE,
   NOOFDEBITPERWEEK,
   MONTHLYPRODUCTACT,
   BORROWERCODE,
   LINKACCOUNTNO,
   USERID,
   LASTUPDATE,
   SHADOWDEBIT,
   LASTDEBITTRANSDATE,
   LASTCREDITTRANSDATE,
   LOANCASENO,
   LOANDUESTATUS,
   LOANDEBITINTREST,
   PREVIOUSINTERESTPAID,
   PREVIOUSINTEREST,
   CONTACTUALINTACT,
   DPRODUCT,
   INTERESTFREE,
   EXDUTYFREE,
   ICFREE,
   SERVICECHARGEFREE,
   FXNUMBER,
   OLDACCOUNTNO,
   NOOFPRINT)
  SELECT NVL(TRIM(ACCOUNTNO), 0),
         TRIM(CUSTOMERID),
         TRIM(ACCOUNTTYPECODE),
         TRIM(OPERATIONMODE),
         TRIM(ACCOUNTOPENDATE),
         TRIM(INTRODUCERACCOUNTNO),
         TRIM(INTRODUCERNAME),
         TRIM(RESIDENCE),
         TRIM(ACCOUNTSTATUSCODE),
         TRIM(ACCOUNTSTATUSDATE),
         TRIM(ACCOUNTSTATUSREF),
         TRIM(LEDGERNO),
         TRIM(TERM),
         TRIM(PRINCIPALAMOUNT),
         TRIM(RECEIPTNO),
         TRIM(DEPOSITINSTALMENT),
         TRIM(INTERESTRATE),
         TRIM(REPAYMENTTYPE),
         TRIM(PAIDPENSIONAMOUNT),
         TRIM(TRANSFERREDFROM),
         TRIM(TRANSFERREDDATE),
         TRIM(TRANSFERREDAMOUNT),
         TRIM(INTERESTAMOUNT),
         TRIM(INSTALMENTPENSIONPAYMENT),
         TRIM(LASTINSTALPENSIONPAYDATE),
         TRIM(NOOFIRREGULARITIES),
         TRIM(INTERESTPROVISION),
         TRIM(PRODUCTAMOUNT),
         TRIM(FCBALANCE),
         TRIM(AVAILABLEBALANCE),
         TRIM(SHADOWCREDIT),
         TRIM(FINANCINGSORUCE),
         TRIM(SERVICETYPE),
         TRIM(HOLDINGBALANCE),
         TRIM(LASTRENEWALDATE),
         TRIM(LASTRENEWALAMOUNT),
         TRIM(RENEWALNUMBER),
         TRIM(LASTANNIVERSARYDATE),
         TRIM(ANNIVERSARYNUMBER),
         TRIM(LASTANNIVERSARYAMOUNT),
         TRIM(INTERESTWITHDRAWALAMOUNT),
         TRIM(LASTINTERESTWITHDRAWALDATE),
         TRIM(DUPLICATERECEIPTNO),
         TRIM(DUPLICATERECEIPTISSUEDATE),
         TRIM(LASTTRANSDATE),
         TRIM(LASTSYSTRANSDATE),
         TRIM(LASTSTATPRINTDATE),
         TRIM(TOTALDEBIT),
         TRIM(TOTALCREDIT),
         TRIM(TOTALDEBITVOUCHER),
         TRIM(TOTALCREDITVOUCHER),
         TRIM(ADVANCETYPECODE),
         TRIM(DPAMOUNT),
         TRIM(LIMITAMOUNT),
         TRIM(LIMITEXPDATE),
         TRIM(MINBALANCE),
         TRIM(MAXBALANCE),
         TRIM(SANCTIONDATE),
         TRIM(SANCTIONNO),
         TRIM(SANCTIONAMOUNT),
         TRIM(SANCTIONBY),
         TRIM(EXPIREDATE),
         TRIM(MARGIN),
         TRIM(ECONOMICPURPOSECODE),
         TRIM(LASTDISBURSEDATE),
         TRIM(INTERESTINSTALMENT),
         TRIM(GRACEPERIOD),
         TRIM(NOOFDISBURSEMENT),
         TRIM(FIRSTINSTALMENTDATE),
         TRIM(LASTINSTALMENTDATE),
         TRIM(PRODUCTIONSTARTDATE),
         TRIM(NOOFINSTALMENT),
         TRIM(INSTALMENTPERIOD),
         TRIM(LOANTYPE),
         TRIM(LASTINTERESTCREDITDATE),
         TRIM(TOTALDISHONORCHEQUE),
         TRIM(NOOFDEBITPERWEEK),
         TRIM(MONTHLYPRODUCTACT),
         TRIM(BORROWERCODE),
         TRIM(LINKACCOUNTNO),
         TRIM(USERID),
         TRIM(LASTUPDATE),
         TRIM(SHADOWDEBIT),
         TRIM(LASTDEBITTRANSDATE),
         TRIM(LASTCREDITTRANSDATE),
         TRIM(LOANCASENO),
         TRIM(LOANDUESTATUS),
         TRIM(LOANDEBITINTREST),
         TRIM(PREVIOUSINTERESTPAID),
         TRIM(PREVIOUSINTEREST),
         TRIM(CONTACTUALINTACT),
         TRIM(DPRODUCT),
         TRIM(INTERESTFREE),
         TRIM(EXDUTYFREE),
         TRIM(ICFREE),
         TRIM(SERVICECHARGEFREE),
         TRIM(FXNUMBER),
         TRIM(OLDACCOUNTNO),
         TRIM(NOOFPRINT)
    FROM ACCOUNTINFORMATION
	WHERE TRIM(CUSTOMERID) IS NOT NULL;




------------------------------------------------------------------------------
------------------------------------------------------------------------------

-------- update branch code

update ACCOUNTLEGACY t set t.branch_code = &branch_code ; ---- put the branch code of the respective branch here 



------------------------------------------------------------------------------
------------------------------------------------------------------------------


------- update customer name and address

begin
  for idx in (select a.customerid, c.customername, c.customeraddress
                from accountlegacy a, customer c
               where a.customerid = trim(c.customerid ) ) loop
    update accountlegacy a
       set a.customer_name    = idx.customername,
           a.customer_address = substr( idx.customeraddress,1,100)
     where a.customerid = idx.customerid;
  end loop;
end;   ---- press commit after completion


------- update product name

begin
  for idx in (select a.accounttypecode, c.accounttypename
                from accountlegacy a, accounttype c
               where a.accounttypecode = trim(c.accounttypecode ) ) loop
    update accountlegacy a
       set a.product_name    = idx.accounttypename
         
     where a.accounttypecode = idx.accounttypecode;
  end loop;
end;  ---- press commit after completion


------- update account status

begin
  for idx in (select a.accountstatuscode, c.statusdescription
                from accountlegacy a, accountstatuscode c
               where a.accountstatuscode = trim(c.statuscode ) ) loop
    update accountlegacy a
       set a.account_status    = trim(idx.statusdescription)
         
     where a.accountstatuscode = trim(idx.accountstatuscode);
  end loop;
end;    ---- press commit after completion


----------- update product type

update accountlegacy a set a.product_type = 1 where a.accounttypecode < 25 ; 
update accountlegacy a set a.product_type = 3 where a.accounttypecode < 45 and a.accounttypecode > 24 ;
update accountlegacy a set a.product_type = 4 where a.accounttypecode > 44  ;
commit;




