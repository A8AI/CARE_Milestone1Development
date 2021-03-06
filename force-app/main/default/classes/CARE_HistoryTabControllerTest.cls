/***********************************************************************************************************   
Apex Util class Name :  CARE_HistoryTabControllerTest
Version              :  1.0                                                                          
Created Date         :  05/14/2020                                                         
Function             :  This is the Test class for Apex Controller for history Tab of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/19/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/


@istest(SeeAllData=false)

public class CARE_HistoryTabControllerTest {
    EI_Site__c lstSite = new EI_Site__c();
    
    @testSetup
    public static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User lstusr = PM_EI_TestDataUtility.createUser(); //called testdatafactory for creation of user
        System.debug('lstusr is'+lstusr);
        lstusr.ProfileId = p.Id;
        insert lstusr;   // inserted user
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
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;
        /*Image objImage = CARE_TestDataFactory.objImage();
insert objImage;*/
        CARE_APP_Image_List__c objImgList = CARE_TestDataFactory.careImage(objCareApp, objCase);
        insert objImgList;
    }
    
    @isTest
    static void testgetEnrollHistoryData2(){
        date dToday = system.today();
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
        List<CARE_Application__c> acc = [SELECT Id, Name,PER_ID__c, APPLICATION_STATUS__c, CARE_Account_ID__c,CCB_CONTACT_CODE__c From CARE_Application__c ];    // queried CARE_APPLICATION
        List<CARE_Type__c> careType = [SELECT COMMENTS__c,TYPE_CODE__c,TYPE_NO__c FROM CARE_Type__c];
        System.debug('acc is '+acc);
        acc[0].CCB_CONTACT_CODE__c = careType[0].TYPE_CODE__c;
        update acc[0];
        Test.startTest();
        CARE_HistoryTabController.HistoryListWrapper saveResults = new CARE_HistoryTabController.HistoryListWrapper();
        //List<HistoryListWrapper> listHistoryRecords = new List<HistoryListWrapper>();
        saveResults.sApplicationName= 'TestApp';
        saveResults.sId= acc[0].Id;
        saveResults.sSAID= '1212121212';
        saveResults.sSAType= 'E';
        saveResults.sDiscountType= 'CARE';
        saveResults.dStartDate= dToday;
        saveResults.dEndDate= dToday;
        saveResults.dReceiveDate= dToday;
        saveResults.sContact= 'TestApp';
        saveResults.sDescription= 'Test Desc';
        saveResults.sCCBComment= 'Test Comment';
        saveResults.sAppSource= 'Regular App';
        saveResults.sCommittedBy= 'Test User';
        saveResults.sFormatText= 'Test App';
        saveResults.sViewButton= 'Test App';
        saveResults.bDeleteButton= False;
        saveResults.sApplicationStatus= 'New';
        saveResults.sTypeNo= '6011';
        //listHistoryRecords.add(saveResults);
        
        
        CARE_HistoryTabController.TotalHistoryWrapper totResults = new CARE_HistoryTabController.TotalHistoryWrapper();
        
        //totResults.listHistoryWrapper = acc;
        totResults.iTotalRecCount = 10;
        totResults.idLastRec = acc[0].Id;
        
        CARE_App_Enrolled_SA__c objCareAppEnroll = new CARE_App_Enrolled_SA__c();
        objCareAppEnroll.APPLICATION__c = acc[0].Id;
        objCareAppEnroll.SA_ID__c = '1212121212';
        objCareAppEnroll.PREM_ID__c = '2323232323';
        objCareAppEnroll.ACCT_ID__c = '123456789';
        objCareAppEnroll.CC_CL_CD__c = 'CARE';
        //objCareAppEnroll.Service_Agreement__c = eiSite.Id;
        objCareAppEnroll.PER_ID__c = '4545454545';
        objCareAppEnroll.END_DATE__c = dToday;
        objCareAppEnroll.SERVICE_FULL_ADDRESS__c = 'Test Add';
        objCareAppEnroll.CC_CL_CD__c = 'C';
        objCareAppEnroll.CCB_CONTACT_TYPE__c = '6042';
        objCareAppEnroll.RS_CD__c = '4213122121';
        insert objCareAppEnroll;
        
        
        CARE_HistoryTabController.getEnrollHistoryData(acc[0].PER_ID__c,'yes', '');
        //CARE_HistoryTabController.getEnrollHistoryData(acc[0].PER_ID__c,'yes', '');
        CARE_HistoryTabController.getSpecialMessage(acc[0].Name,careType[0].TYPE_NO__c);
        CARE_HistoryTabController.getSpecialMessage(acc[0].Name,null);
        Test.stopTest();
        
    }    
    
    @isTest
    static void testgetEnrollHistoryData(){
        date dToday = system.today();
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
        
        
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        insert objAccountRecord;
        
        CARE_Application__c objcareApp = new CARE_Application__c();
        objcareApp.CARE_Account_ID__c = objAccountRecord.Id;
        objcareApp.APPLICATION_STATUS__c = 'New';
        objcareApp.APPLICANT_NAME__c = 'Test Care';
        objcareApp.PER_ID__c = 'TestPerId';
        objcareApp.ENROLLMENT_TYPE__c = 'OTHER';
        insert objcareApp;
        
        EI_Site__c lstSite = [SELECT  Id, Person_ID_EI__c, Care_Stop_Date_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Account_EI__r.Discount__c,Site_Premise_ID_EI__c,Res_Ind_EI__c,SAID_EI__c,Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c From EI_Site__c Limit 1];    // queried lstSite	
        //CARE_App_Enrolled_SA__c objCareAppEnrol = CARE_TestDataFactory.careAppEnrolledSa(objCareApp[0],lstSite);
        //insert objCareAppEnrol;
        Test.startTest(); 
        CARE_HistoryTabController.getEnrollHistoryData(objCareApp.PER_ID__c,'No', objCareApp.Id);
        CARE_HistoryTabController.deleteEnrollmentRecord(objCareApp.Id);
        
        System.assertNotEquals(null, objCareApp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteHistoryPevHuData(){
        date dToday = system.today();
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
        
        Test.startTest();
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        insert objAccountRecord;
        
        CARE_Application__c objcareApp = new CARE_Application__c();
        objcareApp.CARE_Account_ID__c = objAccountRecord.Id;
        objcareApp.APPLICATION_STATUS__c = 'New';
        objcareApp.APPLICANT_NAME__c = 'Test Care';
        objcareApp.PER_ID__c = 'TestPerId';
        objcareApp.ENROLLMENT_TYPE__c = 'PEV';
        insert objcareApp;
        
        CARE_Household_Detail__c objCareHhDet = new CARE_Household_Detail__c();
        objCareHhDet.APPLICATION__c = objcareApp.Id;
        objCareHhDet.PERSON_NAME__c = 'Test Person';
        objCareHhDet.EST_ANNUAL_SALARY__c = 0;
        objCareHhDet.INCOME_SOURCE_STATUS__c = CARE_Constants.CARE_HH_DET_INC_STS_INVALID;
       	insert objCareHhDet;
         
        CARE_Household_Member_Income__c objCareHhInc = new CARE_Household_Member_Income__c();
        objCareHhInc.CARE_Application__c = objcareApp.Id;
        objCareHhInc.HOUSEHOLDDETAIL__c = objCareHhDet.Id;
        objCareHhInc.DISCOUNT_LENGTH_IN_DAYS__c = 1;
        objCareHhInc.NO_MONTHS__c = 0;
        objCareHhInc.PERIOD_TYPE__c = 'Annually';
        objCareHhInc.INCOME_SOURCE_STATUS__c = 'Valid';
        objCareHhInc.INCOME_SOURCE_TYPE__c = 'Contract Work';
        objCareHhInc.INCOME_DOC_TYPE__c = 'IRS 1040 2018';
        objCareHhInc.INCOME_FORM_TYPE__c = 'IRS 1040 2018';
        objCareHhInc.SCHEDULE_1__c = true;
        objCareHhInc.SCHEDULE_1_VALID__c = true;
        objCareHhInc.Document_Complete__c = true;
        objCareHhInc.LINE_1__c = 1;
        objCareHhInc.ADJ_1__c = 1;
        insert objCareHhInc;
        
        CARE_Household_Member_IncomeC__c objCareHhIncC = new CARE_Household_Member_IncomeC__c();
        objCareHhIncC.Application__c = objcareApp.Id;
        objCareHhIncC.DETAIL_INCOME__c = objCareHhInc.Id;
        objCareHhIncC.HOUSEHOLD_DETAIL__c = objCareHhDet.Id;
        objCareHhIncC.LINE3__c = 2;
        objCareHhIncC.LINE29__c = 2;
        objCareHhIncC.LINE31__c = 2;
        insert objCareHhIncC;
        
        CARE_HistoryTabController.deletePevHuRecord(objCareApp.Id);
        
        System.assertNotEquals(null, objCareApp.Id);
        Test.stopTest();
    }
    
    private static List<CARE_Type__c> createCareTypeRecords(){
        List<CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        CARE_Type__c careType1 = CARE_TestDataFactory.careType();        
        careType1.TYPE_NO__c = '6044';
        careType1.COMMENTS__c = 'Customer has submitted proof of income, however additional proof of income required.';
        careType1.TYPE_CODE__c = '7';
        careType1.TYPE_DESC__c = 'Straight Adjustment';
        careType1.TYPE_DESC_LONG__c = 'DISCOUNT APPLIED TO ADDITIONAL COMMODITY (GAS AND OR ELECTRIC)';
        careType1.CATEGORY__c  = 'CARE Enrollment Contact Codes';
        lstCareTypes.add(careType1);
        
        //Create records in Care Type for displaying in Reason dropdown
        CARE_Type__c careType2 = CARE_TestDataFactory.careType();
        careType2.TYPE_NO__c = '6042';
        careType1.COMMENTS__c = 'Customer has submitted proof of income, however additional proof of income required.';
        careType2.TYPE_DESC__c = 'Covid-19';
        careType2.CATEGORY__c  = 'Adjustment Reason';
        lstCareTypes.add(careType2);
        
        CARE_Type__c careType3 = CARE_TestDataFactory.careType();
        careType3.TYPE_NO__c = '6032';
        careType1.COMMENTS__c = 'Customer has submitted proof of income, however additional proof of income required.';
        careType3.TYPE_DESC__c = 'Customer Satisfaction';
        careType3.CATEGORY__c  = 'Adjustment Reason';
        lstCareTypes.add(careType3);
        
        //Create records in Care Type for Valid Status and Valid Rate Schedule
        CARE_Type__c careType4 = CARE_TestDataFactory.careType();
        careType4.TYPE_NO__c = '6033';
        careType1.COMMENTS__c = 'Customer has submitted proof of income, however additional proof of income required.';
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