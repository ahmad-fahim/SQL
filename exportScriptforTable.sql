/*Export script after migration. The impdp command will import the dump file to the SBL010715AFTHE schema for the UAT and SBBDPRODUCTION schema for the production.*/
expdp SONALI_MIG_4/###password### tables=ACASLL,ACASLLDTL,ACNTBAL,ACNTBBAL,ACNTCBAL,ACNTCBBAL,ACNTCONTRACT,ACNTCVDBBAL,ACNTFRZ,ACNTLINK,ACNTMAIL,temp_sec,ACNTOTN,ACNTS,ACNTLIEN,ACNTSTATUS,ACNTVDBBAL,ADVBAL,ADVBBAL,ADVVDBBAL,ASSETCLS,ASSETCLSHIST,BATCHCOUNTER,CBISS,CLIENTNUM,CLIENTOTN,CLIENTOTNDTL,CLIENTS,CLIENTSBKDTL,CONNPINFO,CORPCLIENTS,DDPOISS,DDPOISSDTL,DDPOISSDTLANX,DDPOPAYDB,DENOMBAL,DENOMDBAL,DEPACCLIEN,depcls,DEPINTPAYMENT,DEPINTPAYMENTDTL,GLBBAL,IACLINK,INDCLIENTS,JOINTCLIENTS,JOINTCLIENTSDTL,LADACNTDTL,lngsacnts,lngsacntdtl,LADACNTS,LIMITLINE,limitlinehist,LIMITSERIAL,LLACNTOS,LLPROD,LNACAODHIST,LNACDISB,LNACDSDTL,LNACDSDTLHIST,LNACGUAR,LNACIR,LNACIRHIST,LNACIRS,LNACIRSHIST,LNACMIS,LNACMISHIST,LNACRS,LNACRSDTL,LNACRSHDTL,LNACRSHIST,LNSUSPBAL,LNSUSPLED,LOANACNTOTN,LOANACNTS,MARGINREC,NOMENTRY,NOMREG,PBCOUNT,PBDCONTDSA,PBDCONTDSAHIST,PBDCONTRACT,PIDDOCS,PROVLED,RDINS,STOPCHQ,STOPLEAF,TDSPI,TDSPIDTL,VAULTBAL,VAULTDBAL,TBILLSERIAL,INVSPDOCIMG,CLAMIMAGE,spdocimage,SECRCPT,SECASSIGNMENTS,SECASSIGNMTDTL,SECASSIGNMTBAL,SECASSIGNMTDBAL,SECMORTGAGE,SECMORTEC,SECINVEST,SECVEHICLE,SECCLIENT,SECSHARES,SECSHARESDTL,SECINSUR,SECSTKBKDB,SECSTKBKDBDTL,SECSTKBKDT,SECSTKBKDTDTL,LNDP,LNDPHIST,LIMFACCURR,LIMITLINEAUX,LOANACHIST,LOANACHISTDTL,LOANACDTL,LIMITLINECTREQ,LNSUBVENRECV,LNACSUBSIDY,LNACIRDTL,LNACIRHDTL,addrdtls,PBDCONTTRFOD,TDSREMITGOV,HOVERING,HOVERRECBRK,amlacturnover,hoverseq,ecsacmap,LADDEPLINK,LADDEPLINKHIST,LADDEPLINKHISTDTL,LNGOVTSEC,SECVAL,LOCKERAVL,LOCKERAVLHIST,LOCKERAM,LOCKERCHGSHIST,LOCKERACCHIST,LOCKERACC,LOCKERKEYHIST,LOCKERKEY,LOCKERDTLS,LOCKERRENT,LOCKERSTAT,LOCKERSTATHIST,ACSEQGEN,DEPRCPTPRNT,LEGALNOTICE,LEGALSTAT,LEGALACTION,LNACINTCTL,LNACINTCTLHIST,ITFORMS,CLIENTMEM,MEMNUM,DEPCLIENTNOMMEM,NOMINALMEMNUM,LNNOMINALMEM,LNNOMINALMEMDTL,ACNTOTN,ACNTOTNNEW,LNACCHGS,LNACCHGSQBAL,LNACCHGSQLED,VAULTDBAL,DENOMDBAL,LNACINTARHIST,LNACINTARDTL,LNACINTARHDTL,LNACINTAR,LNTOTINTDBMIG,SMSBREG,SMSBREGDTL,SMSBREGSVC,ivracnts,,IBS_AC_BAL,MIG_LDR,MIG_TDS,MIG_FWD,MIG_RD,IBS_GL_BAL,IBS_NOMENTRY,MIG_DP,MIG_PDISB,MIG_FWDCFINT,MIG_SBACCR,MIG_CLIENT_ACCESS,MIG_ACNTS_ACCESS,MIG_DEP_ACCESS,MIG_CLIENTSBKDTL_ACCESS,MIG_CLNT_KYCACC,MIG_JOINTCLIENTSDTL_ACCESS,MIG_JOINTCLIENTS_ACCESS,MIG_OVERDUE_DETAILS,MIG_CP,MIG_OBC,MIG_IBC,MIG_SCH_MAST,MIG_TL_MAST,MIG_INT_MAST,MIG_CHEQ_BK,MIG_CHEQSTOP,MIG_CUMUSUB,MIG_NPARPT,MIG_BANK,MIG_BR_PARA,MIG_AC_MAST_NEW,MIG_D_MAST_NEW,MIG_LNRPST,TEMP_CLIENT,DEPIA,LOANIA,SBCAIA,LOANIADTL,SBCAIABRK,ACBALASONHIST,ACBALASONHIST_MAX,ACBALASONHIST_AVGBAL,NOMREGDTL,ACBALASONHIST_MIN,SNDPROD,MMB_ACNTS,DDADVPART,DDADVPARTDTL,LOANIAMRR,LOANIAMRRDTL,BLLOANIA,LNWRTOFF,TRAN2018,GLSUM2018,TRANADV2018,TRANBAT2018,TRANADVADDN2018,CTRAN2018,LNWRTOFFRECOV directory=DUMPDIR_MIG dumpfile=SONALI_MIG_4_52167_ROWMORI_V1.DMP logfile=EXP_SONALI_MIG_4_52167_ROWMORI_V1.log

expdp SONALI_21DEC/sonali1234 tables=INVSPDOCIMG,CLAMIMAGE,SPDOCIMAGE directory=DUMPDIR dumpfile=SIG_SONALI_31OCT_10066_CHOWKBAZAR_V1.dmp logfile=SIG_EXP_SONALI_31OCT_10066_CHOWKBAZAR_V1.log

scp SONALI_MIG_17_55194_MUKIMKATRA_V1.DMP oracle@10.32.10.87:/oradata9/

--UAT

host(impdp SBL010715AFTHE/###password### directory=DUMPDIR_MIG dumpfile=SONALI_MIG_4_52167_ROWMORI_V1.DMP logfile=IMP_SONALI_MIG_4_52167_ROWMORI_V1.LOG remap_schema=SONALI_MIG_4:SBL010715AFTHE transform=oid:n IGNORE='Y')


-- PRODUCTION


impdp system/oracle directory=DUMPDIR dumpfile=EXPDP_RBL_PRODUCTION_31AUG2016_DATA_BEOD.dmp logfile=LOGPDIR:impSBLPROD_BODAY290816.log remap_schema=RBL_PRODUCTION:RBL_PROD transform=oid:n

host(impdp SBBDPRODUCTION/###password### directory=DUMPDIR dumpfile=SONALI_MIG_3_6205_KAHALU_BOGRA_V1.DMP logfile=IMP_SONALI_MIG_3_6205_KAHALU_BOGRA_V1.LOG remap_schema=SONALI_MIG_5:SBBDPRODUCTION transform=oid:n IGNORE='Y')

EXPORT OF PRODUCTIONDUMP
expdp SBBDPRODUCTION/###password### schemas=SBBDPRODUCTION directory=DUMPDIR dumpfile=SBBDPROD_CBD_22_JAN_2015_BEFORE_MIGRATION.dmp logfile=EXP_SBBDPROD_CBD_22_JAN_2015_BEFORE_MIGRATION.log parallel = 20

--without Image file

expdp SBLPROD/###password### schemas=SBLPROD directory=DUMPDIR dumpfile=SBBDPROD_CBD_30_AUG_2015_AFTER_MIGRATION_V4.dmp logfile=EXP_SBBDPROD_CBD_30_AUG_2015_AFTER_MIGRATION_V4.log EXCLUDE=TABLE:\"LIKE \'SPDOCIMAGE\'\"