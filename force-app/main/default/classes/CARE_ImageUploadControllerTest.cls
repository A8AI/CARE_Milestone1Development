/***********************************************************************************************************   
Apex Util class Name :  CARE_ImageUploadControllerTest
Version              :  1.0                                                                          
Created Date         :  06/16/2020                                                         
Function             :  This is the test class supporting the class CARE_ImageUploadController for CARE Search application.
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
public class CARE_ImageUploadControllerTest {
    
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    //This is the testsetup for preparing the data
    @testSetup
    static void loadTestData(){
        Profile p = [select id from Profile where name = 'CARE Base Profile' LIMIT 1];
        
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
        //Site record with status as '20', with valid Rate Schedule, and discount in 'Electric'
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords);
        insert listSiteRecords;
        
        //Create records in Care Type for stamping as CC code
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;  
        
        //Create Care Application record
        List<CARE_Application__c> lstCareApp = createCareAppRecords(listAccountRecords,lstCareTypes);
        insert lstCareApp;
        
        //Create Care App Image List record
        List<CARE_APP_Image_List__c> lstcareAppImgList = createCareAppImagesLists(lstCareApp);        
        insert lstcareAppImgList;
    }
    
    /**********************Test Methods************************************************************************/
    
    //Fetch CARE_APP_Image_List__c
    @isTest
    static void getCareAppImageListTest(){
        List<CARE_ImageUploadController.CareAppImageWrapper> wrapperObj = new List<CARE_ImageUploadController.CareAppImageWrapper>();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE PER_ID__c = '0123456003'];
        
        System.runAs(user1[0]){            
            wrapperObj = CARE_ImageUploadController.getCareAppImageList(lstCareApp[0].Id);
            
            System.assert(wrapperObj.size() == 2);  
        }
        test.stopTest();
    }
    
    //Insert and update CARE_APP_Image_List__c
    @isTest
    static void createCareAppImageListInsertUpdateTest(){
        List<CARE_ImageUploadController.CareAppImageWrapper> lstWrapperObj = new List<CARE_ImageUploadController.CareAppImageWrapper>();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE PER_ID__c = '0123456003'];
        
        //Select the existing
        List<CARE_APP_Image_List__c> lstExisting = [SELECT Id, Name, IMAGE_ID__c, Application__c, IMAGE_TYPE__c, SOURCE_SYSTEM__c 
                                                    FROM CARE_APP_Image_List__c
                                                    WHERE Application__c =:lstCareApp[0].Id
                                                    ORDER by Name];
        for(CARE_APP_Image_List__c ci : lstExisting){ //update
            CARE_ImageUploadController.CareAppImageWrapper wrapperObj1 = new CARE_ImageUploadController.CareAppImageWrapper();
            wrapperObj1.sId = ci.Id;
            wrapperObj1.iImageIndex = 0;
            wrapperObj1.iNumber = 1;
            wrapperObj1.sImageId = String.valueOf(ci.IMAGE_ID__c);
            lstWrapperObj.add(wrapperObj1);
        }
        //Add extra value //insert
        CARE_ImageUploadController.CareAppImageWrapper wrapperObj2 = new CARE_ImageUploadController.CareAppImageWrapper();
        wrapperObj2.iImageIndex = 1;
        wrapperObj2.iNumber = 2;
        wrapperObj2.sImageId = '99999999';
        lstWrapperObj.add(wrapperObj2);
        CARE_ImageUploadController.CareAppImageWrapper wrapperObj3 = new CARE_ImageUploadController.CareAppImageWrapper();
        wrapperObj3.iImageIndex = 2;
        wrapperObj3.iNumber = 3;
        wrapperObj3.sImageId = '99999994';
        lstWrapperObj.add(wrapperObj3);
        
        System.runAs(user1[0]){            
            List<CARE_APP_Image_List__c> lstCareAppImageList = CARE_ImageUploadController.createCareAppImageList(lstWrapperObj, lstCareApp[0].Id);
            
            System.assert(lstCareAppImageList.size() == 4);  
        }
        test.stopTest();
    }
    
    //Delete CARE_APP_Image_List__c
    @isTest
    static void deleteCareAppImageListTest(){
        List<CARE_ImageUploadController.CareAppImageWrapper> lstWrapperObj = new List<CARE_ImageUploadController.CareAppImageWrapper>();
        
        test.startTest();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        System.runAs(user1[0]){       
            List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE PER_ID__c = '0123456003'];
            
            //Select the existing
            List<CARE_APP_Image_List__c> lstExisting = [SELECT Id, Name, IMAGE_ID__c, Application__c, IMAGE_TYPE__c, SOURCE_SYSTEM__c 
                                                        FROM CARE_APP_Image_List__c
                                                        WHERE Application__c =:lstCareApp[0].Id
                                                        ORDER by Name];
            
            CARE_ImageUploadController.deleteCareAppImageList(lstExisting[0].Id);
            
            //Check the existing
            List<CARE_APP_Image_List__c> lstAfterDel = [SELECT Id, Name, IMAGE_ID__c, Application__c, IMAGE_TYPE__c, SOURCE_SYSTEM__c 
                                                        FROM CARE_APP_Image_List__c
                                                        WHERE Application__c =:lstCareApp[0].Id
                                                        ORDER by Name];
            System.assert(lstAfterDel.size() == 1);   //remaining is 1 out of 2 after deletion
        }
        test.stopTest();
    }
    
    //Fetch and Delete Files objects using File Upload Controller
    @isTest 
    static void filesUploadGetDeleteTest(){
        List<CARE_ImageUploadController.ContentVersionWrapper> lstCVWrapper = new List<CARE_ImageUploadController.ContentVersionWrapper>();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        
        System.runAs(user1[0]){ 
            /*********************Test data setup************************/
            List<CARE_Application__c> lstCareApp = [SELECT Id FROM CARE_Application__c WHERE PER_ID__c = '0123456003'];
            
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
            List<ContentVersion> contentVersionSelect;
            //System.runAs(user1[0]){     
            List<Id> listConVerIds = new List<Id>();
            for(ContentVersion cv :lstContVer){
                listConVerIds.add(cv.Id);
            }
            // Test INSERT
            contentVersionSelect = [SELECT Id, Title, ContentDocumentId, PathOnClient, FileExtension FROM ContentVersion WHERE Id IN:listConVerIds];        
            System.assertEquals(documents.size(), 2);
            
            // Test RETRIEVE
            lstCVWrapper = CARE_ImageUploadController.getUploadedFiles(lstCareApp[0].Id);            
            System.assert(lstCVWrapper.size() == 2);  
            System.assertEquals(lstCVWrapper[0].sPathOnClient, contentVersionSelect[0].PathOnClient);  
            System.assertEquals(lstCVWrapper[0].sFileExtension, contentVersionSelect[0].FileExtension);
            
            // Test DELETE
            CARE_ImageUploadController.deleteUploadedFile(contentVersionSelect[0].ContentDocumentId);
            documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            System.assertEquals(documents.size(), 1);
            
            test.stopTest();
        }  
    }
    
    /**********************Test Methods************************************************************************/
    
    /**********************Private Test Method for Data Setup***********************************************/
    //Create Premise Record
    private static List<EI_PREMISE__c> createPremiseRecords(){
        List<EI_PREMISE__c> listPremiseRecords = new List<EI_PREMISE__c>();
        
        EI_PREMISE__c prmemiseRecord1 = CARE_TestDataFactory.createPremise('Prem1', '1111111111');
        listPremiseRecords.add(prmemiseRecord1);
        
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
        
        return listSiteRecords;
    }
    
    //create Care Type records for Reason list & CC Code.      
    private static List<CARE_Type__c> createCareTypeRecords(){
        List <CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        CARE_Type__c careType1 = CARE_TestDataFactory.careType();
        careType1.TYPE_NO__c = '6034';
        careType1.TYPE_CODE__c = '7';
        careType1.TYPE_DESC__c = 'Enrollment';
        careType1.CATEGORY__c  = 'CARE Enrollment Contact Codes';
        lstCareTypes.add(careType1);
        
        return lstCareTypes;
    }    
    
    //create Care App Records
    private static List<CARE_Application__c> createCareAppRecords( List<Account>listAccountRecords , List<CARE_Type__c> lstCareTypes){
        
        List <CARE_Application__c> listCareAppRecords = new List<CARE_Application__c>();
        CARE_Application__c careApp = CARE_TestDataFactory.careApplication(listAccountRecords[0]);
        
        careApp.APPLICANT_NAME__c = 'TestApplicant';
        careApp.APPLICATION_STATUS__c = 'In-progress';
        careApp.PROCESSED_DATE__c = Date.today();
        careApp.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        careApp.CCB_CONTACT_CODE__c = lstCareTypes[0].TYPE_CODE__c;
        careApp.CCB_CONTACT_DESC__c= lstCareTypes[0].TYPE_DESC__c;
        careApp.CCB_CONTACT_COMMENT__c = lstCareTypes[0].TYPE_DESC_LONG__c;
        careApp.ENROLLMENT_TYPE__c = 'OTHER'; 
        careApp.APPLICATION_EXTERNAL_ID__c = 'EN'; 
        careApp.APPLICATION_TYPE__c = 'Enrollment';  
        careApp.SOURCE_CHANNEL_TYPE__c = 'Regular App';
        listCareAppRecords.add(careApp);   
        
        return listCareAppRecords;
    }
    
    //create Care App Image List Records
    private static List<CARE_APP_Image_List__c> createCareAppImagesLists(List<CARE_Application__c> lstCareApp){
        List<CARE_APP_Image_List__c> lstcareAppImgList = new List<CARE_APP_Image_List__c>();
        CARE_APP_Image_List__c careAppImgList1 = CARE_TestDataFactory.careImage(lstCareApp[0]);
        careAppImgList1.IMAGE_ID__c = Long.valueOf('88888888'); //8 digit - DATAXPORT
        careAppImgList1.SOURCE_SYSTEM__c = 'DATAXPORT';
        lstcareAppImgList.add(careAppImgList1);
        
        CARE_APP_Image_List__c careAppImgList2 = CARE_TestDataFactory.careImage(lstCareApp[0]);
        careAppImgList2.IMAGE_ID__c = Long.valueOf('5555555555'); //10 digit - DOCUMENTUM
        careAppImgList2.SOURCE_SYSTEM__c = 'DOCUMENTUM';
        lstcareAppImgList.add(careAppImgList2);
        
        return lstcareAppImgList;
    }
    /**********************Private Test Method for Data Setup***********************************************/
    
}