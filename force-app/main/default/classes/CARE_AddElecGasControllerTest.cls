/***********************************************************************************************************   
Apex Util class Name :  CARE_AddElecGasControllerTest
Version              :  1.0                                                                          
Created Date         :  06/15/2020                                                         
Function             :  This is the test class supporting the class CARE_AddElecGasController for CARE Search application.
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
public class CARE_AddElecGasControllerTest {
    
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    //This is the testsetup for preparing the data
    @testSetup
    static void loadTestData(){
        Profile p = [select id from Profile where name =: CARE_Constants.CARE_PROCESSOR_PROFILE LIMIT 1];
        
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
        insert listAccountRecords;
        
        //Create Site records  
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords);
        insert listSiteRecords;
        
        //Create records in Care Type for stamping as CC code
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;    
    }
    
    /**********************Test Methods************************************************************************/
    //This test method supports the method to check the records returned when 'Add Elec / Gas' button is clicked, NO VALID DISCOUNT
    @isTest
    static void getAddElecGasForCustomerNoValidDiscountDiscTest(){
        test.startTest();
        
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Imported_Site_Name_EI__c = 'PABLO,JORGE'];
        
        System.runAs(user1[0]){
            CARE_AddElecGasController.AddElecGasWrapperResponse wrapperObj = new CARE_AddElecGasController.AddElecGasWrapperResponse();
            wrapperObj = CARE_AddElecGasController.getSAListForPerId(eiObj[0].Person_Id_EI__C);
            
            System.assertEquals(false, wrapperObj.bSuccess);  
            System.assertEquals(false, wrapperObj.bValidCustomer);			
            
        }
        test.stopTest();
    }
    
    //This test method supports the method to check the records returned when 'Add Elec / Gas' button is clicked, NOT A CARE CUSTOMER
    @isTest
    static void getAddElecGasForCustomerNotCAREDiscTest(){
        test.startTest();
        
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Imported_Site_Name_EI__c = 'COWLEY,ALEX'];
        
        System.runAs(user1[0]){
            CARE_AddElecGasController.AddElecGasWrapperResponse wrapperObj = new CARE_AddElecGasController.AddElecGasWrapperResponse();
            wrapperObj = CARE_AddElecGasController.getSAListForPerId(eiObj[0].Person_Id_EI__C);
            
            System.assertEquals(false, wrapperObj.bSuccess);  
            System.assertEquals(false, wrapperObj.bValidCustomer);			
            
        }
        test.stopTest();
    }
    
    //This test method supports the method to check the records returned when 'Add Elec / Gas' button is clicked, WITH RECORDS
    @isTest
    static void getSAListForPerIdTest(){
        CARE_AddElecGasController.AddElecGasWrapperResponse wrapperObj = new CARE_AddElecGasController.AddElecGasWrapperResponse();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Imported_Site_Name_EI__c = 'MEDRANO,JOSE'];
        system.debug('testperson-->'+eiObj[0].Person_Id_EI__C);
        System.runAs(user1[0]){            
            wrapperObj = CARE_AddElecGasController.getSAListForPerId(eiObj[0].Person_Id_EI__C);
            system.debug('testperson1-->'+wrapperObj);
            System.assert(wrapperObj.listAddElecGasExisting.size() == 1);  
            System.assert(wrapperObj.listAddElecGasNew.size() == 1);
            System.assert(wrapperObj.listAddElecGasReason.size() == 2);
        }
        test.stopTest();
    } 
    
    //This test method supports the method and checks if record is created in Care_Application__c object when Send App button is clicked
    @isTest
    static void createTransactionForSendAppTest(){
        Boolean bReturn = false;
        List<CARE_AddElecGasController.AddElecGasWrapper> lstWrapper = new List<CARE_AddElecGasController.AddElecGasWrapper>();
        
        //Create input param 2
        CARE_AddElecGasController.AddElecGasInputWrapper wrapperInputObj = new CARE_AddElecGasController.AddElecGasInputWrapper();
        wrapperInputObj.sPerId = '0123456003';
        wrapperInputObj.sComment = 'THIS IS A TEST COMMENT';
        wrapperInputObj.sReason = 'Customer Satisfaction';
        wrapperInputObj.dHighestDtOfExistingComm = date.today()+30;
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        //Create input param 1
        List<EI_Site__c> listEIObj = [SELECT Id, Person_Id_EI__C, Site_Premise_ID_EI__c, SAID_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,
                                      Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, Account_EI__r.Id, Billing_Account_ID_EI__c
                                      FROM EI_Site__c WHERE Name = 'Site3'];
        for(EI_Site__c eiObj : listEIObj){
            CARE_AddElecGasController.AddElecGasWrapper wrapper =  new CARE_AddElecGasController.AddElecGasWrapper();
            wrapper.idSARecID = eiObj.Id;
            wrapper.sApplicantName = eiObj.Imported_Site_Name_EI__c;
            wrapper.sPremiseId = eiObj.Site_Premise_ID_EI__c;
            wrapper.sSAId = eiObj.SAID_EI__c;
            wrapper.sBillingAccountId = eiObj.Billing_Account_ID_EI__c;
            wrapper.sDiscountType = eiObj.Account_EI__r.CARE_DISCOUNT_TYPE__c;
            wrapper.dStartDate = eiObj.Care_Start_Date_EI__c;
            wrapper.dEndDate = eiObj.Care_Stop_Date_EI__c;
            wrapper.sAccountId = eiObj.Account_EI__r.Id;
            wrapper.sRateSchedule = eiObj.Rate_Schedule_EI__c;
            
            lstWrapper.add(wrapper);
        }
        
        System.runAs(user1[0]){
            bReturn = CARE_AddElecGasController.createElecGasSA(lstWrapper, wrapperInputObj);
            
            //Check from Care Application object
            List<Care_Application__c> lstCareApp = [SELECT Id, CARE_Account_ID__c, PROCESSED_DATE__c, CCB_CONTACT_CODE__c, CCB_CONTACT_DESC__c FROM Care_Application__c WHERE PER_ID__c =: listEIObj[0].Person_Id_EI__C];
            System.assert(lstCareApp.size() == 1); 
            System.assert(lstCareApp[0].CARE_Account_ID__c == listEIObj[0].Account_EI__r.Id);  
            System.assert(lstCareApp[0].PROCESSED_DATE__c == Date.today());  
            
            //Check from Care App Enrolled SA object
            List<CARE_App_Enrolled_SA__c> lstCareAppEnroll = [SELECT Id, SA_ID__c, APPLICATION__r.CC_CL_CD__c, CC_CL_CD__c, START_DATE__c, END_DATE__c, Service_Agreement__r.Id, Service_Agreement__r.Svc_Type_Code_EI__c, 
                                                              APPLICATION__r.Id, APPLICATION__c, ACCT_ID__c, PREM_ID__c, PER_ID__c, RETRO_START_DATE__c, RETRO_END_DATE__c, 
                                                              APPLICATION__r.CARE_Account_ID__c, CCB_CONTACT_TYPE__c 
                                                              FROM CARE_App_Enrolled_SA__C 
                                                              WHERE APPLICATION__c =:lstCareApp[0].Id];
            
            System.assert(lstCareAppEnroll.size() == 1);   
            System.assertEquals('CARE', lstCareAppEnroll[0].CC_CL_CD__c);  
            System.assertEquals('6033', lstCareAppEnroll[0].CCB_CONTACT_TYPE__c);  
            System.assertEquals(wrapperInputObj.dHighestDtOfExistingComm, lstCareAppEnroll[0].END_DATE__c);
            
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
        
        Account objAccountRecord1 = PM_EI_TestDataUtility.createAccount();
        objAccountRecord1.AccountNumber = '1224590385';
        objAccountRecord1.CARE_DISCOUNT_TYPE__c = 'FERA';
        objAccountRecord1.Encrypted_Account_Name__c = 'Test Dummy Acct FERA';
        objAccountRecord1.SAID__c = '8888888888';
        objAccountRecord1.Phone = '9065231';
        objAccountRecord1.Discount__c = 'F';
        objAccountRecord1.Billing_Person_ID_EI__c = '0123456004';
        objAccountRecord1.Service_Address__c = 'Search1234';
        objAccountRecord1.SA_Type__c = 'E';
        objAccountRecord1.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord1.Type = 'Type';
        objAccountRecord1.Rate__c = 'HAG1A';
        objAccountRecord1.Branch_Code_EI__c = 'Get';
        objAccountRecord1.Original_Tree_Level_EI__c = 2.0;
        listAccountRecords.add(objAccountRecord1);  
        
        return listAccountRecords;
    }
    
    //Create Site Record
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccountRecords){
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
        listSiteRecords.add(objSite1);
        
        //Site record with status as '30', with invalid Rate Schedule, and discount in 'Gas'
        EI_Site__c objSite2 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite2.Name='Site2';
        objSite2.Rate_Schedule_EI__c='EVA';
        objSite2.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite2.Site_Premise_ID_EI__c = 'Prem2';
        objSite2.Care_Start_Date_EI__c = date.today();
        objSite2.Care_Stop_Date_EI__c = date.today()+60;
        objSite2.Svc_Status_Code_EI__c = '30';
        objSite2.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite2);    
        
        //Site record with status as '10', and Care_Stop_Date_EI__c <todays date, so that it is not in any discount for 'Gas'
        EI_Site__c objSite3 = CARE_TestDataFactory.createSite(listAccountRecords);
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
        
        //Create record with Valid status, Valid Rate schedule, but not a CARE customer (for method getAddElecGasForCustomerNotCAREDiscTest)
        EI_Site__c objSite5 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite5.Name='Site5';
        objSite5.Account_EI__c = listAccountRecords[1].Id;
        objSite5.Rate_Schedule_EI__c='STANDARD';
        objSite5.Billing_Account_ID_EI__c = '7878787878';
        objSite5.Imported_Site_Name_EI__c = 'COWLEY,ALEX';
        objSite5.Person_ID_EI__c = '9000000002';
        objSite5.Site_Premise_ID_EI__c = 'Prem3';
        objSite5.Care_Start_Date_EI__c = date.today()-10;
        objSite5.Care_Stop_Date_EI__c = date.today()+5;
        objSite5.SAID_EI__c = '6456456456';
        objSite5.Svc_Status_Code_EI__c = '10';
        listSiteRecords.add(objSite5);
        
        return listSiteRecords;
    }
    
    //create Care Type records for Reason list & CC Code.      
    private static List<CARE_Type__c> createCareTypeRecords(){
        List<CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        CARE_Type__c careType1 = CARE_TestDataFactory.careType();        
        careType1.TYPE_NO__c = '6033';
        careType1.TYPE_CODE__c = '7';
        careType1.TYPE_DESC__c = 'Commodity Addition';
        careType1.TYPE_DESC_LONG__c = 'DISCOUNT APPLIED TO ADDITIONAL COMMODITY (GAS AND OR ELECTRIC)';
        careType1.CATEGORY__c  = 'CARE Enrollment Contact Codes';
        lstCareTypes.add(careType1);
        
        //Create records in Care Type for displaying in Reason dropdown
        CARE_Type__c careType2 = CARE_TestDataFactory.careType();
        careType2.TYPE_NO__c = '11';
        careType2.TYPE_DESC__c = 'Covid-19';
        careType2.CATEGORY__c  = 'Add Electric Gas Reason';
        lstCareTypes.add(careType2);
        
        CARE_Type__c careType3 = CARE_TestDataFactory.careType();
        careType3.TYPE_NO__c = '12';
        careType3.TYPE_DESC__c = 'Customer Satisfaction';
        careType3.CATEGORY__c  = 'Add Electric Gas Reason';
        lstCareTypes.add(careType3);
        
        //Create records in Care Type for Valid Status and Valid Rate Schedule
        CARE_Type__c careType4 = CARE_TestDataFactory.careType();
        careType4.TYPE_NO__c = '13';
        careType4.TYPE_CODE__c = 'CARE';
        careType4.TYPE_DESC__c = '10,20';
        careType4.CATEGORY__c  = 'Valid SA status';
        lstCareTypes.add(careType4);
        
        CARE_Type__c careType5 = CARE_TestDataFactory.careType();
        careType5.TYPE_NO__c = '14';
        careType5.TYPE_CODE__c = 'CARE';
        careType5.TYPE_DESC__c = 'STANDARD,E-RES,G-RES,HE-RES,HG-RES,PT-E-RES,HN-E-RES';
        careType5.CATEGORY__c  = 'Valid Rate Schedule';
        lstCareTypes.add(careType5);
        
        return lstCareTypes;
    }    
    /**********************Private Test Method for Data Setup***********************************************/
}