/**************************************************************************************************   
Apex Batch Name      :  CARE_ESAFortyFiveDayBatchTest
Version              :  1.0                                                                          
Created Date         :  08/05/2020                                                              
Function             :  Test class for CARE_ESAFortyFiveDayBatch
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* AATG                   08/05/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_ESAFortyFiveDayBatchTest {
    
    public static Date dTodaysDate = Date.today();
    public static Date dFortyFiveDay = dTodaysDate.addDays(+45);
    public static CARE_CC_Batch_Detail__c careBatchDetailRec;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec2;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec3;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec4;
    public static CARE_CI_CC__c careCICCRecord;
    public static CARE_CI_CC__c careCICCRecord2;
    public static CARE_CI_CC__c careCICCRecord3;
    public static CARE_CI_CC__c careCICCRecord4;
    
    public static List<CARE_CI_CC__c> careCICCList = new List<CARE_CI_CC__c>();
    public static List<CARE_CC_Batch_Detail__c> careBatchDetailList = new List<CARE_CC_Batch_Detail__c>();
    
    

    @testSetup 
    public static void setup() {
         List<Account> listAccountRecords = new List<Account>();
               
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        objAccountRecord.AccountNumber = '1224590384';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.SAID__c = '7777777777';
        objAccountRecord.Phone = '9065231';
        objAccountRecord.Discount__c = 'C';
        objAccountRecord.Billing_Person_ID_EI__c = '3434343434';
        objAccountRecord.Service_Address__c = 'Search1234';
        objAccountRecord.SA_Type__c = 'E';
        objAccountRecord.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord.Type = 'Type';
        objAccountRecord.Rate__c = 'HAG1A';
        objAccountRecord.Branch_Code_EI__c = 'Get';
        objAccountRecord.Original_Tree_Level_EI__c = 2.0;
        listAccountRecords.add(objAccountRecord);  
        insert listAccountRecords;
        
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
        
        //Site record with status as '20', with valid Rate Schedule, and discount in 'Electric'
        EI_Site__c objSite1 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite1.Name='Site1';
        objSite1.Rate_Schedule_EI__c='STANDARD';
        objSite1.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite1.Site_Premise_ID_EI__c = 'Prem1';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        objSite1.Person_ID_EI__c = '3434343434';
        listSiteRecords.add(objSite1);
        insert listSiteRecords;
       CARE_Application__c careApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        careApp.ENROLLMENT_TYPE__c = 'OTHER';
        insert careApp;
        CARE_App_Enrolled_SA__c careEnrol =CARE_TestDataFactory.careAppEnrolledSa(careApp,listSiteRecords[0]);
        insert careEnrol;
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise(careEnrol.PREM_ID__c, '3333333333');
        prmemiseRecord1.Last_ESA_Enrollment_Date__c = System.today()-90;
        prmemiseRecord1.ESA_Last_Treated_EI__c = System.today()-90;
        insert prmemiseRecord1;
       /* CARE_System_Value__c cSysValue = CARE_TestDataFactory.createSystemValue('care',CARE_Constants.CARE_ESA_SystemValueCode,'17');
        insert cSysValue;    */
        
        CARE_Type__c cType = CARE_TestDataFactory.careType();
        insert cType;
        cType.TYPE_NO__c = CARE_Constants.CARE_CC_ESA_ENROLLED;
        update cType;
        
         CARE_Type__c careType = CARE_TestDataFactory.careType();
        insert careType;
        careType.TYPE_NO__c = CARE_Constants.CARE_CC_HU_DROP;
        //careType.TYPE_CODE__c = CARE_Constants.CARE_CC_HU_DROP;
        update careType;
        
       careCICCRecord = new CARE_CI_CC__c(PER_ID__c = careEnrol.PER_ID__c, CC_TYPE_CD__c = 'DE', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord2 = new CARE_CI_CC__c(PER_ID__c = careEnrol.PER_ID__c, CC_TYPE_CD__c = CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK , CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord3 = new CARE_CI_CC__c(PER_ID__c = careEnrol.PER_ID__c, CC_TYPE_CD__c = 'ESA COMP', CC_DTTM__c = date.today()-870, USER_ID__c = '1234');
        careCICCRecord4 = new CARE_CI_CC__c(PER_ID__c = careEnrol.PER_ID__c, CC_TYPE_CD__c = '7', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        //insert careCICCRecord3;
        careCICCList.add(careCICCRecord);
        careCICCList.add(careCICCRecord2);
        careCICCList.add(careCICCRecord3);
        careCICCList.add(careCICCRecord4);
       insert careCICCList;
        careBatchDetailRec = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412',APPLICATION__c=careEnrol.APPLICATION__c, CARE_APP_ENROLLED_SA__c =careEnrol.Id, CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[0].Id ,CC_TYPE_CD__c = 'DE',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = careEnrol.PER_ID__c,USER_ID_CARE1__c = '1234');
        
       careBatchDetailRec2 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-20,CARE_APP_ENROLLED_SA__c =careEnrol.Id, APPLICATION__c=careEnrol.APPLICATION__c,  CARE_CI_CC__c = careCICCList[1].Id ,CC_TYPE_CD__c = CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK,DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = careEnrol.PER_ID__c,USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '119');
        careBatchDetailRec3 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-870,CARE_APP_ENROLLED_SA__c =careEnrol.Id, APPLICATION__c=careEnrol.APPLICATION__c,  CARE_CI_CC__c = careCICCList[2].Id ,CC_TYPE_CD__c = 'ESA COMP',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = careEnrol.PER_ID__c,USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '119');
        careBatchDetailRec4 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-20,CARE_APP_ENROLLED_SA__c =careEnrol.Id, APPLICATION__c=careEnrol.APPLICATION__c,  CARE_CI_CC__c = careCICCList[3].Id ,CC_TYPE_CD__c = '7',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = careEnrol.PER_ID__c,USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '6036');
        careBatchDetailList.add(careBatchDetailRec);
        careBatchDetailList.add(careBatchDetailRec2);
         careBatchDetailList.add(careBatchDetailRec3);
        careBatchDetailList.add(careBatchDetailRec4);
        insert careBatchDetailList;
        
        EI_SA_Char__c saChar = new EI_SA_Char__c();
        saChar.SA_ID__c=listSiteRecords[0].SAID_EI__c;
        saChar.CHAR_TYPE_CD__c='CARE-USG';
        saChar.CHAR_VAL__c = 'GT-600';
        saChar.EXTERNAL_ID__c = '5656565656';
        saChar.SERVICE_AGREEMENT__c=listSiteRecords[0].Id;
        insert saChar;                                   
   }
        
    public static testMethod void TestESAFortyFiveDayMethod(){ 
        Test.startTest();
        
            CARE_ESAFortyFiveDayBatch obj = new CARE_ESAFortyFiveDayBatch(); 
          	DataBase.executeBatch(obj);
        	String helper = '0 0 6 * * ?';
        	CARE_ESAFortyFiveDayBatchScheduler testsch = new CARE_ESAFortyFiveDayBatchScheduler();
        	system.schedule('Test CARE_ESAFortyFiveDayBatchScheduler', helper, testsch);
            
        Test.stopTest();
    }
}