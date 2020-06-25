/***********************************************************************************************************   
Apex Util class Name :  CARE_HistoryTabControllerTest
Version              :  1.0                                                                          
Created Date         :  05/14/2020                                                         
Function             :  This is the Test class for Apex Controller of Care Search Controller.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/27/2020             AATG                                              Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

@istest

public class CARE_SearchControllerTest {
    
    @testSetup
    public static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User lstusr = PM_EI_TestDataUtility.createUser(); //called testdatafactory for creation of user
        System.debug('lstusr is'+lstusr);
        lstusr.ProfileId = p.Id;
        insert lstusr;   // inserted user
        /*Account lst = PM_EI_TestDataUtility.createAccount(); //called testdatafactory for creation of account
                lst.Premise_ID__c = 'A1234BC';
                lst.AccountNumber = '12245903841';
        		lst.CARE_DISCOUNT_TYPE__c = 'CARE';
        		lst.Encrypted_Account_Name__c = 'Test Dummy Acct';
                lst.SAID__c = '000000000E';
        		lst.Phone = '9065231';
                //obj.F_Person_ID_EI__c = 'A786HI';
                lst.Discount__c = 'F';
        		lst.Billing_Person_ID_EI__c = '0123456003';
                lst.Service_Address__c = 'Search1234';
                lst.SA_Type__c = 'G';
                lst.Encrypted_Account_Name__c = 'Encrypted';
                lst.Type = 'Type';
                lst.Rate__c = 'HAG1A';
                lst.Branch_Code_EI__c = 'Get';
                lst.Original_Tree_Level_EI__c = 2.0;
                
        insert lst;	//inserted account
           EI_NAICS_Code__c oNAICSCode = PM_EI_TestDataUtility.createNAICSCode();
        insert oNAICSCode;
        EI_Site__c lstSite = PM_EI_TestDataUtility.createSite(lst,oNAICSCode);//called testdatafactory for creation of Site
        lstSite.Billing_Account_ID_EI__c = lst.Id;
        lstSite.Imported_Site_Name_EI__c = lst.Name;
        lstSite.Person_ID_EI__c = lst.Billing_Person_ID_EI__c;
        lstSite.Site_Premise_ID_EI__c = lst.Premise_ID__c;
        lstSite.Rate_Schedule_EI__c = 'STANDARDDD';
        lstSite.Care_Stop_Date_EI__c = date.today()+1;
        lstSite.Res_Ind_EI__c = 'N';
        lstSite.SAID_EI__c = lst.SAID__c;
        lstSite.Phone_1_EI__c = lst.Phone;
      	lstSite.Svc_Full_Adr_EI__c = 'WASHINGTON ST CA 23432';
        lstSite.Svc_Status_Code_EI__c = '20';
        lstSite.Svc_Type_Code_EI__c = 'E';
        lstSite.Site_Premise_ID_EI__c = '1234567890';
        insert lstSite; //inserted site*/
        List<Account> listAccountRecords = createAccountRecords();
        insert listAccountRecords;
        List<EI_PREMISE__c> listPremiseRecords = createPremiseRecords();
        insert listPremiseRecords;
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords);
        insert listSiteRecords;
        Case objCase = CARE_TestDataFactory.objCase();
        insert objCase;
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        objCareApp.ENROLLMENT_TYPE__c = 'OTHER';
        objCareApp.IS_RECERT__c =  true;
            objCareApp.NO_ADULT__c =  3;
            objCareApp.NO_CHILD__c =  1;
            objCareApp.IS_SIGNED__c =  true;
            objCareApp.REQUEST_DROP__c =  true;
            objCareApp.NEED_NAME_CHANGE__c =  false;
            objCareApp.APPLICANT_NAME__c =  'TestAman';
            objCareApp.RECEIVED_DATE__c =  date.today()-7;
            objCareApp.PROCESSED_DATE__c =  date.today()-5;
            objCareApp.SOURCE_CHANNEL_TYPE__c =  'Bill Insert';
            objCareApp.FORM_CODE__c =  '';
            objCareApp.COC_CODE__c =  '';
            objCareApp.APPLICATION_STATUS__c = 'In-Progress';        
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
        CARE_App_Enrolled_SA__c objCareAppEnrol = CARE_TestDataFactory.careAppEnrolledSa(objCareApp,listSiteRecords[0]);
        insert objCareAppEnrol;
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;
        /*Image objImage = CARE_TestDataFactory.objImage();
        insert objImage;*/
        CARE_APP_Image_List__c objImgList = CARE_TestDataFactory.careImage(objCareApp, objCase);
        insert objImgList;
    }
    @isTest
    static void testSearch(){
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
        List<EI_Site__c> acc = [SELECT  Id, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Res_Ind_EI__c,SAID_EI__c,Svc_Full_Adr_EI__c From EI_Site__c];    // queried account
        System.debug('acc is '+acc);
        String searchAcc = 'STANDARDDD';
        String searchObjApi = 'EI_Site__c';
        String searchFieldApi = 'Rate_Schedule_EI__c';
        Test.startTest(); // test class also have governor limits. We use Test.statTest and StopTest to eliminate them and write the required method call inside it
        //System.runAs(usr[0]){ // usually we use runAs because sometimes it is necessary to run as a particular user to satisfy conditions
        CARE_SearchController.getListOfStrings(searchAcc,searchObjApi,searchFieldApi);   // main class is called
        //}
        Test.stopTest();
        
    } 
    @isTest
    static void getcustomerlisttest() {
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and LastName = 'Testing']; //queried user 
        List<Account> acc = [select Name, AccountNumber, Type, Branch_Code_EI__c, CARE_DISCOUNT_TYPE__c, Encrypted_Account_Name__c, Discount__c, Billing_Person_ID_EI__c, Premise_ID__c, Rate__c, SA_Type__c, SAID__c, Service_Address__c from Account];    // queried account
        System.debug('acc is '+acc);
        List<EI_NAICS_Code__c> eincList = [select Id,Name, NAICS_Dsc_EI__c From EI_NAICS_Code__c];
        set<Id> ids = new Set<Id>();
        for(integer i=0;i<acc.size();i++)
        {
            ids.add(acc[i].Id);
        }
        List<EI_Site__c> sitelst = [SELECT Zip_Code_EI__c,City_EI__c,Svc_Full_Adr_EI__c,Phone_1_EI__c,RecordTypeId,Name,Account_EI__c,Billing_Account_ID_EI__c,Imported_Site_Name_EI__c,Legislative_Discount_EI__c,Person_ID_EI__c,Rate_Schedule_EI__c, Res_Ind_EI__c,SAID_EI__c,Svc_Status_Code_EI__c,Svc_Type_Code_EI__c,Site_Premise_ID_EI__c,NAICS_Code_relation_EI__c FROM EI_Site__c];
        sitelst[0].Billing_Account_ID_EI__c = acc[0].Id;
        sitelst[0].Phone_1_EI__c =  '9065231';
        sitelst[0].Svc_Full_Adr_EI__c = 'Lane';
        sitelst[0].City_EI__c = 'NY';
        sitelst[0].Zip_Code_EI__c = '121782';
        update sitelst[0];
        System.debug('sitelst length  '+sitelst.size());
        System.debug('sitelst---> '+sitelst);
        Test.startTest();
        try{
        CARE_SearchController.SearchWrapperResponse sWrapperResponse = new CARE_SearchController.SearchWrapperResponse();
        
        CARE_SearchController.SearchWrapperRequest sWrapperRequest = new CARE_SearchController.SearchWrapperRequest();
        sWrapperRequest.sAccountID = acc[0].Id;
        sWrapperRequest.sPersonID = acc[0].Billing_Person_ID_EI__c;
        sWrapperRequest.sPremiseID = sitelst[0].Site_Premise_ID_EI__c;
        //sWrapperRequest.sPremiseID ='';
        sWrapperRequest.bInactiveCustomer = false;
        sWrapperRequest.sSAID = acc[0].SAID__c;
        sWrapperRequest.sName = sitelst[0].Imported_Site_Name_EI__c;
        sWrapperRequest.sPhone = '9065231';
        sWrapperRequest.sStreet = 'Lane';
        sWrapperRequest.sCity = 'NY';
        sWrapperRequest.sZip = '121782';
        sWrapperRequest.sSpace = 'Test';
        sWrapperRequest.bMFHC = false;
        sWrapperRequest.sFacilityHousing = 'Yes';
        sWrapperRequest.bEnrolledTenant = false;
        sWrapperRequest.bProbation = false;
        
        CARE_SearchController.CustomerWrapper cWrapper = new CARE_SearchController.CustomerWrapper();
        cWrapper.idcustId = sitelst[0].id;
       // cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sResNonRes = sitelst[0].Res_Ind_EI__c;
        cWrapper.sFHType = 'TestFHType';
        cWrapper.sAccId = acc[0].Id;
        cWrapper.sSAId = acc[0].SAID__c;
        cWrapper.sSAType = sitelst[0].Svc_Type_Code_EI__c;
        cWrapper.sSAStatus = sitelst[0].Svc_Status_Code_EI__c;
        cWrapper.sDiscount = acc[0].CARE_DISCOUNT_TYPE__c;
        cWrapper.sRate = sitelst[0].Rate_Schedule_EI__c;
        cWrapper.sSvcAddr = sWrapperRequest.sStreet;
        cWrapper.sFacility = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sSpaceUnit = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sPerId = sWrapperRequest.sPersonID;
        cWrapper.sPremId = sitelst[0].Site_Premise_ID_EI__c;
        CARE_SearchController.getCustomerList(sWrapperRequest);
            System.debug('sWrapperRequest---> '+sWrapperRequest);
        }
        catch(exception e){
            System.debug('exception is ---> '+e);
        }
        Test.stopTest();
    }
    
   @isTest
    static void getcustomerlistonlyacctest() {
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and LastName = 'Testing']; //queried user 
        List<Account> acc = [select Name, AccountNumber, Type, Branch_Code_EI__c, CARE_DISCOUNT_TYPE__c, Encrypted_Account_Name__c, Discount__c, Billing_Person_ID_EI__c, Premise_ID__c, Rate__c, SA_Type__c, SAID__c, Service_Address__c from Account];    // queried account
        System.debug('acc is '+acc);
        set<Id> ids = new Set<Id>();
        for(integer i=0;i<acc.size();i++)
        {
            ids.add(acc[i].Id);
        }
        List<EI_Site__c> sitelst = [SELECT Zip_Code_EI__c,City_EI__c,Svc_Full_Adr_EI__c,Phone_1_EI__c,RecordTypeId,Name,Account_EI__c,Billing_Account_ID_EI__c,Imported_Site_Name_EI__c,Legislative_Discount_EI__c,Person_ID_EI__c,Rate_Schedule_EI__c, Res_Ind_EI__c,SAID_EI__c,Svc_Status_Code_EI__c,Svc_Type_Code_EI__c,Site_Premise_ID_EI__c,NAICS_Code_relation_EI__c FROM EI_Site__c];
        sitelst[0].Billing_Account_ID_EI__c = acc[0].Id; 
        sitelst[0].Phone_1_EI__c =  '9065231';
        sitelst[0].Svc_Full_Adr_EI__c = 'Lane';
        sitelst[0].City_EI__c = 'NY';
        sitelst[0].Zip_Code_EI__c = '121782';
        update sitelst[0];
        System.debug('sitelst---> '+sitelst);
        Test.startTest();
        try{
        CARE_SearchController.SearchWrapperResponse sWrapperResponse = new CARE_SearchController.SearchWrapperResponse();
        
        CARE_SearchController.SearchWrapperRequest sWrapperRequest = new CARE_SearchController.SearchWrapperRequest();
        sWrapperRequest.sAccountID = acc[0].Id;
        sWrapperRequest.sPersonID = '';
        sWrapperRequest.sPremiseID = '';
        sWrapperRequest.bInactiveCustomer = false;
        sWrapperRequest.sSAID = '';
        sWrapperRequest.sName = '';
        sWrapperRequest.sPhone = '';
        sWrapperRequest.sStreet = '';
        sWrapperRequest.sSpace = 'Test';
        sWrapperRequest.sCity = '';
        sWrapperRequest.sZip = '';
        sWrapperRequest.bMFHC = false;
        sWrapperRequest.sFacilityHousing = 'Yes';
        sWrapperRequest.bEnrolledTenant = false;
        sWrapperRequest.bProbation = false;
        
        CARE_SearchController.CustomerWrapper cWrapper = new CARE_SearchController.CustomerWrapper();
        cWrapper.idcustId = sitelst[0].id;
       // cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sResNonRes = sitelst[0].Res_Ind_EI__c;
        cWrapper.sFHType = 'TestFHType';
        cWrapper.sAccId = acc[0].Id;
        cWrapper.sSAId = acc[0].SAID__c;
        cWrapper.sSAType = sitelst[0].Svc_Type_Code_EI__c;
        cWrapper.sSAStatus = sitelst[0].Svc_Status_Code_EI__c;
        cWrapper.sDiscount = acc[0].CARE_DISCOUNT_TYPE__c;
        cWrapper.sRate = sitelst[0].Rate_Schedule_EI__c;
        cWrapper.sSvcAddr = sWrapperRequest.sStreet;
        cWrapper.sFacility = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sSpaceUnit = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sPerId = sWrapperRequest.sPersonID;
        cWrapper.sPremId = sitelst[0].Site_Premise_ID_EI__c;
        CARE_SearchController.getCustomerList(sWrapperRequest);
        }
        catch(exception e){
            System.debug('exception is ---> '+e);
        }
    Test.stopTest();
    }
    
    @isTest
    static void getcustomerselectalltest() {
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and LastName = 'Testing']; //queried user 
        List<Account> acc = [select Name, AccountNumber, Type, Branch_Code_EI__c, CARE_DISCOUNT_TYPE__c, Encrypted_Account_Name__c, Discount__c, Billing_Person_ID_EI__c, Premise_ID__c, Rate__c, SA_Type__c, SAID__c, Service_Address__c from Account];    // queried account
        System.debug('acc is '+acc);
        set<Id> ids = new Set<Id>();
        for(integer i=0;i<acc.size();i++)
        {
            ids.add(acc[i].Id);
        }
        List<EI_Site__c> sitelst = [SELECT Zip_Code_EI__c,City_EI__c,Svc_Full_Adr_EI__c,Phone_1_EI__c,RecordTypeId,Name,Account_EI__c,Billing_Account_ID_EI__c,Imported_Site_Name_EI__c,Legislative_Discount_EI__c,Person_ID_EI__c,Rate_Schedule_EI__c, Res_Ind_EI__c,SAID_EI__c,Svc_Status_Code_EI__c,Svc_Type_Code_EI__c,Site_Premise_ID_EI__c,NAICS_Code_relation_EI__c FROM EI_Site__c ];
       sitelst[0].Billing_Account_ID_EI__c = acc[0].Id;
        sitelst[0].Phone_1_EI__c =  '9065231';
        sitelst[0].Svc_Full_Adr_EI__c = 'Lane';
        sitelst[0].City_EI__c = 'NY';
        sitelst[0].Zip_Code_EI__c = '121782';
        update sitelst[0];
        System.debug('sitelst---> '+sitelst);
        Test.startTest();
        try{
        CARE_SearchController.SearchWrapperResponse sWrapperResponse = new CARE_SearchController.SearchWrapperResponse();
        
        CARE_SearchController.SearchWrapperRequest sWrapperRequest = new CARE_SearchController.SearchWrapperRequest();
        sWrapperRequest.sAccountID = acc[0].Id;
        sWrapperRequest.sPersonID = acc[0].Billing_Person_ID_EI__c;
        sWrapperRequest.sPremiseID = sitelst[0].Site_Premise_ID_EI__c;
        sWrapperRequest.bInactiveCustomer = false;
        sWrapperRequest.sSAID = acc[0].SAID__c;
        sWrapperRequest.sName = sitelst[0].Imported_Site_Name_EI__c;
        sWrapperRequest.sPhone = '';
        sWrapperRequest.sStreet = '';
        sWrapperRequest.sSpace = 'Test';
        sWrapperRequest.sCity = '';
        sWrapperRequest.sZip = '';
        sWrapperRequest.bMFHC = false;
        sWrapperRequest.sFacilityHousing = 'Yes';
        sWrapperRequest.bEnrolledTenant = false;
        sWrapperRequest.bProbation = null;
        
        CARE_SearchController.CustomerWrapper cWrapper = new CARE_SearchController.CustomerWrapper();
        cWrapper.idcustId = sitelst[0].id;
       // cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sCustName = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sResNonRes = sitelst[0].Res_Ind_EI__c;
        cWrapper.sFHType = 'TestFHType';
        cWrapper.sAccId = acc[0].Id;
        cWrapper.sSAId = acc[0].SAID__c;
        cWrapper.sSAType = sitelst[0].Svc_Type_Code_EI__c;
        cWrapper.sSAStatus = sitelst[0].Svc_Status_Code_EI__c;
        cWrapper.sDiscount = acc[0].CARE_DISCOUNT_TYPE__c;
        cWrapper.sRate = sitelst[0].Rate_Schedule_EI__c;
        cWrapper.sSvcAddr = sWrapperRequest.sStreet;
        cWrapper.sFacility = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sSpaceUnit = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sPerId = sWrapperRequest.sPersonID;
        cWrapper.sPremId = sitelst[0].Site_Premise_ID_EI__c;
            System.debug('sWrapperRequest---> '+sWrapperRequest);
        CARE_SearchController.getCustomerList(sWrapperRequest);
        }
            catch(exception e){
            System.debug('exception is ---> '+e);
        }
    Test.stopTest();
    }
     @isTest
    static void getcustomerlistonlyacctest1() {
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and LastName = 'Testing']; //queried user 
        List<Account> acc = [select Name, AccountNumber, Type, Branch_Code_EI__c, CARE_DISCOUNT_TYPE__c, Encrypted_Account_Name__c, Discount__c, Billing_Person_ID_EI__c, Premise_ID__c, Rate__c, SA_Type__c, SAID__c, Service_Address__c from Account];    // queried account
        System.debug('acc is '+acc);
        set<Id> ids = new Set<Id>();
        for(integer i=0;i<acc.size();i++)
        {
            ids.add(acc[i].Id);
        }
        List<EI_Site__c> sitelst = [SELECT Zip_Code_EI__c,City_EI__c,Svc_Full_Adr_EI__c,Phone_1_EI__c,RecordTypeId,Name,Account_EI__c,Billing_Account_ID_EI__c,Imported_Site_Name_EI__c,Legislative_Discount_EI__c,Person_ID_EI__c,Rate_Schedule_EI__c, Res_Ind_EI__c,SAID_EI__c,Svc_Status_Code_EI__c,Svc_Type_Code_EI__c,Site_Premise_ID_EI__c,NAICS_Code_relation_EI__c FROM EI_Site__c WHERE Billing_Account_ID_EI__c In : ids];        System.debug('sitelst---> '+sitelst);
        EI_PREMISE__c pre = [select Id from EI_PREMISE__c Limit 1];
        Test.startTest();
        try{
            
            CARE_SearchController.PremiseSiteDetails preDetails = new CARE_SearchController.PremiseSiteDetails();
            preDetails.premise = pre;
            preDetails.siteContactName = 'Test';
            preDetails.SiteContactPhoneNumber = '1234567897';
            preDetails.SiteSAIds = pre.Id;
        CARE_SearchController.SearchWrapperResponse sWrapperResponse = new CARE_SearchController.SearchWrapperResponse();
        
        CARE_SearchController.SearchWrapperRequest sWrapperRequest = new CARE_SearchController.SearchWrapperRequest();
        sWrapperRequest.sAccountID = '';
        sWrapperRequest.sPersonID = '';
        sWrapperRequest.sPremiseID = '';
        sWrapperRequest.bInactiveCustomer = null;
        sWrapperRequest.sSAID = '';
        sWrapperRequest.sName = '';
        sWrapperRequest.sPhone = '';
        sWrapperRequest.sStreet = '';
        sWrapperRequest.sSpace = 'Test';
        sWrapperRequest.sCity = '';
        sWrapperRequest.sZip = '';
        sWrapperRequest.bMFHC = false;
        sWrapperRequest.sFacilityHousing = 'Yes';
        sWrapperRequest.bEnrolledTenant = false;
        sWrapperRequest.bProbation = false;
        
        CARE_SearchController.CustomerWrapper cWrapper = new CARE_SearchController.CustomerWrapper();
        cWrapper.idcustId = sitelst[0].id;
        cWrapper.sCustName = sitelst[0].Name;
        cWrapper.sResNonRes = sitelst[0].Res_Ind_EI__c;
        cWrapper.sFHType = 'TestFHType';
        cWrapper.sAccId = acc[0].Id;
        cWrapper.sSAId = sitelst[0].SAID_EI__c;
        cWrapper.sSAType = sitelst[0].Svc_Type_Code_EI__c;
        cWrapper.sSAStatus = sitelst[0].Svc_Status_Code_EI__c;
        cWrapper.sDiscount = acc[0].CARE_DISCOUNT_TYPE__c;
        cWrapper.sRate = sitelst[0].Rate_Schedule_EI__c;
        cWrapper.sSvcAddr = sitelst[0].Svc_Full_Adr_EI__c;
        cWrapper.sFacility = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sSpaceUnit = sitelst[0].Imported_Site_Name_EI__c;
        cWrapper.sPerId = '';
        cWrapper.sPremId = sitelst[0].Site_Premise_ID_EI__c;
        CARE_SearchController.getCustomerList(sWrapperRequest);
            
            
        }
            catch(exception e){
            System.debug('exception is ---> '+e);
        }
    Test.stopTest();
    }
    private static List<CARE_Type__c> createCareTypeRecords(){
        List<CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        CARE_Type__c careType1 = CARE_TestDataFactory.careType();        
        careType1.TYPE_NO__c = '6034';
        careType1.TYPE_CODE__c = '7';
        careType1.TYPE_DESC__c = 'Straight Adjustment';
        careType1.TYPE_DESC_LONG__c = 'DISCOUNT APPLIED TO ADDITIONAL COMMODITY (GAS AND OR ELECTRIC)';
        careType1.CATEGORY__c  = 'CARE Enrollment Contact Codes';
        lstCareTypes.add(careType1);
        
        //Create records in Care Type for displaying in Reason dropdown
        CARE_Type__c careType2 = CARE_TestDataFactory.careType();
        careType2.TYPE_NO__c = '11';
        careType2.TYPE_DESC__c = 'Covid-19';
        careType2.CATEGORY__c  = 'Adjustment Reason';
        lstCareTypes.add(careType2);
        
        CARE_Type__c careType3 = CARE_TestDataFactory.careType();
        careType3.TYPE_NO__c = '12';
        careType3.TYPE_DESC__c = 'Customer Satisfaction';
        careType3.CATEGORY__c  = 'Adjustment Reason';
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
        
        return listSiteRecords;
    }
    private static List<EI_PREMISE__c> createPremiseRecords(){
        List<EI_PREMISE__c> listPremiseRecords = new List<EI_PREMISE__c>();
        
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise('Prem1', '1111111111');
        listPremiseRecords.add(prmemiseRecord1);
        
        EI_PREMISE__c prmemiseRecord2 = CARE_TestDataFactory.createPremise('Prem2', '2222222222');
        listPremiseRecords.add(prmemiseRecord2);
        
        return listPremiseRecords;    
    }
}