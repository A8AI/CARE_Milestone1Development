/***********************************************************************************************************   
Apex Util class Name :  CARE_OnDemandStatusController
Version              :  1.0                                                                          
Created Date         :  06/29/2020                                                         
Function             :  This is the Apex COntroller for On Demand Status of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/29/2020            CTS                   Initial Version.
*                                              CARE Application: 
**************************************************************************************************************/
public with sharing class CARE_OnDemandStatusController {
    
    //Constants 
    Private Static final Date dTodaysDate = Date.today(); 
    
    public class OnDemandStatusListWrapper{
        @AuraEnabled public Id idSARecID {get; set;}
        @AuraEnabled public Id idAccRecID {get; set;}
        @AuraEnabled public String sPerId {get; set;}
        @AuraEnabled public String sPremId {get; set;}
        @AuraEnabled public String dPremId {get; set;}
        @AuraEnabled public String sSAID {get; set;}
        @AuraEnabled public String dSaName {get; set;}
        @AuraEnabled public String saStatus {get; set;}
        @AuraEnabled public String sRate {get; set;}
        @AuraEnabled public String dRateName {get; set;}
        @AuraEnabled public String sSvcType {get; set;}
        @AuraEnabled public String dSvcTypName {get; set;}
        @AuraEnabled public String sSiteName {get; set;}
        @AuraEnabled public Date dYesDate {get; set;}
        @AuraEnabled public Date dNoDate {get; set;}
        @AuraEnabled public string sType {get; set;}
        @AuraEnabled public string sExtId {get; set;}
    }
    
    public class WrapperOnDemandStatusResponse{
        @AuraEnabled public List<OnDemandStatusListWrapper> listOnDemandStatus = new List<OnDemandStatusListWrapper>();
        @AuraEnabled public List<WrapperTransferReason> listTransferReason = new List <WrapperTransferReason>();
        @AuraEnabled public String sCommentTransferWithDrop{get;set;}
        @AuraEnabled public String sCommentTransfer{get;set;}
        @AuraEnabled public Date dTodaysDate{get;set;}
        @AuraEnabled public String sContactCode{get;set;}
        @AuraEnabled public String sProbation{get;set;}
        @AuraEnabled public Boolean bProbation{get;set;}
        
        
        public WrapperOnDemandStatusResponse(){
            listOnDemandStatus = new List<OnDemandStatusListWrapper>();
            listTransferReason = new List<WrapperTransferReason>();
            sCommentTransferWithDrop = '';
            sCommentTransfer = '';
            sContactCode = '';
            bProbation = false;
            sProbation = '';
        }
    }
    
    public class WrapperTransferReason{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
    //Input parameter from UI selected value
    public class OnDemandStatusInputWrapper{
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sReason{get;set;}
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public String sBillAcctId{get;set;}
        @AuraEnabled public String sDiscountType{get;set;}
    }
    
    @AuraEnabled
    public static WrapperOnDemandStatusResponse getSADetails (String sBillingAcctID){
        
        WrapperOnDemandStatusResponse onDemandStatusRecords = new WrapperOnDemandStatusResponse();
        //List<OnDemandStatusListWrapper> listSiteRecords = new List<OnDemandStatusListWrapper>();
        List<CARE_Type__c> listTransferWithDrop = new List<CARE_Type__c>();
        List<CARE_Type__c> listTransfer = new List<CARE_Type__c>();
        String[] sSAList = new String[0];
        string sOnProbation = CARE_Constants.CARE_Customer_Not_OnProbation;
        Boolean bOnProbation = false;
        
        try{
            list<EI_Site__c> siteSADetailList = [select Id, External_ID_EI__c, Svc_Type_Code_EI__c, Billing_Account_ID_EI__c, Account_EI__c, Person_ID_EI__c, SAID_EI__c, Site_Premise_ID_EI__c,
                                                 Svc_Status_Code_EI__c, Rate_Schedule_EI__c, Account_EI__r.CARE_ON_PROBATION__c, Imported_Site_Name_EI__c,
                                                 Account_EI__r.CARE_PROBATION_END_DATE__c, Account_EI__r.CARE_PROBATION_START_DATE__c, Account_EI__r.Id
                                                 from EI_Site__c where Billing_Account_ID_EI__c =: sBillingAcctID];
            
            if(siteSADetailList.size() > 0){
                bOnProbation = CARE_UtilityController.checkCustomerOnProbation(siteSADetailList[0].Person_ID_EI__c);
                if(bOnProbation == true){
                   sOnProbation = CARE_Constants.CARE_Customer_OnProbation; 
                }else{
                   sOnProbation = CARE_Constants.CARE_Customer_Not_OnProbation;
                }
                
            }
            
            
            for(EI_Site__c siteRec : siteSADetailList){
                OnDemandStatusListWrapper objRec = new OnDemandStatusListWrapper();
                objRec.sExtId = siteRec.External_ID_EI__c;
                objRec.idSARecID = siteRec.Id;
                objRec.idAccRecID = siteRec.Account_EI__r.Id;
                objRec.sPerId = siteRec.Person_ID_EI__c;
                objRec.sPremId = siteRec.Site_Premise_ID_EI__c;
                objRec.sSAID = siteRec.SAID_EI__c;
                objRec.saStatus = siteRec.Svc_Status_Code_EI__c;
                objRec.sRate = siteRec.Rate_Schedule_EI__c;
                objRec.sSiteName = siteRec.Imported_Site_Name_EI__c;
                objRec.sSvcType = siteRec.Svc_Type_Code_EI__c;
                objRec.sType = 'SF';
                onDemandStatusRecords.listOnDemandStatus.add(objRec);                
            }
            
            //call the web service..
            List<sObject> webServiceList = new List<sObject>();
            
            if(webServiceList.size() > 0){ // to be changed
                //loop over the data
                //objRec.sType = 'WS';
                /*for(EI_Site__c siteRec : webServiceList){
OnDemandStatusListWrapper objRec = new OnDemandStatusListWrapper();
objRec.idSARecID = siteRec.Id;
objRec.idAccRecID = siteRec.Account_EI__r.Id;
objRec.sPerId = siteRec.Person_ID_EI__c;
objRec.sPremId = siteRec.Site_Premise_ID_EI__c;
objRec.sSAID = siteRec.SAID_EI__c;
objRec.saStatus = siteRec.Svc_Status_Code_EI__c;
objRec.sRate = siteRec.Rate_Schedule_EI__c;
objRec.sSiteName = siteRec.Imported_Site_Name_EI__c;
objRec.sType = 'WS';
onDemandStatusRecords.listOnDemandStatus.add(objRec);                
}*/
            }else{
                for(integer i = 0; i < 3; i++){
                    OnDemandStatusListWrapper objRec = new OnDemandStatusListWrapper();
                    objRec.sExtId = 'Ext'+ i;
                    objRec.idSARecID = null;
                    objRec.idAccRecID = null;
                    objRec.sPerId = '';
                    objRec.sPremId = '';
                    objRec.sSAID = '';
                    objRec.saStatus = '';
                    objRec.sRate = '';
                    objRec.sSiteName = '';
                    objRec.sSvcType = '';
                    objRec.sType = 'DM';
                    onDemandStatusRecords.listOnDemandStatus.add(objRec); 
                }  
            }
            //get the Transfer reason list  
            List <String> listTransferReason = CARE_UtilityController.getReasonList(CARE_Constants.CARE_OnDemandStatus_RSN_CAT);
            for(String sReasonRec : listTransferReason){
                
                WrapperTransferReason objTransferReason = new WrapperTransferReason();
                objTransferReason.label = sReasonRec;
                objTransferReason.value = sReasonRec;  
                onDemandStatusRecords.listTransferReason.add(objTransferReason);
            } 
            
            //get the cc code details for Transfer and Transfer with Drop
            listTransferWithDrop = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_TRANSFER_FROM, null, null);                
            onDemandStatusRecords.sCommentTransferWithDrop = listTransferWithDrop[0].TYPE_DESC_LONG__c;
            onDemandStatusRecords.sContactCode = listTransferWithDrop[0].TYPE_CODE__c;
            
            listTransfer = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_OnDemandTRANSFER, null, null);
            onDemandStatusRecords.sCommentTransfer = listTransfer[0].TYPE_DESC_LONG__c;
            
            for(EI_Site__c siteSAID : siteSADetailList){
                sSAList.add(siteSAID.SAID_EI__c);
            }
            system.debug('sSAList---->'+ sSAList);
            String sTransferSA = String.join(sSAList, '; ');
            
            onDemandStatusRecords.sCommentTransferWithDrop = onDemandStatusRecords.sCommentTransferWithDrop.replace(CARE_Constants.CARE_SA_ID_PLACEHOLDER, sTransferSA);
            onDemandStatusRecords.sCommentTransfer = onDemandStatusRecords.sCommentTransfer.replace(CARE_Constants.CARE_SA_ID_PLACEHOLDER, sTransferSA);
            
            onDemandStatusRecords.sProbation = sOnProbation;
            onDemandStatusRecords.dTodaysDate = dTodaysDate;
            
            
            
        }catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandStatusController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandStatusController','','','', ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        
        return onDemandStatusRecords;
    }
    
    @AuraEnabled
    public static Boolean getDetailsOnButtonClick (List<OnDemandStatusListWrapper> listOnDemandStatus, OnDemandStatusInputWrapper objOnDemandStatusList){
        string careAppId = '';
        string careEnrollSAId = '';
        Boolean bStatus;
        system.debug('Inside button click method------>');
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        try{
            careAppId = createCareAppRecord(listOnDemandStatus, objOnDemandStatusList, careAppRecTypeId);
            careEnrollSAId = createCareEnrolledSA(listOnDemandStatus, objOnDemandStatusList, careAppRecTypeId, careAppId);
            
            bStatus = true;
            system.debug('bStatus--->'+bStatus);
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandStatusController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandStatusController','','','', ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        
        return bStatus;
        
    }
    
    
    public static string createCareAppRecord(List<OnDemandStatusListWrapper> listOnDemandStatus, OnDemandStatusInputWrapper objOnDemandStatusList, Id careAppRecTypeId){
        string careAppId = '';
        
        system.debug('Inside create care app method------>');
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        
        try{
            if(listOnDemandStatus[0].dNoDate > dTodaysDate){
                listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_OnDemandTRANSFER, null, null);
            }else if(listOnDemandStatus[0].dNoDate <= dTodaysDate){
                listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_TRANSFER_FROM, null, null);
            }
            
            //create CARE APP Transaction record
            CARE_Application__c careAppObj = new CARE_Application__c();
            careAppObj.RecordTypeId = careAppRecTypeId;
            careAppObj.APPLICANT_NAME__c = listOnDemandStatus[0].sSiteName;
            careAppObj.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
            careAppObj.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT;
            careAppObj.RECEIVED_DATE__c = dTodaysDate;
            careAppObj.PROCESSED_DATE__c = dTodaysDate;
            careAppObj.PER_ID__c = listOnDemandStatus[0].sPerId; 
            careAppObj.CARE_Account_ID__c = listOnDemandStatus[0].idAccRecID;
            careAppObj.ACCT_ID__c = objOnDemandStatusList.sBillAcctId;
            careAppObj.CCB_CONTACT_CODE__c = listCareType[0].TYPE_CODE__c;
            careAppObj.CCB_CONTACT_DESC__c= listCareType[0].TYPE_DESC__c;
            careAppObj.CCB_Contact_Type_No__c = listCareType[0].TYPE_NO__c;
            careAppObj.CCB_CONTACT_COMMENT__c = objOnDemandStatusList.sComment; 
            careAppObj.REASON_DESC__c = objOnDemandStatusList.sReason; 
            careAppObj.APPLICATION_EXTERNAL_ID__c = 'EN'; //EN or PE or BA
            careAppObj.APPLICATION_TYPE__c = 'Enrollment';     //Enrollment,PEV,Notice,Other 
            careAppObj.CC_CL_CD__c = objOnDemandStatusList.sDiscountType;//This will be Account's discount for stamping
            careAppObj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_TRANSFER_SRC;
            
            listCareApp.add(careAppObj);
            
            Database.SaveResult[] srList = Database.insert(listCareApp, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted careApp--->: ' + sr.getId());
                    careAppId = sr.getId();
                    System.debug('careAppId is--->: ' + careAppId);
                }
                else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandStatusController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandStatusController','','',listOnDemandStatus[0].sPerId, ex);
        }
        
        return careAppId;
        
    }
    
    
    public static string createCareEnrolledSA(List<OnDemandStatusListWrapper> listOnDemandStatus, OnDemandStatusInputWrapper objOnDemandStatusList, Id careAppRecTypeId, string careAppId){
        string careEnrollSAId = '';
        
        system.debug('Inside create care enrolled sa method------>');
        
        List<CARE_App_Enrolled_SA__c> listCareAppAdjustedSAToInsert = new List<CARE_App_Enrolled_SA__c>();
        
        try{
            for (OnDemandStatusListWrapper objWrapperSA : listOnDemandStatus ){
                CARE_App_Enrolled_SA__c careEnrolledSAObj = new CARE_App_Enrolled_SA__c(); 
                
                careEnrolledSAObj.ACCT_ID__c = objOnDemandStatusList.sBillAcctId;
                careEnrolledSAObj.APPLICATION__c = careAppId;
                careEnrolledSAObj.CC_CL_CD__c = objOnDemandStatusList.sDiscountType; //This will be Account's discount for stamping
                careEnrolledSAObj.CCB_CONTACT_TYPE__c = CARE_Constants.CARE_CC_OnDemandTRANSFER;
                careEnrolledSAObj.PER_ID__c = objOnDemandStatusList.sPerId;
                careEnrolledSAObj.PREM_ID__c = (objWrapperSA.dPremId != null) ? objWrapperSA.dPremId : objWrapperSA.sPremId;
                careEnrolledSAObj.SA_ID__c = (objWrapperSA.dSaName != null) ? objWrapperSA.dSaName : objWrapperSA.sSAID;
                careEnrolledSAObj.START_DATE__c = objWrapperSA.dYesDate; 
                careEnrolledSAObj.END_DATE__c = objWrapperSA.dNoDate;
                //careEnrolledSAObj.SA_START_DATE__c = objWrapperAdjust.dSAStartDate;
                careEnrolledSAObj.Service_Agreement__c = objWrapperSA.idSARecID;
                careEnrolledSAObj.SERVICE_TYPE_CODE__c = (objWrapperSA.dSvcTypName!= null) ? objWrapperSA.dSvcTypName : objWrapperSA.sSvcType;
                careEnrolledSAObj.RS_CD__c = (objWrapperSA.dRateName != null) ? objWrapperSA.dRateName : objWrapperSA.sRate;
                //careEnrolledSAObj.RETRO_START_DATE__c = objWrapperAdjust.dRetroStartDate;
                //do not update the Retro End Date if, 'checkbox from UI is checked for 'Yes Start Date Only'
                //careEnrolledSAObj.RETRO_END_DATE__c = (bRetroStartDateOnly) ? null : objWrapperAdjust.dRetroEndDate;
                
                listCareAppAdjustedSAToInsert.add(careEnrolledSAObj);
                
            } 
            
            Database.SaveResult[] srList = Database.insert(listCareAppAdjustedSAToInsert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted careAppEnrolledSA--->: ' + sr.getId());
                    careEnrollSAId = sr.getId();
                    //careAppId = sr.getId();
                }
                else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }            
            }
        }catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_OnDemandStatusController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_OnDemandStatusController','','',objOnDemandStatusList.sPerId, ex);
        }
        return careEnrollSAId;  
        
    }
    
    
    
}