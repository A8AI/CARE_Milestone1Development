/***********************************************************************************************************   
Apex Util class Name :  CARE_CommunicationControllerTest
Version              :  1.0                                                                          
Created Date         :  05/27/2020                                                         
Function             :  This is the Test class for Apex Controller for Communication Modals in CARE Enrollment tab.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/27/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/
@istest(SeeAllData=false)

public class CARE_CommunicationControllerTest {
    
    @TestSetup
    public static void setUpData() {
        Account a = new Account();
        a.Name = 'Test Account1';
        a.Bus_Phone_1_EI__c = '8085835332';
        a.Bus_Phone_2_EI__c = '9039780462';
        a.Primary_Contact_Mobile_EI__c = '8109145322';
        a.Billing_Person_ID_EI__c = '0123456001';
        a.PREFERRED_CONTACT_METHOD__c = 'Mail';
        a.Languages_Other_Than_English_EI__c = 'Korean';
        insert a;
         
        }
       
    
	@isTest
    static void getPhoneDetailsTest(){
        boolean bCommStatus = false;
        
        Account a = new Account();
        a.Name = 'Test Account1';
        a.Bus_Phone_1_EI__c = '8085835332';
        a.Bus_Phone_2_EI__c = '9039780462';
        a.Primary_Contact_Mobile_EI__c = '8109145322';
        a.Billing_Person_ID_EI__c = '0123456001';
        a.PREFERRED_CONTACT_METHOD__c = 'Mail';
        a.Languages_Other_Than_English_EI__c = 'Korean';
        insert a;
        
        //setUpData();
        Test.startTest(); 
        List<CARE_CommunicationController.DataTableWrapper> listPhoneDetails = new List<CARE_CommunicationController.DataTableWrapper>();
        listPhoneDetails = CARE_CommunicationController.getPhoneDetails(a.Billing_Person_ID_EI__c);
        System.assertEquals(1, listPhoneDetails.size(),'Success');
        
        CARE_CommunicationController.DataTableWrapper saveResults = new CARE_CommunicationController.DataTableWrapper();
        saveResults.home= '8085835332';
        saveResults.work= '9039780462';
        saveResults.mobile= '8109145322'; 
        CARE_CommunicationController.savePhoneDetails(saveResults, a.Billing_Person_ID_EI__c);
        //System.assertEquals(1, saveResults.size(),'Success');
        
        List<Account> languageDetails = new List<Account>();
        languageDetails = CARE_CommunicationController.getLangDetails(a.Billing_Person_ID_EI__c);
        System.assertEquals(1, languageDetails.size(),'Success');
        
        string language = 'Vietnamese';
        CARE_CommunicationController.saveLangDetails(language, a.Billing_Person_ID_EI__c);
        
        List<Account> commDetails = new List<Account>();
        commDetails = CARE_CommunicationController.getCommDetails(a.Billing_Person_ID_EI__c);
        System.assertEquals(1, commDetails.size(),'Success');
        
        
        string commPref =  'Email';  
     	bCommStatus = CARE_CommunicationController.saveCommDetails(commPref, a.Billing_Person_ID_EI__c);
        //System.assertEquals(true, bCommStatus);
        Test.stopTest();
    }
     
    @isTest
    static void fetchPickListValueTest(){
        Test.startTest();
        List<CARE_CommunicationController.DataTableWrapper> commPicklistValues = new List<CARE_CommunicationController.DataTableWrapper>();
        Account a = new Account();
        commPicklistValues = CARE_CommunicationController.fetchPickListValue(a,'PREFERRED_CONTACT_METHOD__c');
        System.assert(commPicklistValues.size()>0,'Success');
        Test.stopTest();
            
    }
    
}