/***********************************************************************************************************   
Apex Util class Name :  CARE_OnDemandPEVController
Version              :  1.0                                                                          
Created Date         :  07/03/2020                                                         
Function             :  This is the Apex COntroller for sending On Demand PEV  request for customer.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/03/2020            CTS                   Initial Version.
*                                             CARE Application: 
* 08/28/2020			SKMN				  Updated to stamp extra fields for all applications
**************************************************************************************************************/
public with sharing class CARE_OnDemandPEVController {
    
    /******************************************WRAPPER CLASSES*************************************** */
    //Custom Wrapper class for User List
    public class OnDemandPEVWrapper{
        @AuraEnabled public Boolean bSuccess{get;set;}
        @AuraEnabled public String sErrorCode{get;set;}
        @AuraEnabled public String sErrorMessage{get;set;}
        //@AuraEnabled public String sComment{get;set;}
        //@AuraEnabled public String sContactCode{get;set;}
        public OnDemandPEVWrapper()
        {
            bSuccess = true;
            sErrorCode = '';
            sErrorMessage = '';
            //sComment = '';
            //sContactCode = '';
        }        
    } 
    
    public class OnDemandPEVWrapperReq{
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sAccId{get;set;}
        @AuraEnabled public String sBillingAccId{get;set;}
        @AuraEnabled public String sApplicantName{get;set;}         
    }   
    
    /******************************************WRAPPER CLASSES*************************************** */
    
    
    /******************************************PUBLIC METHODS*************************************** */
    @AuraEnabled
    public static OnDemandPEVWrapper getCustomerDetails(string sPersonId){
        
		//string sPerId = '4155837704';
		OnDemandPEVWrapper OnDemandPEVWrapper = new OnDemandPEVWrapper();
        //List<CARE_Application__c> listPEVHU = new List<CARE_Application__c>();
        
        //String sSystemValue = [Select SYSTEM_VALUE__c from CARE_System_Value__c where SYSTEM_VALUE_CODE__c = 810 limit 1].SYSTEM_VALUE__c;
		//Integer i = Integer.valueOf(sSystemValue);
        Integer iSystemValue;
        Date dTodaysDate = Date.today();
		Date dDateBeforeFortyFiveDays;
        Map <String, EI_SITE__C> mapValidSAForPerId = new Map <String, EI_SITE__C>();
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>{CARE_Constants.CARE_PEV_SystemValueCode};
        //String sCustomerOnDiscount;
        system.debug('listCareSystemValue-->'+listCareSystemValue);
        try{
            if(listCareSystemValue.size() > 0){
            listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
            system.debug('listGetSystemValue--->'+listGetSystemValue);
            }
            
            if(listGetSystemValue.size() > 0){
                for(CARE_System_Value__c careSystemRecord : listGetSystemValue){
                    if(careSystemRecord.SYSTEM_VALUE_CODE__c == CARE_Constants.CARE_PEV_SystemValueCode){
                        iSystemValue = Integer.valueOf(careSystemRecord.SYSTEM_VALUE__c);
                        system.debug('iSystemValue--->'+iSystemValue);
                    }
                } 
            }else{
                iSystemValue = CARE_Constants.CARE_FortyFiveDay;
            }
            dDateBeforeFortyFiveDays = dTodaysDate.addDays(-iSystemValue);
            
        mapValidSAForPerId = CARE_UtilityController.getActiveSADetailsForPersonId(sPersonId);
        List<CARE_CC_Batch_Detail__c> listCareCCBatchForCust = [select Id, CARE_CI_CC__r.CC_DTTM__c, CARE_CI_CC__r.CC_TYPE_CD__c from CARE_CC_Batch_Detail__c
                                              					where PER_ID__c =: sPersonId];
        
        
        /*List<CARE_Application__c> listCareCust = [select Id, CCB_CONTACT_CODE__c, CreatedDate from CARE_Application__c
                                              where PER_ID__c =: sPersonId];*/ 
        
        system.debug('mapValidSAForPerId size--->'+ mapValidSAForPerId.size());
        system.debug('listCareCCBatchForCust size--->'+ listCareCCBatchForCust.size());
        
        /*if(listCareCust.size() > 0){
            for(CARE_Application__c careApp : listCareCust){
                if(careApp.CCB_CONTACT_CODE__c == 'V' || careApp.CCB_CONTACT_CODE__c == 'VH')
                listPEVHU.add(careApp);
                //break;
            }
        }*/
        
            if(mapValidSAForPerId.size() > 0){
          //if(listCareCust.size() > 0){
            for(CARE_CC_Batch_Detail__c carePEV : listCareCCBatchForCust){
                if((carePEV.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_PEV || carePEV.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_HU) && carePEV.CARE_CI_CC__r.CC_DTTM__c >= dDateBeforeFortyFiveDays){
                  OnDemandPEVWrapper.bSuccess = true;
                  break;  
                }else{
                   OnDemandPEVWrapper.bSuccess = false;
                   OnDemandPEVWrapper.sErrorCode = CARE_Constants.CARE_ONDEMANDPEV_ERROR;
                }
            }
        }
        //else if(mapValidSAForPerId.size() <= 0 && listCareCCBatchForCust.size() <= 0){
         else if(mapValidSAForPerId.size() <= 0){
            	OnDemandPEVWrapper.bSuccess = true;
            	//OnDemandPEVWrapper.sErrorCode = CARE_Constants.CARE_ONDEMANDPEV_ERROR;
        }else{
                OnDemandPEVWrapper.bSuccess = false;
                OnDemandPEVWrapper.sErrorCode = CARE_Constants.CARE_ONDEMANDPEV_ERROR;
        }
   }catch(Exception ex){
            //OnDemandPEVWrapper.bSuccess = false;
            //OnDemandPEVWrapper.sErrorCode = CARE_Constants.CARE_ONDEMANDPEV_ERROR;
            //OnDemandPEVWrapper.sErrorMessage = ex.getMessage();
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandPEVController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandPEVController','','',sPersonId, ex);
   }
        
        
		system.debug('OnDemandPEVWrapper.bSuccess--->'+ OnDemandPEVWrapper.bSuccess);        
        return OnDemandPEVWrapper;
        
    }
    
    @AuraEnabled
    public static OnDemandPEVWrapper createTransactionForOnDemandPEV(OnDemandPEVWrapperReq objOnDemandPEV){
        
        system.debug('inside createTransactionForOnDemandPEV method----->');
        
        List<CARE_Type__c> listCareTypeVE = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_PEVOnDemand, null,null);
        List<CARE_Type__c> listCareTypeVHE = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_PEVHighUsageOnDemand, null,null);
        
        Date dTodaysDate = Date.today();
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-2);
        string sCCContactCode = listCareTypeVE[0].TYPE_CODE__c; //'VE';
        OnDemandPEVWrapper OnDemandPEVWrapper = new OnDemandPEVWrapper();
        OnDemandPEVWrapper.bSuccess = false;
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        
        /*List<CARE_Application__c> listCCCodeAssign = [select Id, CCB_CONTACT_CODE__c, CreatedDate from CARE_Application__c
                                                     where PER_ID__c =: objOnDemandPEV.sPerId];*/
        
        try{
        List<CARE_CC_Batch_Detail__c> listCCCodeAssign = [select Id, CARE_CI_CC__r.CC_DTTM__c, CARE_CI_CC__r.CC_TYPE_CD__c, CC_CL_CD__c, APPLICATION__r.CARE_Account_ID__r.CARE_DISCOUNT_TYPE__c
                                                          from CARE_CC_Batch_Detail__c where PER_ID__c =: objOnDemandPEV.sPerId];
            
         List<EI_Site__c> listAcctDiscountType = [select Id, Account_EI__r.CARE_DISCOUNT_TYPE__c
                                                  from EI_Site__c where Account_EI__c =: objOnDemandPEV.sAccId];   
               
        if(listCCCodeAssign.size() > 0){
            for(CARE_CC_Batch_Detail__c objCare : listCCCodeAssign){
                if(objCare.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_HU && objCare.CARE_CI_CC__r.CC_DTTM__c >= dDateBeforeTwoYears){
                  sCCContactCode = listCareTypeVHE[0].TYPE_CODE__c; //'VHE';
                    break;
                }
            }
        }
            system.debug('sCCContactCode value----->'+ sCCContactCode);
            
            //Fetch the user's LANID to stamp as CommittedBy
            Id userId = UserInfo.getUserId();            
            User userDetails = [SELECT Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];
            
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME); 
            
            //Create record in CARE_Application__c
            CARE_Application__c careApp = new CARE_Application__c();   
            careApp.RecordTypeId = careAppRecTypeId;
            careApp.APPLICANT_NAME__c = objOnDemandPEV.sApplicantName;
            careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
            careApp.RECEIVED_DATE__c = dTodaysDate;
            careApp.PROCESSED_DATE__c = dTodaysDate;
            careApp.CC_CL_CD__c = listAcctDiscountType[0].Account_EI__r.CARE_DISCOUNT_TYPE__c;
            careApp.PER_ID__c = objOnDemandPEV.sPerId;
            careApp.CARE_Account_ID__c = objOnDemandPEV.sAccId;
            careApp.ACCT_ID__c = objOnDemandPEV.sBillingAccId;
            careApp.CCB_CONTACT_CODE__c = sCCContactCode;
            careApp.CCB_CONTACT_DESC__c= (sCCContactCode == listCareTypeVHE[0].TYPE_CODE__c) ? listCareTypeVHE[0].TYPE_DESC__c : listCareTypeVE[0].TYPE_DESC__c;
            careApp.CCB_CONTACT_COMMENT__c = (sCCContactCode == listCareTypeVHE[0].TYPE_CODE__c) ? listCareTypeVHE[0].TYPE_DESC_LONG__c : listCareTypeVE[0].TYPE_DESC_LONG__c;
            careApp.CCB_Contact_Type_No__c = (sCCContactCode == listCareTypeVHE[0].TYPE_CODE__c) ? listCareTypeVHE[0].TYPE_NO__c : listCareTypeVE[0].TYPE_NO__c;
        	careApp.ENROLLMENT_TYPE__c = 'OTHER'; //(sCCContactCode == listCareTypeVHE[0].TYPE_CODE__c) ? CARE_Constants.CARE_PEV_HU : CARE_Constants.CARE_PEV; //ENROLLMENT, PEV, PEV NOTICE, OTHER
            //careApp.ENROLLMENT_TYPE__c = 'PEV Receipt';
            //careApp.APPLICATION_EXTERNAL_ID__c = 'EN'; //EN or PE or BA
            careApp.APPLICATION_TYPE__c = CARE_Constants.CARE_PEV;     //Enrollment,PEV,Notice,Other  
            careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_REGULAR_APP;
            careApp.HOUSE_QUALIFY__c = false; //Extra fields
            careApp.USER_NAME_CARE1__c = (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '';//Extra fields  
            careApp.RESULT_DATE__c = dTodaysDate;//Extra fields
            
            listCareApp.add(careApp);
        
        Database.SaveResult[] srList = Database.insert(listCareApp, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted careApp--->: ' + sr.getId());
                OnDemandPEVWrapper.bSuccess = true;
                //careAppId = sr.getId();
                //System.debug('careAppId is--->: ' + careAppId);
            }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('CAre Application fields that affected this error: ' + err.getFields());
                }
            }
        } 
                      
          }catch (Exception ex) {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandPEVController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandPEVController','','',objOnDemandPEV.sPerId, ex);
        }
        
        
        return OnDemandPEVWrapper;
    }

}