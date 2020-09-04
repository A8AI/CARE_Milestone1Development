/**************************************************************************************************   
Apex Batch Name      :  CARE_AutoUtilityControllerTest
Version              :  1.0                                                                          
Created Date         :  08/04/2020                                                              
Function             :  Test class for CARE_AutoUtilityController
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   08/10/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_AutoUtilityControllerTest {
    
    public static Date dTodaysDate = Date.today();
    public static Date dFortyFiveDay = dTodaysDate.addDays(-45);
    
    public static CARE_CI_CC__c careCICCRecord1;
    public static CARE_CI_CC__c careCICCRecord2;
    public static CARE_CI_CC__c careCICCRecord3;
    public static CARE_CI_CC__c careCICCRecord4;
    public static CARE_CI_CC__c careCICCRecord5;
    public static CARE_CI_CC__c careCICCRecord6;
    public static CARE_CI_CC__c careCICCRecord7;
    public static CARE_CI_CC__c careCICCRecord8;
    public static CARE_CI_CC__c careCICCRecord9;
    public static CARE_CI_CC__c careCICCRecord10;
    public static CARE_CI_CC__c careCICCRecord11;
    
    public static CARE_CC_Batch_Detail__c careBatchDetailRec1;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec2;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec3;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec4;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec5;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec6;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec7;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec8;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec9;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec10;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec11;
    
    public static CARE_Batch_Staging__c careBatchStagingRec1;
    public static CARE_Batch_Staging__c careBatchStagingRec2;
    public static CARE_Batch_Staging__c careBatchStagingRec3;
    public static CARE_Batch_Staging__c careBatchStagingRec4;
    
    public static CARE_Type__c careTypeV;
    public static CARE_Type__c careTypeVH;
    
    public static EI_SA_Char__c eISaCharRec1;
    public static EI_SA_Char__c eISaCharRec2;
    public static EI_SA_Char__c eISaCharRec3;
    
    public static List<CARE_CI_CC__c> careCICCList = new List<CARE_CI_CC__c>();
    public static List<CARE_CC_Batch_Detail__c> careBatchDetailList = new List<CARE_CC_Batch_Detail__c>();
    public static List<CARE_Batch_Staging__c> careBatchStagingList = new List<CARE_Batch_Staging__c>();
    public static List<Account> listAccountRecords = new List<Account>();
    public static List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
    public static List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
    public static List<EI_SA_Char__c> listSACharType = new List<EI_SA_Char__c>();
    public static Set<Id> careAppIdSet = new Set<Id>();
    public static Set<Id> setCareAppId = new Set<Id>();
    public static Set<String> setPerId = new Set<String>();
    
    @testSetup 
    public static void setup() {
        
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        objAccountRecord.AccountNumber = '1224590384';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.SAID__c = '7777777777';
        objAccountRecord.Phone = '9065231';
        objAccountRecord.Discount__c = 'C';
        objAccountRecord.Billing_Person_ID_EI__c = '7437437437';
        objAccountRecord.Service_Address__c = 'Search1234';
        objAccountRecord.SA_Type__c = 'E';
        objAccountRecord.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord.Type = 'Type';
        objAccountRecord.Rate__c = 'HAG1A';
        objAccountRecord.Branch_Code_EI__c = 'Get';
        objAccountRecord.Original_Tree_Level_EI__c = 2.0;
        objAccountRecord.CARE_ON_PROBATION__c = false;
        listAccountRecords.add(objAccountRecord); 
        
        Account objAccountRecord2 = PM_EI_TestDataUtility.createAccount();
        objAccountRecord2.AccountNumber = '1224590385';
        objAccountRecord2.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord2.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord2.SAID__c = '7777777777';
        objAccountRecord2.Phone = '9065231';
        objAccountRecord2.Discount__c = 'C';
        objAccountRecord2.Billing_Person_ID_EI__c = '1111155555';
        objAccountRecord2.Service_Address__c = 'Search1234';
        objAccountRecord2.SA_Type__c = 'E';
        objAccountRecord2.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord2.Type = 'Type';
        objAccountRecord2.Rate__c = 'HAG1A';
        objAccountRecord2.Branch_Code_EI__c = 'Get';
        objAccountRecord2.Original_Tree_Level_EI__c = 2.0;
        objAccountRecord2.CARE_ON_PROBATION__c = false;
        listAccountRecords.add(objAccountRecord2);
        insert listAccountRecords;
        
        //Site record with status as '20', with valid Rate Schedule, and discount in 'Electric'
        EI_Site__c objSite1 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite1.Name='Site1';
        objSite1.Rate_Schedule_EI__c='STANDARD';
        objSite1.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite1.Site_Premise_ID_EI__c = '1212121212';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        objSite1.Person_ID_EI__c = '6767676767';
        listSiteRecords.add(objSite1);
        
        EI_Site__c objSite2 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite2.Name='Site2';
        objSite2.Rate_Schedule_EI__c='STANDARD';
        objSite2.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite2.Site_Premise_ID_EI__c = '1212121212';
        objSite2.Care_Start_Date_EI__c = date.today();
        objSite2.Care_Stop_Date_EI__c = date.today()+30;
        objSite2.Svc_Status_Code_EI__c = '20';
        objSite2.Svc_Type_Code_EI__c = 'E';
        objSite2.Person_ID_EI__c = '3434343434';
        listSiteRecords.add(objSite2);
        
        EI_Site__c objSite3 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite3.Name='Site2';
        objSite3.Rate_Schedule_EI__c='STANDARD';
        objSite3.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite3.Site_Premise_ID_EI__c = '1212121212';
        objSite3.Care_Start_Date_EI__c = date.today();
        objSite3.Care_Stop_Date_EI__c = date.today()+90;
        objSite3.Svc_Status_Code_EI__c = '20';
        objSite3.Svc_Type_Code_EI__c = 'E';
        objSite3.Person_ID_EI__c = '1111155555';
        listSiteRecords.add(objSite3);
        
        insert listSiteRecords;
        
        //CARE Application Insert
        CARE_Application__c careApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        careApp.ENROLLMENT_TYPE__c = 'OTHER';
        insert careApp;
        
        //CARE App Enrolled SA Insert
        CARE_App_Enrolled_SA__c careEnrol =CARE_TestDataFactory.careAppEnrolledSa(careApp,listSiteRecords[0]);
        insert careEnrol;
        
        //CARE App Enrolled SA Insert
        CARE_App_Enrolled_SA__c careEnrol2 =CARE_TestDataFactory.careAppEnrolledSa(careApp,listSiteRecords[1]);
        insert careEnrol2;
        
        //Premise Insert
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise(careEnrol.PREM_ID__c, '3333333333');
        prmemiseRecord1.Last_ESA_Enrollment_Date__c = System.today()-90;
        prmemiseRecord1.ESA_Last_Treated_EI__c = System.today()-90;
        insert prmemiseRecord1;
        
        careCICCRecord1 = new CARE_CI_CC__c(PER_ID__c = '7437437437', CC_TYPE_CD__c = 'V', CC_DTTM__c = date.today()-70, USER_ID__c = '1234');
        careCICCRecord2 = new CARE_CI_CC__c(PER_ID__c = '7437437437', CC_TYPE_CD__c = 'C AE CARE', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord3 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'H RAND CERT', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord4 = new CARE_CI_CC__c(PER_ID__c = '6767676767', CC_TYPE_CD__c = 'FC', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord5 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'V', CC_DTTM__c = date.today()-70, USER_ID__c = '1234');
        careCICCRecord6 = new CARE_CI_CC__c(PER_ID__c = '7437437437', CC_TYPE_CD__c = 'VH', CC_DTTM__c = date.today()-70, USER_ID__c = '1234');
        careCICCRecord7 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'ESA COMP', CC_DTTM__c = date.today()-725, USER_ID__c = '1234');
        careCICCRecord8 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = '7', CC_DTTM__c = date.today()-1, USER_ID__c = '1234');
        careCICCRecord9 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'H RAND CERT', CC_DTTM__c = date.today()-90, USER_ID__c = '1234');
        careCICCRecord10 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'DE', CC_DTTM__c = date.today()-90, USER_ID__c = '1234');
        careCICCRecord11 = new CARE_CI_CC__c(PER_ID__c = '1111155555', CC_TYPE_CD__c = '3', CC_DTTM__c = date.today()-90, USER_ID__c = '1234');
        careCICCList.add(careCICCRecord1);
        careCICCList.add(careCICCRecord2);
        careCICCList.add(careCICCRecord3);
        careCICCList.add(careCICCRecord4);
        careCICCList.add(careCICCRecord5);
        careCICCList.add(careCICCRecord6);
        careCICCList.add(careCICCRecord7);
        careCICCList.add(careCICCRecord8);
        careCICCList.add(careCICCRecord9);
        careCICCList.add(careCICCRecord10);
        careCICCList.add(careCICCRecord11);
        insert careCICCList;
        
        careBatchDetailRec1 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-70, CARE_CI_CC__c = careCICCList[0].Id ,CC_TYPE_CD__c = 'V',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '7437437437',USER_ID_CARE1__c = '1234');
        careBatchDetailRec2 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[1].Id ,CC_TYPE_CD__c = 'C AE CARE',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '7437437437',USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '119');
        careBatchDetailRec3 = new CARE_CC_Batch_Detail__c(APPLICATION__c = careApp.Id, CARE_APP_ENROLLED_SA__c = careEnrol.Id, ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[2].Id ,CC_TYPE_CD__c = 'H RAND CERT',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec4 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[3].Id ,CC_TYPE_CD__c = 'FC',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '6767676767',USER_ID_CARE1__c = '1234');
        
        careBatchDetailRec5 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-70, CARE_CI_CC__c = careCICCList[4].Id ,CC_TYPE_CD__c = 'V',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec6 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-70, CARE_CI_CC__c = careCICCList[5].Id ,CC_TYPE_CD__c = 'VH',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '7437437437',USER_ID_CARE1__c = '1234');
        careBatchDetailRec7 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-725, CARE_CI_CC__c = careCICCList[6].Id ,CC_TYPE_CD__c = 'ESA COMP',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec8 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-1, CARE_CI_CC__c = careCICCList[7].Id ,CC_TYPE_CD__c = '7',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '6036');
        careBatchDetailRec9 = new CARE_CC_Batch_Detail__c(APPLICATION__c = careApp.Id, CARE_APP_ENROLLED_SA__c = careEnrol2.Id, ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-90, CARE_CI_CC__c = careCICCList[8].Id ,CC_TYPE_CD__c = 'H RAND CERT',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec10 = new CARE_CC_Batch_Detail__c(APPLICATION__c = careApp.Id, CARE_APP_ENROLLED_SA__c = careEnrol2.Id, ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-90, CARE_CI_CC__c = careCICCList[9].Id ,CC_TYPE_CD__c = 'DE',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec11 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-90, CARE_CI_CC__c = careCICCList[10].Id ,CC_TYPE_CD__c = '3',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '1111155555',USER_ID_CARE1__c = '1234');
        careBatchDetailList.add(careBatchDetailRec1);
        careBatchDetailList.add(careBatchDetailRec2);
        careBatchDetailList.add(careBatchDetailRec3);
        careBatchDetailList.add(careBatchDetailRec4);
        careBatchDetailList.add(careBatchDetailRec5);
        careBatchDetailList.add(careBatchDetailRec6);
        careBatchDetailList.add(careBatchDetailRec7);
        careBatchDetailList.add(careBatchDetailRec8);
        careBatchDetailList.add(careBatchDetailRec9);
        careBatchDetailList.add(careBatchDetailRec10);
        careBatchDetailList.add(careBatchDetailRec11);
        insert careBatchDetailList;
        careAppIdSet.add(careBatchDetailList[2].APPLICATION__c);
        system.debug('careBatchDetailList---->'+careBatchDetailList);
        system.debug('careBatchDetailList size---->'+careBatchDetailList.size());
        
        eISaCharRec1 = new EI_SA_Char__c(SERVICE_AGREEMENT__c = listSiteRecords[1].Id, EXTERNAL_ID__c = '5656565656', SA_ID__c = '8989898989', CHAR_TYPE_CD__c = 'CARE-USG', CHAR_VAL__c = 'GT-600');
        
        eISaCharRec2 = new EI_SA_Char__c(SERVICE_AGREEMENT__c = listSiteRecords[1].Id, EXTERNAL_ID__c = '5656565656', SA_ID__c = '8989898989', CHAR_TYPE_CD__c = 'MEDALLOT', EFFDT__c = date.today()-90, CHAR_VAL__c = '1');
        eISaCharRec3 = new EI_SA_Char__c(SERVICE_AGREEMENT__c = listSiteRecords[0].Id, EXTERNAL_ID__c = '5656565656', SA_ID__c = '8989898989', CHAR_TYPE_CD__c = 'CARE-USG', CHAR_VAL__c = 'GT-600');
        listSACharType.add(eISaCharRec1);
        listSACharType.add(eISaCharRec2);
        listSACharType.add(eISaCharRec3);
        insert listSACharType;
        
        //insert CARE BATCH STAGING Record
        careBatchStagingRec1 = new CARE_Batch_Staging__c(PER_ID__c = '7437437437', APPLICANT_NAME__c = 'Test V Applicant', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        
        careBatchStagingRec2 = new CARE_Batch_Staging__c(PER_ID__c = '3434343434', APPLICANT_NAME__c = 'Test VH Applicant', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0017', Processing_Message__c = '');
        
        careBatchStagingRec3 = new CARE_Batch_Staging__c(PER_ID__c = '1111155555', APPLICANT_NAME__c = 'Test Applicant1', EI_ACCOUNT__c = listAccountRecords[1].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '5555599999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        
        careBatchStagingRec4 = new CARE_Batch_Staging__c(PER_ID__c = '7777766666', APPLICANT_NAME__c = 'Test Applicant2', EI_ACCOUNT__c = listAccountRecords[1].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999988888', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        careBatchStagingList.add(careBatchStagingRec1);
        careBatchStagingList.add(careBatchStagingRec2);
        careBatchStagingList.add(careBatchStagingRec3);
        careBatchStagingList.add(careBatchStagingRec4);
        insert careBatchStagingList;
        
        /*CARE_Type__c cCbsType = CARE_TestDataFactory.careType();
        insert cCbsType;
        cCbsType.TYPE_NO__c = CARE_Constants.CARE_CC_V_HU;
        cCbsType.TYPE_CODE__c = 'V';
        cCbsType.TYPE_DESC__c = 'PEV Sent';
        cCbsType.TYPE_DESC_LONG__c = 'POST ENROLLMENT VERIFICATION LETTER SENT. CUSTOMER HAS 45 DAYS FOR RESPONSE MT.';
        update cCbsType;*/
    }
    
    @isTest
    public static void testFortyFiveDaysCheck(){
        
        List<CARE_CC_Batch_Detail__c> careBatchList = [Select ACCT_ID__c, APPLICATION__c, CARE_APP_ENROLLED_SA__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c, CC_DTTM__c, CARE_CI_CC__c,CARE_CI_CC__r.CC_DTTM__c, CC_TYPE_CD__c, DETAIL_STATUS_CODE__c, PER_ID__c, USER_ID_CARE1__c, CCB_Contact_Type_No__c
                                                      from CARE_CC_Batch_Detail__c where PER_ID__c IN ('7437437437', '3434343434', '6767676767')];      
        system.debug('careBatchList----->'+careBatchList);
        for(CARE_CC_Batch_Detail__c batchRecord : careBatchList){
            if(batchRecord.PER_ID__c == '3434343434'){
               setCareAppId.add(batchRecord.APPLICATION__c);
                setPerId.add(batchRecord.PER_ID__c);
            } 
        }
        
        CARE_AutoUtilityController.ESAThresholdCheckWrapper wrapperInputObj = new CARE_AutoUtilityController.ESAThresholdCheckWrapper();
        wrapperInputObj.setESACareAppId = setCareAppId;
        wrapperInputObj.setESAErrorId = setCareAppId;
        wrapperInputObj.setErrorPerId = setPerId;
        wrapperInputObj.setESADropAppId = setCareAppId;
        wrapperInputObj.setESADropErrId = setCareAppId;
        wrapperInputObj.setESADropErrPerId = setPerId;
        
        CARE_Type__c cType = CARE_TestDataFactory.careType();
        insert cType;
        cType.TYPE_NO__c = CARE_Constants.CARE_CC_ESA_ENROLLED;
        update cType;
        
        CARE_Type__c careType = CARE_TestDataFactory.careType();
        insert careType;
        careType.TYPE_NO__c = CARE_Constants.CARE_CC_HU_DROP;
        //careType.TYPE_CODE__c = CARE_Constants.CARE_CC_HU_DROP;
        update careType;
        
        
        Test.startTest();
        CARE_AutoUtilityController.PEVFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.HUFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.eSAFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.createEsaCompRecord(setCareAppId);
        CARE_AutoUtilityController.thresholdExceedCheckMethod(careBatchList);
        //CARE_AutoUtilityController.NotEnrolledESADropCustomers(careBatchList);
        //CARE_AutoUtilityController.eSASixEightyFiveDaysCheck(careBatchList);
        Test.stopTest();       
        
    }
    
    @isTest
    public static void testFortyFiveDaysExpireCheck(){
        List<CARE_CC_Batch_Detail__c> careBatchList = [Select ACCT_ID__c, APPLICATION__c, CARE_APP_ENROLLED_SA__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c, CC_DTTM__c, CARE_CI_CC__c, CC_TYPE_CD__c, DETAIL_STATUS_CODE__c, PER_ID__c, USER_ID_CARE1__c, CCB_Contact_Type_No__c
                                                      from CARE_CC_Batch_Detail__c where PER_ID__c IN ('7437437437', '3434343434', '6767676767')];      
        system.debug('careBatchList----->'+careBatchList);
        for(CARE_CC_Batch_Detail__c batchRecord : careBatchList){
            if(batchRecord.PER_ID__c == '3434343434'){
               setCareAppId.add(batchRecord.APPLICATION__c);
                setPerId.add(batchRecord.PER_ID__c);
            } 
        }
        
        CARE_AutoUtilityController.ESAThresholdCheckWrapper wrapperInputObj = new CARE_AutoUtilityController.ESAThresholdCheckWrapper();
        wrapperInputObj.setESACareAppId = setCareAppId;
        wrapperInputObj.setESAErrorId = setCareAppId;
        wrapperInputObj.setErrorPerId = setPerId;
        wrapperInputObj.setESADropAppId = setCareAppId;
        wrapperInputObj.setESADropErrId = setCareAppId;
        wrapperInputObj.setESADropErrPerId = setPerId;
        
        CARE_Type__c cType = CARE_TestDataFactory.careType();
        insert cType;
        cType.TYPE_NO__c = CARE_Constants.CARE_CC_ESA_ENROLLED;
        update cType;
        
        CARE_Type__c careType = CARE_TestDataFactory.careType();
        insert careType;
        careType.TYPE_NO__c = CARE_Constants.CARE_CC_HU_DROP;
        //careType.TYPE_CODE__c = CARE_Constants.CARE_CC_HU_DROP;
        update careType;
        
        CARE_Type__c careTypeEx = CARE_TestDataFactory.careType();
        insert careTypeEx;
        careTypeEx.TYPE_NO__c = CARE_Constants.CARE_CC_ESA_EXPIRE;
        //careType.TYPE_CODE__c = CARE_Constants.CARE_CC_HU_DROP;
        update careTypeEx;
        
        Test.startTest();
        CARE_AutoUtilityController.NotEnrolledESADropCustomers(careBatchList);
        CARE_AutoUtilityController.eSASixEightyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.createEsaCompRecord(setCareAppId);
        //CARE_AutoUtilityController.thresholdExceedCheckMethod(setPerId, wrapperInputObj);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testManualUploadMethods(){
        
        List<CARE_Batch_Staging__c> careCBSList = [Select Id, APPLICANT_NAME__c, EI_ACCOUNT__c, CARE_BILLING_ACCT_ID__c, JOB_NO__c, PER_ID__c, Processing_Message__c, Processing_Status__c
                                                      FROM CARE_Batch_Staging__c WHERE PER_ID__c IN ('7437437437', '3434343434', '1111155555', '7777766666')];
        
        Date dTodaysDate = Date.today();
        CARE_Type__c careTypeV = new CARE_Type__c(TYPE_CODE__c = 'V', TYPE_NO__c = '116', TYPE_DESC__c = 'PEV Sent', 
                                                 TYPE_DESC_LONG__c = 'POST ENROLLMENT VERIFICATION LETTER SENT. CUSTOMER HAS 45 DAYS FOR RESPONSE MT.',
                                                 START_DATE__c = date.today()-1, END_DATE__c = date.today()+30, CATEGORY__c = 'CCB Person Level Contact Code and Comments',
                                                 IS_ACTIVE__c = true);
        
        CARE_Type__c careTypeVH = new CARE_Type__c(TYPE_CODE__c = 'VH', TYPE_NO__c = '124', TYPE_DESC__c = 'PEV Sent High Usage', 
                                                 TYPE_DESC_LONG__c = 'HIGH USAGE POST ENROLLMENT VERIFICATION LETTER SENT. CUSTOMER HAS 45 DAYS TO PROVIDE INCOME PROOF DOCUMENTATION AND ESA AGREEMENT.',
                                                 START_DATE__c = date.today()-1, END_DATE__c = date.today()+30, CATEGORY__c = 'CCB Person Level Contact Code and Comments',
                                                 IS_ACTIVE__c = true);
        listCareType.add(careTypeV);
        listCareType.add(careTypeVH);
        
        insert listCareType;
        
        Test.startTest();
        CARE_AutoUtilityController.determineVCodeStamping(careCBSList);
        CARE_AutoUtilityController.determineVHCodeStamping(careCBSList);
        Test.stopTest();
    }
    
    @isTest
    public static void testProbationCheck(){
        List<String> perIdList = new List<String>();
        List<CARE_CC_Batch_Detail__c> careBatchProbList = [Select ACCT_ID__c, CC_DTTM__c, CARE_CI_CC__c, CC_TYPE_CD__c, DETAIL_STATUS_CODE__c, PER_ID__c, USER_ID_CARE1__c, CCB_Contact_Type_No__c
                                                           from CARE_CC_Batch_Detail__c where PER_ID__c IN ('3434343434', '1111155555')]; 
        for(CARE_CC_Batch_Detail__c ccBatch : careBatchProbList){
           perIdList.add(ccBatch.PER_ID__c); 
        }
        
        Test.startTest();
        CARE_AutoUtilityController.setProbationStatusOnAccount(perIdList);
        CARE_AutoUtilityController.determineProbationStatusForAccount(perIdList);
        Test.stopTest();
    }

}