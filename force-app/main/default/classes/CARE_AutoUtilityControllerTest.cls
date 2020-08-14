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
    
    public static EI_SA_Char__c eISaCharRec;
    
    public static List<CARE_CI_CC__c> careCICCList = new List<CARE_CI_CC__c>();
    public static List<CARE_CC_Batch_Detail__c> careBatchDetailList = new List<CARE_CC_Batch_Detail__c>();
    public static List<Account> listAccountRecords = new List<Account>();
    public static List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
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
        listAccountRecords.add(objAccountRecord);  
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
        careCICCRecord7 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'ESA COMP', CC_DTTM__c = date.today()-870, USER_ID__c = '1234');
        careCICCRecord8 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = '7', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord9 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'H RAND CERT', CC_DTTM__c = date.today()-90, USER_ID__c = '1234');
        careCICCRecord10 = new CARE_CI_CC__c(PER_ID__c = '3434343434', CC_TYPE_CD__c = 'DE', CC_DTTM__c = date.today()-90, USER_ID__c = '1234');
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
        careBatchDetailRec7 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-870, CARE_CI_CC__c = careCICCList[6].Id ,CC_TYPE_CD__c = 'ESA COMP',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec8 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[7].Id ,CC_TYPE_CD__c = '7',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '6036');
        careBatchDetailRec9 = new CARE_CC_Batch_Detail__c(APPLICATION__c = careApp.Id, CARE_APP_ENROLLED_SA__c = careEnrol2.Id, ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-90, CARE_CI_CC__c = careCICCList[8].Id ,CC_TYPE_CD__c = 'H RAND CERT',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
        careBatchDetailRec10 = new CARE_CC_Batch_Detail__c(APPLICATION__c = careApp.Id, CARE_APP_ENROLLED_SA__c = careEnrol2.Id, ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-90, CARE_CI_CC__c = careCICCList[9].Id ,CC_TYPE_CD__c = 'DE',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3434343434',USER_ID_CARE1__c = '1234');
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
        insert careBatchDetailList;
        careAppIdSet.add(careBatchDetailList[2].APPLICATION__c);
        system.debug('careBatchDetailList---->'+careBatchDetailList);
        system.debug('careBatchDetailList size---->'+careBatchDetailList.size());
        
        eISaCharRec = new EI_SA_Char__c(SERVICE_AGREEMENT__c = listSiteRecords[1].Id, EXTERNAL_ID__c = '5656565656', SA_ID__c = '8989898989', CHAR_TYPE_CD__c = 'CARE USG', CHAR_VAL__c = 'GT-600');
        insert eISaCharRec;
    }
    
    @isTest
    public static void testFortyFiveDaysCheck(){
        
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
        
        
        Test.startTest();
        CARE_AutoUtilityController.PEVFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.HUFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.eSAFortyFiveDaysCheck(careBatchList);
        CARE_AutoUtilityController.createEsaCompRecord(setCareAppId);
        CARE_AutoUtilityController.thresholdExceedCheckMethod(setPerId, wrapperInputObj);
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
        CARE_AutoUtilityController.thresholdExceedCheckMethod(setPerId, wrapperInputObj);
        Test.stopTest();
        
    }

}