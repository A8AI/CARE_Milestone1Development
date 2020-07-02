/***********************************************************************************************************   
Apex Util class Name :  CARE_OnDemandDropController
Version              :  1.0                                                                          
Created Date         :  05/28/2020                                                         
Function             :  This is the Controller Class for On Demand Drop Modal Popup.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/28/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public class CARE_OnDemandDropController {
    
    public static date dDateToday = system.today();
    public static date dToday = system.today();
    public static String dTodayDate = dToday.format();
    public static Id currentLoggedInUser = UserInfo.getUserId();
   
  
    @AuraEnabled
    //public static Map<String, EI_Site__c> getPerIdValue(String perIdValue){
    public static onDropData getPerIdValue(String perIdValue){
        onDropData careRes = new onDropData();
        careRes.oldAppIdForCare='';
		careRes.descLongValue='';
        careRes.NewAppIdForCare='';
        careRes.sContactCode = '';
        string enrollAppIdValue = '';
        Integer iLimit = integer.valueof(CARE_Constants.CARE_OnDemandDrop_QueryLimit);
        
        system.debug('perID Value---->' + perIdValue);
        
        Id userId = UserInfo.getUserId();            
        User userDetails = [SELECT Profile.Name, LAN_ID_EI__c FROM User WHERE ID = :userId];
        
        Map<String, EI_Site__c> careEISiteMapData = new Map<String, EI_Site__c>();
     	careEISiteMapData = CARE_UtilityController.getActiveSADetailsForPersonId(perIdValue);
        
        Id NewCareId;
        system.debug('careEISiteMapData Map value in care enrolled SA---->' + careEISiteMapData);
        List<CARE_App_Enrolled_SA__c> listCareAppId = new List<CARE_App_Enrolled_SA__c>();
        
        listCareAppId = [Select APPLICATION__r.Id from CARE_App_Enrolled_SA__c
                    where SA_ID__c In: careEISiteMapData.keyset() AND END_DATE__c >: dDateToday Order by CreatedDate desc limit : iLimit];
        
        system.debug('listCareAppId from App Enrolled------->'+ listCareAppId);
        if(listCareAppId.size() > 0){
            enrollAppIdValue = listCareAppId[0].APPLICATION__r.Id;
        }
        
        system.debug('App Id is enrollAppIdValue---->:'+ enrollAppIdValue);
        
        /***prepopulate Type Desc long in comments field***/
            List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        //get the cc code details for Transfer Drop
         	listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_OnDemandDrop,null,null);
            
            string sLanID = listCareTypeDesc[0].TYPE_DESC_LONG__c.replace('<LAN ID>', (userDetails.LAN_ID_EI__c != null) ? userDetails.LAN_ID_EI__c : '');
        	//string descLongVal = sLanID.replace('<Date Received>', dTodayDate);//String.valueOf(dToday));
        	//string sContactCode = listCareTypeDesc[0].TYPE_CODE__c;
        	
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        /*****create Care Application record for Uploading in Image Id******/
        List<CARE_Application__c> careAppNewRecord = new List<CARE_Application__c>();
        if(String.isNotBlank(enrollAppIdValue)){
        List<CARE_Application__c> careAppRecord = [select IS_RECERT__c, NO_ADULT__c, APPLICANT_NAME__c, APPLICATION_STATUS__c,
                                                   NO_CHILD__c, IS_SIGNED__c, REQUEST_DROP__c, NEED_NAME_CHANGE__c, RECEIVED_DATE__c,
                                                   SOURCE_CHANNEL_TYPE__c, PROCESSED_DATE__c, FORM_CODE__c, COC_CODE__c, LIHEAP__c, 
                                                   MEDICAID_UNDER65__c, MEDICAID_OVER65__c, EMAIL_ADDRESS__c, ANNUAL_HOUSEHOLD_INCOME__c,
                                                   FIXED_INCOME__c, WIC__c, CALFRESH_SNAP__c, CALWORKS_TANF__c, HEAD_START_INCOME__c,
                                                   SSI__c, HEALTHY_FAMILIES__c, PROCESS_NOTES__c, NSLP__c, BUREAU_INDIAN_AFFAIRS__c,CCB_CONTACT_CODE__c,
                                                   CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c, PER_ID__c, ENROLLMENT_TYPE__c,
                                                   DROP_SOURCE__c, APPLICATION_TYPE__c, CARE_Account_ID__c,  CC_CL_CD__c
                                                   //REASON_DESC__c,
                                                   from CARE_Application__c where Id =: enrollAppIdValue];
    
          CARE_Application__c appCare = new CARE_Application__c();
            	appCare.RecordTypeId = careAppRecTypeId;
                appCare.IS_RECERT__c = careAppRecord[0].IS_RECERT__c;
                appCare.NO_ADULT__c = careAppRecord[0].NO_ADULT__c;
                appCare.NO_CHILD__c = careAppRecord[0].NO_CHILD__c;
                appCare.IS_SIGNED__c = careAppRecord[0].IS_SIGNED__c;
                appCare.REQUEST_DROP__c = careAppRecord[0].REQUEST_DROP__c;
                appCare.NEED_NAME_CHANGE__c = careAppRecord[0].NEED_NAME_CHANGE__c;
                appCare.APPLICANT_NAME__c = careAppRecord[0].APPLICANT_NAME__c;
                appCare.RECEIVED_DATE__c = careAppRecord[0].RECEIVED_DATE__c != null ? careAppRecord[0].RECEIVED_DATE__c : careAppRecord[0].PROCESSED_DATE__c;
                appCare.PROCESSED_DATE__c = dDateToday; //careAppRecord[0].PROCESSED_DATE__c;
                appCare.SOURCE_CHANNEL_TYPE__c = 'Regular App';
                appCare.FORM_CODE__c = careAppRecord[0].FORM_CODE__c;
                appCare.COC_CODE__c = careAppRecord[0].COC_CODE__c;
                appCare.APPLICATION_STATUS__c = 'Decision Made';        
                appCare.LIHEAP__c = careAppRecord[0].LIHEAP__c;
                appCare.WIC__c = careAppRecord[0].WIC__c;
                appCare.CALFRESH_SNAP__c = careAppRecord[0].CALFRESH_SNAP__c;
                appCare.CALWORKS_TANF__c = careAppRecord[0].CALWORKS_TANF__c;
                appCare.HEAD_START_INCOME__c = careAppRecord[0].HEAD_START_INCOME__c;
                appCare.SSI__c = careAppRecord[0].SSI__c;
                appCare.HEALTHY_FAMILIES__c = careAppRecord[0].HEALTHY_FAMILIES__c;
                appCare.NSLP__c = careAppRecord[0].NSLP__c;
                appCare.BUREAU_INDIAN_AFFAIRS__c = careAppRecord[0].BUREAU_INDIAN_AFFAIRS__c;
                appCare.MEDICAID_UNDER65__c = careAppRecord[0].MEDICAID_UNDER65__c;
                appCare.MEDICAID_OVER65__c = careAppRecord[0].MEDICAID_OVER65__c;
                appCare.EMAIL_ADDRESS__c = careAppRecord[0].EMAIL_ADDRESS__c;
                appCare.ANNUAL_HOUSEHOLD_INCOME__c = careAppRecord[0].ANNUAL_HOUSEHOLD_INCOME__c;
                appCare.FIXED_INCOME__c = careAppRecord[0].FIXED_INCOME__c;
                appCare.PER_ID__c = careAppRecord[0].PER_ID__c;
                appCare.APPLICATION_TYPE__c = 'Other';
                appCare.CARE_Account_ID__c = careAppRecord[0].CARE_Account_ID__c;
                appCare.PROCESS_NOTES__c = careAppRecord[0].PROCESS_NOTES__c;
                appCare.ENROLLMENT_TYPE__c = careAppRecord[0].ENROLLMENT_TYPE__c != null ? careAppRecord[0].ENROLLMENT_TYPE__c : 'OTHER';                
                appCare.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                appCare.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                appCare.CCB_CONTACT_COMMENT__c = careAppRecord[0].CCB_CONTACT_COMMENT__c;
                appCare.DROP_SOURCE__c = careAppRecord[0].DROP_SOURCE__c;
                //appCare.REASON_DESC__c = careAppRecord[0].REASON_DESC__c;
                appCare.CC_CL_CD__c = careAppRecord[0].CC_CL_CD__c;
                system.debug('appCare Value: ' + appCare);
                careAppNewRecord.add(appCare); 
        }else{
            careRes.oldAppIdForCare='';
			careRes.descLongValue='';
        	careRes.NewAppIdForCare='';
        }
        //string descLongVal = sLanID.replace('<Date Received>', String.valueOf(careAppNewRecord[0].RECEIVED_DATE__c));
         Database.SaveResult[] srList = Database.insert(careAppNewRecord, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted careApp after isAdjust clicked--->: ' + sr.getId());
                NewCareId = sr.getId();
                System.debug('careNewAppId is--->: ' + NewCareId);
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
        
        string dateReceivedForComment = careAppNewRecord[0].RECEIVED_DATE__c.format();
        string descLongVal = sLanID.replace('<Date Received>', dateReceivedForComment);//String.valueOf(dToday));
                
        	careRes.oldAppIdForCare=enrollAppIdValue;
			careRes.descLongValue=descLongVal;
        	careRes.NewAppIdForCare=NewCareId;
        	careRes.sContactCode = careAppNewRecord[0].CCB_CONTACT_CODE__c;
        
        
        //return careEISiteMapData;
        return careRes;
    }
    
      public class onDropData{
        @AuraEnabled
		public string oldAppIdForCare{get;set;}
        @AuraEnabled
		public string NewAppIdForCare{get;set;}
        @AuraEnabled
		public string descLongValue{get;set;}
        @AuraEnabled
		public string sContactCode{get;set;}
}
    
    public class onDemandDropInfoWrapper{
        //@AuraEnabled public String sId{get;set;}
        @AuraEnabled public string dropReasonValue{get;set;}
        @AuraEnabled public string dropSourceValue{get;set;}
        @AuraEnabled public string caseIDValue{get;set;}
        @AuraEnabled public date dropDateValue{get;set;}
        @AuraEnabled public date receiveDateValue{get;set;}
    }
    
    public class finalResult{
        @AuraEnabled
		public String inCorrectCaseId{get;set;}
        @AuraEnabled
		public string careAppEnrolledID{get;set;}
        @AuraEnabled
		public Boolean bImageCheck{get;set;}
        @AuraEnabled
		public String dropSourceName{get;set;}
}
    
    @AuraEnabled
    public static finalResult getOnDemandDropInfoList(onDemandDropInfoWrapper onDemandDropData, Id oldAppIdCare, String perID, Id newAppIdCare, String nameOfEvent){
        String caseIdValue;
        //String careNewAppId = '';
        String careAppEnrollId = '';
        finalResult fr = new finalResult();
        fr.bImageCheck = true;
        fr.careAppEnrolledID = '';
        fr.inCorrectCaseId = '';
        fr.dropSourceName = onDemandDropData.dropSourceValue;
        system.debug('oldAppIdCare----->' + oldAppIdCare);
        system.debug('onDemandDropData.dropSourceValue----->' + onDemandDropData.dropSourceValue);
        system.debug('Event Button name----->' + nameOfEvent);
        
        
        caseIdValue = verifyCaseId(onDemandDropData);
        system.debug('caseIdValue in main method---->'+ caseIdValue);
        
        if(nameOfEvent == 'confirm'){
            
            if(String.isNotBlank(caseIdValue) && (onDemandDropData.dropSourceValue == 'CC&B Case' || onDemandDropData.dropSourceValue == 'SF Case')){
                system.debug('inside if block when dropsource is CC&B Case---->');
                updateCareAppRecord(onDemandDropData, perID, newAppIdCare);
        		careAppEnrollId = createcareAppEnrollSARecord(onDemandDropData, oldAppIdCare, newAppIdCare);
        		createCareAppImageRecord(onDemandDropData, newAppIdCare);
                
                fr.careAppEnrolledID = careAppEnrollId;
           		fr.inCorrectCaseId = caseIdValue;
                //fr.dropSourceName = 'CC&B Case';
                
            } else if(onDemandDropData.dropSourceValue == 'Emailed' && (String.isBlank(caseIdValue) || String.isNotBlank(caseIdValue))){
                if(CARE_UtilityController.checkIfImageIDExists(newAppIdCare) || CARE_UtilityController.checkIfUploadedImageExists(newAppIdCare)){
                    system.debug('inside if block when dropsource is Emailed and image ID exists---->');
                    updateCareAppRecord(onDemandDropData, perID, newAppIdCare);
        			careAppEnrollId = createcareAppEnrollSARecord(onDemandDropData, oldAppIdCare, newAppIdCare);
        			//createCareAppImageRecord(onDemandDropData, newAppIdCare);
                    
                    fr.careAppEnrolledID = careAppEnrollId;
           			fr.inCorrectCaseId = '';
                    fr.bImageCheck = true;
                    //fr.dropSourceName = 'Emailed';
                }else{
                    system.debug('inside else of checkIfImageIDExists class call---->');
                    fr.careAppEnrolledID = '';
           			fr.inCorrectCaseId = '';
                    fr.bImageCheck = false;
                    fr.dropSourceName = '';
                }
            }else if((onDemandDropData.dropSourceValue == 'Called - In' || onDemandDropData.dropSourceValue == 'Space Occupied' || onDemandDropData.dropSourceValue == 'Faxed/Letter Mailed - In' || onDemandDropData.dropSourceValue == 'CSR' || onDemandDropData.dropSourceValue == 'Other') && (String.isBlank(caseIdValue) || String.isNotBlank(caseIdValue))){
                system.debug('inside if block when dropsource is Called - In---->');
                updateCareAppRecord(onDemandDropData, perID, newAppIdCare);
        		careAppEnrollId = createcareAppEnrollSARecord(onDemandDropData, oldAppIdCare, newAppIdCare);
        		//createCareAppImageRecord(onDemandDropData, newAppIdCare);
                
                fr.careAppEnrolledID = careAppEnrollId;
           		fr.inCorrectCaseId = '';
           	    //fr.bImageCheck = true;
           	    //fr.dropSourceName = 'Called - In';
            }else{
                system.debug('inside final else---->');
                fr.careAppEnrolledID = '';
           		fr.inCorrectCaseId = '';
                fr.dropSourceName = '';
           		//fr.bImageCheck = false;
            }
        }
            
        return fr;
    }
        
    	@AuraEnabled
    public static String verifyCaseId(onDemandDropInfoWrapper onDemandDropData){
        String caseIdValue = '';
        List<Case> caseList = new List<Case>();
        
        if(onDemandDropData.caseIDValue != null){
            for(case caseListVal : [select Id, Reason from case where Id =: onDemandDropData.caseIDValue limit 1]){
                caseList.add(caseListVal);
            }
            system.debug('caseList----> ' + caseList);
        }
        
        if(caseList.size() > 0){
           caseIdValue =  caseList[0].Id;
            
        }
        system.debug('caseIdValue----> ' + caseIdValue);
        return caseIdValue;
    }
        
    	@AuraEnabled
        public static void updateCareAppRecord(onDemandDropInfoWrapper onDemandDropData, String perID, Id newAppIdCare){
            
            system.debug('inside updateCareAppRecord----->');
        
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
            
         List<CARE_Application__c> careAppListToUpdate =[select Id, DROP_SOURCE__c, CCB_CONTACT_COMMENT__c, 
                                                        RECEIVED_DATE__c, PER_ID__c
                                                         //REASON_DESC__c
                                                        from CARE_Application__c where Id =: newAppIdCare];
            
            if(careAppListToUpdate != null){
            for(CARE_Application__c appCare : careAppListToUpdate){                 
                appCare.RECEIVED_DATE__c = onDemandDropData.receiveDateValue != null ? onDemandDropData.receiveDateValue : dDateToday;
                appCare.PER_ID__c = perID;
                appCare.CCB_CONTACT_COMMENT__c = onDemandDropData.dropReasonValue;
                appCare.DROP_SOURCE__c = onDemandDropData.dropSourceValue;
                //appCare.REASON_DESC__c = onDemandDropData.dropReasonValue;
                //system.debug('caAPP Value: ' + careApp);
                careAppList.add(appCare); 
            }
        }
            if(careAppList.size() > 0 && careAppList != null){
                update careAppList;
                system.debug('updated care app record properly-----> ' + careAppList);
            }
            
        }
    
    @AuraEnabled
    public static string createcareAppEnrollSARecord(onDemandDropInfoWrapper onDemandDropData, Id oldAppIdCare, String newAppIdCare){
        string careAppEnrollId = '';
        
        system.debug('inside createcareAppEnrollSARecord');
        system.debug('App Id for Care App New --->'+ newAppIdCare);
        system.debug('App Id for Care App old --->'+ oldAppIdCare);
        
        List<CARE_Application__c> listReceiveDate = [select Id, PROCESSED_DATE__c from CARE_Application__c
                                                     where Id =: newAppIdCare];
        
        List<CARE_App_Enrolled_SA__c> careEnrolledSAListToInsert = new List<CARE_App_Enrolled_SA__c>();
        
        List<CARE_App_Enrolled_SA__c> retroDatesUpdateList = [select Id, ACCT_ID__c, APPLICATION__c,RETRO_START_DATE__c, RETRO_END_DATE__c,
                                                             CC_CL_CD__c, PER_ID__c, PREM_ID__c, SA_ID__c, START_DATE__c,END_DATE__c,  Service_Agreement__c,
                                                             CCB_CONTACT_TYPE__c, RS_CD__c, SA_START_DATE__c, LAST_BILL_DATE__c, CSR_USER__c
                                                             from CARE_App_Enrolled_SA__c where APPLICATION__r.Id =: oldAppIdCare];
        
        if(retroDatesUpdateList !=null && !retroDatesUpdateList.isEmpty()){
            for(CARE_App_Enrolled_SA__c caEnroll : retroDatesUpdateList){
                CARE_App_Enrolled_SA__c careEnrollSa = new CARE_App_Enrolled_SA__c();
                careEnrollSa.ACCT_ID__c = caEnroll.ACCT_ID__c;
                //careEnrollSa.APPLICATION__c = caEnroll.APPLICATION__c;
                careEnrollSa.CC_CL_CD__c = caEnroll.CC_CL_CD__c;
                careEnrollSa.Service_Agreement__c = caEnroll.Service_Agreement__c;
                careEnrollSa.RETRO_START_DATE__c = caEnroll.RETRO_START_DATE__c;
                careEnrollSa.RETRO_END_DATE__c = caEnroll.RETRO_END_DATE__c;
                careEnrollSa.PER_ID__c = caEnroll.PER_ID__c;
                careEnrollSa.PREM_ID__c = caEnroll.PREM_ID__c;
                careEnrollSa.SA_ID__c = caEnroll.SA_ID__c;
                careEnrollSa.RS_CD__c = caEnroll.RS_CD__c;
                careEnrollSa.START_DATE__c = caEnroll.START_DATE__c;
                careEnrollSa.END_DATE__c = onDemandDropData.dropDateValue == null ? listReceiveDate[0].PROCESSED_DATE__c : onDemandDropData.dropDateValue;
                careEnrollSa.CCB_CONTACT_TYPE__c = caEnroll.CCB_CONTACT_TYPE__c != '' ? caEnroll.CCB_CONTACT_TYPE__c : '6026';
                careEnrollSa.APPLICATION__c = newAppIdCare;
                careEnrollSa.SA_START_DATE__c = caEnroll.SA_START_DATE__c;
                //careEnrollSa.SA_END_DATE__c = caEnroll.SA_END_DATE__c;
                careEnrollSa.LAST_BILL_DATE__c = caEnroll.LAST_BILL_DATE__c;
                careEnrollSa.CSR_USER__c = currentLoggedInUser;
                careEnrolledSAListToInsert.add(careEnrollSa);
                
            }
        }
        
        Database.SaveResult[] srList = Database.insert(careEnrolledSAListToInsert, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted careAppEnrolledSA records--->: ' + sr.getId());
                careAppEnrollId = sr.getId();
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
        return careAppEnrollId;
        
    }
    
    @AuraEnabled
    public static void createCareAppImageRecord(onDemandDropInfoWrapper onDemandDropData, String newAppIdCare){
        
        List<CARE_APP_Image_List__c> careAppImageList = new List<CARE_APP_Image_List__c>();
        CARE_APP_Image_List__c careAppImage = new CARE_APP_Image_List__c();
        if(onDemandDropData != null){
           careAppImage.Application__c = newAppIdCare;
            careAppImage.CASE__c = onDemandDropData.caseIDValue;
            careAppImage.SOURCE_SYSTEM__c = 'CASE';
            careAppImage.IMAGE_ID__c = 0000000000;
            careAppImageList.add(careAppImage);
        }
        Database.SaveResult[] srList = Database.insert(careAppImageList, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted care App Image Record. AppImage ID: ' + sr.getId());
                
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
    
    @AuraEnabled
    public static void deleteCareAppRecord(String newCareIdToDelete){
        
        List<CARE_Application__c> listToDeleteCareApp = [select Id from CARE_Application__c where Id =: newCareIdToDelete];
        
        if(listToDeleteCareApp.size() > 0){
            delete listToDeleteCareApp;
        }
    }
    
}