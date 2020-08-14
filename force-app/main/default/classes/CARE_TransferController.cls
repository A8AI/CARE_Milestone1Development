/***********************************************************************************************************   
Apex Util class Name :  CARE_TransferController
Version              :  1.0                                                                          
Created Date         :  05/27/2020                                                         
Function             :  This is the Apex Controller for Transfer functionality for CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/27/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_TransferController {
    //constant
    Private Static final Date dTodaysDate = Date.today();
    Private Static  Date dHighestEndDate;
    // response Wrapper class for Transfer Section
    public class WrapperTranferResponse{
        @AuraEnabled
        public List<WrapperTransfer> listTransferTo {get;set;}
        @AuraEnabled
        public List<WrapperTransfer> listTransferFrom {get;set;}  
        @AuraEnabled
        public List<WrapperTransferReason> listTransferReason {get;set;}
        @AuraEnabled
        public String sComment {get; set;}
        @AuraEnabled
        public String sContactCode {get; set;}
        
        public WrapperTranferResponse(){
            listTransferFrom = new List <WrapperTransfer>();         
            listTransferTo = new List <WrapperTransfer>();
            listTransferReason = new List <WrapperTransferReason>();
            sComment = '';
            sContactCode = '';
        }
    }
    public class WrapperTransfer{
        @AuraEnabled
        public Id idSARecID {get; set;}
        @AuraEnabled
        public String sAccountId {get; set;}
        @AuraEnabled
        public String sAccId {get; set;}
        @AuraEnabled
        public String sPremiseId {get; set;} 
        @AuraEnabled
        public String sSAId {get; set;}
        @AuraEnabled
        public String sSAType {get; set;}
        @AuraEnabled
        public String sDiscountType {get; set;}
        @AuraEnabled
        public String sSADiscountType {get; set;}
        @AuraEnabled
        public String sAddress {get; set;}
        @AuraEnabled
        public String sSAStatus {get; set;}
        @AuraEnabled
        public String sRateSchedule {get; set;}
        @AuraEnabled
        public Date dEndDate {get; set;}
        @AuraEnabled
        public Date dSAStartDate {get; set;}
        @AuraEnabled
        public Boolean bOverRide {get; set;}
        @AuraEnabled
        public Boolean sSelectedRecord {get; set;}
        @AuraEnabled
        public Boolean bSelectionDisabled {get; set;}
        @AuraEnabled
        public String sApplicantName {get; set;}
    }
    
    public class WrapperTransferReason{
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value {get;set;}
    }
    
    public class WrapperTransferInput{
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sReason{get;set;}
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public String sContactCode{get;set;}
    }
    
    
    //Method to get the Tranfer From, Tranfer To && reason section for Transfer modal pop up
    @AuraEnabled
    public static WrapperTranferResponse getTranferDetails (String sPerId){
        
        WrapperTranferResponse transferResponse = new WrapperTranferResponse();
        Date dTodaysDate = Date.today();
        Set<String> sPremId = new Set<String>();
        List<CARE_Type__c> listCareTypeTo = new List<CARE_Type__c>(); 
        List<String>listActiveStatusCode = new List<String>();
        List<String>listValidRateSchedule = new List<String>();
        
        try {            
            //get the cc code details for Transfer Drop            
            listCareTypeTo = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_TRANSFER_TO,null,null);   
            String sDiscountType = CARE_UtilityController.getDiscountType(sPerId);
            listValidRateSchedule = CARE_UtilityController.getCareValidRateSchedule(sDiscountType);
            listActiveStatusCode = CARE_UtilityController.getCareActiveStatusCode();
            //get the Active enrollment list to be shown in Tranfer From Section              
            Map <String, EI_SITE__C> mapActiveSADiscountEnrollment = new Map <String ,EI_SITE__C >();
            mapActiveSADiscountEnrollment = CARE_UtilityController.getActiveSADetailsForPersonId(sPerId); 
            
            if (mapActiveSADiscountEnrollment.size()>0){
            for (EI_SITE__C EISiteActiveRec :mapActiveSADiscountEnrollment.values()){
                
                WrapperTransfer objTransferFrom = new WrapperTransfer ();
                sPremId.add(EISiteActiveRec.Site_Premise_ID_EI__c);
                
                objTransferFrom.idSARecID =  EISiteActiveRec.Id;
                objTransferFrom.sAccountId =  EISiteActiveRec.Billing_Account_ID_EI__c;
                objTransferFrom.sAccId =  EISiteActiveRec.Account_EI__r.Id;
                objTransferFrom.sPremiseId =  EISiteActiveRec.Site_Premise_ID_EI__c;
                objTransferFrom.sSAId =  EISiteActiveRec.SAID_EI__c;
                objTransferFrom.sSAType =  EISiteActiveRec.Svc_Type_Code_EI__c;
                objTransferFrom.sDiscountType =  EISiteActiveRec.Account_EI__r.CARE_DISCOUNT_TYPE__c;
                objTransferFrom.sSADiscountType = EISiteActiveRec.CARE_DISCOUNT_TYPE__c;
                objTransferFrom.dEndDate = EISiteActiveRec.Care_Stop_Date_EI__c;
                objTransferFrom.sRateSchedule = EISiteActiveRec.Rate_Schedule_EI__c; 
                objTransferFrom.dSAStartDate = EISiteActiveRec.SA_Start_Date_EI__c;
                objTransferFrom.sApplicantName = EISiteActiveRec.Imported_Site_Name_EI__c;
                
                transferResponse.listTransferFrom.add(objTransferFrom); 
            }
            
            //get the enrollment list to be shown in Tranfer To section (Active & Inactive SA exluding SA of Premise Id's from TRanfer From Section)
            
            Map <String, EI_SITE__C> mapSAEnrollment = new Map <String ,EI_SITE__C >();
            mapSAEnrollment = CARE_UtilityController.getSADetailsForPersonId(sPerId);
            
            for(EI_Site__c EI_Site_Rec : mapSAEnrollment.values()){
                
                if(!sPremId.contains(EI_Site_Rec.Site_Premise_ID_EI__c)){
                    
                    WrapperTransfer objTransferTo = new WrapperTransfer ();
                    
                    objTransferTo.idSARecID =  EI_Site_Rec.Id;
                    objTransferTo.sAccountId =  EI_Site_Rec.Billing_Account_ID_EI__c;
                    objTransferTo.sAccId =  EI_Site_Rec.Account_EI__r.Id;
                    objTransferTo.sAddress = EI_Site_Rec.Svc_Full_Adr_EI__c;
                    objTransferTo.sPremiseId =  EI_Site_Rec.Site_Premise_ID_EI__c;
                    objTransferTo.sSAId =  EI_Site_Rec.SAID_EI__c;
                    objTransferTo.sSAType =  EI_Site_Rec.Svc_Type_Code_EI__c;                  
                    objTransferTo.sSAStatus = EI_Site_Rec.Svc_Status_Code_EI__c;
                    objTransferTo.sRateSchedule = EI_Site_Rec.Rate_Schedule_EI__c; 
                    objTransferTo.dSAStartDate = EI_Site_Rec.SA_Start_Date_EI__c;               
                    objTransferTo.bOverRide = false; 
                    objTransferTo.sSelectedRecord = false;    
                    //Set UI Slection enable/Disable
                    if (listActiveStatusCode.contains(EI_Site_Rec.Svc_Status_Code_EI__c))//check active SA
                    {                       
                        if(listValidRateSchedule.contains(EI_Site_Rec.Rate_Schedule_EI__c))//check valid rate Schedule
                        {
                            //check if exisitng discount is FERA, then disable the selection for SA  GAS SA Type.
                           if((transferResponse.listTransferFrom[0].sDiscountType == CARE_Constants.CARE_FERA_DISCOUNT_TYPE) && (objTransferTo.sSAType ==CARE_Constants.CARE_GAS_SA_TYPE)){
                                objTransferTo.bSelectionDisabled = true;
                            }
                            else{
                                objTransferTo.bSelectionDisabled = false;    
                            }               
                        }
                        else{
                            objTransferTo.bSelectionDisabled = true;
                        }                    
                    }
                    else{                    
                        objTransferTo.bSelectionDisabled = true;
                    }                    
                    transferResponse.listTransferTo.add(objTransferTo);
                }
            }
            
            //get the Transfer reason list  
            List <String> listTransferReason = CARE_UtilityController.getReasonList(CARE_Constants.CARE_TRANSFER_RSN_CAT);
            for(String sReasonRec : listTransferReason){
                
                WrapperTransferReason objTransferReason = new WrapperTransferReason ();
                objTransferReason.label = sReasonRec;
                objTransferReason.value = sReasonRec;  
                transferResponse.listTransferReason.add(objTransferReason);                        
            }
            
            transferResponse.sComment = listCareTypeTo[0].TYPE_DESC_LONG__c;
            transferResponse.sContactCode = listCareTypeTo[0].TYPE_CODE__c;
        }     
        }
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_TransferController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_TransferController','','',sPerId, ex);
        }
        return transferResponse;
    }    
    
    //Method to save the Tranfer details
    @AuraEnabled
    public static Boolean updateSADetails(List<WrapperTransfer>  listTranferFrom, List<WrapperTransfer>listTranferTo, WrapperTransferInput objTransferInput){
        
        Boolean bStatus;               
        try{
            
            List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSAFrom = new List<CARE_App_Enrolled_SA__c>();
            List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSATo = new List<CARE_App_Enrolled_SA__c>();
            List<CARE_Type__c> listCareTypeFrom = new List<CARE_Type__c>();
            List<CARE_Type__c> listCareTypeTo = new List<CARE_Type__c>();            
            List<Date> listSAFromEndDate = new List <Date>();
            String sTransferFromCCCode = CARE_Constants.CARE_CC_TRANSFER_FROM; 
            String sTransferToCCCode = CARE_Constants.CARE_CC_TRANSFER_TO; 
            String[] sSAListFrom = new String[0];
            String[] sSAListTo = new String[0];
            
            //get the cc code details for Transfer Drop FrOm
            listCareTypeFrom = CARE_UtilityController.getCCCode(sTransferFromCCCode,null,null);
            String sContactComment = listCareTypeFrom[0].TYPE_DESC_LONG__c;
            
            //get the List of SA ID (Transfer From) in a string to save in care App Comment Desc Field
            for ( WrapperTransfer TranferFromObj :listTranferFrom ){
                sSAListFrom.add(TranferFromObj.sSAId);
            }            
            String sTransferFromSA = String.join(sSAListFrom, ', ');
            sContactComment = sContactComment.replace(CARE_Constants.CARE_SA_ID_PLACEHOLDER, sTransferFromSA);
            
            //get RecordType id from constant class
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            //create CARE APP Transaction To end the discounts for the ‘From’ Premise/Premises             
            CARE_Application__c careAppFromObj = new CARE_Application__c();
            
            careAppFromObj.RecordTypeId = careAppRecTypeId;
            careAppFromObj.APPLICANT_NAME__c = listTranferFrom[0].sApplicantName;
            careAppFromObj.APPLICATION_STATUS__c = 'Decision Made';
            careAppFromObj.ENROLLMENT_TYPE__c = 'OTHER';
            careAppFromObj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_TRANSFER_SRC;
            careAppFromObj.PROCESSED_DATE__c  = dTodaysDate;
            careAppFromObj.PER_ID__c = objTransferInput.sPerId; 
            careAppFromObj.CCB_Contact_Type_No__c = sTransferFromCCCode;
            careAppFromObj.CCB_CONTACT_CODE__c = listCareTypeFrom[0].TYPE_CODE__c;
            careAppFromObj.CCB_CONTACT_DESC__c= listCareTypeFrom[0].TYPE_DESC__c;
            careAppFromObj.CCB_CONTACT_COMMENT__c = sContactComment;                        
            careAppFromObj.REASON_DESC__c = objTransferInput.sReason;
            careAppFromObj.CARE_Account_ID__c = listTranferFrom[0].sAccId;//EI Account Id
            careAppFromObj.ACCT_ID__c = listTranferFrom[0].sAccountId;//Billing Account 
            careAppFromObj.CC_CL_CD__c = listTranferFrom[0].sDiscountType;
            
            Insert careAppFromObj;            
            
            for ( WrapperTransfer TranferFromObj :listTranferFrom ){
                CARE_App_Enrolled_SA__c careEnrolledSAObj = new CARE_App_Enrolled_SA__c(); 
                
                careEnrolledSAObj.APPLICATION__c = careAppFromObj.Id;
                careEnrolledSAObj.Service_Agreement__c = TranferFromObj.idSARecID;
                careEnrolledSAObj.ACCT_ID__c = TranferFromObj.sAccountId;//Billing Account Id
                careEnrolledSAObj.CC_CL_CD__c = TranferFromObj.sSADiscountType;
                careEnrolledSAObj.CCB_CONTACT_TYPE__c = sTransferFromCCCode;
                careEnrolledSAObj.PER_ID__c = objTransferInput.sPerId;
                careEnrolledSAObj.PREM_ID__c = TranferFromObj.sPremiseId;
                careEnrolledSAObj.RS_CD__c = TranferFromObj.sRateSchedule;
                careEnrolledSAObj.SA_ID__c = TranferFromObj.sSAId;
                careEnrolledSAObj.END_DATE__c = dTodaysDate;
                careEnrolledSAObj.SA_START_DATE__c = TranferFromObj.dSAStartDate;                
                careEnrolledSAObj.OVERRIDE_IND__c = listTranferTo[0].bOverRide;
                
                listCareAppEnrolledSAFrom.add(careEnrolledSAObj);
                //add endDates from active SA 
                listSAFromEndDate.add(TranferFromObj.dEndDate);
            }           
            Insert listCareAppEnrolledSAFrom;
            
            //get the highest end date from Active discount section.
            listSAFromEndDate.sort();
            dHighestEndDate = listSAFromEndDate.get(listSAFromEndDate.size()-1);
            
            //get the cc code details for Transfer Drop To
            listCareTypeTo = CARE_UtilityController.getCCCode(sTransferToCCCode,null,null);
            
            //get the List of SA ID (Transfer To) in a string to save in care App Comment Desc
            for ( WrapperTransfer TranferToObj :listTranferTo ){
                sSAListTo.add (TranferToObj.sSAId);
            }            
            String sTransferToObj = String.join(sSAListTo, '; ');
            String sTransferToContactComment = objTransferInput.sComment.replace(CARE_Constants.CARE_SA_ID_PLACEHOLDER, sTransferToObj);
            
            //create CARE APP Transaction To create discounts for the ‘To’ Premise/Premises
            CARE_Application__c careAppToObj = new CARE_Application__c();
            
            careAppToObj.RecordTypeId = careAppRecTypeId;
            careAppToObj.APPLICANT_NAME__c = listTranferFrom[0].sApplicantName;
            careAppToObj.APPLICATION_STATUS__c = 'Decision Made';
            careAppToObj.ENROLLMENT_TYPE__c = 'OTHER';
            careAppToObj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_TRANSFER_SRC;
            careAppToObj.PROCESSED_DATE__c = dTodaysDate;
            careAppToObj.PER_ID__c = objTransferInput.sPerId;   
            careAppToObj.CCB_Contact_Type_No__c = sTransferToCCCode;
            careAppToObj.CCB_CONTACT_CODE__c = listCareTypeTo[0].TYPE_CODE__c;
            careAppToObj.CCB_CONTACT_DESC__c= listCareTypeTo[0].TYPE_DESC__c;
            careAppToObj.CCB_CONTACT_COMMENT__c = sTransferToContactComment;   //objTransferInput.sComment; //Comment updated in Modal      
            careAppToObj.REASON_DESC__c = objTransferInput.sReason;//Reason selected in Modal  
            careAppToObj.CARE_Account_ID__c = listTranferTo[0].sAccId;//EI Account Id
            careAppToObj.ACCT_ID__c = listTranferTo[0].sAccountId;//Billing Account 
            careAppToObj.CC_CL_CD__c = listTranferFrom[0].sDiscountType;//Discount from Transfer From Section
            
            Insert careAppToObj;
            
            for ( WrapperTransfer TranferToObj :listTranferTo ){
                CARE_App_Enrolled_SA__c careEnrolledSAToObj = new CARE_App_Enrolled_SA__c(); 
                
                careEnrolledSAToObj.APPLICATION__c = careAppToObj.Id;
                careEnrolledSAToObj.Service_Agreement__c = TranferToObj.idSARecID;
                careEnrolledSAToObj.ACCT_ID__c = TranferToObj.sAccountId;//Billing Account 
                careEnrolledSAToObj.CC_CL_CD__c = listTranferFrom[0].sDiscountType;//Transferred Discount Type
                careEnrolledSAToObj.CCB_CONTACT_TYPE__c = sTransferToCCCode;
                careEnrolledSAToObj.PER_ID__c = objTransferInput.sPerId;
                careEnrolledSAToObj.PREM_ID__c = TranferToObj.sPremiseId;
                careEnrolledSAToObj.RS_CD__c = TranferToObj.sRateSchedule;
                careEnrolledSAToObj.SA_ID__c = TranferToObj.sSAId;
                careEnrolledSAToObj.START_DATE__c = dTodaysDate;
                careEnrolledSAToObj.END_DATE__c = dHighestEndDate;
                careEnrolledSAToObj.SA_START_DATE__c = TranferToObj.dSAStartDate;    
                careEnrolledSAToObj.OVERRIDE_IND__c = listTranferTo[0].bOverRide;
                
                listCareAppEnrolledSATo.add(careEnrolledSAToObj);
            }            
            Insert listCareAppEnrolledSATo;
            
            bStatus = true;
        }
        catch (Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_TransferController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_TransferController','','',objTransferInput.sPerId, ex);
        }
        return bStatus;
        
    }
    
    
}