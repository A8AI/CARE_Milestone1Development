/***********************************************************************************************************   
Apex Util class Name :  CARE_PEVHUController
Version              :  1.0                                                                          
Created Date         :  06/24/2020                                                         
Function             :  This is the Apex Controller for PEV and HU enrollment of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/24/2020            SKMN                   Initial Version.
*                                              CARE Application: 
* 08/28/2020			SKMN				   Updated to stamp extra fields for all applications
* 09/03/2020			SKMN				   Updated Account.PREFERRED_CONTACT_METHOD__c for existing records
****************************************************************************************************************************************/
public class CARE_PEVHUController {
    
    //Constants   
    private Static final Date dTodaysDate = Date.today();    
    public static Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
    
    /******************************************WRAPPER CLASSES*************************************** */
    //Return: PEVHUWrapperResponse for checking customer is PEV or HU
    public class PEVHUWrapperResponse{
        @AuraEnabled public Boolean bIsPEVHUCust{get;set;}
        @AuraEnabled public String sPEVorHU{get;set;}
        @AuraEnabled public String sErrorCode{get;set;}
        @AuraEnabled public String sErrorMessage{get;set;}
        public PEVHUWrapperResponse()
        {
            bIsPEVHUCust = true;
            sPEVorHU = '';
            sErrorCode = '';
            sErrorMessage = '';
        }        
    }
    
    //Param & Return: PEVHUWrapper class for PEV or HU form
    public class PEVHUWrapper{
        /*1.Household Info*/
        @AuraEnabled public Id sId{get;set;}
        @AuraEnabled public String sApplicantName{get;set;}
        @AuraEnabled public Integer iAdultValue{get;set;}
        @AuraEnabled public Integer iChildrenValue{get;set;}
        @AuraEnabled public Integer iNoWithIncome{get;set;}
        @AuraEnabled public Date sProcessDate{get;set;}
        @AuraEnabled public Date sReceiveDate{get;set;}
        @AuraEnabled public Boolean bRequestedDrop{get;set;}
        @AuraEnabled public Boolean bNoAttachment{get;set;}
        @AuraEnabled public String sSourceChannelType{get;set;}
        @AuraEnabled public String sFormCode{get;set;}
        @AuraEnabled public String sCocCode{get;set;}
        @AuraEnabled public String sEmail{get;set;}         
        @AuraEnabled public Decimal iAnnualInc{get;set;}
        @AuraEnabled public Integer iTotalPersons{get;set;}
        @AuraEnabled public Boolean bOnProbation{get;set;}
        @AuraEnabled public Boolean bPevForm{get;set;}
        /*2.Income Info*/
        @AuraEnabled public List<CareHouseholdDetailWrapper> listCareHhDetailWrapper{get;set;}
        /*3.Result 4.Comment*/
        @AuraEnabled public String sApplicationStatus{get;set;}
        @AuraEnabled public Boolean bIsAdjustment{get;set;}
        @AuraEnabled public String sAdjustReasonValue{get;set;}
        @AuraEnabled public String sCcbContactCode{get;set;}
        @AuraEnabled public String sCcbContactDesc{get;set;}
        @AuraEnabled public String sCcbContactComment{get;set;}
        @AuraEnabled public String sProcessNotes{get;set;}    
        /*5.System Info*/        
        @AuraEnabled public String sLastModifiedById{get;set;}
        @AuraEnabled public String sLastModifiedDate{get;set;}
        @AuraEnabled public String sQualifiedBy{get;set;}
        @AuraEnabled public String sEIAccountName{get;set;}
        @AuraEnabled public String sEIAccountId{get;set;} 
        @AuraEnabled public String sAssignedTo{get;set;}
        /*Phone Info*/
        @AuraEnabled public String sHomePhone{get;set;}
        @AuraEnabled public String sWorkPhone{get;set;}
        @AuraEnabled public String sMobilePhone{get;set;}
        
        @AuraEnabled public String sEnrollmentType{get;set;}
        @AuraEnabled public String sPevOrHu{get;set;}
        @AuraEnabled public String sAppIdToCancel{get;set;}
        @AuraEnabled public Boolean bIsSuccess{get;set;}
        
        public PEVHUWrapper(){
            listCareHhDetailWrapper = new List <CareHouseholdDetailWrapper>();
        }  
    }
    
    //CareHouseholdDetailWrapper class for Person Info returned as a result of PEVHUWrapper
    public class CareHouseholdDetailWrapper{
        @AuraEnabled public String sId{get;set;}
        @AuraEnabled public Integer iIncomeIndex{get;set;}
        @AuraEnabled public String sNumber{get;set;}
        @AuraEnabled public String sPersonName{get;set;}
        
        
        
        
        @AuraEnabled public Decimal dEstAnnSal{get;set;}
        @AuraEnabled public String sIncSrcStatus{get;set;}
        @AuraEnabled public Integer iNoDocs{get;set;}
    }
    
    //Return: ResultResp class for response from Save / Verify / Accept
    public class ResultResp{
        @AuraEnabled public string applicationId{get;set;}        
        @AuraEnabled public Boolean bImageCheck{get;set;}
        @AuraEnabled public Boolean bDocCheck{get;set;}
        @AuraEnabled public string sEventName{get;set;}
        @AuraEnabled public string careApplicationStatus{get;set;}
        @AuraEnabled public string ccCode{get;set;}
        @AuraEnabled public string ccCodeDescription{get;set;}
        @AuraEnabled public string careCCLongDescValue{get;set;}        
    }
    
    //Return: VerificationResultResp class for response from flow
    public class VerificationResultResp{
        @AuraEnabled public string ccCode{get;set;}
        @AuraEnabled public string ccCodeDescription{get;set;}
        @AuraEnabled public string ccCodeDescriptionLong{get;set;}
    }
    
    //CareAppSAWrapper class returned as a list of DataTable Wrapper
    public class CareAppSAWrapper{
        @AuraEnabled public Id Id {get;set;}
        @AuraEnabled public String sSaId {get;set;}
        @AuraEnabled public String sSaType {get;set;}
        @AuraEnabled public Date dYesDate {get;set;}
        @AuraEnabled public Date dNoDate {get;set;}
        @AuraEnabled public Date dRStartDate {get;set;}
        @AuraEnabled public Date dREndDate {get;set;}   
        @AuraEnabled public Date dLastBillDate {get;set;}
        @AuraEnabled public Date dCcbSAstartDate {get;set;}   
        @AuraEnabled public String sSvcAdd {get;set;}
        @AuraEnabled public String sRateSchedule {get;set;}
    }
    
    //AdjustmentReasonWrapper class returned as a list of DataTable Wrapper
    public class AdjustmentReasonWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
    
    //Return: DataTableWrapper class for response of Adjustment Reason and SA details
    public class DataTableWrapper{
        /*6.SA Details*/
        @AuraEnabled public List<CareAppSAWrapper> listSA {get;set;}
        /*3.Adjustment picklist*/
        @AuraEnabled public List<AdjustmentReasonWrapper> listAdjustReason {get;set;}
        /*Set this flag if any record has Retro start date or retro End date*/
        @AuraEnabled public Boolean bHavingRetroDates {get;set;}
        
        public DataTableWrapper(){
            listSA = new List <CareAppSAWrapper>();
            listAdjustReason = new List <AdjustmentReasonWrapper>();
            bHavingRetroDates = false;
        }        
    }
    
    //Return: AccountWrapper class for the phone details of the account
    public class AccountWrapper{
        @AuraEnabled public String sHomePhone {get;set;}
        @AuraEnabled public String sWorkPhone {get;set;}
        @AuraEnabled public String sMobilePhone {get;set;}
        @AuraEnabled public String sAccountEmail {get;set;}
    }
    /******************************************WRAPPER CLASSES*************************************** */
    
    /******************************************PUBLIC METHODS*************************************** */    
    
    //This method returns the account email against the account Id
    @AuraEnabled(Cacheable = true)
    public static AccountWrapper getAccountDetails(Id idAcc){   
        List<Account> listAccDet = [SELECT Email_adr_EI__c
                                    FROM Account
                                    WHERE Id =:idAcc];
        
        AccountWrapper accWrapper = new AccountWrapper();
        if(!listAccDet.isEmpty() && listAccDet.size() > 0){
            accWrapper.sAccountEmail = listAccDet[0].Email_adr_EI__c;
        }   
        return accWrapper;
    }
    
    //This method used to return the In-Progress Care application record, or the Care Application record based on Id
    @AuraEnabled(Cacheable = true)
    public static PEVHUWrapper getPevHuData(String sPersonId, String sSelectedAppId, String sLiveCall){
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        PEVHUWrapper wrapperPEVHU = new PEVHUWrapper();
        Id sCareAppId = null;
        Boolean bFreshForm = false;
        String sEnrollmentType = '';
        String sApplicationStatus = '';
        
        try{
            Date dateReceivedDt  = CARE_UtilityController.getReceivedDateSession();
            List<String> listEnrollmentTypes = new List<String>{CARE_Constants.CARE_PEV_HU, CARE_Constants.CARE_PEV};
                String soqlWhereClause;
            if(sSelectedAppId == 'tab'){
                soqlWhereClause = ' PER_ID__c =:sPersonId AND APPLICATION_STATUS__c = \'In-Progress\' AND ENROLLMENT_TYPE__c IN:listEnrollmentTypes Order by CreatedDate desc limit 1';
            }else{
                soqlWhereClause = ' Id=:sSelectedAppId';
            }
            String sSoqlAppQuery = 'SELECT Id, APPLICANT_NAME__c, PER_ID__c, PREM_ID__c, NO_ADULT__c, NO_CHILD__c, NO_WITH_INCOME__c,'
                + ' PROCESSED_DATE__c, RECEIVED_DATE__c, REQUEST_DROP__c, NO_ATTACHMENTS_RECEIVED__c,'
                + ' SOURCE_CHANNEL_TYPE__c, FORM_CODE__c, COC_CODE__c, EMAIL_ADDRESS__c,'
                + ' PHONE_NO__c, ANNUAL_HOUSEHOLD_INCOME__c, Total_Persons_in_Household__c, PEV_FORM__c,'
                + ' APPLICATION_STATUS__c, ENROLLMENT_TYPE__c, ACCT_ID__c, APPLICATION_TYPE__c, On_Probation__c,'
                + ' LastModifiedBy.LAN_ID_EI__c, LastModifiedDate, QUALIFIED_BY__c, Owner_LAN_ID__c, CARE_Account_ID__c, CARE_Account_ID__r.Name,'
                + ' CCB_CONTACT_CODE__c, CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c, REASON_DESC__c, PROCESS_NOTES__c, START_DATE__c, END_DATE__c, IS_ADJUSTMENT__c'
                + ' FROM CARE_Application__c WHERE ' + soqlWhereClause;
            
            listCareApp = Database.query(sSoqlAppQuery);
            
            PEVHUWrapperResponse objCheckPevHu = checkForPEVandHUCustomer(sPersonId);
            if(!listCareApp.isEmpty()){  
                if(sSelectedAppId == 'tab'){
                    sCareAppId = listCareApp[0].Id;
                }
                else{
                    sCareAppId = sSelectedAppId;
                }
                /**Check for PEV or HU form to load**/
                //Call method to check if PEV or HU, if 'Inprogress' and 'tab'??
                sEnrollmentType = (listCareApp[0].ENROLLMENT_TYPE__c != null) ? listCareApp[0].ENROLLMENT_TYPE__c : '';
                sApplicationStatus = (listCareApp[0].APPLICATION_STATUS__c != null) ? listCareApp[0].APPLICATION_STATUS__c : '';
                
                if(sSelectedAppId == 'tab' && sApplicationStatus == CARE_Constants.CARE_IN_PROGRESS){
                    //If match, then return with enrollment type
                    if((objCheckPevHu.sPEVorHU == CARE_Constants.CARE_APP_PEV && sEnrollmentType == CARE_Constants.CARE_PEV) || (objCheckPevHu.sPEVorHU == CARE_Constants.CARE_APP_HU && sEnrollmentType == CARE_Constants.CARE_PEV_HU)){
                        bFreshForm = false;
                        wrapperPEVHU.sEnrollmentType = sEnrollmentType;
                        wrapperPEVHU.sPevOrHu = (sEnrollmentType == CARE_Constants.CARE_PEV) ? CARE_Constants.CARE_APP_PEV : CARE_Constants.CARE_APP_HU; // (Or wrapperPEVHU.sPevOrHu = objCheckPevHu.sPEVorHU; will return same thing)
                    }
                    //If not match and 'tab', then cancel the current application Id, and return blank form with PEV or HU flag
                    else{
                        //cancel the application
                        //Boolean isCancel = CARE_UtilityController.setCancelStatusCareApplication(sCareAppId);
                        //Set flag to return blank form
                        bFreshForm = true;
                        wrapperPEVHU.sPevOrHu = objCheckPevHu.sPEVorHU;
                        wrapperPEVHU.sAppIdToCancel = sCareAppId;
                    }
                }
                //Else not 'In progress' or from 'History' view-->return with enrollment type
                else{
                    bFreshForm = false;
                    wrapperPEVHU.sEnrollmentType = sEnrollmentType;
                    wrapperPEVHU.sPevOrHu = (sEnrollmentType == CARE_Constants.CARE_PEV) ? CARE_Constants.CARE_APP_PEV : CARE_Constants.CARE_APP_HU;                  
                }                
                /**Check for PEV or HU form to load**/
            }
            else{
                //For no records in Care application, it is a fresh form, and call method to check if PEV or HU, return with PEV or HU flag
                bFreshForm = true;                
                wrapperPEVHU.sPevOrHu = objCheckPevHu.sPEVorHU;
            }
            
            if(!bFreshForm && !listCareApp.isEmpty()){
                wrapperPEVHU.sId = listCareApp[0].Id;
                wrapperPEVHU.sApplicantName = (listCareApp[0].APPLICANT_NAME__c != null) ? listCareApp[0].APPLICANT_NAME__c : '';                
                wrapperPEVHU.iAdultValue = (listCareApp[0].NO_ADULT__c != null) ? Integer.valueOf(listCareApp[0].NO_ADULT__c) : 1;
                wrapperPEVHU.iChildrenValue = (listCareApp[0].NO_CHILD__c != null) ? Integer.valueOf(listCareApp[0].NO_CHILD__c) : 0;
                wrapperPEVHU.iNoWithIncome = (listCareApp[0].NO_WITH_INCOME__c != null) ? Integer.valueOf(listCareApp[0].NO_WITH_INCOME__c) : 1;
                //For viewing from History, retrieve the saved processed date, else always populate with today's date from form
                wrapperPEVHU.sProcessDate = (sSelectedAppId == 'tab') ? dTodaysDate : ((listCareApp[0].PROCESSED_DATE__c != null) ? listCareApp[0].PROCESSED_DATE__c : dTodaysDate); 
                    //For viewing from History, retrieve the saved received date (if present, else use processed date), else always populate from session (session if blank, then today's date)
                    wrapperPEVHU.sReceiveDate = (sSelectedAppId == 'tab') ? dateReceivedDt : ((listCareApp[0].RECEIVED_DATE__c != null) ? listCareApp[0].RECEIVED_DATE__c : wrapperPEVHU.sProcessDate);
                        wrapperPEVHU.bRequestedDrop = (listCareApp[0].REQUEST_DROP__c != null) ? listCareApp[0].REQUEST_DROP__c : false;
                wrapperPEVHU.bNoAttachment = (listCareApp[0].NO_ATTACHMENTS_RECEIVED__c != null) ? listCareApp[0].NO_ATTACHMENTS_RECEIVED__c : false;
                wrapperPEVHU.sSourceChannelType = (listCareApp[0].SOURCE_CHANNEL_TYPE__c != null) ? listCareApp[0].SOURCE_CHANNEL_TYPE__c : '';
                wrapperPEVHU.sFormCode = (listCareApp[0].FORM_CODE__c != null) ? listCareApp[0].FORM_CODE__c : '';
                wrapperPEVHU.sCocCode = (listCareApp[0].COC_CODE__c != null) ? listCareApp[0].COC_CODE__c : '';
                wrapperPEVHU.sEmail = (listCareApp[0].EMAIL_ADDRESS__c != null) ? listCareApp[0].EMAIL_ADDRESS__c : '';
                wrapperPEVHU.iAnnualInc = (listCareApp[0].ANNUAL_HOUSEHOLD_INCOME__c != null) ? listCareApp[0].ANNUAL_HOUSEHOLD_INCOME__c : 0;
                wrapperPEVHU.iTotalPersons = (listCareApp[0].Total_Persons_in_Household__c != null) ? Integer.valueOf(listCareApp[0].Total_Persons_in_Household__c) : 0;
                //For viewing from History, retrieve Care_Application.On_Probation, else populate from Care_Application.Account.CARE_ON_PROBATION__c (passed from parent lwc)
                //Handled in lwc
                wrapperPEVHU.bOnProbation = (listCareApp[0].On_Probation__c != null) ? listCareApp[0].On_Probation__c : false;
                wrapperPEVHU.bPevForm = (listCareApp[0].PEV_FORM__c != null) ? listCareApp[0].PEV_FORM__c : false;
                /*Reason*/
                wrapperPEVHU.sApplicationStatus = sApplicationStatus;
                wrapperPEVHU.bIsAdjustment = (listCareApp[0].IS_ADJUSTMENT__c != null) ? listCareApp[0].IS_ADJUSTMENT__c: false;
                wrapperPEVHU.sAdjustReasonValue = (listCareApp[0].REASON_DESC__c != null) ? listCareApp[0].REASON_DESC__c: '';  
                wrapperPEVHU.sCcbContactCode = (listCareApp[0].CCB_CONTACT_CODE__c != null) ? listCareApp[0].CCB_CONTACT_CODE__c : '';
                wrapperPEVHU.sCcbContactDesc = (listCareApp[0].CCB_CONTACT_DESC__c != null) ? listCareApp[0].CCB_CONTACT_DESC__c : '';
                wrapperPEVHU.sCcbContactComment = (listCareApp[0].CCB_CONTACT_COMMENT__c != null) ? listCareApp[0].CCB_CONTACT_COMMENT__c : '';                
                wrapperPEVHU.sProcessNotes = (listCareApp[0].PROCESS_NOTES__c != null) ? listCareApp[0].PROCESS_NOTES__c : '';                
                /*System Information*/
                wrapperPEVHU.sLastModifiedById = (listCareApp[0].LastModifiedBy.LAN_ID_EI__c != null) ? listCareApp[0].LastModifiedBy.LAN_ID_EI__c :'';
                wrapperPEVHU.sLastModifiedDate = (listCareApp[0].LastModifiedDate != null) ? listCareApp[0].LastModifiedDate.format('MM/dd/yyyy', 'America/Los_Angeles') : ''; //this gives  07/27/2020
                //wrapperPEVHU.sLastModifiedDate = (listCareApp[0].LastModifiedDate != null) ? listCareApp[0].LastModifiedDate.format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles') : '';//this gives  07/27/2020 05:50:45
                //wrapperPEVHU.sLastModifiedDate = (listCareApp[0].LastModifiedDate != null) ? listCareApp[0].LastModifiedDate.formatLong() : ''; //this gives  07/27/2020 05:50:45 AM PDT
                //wrapperPEVHU.sLastModifiedDate = (listCareApp[0].LastModifiedDate != null) ? listCareApp[0].LastModifiedDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') : '';//this gives  07/27/2020 11:20:45 AM (not sure about the timezone)
                wrapperPEVHU.sQualifiedBy = (listCareApp[0].QUALIFIED_BY__c != null) ? listCareApp[0].QUALIFIED_BY__c : '';
                wrapperPEVHU.sEIAccountName = (listCareApp[0].CARE_Account_ID__r.Name != null) ? listCareApp[0].CARE_Account_ID__r.Name : '';
                wrapperPEVHU.sEIAccountId = (listCareApp[0].CARE_Account_ID__r.Name != null) ? '/' + listCareApp[0].CARE_Account_ID__c : ''; 
                wrapperPEVHU.sAssignedTo = (listCareApp[0].Owner_LAN_ID__c != null) ? listCareApp[0].Owner_LAN_ID__c : '';
                
                wrapperPEVHU.bIsSuccess = true;
                
                /**Fetch the Household Details with care application Id**/
                wrapperPEVHU.listCareHhDetailWrapper = getCareHouseholdDetail(sCareAppId);
                /**Fetch the Household Details with care application Id**/                
            }
            else{
                wrapperPEVHU.sProcessDate = dTodaysDate;
                wrapperPEVHU.sReceiveDate = dateReceivedDt;
                wrapperPEVHU.bIsSuccess = false;
            }            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, ex);
            
            return null;
        }
        return wrapperPEVHU;
    }
    
    //Method is used to Save/Verify/Accept the PEV or HU record, call the verification flow on verify and accept
    @AuraEnabled
    public static ResultResp submitPEVForm(PEVHUWrapper wrapperObj, List<CareHouseholdDetailWrapper> listCareHhWrapper, String sPersonId, List<String> listPremId, String sActionName, String sCareAppId, string eIAcctId, String billingAccId, Boolean bIsHUForm){
        String sCareAppIdRes = '';
        String sIsAccepted = 'No';
        ResultResp careRes = new ResultResp();
        VerificationResultResp vRes = new VerificationResultResp();        
        careRes.bImageCheck = true;
        careRes.bDocCheck = true;
        careRes.applicationId='';
        careRes.ccCodeDescription='';
        careRes.sEventName = sActionName;
        careRes.careApplicationStatus = '';
        careRes.careCCLongDescValue = '';
        vRes.ccCodeDescription = '';
        vRes.ccCodeDescriptionLong = '';
        try{
            if(sActionName == 'save'){
                sCareAppIdRes = createUpdateCareAppRecord(wrapperObj, sPersonId, listPremId, sCareAppId, eIAcctId, billingAccId, bIsHUForm, sActionName);
                
                List<CARE_Household_Detail__c> listCareHouseholdDet = createUpdateCareHouseholdDet(listCareHhWrapper, sCareAppIdRes, sPersonId);
                
                careRes.applicationId = sCareAppIdRes;
                careRes.ccCode ='';
                careRes.ccCodeDescription ='';
                careRes.careCCLongDescValue ='';
                careRes.careApplicationStatus = CARE_Constants.CARE_IN_PROGRESS;        
            }
            else if(sActionName == 'verify'){
                sIsAccepted = 'No';
                sCareAppIdRes = createUpdateCareAppRecord(wrapperObj, sPersonId, listPremId, sCareAppId, eIAcctId, billingAccId, bIsHUForm, sActionName); 
                List<CARE_Household_Detail__c> listCareHouseholdDet = createUpdateCareHouseholdDet(listCareHhWrapper, sCareAppIdRes, sPersonId);
                if(String.isNotBlank(sCareAppIdRes)){
                    if(checkIfIncomeDocumentAvailable(wrapperObj, sCareAppIdRes)){
                        vRes = runPevHuVerification(sCareAppIdRes, sPersonId,  listPremId, sIsAccepted, bIsHUForm); 
                        
                        careRes.applicationId = sCareAppIdRes;
                        careRes.ccCode = vRes.ccCode;
                        careRes.ccCodeDescription = vRes.ccCodeDescription;
                        careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                        careRes.careApplicationStatus = CARE_Constants.CARE_IN_PROGRESS;          
                    }
                    else{
                        careRes.bDocCheck = false; // Document validation failed
                        careRes.applicationId = sCareAppId;
                    }
                }                
            }
            else if(sActionName == 'accept'){
                sIsAccepted = 'Yes';
                if(String.isNotBlank(sCareAppId)){
                    if(CARE_UtilityController.checkIfImageIDExists(sCareAppId) || CARE_UtilityController.checkIfUploadedImageExists(sCareAppId) ){
                        if(checkIfIncomeDocumentAvailable(wrapperObj, sCareAppId)){
                            //Fetch the phone numbers from Account and update Care Application
                            AccountWrapper accPhoneDetails = getPhoneDetails(eIAcctId);
                            wrapperObj.sHomePhone = accPhoneDetails.sHomePhone;
                            wrapperObj.sWorkPhone = accPhoneDetails.sWorkPhone;
                            wrapperObj.sMobilePhone = accPhoneDetails.sMobilePhone;                        
                            
                            //Update Care Application
                            sCareAppIdRes = createUpdateCareAppRecord(wrapperObj, sPersonId, listPremId, sCareAppId, eIAcctId, billingAccId, bIsHUForm, sActionName);  
                            //Update Care Household Detail
                            List<CARE_Household_Detail__c> listCareHouseholdDet = createUpdateCareHouseholdDet(listCareHhWrapper, sCareAppIdRes, sPersonId);
                            
                            //Run Full Qualification logic
                            vRes = runPevHuVerification(sCareAppIdRes, sPersonId,  listPremId, sIsAccepted, bIsHUForm); 
                            
                            //Update Account Email
                            system.debug('wrapperObj.sEmail-->'+wrapperObj.sEmail);
                            if(wrapperObj.sEmail != null && wrapperObj.sEmail != ''){
                                updateAccountEmail(wrapperObj, sPersonId);
                            }                            
                            
                            careRes.applicationId = sCareAppIdRes;
                            careRes.ccCode = vRes.ccCode;
                            careRes.ccCodeDescription = vRes.ccCodeDescription;
                            careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                            careRes.careApplicationStatus = CARE_Constants.CARE_DECISION_MADE;
                        }
                        else{
                            careRes.bDocCheck = false; // Document validation failed
                            careRes.applicationId = sCareAppId;
                        }
                        
                    }else{
                        careRes.bImageCheck = false; // No image is attached at accept event
                        careRes.applicationId = sCareAppId;
                    }
                }
            }
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, ex);
            
            //throw new AuraHandledException(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString()); 
        }
        
        return careRes; 
    }
    
    //Method to return the list of CARE_App_Enrolled_SA__c data, Adjustment Reason list
    @AuraEnabled(Cacheable = true)
    public static DataTableWrapper getRelatedSA(String sSelectedAppId, String sLiveCall){ 
        DataTableWrapper response = new DataTableWrapper();
        try{
            List<CARE_App_Enrolled_SA__c> saList = [select Id, SA_ID__c, Service_Agreement__r.Svc_Type_Code_EI__c ,SA_START_DATE__c, 
                                                    END_DATE__c, RETRO_START_DATE__c,RETRO_END_DATE__c, LAST_BILL_DATE__c, 
                                                    Service_Agreement__r.SA_Start_Date_EI__c, START_DATE__c, SERVICE_FULL_ADDRESS__c, RS_CD__c   
                                                    from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: sSelectedAppId 
                                                    ORDER BY SA_ID__c];
            
            for(CARE_App_Enrolled_SA__c careEnrolled : saList){
                CareAppSAWrapper obj = new CareAppSAWrapper();
                obj.Id            = careEnrolled.Id;
                obj.sSaId          = careEnrolled.SA_ID__c + ' (' + careEnrolled.Service_Agreement__r.Svc_Type_Code_EI__c + ')';
                obj.sSaType        = careEnrolled.Service_Agreement__r.Svc_Type_Code_EI__c;
                obj.dYesDate       = careEnrolled.START_DATE__c;
                obj.dNoDate        = careEnrolled.END_DATE__c;
                obj.dRStartDate    = careEnrolled.RETRO_START_DATE__c;
                obj.dREndDate      = careEnrolled.RETRO_END_DATE__c;
                obj.dCcbSAstartDate= careEnrolled.SA_START_DATE__c;
                //obj.ccbSAstartDate= careEnrolled.Service_Agreement__r.SA_Start_Date_EI__c;   
                obj.dLastBillDate  = careEnrolled.LAST_BILL_DATE__c;     
                obj.sSvcAdd  = careEnrolled.SERVICE_FULL_ADDRESS__c; 
                obj.sRateSchedule  = careEnrolled.RS_CD__c;             
                
                response.listSA.add(obj);
                
                if(careEnrolled.RETRO_START_DATE__c != null || careEnrolled.RETRO_END_DATE__c != null){
                    response.bHavingRetroDates = true;
                }
            } 
            //get the Adjustment reason list  
            List <String> listAdjustReason = CARE_UtilityController.getReasonList(CARE_Constants.CARE_ADJUSTMENT_RSN_CAT);
            for(String sReasonRec : listAdjustReason){                
                AdjustmentReasonWrapper objAdjustReason = new AdjustmentReasonWrapper ();
                objAdjustReason.label = sReasonRec;
                objAdjustReason.value = sReasonRec;  
                response.listAdjustReason.add(objAdjustReason);
            }
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
        return response;        
    }
    
    //This method is used to delete the Care Household detail record
    @AuraEnabled
    public static Boolean deleteCareHouseholdDet(String sId){
        List<CARE_Household_Member_Income__c> listCareHhInc = new List<CARE_Household_Member_Income__c>();
        List<CARE_Household_Member_IncomeC__c> listCareHhIncC = new List<CARE_Household_Member_IncomeC__c>();
        Boolean bSuccess = true;
        try {            
            List<CARE_Household_Detail__c> listCareHhDet = [SELECT Id, PERSON_NAME__c, EST_ANNUAL_SALARY__c, APPLICATION__c,
                                                            (SELECT Id FROM CARE_Household_Member_Income__r),
                                                            (SELECT Id FROM CARE_Household_Member_IncomeC__r)
                                                            FROM CARE_Household_Detail__c
                                                            WHERE Id =:sId];
            //Set the values of Care App Id and Est Salary
            Id sCareAppId = listCareHhDet[0].APPLICATION__c;
            Decimal dEstAnnSal = listCareHhDet[0].EST_ANNUAL_SALARY__c;
            
            for(CARE_Household_Detail__c hHDet : listCareHhDet){
                if(!hHDet.CARE_Household_Member_Income__r.isEmpty()){
                    listCareHhInc.addAll(hHDet.CARE_Household_Member_Income__r);
                }
                if(!hHDet.CARE_Household_Member_IncomeC__r.isEmpty()){
                    listCareHhIncC.addAll(hHDet.CARE_Household_Member_IncomeC__r);
                }
            }
            
            //Delete child objects in order
            deleteList(listCareHhIncC);
            deleteList(listCareHhInc);
            deleteList(listCareHhDet);
            
            List<CARE_Application__c> listCareApp = [SELECT Id, ANNUAL_HOUSEHOLD_INCOME__c
                                                     FROM CARE_Application__c
                                                     WHERE Id =:sCareAppId];            
            
            
            //Update the Care Application with the updated Annual Household Income
            listCareApp[0].ANNUAL_HOUSEHOLD_INCOME__c = listCareApp[0].ANNUAL_HOUSEHOLD_INCOME__c - dEstAnnSal;
            update listCareApp;
            
            bSuccess = true;
            
        } catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', '', ex);
            bSuccess = false;
            //throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
        return bSuccess;
    }
    
    /******************************************PUBLIC METHODS*************************************** */    
    
    /******************************************PRIVATE METHODS*************************************** */    
    
    //This method returns whether the customer is PEV or HU
    private static PEVHUWrapperResponse checkForPEVandHUCustomer(String sPersonId){
        PEVHUWrapperResponse wrapperPEVHUResp = new PEVHUWrapperResponse();        
        try{
            Date dLastTwoYrs = dTodaysDate.addYears(-2);
            List<CARE_CC_Batch_Detail__c> listcareCCBatchDet = [SELECT Id, CARE_CI_CC__c, CARE_CI_CC__r.CC_TYPE_CD__c, CC_CL_CD__c, CC_TYPE_CD__c, 
                                                                PER_ID__c, SA_ID__c, CCB_Contact_Type_No__c, CreatedDate, CC_DTTM__c  
                                                                FROM CARE_CC_Batch_Detail__c 
                                                                WHERE PER_ID__c =: sPersonId
                                                                AND CARE_CI_CC__r.CC_TYPE_CD__c IN: CARE_Constants.CARE_CC_CODE_PEV_OR_HU
                                                                AND CC_DTTM__c >=: dLastTwoYrs
                                                                ORDER BY CreatedDate DESC];
            if(listcareCCBatchDet != null && listcareCCBatchDet.size() > 0){
                //PEV or HU customer is present
                wrapperPEVHUResp.bIsPEVHUCust = true;
                wrapperPEVHUResp.sPEVorHU = (listcareCCBatchDet[0].CARE_CI_CC__r.CC_TYPE_CD__c == 'V' || listcareCCBatchDet[0].CARE_CI_CC__r.CC_TYPE_CD__c == 'VE') ? CARE_Constants.CARE_APP_PEV : CARE_Constants.CARE_APP_HU; //fetch the latest CC code
                
            }
            else{
                //No PEV or HU customer
                wrapperPEVHUResp.bIsPEVHUCust = false;
                wrapperPEVHUResp.sPEVorHU = CARE_Constants.CARE_APP_PEV;                
            }            
        }
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, ex);
        }
        return wrapperPEVHUResp;
    }
    
    //Check if every person should have at least one document (if joint filing is selected for one, this restriction is removed for one person)
    private static Boolean checkIfIncomeDocumentAvailable(PEVHUWrapper wrapperObj, Id idCareApplication){
        List<CareHouseholdDetailWrapper> listCareHouseholdDetailWrapper =  new List<CareHouseholdDetailWrapper>();
        Map<CARE_Household_Detail__c, List<CARE_Household_Member_Income__c>> mapPerWithDoc = new Map<CARE_Household_Detail__c, List<CARE_Household_Member_Income__c>>();
        Map<CARE_Household_Detail__c, List<CARE_Household_Member_Income__c>> mapPerWithNoDoc = new Map<CARE_Household_Detail__c, List<CARE_Household_Member_Income__c>>();
        List<String> listPerWithJointFiling = new List<String>();
        Boolean bIncomeDocAvailable = true;
        try{      
            //The validations on Income documents should be applied only if Requested drop not true, no attachments not true and PEV form true
            if(!wrapperObj.bRequestedDrop && !wrapperObj.bNoAttachment && wrapperObj.bPevForm){
                
                List<CARE_Household_Detail__c> listCareHouseholdDetail = [SELECT Id, Name, PERSON_NAME__c, APPLICATION__c, EST_ANNUAL_SALARY__c, INCOME_SOURCE_STATUS__c, 
                                                                          (SELECT Id, Name, IS_FILING_JOINTLY__c FROM CARE_Household_Member_Income__r)
                                                                          FROM CARE_Household_Detail__c
                                                                          WHERE APPLICATION__c =:idCareApplication
                                                                          ORDER by Name];
                for(CARE_Household_Detail__c careHouseholdDetail : listCareHouseholdDetail){
                    Integer iNoOfDocs = 0;                
                    List<CARE_Household_Member_Income__c> listDocuments = careHouseholdDetail.CARE_Household_Member_Income__r;
                    iNoOfDocs =  (listDocuments != null && !listDocuments.isEmpty()) ? listDocuments.size() : 0;
                    
                    //Populate a map with persons having documents
                    if(iNoOfDocs > 0){
                        mapPerWithDoc.put(careHouseholdDetail, listDocuments);
                    }
                    else{
                        //Populate a map with persons having no documents
                        mapPerWithNoDoc.put(careHouseholdDetail, listDocuments);
                    }           
                }            
                //Loop over map values for map with person having document, and check which person has atleast one record with joint filing checked
                for(List<CARE_Household_Member_Income__c> lst: mapPerWithDoc.values()){
                    for(CARE_Household_Member_Income__c inc : lst){
                        if(inc.IS_FILING_JOINTLY__c){
                            listPerWithJointFiling.add(inc.Name);
                            break;
                        }                    
                    }
                }
                //If any person has no document and that is equal to the no. of person having if filing checked true, then success
                if(mapPerWithNoDoc != null && (mapPerWithNoDoc.keyset().size() > 0) && (mapPerWithNoDoc.keyset().size() > listPerWithJointFiling.size())){
                    bIncomeDocAvailable = false;
                    //return false;
                }
                else{
                    bIncomeDocAvailable = true;
                    //return true;
                }   
            }
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', '', ex);
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        } 
        return bIncomeDocAvailable;
    }
    
    //This method returns the list of HouseholdDetail against the Care application Id
    private static List<CareHouseholdDetailWrapper> getCareHouseholdDetail(Id idCareApplication){
        List<CareHouseholdDetailWrapper> listCareHouseholdDetailWrapper =  new List<CareHouseholdDetailWrapper>();
        try{            
            List<CARE_Household_Detail__c> listCareHouseholdDetail = [SELECT Id, Name, PERSON_NAME__c, APPLICATION__c, EST_ANNUAL_SALARY__c, INCOME_SOURCE_STATUS__c, 
                                                                      (SELECT Id, IS_FILING_JOINTLY__c FROM CARE_Household_Member_Income__r)
                                                                      FROM CARE_Household_Detail__c
                                                                      WHERE APPLICATION__c =:idCareApplication
                                                                      ORDER by Name];
            for(CARE_Household_Detail__c careHouseholdDetail : listCareHouseholdDetail){
                CareHouseholdDetailWrapper careHouseholdDetailWrap =  new CareHouseholdDetailWrapper();
                careHouseholdDetailWrap.sId = careHouseholdDetail.Id;
                careHouseholdDetailWrap.sPersonName = careHouseholdDetail.PERSON_NAME__c;
                careHouseholdDetailWrap.dEstAnnSal = careHouseholdDetail.EST_ANNUAL_SALARY__c;
                careHouseholdDetailWrap.sIncSrcStatus = careHouseholdDetail.INCOME_SOURCE_STATUS__c;
                
                List<CARE_Household_Member_Income__c> listDocuments = careHouseholdDetail.CARE_Household_Member_Income__r;
                careHouseholdDetailWrap.iNoDocs =  (listDocuments != null && !listDocuments.isEmpty()) ? listDocuments.size() : 0;
                
                listCareHouseholdDetailWrapper.add(careHouseholdDetailWrap);
                
            }
            return listCareHouseholdDetailWrapper;
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', '', ex);
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
    }
    
    //This method is used to save the Care application
    private static string createUpdateCareAppRecord(PEVHUWrapper wrapperObj, String sPersonId, List<String> listPremId, string sCareAppId, string eIAcctId, String billingAccId, Boolean bIsHUForm, String sActionName){
        String careAppIdResp;
        CARE_Application__c caObj = new CARE_Application__c();
        List<CARE_Application__c> caRecList = new List<CARE_Application__c>();
        
        //Fetch the user's LANID to stamp as CommittedBy
        Id userId = UserInfo.getUserId();            
        User userDetails = [SELECT Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];       
        
        
        //Check for IsNewEnrollemnt
        Map<String, Boolean> mapIsNewEnrollment = determineisNewEnrollment(sPersonId, '');
        Boolean bIsNewEnrollment = mapIsNewEnrollment.get('bIsNewCustomer') ? true : false;
        
        if(wrapperObj != null){
            caObj.RecordTypeId = careAppRecTypeId;
            caObj.APPLICANT_NAME__c = wrapperObj.sApplicantName;
            caObj.NO_ADULT__c = wrapperObj.iAdultValue;
            caObj.NO_CHILD__c = wrapperObj.iChildrenValue;
            caObj.NO_WITH_INCOME__c = wrapperObj.iNoWithIncome;                       
            caObj.PROCESSED_DATE__c = wrapperObj.sProcessDate;
            caObj.RECEIVED_DATE__c = wrapperObj.sReceiveDate != null ? wrapperObj.sReceiveDate : wrapperObj.sProcessDate;
            caObj.REQUEST_DROP__c = wrapperObj.bRequestedDrop;
            caObj.NO_ATTACHMENTS_RECEIVED__c = wrapperObj.bNoAttachment; 
            caObj.COC_CODE__c = wrapperObj.sCocCode;    
            caObj.PHONE_NO__c = wrapperObj.sMobilePhone;
            caObj.HOME_PHONE_NO__c = wrapperObj.sHomePhone;
            caObj.WORK_PHONE_NO__c = wrapperObj.sWorkPhone;
            caObj.EMAIL_ADDRESS__c = wrapperObj.sEmail;
            caObj.ANNUAL_HOUSEHOLD_INCOME__c = wrapperObj.iAnnualInc;
            caObj.Total_Persons_in_Household__c = wrapperObj.iTotalPersons;   
            caObj.On_Probation__c = wrapperObj.bOnProbation;
            caObj.PEV_FORM__c = wrapperObj.bPevForm;
            caObj.ENROLLMENT_TYPE__c = (bIsHUForm) ? CARE_Constants.CARE_PEV_HU : CARE_Constants.CARE_PEV;
            caObj.CARE_Account_ID__c = eIAcctId != '' ? eIAcctId : '';
            caObj.PER_ID__c = sPersonId != null ? sPersonId : '';   
            caObj.IS_ADJUSTMENT__c = wrapperObj.bIsAdjustment;
            caObj.REASON_DESC__c = wrapperObj.sAdjustReasonValue;
            caObj.PROCESS_NOTES__c = wrapperObj.sProcessNotes != null ? wrapperObj.sProcessNotes : wrapperObj.sAdjustReasonValue;
            caObj.CCB_CONTACT_COMMENT__c = wrapperObj.sCcbContactComment;
            caObj.APPLICATION_STATUS__c = CARE_Constants.CARE_STG_ENR_STATUS_IN_PROGRESS;  
            caObj.IS_NEW_ENROLLMENT__c = bIsNewEnrollment;
            caObj.USER_NAME_CARE1__c = (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '';
            //For insert (sCareAppId is blank), use 'Regular App', else for update don't do anything
            if(String.isBlank(sCareAppId)){
                caObj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_REGULAR_APP;
                //caObj.DOC_RECEIVED_DATE__c = dTodaysDate; //Extra fields:Created Date of application that is, stamp with today's date while insert, else don't do anything leave as-is
            }  
            if(sActionName == 'accept'){
                caObj.RESULT_DATE__c = dTodaysDate;//Extra fields       
            }   
            caObj.ACCT_ID__c = billingAccId != '' ? billingAccId : '';//Extra fields
            
            if(wrapperObj.sReceiveDate != null){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CareSessionCache');
                sessionPart.put('CareEnrollmentReceivedDateSession', wrapperObj.sReceiveDate);
            }
            if(string.isNotBlank(sCareAppId)){
                caObj.Id = sCareAppId;
            }
            
            caRecList.add(caObj);
        }
        if(string.isNotBlank(sCareAppId)){
            //update caRecList;
            Database.SaveResult[] srList = Database.update(caRecList, false);
            careAppIdResp = sCareAppId;
            for (Database.SaveResult sr : srList){
                if (sr.isSuccess()){
                    
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, new AuraHandledException(err.getMessage())));
                        CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, new AuraHandledException(err.getMessage()));
                    }
                }                
            }
        }
        else{
            Database.SaveResult[] srList = Database.insert(caRecList, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    //System.debug('Successfully inserted care AppRecord. App ID: ' + sr.getId());
                    careAppIdResp = sr.getId();                    
                }
                else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : sr.getErrors()) {
                        //System.debug('The following error has occurred.');                   
                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('Fields that affected this error: ' + err.getFields());
                        EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, new AuraHandledException(err.getMessage())));
                        CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, new AuraHandledException(err.getMessage()));
                    }
                    
                }                
            }
        }
        return careAppIdResp;
    }
    
    //This method is used to create or update CareHousehold detail
    private static List<CARE_Household_Detail__c> createUpdateCareHouseholdDet(List<CareHouseholdDetailWrapper> listCareHhWrapper, Id idApplication, String sPersonId){
        List<CARE_Household_Detail__c> listCareHouseholdDet =  new List<CARE_Household_Detail__c>();
        try{
            if(listCareHhWrapper != null && listCareHhWrapper.size() > 0){
                for(CareHouseholdDetailWrapper careHhWrapper : listCareHhWrapper){
                    CARE_Household_Detail__c careHouseholdDet = new CARE_Household_Detail__c();
                    
                    if(String.isNotEmpty(careHhWrapper.sId)){ //For update
                        careHouseholdDet.Id = careHhWrapper.sId;
                    }   
                    if(String.isEmpty(careHhWrapper.sId)){ //For insert
                        careHouseholdDet.APPLICATION__c = idApplication;
                    }
                    careHouseholdDet.PERSON_NAME__c = careHhWrapper.sPersonName;
                    careHouseholdDet.EST_ANNUAL_SALARY__c = careHhWrapper.dEstAnnSal;
                    if(String.isEmpty(careHhWrapper.sId)){ //For insert
                        careHouseholdDet.INCOME_SOURCE_STATUS__c = CARE_Constants.CARE_HH_DET_INC_STS_INVALID;
                    }
                    
                    listCareHouseholdDet.add(careHouseholdDet);
                }                
                upsert listCareHouseholdDet; 
            }
            
        }catch (Exception ex) {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', sPersonId, ex);
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        } 
        
        return listCareHouseholdDet;
    }
    
    //Method that calls either PEV verification flow or HU verification flow
    private static VerificationResultResp runPevHuVerification(String careAppId, String perID, List<String> premID, string sIsAccepted, Boolean bIsHUForm){       
        VerificationResultResp vRes = new VerificationResultResp();     
        String ccCode = '';
        String ccDescription = '';
        String ccDescriptionLong = '';
        Map<String,List<String>> mapInputValues=new Map<String,List<String>>();
        
        try{
            
            
            List<String> isAcceptedList = new List<String>();        
            isAcceptedList.add(sIsAccepted);        
            List<String> listApplicationID = new list<String>();
            listApplicationID.add(careAppId);       
            List<String> listPersonID = new list<String>();
            listPersonID.add(perID);
            
            mapInputValues.put('colCareApplicationIDs_Input',listApplicationID);
            mapInputValues.put('colPremiseIDs_Input',premID);
            mapInputValues.put('colPersonIDs_Input',listPersonID);
            mapInputValues.put('colIsApplicationAccepted_Input',isAcceptedList);
            //System.debug('Application id---->'+listApplicationID);
            //System.debug('Premise id---->'+premID);
            //System.debug('Person id---->'+listPersonID);
            if(bIsHUForm){ //If HU
                Flow.Interview.CARE_HU_Verification_Process_Flow getCodeFlow = new Flow.Interview.CARE_HU_Verification_Process_Flow(mapInputValues);	
                getCodeFlow.start();
                
                ccCode = (String)getCodeFlow.getVariableValue('varCCCode_Output');
                ccDescription = (String)getCodeFlow.getVariableValue('varCCCodeDescription_Output');
                ccDescriptionLong = (String)getCodeFlow.getVariableValue('varCCCodeLongDescription_Output');   
            }
            else{ // If PEV
                Flow.Interview.CARE_PEV_Verification_Process_Flow getCodeFlow = new Flow.Interview.CARE_PEV_Verification_Process_Flow(mapInputValues);	
                getCodeFlow.start();
                
                ccCode = (String)getCodeFlow.getVariableValue('varCCCode_Output');
                ccDescription = (String)getCodeFlow.getVariableValue('varCCCodeDescription_Output');
                ccDescriptionLong = (String)getCodeFlow.getVariableValue('varCCCodeLongDescription_Output');   
            }
            
            vRes.ccCode = ccCode;
            vRes.ccCodeDescription = ccDescription;
            vRes.ccCodeDescriptionLong = ccDescriptionLong;
        }
        catch (Exception ex) {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', perID, ex);
        } 
        return vRes;        
    }
    
    //This method updates the email of the account, when 'accept' button is clicked
    private static void updateAccountEmail(PEVHUWrapper wrapperObj, String sPersonId){
        List<Account> listAccUpdate = new List<Account>();
        
        List<Account> listAccount = [Select Id, Imported_Email_EI__c, Email_adr_EI__c, PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: sPersonId];
        system.debug('wrapperObj.sEmail2-->'+wrapperObj.sEmail);
        if(string.isNotBlank(wrapperObj.sEmail)){
            for(Account acc : listAccount){
                system.debug('wrapperObj.sEmail3-->'+wrapperObj.sEmail);
                acc.Email_adr_EI__c = wrapperObj.sEmail;
                if(string.isBlank(acc.PREFERRED_CONTACT_METHOD__c)){ //This field is a required field, hence update the existing record having blank value
                    acc.PREFERRED_CONTACT_METHOD__c = CARE_Constants.ACC_PREFERRED_CONTACT_DEFAULT;
                }
                listAccUpdate.add(acc);
            }
        }
        if(listAccUpdate.size() > 0){
            update listAccUpdate;
        }
    }
    
    //This method returns the phone numbers against the account Id
    public static AccountWrapper getPhoneDetails(Id idAcc){   
        List<Account> listAccPhone = [SELECT Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c 
                                      FROM Account
                                      WHERE Id =:idAcc];
        
        AccountWrapper accWrapper = new AccountWrapper();
        if(!listAccPhone.isEmpty() && listAccPhone.size() > 0){
            accWrapper.sHomePhone = listAccPhone[0].Bus_Phone_1_EI__c;
            accWrapper.sWorkPhone = listAccPhone[0].Bus_Phone_2_EI__c;
            accWrapper.sMobilePhone = listAccPhone[0].Primary_Contact_Mobile_EI__c;
        }   
        return accWrapper;
    }
    
    //This is a common method to delete any sObject list
    private static void deleteList(List<sObject> sobjList){
        if(sobjList != null && !sobjList.isEmpty()){
            delete sobjList;
        } 
    }
    
    private static Map<String,Boolean> determineisNewEnrollment(String selectedPerId, String sMakeLiveCallDetermine){
        Map<String,Boolean> listResponse = new Map<String,Boolean>(); 
        boolean bIsNewCustomer = false;
        boolean bRequestDrop = true;  
        Date dDateAfterNinetyDays = dTodaysDate.addDays(+90);
        
        Map<String, EI_Site__c> careEISiteMapData = new Map<String, EI_Site__c>();
        try{
            careEISiteMapData = CARE_UtilityController.getActiveSADetailsForPersonId(selectedPerId);
            
            if(careEISiteMapData.size() > 0){
                bRequestDrop = false;
                for(EI_Site__c careEISite : careEISiteMapData.values()){                    
                    if(careEISite.Care_Stop_Date_EI__c != null && careEISite.Care_Stop_Date_EI__c > dTodaysDate && careEISite.Care_Stop_Date_EI__c >= dDateAfterNinetyDays){   
                        bIsNewCustomer = false;
                        break; 
                    }
                }
            }            
            else{
                bIsNewCustomer = true;
            }
            
            listResponse.put('bIsNewCustomer',bIsNewCustomer);
            listResponse.put('bRequestDrop',bRequestDrop);
        }
        catch (Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_EnrollTabController','','',selectedPerId, ex);
        }        
        return listResponse;        
    }
    /******************************************PRIVATE METHODS*************************************** */    
}