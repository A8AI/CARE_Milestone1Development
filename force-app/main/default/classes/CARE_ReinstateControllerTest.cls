/***********************************************************************************************************   
Apex Util class Name :  CARE_ReinstateControllerTest
Version              :  1.0                                                                          
Created Date         :  06/15/2020                                                         
Function             :  This is the Test class for Apex Controller of Care_Reinstate Controller.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/15/2020            NPK3                                                Initial Version.
*                                                                           CARE Application: 
****************************************************************************************************************************************/

@istest(SeeAllData=false)

public class CARE_ReinstateControllerTest {
    
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    @testsetup 
    static void setupData(){
        
        Profile p = [select id from Profile where name =: CARE_Constants.CARE_PROCESSOR_PROFILE LIMIT 1];
        
        //Create user record
        User usr = PM_EI_TestDataUtility.createUser();
        usr.LastName = CARE_PROCESSOR_USR;
        usr.profileid = p.Id;
        insert usr;

        List<EI_Premise__c> listPremise=createPremiseRecords();
        insert listPremise; 
        
        //Create Account record
        List<Account> listAccount = createAccountRecords();
        listAccount[0].Premise_ID__c = listPremise[0].Id;
        insert listAccount; 
        
         //Create Site record
        List<EI_Site__c> listSite = createSiteRecords(listAccount);
        listSite[0].Account_EI__c =  listAccount[0].Id; 
        listSite[0].EI_Premise__c = listPremise[0].Id;   
        insert listSite;
        
        //Create CARE APP record
        List <CARE_Application__c> listCareApp = createCareAppRecords(listAccount,listSite);
        insert listCareApp;
        
        //Create CARE APP Enrolled record
        List <CARE_App_Enrolled_SA__c> listCareAppEnrolledSA = createCareAppEnrolledSARecords(listCareApp,listSite);
        insert listCareAppEnrolledSA;
        
        //Create CARE Type
        List<CARE_Type__c>listCareType = createCareTypeRecords();
        insert listCareType;   
    }
    
    //**********************Test Methods************************************************************************
    static testmethod void getReinstateDetailsTest(){
        
        Test.startTest();
        String sPerId = '0123456003';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        //Check if the person is having an exisitng discount, if yes customer is not eligible for reinstate  
        EI_Site__c siteObj = [SELECT  Id, Person_ID_EI__c, Care_Stop_Date_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Res_Ind_EI__c,SAID_EI__c,
                              Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c 
                              From EI_Site__c 
                              where Person_ID_EI__c = :sPerId and Svc_Type_Code_EI__c = 'E'];
        
        CARE_App_Enrolled_SA__c careAppEnrolledSAObj = [SELECT  Id, CC_CL_CD__c 
                                                        FROM CARE_App_Enrolled_SA__c WHERE PER_ID__C =:sPerId];
        CARE_ReinstateController.WrapperReinstateResponse objWrapperResponse = new CARE_ReinstateController.WrapperReinstateResponse();
        System.runAs(user1[0]){       
        objWrapperResponse = CARE_ReinstateController.getReinstateDetails(sPerId);
        System.assertEquals(null, objWrapperResponse);
       }
        //End the Discount of the person in that premise so that person is eligible for Reinstate
        siteObj.Care_Stop_Date_EI__c = Date.today()-1;
        update siteObj;
        System.runAs(user1[0]){
        objWrapperResponse = CARE_ReinstateController.getReinstateDetails(sPerId);
        System.assertEquals('Income Proof Provided', objWrapperResponse.listReinstateReason[0].value);
        
        //Previous Enrollment is not having a valid rate/End date       
        careAppEnrolledSAObj.END_DATE__c = Date.today()-10;
        update careAppEnrolledSAObj;
        objWrapperResponse = CARE_ReinstateController.getReinstateDetails(sPerId);
        System.assertEquals(null, objWrapperResponse);
        }
        Test.stopTest();
    }
    
    static testmethod void reinstateSATest(){
        Test.startTest();
        List<CARE_ReinstateController.WrapperReinstate> listWrapperReinstateInput = new List<CARE_ReinstateController.WrapperReinstate>();
        CARE_ReinstateController.WrapperReinstate objReinstateWrapper = new CARE_ReinstateController.WrapperReinstate();
        CARE_ReinstateController.ReinstateInputWrapper objReinstateInputWrapper = new CARE_ReinstateController.ReinstateInputWrapper();
        String sPerId = '0123456003';
        CARE_App_Enrolled_SA__c careAppEnrolledObj =[SELECT SA_ID__c, START_DATE__c, END_DATE__c,Service_Agreement__r.Id,Service_Agreement__r.Svc_Type_Code_EI__c,
                                                     APPLICATION__c, ACCT_ID__c, PREM_ID__c,RETRO_START_DATE__c, RETRO_END_DATE__c,APPLICATION__r.Id, RS_CD__c, 
                                                     APPLICATION__r.CARE_Account_ID__c,  APPLICATION__r.CC_CL_CD__c, APPLICATION__r.PER_ID__c , 
                                                     Service_Agreement__r.SA_Start_Date_EI__c , Service_Agreement__r.Imported_Site_Name_EI__c                                                 
                                                     FROM CARE_App_Enrolled_SA__C 
                                                     WHERE APPLICATION__r.PER_ID__C = :sPerId]; 
        
        objReinstateWrapper.idSARecID = careAppEnrolledObj.Service_Agreement__r.Id;
        objReinstateWrapper.idAccountID = careAppEnrolledObj.APPLICATION__r.CARE_Account_ID__c;
        objReinstateWrapper.sBillingAccountId = careAppEnrolledObj.ACCT_ID__C;
        objReinstateWrapper.sPremiseId = careAppEnrolledObj.PREM_ID__c;
        objReinstateWrapper.sSAId = careAppEnrolledObj.SA_ID__c;
        objReinstateWrapper.sSAType = careAppEnrolledObj.Service_Agreement__r.Svc_Type_Code_EI__c; 
        objReinstateWrapper.sDiscountType = careAppEnrolledObj.APPLICATION__r.CC_CL_CD__c;
        objReinstateWrapper.dEndDate = careAppEnrolledObj.END_DATE__c;  
        objReinstateWrapper.sRateSchedule = careAppEnrolledObj.RS_CD__c; 
        objReinstateWrapper.dSAStartDate = careAppEnrolledObj.Service_Agreement__r.SA_Start_Date_EI__c;
        objReinstateWrapper.sApplicantName = careAppEnrolledObj.Service_Agreement__r.Imported_Site_Name_EI__c;
        listWrapperReinstateInput.add(objReinstateWrapper);   
        
        CARE_Type__c objCareTpeWithAdjustment = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c  FROM CARE_Type__c 
                                                 WHERE TYPE_NO__c =:CARE_Constants.CARE_CC_REINSTATE_ADJUSTMENT];
        objReinstateInputWrapper.sComment = objCareTpeWithAdjustment.TYPE_DESC__c;
        objReinstateInputWrapper.sPerId = careAppEnrolledObj.APPLICATION__r.PER_ID__C;
        objReinstateInputWrapper.sReason = 'Income Proof Provided';
        Boolean ifAdjustment = true;
        Boolean Result = CARE_ReinstateController.reinstateSA(sPerId, listWrapperReinstateInput, objReinstateInputWrapper, ifAdjustment);
        system.assertEquals(true, Result);
        
        CARE_Type__c objCareTpeWithOutAdjustment = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c  FROM CARE_Type__c 
                                                    WHERE TYPE_NO__c =:CARE_Constants.CARE_CC_REINSTATE_NO_ADJUSTMENT];
        objReinstateInputWrapper.sComment = objCareTpeWithOutAdjustment.TYPE_DESC__c;
        objReinstateInputWrapper.sPerId = careAppEnrolledObj.APPLICATION__r.PER_ID__C;
        objReinstateInputWrapper.sReason = 'Income Proof Provided';
        ifAdjustment = false;
        Result = CARE_ReinstateController.reinstateSA(sPerId, listWrapperReinstateInput, objReinstateInputWrapper, ifAdjustment);
        system.assertEquals(true, Result);
        
        Test.stopTest();
        
    } 
    
    
    
    //********************Private Test Method for Data Setup****************************
    //Create Account Record
    private static List<Account> createAccountRecords(){
        List<Account> listAccountRecords = new List<Account>();
        
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount(); //called testdatafactory for creation of account
        
        objAccountRecord.AccountNumber = '12245903841';
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
    
    //Create Premise Record
    private static List<EI_PREMISE__c> createPremiseRecords(){
        List<EI_PREMISE__c> listPremiseRecords = new List<EI_PREMISE__c>();
        
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise('Prem1', '0001234000');
        listPremiseRecords.add(prmemiseRecord1);

        EI_PREMISE__c prmemiseRecord2 = CARE_TestDataFactory.createPremise('Prem2', '0004567000');
        listPremiseRecords.add(prmemiseRecord2);
        
        return listPremiseRecords;    
    }
    //Create Site Record
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccount){
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
                
        EI_Site__c electricSARecord = CARE_TestDataFactory.createSite(listAccount);
        
       // EI_Site__c electricSARecord = PM_EI_TestDataUtility.createSite(listAccount[0],oNAICSCode);//called testdatafactory for creation of Site
        electricSARecord.Billing_Account_ID_EI__c = listAccount[0].Id;
        electricSARecord.Imported_Site_Name_EI__c = listAccount[0].Name;
        electricSARecord.Person_ID_EI__c = listAccount[0].Billing_Person_ID_EI__c;
        electricSARecord.Site_Premise_ID_EI__c = 'Prem1';
        electricSARecord.Rate_Schedule_EI__c = 'HE-RES';
        electricSARecord.Care_Start_Date_EI__c = date.today();
        electricSARecord.Care_Stop_Date_EI__c = date.today()+30;
        electricSARecord.SAID_EI__c = listAccount[0].SAID__c;
        electricSARecord.Svc_Status_Code_EI__c = '20';
        electricSARecord.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(electricSARecord);
        
        EI_Site__c gasSARecord = CARE_TestDataFactory.createSite(listAccount);//called testdatafactory for creation of Site
        gasSARecord.Billing_Account_ID_EI__c = listAccount[0].Id;
        gasSARecord.Imported_Site_Name_EI__c = listAccount[0].Name;
        gasSARecord.Person_ID_EI__c = listAccount[0].Billing_Person_ID_EI__c;
        gasSARecord.Site_Premise_ID_EI__c = 'Prem1';   //listAccount[0].Premise_ID__c;
        gasSARecord.Rate_Schedule_EI__c = 'EVA';
        gasSARecord.Care_Start_Date_EI__c = date.today();
        gasSARecord.Care_Stop_Date_EI__c = date.today()+60;
        gasSARecord.SAID_EI__c = listAccount[0].SAID__c;
        gasSARecord.Svc_Status_Code_EI__c = '30';
        gasSARecord.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(gasSARecord);    
        
        return listSiteRecords;
    }
    
    //create Care App Records
    private static List<CARE_Application__c> createCareAppRecords( List<Account>listAccountRecords , List<EI_Site__c> listSiteRecords){
        
        List <CARE_Application__c> listCareAppRecords = new List<CARE_Application__c>();
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        objCareApp.APPLICANT_NAME__c = listSiteRecords[0].Imported_Site_Name_EI__c;
        objCareApp.CC_CL_CD__c = 'CARE';
        objCareApp.ENROLLMENT_TYPE__c = 'OTHER';
        objCareApp.CCB_CONTACT_CODE__c = 'FC';
        objCareApp.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        listCareAppRecords.add(objCareApp);
        return listCareAppRecords;
    }
    
    //create Care App Enrolled SA Records
    private static List<CARE_App_Enrolled_SA__c> createCareAppEnrolledSARecords( List<CARE_Application__c>listCareAppRecords , List<EI_Site__c> listSiteRecords){
        List <CARE_App_Enrolled_SA__c> listCareAppEnrolledSARecords = new List<CARE_App_Enrolled_SA__c>();
        
        CARE_App_Enrolled_SA__c objCareAppEnrollmentRecord = CARE_TestDataFactory.careAppEnrolledSa(listCareAppRecords[0],listSiteRecords[0]);
        objCareAppEnrollmentRecord.RS_CD__c = listSiteRecords[0].Rate_Schedule_EI__c;
        objCareAppEnrollmentRecord.END_DATE__c = Date.today()+30;
        
        listCareAppEnrolledSARecords.add(objCareAppEnrollmentRecord);
        return listCareAppEnrolledSARecords;
    }
    
    //create Care Type records for Reason list & CC Code.      
    private static List<CARE_Type__c> createCareTypeRecords(){
        List <CARE_Type__c> listCareType = new List<CARE_Type__c>();
        
        
        //Create records in Care Type for Valid Status and Valid Rate Schedule
        CARE_Type__c objCareTypeForValidSA = CARE_TestDataFactory.careType();
        objCareTypeForValidSA.TYPE_NO__c = '13';
        objCareTypeForValidSA.TYPE_CODE__c = 'CARE';
        objCareTypeForValidSA.TYPE_DESC__c = '10,20';
        objCareTypeForValidSA.CATEGORY__c  = CARE_Constants.CARE_VALID_SA_CAT;
        listCareType.add(objCareTypeForValidSA);
        
        CARE_Type__c objCareTypeForCC = CARE_TestDataFactory.careType();
        objCareTypeForCC.TYPE_NO__c = CARE_Constants.CARE_CC_REINSTATE_ADJUSTMENT;
        objCareTypeForCC.TYPE_CODE__c = '7';
        objCareTypeForCC.TYPE_DESC__c = 'Reinstatement Regular Customer with Adjustment';
        objCareTypeForCC.TYPE_DESC_LONG__c = 'CARE REINSTATED AND ADJUSTED REGULAR CUSTOMER';
        listCareType.add(objCareTypeForCC);
        
        CARE_Type__c objCareTypeForCCWithOutAdjsutment = CARE_TestDataFactory.careType();
        objCareTypeForCCWithOutAdjsutment.TYPE_NO__c = CARE_Constants.CARE_CC_REINSTATE_NO_ADJUSTMENT;
        objCareTypeForCCWithOutAdjsutment.TYPE_CODE__c = '7';
        objCareTypeForCCWithOutAdjsutment.TYPE_DESC__c = 'Reinstatement Regular Customer';
        objCareTypeForCCWithOutAdjsutment.TYPE_DESC_LONG__c = 'CARE REINSTATED REGULAR CUSTOMER';
        listCareType.add(objCareTypeForCCWithOutAdjsutment);
        
        CARE_Type__c objCareTypeForReason = CARE_TestDataFactory.careType();        
        objCareTypeForReason.CATEGORY__c = 'Reinstatement Reason';
        objCareTypeForReason.TYPE_DESC__c = 'Income Proof Provided';
        objCareTypeForReason.IS_ACTIVE__C = true;
        listCareType.add(objCareTypeForReason);        
        
        CARE_Type__c objCareTypeForValidRate = CARE_TestDataFactory.careType();
        objCareTypeForValidRate.TYPE_NO__c = '14';
        objCareTypeForValidRate.TYPE_CODE__c = 'CARE';
        objCareTypeForValidRate.TYPE_DESC__c = 'STANDARD,E-RES,G-RES,HE-RES,HG-RES,PT-E-RES,HN-E-RES';
        objCareTypeForValidRate.CATEGORY__c  = CARE_Constants.CARE_VALID_RATE_CAT;
        listCareType.add(objCareTypeForValidRate);
        
        return listCareType;
    }
    
}