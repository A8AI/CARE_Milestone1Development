/***********************************************************************************************************   
Apex Util class Name :  CARE_UtilityControllerTest
Version              :  1.0                                                                          
Created Date         :  06/16/2020                                                         
Function             :  This is the Test class for Apex Controller for Utility of CARE Enroll tab Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/16/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

@istest(SeeAllData=false)
public class CARE_UtilityControllerTest {
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    @TestSetup
    public static void makeData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile careProcessorProfile = [select id from Profile where name = 'CARE Base Profile' LIMIT 1];
        
        //Create user record
        List<User> lstUser = new List<User>();
        User usr = PM_EI_TestDataUtility.createUser(); //called testdatafactory for creation of user
        System.debug('lstusr is'+usr);
        usr.ProfileId = p.Id;
        lstUser.add(usr);   
        
        User usrCareProcessor = PM_EI_TestDataUtility.createUser();
        usrCareProcessor.LastName = CARE_PROCESSOR_USR;
        usrCareProcessor.profileid = careProcessorProfile.Id;
        usrCareProcessor.Username = 'test@careprocessor.com';
        usrCareProcessor.CommunityNickname = 'test@careprocessor.com';
        lstUser.add(usrCareProcessor);
        
        insert lstUser;   // inserted user
        
        Account lst = PM_EI_TestDataUtility.createAccount(); //called testdatafactory for creation of account
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
        insert lstSite; //inserted site
        Case objCase = CARE_TestDataFactory.objCase();
        insert objCase;
        List<CARE_Application__c> lstCareAppObj = new List<CARE_Application__c>();
        CARE_Application__c objCareApp = CARE_TestDataFactory.careApplication(lst);
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
        lstCareAppObj.add(objCareApp);
        
        CARE_Application__c objCareApp1 = CARE_TestDataFactory.careApplication(lst);
        objCareApp1.ENROLLMENT_TYPE__c = 'OTHER';
        objCareApp1.IS_RECERT__c =  true;
        objCareApp1.NO_ADULT__c =  3;
        objCareApp1.NO_CHILD__c =  1;
        objCareApp1.IS_SIGNED__c =  true;
        objCareApp1.REQUEST_DROP__c =  true;
        objCareApp1.NEED_NAME_CHANGE__c =  false;
        objCareApp1.APPLICANT_NAME__c =  'TestImage';
        objCareApp1.RECEIVED_DATE__c =  date.today()-7;
        objCareApp1.PROCESSED_DATE__c =  date.today()-5;
        objCareApp1.SOURCE_CHANNEL_TYPE__c =  'Bill Insert';
        objCareApp1.FORM_CODE__c =  '';
        objCareApp1.COC_CODE__c =  '';
        objCareApp1.APPLICATION_STATUS__c = 'In-Progress';        
        objCareApp1.LIHEAP__c =  false;
        objCareApp1.WIC__c =  false;
        objCareApp1.CALFRESH_SNAP__c =  false;
        objCareApp1.CALWORKS_TANF__c =  false;
        objCareApp1.HEAD_START_INCOME__c =  false;
        objCareApp1.SSI__c =  true;
        objCareApp1.HEALTHY_FAMILIES__c =  false;
        objCareApp1.NSLP__c =  false;
        objCareApp1.BUREAU_INDIAN_AFFAIRS__c =  true;
        objCareApp1.MEDICAID_UNDER65__c =  true;
        objCareApp1.MEDICAID_OVER65__c =  false;
        objCareApp1.EMAIL_ADDRESS__c =  'abc@gmail.com';
        objCareApp1.ANNUAL_HOUSEHOLD_INCOME__c =  1234;
        objCareApp1.FIXED_INCOME__c =  false;
        objCareApp1.ENROLLMENT_TYPE__c = 'ENROLLMENT'; 
        objCareApp1.CCB_CONTACT_COMMENT__c = 'Not Proper';
        objCareApp1.DROP_SOURCE__c = 'CC&B Case';
        objCareApp1.REASON_DESC__c = 'Testing';        
        lstCareAppObj.add(objCareApp1);
        
        insert lstCareAppObj;
        /* ContentDocumentLink coD = new ContentDocumentLink();
coD.LinkedEntityId = objCareApp.Id;
coD.ContentDocumentId = '0693K000000hXdgQAJ';
insert coD;
ContentVersion cot = new ContentVersion();
cot.Title = 'text';
cot.ContentDocumentId = coD.ContentDocumentId;
insert cot; */
        CARE_App_Enrolled_SA__c objCareAppEnrol = CARE_TestDataFactory.careAppEnrolledSa(objCareApp,lstSite);
        insert objCareAppEnrol;
        CARE_Type__c objCareType = CARE_TestDataFactory.careType();
        insert objCareType;
        /*Image objImage = CARE_TestDataFactory.objImage();
insert objImage;*/
        CARE_APP_Image_List__c objImgList = CARE_TestDataFactory.careImage(objCareApp, objCase);
        insert objImgList;
        EI_SA_CONTERM__c cont = CARE_TestDataFactory.objConterm(lstSite,objCareAppEnrol);
        cont.END_DT__C = date.today()+3;
        cont.BF_CD__C = 'EMP-DSC';
        cont.EXTERNAL_ID__c = '1234567890';
        cont.START_DT__c = date.today()-3;
        insert cont;
    }      
    
    @isTest
    public static void testgetSADetailsForPersonId(){
        List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
        Account acc = [SELECT ID,CARE_ON_PROBATION__c,Billing_Person_ID_EI__c,Billing_Account_ID_EI__c,CARE_PROBATION_START_DATE__c,CARE_PROBATION_END_DATE__c FROM ACCOUNT];
        acc.CARE_PROBATION_END_DATE__c = date.today()+3;
        acc.CARE_PROBATION_START_DATE__c = date.today()-3;
        List<String> str = new List<string>();
        str.add(acc.Billing_Account_ID_EI__c);
       
        List<CARE_APPLICATION__c> careApp = [SELECT IS_RECERT__c,CCB_CONTACT_COMMENT__c,DROP_SOURCE__c, REASON_DESC__c, NO_ADULT__c,CARE_Account_ID__c,NO_CHILD__c,IS_SIGNED__c,REQUEST_DROP__c,NEED_NAME_CHANGE__c,APPLICANT_NAME__c,RECEIVED_DATE__c,PROCESSED_DATE__c,SOURCE_CHANNEL_TYPE__c,FORM_CODE__c,COC_CODE__c,APPLICATION_STATUS__c,LIHEAP__c,WIC__c,CALFRESH_SNAP__c,CALWORKS_TANF__c,HEAD_START_INCOME__c,SSI__c,HEALTHY_FAMILIES__c,NSLP__c,BUREAU_INDIAN_AFFAIRS__c,MEDICAID_UNDER65__c,MEDICAID_OVER65__c,EMAIL_ADDRESS__c,ANNUAL_HOUSEHOLD_INCOME__c,FIXED_INCOME__c,ENROLLMENT_TYPE__c,PER_ID__c from CARE_APPLICATION__c];//queried Care Application 
        //ContentDocumentLink coD = [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: careApp[0].Id];
        EI_Site__c lstSite = [SELECT  Id, Person_ID_EI__c, Care_Stop_Date_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Account_EI__r.Discount__c,Site_Premise_ID_EI__c,Res_Ind_EI__c,SAID_EI__c,Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c From EI_Site__c where Rate_Schedule_EI__c = 'STANDARDDD'];    // queried lstSite	
        List<CARE_Type__c> objCareType = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c,CATEGORY__c,IS_ACTIVE__c,TYPE_NO__c, START_DATE__c ,END_DATE__c  FROM CARE_Type__c ];
        System.debug('objCareType---> '+objCareType);
        EI_SA_CONTERM__c cont = [SELECT SERVICE_AGREEMENT__c, Id, Name, SA_ID__c,END_DT__C,BF_CD__C FROM EI_SA_CONTERM__c];
        CARE_APP_Image_List__c imgObj = [SELECT Id, Name,Application__c FROM CARE_APP_Image_List__c ];
        Test.startTest();
        CARE_UtilityController.getSADetailsForPersonId(lstSite.Person_ID_EI__c);
        CARE_UtilityController.getActiveSADetailsForPersonId(lstSite.Person_ID_EI__c);
        CARE_UtilityController.getCCCode(objCareType[0].TYPE_NO__c,objCareType[0].TYPE_CODE__C,objCareType[0].CATEGORY__c);
        CARE_UtilityController.getCCCode(null,objCareType[0].TYPE_CODE__C,objCareType[0].CATEGORY__c);
        lstSite.Care_Stop_Date_EI__c = date.today()-1;
        update lstSite;
        CARE_UtilityController.getActiveSADetailsWithNoDiscForPersonId(lstSite.Person_ID_EI__c);
        CARE_UtilityController.checkCustomerOnProbation(acc.Billing_Person_ID_EI__c);
        CARE_UtilityController.validateRetroDates(str);
        CARE_UtilityController.getReasonList(objCareType[0].CATEGORY__c);
        CARE_UtilityController.checkIfImageIDExists(imgObj.Application__c);
        CARE_UtilityController.getReceivedDateSession();
        CARE_UtilityController.checkIfUploadedImageExists(careApp[0].Id);
        CARE_UtilityController.checkIfImageIDExists(acc.Id);
        CARE_UtilityController.checkEmployeeDiscount(lstSite.Person_ID_EI__c);
        CARE_UtilityController.checkEmployeeDiscount(acc.Id);
        Test.stopTest();       
    }
    
    //Fetch and Delete Files objects using File Upload Controller
    @isTest 
    static void checkIfUploadedImageExistsTest(){
        Boolean bExists = false;
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        System.runAs(user1[0]){ 
            /*********************Test data setup************************/
            List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE APPLICANT_NAME__c = 'TestAman'];
            
            //Create ContentVersion
            List<ContentVersion> lstContVer = new List<ContentVersion>();
            ContentVersion contentVersionInsert1 = CARE_TestDataFactory.createContentVersion();
            lstContVer.add(contentVersionInsert1);
            
            ContentVersion contentVersionInsert2 = CARE_TestDataFactory.createContentVersion();
            contentVersionInsert2.Title = 'TestEmail';
            contentVersionInsert2.PathOnClient = 'TestEmail.msg';
            lstContVer.add(contentVersionInsert2);
            insert lstContVer;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //Create ContentDocumentLink
            List<ContentDocumentLink> lstContDocLink = CARE_TestDataFactory.createContentDocumentLink(lstCareApp[0], documents);            
            insert lstContDocLink;
            
            /*********************Test data setup************************/
            
            test.startTest();
            
            // Test check document exists
            bExists = CARE_UtilityController.checkIfUploadedImageExists(lstCareApp[0].Id);    
            System.assertEquals(true, bExists);  
            
            // Test check document doesn't exists [there are no ContentVersion records created againnst this Care_Application__c record]
            List<CARE_Application__c> lstCareApp1 = [SELECT Id FROM CARE_Application__c WHERE APPLICANT_NAME__c = 'TestImage'];
            bExists = CARE_UtilityController.checkIfUploadedImageExists(lstCareApp1[0].Id);    
            System.assertEquals(false, bExists);  
                        
            test.stopTest();
        }  
    }
    
    //Fetch and Delete Files objects using File Upload Controller
    @isTest 
    static void deleteUploadedContentsTest(){
        Boolean bDeletedSuccess = false;
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        System.runAs(user1[0]){ 
            /*********************Test data setup************************/
            List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE APPLICANT_NAME__c = 'TestAman'];
            
            //Create ContentVersion
            List<ContentVersion> lstContVer = new List<ContentVersion>();
            ContentVersion contentVersionInsert1 = CARE_TestDataFactory.createContentVersion();
            lstContVer.add(contentVersionInsert1);
            
            ContentVersion contentVersionInsert2 = CARE_TestDataFactory.createContentVersion();
            contentVersionInsert2.Title = 'TestEmail';
            contentVersionInsert2.PathOnClient = 'TestEmail.msg';
            lstContVer.add(contentVersionInsert2);
            insert lstContVer;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //Create ContentDocumentLink
            List<ContentDocumentLink> lstContDocLink = CARE_TestDataFactory.createContentDocumentLink(lstCareApp[0], documents);            
            insert lstContDocLink;
            
            /*********************Test data setup************************/
            
            test.startTest();
            
            // Check if Delete is successful
            bDeletedSuccess = CARE_UtilityController.deleteUploadedContents(lstCareApp[0].Id);    
            System.assertEquals(true, bDeletedSuccess);  
            
            // Test check document doesn't exists [there are no ContentVersion records created againnst this Care_Application__c record]
            List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            System.assert(documents1.size() == 0);  
                        
            test.stopTest();
        }  
 
    }
    
    @isTest 
    static void getObjectRecordTypeIdTest(){
        Id recTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        System.assertEquals(recTypeId != null,true);    
    }
    
}