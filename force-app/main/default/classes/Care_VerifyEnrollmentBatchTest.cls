/***********************************************************************************************************   
Apex Util class Name :  Care_VerifyEnrollmentBatchTest
Version              :  1.0                                                                          
Created Date         :  07/28/2020                                                         
Function             :  This is the Test class for Calling Full Qualification Logic.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                                 Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/28/2020            Priyanka Nimkar                                     Initial Version.
****************************************************************************************************************************************/
@istest(SeeAllData=false)

public class Care_VerifyEnrollmentBatchTest {
    EI_Site__c lstSite = new EI_Site__c();
    
    @testSetup
    public static void makeData(){
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User lstusr = PM_EI_TestDataUtility.createUser(); //called testdatafactory for creation of user
        System.debug('lstusr is'+lstusr);
        lstusr.ProfileId = p.Id;
        insert lstusr;   // inserted user
        */
        List<Account> listAccountRecords = createAccountRecords();
        insert listAccountRecords;
        /*List<EI_PREMISE__c> listPremiseRecords = createPremiseRecords();
        insert listPremiseRecords;
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords);
        insert listSiteRecords;*/
        Case objCase = CARE_TestDataFactory.objCase();
        insert objCase;
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        objCareApp.ENROLLMENT_TYPE__c = 'OTHER';
        objCareApp.CC_CL_CD__c = 'C';
        objCareApp.IS_RECERT__c =  true;
        objCareApp.NO_ADULT__c =  3;
        objCareApp.NO_CHILD__c =  1;
        objCareApp.IS_SIGNED__c =  true;
        objCareApp.REQUEST_DROP__c =  true;
        objCareApp.NEED_NAME_CHANGE__c =  false;
        objCareApp.APPLICANT_NAME__c =  'TestAman';
        objCareApp.RECEIVED_DATE__c =  date.today()-7;
        objCareApp.PROCESSED_DATE__c =  date.today()-5;
        objCareApp.SOURCE_CHANNEL_TYPE__c =  'DataXport Enrollment';
        objCareApp.FORM_CODE__c =  '';
        objCareApp.COC_CODE__c =  '';
        objCareApp.APPLICATION_STATUS__c = 'Pending';        
        objCareApp.LIHEAP__c =  false;
        objCareApp.WIC__c =  false;
        objCareApp.CALFRESH_SNAP__c =  false;
        objCareApp.CALWORKS_TANF__c =  false;
        objCareApp.HEAD_START_INCOME__c =  false;
        objCareApp.SSI__c =  true;
        objCareApp.HEALTHY_FAMILIES__c =  false;
        objCareApp.NSLP__c =  false;
        objCareApp.BUREAU_INDIAN_AFFAIRS__c =  true;
        objCareApp.MEDICAID_UNDER65__c =  true;
        objCareApp.MEDICAID_OVER65__c =  false;
        objCareApp.EMAIL_ADDRESS__c =  'abc@gmail.com';
        objCareApp.ANNUAL_HOUSEHOLD_INCOME__c =  1234;
        objCareApp.FIXED_INCOME__c =  false;
        objCareApp.ENROLLMENT_TYPE__c = 'ENROLLMENT'; 
        objCareApp.CCB_CONTACT_COMMENT__c = 'Not Proper';
        objCareApp.DROP_SOURCE__c = 'CC&B Case';
        objCareApp.REASON_DESC__c = 'Testing';
        insert objCareApp;
        //List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        //insert lstCareTypes;
        //
        // Create Email Address to which email should be sent with Batch Processing Statistics or Error details
        List<CARE_SYSTEM_VALUE__c> careSysList = CARE_TestDataFactory.createEmailAddrForBatchJobs();
        if (careSysList != null && !careSysList.isEmpty()) {
            insert careSysList;
        }
    }
    
    @isTest
    static void testMethod1(){
        makeData();
        Test.startTest();
        Database.executeBatch(new Care_VerifyEnrollmentBatch());
        Test.stopTest();
        
    }    
    
    private static List<Account> createAccountRecords(){
        List<Account> listAccountRecords = new List<Account>();
        
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        objAccountRecord.AccountNumber = '1224590384';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.SAID__c = '7777777777';
        objAccountRecord.Phone = '9065231';
        objAccountRecord.Discount__c = 'C';
        objAccountRecord.Billing_Person_ID_EI__c = '0123456003';
        objAccountRecord.Service_Address__c = 'Search1234';
        objAccountRecord.SA_Type__c = 'E';
        objAccountRecord.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord.Type = 'Type';
        objAccountRecord.Rate__c = 'HAG1A';
        objAccountRecord.Branch_Code_EI__c = 'Get';
        objAccountRecord.Original_Tree_Level_EI__c = 2.0;
        listAccountRecords.add(objAccountRecord);  
        
        return listAccountRecords;
    }
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccountRecords){
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
        
        //Site record with status as '20', with valid Rate Schedule, and discount in 'Electric'
        EI_Site__c objSite1 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite1.Name='Site1';
        objSite1.Rate_Schedule_EI__c='STANDARD';
        objSite1.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite1.Site_Premise_ID_EI__c = 'Prem3';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(objSite1);
        
        //Site record with status as '30', with invalid Rate Schedule, and discount in 'Gas'
        EI_Site__c objSite2 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite2.Name='Site2';
        objSite2.Rate_Schedule_EI__c='EVA';
        objSite2.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite2.Site_Premise_ID_EI__c = 'Prem4';
        objSite2.Care_Start_Date_EI__c = date.today();
        objSite2.Care_Stop_Date_EI__c = date.today()+60;
        objSite2.Svc_Status_Code_EI__c = '30';
        objSite2.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite2);    
        
        //Site record with status as '10', and Care_Stop_Date_EI__c <todays date, so that it is not in any discount for 'Gas'
/*        EI_Site__c objSite3 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite3.Name='Site3';
        objSite3.Rate_Schedule_EI__c='STANDARD';
        objSite3.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite3.Site_Premise_ID_EI__c = 'Prem1';
        objSite3.Care_Start_Date_EI__c = date.today()-10;
        objSite3.Care_Stop_Date_EI__c = date.today()-5;
        objSite3.Svc_Status_Code_EI__c = '10';
        objSite3.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite3);    
        
        //Create record with Invalid status, invalid Rate schedule, Care Stop Date < todays date (for method getAddElecGasForCustomerNoValidDiscountDiscTest)
        EI_Site__c objSite4 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite4.Name='Site4';
        objSite4.Rate_Schedule_EI__c='EVA';
        objSite4.Billing_Account_ID_EI__c = '6767676767';
        objSite4.Imported_Site_Name_EI__c = 'PABLO,JORGE';
        objSite4.Person_ID_EI__c = '9000000001';
        objSite4.Site_Premise_ID_EI__c = 'Prem3';
        objSite4.Care_Start_Date_EI__c = date.today()-10;
        objSite4.Care_Stop_Date_EI__c = date.today()-5;
        objSite4.SAID_EI__c = '6456456456';
        objSite4.Svc_Status_Code_EI__c = '30';
        listSiteRecords.add(objSite4);
 */       
        return listSiteRecords;
    }
    private static List<EI_PREMISE__c> createPremiseRecords(){
        List<EI_PREMISE__c> listPremiseRecords = new List<EI_PREMISE__c>();
        
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise('Prem3', '3333333333');
        listPremiseRecords.add(prmemiseRecord1);
        
        //EI_PREMISE__c prmemiseRecord2 = CARE_TestDataFactory.createPremise('Prem4', '4444444444');
        //listPremiseRecords.add(prmemiseRecord2);
        
        return listPremiseRecords;    
    }
}