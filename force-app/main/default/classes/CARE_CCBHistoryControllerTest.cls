/***********************************************************************************************************   
Apex Util class Name :  CARE_CCBHistoryControllerTest
Version              :  1.0                                                                          
Created Date         :  06/023/2020                                                         
Function             :  This is the Apex COntroller test class for CCBHistory modal.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                        Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/23/2020     Cognizant Technology Solutions                   Initial Version.
*                                                                 CARE Application: 
****************************************************************************************************************************************/
@isTest
public class CARE_CCBHistoryControllerTest {
    
public static CARE_CC_Batch_Detail__c ccBatchRecord;
    
public static testMethod void TestCCbHistoryMethod() {
    
    Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
    insert objAccountRecord;
    
    CARE_Application__c objcareApp = new CARE_Application__c();
        objcareApp.CARE_Account_ID__c = objAccountRecord.Id;
        objcareApp.APPLICATION_STATUS__c = 'New';
        objcareApp.APPLICANT_NAME__c = 'Test Care';
        objcareApp.PER_ID__c = 'TestPerId';
    	objcareApp.ENROLLMENT_TYPE__c = 'OTHER';
    insert objcareApp;
    
    	CARE_CI_CC__c objcareCICC = new CARE_CI_CC__c();
        objcareCICC.CC_STATUS_FLG__c = 'CARE';
        objcareCICC.USER_ID__c = '77777777';
        objcareCICC.CC_DTTM__c = system.today();
        objcareCICC.CC_CL_CD__c = 'CARE';
    	objcareCICC.CC_TYPE_CD__c = '1212121212';
    	insert objcareCICC;
        
      ccBatchRecord = new CARE_CC_Batch_Detail__c(ACCT_ID__c = '1212232122', APPLICATION__c = objcareApp.Id, DETAIL_STATUS_CODE__c = 'Validate',
                                   ELEC_SA_ID__c = '3424354232', GAS_SA_ID__c = '4536543726', EXTERNAL_ID__c = '4653745345',PER_ID__c = '4545454545',
                                   SOURCE_CHANNEL_TYPE__c = 'CARE', USER_ID_CARE1__c = '65656565', CARE_CI_CC__c = objcareCICC.Id);
    insert ccBatchRecord;
    
    CARE_CCBHistoryController.getCCBHistory(ccBatchRecord.PER_ID__c);
        
    }

}