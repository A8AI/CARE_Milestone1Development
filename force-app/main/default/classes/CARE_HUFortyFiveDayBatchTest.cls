/**************************************************************************************************   
Apex Batch Name      :  CARE_HUFortyFiveDayBatchTest
Version              :  1.0                                                                          
Created Date         :  08/04/2020                                                              
Function             :  Test class for CARE_HUFortyFiveDayBatch
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   08/04/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_HUFortyFiveDayBatchTest {
    
	public static Date dTodaysDate = Date.today();
    public static Date dFortyFiveDay = dTodaysDate.addDays(-45);
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
        
       careCICCRecord = new CARE_CI_CC__c(PER_ID__c = '7437437437', CC_TYPE_CD__c = 'VH', CC_DTTM__c = date.today()-70, USER_ID__c = '1234');
        careCICCRecord2 = new CARE_CI_CC__c(PER_ID__c = '7437437437', CC_TYPE_CD__c = 'H RAND CERT', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord3 = new CARE_CI_CC__c(PER_ID__c = '6767676767', CC_TYPE_CD__c = 'FC', CC_DTTM__c = date.today()-20, USER_ID__c = '1234');
        careCICCRecord4 = new CARE_CI_CC__c(PER_ID__c = '6767676767', CC_TYPE_CD__c = 'VH', CC_DTTM__c = date.today()-70, USER_ID__c = '1234');
        
        careCICCList.add(careCICCRecord);
        careCICCList.add(careCICCRecord2);
        careCICCList.add(careCICCRecord3);
        careCICCList.add(careCICCRecord4);
       insert careCICCList;
        
       careBatchDetailRec = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-70, CARE_CI_CC__c = careCICCList[0].Id ,CC_TYPE_CD__c = 'VH',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '7437437437',USER_ID_CARE1__c = '1234');
        
       careBatchDetailRec2 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123412', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[1].Id ,CC_TYPE_CD__c = 'H RAND CERT',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '7437437437',USER_ID_CARE1__c = '1234', CCB_Contact_Type_No__c = '119');
        
        careBatchDetailRec3 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-20, CARE_CI_CC__c = careCICCList[2].Id ,CC_TYPE_CD__c = 'FC',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '6767676767',USER_ID_CARE1__c = '1234');
        
        careBatchDetailRec4 = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1234123111', CC_DTTM__c = date.today()-70, CARE_CI_CC__c = careCICCList[3].Id ,CC_TYPE_CD__c = 'VH',DETAIL_STATUS_CODE__c = 'Validate',
                                                        PER_ID__c = '6767676767',USER_ID_CARE1__c = '1234');
        
        careBatchDetailList.add(careBatchDetailRec);
        careBatchDetailList.add(careBatchDetailRec2);
        careBatchDetailList.add(careBatchDetailRec3);
        careBatchDetailList.add(careBatchDetailRec4);
        insert careBatchDetailList;
        
        List<Account> listAccountRecords = new List<Account>();
               
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
        objSite1.Person_ID_EI__c = '6767676767';
        listSiteRecords.add(objSite1);
        insert listSiteRecords;
                                                                                                     
   }
    
    public static testMethod void TestHUFortyFiveDayMethod(){
        Test.startTest();

            CARE_HUFortyFiveDayBatch obj = new CARE_HUFortyFiveDayBatch();
            DataBase.executeBatch(obj);
        	String helper = '0 0 6 * * ?';
        	CARE_HUFortyFiveDayBatchScheduler testsch = new CARE_HUFortyFiveDayBatchScheduler ();
        	system.schedule('Test CARE_HUFortyFiveDayBatchScheduler', helper, testsch);
            
        Test.stopTest();
    }
}