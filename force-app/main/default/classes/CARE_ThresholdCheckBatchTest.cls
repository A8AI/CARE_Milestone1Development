/**************************************************************************************************   
Apex Batch Name      :  CARE_ThresholdCheckBatchTest
Version              :  1.0                                                                          
Created Date         :  08/20/2020                                                              
Function             :  Test class for CARE_ThresholdCheckBatch
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* AATG                   08/20/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_ThresholdCheckBatchTest {
    
    public static CARE_CI_CC__c careCICCRecord1;
    public static CARE_CI_CC__c careCICCRecord2;
    
    public static CARE_CC_Batch_Detail__c careBatchDetailRec1;
    public static CARE_CC_Batch_Detail__c careBatchDetailRec2;
    
    public static List<CARE_CI_CC__c> careCICCList = new List<CARE_CI_CC__c>();
    public static List<CARE_CC_Batch_Detail__c> careBatchDetailList = new List<CARE_CC_Batch_Detail__c>();
    public static List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
    
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
        objAccountRecord.Billing_Person_ID_EI__c = '3030303030';
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
        objSite1.Site_Premise_ID_EI__c = 'Prem1';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        objSite1.Person_ID_EI__c = '3030303030';
        listSiteRecords.add(objSite1);
        insert listSiteRecords;
        
        careCICCRecord1 = new CARE_CI_CC__c(PER_ID__c = '3030303030', CC_TYPE_CD__c = 'ESA COMP', CC_DTTM__c = date.today()-725, USER_ID__c = '1234');
        careCICCRecord2 = new CARE_CI_CC__c(PER_ID__c = '3030303030', CC_TYPE_CD__c = '7', CC_DTTM__c = date.today()-1, USER_ID__c = '1234');
        careCICCList.add(careCICCRecord1);
        careCICCList.add(careCICCRecord2);
        insert careCICCList;
        
        careBatchDetailRec1 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-725, CARE_CI_CC__c = careCICCList[0].Id ,CC_TYPE_CD__c = 'ESA COMP',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3030303030', USER_ID_CARE1__c = '1234');
        careBatchDetailRec2 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-1,CARE_CI_CC__c = careCICCList[1].Id ,CC_TYPE_CD__c = '7',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '3030303030',USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '6036');
        careBatchDetailList.add(careBatchDetailRec1);
        careBatchDetailList.add(careBatchDetailRec2);
        insert careBatchDetailList;
        
        EI_SA_Char__c saChar = new EI_SA_Char__c();
        saChar.SA_ID__c=listSiteRecords[0].SAID_EI__c;
        saChar.CHAR_TYPE_CD__c='CARE-USG';
        saChar.CHAR_VAL__c = 'GT-600';
        saChar.EXTERNAL_ID__c = '5656565656';
        saChar.SERVICE_AGREEMENT__c=listSiteRecords[0].Id;
        insert saChar;   
    }
    
    public static testMethod void testThresholdCheckMethod(){ 
        Test.startTest();
        
            CARE_ThresholdCheckBatch obj = new CARE_ThresholdCheckBatch(); 
          	DataBase.executeBatch(obj);
        	String helper = '0 0 6 * * ?';
        	CARE_ThresholdCheckBatchScheduler testsch = new CARE_ThresholdCheckBatchScheduler();
        	system.schedule('Test CARE_ThresholdCheckBatchScheduler', helper, testsch);
            
        Test.stopTest();
    }

}