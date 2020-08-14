/***********************************************************************************************************   
Apex Util class Name :  CARE_AddElecGasController
Version              :  1.0                                                                          
Created Date         :  06/07/2020                                                         
Function             :  This is the Apex COntroller for adding Electric / Gas discount for CARE customer of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/07/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/
public class CARE_AddElecGasController {
    //Constants 
    Private static final Date dTodaysDate = Date.today();
    
    /******************************************WRAPPER CLASSES*************************************** */
    //Custom Wrapper class for User List
    public class AddElecGasWrapperResponse{
        @AuraEnabled public Boolean bValidCustomer{get;set;}
        @AuraEnabled public Boolean bSuccess{get;set;}
        @AuraEnabled public String sErrorCode{get;set;}
        @AuraEnabled public String sErrorMessage{get;set;}
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public String sContactCode{get;set;}
        @AuraEnabled public List<AddElecGasWrapper> listAddElecGasExisting {get;set;}
        @AuraEnabled public List<AddElecGasWrapper> listAddElecGasNew {get;set;}  
        @AuraEnabled public List<AddElecGasWrapperReason> listAddElecGasReason {get;set;}  
        public AddElecGasWrapperResponse()
        {
            bValidCustomer = true;
            bSuccess = true;
            sErrorCode = '';
            sErrorMessage = '';
            sComment = '';
            sContactCode = '';
            listAddElecGasExisting = new List <AddElecGasWrapper>();         
            listAddElecGasNew = new List <AddElecGasWrapper>();
            listAddElecGasReason = new List <AddElecGasWrapperReason>();
        }        
    } 
    
    public class AddElecGasWrapper{
        @AuraEnabled public Id idSARecID {get; set;}
        @AuraEnabled public String sApplicantName {get; set;}
        @AuraEnabled public String sAccountId {get; set;}
        @AuraEnabled public String sBillingAccountId {get; set;}
        @AuraEnabled public String sPremiseId {get; set;} 
        @AuraEnabled public String sSAId {get; set;}
        @AuraEnabled public String sSAType {get; set;}
        @AuraEnabled public String sDiscountType {get; set;}
        @AuraEnabled public String sSADiscountType {get; set;}
        @AuraEnabled public String sRateSchedule {get; set;}
        @AuraEnabled public String sSAStatus {get; set;}
        @AuraEnabled public Date dStartDate {get; set;}
        @AuraEnabled public Date dEndDate {get; set;}
        @AuraEnabled public Date dSAStartDate {get; set;}
        @AuraEnabled public Boolean sSelectedRecord {get; set;}
    }
    
    public class AddElecGasWrapperReason{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
    public class AddElecGasInputWrapper{
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sReason{get;set;}
        @AuraEnabled public String sComment{get;set;}
        @AuraEnabled public Date dHighestDtOfExistingComm{get;set;}
    }
    
    /******************************************WRAPPER CLASSES*************************************** */
    
    /******************************************PUBLIC METHODS*************************************** */    
    
    //Method to check the customer validity, and return existing discount details and to be changed details
    @AuraEnabled
    public static AddElecGasWrapperResponse getSAListForPerId(String sPersonId){
        Boolean bCARECustomerOnly = true;
        Map<String, EI_Site__c> mapActiveSAEnrollment = new Map<String, EI_Site__c>();
        Map <String, EI_SITE__C> mapActiveSANoDiscEnrollment = new Map <String ,EI_SITE__C >();
        AddElecGasWrapperResponse addElecGasWrapperResp = new AddElecGasWrapperResponse();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        
        try{
            
            //Check if the customer is on CARE discount currently or not. If Customer is currently on FERA discount OR no discount, set flag bValidCustomer as false 
            mapActiveSAEnrollment = CARE_UtilityController.getActiveSADetailsForPersonId(sPersonId);
            if(mapActiveSAEnrollment.isEmpty()){
                bCARECustomerOnly = false;
            }
            else {
                for(EI_Site__c careEISite : mapActiveSAEnrollment.values()){
                    if(careEISite.Account_EI__r != null && careEISite.Account_EI__r.CARE_DISCOUNT_TYPE__c != CARE_Constants.CARE_DEFAULT_RATE_SC){
                        bCARECustomerOnly = false; 
                        break;
                    }
                }
            }
            
            
            //If customer is on FERA or NO discount, throw error, else proceed
            if(!bCARECustomerOnly){
                addElecGasWrapperResp.bValidCustomer = bCARECustomerOnly;
                addElecGasWrapperResp.bSuccess = false;
                addElecGasWrapperResp.sErrorCode = CARE_Constants.CARE_INVALID_CUST_CODE;
                addElecGasWrapperResp.sErrorMessage = CARE_Constants.CARE_INVALID_CUST_MSG;
            }
            else{
                //get the cc code details for Commodity Addition
                listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ADD_ELEC_GAS, null, null);
                
                //get the Active enrollment list to be shown in Existing Section              
                for(EI_Site__c careEISite : mapActiveSAEnrollment.values()){
                    
                    AddElecGasWrapper objAddElecGasWrapper = new AddElecGasWrapper();
                    
                    objAddElecGasWrapper.idSARecID =  careEISite.Id;
                    objAddElecGasWrapper.sApplicantName =  careEISite.Imported_Site_Name_EI__c;
                    objAddElecGasWrapper.sBillingAccountId =  careEISite.Billing_Account_ID_EI__c;
                    objAddElecGasWrapper.sAccountId =  careEISite.Account_EI__r.Id;
                    objAddElecGasWrapper.sPremiseId =  careEISite.Site_Premise_ID_EI__c;
                    objAddElecGasWrapper.sSAId =  careEISite.SAID_EI__c;
                    objAddElecGasWrapper.sSAType =  careEISite.Svc_Type_Code_EI__c;
                    objAddElecGasWrapper.sDiscountType =  careEISite.Account_EI__r.CARE_DISCOUNT_TYPE__c;//Used for stamping
                    objAddElecGasWrapper.sSADiscountType =  careEISite.CARE_DISCOUNT_TYPE__c;//Used for display
                    objAddElecGasWrapper.sRateSchedule = careEISite.Rate_Schedule_EI__c;
                    objAddElecGasWrapper.dEndDate = careEISite.Care_Stop_Date_EI__c;
                    objAddElecGasWrapper.dSAStartDate = careEISite.SA_Start_Date_EI__c;
                    
                    addElecGasWrapperResp.listAddElecGasExisting.add(objAddElecGasWrapper);
                    
                }
                
                //get the enrollment list to be shown in New Section (Active & Inactive SA excluding SA of Premise Id's from Existing Section)  
                mapActiveSANoDiscEnrollment = CARE_UtilityController.getActiveSADetailsWithNoDiscForPersonId(sPersonId);
                
                if(!mapActiveSANoDiscEnrollment.isEmpty()){
                    for(EI_Site__c careEISite : mapActiveSANoDiscEnrollment.values()){
                        
                        AddElecGasWrapper objAddElecGasWrapperNew = new AddElecGasWrapper();
                        
                        objAddElecGasWrapperNew.idSARecID =  careEISite.Id;
                        objAddElecGasWrapperNew.sApplicantName =  careEISite.Imported_Site_Name_EI__c;
                        objAddElecGasWrapperNew.sBillingAccountId =  careEISite.Billing_Account_ID_EI__c;
                        objAddElecGasWrapperNew.sAccountId =  careEISite.Account_EI__r.Id;
                        objAddElecGasWrapperNew.sPremiseId =  careEISite.Site_Premise_ID_EI__c;
                        objAddElecGasWrapperNew.sSAId =  careEISite.SAID_EI__c;
                        objAddElecGasWrapperNew.sSAType =  careEISite.Svc_Type_Code_EI__c;
                        objAddElecGasWrapperNew.sDiscountType =  careEISite.Account_EI__r.CARE_DISCOUNT_TYPE__c;//Used for stamping
                        objAddElecGasWrapperNew.sSADiscountType =  careEISite.CARE_DISCOUNT_TYPE__c;//Used for display
                        objAddElecGasWrapperNew.sSAStatus = careEISite.Svc_Status_Code_EI__c;
                        objAddElecGasWrapperNew.dStartDate = careEISite.Care_Start_Date_EI__c;
                        objAddElecGasWrapperNew.dEndDate = careEISite.Care_Stop_Date_EI__c;
                        objAddElecGasWrapperNew.dSAStartDate = careEISite.SA_Start_Date_EI__c;
                        objAddElecGasWrapperNew.sRateSchedule = careEISite.Rate_Schedule_EI__c;
                        objAddElecGasWrapperNew.sSelectedRecord = false;
                        
                        addElecGasWrapperResp.listAddElecGasNew.add(objAddElecGasWrapperNew);
                    }
                }
                
                
                //get the Add Elec Gas reason list  
                List<String> listAddElecGasReason = CARE_UtilityController.getReasonList(CARE_Constants.CARE_ADD_ELEC_GAS_RSN_CAT);
                for(String sReasonRec : listAddElecGasReason){                    
                    AddElecGasWrapperReason objAddElecGasReason = new AddElecGasWrapperReason();
                    objAddElecGasReason.label = sReasonRec;
                    objAddElecGasReason.value = sReasonRec;  
                    addElecGasWrapperResp.listAddElecGasReason.add(objAddElecGasReason);
                }              
                
                addElecGasWrapperResp.bValidCustomer = bCARECustomerOnly;
                addElecGasWrapperResp.sComment = listCareType[0].TYPE_DESC_LONG__c;
                addElecGasWrapperResp.sContactCode = listCareType[0].TYPE_CODE__c;
                addElecGasWrapperResp.bSuccess = true;
                
            }        
            
        }
        catch (exception ex){            
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADD_ELECGAS_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADD_ELECGAS_CONTROLLER, '', '', sPersonId, ex);
        }
        return addElecGasWrapperResp;
    }
    
    //Method to save the SA for adding electric and gas discounts
    @AuraEnabled
    public static Boolean createElecGasSA(List<AddElecGasWrapper> listAddElecGas, AddElecGasInputWrapper objAddElecGasInput){           
        Boolean bStatus;     
        List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSAFrom = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        String sPersonId = '';
        
        try{
            sPersonId = objAddElecGasInput.sPerId;
            
            //get the cc code details for Commodity Addition
            listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ADD_ELEC_GAS, null, null);
            
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            //create CARE APP Transaction record
            CARE_Application__c careAppObj = new CARE_Application__c();
            
            careAppObj.RecordTypeId = careAppRecTypeId;
            careAppObj.APPLICANT_NAME__c = listAddElecGas[0].sApplicantName;
            careAppObj.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
            careAppObj.ENROLLMENT_TYPE__c = 'OTHER';
            //careAppObj.RECEIVED_DATE__c = dTodaysDate;
            careAppObj.PROCESSED_DATE__c = dTodaysDate;
            careAppObj.PER_ID__c = objAddElecGasInput.sPerId; 
            careAppObj.CARE_Account_ID__c = listAddElecGas[0].sAccountId;
            careAppObj.ACCT_ID__c = listAddElecGas[0].sBillingAccountId;
            careAppObj.CCB_Contact_Type_No__c = CARE_Constants.CARE_CC_ADD_ELEC_GAS;
            careAppObj.CCB_CONTACT_CODE__c = listCareType[0].TYPE_CODE__c;
            careAppObj.CCB_CONTACT_DESC__c= listCareType[0].TYPE_DESC__c;
            careAppObj.CCB_CONTACT_COMMENT__c = objAddElecGasInput.sComment; //listCareType[0].TYPE_DESC_LONG__c;       
            careAppObj.REASON_DESC__c = objAddElecGasInput.sReason; //sReason;
            //careAppObj.START_DATE__c = dTodaysDate; //TBD //Yes date = last billing date or SA start date if last billing date is null 
            //No date = that of the other commodity, but greater one if there are multiple
            //careAppObj.END_DATE__c = objAddElecGasInput.dHighestDtOfExistingComm;
            //careAppObj.APPLICATION_EXTERNAL_ID__c = 'EN'; //EN or PE or BA
            //careAppObj.APPLICATION_TYPE__c = 'Enrollment';     //Enrollment,PEV,Notice,Other 
            careAppObj.CC_CL_CD__c = listAddElecGas[0].sDiscountType; // It will be always 'C', stamp with the Account's discount
            careAppobj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_ADD_ELEC_GAS_SRC;
            
            Insert careAppObj;  
            for (AddElecGasWrapper objAddElecGas : listAddElecGas ){
                CARE_App_Enrolled_SA__c careEnrolledSAObj = new CARE_App_Enrolled_SA__c(); 
                
                careEnrolledSAObj.ACCT_ID__c = objAddElecGas.sBillingAccountId;
                careEnrolledSAObj.APPLICATION__c = careAppObj.Id;
                careEnrolledSAObj.CC_CL_CD__c = objAddElecGas.sDiscountType; // It will be always 'C', stamp with the Account's discount
                careEnrolledSAObj.CCB_CONTACT_TYPE__c = CARE_Constants.CARE_CC_ADD_ELEC_GAS;
                careEnrolledSAObj.PER_ID__c = objAddElecGasInput.sPerId;
                careEnrolledSAObj.PREM_ID__c = objAddElecGas.sPremiseId;
                careEnrolledSAObj.SA_ID__c = objAddElecGas.sSAId;
                careEnrolledSAObj.RS_CD__c = objAddElecGas.sRateSchedule;
                //Yes date = last billing date or SA start date if last billing date is null , else today's date. For now, ignore last billing date
                careEnrolledSAObj.START_DATE__c = (objAddElecGas.dStartDate != null) ? objAddElecGas.dStartDate : dTodaysDate; 
                //No date = that of the other commodity, but greater one if there are multiple
                careEnrolledSAObj.END_DATE__c = objAddElecGasInput.dHighestDtOfExistingComm;
                careEnrolledSAObj.Service_Agreement__c = objAddElecGas.idSARecID;
                careEnrolledSAObj.SA_START_DATE__c = objAddElecGas.dSAStartDate;
                
                listCareAppEnrolledSAFrom.add(careEnrolledSAObj);
                
            }           
            Insert listCareAppEnrolledSAFrom;
            bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false; 
            
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_ADD_ELECGAS_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_ADD_ELECGAS_CONTROLLER, '', '', sPersonId, ex);
        }
        return bStatus;         
    }
    
    /******************************************PUBLIC METHODS*************************************** */  
    
}