/***********************************************************************************************************   
Apex Util class Name :  CARE_EnrollTabController
Version              :  1.0                                                                          
Created Date         :  05/04/2020                                                         
Function             :  This is the Apex COntroller for Enroll Tab of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                        Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/04/2020     Cognizant Technology Solutions                   Initial Version.
*                                                                 CARE Application: 
* 08/28/2020			SKMN				   Updated to stamp extra fields for all applications
* 09/03/2020			SKMN				   Updated Account.PREFERRED_CONTACT_METHOD__c for existing records
****************************************************************************************************************************************/

public class CARE_EnrollTabController {
    
    public static date today = system.today();
    public static Date dDateAfterNinetyDays = today.addDays(+90);
    public static Id currentLoggedInUser = UserInfo.getUserId();
    public static Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
    
    
    @AuraEnabled(Cacheable = true)
    public static DataTableWrapper getRelatedSA(String selectedAppId, String sMakeLiveCall){
        
        //String perIdVal = selectedPerId;
        //system.debug('careAppId: '+ careAppId);
        
        DataTableWrapper response = new DataTableWrapper();
        List<CARE_App_Enrolled_SA__c> saList = [select Id, SA_ID__c, Service_Agreement__r.Svc_Type_Code_EI__c ,SA_START_DATE__c, 
                                                END_DATE__c, RETRO_START_DATE__c,RETRO_END_DATE__c,
                                                LAST_BILL_DATE__c, Service_Agreement__r.SA_Start_Date_EI__c, START_DATE__c  
                                                from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: selectedAppId order by SA_ID__c];
        
        for(CARE_App_Enrolled_SA__c pfs : saList){
            AdjustmentWrapper obj = new AdjustmentWrapper();
            obj.Id            = pfs.Id;
            obj.yesDate       = pfs.START_DATE__c;
            obj.rStartDate    = pfs.RETRO_START_DATE__c;
            obj.rEndDate      = pfs.RETRO_END_DATE__c;
            obj.lastBillDate  = pfs.LAST_BILL_DATE__c;
            obj.ccbSAstartDate= pfs.SA_START_DATE__c;
            //obj.ccbSAstartDate= pfs.Service_Agreement__r.SA_Start_Date_EI__c;
            obj.noDate        = pfs.END_DATE__c;
            obj.saID          = pfs.SA_ID__c;
            obj.saType        = pfs.Service_Agreement__r.Svc_Type_Code_EI__c;
            response.listAdjust.add(obj);
            if(pfs.RETRO_START_DATE__c != null || pfs.RETRO_END_DATE__c != null){
                response.bHavingRetroDates = true;
            }
        }
        
        //get the Transfer reason list  
            List <String> listAdjustReason = CARE_UtilityController.getReasonList('Adjustment Reason');
            for(String sReasonRec : listAdjustReason){
                
             WrapperAdjustReason objAdjustReason = new WrapperAdjustReason ();
             objAdjustReason.label = sReasonRec;
             objAdjustReason.value = sReasonRec;  
             response.listAdjustReason.add(objAdjustReason);
            }
        return response;        
    }
    
    public class AdjustmentWrapper{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public Date rStartDate {get;set;}
        @AuraEnabled
        public Date rEndDate {get;set;}
        
        @AuraEnabled
        public String saID {get;set;}
        @AuraEnabled
        public String saType {get;set;}
        @AuraEnabled
        public Date yesDate {get;set;}
        @AuraEnabled
        public Date noDate {get;set;}
        @AuraEnabled
        public Date lastBillDate {get;set;}
        @AuraEnabled
        public Date ccbSAstartDate {get;set;}
    }
    
    public class WrapperAdjustReason{
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value {get;set;}
    }
    
    public class AccountWrapper{
        @AuraEnabled public String sHomePhone {get;set;}
        @AuraEnabled public String sWorkPhone {get;set;}
        @AuraEnabled public String sMobilePhone {get;set;}
    }
        
    public class DataTableWrapper{
        @AuraEnabled
        public List<AdjustmentWrapper> listAdjust {get;set;}
        @AuraEnabled
        public List<WrapperAdjustReason> listAdjustReason {get;set;}
        @AuraEnabled 
        public Boolean bHavingRetroDates {get;set;}
        
    public DataTableWrapper(){
          listAdjust = new List <AdjustmentWrapper>();
          listAdjustReason = new List <WrapperAdjustReason>();
          bHavingRetroDates = false;
    }

	}
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static Map<String,Date> sendReceivedDate(String sLiveCall){
        Map<String,Date> listDates = new Map<String,date>();
        date dToday = date.today();
        listDates.put('processDateValue', dToday);
        date receivedDate  = CARE_UtilityController.getReceivedDateSession();
        listDates.put('receiveDateValue', receivedDate);
        return listDates;
    }
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static Map<String,Boolean> determineisNewEnrollment(String selectedPerId, String sMakeLiveCallDetermine){
       Map<String,Boolean> listResponse = new Map<String,Boolean>(); 
       boolean bIsNewCustomer = false;
       boolean bRequestDrop = true;  
        system.debug('selectedPerId for isNewEnrollment---->'+selectedPerId);
        
        Map<String, EI_Site__c> careEISiteMapData = new Map<String, EI_Site__c>();
        try{
        careEISiteMapData = CARE_UtilityController.getActiveSADetailsForPersonId(selectedPerId);
        system.debug('careEISiteMapData for is new enrollment: '+ careEISiteMapData);
        date noDateValue;
        
        if(careEISiteMapData.size() > 0){
                bRequestDrop = false;
                //for(string careEISite : careEISiteMapData.keyset()){ 
                for(EI_Site__c careEISite : careEISiteMapData.values()){
                    //if(careEISite.get(careEISite).Care_Stop_Date_EI__c != null && careEISite.get(careEISite).Care_Stop_Date_EI__c > today && careEISite.get(careEISite).Care_Stop_Date_EI__c >= dDateAfterNinetyDays){
                     if(careEISite.Care_Stop_Date_EI__c != null && careEISite.Care_Stop_Date_EI__c > today && careEISite.Care_Stop_Date_EI__c >= dDateAfterNinetyDays){   
                       bIsNewCustomer = false;
                  		break; 
                    }
                }
        }
           
        else{
            bIsNewCustomer = true;
        }
        
        
        /*date noDateValue = [Select END_DATE__c from CARE_App_Enrolled_SA__c
                    where SA_ID__c In: careEISiteMapData.keyset() Order by CreatedDate desc limit 1].END_DATE__c;*/
        listResponse.put('bIsNewCustomer',bIsNewCustomer);
        listResponse.put('bRequestDrop',bRequestDrop);
        }catch (Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_EnrollTabController','','',selectedPerId, ex);
    }
        
        return listResponse;
        
    }
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static List<CARE_Application__c> prePopulatEnrollData(String selectPerId, String sSelectedAppId){
        
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        try{
        String soqlWhereClause;
        if(sSelectedAppId == 'tab'){
            soqlWhereClause = ' PER_ID__c =: selectPerId AND APPLICATION_STATUS__c = \'In-Progress\' AND ENROLLMENT_TYPE__c = \'ENROLLMENT\' Order by CreatedDate desc limit 1';
        }else{
            soqlWhereClause = ' Id=:sSelectedAppId';
        }
        String sSoqlAppQuery = 'Select Id, IS_RECERT__c, NO_ADULT__c, APPLICANT_NAME__c,IS_ADJUSTMENT__c,REASON_DESC__c, APPLICATION_STATUS__c,'
                + 'NO_CHILD__c, IS_SIGNED__c, REQUEST_DROP__c, NEED_NAME_CHANGE__c, RECEIVED_DATE__c, LastModifiedBy.LAN_ID_EI__c, '
                + 'SOURCE_CHANNEL_TYPE__c, PROCESSED_DATE__c, FORM_CODE__c, COC_CODE__c, LIHEAP__c, LastModifiedDate,' 
                + 'MEDICAID_UNDER65__c, MEDICAID_OVER65__c, EMAIL_ADDRESS__c, ANNUAL_HOUSEHOLD_INCOME__c, QUALIFIED_BY__c, CARE_Account_ID__c,'
                + 'FIXED_INCOME__c, WIC__c, CALFRESH_SNAP__c, CALWORKS_TANF__c, HEAD_START_INCOME__c, PREM_ID__c,'
                + 'SSI__c, HEALTHY_FAMILIES__c,PROCESS_NOTES__c, NSLP__c, BUREAU_INDIAN_AFFAIRS__c, CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c'
                + ' from CARE_Application__c where ' + soqlWhereClause;
                        
        System.debug('sSoqlAppQuery==>' + sSoqlAppQuery );
        listCareApp = Database.query(sSoqlAppQuery);
        System.debug('listCareApp---> '+listCareApp);
       }
        catch (Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_EnrollTabController','','',selectPerId, ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }

        
        return listCareApp;
    }
    
    //public CARE_EnrollTabController() {}
    
    //CustomerInfoWrapper class
    public class CustomerInfoWrapper{
        //@AuraEnabled public String sId{get;set;}
        @AuraEnabled public boolean isCertValueCB{get;set;}
        @AuraEnabled public integer adultValue{get;set;}
        @AuraEnabled public integer childrenValue{get;set;}
        @AuraEnabled public boolean isSignedValueCB{get;set;}
        @AuraEnabled public boolean requestDropValueCB{get;set;}
        @AuraEnabled public boolean nncValueCB{get;set;}
        @AuraEnabled public string applicantNameValue{get;set;}
        @AuraEnabled public date receiveDateValue{get;set;}
        @AuraEnabled public date processDateValue{get;set;}
        @AuraEnabled public string channelTypeValue{get;set;}
        @AuraEnabled public string formCodeValue{get;set;}
        @AuraEnabled public string cocCodeValue{get;set;}       
        @AuraEnabled public boolean uHeapValue{get;set;}
        @AuraEnabled public boolean wicValue{get;set;}
        @AuraEnabled public boolean calFreshValue{get;set;}
        @AuraEnabled public boolean calWorkValue{get;set;}
        @AuraEnabled public boolean hsieValue{get;set;}
        @AuraEnabled public boolean ssiValue{get;set;}
        @AuraEnabled public boolean mediFamilyValue{get;set;}
        @AuraEnabled public boolean nslpValue{get;set;}
        @AuraEnabled public boolean boiaValue{get;set;}
        @AuraEnabled public boolean mediUnderValue{get;set;}
        @AuraEnabled public boolean mediOverValue{get;set;}
        @AuraEnabled public String emailValue{get;set;}       
        @AuraEnabled public decimal annualIncValue{get;set;}
        @AuraEnabled public boolean fixedIncValue{get;set;}
        @AuraEnabled public boolean isAdjustValue{get;set;}
        @AuraEnabled public string processNoteValue{get;set;}
        @AuraEnabled public string adjustReasonValue{get;set;}
        @AuraEnabled public string ccbCommentValue{get;set;}
        @AuraEnabled public boolean isDuplicateValue{get;set;}
        @AuraEnabled public boolean isNewEnrollmentValue{get;set;}
        @AuraEnabled public String sHomePhone{get;set;}
        @AuraEnabled public String sWorkPhone{get;set;}
        @AuraEnabled public String sMobilePhone{get;set;}
        //@AuraEnabled public CustomerInfoWrapper customerDetails{get;set;}	
        
    }
    public class finalResult{
        @AuraEnabled
		public string applicationId{get;set;}
        @AuraEnabled
		public string ccCodeDescription{get;set;}
        @AuraEnabled
		public Boolean bImageCheck{get;set;}
        @AuraEnabled
		public string sEventName{get;set;}
        @AuraEnabled
		public string careApplicationStatus{get;set;}
        @AuraEnabled
		public string careCCLongDescValue{get;set;}        
}
    
    public class verificationResult{
        @AuraEnabled
		public string ccCodeDescription{get;set;}
        @AuraEnabled
		public string ccCodeDescriptionLong{get;set;}
    }
    
    @AuraEnabled
    public static finalResult handleButtonClickOnUI(CustomerInfoWrapper MassRecordData, String perID, List<String> premID, String eventName, Boolean isAdjustCheckBox, String appIdCareApplication, string eIAcctId, String billingAccId){
        //Boolean eventType = false;
        String careAppId = '';
        String careAppIdForIsAdjust = '';
        String sCareAppStatus = '';
        String sCareLongDescValue = '';
        String ccDescription = '';
        String ccDescriptionLong = '';
        String sIsAccepted = 'No';
        system.debug('eIAcctId--->'+ eIAcctId);
        system.debug('isAdjustCheckBox--->'+ isAdjustCheckBox);
        system.debug('eventName--->'+ eventName);
        List<finalResult> resList = new List<finalResult>();
        finalResult careRes = new finalResult();
        verificationResult vRes = new verificationResult();
        
        system.debug('eIAcctId is---->'+ eIAcctId);
        
        careRes.bImageCheck = true;
        careRes.applicationId='';
		careRes.ccCodeDescription='';
        careRes.sEventName = eventName;
        careRes.careApplicationStatus = '';
        careRes.careCCLongDescValue = '';
        vRes.ccCodeDescription = '';
        vRes.ccCodeDescriptionLong = '';
        
        List<Account> accUpdateEmailList  = new List<Account>();
        
        try{
        if(eventName == 'save'){
            careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID, appIdCareApplication, eIAcctId, billingAccId, eventName);
            //sCareAppStatus = [select APPLICATION_STATUS__c from CARE_Application__c where Id =: careAppId].APPLICATION_STATUS__c;
                
				careRes.applicationId=careAppId;
				careRes.ccCodeDescription='';
            	careRes.careCCLongDescValue='';
            	careRes.careApplicationStatus = 'In-Progress';
            
        }else if(eventName == 'verify'){
            sIsAccepted = 'No';
            careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId, billingAccId, eventName);          
            vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted); 
            careRes.applicationId=careAppId;
            careRes.ccCodeDescription=vRes.ccCodeDescription;
            careRes.careApplicationStatus = 'In-Progress';
            careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
        } else if(eventName == 'accept'){
            sIsAccepted = 'Yes';
            if(String.isNotBlank(appIdCareApplication)){ 
                if(CARE_UtilityController.checkIfImageIDExists(appIdCareApplication) || CARE_UtilityController.checkIfUploadedImageExists(appIdCareApplication) ){
                    	
                    AccountWrapper accPhoneDetails = getPhoneDetails(eIAcctId);
                        MassRecordData.sHomePhone = accPhoneDetails.sHomePhone;
                        MassRecordData.sWorkPhone = accPhoneDetails.sWorkPhone;
                        MassRecordData.sMobilePhone = accPhoneDetails.sMobilePhone;
                    
                    system.debug('MassRecordData.sMobilePhone--->'+MassRecordData.sMobilePhone);
                    system.debug('MassRecordData.sWorkPhone--->'+MassRecordData.sWorkPhone);
                    system.debug('MassRecordData.sHomePhone--->'+MassRecordData.sHomePhone);
                    
                        careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId, billingAccId, eventName);          
            			vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted);
                    	accUpdateEmailList = updateAccountEmail(MassRecordData, perID);
                    
                        careRes.applicationId=appIdCareApplication;
                        careRes.ccCodeDescription=vRes.ccCodeDescription;
                        careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                        careRes.careApplicationStatus = 'Decision Made';
                   
                }else{
                    careRes.bImageCheck = false; // No any image attached at accept event
                    careRes.applicationId=appIdCareApplication;
                }
            }
            
        }
        }catch (Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_EnrollTabController','','',perID, ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }
        
       return careRes; 
        
        
    }
    
    
    public static string createUpdateCareAppRecord(CustomerInfoWrapper MassRecordData, String perID, List<String> premID, string appIdCareApplication, string eIAcctId, String billingAccId, String eventName){
        String careAppId;
        
        system.debug('Inside createUpdateCareAppRecord method---->:');
        system.debug('MassRecordData:'+ MassRecordData);
        
        CARE_Application__c caObj = new CARE_Application__c();
        List<CARE_Application__c> caRecList = new List<CARE_Application__c>();
        
        Id userId = UserInfo.getUserId();           
        User userDetails = [SELECT Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];
        
        
        //try{ 
        if(MassRecordData != null){
            caObj.RecordTypeId = careAppRecTypeId;
            caObj.IS_RECERT__c = MassRecordData.isCertValueCB;
            caObj.NO_ADULT__c = MassRecordData.adultValue;
            caObj.NO_CHILD__c = MassRecordData.childrenValue;
            caObj.IS_SIGNED__c = MassRecordData.isSignedValueCB;
            caObj.REQUEST_DROP__c = MassRecordData.requestDropValueCB;
            caObj.NEED_NAME_CHANGE__c = MassRecordData.nncValueCB;
            caObj.APPLICANT_NAME__c = MassRecordData.applicantNameValue;
            caObj.RECEIVED_DATE__c = MassRecordData.receiveDateValue != null ? MassRecordData.receiveDateValue : MassRecordData.processDateValue;
            caObj.PROCESSED_DATE__c = MassRecordData.processDateValue;
            caObj.SOURCE_CHANNEL_TYPE__c = MassRecordData.channelTypeValue;
            caObj.FORM_CODE__c = MassRecordData.formCodeValue;
            caObj.COC_CODE__c = MassRecordData.cocCodeValue;
            caObj.APPLICATION_STATUS__c = 'In-Progress';        
            caObj.LIHEAP__c = MassRecordData.uHeapValue;
            caObj.WIC__c = MassRecordData.wicValue;
            caObj.CALFRESH_SNAP__c = MassRecordData.calFreshValue;
            caObj.CALWORKS_TANF__c = MassRecordData.calWorkValue;
            caObj.HEAD_START_INCOME__c = MassRecordData.hsieValue;
            caObj.SSI__c = MassRecordData.ssiValue;
            caObj.HEALTHY_FAMILIES__c = MassRecordData.mediFamilyValue;
            caObj.NSLP__c = MassRecordData.nslpValue;
            caObj.BUREAU_INDIAN_AFFAIRS__c = MassRecordData.boiaValue;
            caObj.MEDICAID_UNDER65__c = MassRecordData.mediUnderValue;
            caObj.MEDICAID_OVER65__c = MassRecordData.mediOverValue;
            caObj.EMAIL_ADDRESS__c = MassRecordData.emailValue;
            caObj.PHONE_NO__c = MassRecordData.sMobilePhone;
            caObj.HOME_PHONE_NO__c = MassRecordData.sHomePhone;
            caObj.WORK_PHONE_NO__c = MassRecordData.sWorkPhone;
            caObj.ANNUAL_HOUSEHOLD_INCOME__c = MassRecordData.annualIncValue;
            caObj.FIXED_INCOME__c = MassRecordData.fixedIncValue;
            caObj.PROCESS_NOTES__c = MassRecordData.processNoteValue != null ? MassRecordData.processNoteValue : MassRecordData.adjustReasonValue;
            caObj.ENROLLMENT_TYPE__c = 'ENROLLMENT';
            caObj.CARE_Account_ID__c = eIAcctId != '' ? eIAcctId : '';
            caObj.PER_ID__c = perID != null ? perID : '';
            caObj.CCB_CONTACT_COMMENT__c = MassRecordData.ccbCommentValue;
            caObj.IS_ADJUSTMENT__c = MassRecordData.isAdjustValue;
            caObj.REASON_DESC__c = MassRecordData.adjustReasonValue;
            caObj.IS_DUPLICATE__c = MassRecordData.isDuplicateValue;
            caObj.IS_NEW_ENROLLMENT__c = MassRecordData.isNewEnrollmentValue;
            caObj.USER_NAME_CARE1__c = (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '';
            system.debug('ca Value: ' + caObj);
            system.debug('firstSetReceivedSessionTemp==>'+ MassRecordData.receiveDateValue);
      
            if(MassRecordData.receiveDateValue != null){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CareSessionCache');
                sessionPart.put('CareEnrollmentReceivedDateSession', MassRecordData.receiveDateValue);
                system.debug('SetReceivedSessionTemp==>'+ MassRecordData.receiveDateValue);
            }
            if(string.isNotBlank(appIdCareApplication)){
                caObj.Id = appIdCareApplication;
            }
            if(String.isBlank(appIdCareApplication)){
                //caObj.DOC_RECEIVED_DATE__c = today; //Extra fields:Created Date of application that is, stamp with today's date while insert, else don't do anything leave as-is
            } 
            if(eventName == 'accept'){
                caObj.RESULT_DATE__c = today;//Extra fields       
            }
            caObj.ACCT_ID__c = billingAccId != '' ? billingAccId : '';//Extra fields
            
            caRecList.add(caObj);
        }
        if(string.isNotBlank(appIdCareApplication)){
          Database.SaveResult[] srList = Database.update(caRecList, false);
            careAppId = appIdCareApplication;
        }else{
        Database.SaveResult[] srList = Database.insert(caRecList, false);
        
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted care AppRecord. App ID: ' + sr.getId());
                careAppId = sr.getId();
                
            }
            else {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Care App fields that affected this error: ' + err.getFields());
                }
            }
            
        }
      }
        return careAppId;
    }
    
    public static verificationResult GetCCCode(String careAppId, String perID, List<String> premID, string sIsAccepted){
       
        verificationResult vRes = new verificationResult();
        
        
        System.debug('Inside GetCCCode method------>');
        String ccDescription = '';
        String ccDescriptionLong = '';
        Map<string,List<string>> mapInputValues=new Map<string,List<string>>();
        List<String> isAcceptedList = new List<String>();
        
        try{
        isAcceptedList.add(sIsAccepted);
        
        List<string> listApplicationID =new list<string>();
        listApplicationID.add(careAppId);       
        List<string> listPersonID =new list<string>();
        listPersonID.add(perID);
        
        mapInputValues.put('colCareApplicationIDs_Input',listApplicationID);
        mapInputValues.put('colPremiseIDs_Input',premID);
        mapInputValues.put('colPersonIDs_Input',listPersonID);
        mapInputValues.put('colIsApplicationAccepted_Input',isAcceptedList);
        System.debug('Application id---->'+listApplicationID);
         System.debug('Premise id---->'+premID);
         System.debug('Person id---->'+listPersonID);
        Flow.Interview.CARE_FullQualificationProcess_Flow getCodeFlow =new Flow.Interview.CARE_FullQualificationProcess_Flow(mapInputValues);	
        getCodeFlow.start();
        
        System.debug('Flow Started---->');
        //String ccCode = (String)getCodeFlow.getVariableValue('varResultCCCode_Output');
        ccDescription = (String)getCodeFlow.getVariableValue('varCCCodeDescription_Output');
        ccDescriptionLong = (String)getCodeFlow.getVariableValue('varCCCodeLongDescription_Output');
        //System.debug('CC Code---->'+ccCode);
        System.debug('Description from Flow Returned---->'+ccDescription);
        System.debug('Description Long Returned from Flow---->'+ccDescriptionLong); 
        
        vRes.ccCodeDescription = ccDescription;
        vRes.ccCodeDescriptionLong = ccDescriptionLong;
        
        }catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_EnrollTabController','','',perID, ex);
        }
        return vRes;
    }
    
    public static List<Account> updateAccountEmail(CustomerInfoWrapper MassRecordData, String perID){
        
        system.debug('inside update Account email update method----->');
        
        List<Account> emailUpdateList = new List<Account>();
        List<Account> listUpdateEmail = new List<Account>();
        
        if(string.isNotBlank(MassRecordData.emailValue)){
        	listUpdateEmail = [Select Id, Email_adr_EI__c, PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: perID];
        }
              
            for(Account acc : listUpdateEmail){
                acc.Email_adr_EI__c = MassRecordData.emailValue;
                if(string.isBlank(acc.PREFERRED_CONTACT_METHOD__c)){ //This field is a required field, hence update the existing record having blank value
                    acc.PREFERRED_CONTACT_METHOD__c = CARE_Constants.ACC_PREFERRED_CONTACT_DEFAULT;
                }
                emailUpdateList.add(acc);
            }
            
        if(emailUpdateList.size() > 0){
            system.debug('email updated with value---->'+ emailUpdateList);
            update emailUpdateList;
        }
        return emailUpdateList;
    }
    
    public static AccountWrapper getPhoneDetails(Id idAcc){   
        
        system.debug('inside get phone details method---->');
        List<Account> listAccPhone = [SELECT Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c 
                                      FROM Account
                                      WHERE Id =:idAcc];
        
        AccountWrapper accWrapper = new AccountWrapper();
        if(!listAccPhone.isEmpty() && listAccPhone.size() > 0){
            accWrapper.sHomePhone = listAccPhone[0].Bus_Phone_1_EI__c;
            accWrapper.sWorkPhone = listAccPhone[0].Bus_Phone_2_EI__c;
            accWrapper.sMobilePhone = listAccPhone[0].Primary_Contact_Mobile_EI__c;
        }     
        system.debug('accWrapper-->'+accWrapper);
        return accWrapper;
    }
    
    
}