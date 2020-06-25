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
****************************************************************************************************************************************/

public class CARE_EnrollTabController {
    
    public static date today = system.today();
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
                                                //from CARE_App_Enrolled_SA__c where Id =: careAppId order by SA_ID__c];
                                                from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: selectedAppId order by SA_ID__c];
        
        for(CARE_App_Enrolled_SA__c pfs : saList){
            AdjustmentWrapper obj = new AdjustmentWrapper();
            obj.Id            = pfs.Id;
            obj.yesDate       = pfs.START_DATE__c;
            obj.rStartDate    = pfs.RETRO_START_DATE__c;
            obj.rEndDate      = pfs.RETRO_END_DATE__c;
            obj.lastBillDate  = pfs.LAST_BILL_DATE__c;
            //obj.ccbSAstartDate= pfs.Service_Agreement__r.SA_Start_Date_EI__c;
            obj.noDate        = pfs.END_DATE__c;
            obj.saID          = pfs.SA_ID__c;
            obj.saType        = pfs.Service_Agreement__r.Svc_Type_Code_EI__c;
            response.listAdjust.add(obj);
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
        
    public class DataTableWrapper{
        @AuraEnabled
        public List<AdjustmentWrapper> listAdjust {get;set;}
        @AuraEnabled
        public List<WrapperAdjustReason> listAdjustReason {get;set;}
        
    public DataTableWrapper(){
          listAdjust = new List <AdjustmentWrapper>();
          listAdjustReason = new List <WrapperAdjustReason>();
          //sResult = '';
    }

	}
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static Map<String,Date> sendReceivedDate(){
        Map<String,Date> listDates = new Map<String,date>();
        date dToday = date.today();
        listDates.put('processDateValue', dToday);
        date receivedDate  = CARE_UtilityController.getReceivedDateSession();
        listDates.put('receiveDateValue', receivedDate);
        return listDates;
    }
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static date determineisNewEnrollment(String selectedPerId){
        
        Map<String, EI_Site__c> careEISiteMapData = new Map<String, EI_Site__c>();
        careEISiteMapData = CARE_UtilityController.getActiveSADetailsForPersonId(selectedPerId);
        system.debug('careEISiteMapData for is new enrollment: '+ careEISiteMapData);
        
        date noDateValue = [Select END_DATE__c from CARE_App_Enrolled_SA__c
                    where SA_ID__c In: careEISiteMapData.keyset() Order by CreatedDate desc limit 1].END_DATE__c;
        return noDateValue;
        
    }
    
    @AuraEnabled(Cacheable = true)
    //public static List<CARE_Received_Date_Settings__c> sendReceivedDate(){
    public static List<CARE_Application__c> prePopulatEnrollData(String selectPerId, String sSelectedAppId){
        
        List<CARE_Application__c> listCareApp = new List<CARE_Application__c>();
        try{
        String soqlWhereClause;
        if(sSelectedAppId == 'tab'){
            soqlWhereClause = ' PER_ID__c =: selectPerId AND APPLICATION_STATUS__c = \'In-Progress\' Order by CreatedDate desc limit 1';
        }else{
            soqlWhereClause = ' Id=:sSelectedAppId';
        }
        String sSoqlAppQuery = 'Select Id, IS_RECERT__c, NO_ADULT__c, APPLICANT_NAME__c, APPLICATION_STATUS__c,'
                + 'NO_CHILD__c, IS_SIGNED__c, REQUEST_DROP__c, NEED_NAME_CHANGE__c, RECEIVED_DATE__c,'
                + 'SOURCE_CHANNEL_TYPE__c, PROCESSED_DATE__c, FORM_CODE__c, COC_CODE__c, LIHEAP__c,' 
                + 'MEDICAID_UNDER65__c, MEDICAID_OVER65__c, EMAIL_ADDRESS__c, ANNUAL_HOUSEHOLD_INCOME__c,'
                + 'FIXED_INCOME__c, WIC__c, CALFRESH_SNAP__c, CALWORKS_TANF__c, HEAD_START_INCOME__c,'
                + 'SSI__c, HEALTHY_FAMILIES__c,PROCESS_NOTES__c, NSLP__c, BUREAU_INDIAN_AFFAIRS__c, CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c'
                + ' from CARE_Application__c where ' + soqlWhereClause;
                        
        System.debug('sSoqlAppQuery==>' + sSoqlAppQuery );
        listCareApp = Database.query(sSoqlAppQuery);
        System.debug('listCareApp---> '+listCareApp);
       }
        catch (Exception ex){
            
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
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
    public static finalResult handleButtonClickOnUI(CustomerInfoWrapper MassRecordData, String perID, List<String> premID, String eventName, Boolean isAdjustCheckBox, String appIdCareApplication, string eIAcctId){
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
        
        careRes.bImageCheck = true;
        careRes.applicationId='';
		careRes.ccCodeDescription='';
        careRes.sEventName = eventName;
        careRes.careApplicationStatus = '';
        careRes.careCCLongDescValue = '';
        vRes.ccCodeDescription = '';
        vRes.ccCodeDescriptionLong = '';
        
        if(eventName == 'save'){
            careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID, appIdCareApplication, eIAcctId);
            //sCareAppStatus = [select APPLICATION_STATUS__c from CARE_Application__c where Id =: careAppId].APPLICATION_STATUS__c;
                
				careRes.applicationId=careAppId;
				careRes.ccCodeDescription='';
            	careRes.careCCLongDescValue='';
            	careRes.careApplicationStatus = 'In-Progress';
            
        }else if(eventName == 'verify'){
            sIsAccepted = 'No';
            careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId);          
            vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted); 
            careRes.applicationId=careAppId;
            careRes.ccCodeDescription=vRes.ccCodeDescription;
            careRes.careApplicationStatus = 'In-Progress';
            careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
        } else if(eventName == 'accept'){
            sIsAccepted = 'Yes';
            if(String.isNotBlank(appIdCareApplication)){ 
                if(CARE_UtilityController.checkIfImageIDExists(appIdCareApplication) || CARE_UtilityController.checkIfUploadedImageExists(appIdCareApplication) ){
                        careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId);          
            			vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted);
                        careRes.applicationId=appIdCareApplication;
                        careRes.ccCodeDescription=vRes.ccCodeDescription;
                        careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                        careRes.careApplicationStatus = 'Decision Made';
                    
                    /* if(isAdjustCheckBox == true){
                        
                        careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId);          
            			vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted);
                        //careAppIdForIsAdjust = createCareAppAfterIsAdjust(MassRecordData, appIdCareApplication, perID);
                        //createEnrolledSAforIsAdjust(MassRecordData, careAppIdForIsAdjust, appIdCareApplication);
                        //sCareAppStatus = careUpdateAppStatusRevertRetroDates(appIdCareApplication);
                        careRes.applicationId=careAppIdForIsAdjust;
                        careRes.ccCodeDescription=vRes.ccCodeDescription;
                        careRes.careApplicationStatus = 'Decision Made';
                        careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                    }else{
                        careAppId = createUpdateCareAppRecord(MassRecordData, perID, premID,appIdCareApplication, eIAcctId);          
            			vRes = GetCCCode(careAppId, perID,  premID, sIsAccepted);
                        //sCareAppStatus = careUpdateAppStatusRevertRetroDates(appIdCareApplication);
                        
                        careRes.applicationId=appIdCareApplication;
                        careRes.ccCodeDescription=vRes.ccCodeDescription;
                        careRes.careCCLongDescValue = vRes.ccCodeDescriptionLong;
                        careRes.careApplicationStatus = 'Decision Made';
                    }
                   */
                }else{
                    careRes.bImageCheck = false; // No any image attached at accept event
                    careRes.applicationId=appIdCareApplication;
                }
            }
            
        } 
        
       return careRes; 
        
        
    }
    
    
    @AuraEnabled
    public static string createUpdateCareAppRecord(CustomerInfoWrapper MassRecordData, String perID, List<String> premID, string appIdCareApplication, string eIAcctId){
        String careAppId;
        
        system.debug('Inside createUpdateCareAppRecord method---->:');
        system.debug('MassRecordData:'+ MassRecordData);
        
        CARE_Application__c caObj = new CARE_Application__c();
        List<CARE_Application__c> caRecList = new List<CARE_Application__c>();
        
        
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
            caRecList.add(caObj);
        }
        if(string.isNotBlank(appIdCareApplication)){
            //update caRecList;
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
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
            
        }
      }
        return careAppId;
    }
    
    @AuraEnabled
    public static verificationResult GetCCCode(String careAppId, String perID, List<String> premID, string sIsAccepted){
       
        verificationResult vRes = new verificationResult();
        
        
        System.debug('Inside GetCCCode method------>');
        String ccDescription = '';
        String ccDescriptionLong = '';
        Map<string,List<string>> mapInputValues=new Map<string,List<string>>();
        List<String> isAcceptedList = new List<String>();
        
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
        System.debug('Description---->'+ccDescription);       
        
        vRes.ccCodeDescription = ccDescription;
        vRes.ccCodeDescriptionLong = ccDescriptionLong;
        return vRes;
        
    }
    
    /*@AuraEnabled
    public static String createCareAppAfterIsAdjust(CustomerInfoWrapper MassRecordData, String appIdCareApplication, String perID){
        
        system.debug('inside createCareAppAfterIsAdjust------>');
        system.debug('App ID for Care Application Object------>'+ appIdCareApplication);
        String careAppIdForIsAdjust = '';
        List<CARE_Application__c> careAppListOnIsAdjustClick = new List<CARE_Application__c>();
        List<CARE_Type__c> listCareTypeFrom = new List<CARE_Type__c>();
        
        //get the cc code details for Transfer Drop
         listCareTypeFrom = CARE_UtilityController.getCCCode('6034',null,null);
        
        List<CARE_Application__c> careAppList = [select Id, IS_RECERT__c, NO_ADULT__c, APPLICANT_NAME__c, APPLICATION_STATUS__c,
                                                 NO_CHILD__c, IS_SIGNED__c, REQUEST_DROP__c, NEED_NAME_CHANGE__c, RECEIVED_DATE__c,
                                                 SOURCE_CHANNEL_TYPE__c, PROCESSED_DATE__c, FORM_CODE__c, COC_CODE__c, LIHEAP__c, 
                                                 MEDICAID_UNDER65__c, MEDICAID_OVER65__c, EMAIL_ADDRESS__c, ANNUAL_HOUSEHOLD_INCOME__c,
                                                 FIXED_INCOME__c, WIC__c, CALFRESH_SNAP__c, CALWORKS_TANF__c, HEAD_START_INCOME__c, CARE_Account_ID__c,
                                                 SSI__c, HEALTHY_FAMILIES__c,PROCESS_NOTES__c,ENROLLMENT_TYPE__c, NSLP__c, BUREAU_INDIAN_AFFAIRS__c,CCB_CONTACT_CODE__c,
                                                 //REASON_DESC__c,
                                                 CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c, APPLICATION_TYPE__c from CARE_Application__c where Id =: appIdCareApplication];
                                                 
        if(careAppList != null){
            for(CARE_Application__c caApp : careAppList){
                CARE_Application__c careApp = new CARE_Application__c();
                careApp.RecordTypeId = careAppRecTypeId;
                careApp.IS_RECERT__c = caApp.IS_RECERT__c;
                careApp.NO_ADULT__c = caApp.NO_ADULT__c;
                careApp.NO_CHILD__c = caApp.NO_CHILD__c;
                careApp.IS_SIGNED__c = caApp.IS_SIGNED__c;
                careApp.REQUEST_DROP__c = caApp.REQUEST_DROP__c;
                careApp.NEED_NAME_CHANGE__c = caApp.NEED_NAME_CHANGE__c;
                careApp.APPLICANT_NAME__c = caApp.APPLICANT_NAME__c;
                careApp.RECEIVED_DATE__c = caApp.RECEIVED_DATE__c != null ? caApp.RECEIVED_DATE__c : caApp.PROCESSED_DATE__c;
                careApp.PROCESSED_DATE__c = caApp.PROCESSED_DATE__c;
                careApp.SOURCE_CHANNEL_TYPE__c = 'Enroll/Adjustment';
                careApp.FORM_CODE__c = caApp.FORM_CODE__c;
                careApp.COC_CODE__c = caApp.COC_CODE__c;
                careApp.APPLICATION_STATUS__c = 'Decision Made';        
                careApp.LIHEAP__c = caApp.LIHEAP__c;
                careApp.WIC__c = caApp.WIC__c;
                careApp.CALFRESH_SNAP__c = caApp.CALFRESH_SNAP__c;
                careApp.CALWORKS_TANF__c = caApp.CALWORKS_TANF__c;
                careApp.HEAD_START_INCOME__c = caApp.HEAD_START_INCOME__c;
                careApp.SSI__c = caApp.SSI__c;
                careApp.HEALTHY_FAMILIES__c = caApp.HEALTHY_FAMILIES__c;
                careApp.NSLP__c = caApp.NSLP__c;
                careApp.BUREAU_INDIAN_AFFAIRS__c = caApp.BUREAU_INDIAN_AFFAIRS__c;
                careApp.MEDICAID_UNDER65__c = caApp.MEDICAID_UNDER65__c;
                careApp.MEDICAID_OVER65__c = caApp.MEDICAID_OVER65__c;
                careApp.EMAIL_ADDRESS__c = caApp.EMAIL_ADDRESS__c;
                careApp.ANNUAL_HOUSEHOLD_INCOME__c = caApp.ANNUAL_HOUSEHOLD_INCOME__c;
                careApp.FIXED_INCOME__c = caApp.FIXED_INCOME__c;
                careApp.APPLICATION_TYPE__c = 'Enrollment';
                careApp.PROCESS_NOTES__c = MassRecordData.processNoteValue != null ? MassRecordData.processNoteValue : MassRecordData.adjustReasonValue;
                careApp.PER_ID__c = perID != null ? perID : '';
                careApp.CCB_CONTACT_CODE__c = listCareTypeFrom[0].TYPE_CODE__c;
                careApp.CCB_CONTACT_DESC__c = listCareTypeFrom[0].TYPE_DESC__c;
                careApp.CCB_CONTACT_COMMENT__c = MassRecordData.ccbCommentValue != '' ? MassRecordData.ccbCommentValue : listCareTypeFrom[0].TYPE_DESC_LONG__c;
                careApp.ENROLLMENT_TYPE__c = caApp.ENROLLMENT_TYPE__c != null ? caApp.ENROLLMENT_TYPE__c : 'OTHER';
                //careApp.CCB_CONTACT_TYPE__c = caApp.CCB_CONTACT_TYPE__c != '' ? caApp.CCB_CONTACT_TYPE__c : '6034';
                careApp.CARE_Account_ID__c = caApp.CARE_Account_ID__c;
                //careApp.REASON_DESC__c = MassRecordData.adjustReasonValue;
                careApp.IS_ADJUSTMENT__c = MassRecordData.isAdjustValue;
                system.debug('caAPP Value: ' + careApp);
                careAppListOnIsAdjustClick.add(careApp); 
            }
        }
        
        Database.SaveResult[] srList = Database.insert(careAppListOnIsAdjustClick, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted careApp after isAdjust clicked--->: ' + sr.getId());
                careAppIdForIsAdjust = sr.getId();
               
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
        
        
        List<CARE_Application__c> updateAppStatusList = new List<CARE_Application__c>();
        
        if(careAppList !=null && !careAppList.isEmpty()){
            for(CARE_Application__c updateAppStatus : careAppList){
              updateAppStatus.APPLICATION_STATUS__c = 'Decision Made';
               updateAppStatusList.add(updateAppStatus); 
            }
        }
        
        if(updateAppStatusList.size() > 0){
            update updateAppStatusList;
        }
        
        return careAppIdForIsAdjust;
    }*/
    
    
   /* @AuraEnabled
    public static void createEnrolledSAforIsAdjust(CustomerInfoWrapper MassRecordData, String careAppIdForIsAdjust, String appIdCareApplication){
        system.debug('inside createEnrolledSAforIsAdjust');
        system.debug('App Id for Care App New --->'+ careAppIdForIsAdjust);
        system.debug('App Id for Care App old --->'+ appIdCareApplication);
        
        List<CARE_App_Enrolled_SA__c> careSAListToInsert = new List<CARE_App_Enrolled_SA__c>();
        
        List<CARE_App_Enrolled_SA__c> retroDateUpdateList = [select Id, ACCT_ID__c, APPLICATION__c,RETRO_START_DATE__c, RETRO_END_DATE__c,
                                                             CC_CL_CD__c, PER_ID__c, PREM_ID__c, SA_ID__c, START_DATE__c,END_DATE__c,CSR_USER__c,
                                                             CCB_CONTACT_TYPE__c, RS_CD__c, Service_Agreement__c, SA_START_DATE__c, SA_END_DATE__c, LAST_BILL_DATE__c
                                                             from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: appIdCareApplication]; 
        
        if(retroDateUpdateList !=null && !retroDateUpdateList.isEmpty()){
            for(CARE_App_Enrolled_SA__c caEnroll : retroDateUpdateList){
                CARE_App_Enrolled_SA__c careEnrollSa = new CARE_App_Enrolled_SA__c();
                careEnrollSa.ACCT_ID__c = caEnroll.ACCT_ID__c;
                careEnrollSa.ADJUSTED__c = MassRecordData.isAdjustValue;
                careEnrollSa.CC_CL_CD__c = caEnroll.CC_CL_CD__c;
                careEnrollSa.RETRO_START_DATE__c = caEnroll.RETRO_START_DATE__c;
                careEnrollSa.RETRO_END_DATE__c = caEnroll.RETRO_END_DATE__c;
                careEnrollSa.PER_ID__c = caEnroll.PER_ID__c;
                careEnrollSa.PREM_ID__c = caEnroll.PREM_ID__c;
                careEnrollSa.SA_ID__c = caEnroll.SA_ID__c;
                careEnrollSa.RS_CD__c = caEnroll.RS_CD__c;
                careEnrollSa.START_DATE__c = caEnroll.START_DATE__c;
                careEnrollSa.END_DATE__c = today;
                careEnrollSa.SA_START_DATE__c = caEnroll.SA_START_DATE__c;
                careEnrollSa.SA_END_DATE__c = caEnroll.SA_END_DATE__c;
                careEnrollSa.LAST_BILL_DATE__c = caEnroll.LAST_BILL_DATE__c;
                careEnrollSa.Service_Agreement__c = caEnroll.Service_Agreement__c;
                careEnrollSa.CCB_CONTACT_TYPE__c = caEnroll.CCB_CONTACT_TYPE__c != null ? caEnroll.CCB_CONTACT_TYPE__c : '6034';
                careEnrollSa.APPLICATION__c = careAppIdForIsAdjust;
                careEnrollSa.CSR_USER__c = currentLoggedInUser;
                careSAListToInsert.add(careEnrollSa);
                
            }
        }
        
        Database.SaveResult[] srList = Database.insert(careSAListToInsert, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted careAppEnrolledSA with retro dates--->: ' + sr.getId());
                
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
        List<CARE_App_Enrolled_SA__c> careSAListToRevertRetroDates = new List<CARE_App_Enrolled_SA__c>();
        if(retroDateUpdateList !=null && !retroDateUpdateList.isEmpty()){
            for(CARE_App_Enrolled_SA__c caEnrollRevert : retroDateUpdateList){
                caEnrollRevert.RETRO_START_DATE__c = null;
                caEnrollRevert.RETRO_END_DATE__c = null;
                careSAListToRevertRetroDates.add(caEnrollRevert);
                system.debug('reverted retro dates---->:'+ careSAListToRevertRetroDates);
            }
        }
        if(careSAListToRevertRetroDates !=null && careSAListToRevertRetroDates.size() > 0){
            update careSAListToRevertRetroDates;
        }
    }*/
    
    /*@AuraEnabled
    public static string careUpdateAppStatusRevertRetroDates(String appIdCareApplication){
        String appIdForCareEnroll;
        string sCareAppStatus = '';
        
        List<CARE_App_Enrolled_SA__c> listToRevertRetroDates = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_Application__c> listToUpdateAppStatus = new List<CARE_Application__c>();
        
     
        List<CARE_Application__c> appStatusList = [Select Id, APPLICATION_STATUS__c from CARE_Application__c
                                                    where Id =: appIdCareApplication];
        
        if(appStatusList !=null && !appStatusList.isEmpty()){
            for(CARE_Application__c appStatus : appStatusList){
                appStatus.APPLICATION_STATUS__c = 'Decision Made';
                listToUpdateAppStatus.add(appStatus);
            }
        }
        
        sCareAppStatus = listToUpdateAppStatus[0].APPLICATION_STATUS__c;
        
        if(listToUpdateAppStatus !=null && listToUpdateAppStatus.size() > 0){
            update listToUpdateAppStatus;
            
        }
        
        
        List<CARE_App_Enrolled_SA__c> retroDateRevertList = [select Id, RETRO_START_DATE__c, RETRO_END_DATE__c                                                            
                                                             from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: appIdCareApplication]; 
        
        if(retroDateRevertList !=null && !retroDateRevertList.isEmpty()){
            for(CARE_App_Enrolled_SA__c cAppEnroll : retroDateRevertList){
                cAppEnroll.RETRO_START_DATE__c = null;
                cAppEnroll.RETRO_END_DATE__c = null;
                listToRevertRetroDates.add(cAppEnroll);
            }
        }
        if(listToRevertRetroDates !=null && listToRevertRetroDates.size() > 0){
            update listToRevertRetroDates;
        }
        
        return sCareAppStatus;
    }*/
    
}