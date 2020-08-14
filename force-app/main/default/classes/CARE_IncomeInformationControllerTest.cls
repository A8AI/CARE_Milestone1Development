/***********************************************************************************************************   
Apex Util class Name :  CARE_IncomeInformationControllerTest
Version              :  1.0                                                                          
Created Date         :  07/27/2020                                                         
Function             :  This is the Test class for Apex Controller of Care_IncomeInformationController.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/27/2020            NPK3                                                Initial Version.
*                                                                           CARE Application: 
****************************************************************************************************************************************/
@istest(SeeAllData=false)
public class CARE_IncomeInformationControllerTest {
    
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    static final String CARE_PERMISSION_SET = 'CARE_Processor_PS';
    
    @testsetup 
    static void setupData(){
        
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
            system.debug('userWithDeleteOperation'+userWithDeleteOperation);
        }
        
        //Create Account record
        List<Account> listAccount = createAccountRecords();
        //listAccount[0].Premise_ID__c = listPremise[0].Id;
        insert listAccount; 
        
        //Create Site record
        List<EI_Site__c> listSite = createSiteRecords(listAccount);
        listSite[0].Account_EI__c =  listAccount[0].Id; 
        // listSite[0].EI_Premise__c = listPremise[0].Id;   
        insert listSite;
        
        //Create CARE APP record
        List <CARE_Application__c> listCareApp = createCareAppRecords(listAccount,listSite);
        insert listCareApp;
        
        
        //Create CARE HouseHoldDetail record
        List <CARE_Household_Detail__c> listCareHouseholdDetail = createHouseHoldDetailRecords(listCareApp);
        insert listCareHouseholdDetail;
        system.debug('listCareHouseholdDetail'+listCareHouseholdDetail);
        
        //Create CARE HouseHoldMemberIncome record
        System.runAs(usr){
        List <CARE_Household_Member_Income__c> listCareHouseholdMemberIncome = createHouseHoldMemberIncomeRecords(listCareHouseholdDetail);
        insert listCareHouseholdMemberIncome;
        
        
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
    }
    
    //**********************Test Methods************************************************************************
    static testmethod void getPersonIncomeInformationTest(){
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        CARE_Household_Detail__c HouseholdObj = [SELECT  Id, APPLICATION__c
                                                 From CARE_Household_Detail__c 
                                                 where PERSON_NAME__c = :sPerName];
        String sApplicationType = CARE_Constants.CARE_APP_PEV;
        CARE_IncomeInformationController.WrapperIncomeInformation objWrapperResponse = new CARE_IncomeInformationController.WrapperIncomeInformation();
        System.runAs(user1[0]){       
            objWrapperResponse = CARE_IncomeInformationController.getPersonIncomeInformation(HouseholdObj.Id ,HouseholdObj.APPLICATION__c, sApplicationType);
            System.assertEquals(0, objWrapperResponse.dMemberAnnualSalary);
            //check HU income Source
            sApplicationType = CARE_Constants.CARE_APP_HU;
            objWrapperResponse = CARE_IncomeInformationController.getPersonIncomeInformation(HouseholdObj.Id ,HouseholdObj.APPLICATION__c, sApplicationType);
            System.assertEquals('High Usage', objWrapperResponse.listIncomeSource[0].value);
            Test.stopTest();
        }
    }
    
    static testmethod void getIncomeDocumentTypeTest(){
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        CARE_IncomeInformationController.WrapperIncomeInput objDocumentInput = new CARE_IncomeInformationController.WrapperIncomeInput();
        CARE_IncomeInformationController.WrapperIncomeDocument objIncomeInformationResponse = new  CARE_IncomeInformationController.WrapperIncomeDocument();
        objDocumentInput.sIncomeSource = 'Categorical Fixed';    
        
        System.runAs(user1[0]){       
            objIncomeInformationResponse = CARE_IncomeInformationController.getIncomeDocumentType(objDocumentInput);
            System.assertEquals('Award Letter -Categorical Fixed', objIncomeInformationResponse.listIncomeDocument[0].value);            
            Test.stopTest();
        }
    }
    
    static testmethod void getIncomeFormTypeTest(){
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        CARE_IncomeInformationController.WrapperIncomeInput objDocumentInput = new CARE_IncomeInformationController.WrapperIncomeInput();
        CARE_IncomeInformationController.WrapperIncomeForm objIncomeFormResponse = new  CARE_IncomeInformationController.WrapperIncomeForm();
        objDocumentInput.sIncomeSource = 'Categorical Fixed';    
        objDocumentInput.sDocumentType = 'Award Letter -Categorical Fixed';      
        System.runAs(user1[0]){       
            objIncomeFormResponse = CARE_IncomeInformationController.getIncomeFormType(objDocumentInput);
            System.assertEquals('Award Letter Categorical Fixed', objIncomeFormResponse.sFormType);            
            Test.stopTest();
        }
    }
    
    static testmethod void getHouseMemberIncomeDetailsTest(){
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        CARE_Household_Member_Income__c HouseholdIncomeObj = [SELECT  Id
                                                              From CARE_Household_Member_Income__c 
                                                              WHERE HOUSEHOLDDETAIL__r.PERSON_NAME__c = :sPerName];
        
        CARE_IncomeInformationController.WrapperFormInput objIncomeDetailsResponse = new  CARE_IncomeInformationController.WrapperFormInput();
        
        System.runAs(user1[0]){       
            objIncomeDetailsResponse = CARE_IncomeInformationController.getHouseMemberIncomeDetails(HouseholdIncomeObj.Id);
            System.assertEquals('Not Applicable', objIncomeDetailsResponse.sPeriodType);            
            Test.stopTest();
        }
    }
    static testmethod void saveHouseholdIncomeTest(){ 
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        CARE_Household_Member_Income__c HouseholdIncomeObj = [SELECT  Id, CARE_Application__c, HOUSEHOLDDETAIL__c , DISCOUNT_LENGTH_IN_DAYS__c, NO_MONTHS__c,
                                                              PERIOD_TYPE__c
                                                              FROM CARE_Household_Member_Income__c 
                                                              WHERE HOUSEHOLDDETAIL__r.PERSON_NAME__c = :sPerName];
        
        CARE_IncomeInformationController.WrapperFormInput objIncomeFormInput = new  CARE_IncomeInformationController.WrapperFormInput();
        objIncomeFormInput.idCareHouseholdmemberIncome = HouseholdIncomeObj.id;
        objIncomeFormInput.idCareApp = HouseholdIncomeObj.CARE_Application__c;
        objIncomeFormInput.idCareHouseholdDetail = HouseholdIncomeObj.HOUSEHOLDDETAIL__c;
        objIncomeFormInput.dDiscountLength  = HouseholdIncomeObj.DISCOUNT_LENGTH_IN_DAYS__c;
        objIncomeFormInput.iMonthNo  = Integer.valueof(HouseholdIncomeObj.NO_MONTHS__c);
        objIncomeFormInput.sPeriodType  = HouseholdIncomeObj.PERIOD_TYPE__c;
        objIncomeFormInput.bIsFillingJointly = false; 
        objIncomeFormInput.bRollOver = false; 
        objIncomeFormInput.bIsValidDoc  = true;
        objIncomeFormInput.bIsSchedule1  = true;
        objIncomeFormInput.bSchedule1DocValid = true;
        objIncomeFormInput.bScheduleCDocComplete =true;           
        System.runAs(user1[0]){       
            Boolean Result= CARE_IncomeInformationController.saveHouseholdIncome(objIncomeFormInput);
            System.assertEquals(true, Result);            
            Test.stopTest();
        }
    }  
    
    static testmethod void deleteHouseholdIncomeRecordTest(){
        
        Test.startTest();
        String sPerName = 'Test Person 1';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        CARE_Household_Member_Income__c HouseholdIncomeObj = [SELECT  Id, CARE_Application__c, HOUSEHOLDDETAIL__c 
                                                              FROM CARE_Household_Member_Income__c 
                                                              WHERE HOUSEHOLDDETAIL__r.PERSON_NAME__c = :sPerName];
        
        
        System.runAs(user1[0]){       
            Boolean Result = CARE_IncomeInformationController.deleteHouseholdIncomeRecord(HouseholdIncomeObj.Id, HouseholdIncomeObj.CARE_Application__c, 
                                                                                          HouseholdIncomeObj.HOUSEHOLDDETAIL__c);
            System.assertEquals(true, Result);            
            Test.stopTest();
        }
    }
    
    //********************Private Test Method for Data Setup****************************
    
    
    private static PermissionSetAssignment permissionSetAssignmentForCommUser(User u, Id permissionSetId) {
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetID = permissionSetId;
        psa.AssigneeId = u.Id;       
        return psa;
    }
    
    
    
    //Create Account Record
    private static List<Account> createAccountRecords(){
        List<Account> listAccountRecords = new List<Account>();
        
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount(); //called testdatafactory for creation of account
        
        objAccountRecord.AccountNumber = '12245903841';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.Service_Address__c = 'Search1234';
        objAccountRecord.SA_Type__c = 'E';
        
        listAccountRecords.add(objAccountRecord);  
        
        return listAccountRecords;
    }
    
    //Create Site Record
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccount){
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
        
        EI_Site__c electricSARecord = CARE_TestDataFactory.createSite(listAccount);
        
        electricSARecord.Billing_Account_ID_EI__c = listAccount[0].Id;
        electricSARecord.Imported_Site_Name_EI__c = listAccount[0].Name;
        electricSARecord.Person_ID_EI__c = listAccount[0].Billing_Person_ID_EI__c;
        electricSARecord.Rate_Schedule_EI__c = 'HE-RES';
        electricSARecord.Care_Start_Date_EI__c = date.today();
        electricSARecord.Care_Stop_Date_EI__c = date.today()+30;
        electricSARecord.SAID_EI__c = listAccount[0].SAID__c;
        electricSARecord.Svc_Status_Code_EI__c = '20';
        electricSARecord.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(electricSARecord);
        
        
        return listSiteRecords;
    }
    
    //create Care App Records
    private static List<CARE_Application__c> createCareAppRecords( List<Account>listAccountRecords , List<EI_Site__c> listSiteRecords){
        
        List <CARE_Application__c> listCareAppRecords = new List<CARE_Application__c>();
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        objCareApp.APPLICANT_NAME__c = listSiteRecords[0].Imported_Site_Name_EI__c;
        objCareApp.CC_CL_CD__c = 'CARE';
        objCareApp.ENROLLMENT_TYPE__c = 'ENROLLMENT';
        objCareApp.CCB_CONTACT_CODE__c = 'FC';
        objCareApp.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        objCareApp.PEV_FORM__c = true;
        listCareAppRecords.add(objCareApp);
        return listCareAppRecords;
        
    }
    
    //create HouseholdDetails
    private static List<CARE_Household_Detail__c> createHouseHoldDetailRecords( List<CARE_Application__c>listCareApp){
        List <CARE_Household_Detail__c> listHouseholdDetails = new List <CARE_Household_Detail__c>();
        CARE_Household_Detail__c objCareHouseholdDetail = CARE_TestDataFactory.createHouseholdDetail(listCareApp[0]);
        listHouseholdDetails.add(objCareHouseholdDetail);
        return listHouseholdDetails;
    }
    
    //create HouseholdIncome Records
    private static List<CARE_Household_Member_Income__c> createHouseHoldMemberIncomeRecords(List<CARE_Household_Detail__c> listHouseholdDetails){
        List <CARE_Household_Member_Income__c> listHouseholdMemberIncome = new List <CARE_Household_Member_Income__c>();
        CARE_Household_Member_Income__c objCareHouseholdMemberIncome = CARE_TestDataFactory.createHouseholdMemberIncome(listHouseholdDetails[0]);
        listHouseholdMemberIncome.add(objCareHouseholdMemberIncome);
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
        objCareIncomeSource.Name = 'Categorical Fixed';
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
        objCareIncomeDocument.Name = 'Award Letter -Categorical Fixed';
        objCareIncomeDocument.Doc_Type_No__c = '41';   
        listCareIncomeDocument.add(objCareIncomeDocument);
        return listCareIncomeDocument;
    }
    
    //create Income Form records
    
    private static List<CARE_INCOME_ENTRY_FORM__c> createIncomeFormRecords(){
        List <CARE_INCOME_ENTRY_FORM__c> listCareForm = new List <CARE_INCOME_ENTRY_FORM__c>();
        CARE_INCOME_ENTRY_FORM__c objCareIncomeForm = new CARE_INCOME_ENTRY_FORM__c();
        objCareIncomeForm.Name = 'Award Letter Categorical Fixed';
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
}