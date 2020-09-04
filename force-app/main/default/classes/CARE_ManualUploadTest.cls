/**************************************************************************************************   
Apex Batch Name      :  CARE_ManualUploadTest
Version              :  1.0                                                                          
Created Date         :  08/04/2020                                                              
Function             :  Test class for CARE_ManualUpload
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   08/20/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_ManualUploadTest {
    
    public static CARE_Batch_Staging__c careBatchStagingRecord1;
    public static CARE_Batch_Staging__c careBatchStagingRecord2;
    public static CARE_Batch_Staging__c careBatchStagingRecord3;
    public static CARE_Batch_Staging__c careBatchStagingRecord4;
    public static CARE_Batch_Staging__c careBatchStagingRecord5;
    
    public static EI_Bulk_Upload_History__c careBulkUploadHistory1;
    public static EI_Bulk_Upload_History__c careBulkUploadHistory2;
    
	public static List<Account> listAccountRecords = new List<Account>();
    public static List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
    public static List<CARE_Batch_Staging__c> careBatchStagingList = new List<CARE_Batch_Staging__c>();
    public static List<EI_Bulk_Upload_History__c> careBulkLoadList = new List<EI_Bulk_Upload_History__c>();
    
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
        objSite1.Person_ID_EI__c = '7437437437';
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
        objSite2.Person_ID_EI__c = '1212121212';
        listSiteRecords.add(objSite2);
        insert listSiteRecords;
        
        //insert CARE BATCH STAGING Record
        careBatchStagingRecord1 = new CARE_Batch_Staging__c(PER_ID__c = '7437437437', APPLICANT_NAME__c = 'Test V Applicant1', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        careBatchStagingRecord2 = new CARE_Batch_Staging__c(PER_ID__c = '3434343434', APPLICANT_NAME__c = 'Test V Applicant2', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        careBatchStagingRecord3 = new CARE_Batch_Staging__c(PER_ID__c = '12121212ab', APPLICANT_NAME__c = 'Test VH Applicant1', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        careBatchStagingRecord4 = new CARE_Batch_Staging__c(PER_ID__c = '7437437437', APPLICANT_NAME__c = 'Test V Applicant1', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0016', Processing_Message__c = '');
        careBatchStagingRecord5 = new CARE_Batch_Staging__c(PER_ID__c = '1919191919', APPLICANT_NAME__c = 'Test V Applicant1', EI_ACCOUNT__c = listAccountRecords[0].Id, 
                                                       CARE_BILLING_ACCT_ID__c = '9999999999', Processing_Status__c = 'Loaded', JOB_NO__c = 'CBJ-0017', Processing_Message__c = '');
        
        careBatchStagingList.add(careBatchStagingRecord1);
        careBatchStagingList.add(careBatchStagingRecord2);
        careBatchStagingList.add(careBatchStagingRecord3);
        careBatchStagingList.add(careBatchStagingRecord4);
        careBatchStagingList.add(careBatchStagingRecord5);
        insert careBatchStagingList;
        
        datetime NOW  = system.now();
        careBulkUploadHistory1 = new EI_Bulk_Upload_History__c(Account_EI__c = listAccountRecords[0].Id, File_Name_EI__c = 'V-CODEUPLOAD.csv', File_Upload_Date_EI__c = NOW,
                                                             Bulk_Upload_Sta_EI__c = 'Completed Successfully', File_Rec_Count_EI__c = 10, Error_Count_EI__c = 10,
                                                             Success_Count_EI__c = 0);
        careBulkUploadHistory2 = new EI_Bulk_Upload_History__c(Account_EI__c = listAccountRecords[0].Id, File_Name_EI__c = 'VH-CODEUPLOAD.csv', File_Upload_Date_EI__c = NOW,
                                                             Bulk_Upload_Sta_EI__c = 'Completed Successfully', File_Rec_Count_EI__c = 10, Error_Count_EI__c = 10,
                                                             Success_Count_EI__c = 0);
        
        careBulkLoadList.add(careBulkUploadHistory1);
        careBulkLoadList.add(careBulkUploadHistory2);
        insert careBulkLoadList;
    }
    
    @isTest
    public static void testManualUpload(){
       
        String sJobNo = 'CBJ-0016';
        Set<Id> cbsIdSet = new Set<Id>();
        List<CARE_Batch_Staging__c> cbsList = [SELECT Id, PER_ID__c FROM CARE_Batch_Staging__c WHERE PER_ID__c IN ('7437437437', '3434343434', '1919191919')];
        for(CARE_Batch_Staging__c cbs : cbsList){
        cbsIdSet.add(cbs.Id);    
        }
        String sLibName = 'Bulkload Home';
        String sResFileName = 'VCode_result_';
        List<EI_Bulk_Upload_History__c> bulkUploadList = [SELECT Id, File_Name_EI__c, Bulk_Upload_Sta_EI__c from EI_Bulk_Upload_History__c where File_Name_EI__c IN ('V-CODEUPLOAD.csv', 'VH-CODEUPLOAD.csv')];
        
        //String sArg = ('buhId'+':'+bulkUploadList[0].Id+','+'libraryName'+':'+sLibName);
        String jsonPass1 = '{"buhId":"' + String.valueOf(bulkUploadList[0].Id) + '", "libraryName":"' + sLibName + '"}';
        String jsonPass2 = '{"buhId":"' + String.valueOf(bulkUploadList[1].Id) + '", "libraryName":"' + sLibName + '"}';
        //String jsonData = JSON.serialize(sArg);
            
        Test.startTest();
        CARE_ManualUpload.getRecordsForManualLoad(sJobNo);
        CARE_ManualUpload.prepareResultCSV(cbsIdSet, bulkUploadList[0].Id, sLibName, sResFileName);
        CARE_ManualUpload.processVCode objManualVUpload = new CARE_ManualUpload.processVCode();
        objManualVUpload.execute(jsonPass1);
        CARE_ManualUpload.processVHCode objManualVHUpload = new CARE_ManualUpload.processVHCode();
        objManualVHUpload.execute(jsonPass2);
        Test.stopTest(); 
    }
    
}