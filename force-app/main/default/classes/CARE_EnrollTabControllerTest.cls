/***********************************************************************************************************   
Apex Util class Name :  CARE_EnrollTabControllerTest
Version              :  1.0                                                                          
Created Date         :  06/08/2020                                                         
Function             :  This is the Test class for Apex Controller for Enroll Tab of CARE Enroll tab Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/08/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/


@istest(SeeAllData=false)
public class CARE_EnrollTabControllerTest {
    
    @testSetup
    public static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User lstusr = PM_EI_TestDataUtility.createUser(); //called testdatafactory for creation of user
        System.debug('lstusr is'+lstusr);
        lstusr.ProfileId = p.Id;
        insert lstusr;   // inserted user
        List<Account> listAccountRecords = createAccountRecords();
        insert listAccountRecords;
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
    public static void testgetRelatedSA(){
            List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
	        List<CARE_App_Enrolled_SA__c> objCareAppEnrol = [select Id, SA_ID__c, Service_Agreement__r.Svc_Type_Code_EI__c,SA_START_DATE__c, 
                                                END_DATE__c, RETRO_START_DATE__c,RETRO_END_DATE__c,
                                                LAST_BILL_DATE__c, Service_Agreement__r.SA_Start_Date_EI__c, APPLICATION__r.Id           
                                                //from CARE_App_Enrolled_SA__c where Id =: careAppId order by SA_ID__c];
                                                from CARE_App_Enrolled_SA__c];
        Test.startTest();
            CARE_EnrollTabController.getRelatedSA(objCareAppEnrol[0].APPLICATION__r.Id,'true');
        	CARE_EnrollTabController.sendReceivedDate('test');
        Test.stopTest();

    }
    @isTest
    public static void testdetermineisNewEnrollment(){
            List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user 
            List<EI_Site__c> lstSite = [SELECT  Id, Person_ID_EI__c, Care_Stop_Date_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Account_EI__r.Discount__c,Site_Premise_ID_EI__c,Res_Ind_EI__c,SAID_EI__c,
                                        Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c From EI_Site__c ];    // queried lstSite	
			List<CARE_App_Enrolled_SA__c> objCareAppEnrol = [select Id, SA_ID__c, Service_Agreement__r.Svc_Type_Code_EI__c,SA_START_DATE__c, 
                                                END_DATE__c, RETRO_START_DATE__c,RETRO_END_DATE__c,
                                                LAST_BILL_DATE__c, Service_Agreement__r.SA_Start_Date_EI__c, APPLICATION__r.Id           
                                                from CARE_App_Enrolled_SA__c];
        List<CARE_Type__c> careType = [SELECT COMMENTS__c,TYPE_CODE__c,TYPE_NO__c,TYPE_DESC_LONG__c FROM CARE_Type__c];
        
        List<String> preId = new List<String>();
        preId.add(lstSite[0].Site_Premise_ID_EI__c);
        Test.startTest();
        	CARE_EnrollTabController.determineisNewEnrollment(lstSite[0].Person_ID_EI__c,'test');
        	//CARE_EnrollTabController.GetCCCode(objCareAppEnrol[0].APPLICATION__r.Id,lstSite[0].Person_ID_EI__c,preId,'true');
        	//CARE_EnrollTabController.GetCCCode(objCareAppEnrol[0].APPLICATION__r.Id,lstSite[0].Person_ID_EI__c,preId,'false');
        Test.stopTest();
    }
    @isTest
    public static void testhandleButtonClickOnUI(){
        List<Account> listAccountRecords = createAccountRecords();
        insert listAccountRecords;
            List<User> usr = [SELECT Id, Name From User WHERE isActive = true and Username = 'test@test9845876.com']; //queried user
            List<EI_Site__c> lstSite = [SELECT  Id, Person_ID_EI__c, Care_Stop_Date_EI__c, Imported_Site_Name_EI__c,Rate_Schedule_EI__c,Account_EI__r.Discount__c,Site_Premise_ID_EI__c,Res_Ind_EI__c,SAID_EI__c,
                                        Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c From EI_Site__c ];
     	    List<CARE_App_Enrolled_SA__c> listCareAppEnroll = [select  Id, APPLICATION__c,SA_ID__c,PREM_ID__c,ACCT_ID__c,CC_CL_CD__c,Service_Agreement__c,PER_ID__c, END_DATE__c,SERVICE_FULL_ADDRESS__c from CARE_App_Enrolled_SA__c];
 	        List<CARE_APPLICATION__c> careApp = [SELECT IS_RECERT__c,NO_ADULT__c,CARE_Account_ID__c,NO_CHILD__c,IS_SIGNED__c,REQUEST_DROP__c,NEED_NAME_CHANGE__c,APPLICANT_NAME__c,RECEIVED_DATE__c,PROCESSED_DATE__c,SOURCE_CHANNEL_TYPE__c,FORM_CODE__c,COC_CODE__c,APPLICATION_STATUS__c,LIHEAP__c,WIC__c,CALFRESH_SNAP__c,CALWORKS_TANF__c,HEAD_START_INCOME__c,SSI__c,HEALTHY_FAMILIES__c,NSLP__c,BUREAU_INDIAN_AFFAIRS__c,MEDICAID_UNDER65__c,MEDICAID_OVER65__c,EMAIL_ADDRESS__c,ANNUAL_HOUSEHOLD_INCOME__c,FIXED_INCOME__c,ENROLLMENT_TYPE__c,PER_ID__c from CARE_APPLICATION__c];//queried Care Application 
        	List<CARE_Type__c> objCare = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c,CATEGORY__c,TYPE_NO__c, START_DATE__c ,END_DATE__c  FROM CARE_Type__c Limit 1];
        	objCare[0].TYPE_NO__c = '6034';
        	objCare[0].CATEGORY__c = 'Transfer';
        	objCare[0].START_DATE__c = date.today()-3;
        	objCare[0].END_DATE__c = date.today()+3;
        	objCare[0].IS_ACTIVE__C = true;
        	update objCare[0];
        	List<CARE_APP_Image_List__c> listCareAppImgList = [SELECT Id, Name FROM CARE_APP_Image_List__c];

        	List<String> ID = new List<String>();
        	ID.add(careApp[0].Id);
        	String careAppId = careApp[0].Id;
        	String eIAcctId = careApp[0].CARE_Account_ID__c;
        
            List<String> preId = new List<String>();
            preId.add(lstSite[0].Site_Premise_ID_EI__c);
        
        	String sIsAccepted = 'Yes';
        
        	CARE_EnrollTabController.CustomerInfoWrapper testCustWrapper = new CARE_EnrollTabController.CustomerInfoWrapper();
        	testCustWrapper.isCertValueCB = careApp[0].IS_RECERT__c;
			testCustWrapper.receiveDateValue = careApp[0].RECEIVED_DATE__c;
        	testCustWrapper.processDateValue = careApp[0].PROCESSED_DATE__c;
            testCustWrapper.channelTypeValue = careApp[0].SOURCE_CHANNEL_TYPE__c;
            testCustWrapper.formCodeValue = careApp[0].FORM_CODE__c;
            testCustWrapper.cocCodeValue = careApp[0].COC_CODE__c;
            testCustWrapper.uHeapValue = careApp[0].LIHEAP__c;
            testCustWrapper.wicValue = careApp[0].WIC__c;
			testCustWrapper.calFreshValue = careApp[0].CALFRESH_SNAP__c;
            testCustWrapper.calWorkValue = careApp[0].CALWORKS_TANF__c;
            testCustWrapper.hsieValue = careApp[0].HEAD_START_INCOME__c;
            testCustWrapper.ssiValue = careApp[0].SSI__c;
            testCustWrapper.mediFamilyValue = careApp[0].HEALTHY_FAMILIES__c;
            testCustWrapper.nslpValue = careApp[0].NSLP__c;
            testCustWrapper.boiaValue = careApp[0].BUREAU_INDIAN_AFFAIRS__c;
            testCustWrapper.mediUnderValue = careApp[0].MEDICAID_UNDER65__c;
           	testCustWrapper.mediOverValue = careApp[0].MEDICAID_OVER65__c; 
            testCustWrapper.emailValue = careApp[0].EMAIL_ADDRESS__c;	
            testCustWrapper.annualIncValue = careApp[0].ANNUAL_HOUSEHOLD_INCOME__c;
            testCustWrapper.fixedIncValue = careApp[0].FIXED_INCOME__c;
        Test.startTest();
        CARE_EnrollTabController.prePopulatEnrollData(careApp[0].PER_ID__c,careApp[0].Id);
        CARE_EnrollTabController.prePopulatEnrollData(careApp[0].PER_ID__c,'tab');
        CARE_EnrollTabController.handleButtonClickOnUI(testCustWrapper,careApp[0].PER_ID__c,ID,'save',false,careApp[0].Id,careApp[0].CARE_Account_ID__c);
        CARE_EnrollTabController.updateAccountEmail(testCustWrapper, careApp[0].PER_ID__c);
        CARE_EnrollTabController.getPhoneDetails(listAccountRecords[0].Id);
        CARE_EnrollTabController.createUpdateCareAppRecord(testCustWrapper, careApp[0].PER_ID__c, preId, careAppId, eIAcctId);
        CARE_EnrollTabController.GetCCCode(careAppId, careApp[0].PER_ID__c, preId, sIsAccepted);
        //CARE_EnrollTabController.handleButtonClickOnUI(testCustWrapper,careApp[0].PER_ID__c,ID,'accept',true,careApp[0].Id,careApp[0].CARE_Account_ID__c);
        //CARE_EnrollTabController.handleButtonClickOnUI(testCustWrapper,careApp[0].PER_ID__c,ID,'accept',false,careApp[0].Id,careApp[0].CARE_Account_ID__c);
        //CARE_EnrollTabController.handleButtonClickOnUI(testCustWrapper,careApp[0].PER_ID__c,ID,'verify',false,careApp[0].Id,careApp[0].CARE_Account_ID__c);
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
}