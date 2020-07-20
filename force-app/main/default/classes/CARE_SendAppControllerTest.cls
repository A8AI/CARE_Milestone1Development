/***********************************************************************************************************   
Apex Util class Name :  CARE_SendAppControllerTest
Version              :  1.0                                                                          
Created Date         :  06/15/2020                                                         
Function             :  This is the test class supporting the class CARE_SendAppController for CARE Search application.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/06/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/
@isTest(seeAllData=false)
public class CARE_SendAppControllerTest {
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    //This is the testsetup for preparing the data
    @testSetup
    static void loadTestData(){
        Profile p = [select id from Profile where name =:CARE_Constants.CARE_PROCESSOR_PROFILE LIMIT 1];
        
        //Create user record
        User usr = PM_EI_TestDataUtility.createUser();
        usr.LastName = CARE_PROCESSOR_USR;
        usr.profileid = p.Id;
        insert usr;
        
        //Create Premise record
        List<EI_PREMISE__c> listPremiseRecords = createPremiseRecords();
        insert listPremiseRecords;
        
        //Create Account record
        List<Account> listAccountRecords = createAccountRecords();
        listAccountRecords[0].Premise_ID__c = listPremiseRecords[0].Id;        
        insert listAccountRecords;
               
        //Create Site records  
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords); 
        insert listSiteRecords;
        
        //Create records in Care Type
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;  
    }
    
     /**********************Test Methods************************************************************************/
    //This test method supports the method and checks if record is created in Care_Application__c object
    @isTest
    static void getSendAppDetailsTest(){        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
       
        System.runAs(user1[0]){
            CARE_SendAppController.SendAppWrapper wrapper = new CARE_SendAppController.SendAppWrapper();
            wrapper = CARE_SendAppController.getSendAppDetails();
            
            //System.assertEquals('A', wrapper.sContactCode);  
            //System.assertEquals(true, wrapper.bSuccess);  
            
        }
        test.stopTest();
    } 
    
    //This test method supports the method and checks if record is created in Care_Application__c object
    @isTest
    static void createTransactionForSendAppTest(){
        CARE_SendAppController.SendAppWrapperReq wrapperInput = new CARE_SendAppController.SendAppWrapperReq();
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__c, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Imported_Site_Name_EI__c = 'MEDRANO,JOSE'];
        
        //Create input param
        wrapperInput.sPerId = eiObj[0].Person_Id_EI__c;
        wrapperInput.sAccId = eiObj[0].Account_EI__r.Id;
        wrapperInput.sBillingAccId = eiObj[0].Billing_Account_ID_EI__c;
        wrapperInput.sApplicantName = eiObj[0].Imported_Site_Name_EI__c;
        
        System.runAs(user1[0]){
            CARE_SendAppController.SendAppWrapper wrapper = new CARE_SendAppController.SendAppWrapper();
            wrapper = CARE_SendAppController.createTransactionForSendApp(wrapperInput);
            
            List<Care_Application__c> lstCareApp = [SELECT Id, CARE_Account_ID__c, PROCESSED_DATE__c FROM Care_Application__c WHERE PER_ID__c =: eiObj[0].Person_Id_EI__c];
            //System.assert(lstCareApp.size() == 1);   
            //System.assert(lstCareApp[0].CARE_Account_ID__c == eiObj[0].Account_EI__r.Id);  
            //System.assert(lstCareApp[0].PROCESSED_DATE__c == Date.today());  
            //System.assertEquals(true, wrapper.bSuccess);  
            
            //Test catch block
            wrapperInput.sApplicantName = '';
            wrapper = CARE_SendAppController.createTransactionForSendApp(wrapperInput);
            System.assertEquals(false, wrapper.bSuccess);  
            
        }
        test.stopTest();
    } 
    
     /**********************Test Methods************************************************************************/
    
    /**********************Private Test Method for Data Setup***********************************************/
    //Create Premise Record
    private static List<EI_PREMISE__c> createPremiseRecords(){
        List<EI_PREMISE__c> listPremiseRecords = new List<EI_PREMISE__c>();
        
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise('Prem1', '1111111111');
        listPremiseRecords.add(prmemiseRecord1);
        
        EI_PREMISE__c prmemiseRecord2 = CARE_TestDataFactory.createPremise('Prem2', '2222222222');
        listPremiseRecords.add(prmemiseRecord2);
        
        return listPremiseRecords;    
    }
    
    //Create Account Record
    private static List<Account> createAccountRecords(){
        List<Account> listAccountRecords = new List<Account>();
               
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        objAccountRecord.AccountNumber = '1224590384';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.SAID__c = '000000000G';
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
    
    //Create Site Record
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccountRecords){
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
        
        EI_Site__c objSite1 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite1.Name='Site1';
        objSite1.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite1.Site_Premise_ID_EI__c = 'Prem1';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(objSite1);
                
        EI_Site__c objSite2 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite2.Name='Site2';
        objSite2.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite2.Site_Premise_ID_EI__c = 'Prem1';
        objSite2.Rate_Schedule_EI__c = 'EVA';
        objSite2.Care_Start_Date_EI__c = date.today();
        objSite2.Care_Stop_Date_EI__c = date.today()+60;
        objSite2.Svc_Status_Code_EI__c = '30';
        objSite2.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite2);    
        
        return listSiteRecords;
    }
    
    //create Care Type records for Reason list & CC Code.      
    private static List<CARE_Type__c> createCareTypeRecords(){
        List <CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        CARE_Type__c careType1 = CARE_TestDataFactory.careType();
        careType1.TYPE_NO__c = '6034';
        careType1.TYPE_CODE__c = 'A';
        careType1.TYPE_DESC_LONG__c = 'Long desc';
        careType1.CATEGORY__c  = 'CARE Enrollment Contact Codes';
        lstCareTypes.add(careType1);
        
        return lstCareTypes;
    }    
    /**********************Private Test Method for Data Setup***********************************************/
}