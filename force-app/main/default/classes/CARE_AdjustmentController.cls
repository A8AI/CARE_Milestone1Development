/***********************************************************************************************************   
Apex Util class Name             :  CARE_AdjustmentController
Version                          :  1.0                                                                          
Created Date(MM/DD/YYYY)         :  06/04/2020                                                         
Function                         :  This is the Apex COntroller for Enroll Tab of CARE Application Component.
Story                            :                                                                               
Work Task                        :                                                                               
Modification Log                 :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When(MM/DD/YYYY)                  Who                                        Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/04/2020           Cognizant Technology Solutions                       Initial Version.
*                                                                           CARE Application: 
* 08/28/2020			SKMN				   							    Updated to stamp extra fields for all applications
****************************************************************************************************************************************/


public class CARE_AdjustmentController {
    //Constants 
    Private Static final Date dTodaysDate = Date.today();     
    
    /******************************************WRAPPER CLASSES*************************************** */
    
    //response Wrapper class for Adjustment Section
    public class WrapperAdjustmentResponse{
        @AuraEnabled public List<WrapperAdjustment> listAdjustment = new List<WrapperAdjustment>();
        @AuraEnabled public List<WrapperAdjustmentReason> listAdjustmentReason = new List <WrapperAdjustmentReason>();
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public Date dTodaysDate{get;set;}
        @AuraEnabled public String sContactCode{get;set;}
        
        public WrapperAdjustmentResponse(){
            listAdjustment = new List<WrapperAdjustment>();
            listAdjustmentReason = new List<WrapperAdjustmentReason>();
            sComment = '';
            sContactCode = '';
        }
    }    
    
    //response Wrapper class for Adjustment Section
    public class WrapperAdjustment{
        @AuraEnabled public Id idSARecID {get; set;}
        @AuraEnabled public String sApplicantName {get; set;}
        @AuraEnabled public Id idAccountID {get; set;}
        @AuraEnabled public String sBillingAccountId {get; set;}
        @AuraEnabled public String sPremiseId {get; set;} 
        @AuraEnabled public String sSAId {get; set;}
        @AuraEnabled public String sDiscountType {get; set;}
        @AuraEnabled public String sSADiscountType {get; set;}
        @AuraEnabled public String sRateSchedule {get; set;}
        @AuraEnabled public Date dStartDate {get; set;}
        @AuraEnabled public Date dEndDate {get; set;}
        @AuraEnabled public Date dSAStartDate {get; set;}
        @AuraEnabled public Date dRetroStartDate {get; set;}
        @AuraEnabled public Date dRetroEndDate {get; set;}
        @AuraEnabled public String sSvcFullAddress {get; set;}
        @AuraEnabled public String sSvcTypeCode {get; set;}
    }
    
    public class WrapperAdjustmentReason{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
    //Input parameter from UI selected value
    public class AdjustmentInputWrapper{
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sReason{get;set;}
        @AuraEnabled public String sComment{get;set;}
    }
    /******************************************WRAPPER CLASSES*************************************** */   
    
    /******************************************PUBLIC METHODS*************************************** */     
    //Method to get the SA details for Adjustment modal pop up against the Per ID
    @AuraEnabled 
    public static WrapperAdjustmentResponse getAdjustmentDetails (String sPerId) {
        WrapperAdjustmentResponse adjustmentResponse = new WrapperAdjustmentResponse();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        Map <String, EI_SITE__C> mapActiveSADiscountEnrollment = new Map <String ,EI_SITE__C >();
        string adjustmentAppIdValue = '';
        
        try{
            mapActiveSADiscountEnrollment = CARE_UtilityController.getActiveSADetailsForPersonId(sPerId);
            
            //check if customer is having an existing discount.
            if(mapActiveSADiscountEnrollment.isEmpty()){
                return null;
            }
            else{
                //get the Active enrollment list to be shown in Existing Section              
                for(EI_Site__c careEISite : mapActiveSADiscountEnrollment.values()){
                    
                    WrapperAdjustment objWrapperAdj = new WrapperAdjustment ();
                    objWrapperAdj.idSARecID = careEISite.Id;
                    objWrapperAdj.sApplicantName = careEISite.Imported_Site_Name_EI__c;
                    objWrapperAdj.idAccountID = careEISite.Account_EI__r.Id;
                    objWrapperAdj.sBillingAccountId = careEISite.Billing_Account_ID_EI__c;
                    objWrapperAdj.sPremiseId = careEISite.Site_Premise_ID_EI__c;
                    objWrapperAdj.sSAId = careEISite.SAID_EI__c;
                    objWrapperAdj.sDiscountType = careEISite.Account_EI__r.CARE_DISCOUNT_TYPE__c;//Used for stamping
                    objWrapperAdj.sSADiscountType = careEISite.CARE_DISCOUNT_TYPE__c;//Used for display
                    objWrapperAdj.sRateSchedule = careEISite.Rate_Schedule_EI__c;
                    objWrapperAdj.dStartDate = careEISite.Care_Start_Date_EI__c;
                    objWrapperAdj.dEndDate = careEISite.Care_Stop_Date_EI__c;
                    objWrapperAdj.dSAStartDate = careEISite.SA_Start_Date_EI__c;
                    objWrapperAdj.sSvcFullAddress = careEISite.Svc_Full_Adr_EI__c;//Extra fields
                    objWrapperAdj.sSvcTypeCode = careEISite.Svc_Type_Code_EI__c;//Extra fields
                    
                    adjustmentResponse.listAdjustment.add(objWrapperAdj);                    
                }
                //get the Transfer reason list  
                List <String> listAdjustmentReason = CARE_UtilityController.getReasonList(CARE_Constants.CARE_ADJUSTMENT_RSN_CAT);
                for(String sReasonRec : listAdjustmentReason){
                    
                    WrapperAdjustmentReason objAdjustmentReason = new WrapperAdjustmentReason();
                    objAdjustmentReason.label = sReasonRec;
                    objAdjustmentReason.value = sReasonRec;  
                    adjustmentResponse.listAdjustmentReason.add(objAdjustmentReason);
                } 
                
                //get the cc code details for Adjustment
                listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ADJUSTMENT, null, null);                
                adjustmentResponse.sComment = listCareType[0].TYPE_DESC_LONG__c;
                adjustmentResponse.sContactCode = listCareType[0].TYPE_CODE__c;
                
                adjustmentResponse.dTodaysDate = dTodaysDate;
            }
            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, '', '', sPerId, ex);
        }
        return adjustmentResponse;
    }
    
    @AuraEnabled
    public static Boolean createAdjustmentSA(List<WrapperAdjustment> listAdjustmentSA, AdjustmentInputWrapper objAdjustmentInput, Boolean bRetroStartDateOnly){
        String sCareNewAppId = '';
        String sCareEnrollAppId = '';
        Boolean bStatus;
        String sPersonId = '';
        
        try{   
            sPersonId = objAdjustmentInput.sPerId;
            
            //Fetch the user's LANID to stamp as CommittedBy
            Id userId = UserInfo.getUserId();            
            User userDetails = [SELECT Id, Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];
            
            sCareNewAppId = createcareAppRecord(listAdjustmentSA, objAdjustmentInput, userDetails);
            sCareEnrollAppId = createcareAppEnrolledSARecord(sCareNewAppId, listAdjustmentSA, objAdjustmentInput, bRetroStartDateOnly, userDetails);
            
            bStatus = true;            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, '', '', sPersonId, ex);
        }
        return bStatus ;
    }
    
    /******************************************PUBLIC METHODS*************************************** */     
    
    /******************************************PRIVATE METHODS*************************************** */ 
    
    private static string createcareAppRecord(List<WrapperAdjustment> listAdjustmentSA, AdjustmentInputWrapper objAdjustmentInput, User userDetails){
        string careNewAppId = '';
        String sPersonId = '';
        
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
               
        
        //get the cc code details for Adjustment
        listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ADJUSTMENT, null, null);
        
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        sPersonId = objAdjustmentInput.sPerId;
        //create CARE APP Transaction record
        CARE_Application__c careAppObj = new CARE_Application__c();
        careAppObj.RecordTypeId = careAppRecTypeId;
        careAppObj.APPLICANT_NAME__c = listAdjustmentSA[0].sApplicantName;
        careAppObj.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
        careAppObj.ENROLLMENT_TYPE__c = 'OTHER';        
        careAppObj.PROCESSED_DATE__c = dTodaysDate;
        careAppObj.PER_ID__c = objAdjustmentInput.sPerId; 
        careAppObj.CARE_Account_ID__c = listAdjustmentSA[0].idAccountID;
        careAppObj.ACCT_ID__c = listAdjustmentSA[0].sBillingAccountId;
        careAppObj.CCB_Contact_Type_No__c = CARE_Constants.CARE_CC_ADJUSTMENT;
        careAppObj.CCB_CONTACT_CODE__c = listCareType[0].TYPE_CODE__c;
        careAppObj.CCB_CONTACT_DESC__c= listCareType[0].TYPE_DESC__c;
        careAppObj.CCB_CONTACT_COMMENT__c = objAdjustmentInput.sComment; 
        careAppObj.REASON_DESC__c = objAdjustmentInput.sReason; 
        //careAppObj.START_DATE__c = listAdjustmentSA[0].dStartDate;
        //careAppObj.END_DATE__c = listAdjustmentSA[0].dEndDate;
        //careAppObj.APPLICATION_EXTERNAL_ID__c = 'EN'; //EN or PE or BA //Not required, for migration only
        //careAppObj.APPLICATION_TYPE__c = 'Enrollment';     //Enrollment,PEV,Notice,Other //Not required, for migration only
        careAppObj.CC_CL_CD__c = listAdjustmentSA[0].sDiscountType;//This will be Account's discount for stamping
        careAppObj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_ADJUSTMENT_SRC;
        careAppobj.HOUSE_QUALIFY__c = false; //Extra fields
        careAppObj.RECEIVED_DATE__c = dTodaysDate;//Extra fields
        careAppObj.USER_NAME_CARE1__c = (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '';//Extra fields
        careAppObj.RESULT_DATE__c = dTodaysDate;//Extra fields
        
        listCareApp.add(careAppObj);
        
        Database.SaveResult[] srList = Database.insert(listCareApp, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                //System.debug('Successfully inserted careApp after isAdjust clicked--->: ' + sr.getId());
                careNewAppId = sr.getId();
                //System.debug('careNewAppId is--->: ' + careNewAppId);
            }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    //System.debug('The following error has occurred.');                   
                    //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    //System.debug('Account fields that affected this error: ' + err.getFields());
                    
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, new AuraHandledException(err.getMessage())));
					CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, '', '', sPersonId, new AuraHandledException(err.getMessage()));
                }
            }
        }
        return careNewAppId;
    }
    
    private static string createcareAppEnrolledSARecord(String sCareNewAppId, List<WrapperAdjustment> listAdjustmentSA, AdjustmentInputWrapper objAdjustmentInput, Boolean bRetroStartDateOnly, User userDetails){
        string careEnrollAppId = '';
        String sPersonId = '';
        List<CARE_App_Enrolled_SA__c> listCareAppAdjustedSAToInsert = new List<CARE_App_Enrolled_SA__c>();
        
        //get the Last Bill Date
        Date dLastBillDate = CARE_UtilityController.getLastBillDate();
        
        for (WrapperAdjustment objWrapperAdjust : listAdjustmentSA ){
            if(objWrapperAdjust.dRetroStartDate != null || objWrapperAdjust.dRetroEndDate != null){
                CARE_App_Enrolled_SA__c careEnrolledSAObj = new CARE_App_Enrolled_SA__c(); 
                
                sPersonId = objAdjustmentInput.sPerId;
                careEnrolledSAObj.ACCT_ID__c = objWrapperAdjust.sBillingAccountId;
                careEnrolledSAObj.APPLICATION__c = sCareNewAppId;
                careEnrolledSAObj.CC_CL_CD__c = objWrapperAdjust.sDiscountType; //This will be Account's discount for stamping
                careEnrolledSAObj.CCB_CONTACT_TYPE__c = CARE_Constants.CARE_CC_ADJUSTMENT;
                careEnrolledSAObj.PER_ID__c = objAdjustmentInput.sPerId;
                careEnrolledSAObj.PREM_ID__c = objWrapperAdjust.sPremiseId;
                careEnrolledSAObj.SA_ID__c = objWrapperAdjust.sSAId;
                careEnrolledSAObj.START_DATE__c = objWrapperAdjust.dStartDate; 
                careEnrolledSAObj.END_DATE__c = objWrapperAdjust.dEndDate;
                careEnrolledSAObj.SA_START_DATE__c = objWrapperAdjust.dSAStartDate;
                careEnrolledSAObj.Service_Agreement__c = objWrapperAdjust.idSARecID;
                careEnrolledSAObj.RS_CD__c = objWrapperAdjust.sRateSchedule;
                careEnrolledSAObj.RETRO_START_DATE__c = objWrapperAdjust.dRetroStartDate;
                //do not update the Retro End Date if, 'checkbox from UI is checked for 'Yes Start Date Only'
                careEnrolledSAObj.RETRO_END_DATE__c = (bRetroStartDateOnly) ? null : objWrapperAdjust.dRetroEndDate;
                careEnrolledSAObj.ADJUSTED__c = true;//Extra fields
                if(userDetails.Profile.Name == CARE_Constants.CSR_PROFILE){
                    careEnrolledSAObj.CSR_ADJUSTED__c = true;//Extra fields
                	careEnrolledSAObj.CSR_USER__c = userDetails.Id;//Extra fields
                }   
                careEnrolledSAObj.SERVICE_FULL_ADDRESS__c = objWrapperAdjust.sSvcFullAddress;//Extra fields
                careEnrolledSAObj.SERVICE_TYPE_CODE__c = objWrapperAdjust.sSvcTypeCode;//Extra fields
                careEnrolledSAObj.LAST_BILL_DATE__c = (dLastBillDate != null) ? dLastBillDate : dTodaysDate;//Extra fields
                careEnrolledSAObj.SA_ENTITY_NAME__c = objWrapperAdjust.sApplicantName;//Extra fields
                
                listCareAppAdjustedSAToInsert.add(careEnrolledSAObj);
            }
        } 
        
        Database.SaveResult[] srList = Database.insert(listCareAppAdjustedSAToInsert, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                //System.debug('Successfully inserted careAppEnrolledSA with retro dates--->: ' + sr.getId());
                careEnrollAppId = sr.getId();
            }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    //System.debug('The following error has occurred.');                   
                    //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    //System.debug('Account fields that affected this error: ' + err.getFields());
                    
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, new AuraHandledException(err.getMessage())));
					CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER, '', '', sPersonId, new AuraHandledException(err.getMessage()));
                }
            }            
        }        
        return careEnrollAppId;        
    }
    
    /******************************************PRIVATE METHODS*************************************** */ 
}