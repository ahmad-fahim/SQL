CREATE TABLE AML_CUSTOMERS
(
  CUSTOMERNO             VARCHAR2(27 BYTE)      NOT NULL,
  CUSTUNIQTRACKNO        VARCHAR2(140 BYTE),
  CBSBRANCHCODE          VARCHAR2(36 BYTE),
  SERVICETYPE            VARCHAR2(7 BYTE),
  SCRCUSTOMERTYPE        VARCHAR2(40 BYTE),
  CUSTOMERCATEGORY       VARCHAR2(120 BYTE),
  SHORTNAME              VARCHAR2(140 BYTE),
  SALUTATION             VARCHAR2(20 BYTE),
  FIRSTNAME              VARCHAR2(140 BYTE),
  MIDDLENAME             VARCHAR2(140 BYTE),
  LASTNAME               VARCHAR2(140 BYTE),
  COUNTRY                VARCHAR2(36 BYTE),
  NID                    VARCHAR2(140 BYTE),
  FATHERNAME             VARCHAR2(140 BYTE),
  MOTHERNAME             VARCHAR2(140 BYTE),
  GENDER                 CHAR(3 BYTE),
  MARITALSTATUS          CHAR(3 BYTE),
  SPOUSENAME             VARCHAR2(140 BYTE),
  EDUCATIONALSTATUS      CHAR(3 BYTE),
  PRESENTADDRESS1        VARCHAR2(120 BYTE),
  PRESENTADDRESS2        VARCHAR2(140 BYTE),
  PRESENTADDRESS3        VARCHAR2(140 BYTE),
  PRESENTPOSTCODE        VARCHAR2(20 BYTE),
  PRESENTSTATE           VARCHAR2(36 BYTE),
  PRESENTCITY            VARCHAR2(36 BYTE),
  PRESENTCOUNTRY         VARCHAR2(140 BYTE),
  PERMANENTADDRESS1      VARCHAR2(120 BYTE),
  PERMANENTADDRESS2      VARCHAR2(140 BYTE),
  PERMANENTADDRESS3      VARCHAR2(140 BYTE),
  PERMANENTPOSTCODE      VARCHAR2(20 BYTE),
  PERMANENTSTATE         VARCHAR2(36 BYTE),
  PERMANENTCITY          VARCHAR2(36 BYTE),
  PERMANENTCOUNTRY       VARCHAR2(140 BYTE),
  NATIONALITY            VARCHAR2(36 BYTE),
  DOB                    DATE,
  PHONE                  VARCHAR2(140 BYTE),
  MOBILE                 VARCHAR2(140 BYTE),
  EMAIL                  VARCHAR2(140 BYTE),
  HOMEPHONE              VARCHAR2(50 BYTE),
  WORKPHONE              VARCHAR2(50 BYTE),
  FAX                    VARCHAR2(50 BYTE),
  RESIDENTSTATUS         VARCHAR2(50 BYTE),
  COMMUNICATIONMODE      VARCHAR2(50 BYTE),
  BIRTHCRETIFICATENO     VARCHAR2(50 BYTE),
  BIRTHPLACE             VARCHAR2(50 BYTE),
  BIRTHCOUNTRY           VARCHAR2(50 BYTE),
  LANGUAGE               VARCHAR2(50 BYTE),
  TIN                    VARCHAR2(140 BYTE),
  VATREGNO               VARCHAR2(50 BYTE),
  REGISTRATIONNO         VARCHAR2(50 BYTE),
  PASSPORTNO             VARCHAR2(140 BYTE),
  PASSPORTISSUECOUNTRY   VARCHAR2(50 BYTE),
  PASSPORTISSUEDATE      DATE,
  PASSPORTEXPIRYDATE     DATE,
  VISANO                 VARCHAR2(20 BYTE),
  EXPIRYDATEOFVISA       CHAR(20 BYTE),
  ISUSCITIZEN            VARCHAR2(50 BYTE),
  ISGREENCARDHOLDER      VARCHAR2(50 BYTE),
  ISUSOWNERSHIP          VARCHAR2(50 BYTE),
  DESIGNATION            VARCHAR2(50 BYTE),
  NAMEOFEMPLOYER         VARCHAR2(50 BYTE),
  EMPLOYERADDRESS1       VARCHAR2(50 BYTE),
  EMPLOYERADDRESS3       VARCHAR2(50 BYTE),
  EMPLOYERADDRESS2       VARCHAR2(50 BYTE),
  SOURCEOFFUND           VARCHAR2(50 BYTE),
  SOURCEOFINCOME         VARCHAR2(50 BYTE),
  INTRODUCERNAME         VARCHAR2(50 BYTE),
  INTRODUCERACCNO        VARCHAR2(50 BYTE),
  ACCOUNTOPENINGOFFICER  VARCHAR2(50 BYTE),
  ACCOUNTOPENINGPURPOSE  VARCHAR2(50 BYTE),
  ACCOUNTOPENINGWAY      VARCHAR2(50 BYTE),
  CUSTOMERCREATIONDATE   DATE,
  LASTUPDATEDATE         DATE,
  ENTRYDATE              DATE,
  CUSTOMERTYPE           CHAR(3 BYTE),
  PERMANENTADDRESS4      VARCHAR2(35 BYTE),
  PRESENTADDRESS4        VARCHAR2(35 BYTE),
  NETWORTH               VARCHAR2(35 BYTE),
  KYCSTATUS              VARCHAR2(35 BYTE),
  KYCREFNO               VARCHAR2(35 BYTE),
  ENVRISK                VARCHAR2(35 BYTE),
  SECT                   VARCHAR2(35 BYTE),
  SME                    VARCHAR2(35 BYTE),
  SUBMITAGEPROOF         VARCHAR2(20 BYTE),
  ISACTIVE               NUMBER
);