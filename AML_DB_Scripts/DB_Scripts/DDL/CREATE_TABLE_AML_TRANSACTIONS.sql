CREATE TABLE AML_TRANSACTIONS
(
   ACCOUNTORREFERENCENO    VARCHAR2 (20 BYTE),
   TRANSACTIONNO           VARCHAR2 (20 BYTE),
   TRANSACTIONTYPE         VARCHAR2 (20 BYTE),
   TRANSACTIONMEDIA        VARCHAR2 (50 BYTE),
   AMOUNT                  VARCHAR2 (20 BYTE),
   BALANCE                 VARCHAR2 (20 BYTE),
   CURRENCY                VARCHAR2 (20 BYTE),
   BENEFICIARYNAME         VARCHAR2 (500 BYTE),
   TELLERID                VARCHAR2 (500 BYTE),
   TRANSACTIONDATE         DATE,
   TRANSACTIONTIMESTAMP    VARCHAR2 (500 BYTE),
   CBSBRANCHCODE           VARCHAR2 (500 BYTE),
   GEOLOCATION             VARCHAR2 (80 BYTE),
   COMMENTS                VARCHAR2 (500 BYTE),
   BENIFICIARYACNO         VARCHAR2 (500 BYTE),
   BENIFICIARYBRANCHNAME   VARCHAR2 (500 BYTE),
   BENIFICIARYBANKNAME     VARCHAR2 (500 BYTE),
   DEPOSITORNAME           VARCHAR2 (100 BYTE)
)