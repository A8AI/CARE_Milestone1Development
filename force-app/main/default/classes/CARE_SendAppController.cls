/***********************************************************************************************************   
Apex Util class Name :  CARE_SendAppController
Version              :  1.0                                                                          
Created Date         :  06/05/2020                                                         
Function             :  This is the Apex COntroller for Send App of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/06/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/
public class CARE_SendAppController {
    
    /******************************************WRAPPER CLASSES*************************************** */
    //Custom Wrapper class for User List
    public class SendAppWrapper
    {
        @AuraEnabled public Boolean bSuccess{get;set;}
        @AuraEnabled public String sErrorCode{get;set;}
        @AuraEnabled public String sErrorMessage{get;set;}
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public String sContactCode{get;set;}
        public SendAppWrapper()
        {
            bSuccess = true;
            sErrorCode = '';
            sErrorMessage = '';
            sComment = '';
            sContactCode = '';
        }        
    } 
    public class SendAppWrapperReq
    {
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sAccId{get;set;}
        @AuraEnabled public String sBillingAccId{get;set;}
        @AuraEnabled public String sApplicantName{get;set;}         
    }   
      
    /******************************************WRAPPER CLASSES*************************************** */
    
    /******************************************PUBLIC METHODS*************************************** */
    
    @AuraEnabled
    public static SendAppWrapper getSendAppDetails(){
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        SendAppWrapper sendAppWrapper = new SendAppWrapper();
        try{
            //get the cc code details for Send App
            listCareType = CARE_UtilityController.getCCCode(null, CARE_Constants.CARE_SEND_APP_CC_CODE, CARE_Constants.CARE_SEND_APP_RSN_CAT);   
            sendAppWrapper.sComment = listCareType[0].TYPE_DESC_LONG__c;
            sendAppWrapper.sContactCode = listCareType[0].TYPE_CODE__c;
            sendAppWrapper.bSuccess = true;
        }
        catch(Exception ex){
            sendAppWrapper.bSuccess = false;
            sendAppWrapper.sErrorCode = CARE_Constants.CARE_APPLICATION_ERROR;
            sendAppWrapper.sErrorMessage = ex.getMessage();
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
            //throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());   
        }
        
        return sendAppWrapper;
    }
    
    //This method is used to save record in Care_Application__c object for sending application via CC&B, for those customer who does not have a CARE/FERA enrollment
    @AuraEnabled
    public static SendAppWrapper createTransactionForSendApp(SendAppWrapperReq objSendApp){
        Date dTodaysDate = Date.today();
        Map <String, EI_SITE__C> mapValidSAForPerId = new Map <String, EI_SITE__C>();
        SendAppWrapper sendAppWrapper = new SendAppWrapper();
        
        try{
            Id userId = UserInfo.getUserId();            
            User userDetails = [SELECT Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];
            
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            /* Not required
//Check if the Person Id has valid SA and the customer is not on CARE/FERA
mapValidSAForPerId = CARE_UtilityController.getActiveSADetailsForPersonId(sPerId);
system.debug('mapSAForPerId==>'+ mapValidSAForPerId);

//If the map is empty, then it means the customer has no CARE/FERA enrollment for any of the valid SAs,
//hence insert a record in Care_Application__c, else return error
if(mapValidSAForPerId.isEmpty()){
*/
            //Get the CC Code for 'A' for stamping
            List<CARE_Type__c> listCareType = CARE_UtilityController.getCCCode(null, CARE_Constants.CARE_SEND_APP_CC_CODE, CARE_Constants.CARE_SEND_APP_RSN_CAT);
            
            //Create record in CARE_Application__c
            CARE_Application__c careApp = new CARE_Application__c();   
            careApp.RecordTypeId = careAppRecTypeId;
            careApp.APPLICANT_NAME__c = objSendApp.sApplicantName;
            careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
            //careApp.RECEIVED_DATE__c = dTodaysDate;
            careApp.PROCESSED_DATE__c = dTodaysDate;
            careApp.PER_ID__c = objSendApp.sPerId;
            careApp.CARE_Account_ID__c = objSendApp.sAccId;
            careApp.ACCT_ID__c = objSendApp.sBillingAccId;
            careApp.CCB_CONTACT_CODE__c = listCareType[0].TYPE_CODE__c;
            careApp.CCB_CONTACT_DESC__c= listCareType[0].TYPE_DESC__c;
            careApp.CCB_CONTACT_COMMENT__c = listCareType[0].TYPE_DESC_LONG__c.replace(CARE_Constants.CARE_LAN_ID_PLACEHOLDER, (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '');
            careApp.ENROLLMENT_TYPE__c = 'OTHER'; //ENROLLMENT, PEV, PEV NOTICE, OTHER
            careApp.APPLICATION_EXTERNAL_ID__c = 'EN'; //EN or PE or BA
            careApp.APPLICATION_TYPE__c = 'Enrollment';     //Enrollment,PEV,Notice,Other  
            careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_REGULAR_APP;
            
            
            insert careApp; 
            
            sendAppWrapper.bSuccess = true;
        }catch (Exception ex) {
            system.debug('ex==>'+ex);
            sendAppWrapper.bSuccess = false;
            sendAppWrapper.sErrorCode = CARE_Constants.CARE_APPLICATION_ERROR;
            sendAppWrapper.sErrorMessage = ex.getMessage();
            //throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }    
        /*}
else{
//Return error message with code
sendAppWrapper.bSuccess = false;
sendAppWrapper.sErrorCode = 'Customer not eligible';
sendAppWrapper.sErrorMessage = 'Customer already has CARE/FERA discount in any valid SA.';
}*/
        return sendAppWrapper;
    }
    
    /******************************************PUBLIC METHODS*************************************** */
    
}