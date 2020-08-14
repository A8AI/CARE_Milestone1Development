/***********************************************************************************************************   
Apex Util class Name :  CARE_PEVHUControllerTest
Version              :  1.0                                                                          
Created Date         :  07/21/2020                                                         
Function             :  This is the test class supporting the class CARE_PEVHUController for CARE Search application.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/21/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/
@isTest(seeAllData=false)
public class CARE_PEVHUControllerTest {
    
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    static final String CARE_PERMISSION_SET = 'CARE_Processor_PS';
    
    //This is the testsetup for preparing the data
    @testSetup
    static void loadTestData(){
        Profile p = [select id from Profile where name =: CARE_Constants.CARE_PROCESSOR_PROFILE LIMIT 1];
        
        //Create user record
        User usr = PM_EI_TestDataUtility.createUser();
        usr.LastName = CARE_PROCESSOR_USR;
        usr.profileid = p.Id;
        insert usr;
        
        //Assign permission set to the user in its context
        System.runAs(usr){
            PermissionSet ps = [Select Id, Name from PermissionSet where Name =: CARE_PERMISSION_SET ];
            PermissionSetAssignment userWithDeleteOperation = permissionSetAssignmentForCommUser(usr, ps.Id);
            insert userWithDeleteOperation;
        }

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
        
        //Create CARE CI CC record
        CARE_CI_CC__c objCICC = createCICCRecords(listAccountRecords);
        insert objCICC;
        
        //Create CARE CC Batch Detail record
        CARE_CC_Batch_Detail__c objCC = createCCBatchDetRecords(listAccountRecords);
        objCC.CARE_CI_CC__c = objCICC.Id;
        insert objCC;
        
        //Create CARE Application record
        List<CARE_Application__c> listCareApp = createCareAppRecords(listAccountRecords, listSiteRecords);
        insert listCareApp;
        
        //Create CARE App Enrolled SA record
        List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSA = createCareAppEnrolledSARecords(listCareApp, listSiteRecords);
        insert listCareAppEnrolledSA;
        
        System.runAs(usr){
        //Create CARE HouseHoldDetail record
        List <CARE_Household_Detail__c> listCareHouseholdDetail = createHouseHoldDetailRecords(listCareApp);
        insert listCareHouseholdDetail;
        system.debug('listCareHouseholdDetail'+listCareHouseholdDetail);
        
        //Create CARE HouseHoldMemberIncome record
        List <CARE_Household_Member_Income__c> listCareHouseholdMemberIncome = createHouseHoldMemberIncomeRecords(listCareHouseholdDetail);
        insert listCareHouseholdMemberIncome;
        system.debug('listCareHouseholdMemberIncome'+listCareHouseholdMemberIncome);
        
        //Create CARE HouseHoldMemberIncomeC record        
        List <CARE_Household_Member_IncomeC__c> listCareHouseholdMemberIncomeC = createHouseHoldMemberIncomeCRecords(listCareHouseholdMemberIncome);
        insert listCareHouseholdMemberIncomeC;
        }
        
        //create Income Source Record
        List <CARE_Income_Sources__c> listCareIncomeSource = createIncomeSourceRecords();
        insert listCareIncomeSource;
        
        //create Income Document Record
        List <CARE_Income_Document_Type__c> listCareIncomeDocument = createIncomeDocumentRecords();
        insert listCareIncomeDocument;
        
        //create Income Form Record
        List <CARE_INCOME_ENTRY_FORM__c> listCareIncomeForm = createIncomeFormRecords();
        insert listCareIncomeForm;
        
        //create Income-Source-Doc Mapping
        List <CARE_INCOME_SOURCE_DOC__c> listCareIncomeSourceDoc = createIncomeSourceDocRecords(listCareIncomeSource, listCareIncomeDocument, listCareIncomeForm );
        insert listCareIncomeSourceDoc;
        
        //Create Care App Image List record
        List<CARE_APP_Image_List__c> lstcareAppImgList = createCareAppImagesLists(listCareApp);        
        insert lstcareAppImgList;
        
        //Create records in Care System Value
        List<CARE_System_Value__c> lstCareSysVal = createCareSysValRecords();
        insert lstCareSysVal;
    }
    
    /**********************Test Methods************************************************************************/
    
    //This test method supports the method for fetching the Care App record
    @isTest
    static void getPevHuDataTest(){
        CARE_PEVHUController.PEVHUWrapper wrapperObj = new CARE_PEVHUController.PEVHUWrapper();
        CARE_PEVHUController.DataTableWrapper dataTableWrapperObj = new CARE_PEVHUController.DataTableWrapper();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Person_ID_EI__c = '0123456003'];
        
        System.runAs(user1[0]){            
            wrapperObj = CARE_PEVHUController.getPevHuData(eiObj[0].Person_Id_EI__C, 'tab', '');
            
            System.assert(wrapperObj.bIsSuccess == true);  
            System.assert(wrapperObj.sProcessDate == Date.today());
            
            //Test getRelatedSA
            dataTableWrapperObj = CARE_PEVHUController.getRelatedSA(wrapperObj.sId, '');
            System.assert(dataTableWrapperObj.listSA.size() == 1);  
            System.assertEquals(true, dataTableWrapperObj.listAdjustReason.size() > 0);  
            System.assert(dataTableWrapperObj.bHavingRetroDates == true);  
            
        }
        test.stopTest();
    } 
    
    //This test method supports the method for saving the Care App record
    @isTest
    static void submitPEVFormTest(){
        CARE_PEVHUController.ResultResp objResultResp = new CARE_PEVHUController.ResultResp();
        CARE_PEVHUController.PEVHUWrapper objPevHuWrapper = new CARE_PEVHUController.PEVHUWrapper();
        CARE_PEVHUController.CareHouseholdDetailWrapper objCareHhWrapper = new CARE_PEVHUController.CareHouseholdDetailWrapper();
        CARE_PEVHUController.CareHouseholdDetailWrapper objCareHhWrapper1 = new CARE_PEVHUController.CareHouseholdDetailWrapper();
        List<CARE_PEVHUController.CareHouseholdDetailWrapper> listCareHhWrapper = new List<CARE_PEVHUController.CareHouseholdDetailWrapper>();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id, Site_Premise_ID_EI__c 
                                  FROM EI_Site__c WHERE Imported_Site_Name_EI__c = 'MEDRANO,JOSE'];
        List<CARE_Application__c> careApp = [SELECT Id, APPLICANT_NAME__c, PER_ID__c, PREM_ID__c, NO_ADULT__c, NO_CHILD__c, NO_WITH_INCOME__c,
                                             PROCESSED_DATE__c, RECEIVED_DATE__c, REQUEST_DROP__c, NO_ATTACHMENTS_RECEIVED__c,
                                             SOURCE_CHANNEL_TYPE__c, FORM_CODE__c, COC_CODE__c, EMAIL_ADDRESS__c,
                                             PHONE_NO__c, ANNUAL_HOUSEHOLD_INCOME__c, Total_Persons_in_Household__c, PEV_FORM__c,
                                             APPLICATION_STATUS__c, ENROLLMENT_TYPE__c, ACCT_ID__c, APPLICATION_TYPE__c, On_Probation__c,
                                             LastModifiedBy.LAN_ID_EI__c, LastModifiedDate, QUALIFIED_BY__c, CARE_Account_ID__c, CARE_Account_ID__r.Name,
                                             CCB_CONTACT_CODE__c, CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c, REASON_DESC__c, PROCESS_NOTES__c, START_DATE__c, END_DATE__c, IS_ADJUSTMENT__c
                                             FROM CARE_Application__c WHERE APPLICANT_NAME__c = 'MEDRANO,JOSE'];//queried Care Application 
        
        CARE_Type__c ct = [SELECT TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c FROM CARE_Type__c WHERE TYPE_NO__c = '146'][0];
        System.runAs(user1[0]){       
            List<String> lstPremId = new List<String>{eiObj[0].Site_Premise_ID_EI__c};
                
                //Create param objPevHuWrapper
                objPevHuWrapper.sApplicantName = careApp[0].APPLICANT_NAME__c;
            objPevHuWrapper.iAdultValue = 2;
            objPevHuWrapper.iChildrenValue = 0;
            objPevHuWrapper.iNoWithIncome = 2;
            objPevHuWrapper.sProcessDate = careApp[0].PROCESSED_DATE__c;
            objPevHuWrapper.sReceiveDate = careApp[0].RECEIVED_DATE__c;
            objPevHuWrapper.sEmail = 'a@gmail.com';
            objPevHuWrapper.iAnnualInc = 5;
            objPevHuWrapper.iTotalPersons = 2;
            objPevHuWrapper.bOnProbation = true;
            objPevHuWrapper.bPevForm = true;
            
            //Create param List care household detail wrapper
            objCareHhWrapper.sPersonName = 'Person 1';
            objCareHhWrapper.sIncSrcStatus = 'Valid';
            objCareHhWrapper.dEstAnnSal = 2;
            
            objCareHhWrapper1.sPersonName = 'Person 2';
            objCareHhWrapper1.sIncSrcStatus = 'Valid';
            objCareHhWrapper1.dEstAnnSal = 3;
            
            listCareHhWrapper.add(objCareHhWrapper1);
            
            objPevHuWrapper.listCareHhDetailWrapper = listCareHhWrapper;
            objResultResp = CARE_PEVHUController.submitPEVForm(objPevHuWrapper,listCareHhWrapper , eiObj[0].Person_Id_EI__c, lstPremId, 'save', careApp[0].Id, careApp[0].CARE_Account_ID__c, false );            
            System.assert(objResultResp.applicationId == careApp[0].Id);
            
            objResultResp = CARE_PEVHUController.submitPEVForm(objPevHuWrapper,listCareHhWrapper , eiObj[0].Person_Id_EI__c, lstPremId, 'verify', careApp[0].Id, careApp[0].CARE_Account_ID__c, false );            
            //System.assert(objResultResp.applicationId == careApp[0].Id);
            //System.assert(objResultResp.ccCode != null);
            //System.assert(objResultResp.ccCode == ct.TYPE_CODE__c);
            //System.assert(objResultResp.ccCodeDescription == ct.TYPE_DESC__c);            
            
            objResultResp = CARE_PEVHUController.submitPEVForm(objPevHuWrapper,listCareHhWrapper , eiObj[0].Person_Id_EI__c, lstPremId, 'accept', careApp[0].Id, careApp[0].CARE_Account_ID__c, false );            
            //System.assert(objResultResp.applicationId == careApp[0].Id);
            //System.assert(objResultResp.ccCode != null);
        }
        test.stopTest();
    } 
    
    //This test method supports the method for deleting the HouseholdDetail record
    @isTest
    static void deleteCareHouseholdDetTest(){
        CARE_PEVHUController.PEVHUWrapper wrapperObj = new CARE_PEVHUController.PEVHUWrapper();
        CARE_PEVHUController.DataTableWrapper dataTableWrapperObj = new CARE_PEVHUController.DataTableWrapper();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];        
        
        
        List<Account> listAcc = [SELECT ID, Billing_Person_ID_EI__c
                                 FROM Account WHERE Billing_Person_ID_EI__c = '0123456003'];
        List<EI_Site__c> eiObj = [SELECT ID, Person_Id_EI__C, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, Account_EI__r.Id 
                                  FROM EI_Site__c WHERE Person_ID_EI__c = '0123456003'];
        
        System.runAs(user1[0]){    
            /*PermissionSet ps = [Select Id, Name from PermissionSet where Name =: CARE_PERMISSION_SET ];
            PermissionSetAssignment userWithDeleteOperation = permissionSetAssignmentForCommUser(user1[0], ps.Id);
            insert userWithDeleteOperation;*/
            
            //Create CARE Application record
            List<CARE_Application__c> listCareApp = createCareAppRecords(listAcc, eiObj);
            insert listCareApp;
            
            //Create CARE HouseHoldDetail record
            List <CARE_Household_Detail__c> listCareHouseholdDetail = createHouseHoldDetailRecords(listCareApp);
            insert listCareHouseholdDetail;
            
            //Create CARE HouseHoldMemberIncome record
            List <CARE_Household_Member_Income__c> listCareHouseholdMemberIncome = createHouseHoldMemberIncomeRecords(listCareHouseholdDetail);
            insert listCareHouseholdMemberIncome;
            
            //Create CARE HouseHoldMemberIncomeC record        
            List <CARE_Household_Member_IncomeC__c> listCareHouseholdMemberIncomeC = createHouseHoldMemberIncomeCRecords(listCareHouseholdMemberIncome);
            insert listCareHouseholdMemberIncomeC;
            
            wrapperObj = CARE_PEVHUController.getPevHuData(listCareApp[0].PER_ID__c, 'tab', '');
            
            //Test deleteCareHouseholdDet	
            Boolean res = CARE_PEVHUController.deleteCareHouseholdDet(wrapperObj.listCareHhDetailWrapper[0].sId);
            List<CARE_Household_Detail__c> listCareHhDet = [SELECT Id, PERSON_NAME__c, EST_ANNUAL_SALARY__c, APPLICATION__c,
                                                            (SELECT Id FROM CARE_Household_Member_Income__r),
                                                            (SELECT Id FROM CARE_Household_Member_IncomeC__r)
                                                            FROM CARE_Household_Detail__c
                                                            WHERE APPLICATION__c =:listCareApp[0].Id];
            
            List<CARE_Application__c> listCareAppAfterDelete = [SELECT Id, ANNUAL_HOUSEHOLD_INCOME__c
                                                                FROM CARE_Application__c
                                                                WHERE Id =:listCareApp[0].Id]; 
            
            //System.assert(res == true);
            //System.assert(listCareHhDet.size() == 1); 
            //System.assert(listCareHhDet[0].CARE_Household_Member_Income__r.size() == 1);  
            //System.assert(listCareHhDet[0].CARE_Household_Member_IncomeC__r.size() == 0);  
            
            //System.assertEquals(3, listCareAppAfterDelete[0].ANNUAL_HOUSEHOLD_INCOME__c);
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
        objAccountRecord.Bus_Phone_1_EI__c = '1111111111';
        objAccountRecord.Bus_Phone_2_EI__c = '3333333333';
        objAccountRecord.Primary_Contact_Mobile_EI__c = '5555555555';
        listAccountRecords.add(objAccountRecord);  
        
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
        objSite1.Site_Premise_ID_EI__c = '1234567891';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(objSite1);
        
        return listSiteRecords;
    }
    
    //create Care Type records for Reason list & CC Code.      
    private static List<CARE_Type__c> createCareTypeRecords(){
        List<CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();

        //Create records in Care Type for displaying in Reason dropdown
        CARE_Type__c careType2 = CARE_TestDataFactory.careType();
        careType2.TYPE_NO__c = '11';
        careType2.TYPE_DESC__c = 'Appeal Approval';
        careType2.CATEGORY__c  = 'Adjustment Reason';
        lstCareTypes.add(careType2);
        
        CARE_Type__c careType3 = CARE_TestDataFactory.careType();
        careType3.TYPE_NO__c = '12';
        careType3.TYPE_DESC__c = 'COVID-19';
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
        careType5.TYPE_DESC__c = 'HEV2AN,HEVAN,HEV2A,H2EV2AN,EV2A,E1,E6,HE1,HE6,HETOUA,HETOUB,HETOUC,ABS-TX2,ETOUA,ETOUB,ETOUC,G1,G1NGV,H2E6N,H2ETOUAN,H2ETOUBN,H2ETOUCN,HE1N,HE6N,HG1,HG1NGV,HETOUAN,HETOUBN,HETOUCN,STANDARD';
        careType5.CATEGORY__c  = 'Valid Rate Schedule';
        lstCareTypes.add(careType5);
        
        CARE_Type__c careType6 = CARE_TestDataFactory.careType();
        careType6.TYPE_NO__c = '15';
        careType6.TYPE_CODE__c = 'FERA';
        careType6.TYPE_DESC__c = 'HEV2AN,HEVAN,HEV2A,H2EV2AN,EV2A,E1,E6,HE1,HE6,HETOUA,HETOUB,HETOUC,ABS-TX2,ETOUA,ETOUB,ETOUC,H2E6N,H2ETOUAN,H2ETOUBN,H2ETOUCN,HE1N,HE6N,HETOUAN,HETOUBN,HETOUCN';
        careType6.CATEGORY__c  = 'Valid Rate Schedule';
        lstCareTypes.add(careType6);
        
        CARE_Type__c careType7 = CARE_TestDataFactory.careType();
        careType7.TYPE_NO__c = '163';
        careType7.TYPE_CODE__c = 'D';
        careType7.TYPE_DESC__c = 'IRS Transcript';
        careType7.TYPE_DESC_LONG__c = 'CARE INCOME PROOF LETTER RECEIVED FURTHER PROOF REQUIRED <LAN ID> RCVD <Date Received> # NEED IRS TRANSCRIPT ALL PAGES.';
        careType7.CATEGORY__c  = 'CCB Person Level Contact Code and Comments';
        lstCareTypes.add(careType7);
        
        CARE_Type__c careType8 = CARE_TestDataFactory.careType();
        careType8.TYPE_NO__c = '100';
        careType8.TYPE_CODE__c = 'RANDOM CERT';
        careType8.TYPE_DESC__c = 'PEV Approved - CARE';
        careType8.TYPE_DESC_LONG__c = 'RANDOM;CARE CERT INCOME PROOF DOCUMENTS RECEIVED AND APPROVED <LAN ID> RCVD <Date Received>.';
        careType8.CATEGORY__c  = 'CCB Person Level Contact Code and Comments';
        lstCareTypes.add(careType8);
        
        CARE_Type__c careType9 = CARE_TestDataFactory.careType();
        careType9.TYPE_NO__c = '6042';
        careType9.TYPE_CODE__c = 'TRANSFER';
        careType9.TYPE_DESC__c = 'Account Transfer with Drop';
        careType9.TYPE_DESC_LONG__c = 'CARE DROPPED. DISCOUNT TRANSFERRED TO DIFFERENT SA <SA ID>';
        careType9.CATEGORY__c  = 'CCB Person Level Contact Code and Comments';
        lstCareTypes.add(careType9);
        
        CARE_Type__c careType10 = CARE_TestDataFactory.careType();
        careType10.TYPE_NO__c = '146';
        careType10.TYPE_CODE__c = 'D';
        careType10.TYPE_DESC__c = 'PEV Form?';
        careType10.TYPE_DESC_LONG__c = 'CARE INCOME PROOF LETTER RECEIVED FURTHER PROOF REQUIRED <LAN ID> RCVD <Date Received> # NEED  PEV FORM WITH COMPLETE HOUSEHOLD INFORMATION.';
        careType10.CATEGORY__c  = 'CCB Person Level Contact Code and Comments';
        lstCareTypes.add(careType10);
        
        return lstCareTypes;
    }    
    
    //create Care App Records
    private static List<CARE_Application__c> createCareAppRecords(List<Account> listAccountRecords , List<EI_Site__c> listSiteRecords){
        
        List<CARE_Application__c> listCareAppRecords = new List<CARE_Application__c>();
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        objCareApp.APPLICANT_NAME__c = listSiteRecords[0].Imported_Site_Name_EI__c;
        objCareApp.CC_CL_CD__c = 'CARE';
        objcareApp.APPLICATION_STATUS__c = 'In-Progress';
        objCareApp.CCB_CONTACT_CODE__c = 'D';
        objCareApp.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        objCareApp.PEV_FORM__c = false;
        objCareApp.ENROLLMENT_TYPE__c = 'PEV';
        objCareApp.ANNUAL_HOUSEHOLD_INCOME__c = 5;
        listCareAppRecords.add(objCareApp);
        return listCareAppRecords;
        
    }
    
    //create Care App Enrolled SA Records
    private static List<CARE_App_Enrolled_SA__c> createCareAppEnrolledSARecords(List<CARE_Application__c> listCareAppRecords , List<EI_Site__c> listSiteRecords){
        
        List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSARecords = new List<CARE_App_Enrolled_SA__c>();
        CARE_App_Enrolled_SA__c objCareAppEnrolledSA = CARE_TestDataFactory.careAppEnrolledSa(listCareAppRecords[0], listSiteRecords[0]);      
        objCareAppEnrolledSA.RETRO_START_DATE__c = Date.today()-30;
        objCareAppEnrolledSA.RETRO_END_DATE__c = Date.today()-20;
        listCareAppEnrolledSARecords.add(objCareAppEnrolledSA);
        
        return listCareAppEnrolledSARecords;
        
    }
    //create HouseholdDetails
    private static List<CARE_Household_Detail__c> createHouseHoldDetailRecords( List<CARE_Application__c>listCareApp){
        List <CARE_Household_Detail__c> listHouseholdDetails = new List <CARE_Household_Detail__c>();
        CARE_Household_Detail__c objCareHouseholdDetail = CARE_TestDataFactory.createHouseholdDetail(listCareApp[0]);
        objCareHouseholdDetail.EST_ANNUAL_SALARY__c  = 2;
        objCareHouseholdDetail.INCOME_SOURCE_STATUS__c = 'Valid'; 
        listHouseholdDetails.add(objCareHouseholdDetail);
        
        CARE_Household_Detail__c objCareHouseholdDetail1 = CARE_TestDataFactory.createHouseholdDetail(listCareApp[0]);
        objCareHouseholdDetail1.EST_ANNUAL_SALARY__c  = 3;
        objCareHouseholdDetail1.INCOME_SOURCE_STATUS__c = 'Valid'; 
        listHouseholdDetails.add(objCareHouseholdDetail1);
        
        return listHouseholdDetails;
    }
    
    //create HouseholdIncome Records
    private static List<CARE_Household_Member_Income__c> createHouseHoldMemberIncomeRecords(List<CARE_Household_Detail__c> listHouseholdDetails){
        List <CARE_Household_Member_Income__c> listHouseholdMemberIncome = new List <CARE_Household_Member_Income__c>();
        CARE_Household_Member_Income__c objCareHouseholdMemberIncome = CARE_TestDataFactory.createHouseholdMemberIncome(listHouseholdDetails[0]);
        objCareHouseholdMemberIncome.AMOUNT1__c = 2;
        objCareHouseholdMemberIncome.IS_DOC_VALID__c = true;
        objCareHouseholdMemberIncome.IS_FILING_JOINTLY__c = true;
        listHouseholdMemberIncome.add(objCareHouseholdMemberIncome);
        
        CARE_Household_Member_Income__c objCareHouseholdMemberIncome1 = CARE_TestDataFactory.createHouseholdMemberIncome(listHouseholdDetails[1]);
        objCareHouseholdMemberIncome1.AMOUNT1__c = 2;
        objCareHouseholdMemberIncome1.IS_DOC_VALID__c = true;
        objCareHouseholdMemberIncome1.IS_FILING_JOINTLY__c = true;
        listHouseholdMemberIncome.add(objCareHouseholdMemberIncome1);
        
        return listHouseholdMemberIncome;
    }
    
    //create HouseholdIncomeC Records    
    private static List<CARE_Household_Member_IncomeC__c> createHouseHoldMemberIncomeCRecords(List<CARE_Household_Member_Income__c> listHouseholdMemberIncome){
        List <CARE_Household_Member_IncomeC__c> listHouseholdMemberIncomeC = new List <CARE_Household_Member_IncomeC__c>();
        
        CARE_Household_Member_IncomeC__c objCareHouseholdMemberIncomeC = CARE_TestDataFactory.createHouseholdMemberIncomeC(listHouseholdMemberIncome[0]);
        objCareHouseholdMemberIncomeC.LINE3__c = 3;
        listHouseholdMemberIncomeC.add(objCareHouseholdMemberIncomeC);
        system.debug('listHouseholdMemberIncomeC'+listHouseholdMemberIncomeC);
        return listHouseholdMemberIncomeC;
        
    }
    
    //create Income Source records    
    private static List<CARE_Income_Sources__c> createIncomeSourceRecords(){
        List <CARE_Income_Sources__c> listCareIncomeSource = new List <CARE_Income_Sources__c>();
        CARE_Income_Sources__c objCareIncomeSource = CARE_TestDataFactory.createIncomeSource();
        objCareIncomeSource.Name = 'Contract Work';
        objCareIncomeSource.Source_No__c = '31';   
        listCareIncomeSource.add(objCareIncomeSource);
        
        CARE_Income_Sources__c objCareIncomeSourceHU = CARE_TestDataFactory.createIncomeSource();
        objCareIncomeSourceHU.Name = 'High Usage';
        objCareIncomeSourceHU.Source_No__c = '32';   
        listCareIncomeSource.add(objCareIncomeSourceHU);
        return listCareIncomeSource;
    }
    
    //create Income Document records
    private static List<CARE_Income_Document_Type__c> createIncomeDocumentRecords(){
        List <CARE_Income_Document_Type__c> listCareIncomeDocument = new List <CARE_Income_Document_Type__c>();
        CARE_Income_Document_Type__c objCareIncomeDocument = CARE_TestDataFactory.createIncomeDocument();
        objCareIncomeDocument.Name = 'IRS Transcript';
        objCareIncomeDocument.Doc_Type_No__c = '41';   
        listCareIncomeDocument.add(objCareIncomeDocument);
        return listCareIncomeDocument;
    }
    
    //create Income Form records    
    private static List<CARE_INCOME_ENTRY_FORM__c> createIncomeFormRecords(){
        List <CARE_INCOME_ENTRY_FORM__c> listCareForm = new List <CARE_INCOME_ENTRY_FORM__c>();
        CARE_INCOME_ENTRY_FORM__c objCareIncomeForm = new CARE_INCOME_ENTRY_FORM__c();
        objCareIncomeForm.Name = 'IRS Transcript';        
        objCareIncomeForm.Form_Type_No__c = '51';   
        listCareForm.add(objCareIncomeForm);
        return listCareForm;
    }
    
    
    private static List<CARE_INCOME_SOURCE_DOC__c> createIncomeSourceDocRecords(List <CARE_Income_Sources__c> listCareIncomeSource, 
                                                                                List <CARE_Income_Document_Type__c>listCareIncomeDocument,
                                                                                List <CARE_INCOME_ENTRY_FORM__c> listCareIncomeForm ){
                                                                                    List <CARE_INCOME_SOURCE_DOC__c> listCareSourceDoc = new List <CARE_INCOME_SOURCE_DOC__c>();
                                                                                    CARE_INCOME_SOURCE_DOC__c objCareIncomeSourceDoc = new CARE_INCOME_SOURCE_DOC__c();
                                                                                    objCareIncomeSourceDoc.Source_No__c = listCareIncomeSource[0].Id;
                                                                                    objCareIncomeSourceDoc.DOC_TYPE_NO__c = listCareIncomeDocument[0].Id;    
                                                                                    objCareIncomeSourceDoc.Form_Type_No__c = listCareIncomeForm[0].Id; 
                                                                                    objCareIncomeSourceDoc.DISCOUNT_LENGTH_IN_DAYS__c = 0;                                                                                
                                                                                    listCareSourceDoc.add(objCareIncomeSourceDoc);
                                                                                    return listCareSourceDoc;
                                                                                }
    
    //Create CC Batch Detail Record
    private static CARE_CC_Batch_Detail__c createCCBatchDetRecords(List<Account> listAccountRecords){
        CARE_CC_Batch_Detail__c objCCBatch = CARE_TestDataFactory.createCCBatchDetail(listAccountRecords);
        
        return objCCBatch;
    }
    //Create CI CC Record
    private static CARE_CI_CC__c createCICCRecords(List<Account> listAccountRecords){
        CARE_CI_CC__c objCICC = CARE_TestDataFactory.createCICC(listAccountRecords);
        
        return objCICC;
    }
    
    //create Care App Image List Records
    private static List<CARE_APP_Image_List__c> createCareAppImagesLists(List<CARE_Application__c> lstCareApp){
        List<CARE_APP_Image_List__c> lstcareAppImgList = new List<CARE_APP_Image_List__c>();
        CARE_APP_Image_List__c careAppImgList1 = CARE_TestDataFactory.careImage(lstCareApp[0]);
        careAppImgList1.EXTERNAL_IMAGE_ID__c = '88888888'; //8 digit - DATAXPORT
        careAppImgList1.SOURCE_SYSTEM__c = 'DATAXPORT';
        lstcareAppImgList.add(careAppImgList1);
        
        CARE_APP_Image_List__c careAppImgList2 = CARE_TestDataFactory.careImage(lstCareApp[0]);
        careAppImgList2.EXTERNAL_IMAGE_ID__c = '5555555555'; //10 digit - DOCUMENTUM
        careAppImgList2.SOURCE_SYSTEM__c = 'DOCUMENTUM';
        lstcareAppImgList.add(careAppImgList2);
        
        return lstcareAppImgList;
    }
    
    private static PermissionSetAssignment permissionSetAssignmentForCommUser(User u, Id permissionSetId) {
        
        //PermissionSet ps = [Select Id from PermissionSet where Name = :permissionSetName];
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetID = permissionSetId;
        psa.AssigneeId = u.Id;       
        return psa;
    }
    
    //create Care System Value records for sending email
    private static List<CARE_System_Value__c> createCareSysValRecords(){
        List <CARE_System_Value__c> lstCareSysVal = new List<CARE_System_Value__c>();
        
        CARE_System_Value__c careSysVal1 = CARE_TestDataFactory.createSystemValue('Internal Support Email List', 500, UserInfo.getUserEmail());
        careSysVal1.SYSTEM_VALUE_TYPE__c = 'EMAIL';
        lstCareSysVal.add(careSysVal1);
        
        CARE_System_Value__c careSysVal2 = CARE_TestDataFactory.createSystemValue('Internal Email List CC', 510, UserInfo.getUserEmail());
        careSysVal2.SYSTEM_VALUE_TYPE__c = 'EMAIL';
        lstCareSysVal.add(careSysVal2);
        
        return lstCareSysVal;
    }  
    /**********************Private Test Method for Data Setup***********************************************/
}