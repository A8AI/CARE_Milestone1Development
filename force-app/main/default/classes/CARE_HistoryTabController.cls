/***********************************************************************************************************   
Apex Util class Name :  CARE_HistoryTabController
Version              :  1.0                                                                          
Created Date         :  05/14/2020                                                         
Function             :  This is the Apex Controller for history Tab of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/13/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_HistoryTabController {
    
    //Wrapper class for History List
    Public class HistoryListWrapper{
        @AuraEnabled
        public String sApplicationName {get; set;}
        @AuraEnabled
        public String sIdTable {get;set;}
        @AuraEnabled
        public String sId {get;set;}
        @AuraEnabled
        public String sSAID {get;set;}
        @AuraEnabled
        public String sSAType {get;set;}
        @AuraEnabled
        public String sDiscountType {get;set;}
        @AuraEnabled
        public Date dStartDate {get;set;}
        @AuraEnabled
        public Date dEndDate {get;set;}
        @AuraEnabled
        public Date dReceiveDate {get;set;}
        @AuraEnabled
        public String sContact {get;set;}
        @AuraEnabled
        public String sDescription {get;set;}
        @AuraEnabled
        public String sCCBComment {get;set;}
        @AuraEnabled
        public String sTypeNo {get;set;}
        @AuraEnabled
        public String sAppSource {get;set;}
        @AuraEnabled
        public String sCommittedBy {get;set;}
        @AuraEnabled
        public String sFormatText {get;set;}
        @AuraEnabled
        public String sViewButton {get;set;}
        @AuraEnabled
        public Boolean bDeleteButton {get;set;}
        @AuraEnabled
        public String sApplicationStatus {get;set;}
        @AuraEnabled
        public String sEnrollmentType {get;set;}
        @AuraEnabled
        public String customCssClass{get;set;}

    }
    public class TotalHistoryWrapper{
       @AuraEnabled
       public List<HistoryListWrapper> listHistoryWrapper {get;set;}
        @AuraEnabled
       public Integer iTotalRecCount {get;set;}
        @AuraEnabled
       public Id idLastRec {get;set;}
    }
    
    //method to get the CARE app enrollment history details to whow under history tab 
    @AuraEnabled(Cacheable = true)
    public static TotalHistoryWrapper getEnrollHistoryData (String sPerID, String sMakeLiveCall, String recordId){
        
        TotalHistoryWrapper totHistoryRecords = new TotalHistoryWrapper();
        
        List<HistoryListWrapper> listHistoryRecords = new List<HistoryListWrapper>();
		List<CARE_Application__c> listcareAppRecordsNList = new list<CARE_Application__c>();        
        Date dTodaysDate = Date.today();
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-2);
        Integer iLimit = integer.valueof(CARE_Constants.CARE_History_QueryLimit);
        
        try{
            if(String.isBlank(recordId)){
                listcareAppRecordsNList = [SELECT ID,NAME, APPLICATION_STATUS__c, RECEIVED_DATE__c, PROCESSED_DATE__c, CARE_CI_CC__r.DESCR254__c,
                                                          CCB_CONTACT_CODE__c, CCB_CONTACT_CODE2__c, CCB_CONTACT_DESC__c, CCB_Contact_Type_No__c, CCB_CONTACT_DESC2__c,
                                                          CARE_CI_CC__r.USER_ID__c,SOURCE_CHANNEL_TYPE__c, CreatedDate, ENROLLMENT_TYPE__c,
                                                          (SELECT SA_ID__c, START_DATE__c, END_DATE__c , Service_Agreement__r.Svc_Type_Code_EI__c,
                                                           APPLICATION__c, RETRO_START_DATE__c, RETRO_END_DATE__c, CC_CL_CD__c, CCB_CONTACT_TYPE__c  FROM CARE_App_Enrolled_SA__r)
                                                          FROM CARE_Application__c WHERE PER_ID__C =: sPerID ORDER BY CreatedDate DESc, Id desc limit: iLimit];
                
                system.debug('listcareAppRecordsNList for blank record Id---->' + listcareAppRecordsNList.size());
            }
            else if(String.isNotBlank(recordId)){
                listcareAppRecordsNList = [SELECT ID,NAME, APPLICATION_STATUS__c, RECEIVED_DATE__c, PROCESSED_DATE__c, CARE_CI_CC__r.DESCR254__c,
                                                          CCB_CONTACT_CODE__c, CCB_CONTACT_CODE2__c, CCB_CONTACT_DESC__c, CCB_Contact_Type_No__c, CCB_CONTACT_DESC2__c,
                                                          CARE_CI_CC__r.USER_ID__c,SOURCE_CHANNEL_TYPE__c, CreatedDate, ENROLLMENT_TYPE__c,
                                                          (SELECT SA_ID__c, START_DATE__c, END_DATE__c , Service_Agreement__r.Svc_Type_Code_EI__c,
                                                           APPLICATION__c, RETRO_START_DATE__c, RETRO_END_DATE__c, CC_CL_CD__c, CCB_CONTACT_TYPE__c  FROM CARE_App_Enrolled_SA__r)
                                                          FROM CARE_Application__c WHERE PER_ID__C =: sPerID and Id <: recordId ORDER BY CreatedDate DESc, Id desc limit: iLimit];
                
                system.debug('listcareAppRecordsNList for non blank record Id---->' + listcareAppRecordsNList.size());
            }
            
           
            for( CARE_Application__c listcareAppRecords :listcareAppRecordsNList ){
                
                if (listcareAppRecords.CARE_App_Enrolled_SA__r != null && listcareAppRecords.CARE_App_Enrolled_SA__r.size()>0)
                {   integer cnt = 0; 
                    for (CARE_App_Enrolled_SA__C listCareEnrolledRecords : listcareAppRecords.CARE_App_Enrolled_SA__r)
                    {
                        HistoryListWrapper objRec = new HistoryListWrapper ();
                        objRec.sApplicationName = listcareAppRecords.Name;
                        objRec.sId =  listcareAppRecords.ID;
                        objRec.sIdTable =  listcareAppRecords.ID + '@@@' + cnt;
                        objRec.dReceiveDate = listcareAppRecords.PROCESSED_DATE__c == null ? listcareAppRecords.RECEIVED_DATE__c : listcareAppRecords.PROCESSED_DATE__c;
                        objRec.sDiscountType = listCareEnrolledRecords.CC_CL_CD__c; //listcareAppRecords.CC_CL_CD__c;
                        objRec.sDescription =  listcareAppRecords.CCB_CONTACT_DESC2__c == null ? listcareAppRecords.CCB_CONTACT_DESC__c : listcareAppRecords.CCB_CONTACT_DESC2__c;                        
                        objRec.sContact =  listcareAppRecords.CCB_CONTACT_CODE2__c == null? listcareAppRecords.CCB_CONTACT_CODE__c : listcareAppRecords.CCB_CONTACT_CODE2__c; 
                        objRec.sCCBComment =  listcareAppRecords.CARE_CI_CC__r.DESCR254__c; 
                        objRec.sCommittedBy =  listcareAppRecords.CARE_CI_CC__r.USER_ID__c; 
                        objRec.sAppSource =  listcareAppRecords.SOURCE_CHANNEL_TYPE__c;  
                        objRec.sSAID = listCareEnrolledRecords.SA_ID__c;
                        objRec.sApplicationStatus = listcareAppRecords.APPLICATION_STATUS__c;
                        objRec.sSAType = listCareEnrolledRecords.Service_Agreement__r.Svc_Type_Code_EI__c;
                        objRec.dStartDate = listCareEnrolledRecords.RETRO_START_DATE__C == null? listCareEnrolledRecords.START_DATE__c : listCareEnrolledRecords.RETRO_START_DATE__C; 
                        objRec.dEndDate = listCareEnrolledRecords.END_DATE__c;
                        objRec.sTypeNo = listcareAppRecords.CCB_Contact_Type_No__c != '' ? listcareAppRecords.CCB_Contact_Type_No__c : ''; 
                        objRec.sEnrollmentType = listcareAppRecords.ENROLLMENT_TYPE__c != '' ? listcareAppRecords.ENROLLMENT_TYPE__c : ''; 
                        //objRec.dEndDate = listCareEnrolledRecords.RETRO_END_DATE__c == null? listCareEnrolledRecords.SA_END_DATE__c : listCareEnrolledRecords.RETRO_END_DATE__c;
                        //format text based on the created date
                        objRec.sFormatText = listcareAppRecords.CreatedDate >= dDateBeforeTwoYears ? 'slds-text-title_bold':'slds-text-color_weak';
                        //set view button visiblity --Commented code as per Demo1 feedback
                        objRec.sViewButton = 'slds-show'; // For View button CSS
                        // --Commented code as per Demo1 feedback
                        //objRec.sViewButton = listcareAppRecords.SOURCE_CHANNEL_TYPE__c != 'Batch'?'slds-show':'slds-hide';
                        if(listcareAppRecords.APPLICATION_STATUS__c == 'Staged for CC&B' || listcareAppRecords.APPLICATION_STATUS__c == 'Sent to CC&B' ||
                           listcareAppRecords.APPLICATION_STATUS__c == 'Reconciled' || listcareAppRecords.APPLICATION_STATUS__c == 'Completed')
                        {
                            objRec.bDeleteButton = true;
                            objRec.customCssClass = 'classCSSDisabledDelete'; // For Delete button CSS
                        }
                        else{
                            objRec.bDeleteButton = false;
                            objRec.customCssClass = 'classCSSDelete'; // For Delete button CSS
                        }    
                        //objRec.customCssClass = 'classCSSDelete'; // For Delete button CSS
                        listHistoryRecords.add(objRec);
                        cnt++;
                    }
                } 
                else {
                    HistoryListWrapper objRec = new HistoryListWrapper ();
                    objRec.sApplicationName = listcareAppRecords.Name;
                    objRec.sId =  listcareAppRecords.ID;
                    objRec.sIdTable =  listcareAppRecords.ID;
                    objRec.dReceiveDate = listcareAppRecords.PROCESSED_DATE__c == null ? listcareAppRecords.RECEIVED_DATE__c : listcareAppRecords.PROCESSED_DATE__c;
                    objRec.sDescription =  listcareAppRecords.CCB_CONTACT_DESC2__c == null ? listcareAppRecords.CCB_CONTACT_DESC__c : listcareAppRecords.CCB_CONTACT_DESC2__c;              
                    objRec.sContact =  listcareAppRecords.CCB_CONTACT_CODE2__c == null? listcareAppRecords.CCB_CONTACT_CODE__c : listcareAppRecords.CCB_CONTACT_CODE2__c;  
                    objRec.sTypeNo = listcareAppRecords.CCB_Contact_Type_No__c != '' ? listcareAppRecords.CCB_Contact_Type_No__c : ''; 
                    objRec.sCCBComment =  listcareAppRecords.CARE_CI_CC__r.DESCR254__c; 
                    objRec.sCommittedBy =  listcareAppRecords.CARE_CI_CC__r.USER_ID__c; 
                    objRec.sAppSource =  listcareAppRecords.SOURCE_CHANNEL_TYPE__c;  
                    objRec.sApplicationStatus = listcareAppRecords.APPLICATION_STATUS__c;
                    objRec.sEnrollmentType = listcareAppRecords.ENROLLMENT_TYPE__c != '' ? listcareAppRecords.ENROLLMENT_TYPE__c : ''; 
                    //format text based on the created date
                    objRec.sFormatText = listcareAppRecords.CreatedDate >= dDateBeforeTwoYears ? 'slds-text-title_bold':'slds-text-color_weak';
                    //set view button visiblity
                    objRec.sViewButton = 'slds-show'; // For View button CSS
                    // --Commented code as per Demo1 feedback
                    // objRec.sViewButton = listcareAppRecords.SOURCE_CHANNEL_TYPE__c != 'Batch'?'slds-show':'slds-hide';
                    if(listcareAppRecords.APPLICATION_STATUS__c == 'Staged for CC&B' || listcareAppRecords.APPLICATION_STATUS__c == 'Sent to CC&B' ||
                       listcareAppRecords.APPLICATION_STATUS__c == 'Reconciled' || listcareAppRecords.APPLICATION_STATUS__c == 'Completed')
                    {
                        objRec.bDeleteButton = true;
                        objRec.customCssClass = 'classCSSDisabledDelete'; // For Delete button CSS
                    }
                    else{
                        objRec.bDeleteButton = false;
                        objRec.customCssClass = 'classCSSDelete'; // For Delete button CSS
                    }
                    //objRec.customCssClass = 'classCSSDelete'; // For Delete button CSS
                    listHistoryRecords.add(objRec);     
                    
                }
                 Integer iCountTotal =  [SELECT count() FROM Care_Application__c WHERE PER_ID__C =: sPerID];

                totHistoryRecords.listHistoryWrapper = listHistoryRecords;
                totHistoryRecords.iTotalRecCount = iCountTotal;
                totHistoryRecords.idLastRec = listcareAppRecordsNList[listcareAppRecordsNList.size()-1].Id;
            }
            }catch(Exception ex){
            
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_HistoryTabController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_HistoryTabController','','',sPerID, ex);
        }
        return  totHistoryRecords;
    }
    
    //method to Delete the Enrollment record
    @AuraEnabled
    public static void deleteEnrollmentRecord(String sEnrollmentId){        
        try{
            //Delete the images uploaded in ContentDocument as it has no master-detail relationship between Care_Application and ContentDocument
            //Hence explicitly delete the ContentDocument
            //For Care_App_Image_List, this will get automatically deleted when Care_Application gets deleted
             
            List<String> listCareAppId = new List<String>();
            String ParentCareAppId = [SELECT Parent_Application__c from CARE_Application__c
                                      WHERE Id =: sEnrollmentId].Parent_Application__c;
            Boolean bNotPerformPevDelete = true;
            
            if(string.isNotBlank(ParentCareAppId)){
                String sEnrollmentType = [SELECT ENROLLMENT_TYPE__c from CARE_Application__c
                                      WHERE Id =: ParentCareAppId].ENROLLMENT_TYPE__c;
                if(sEnrollmentType == CARE_Constants.CARE_PEV || sEnrollmentType == CARE_Constants.CARE_PEV_HU){
                    bNotPerformPevDelete = false;
                    deletePevHuRecord(ParentCareAppId); // To delete all income records 
                }else{
                    for(CARE_Application__c appRec : [SELECT Id FROM CARE_Application__c WHERE Parent_Application__c =: ParentCareAppId]){
                        listCareAppId.add(appRec.Id); // Pushing All Child App Id
                    }
                    listCareAppId.add(ParentCareAppId);
                }
                
            }else{
                ParentCareAppId = sEnrollmentId;
                listCareAppId.add(sEnrollmentId); // its a Parent App Id
            }
          
            //Boolean bDeletedSuccess = CARE_UtilityController.deleteUploadedContents(sEnrollmentId);
            Boolean bDeletedSuccess = CARE_UtilityController.deleteUploadedContents(ParentCareAppId);
            
            if(bDeletedSuccess && bNotPerformPevDelete){
                CARE_APP_Image_List__c[] imageRec = [SELECT Id FROM CARE_APP_Image_List__c where Application__c IN: listCareAppId];          
                delete imageRec; 
                
                CARE_Application__c[] rec = [SELECT Id FROM CARE_Application__c where Id IN: listCareAppId OR Parent_Application__c IN: listCareAppId];          
                delete rec;   
            }            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_HistoryTabController',ex));
           CARE_UtilityController.sendExceptionEmail('CARE_HistoryTabController','','',null, ex);    

        }
    }
    
    //method to Delete the Enrollment record
    @AuraEnabled
    public static void deletePevHuRecord(String sPevHuId){        
        try{
            //Delete the images uploaded in ContentDocument as it has no master-detail relationship between Care_Application and ContentDocument
            //Hence explicitly delete the ContentDocument
            //For Care_App_Image_List, this will get automatically deleted when Care_Application gets deleted
            /*List<CARE_Application__c> listParentCareAppId = [SELECT Parent_Application__c from CARE_Application__c
                                                             WHERE Id =: sPevHuId];*/
            List<String> listCareAppId = new List<String>();
            String ParentCareAppId = [SELECT Parent_Application__c from CARE_Application__c
                                      WHERE Id =: sPevHuId].Parent_Application__c;
            
            if(string.isNotBlank(ParentCareAppId)){
                for(CARE_Application__c appRec : [SELECT Id FROM CARE_Application__c WHERE Parent_Application__c =: ParentCareAppId]){
                    listCareAppId.add(appRec.Id); // Pushing All Child App Id
                }
                listCareAppId.add(ParentCareAppId);
                sPevHuId = ParentCareAppId;
            }
            listCareAppId.add(sPevHuId); // its a Parent App Id
            
            Boolean bDeletedSuccess = CARE_UtilityController.deleteUploadedContents(sPevHuId);
            
            if(bDeletedSuccess){
                List<CARE_Application__c> listCareApp = [SELECT Id,
                                                 (SELECT Id FROM CARE_APP_Image_List__r),        
                                                 (SELECT Id FROM CARE_Household_Detail__r),
                                                 (SELECT Id FROM CARE_Household_Member_Income__r),
                                                 (SELECT Id FROM CARE_Household_Member_IncomeC__r)
                                                 FROM CARE_Application__c 
                                                 WHERE Id IN: listCareAppId OR Parent_Application__c IN: listCareAppId];   
                
                List<CARE_APP_Image_List__c> listCareAppImage = new List<CARE_APP_Image_List__c>();
                List<CARE_Household_Detail__c> listCareHhDet = new List<CARE_Household_Detail__c>();
                List<CARE_Household_Member_Income__c> listCareHhInc = new List<CARE_Household_Member_Income__c>();
                List<CARE_Household_Member_IncomeC__c> listCareHhIncC = new List<CARE_Household_Member_IncomeC__c>();
                
                for(CARE_Application__c ca : listCareApp){
                    if(!ca.CARE_APP_Image_List__r.isEmpty()){
                        listCareAppImage.addAll(ca.CARE_APP_Image_List__r);
                    } 
                    if(!ca.CARE_Household_Detail__r.isEmpty()){
                        listCareHhDet.addAll(ca.CARE_Household_Detail__r);
                    }
                    if(!ca.CARE_Household_Member_Income__r.isEmpty()){
                        listCareHhInc.addAll(ca.CARE_Household_Member_Income__r);
                    }
                    if(!ca.CARE_Household_Member_IncomeC__r.isEmpty()){
                        listCareHhIncC.addAll(ca.CARE_Household_Member_IncomeC__r);
                    }                     
                }
                
                //Delete child objects in order
                deleteList(listCareHhIncC);
                deleteList(listCareHhInc);
                deleteList(listCareHhDet);
                deleteList(listCareAppImage);
                deleteList(listCareApp);
            }            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_HistoryTabController',ex));
           CARE_UtilityController.sendExceptionEmail('CARE_HistoryTabController','','',null, ex);    
        }
    }
       
    
    //method to show the special message for Msg button in History Tab
     @AuraEnabled(cacheable=true)
        public static string getSpecialMessage(String sApplicationNo, String sTypeNo)
    {
        String sSpecialMessage='';
        system.debug('CARE sApplicationNo----->'+sApplicationNo);
        system.debug('CARE sTypeNo----->'+sTypeNo);
        
        try{
            String scomments;
             CARE_Application__c careAppObj = [SELECT CCB_CONTACT_CODE__c, CC_CL_CD__c, PROCESSED_DATE__c, RECEIVED_DATE__c 
                                              FROM CARE_Application__c WHERE Name =:sApplicationNo];
            system.debug('careAppObj--->'+careAppObj);
            
            if(string.isNotBlank(sTypeNo)){
                scomments=[SELECT COMMENTS__c FROM CARE_Type__c 
                         WHERE TYPE_NO__c =: sTypeNo limit 1].COMMENTS__c;
            }
            else{
              scomments=[SELECT COMMENTS__c FROM CARE_Type__c 
                         WHERE TYPE_CODE__c=:careAppObj.CCB_CONTACT_CODE__c LIMIT 1].COMMENTS__c;
            }
             system.debug('scomments is----->'+scomments);
            if(string.isNotBlank(scomments)){
                if(scomments.contains(CARE_Constants.CARE_DISCOUNT_TYPE_PLACEHOLDER) && !scomments.contains(CARE_Constants.CARE_CC_DATE_PLACEHOLDER)){
                    sSpecialMessage = scomments.replace(CARE_Constants.CARE_DISCOUNT_TYPE_PLACEHOLDER, careAppObj.CC_CL_CD__c != null ? careAppObj.CC_CL_CD__c : CARE_Constants.CARE_DISCOUNT_TYPE_SELECT);
             		//sSpecialMessage = scomments.replace(CARE_Constants.CARE_CC_DATE_PLACEHOLDER, careAppObj.PROCESSED_DATE__c.format());
                }
                else if(scomments.contains(CARE_Constants.CARE_CC_DATE_PLACEHOLDER) && !scomments.contains(CARE_Constants.CARE_DISCOUNT_TYPE_PLACEHOLDER)){
                    sSpecialMessage = scomments.replace(CARE_Constants.CARE_CC_DATE_PLACEHOLDER, careAppObj.RECEIVED_DATE__c.format() != null ? careAppObj.RECEIVED_DATE__c.format() : careAppObj.PROCESSED_DATE__c.format());
                } 
                else if(scomments.contains(CARE_Constants.CARE_DISCOUNT_TYPE_PLACEHOLDER) && scomments.contains(CARE_Constants.CARE_CC_DATE_PLACEHOLDER)){
                    system.debug('inside 2nd else if--->');
                    scomments = scomments.replace(CARE_Constants.CARE_DISCOUNT_TYPE_PLACEHOLDER, careAppObj.CC_CL_CD__c != null ? careAppObj.CC_CL_CD__c : CARE_Constants.CARE_DISCOUNT_TYPE_SELECT);
                    sSpecialMessage = scomments.replace(CARE_Constants.CARE_CC_DATE_PLACEHOLDER, careAppObj.RECEIVED_DATE__c.format() != null ? careAppObj.RECEIVED_DATE__c.format() : careAppObj.PROCESSED_DATE__c.format());
                }
                else{
                    sSpecialMessage = scomments;
                }
            }
            else{
             sSpecialMessage = CARE_Constants.CARE_NO_SPECIAL_MSG;
            }
            system.debug('sSpecialMessage is----->'+sSpecialMessage);
        }
          catch(Exception ex){
           EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_HistoryTabController',ex));
           CARE_UtilityController.sendExceptionEmail('CARE_HistoryTabController','','',null, ex);    
        }
        return sSpecialMessage;
    }
    
    //This is a common method to delete any sObject list
    private static void deleteList(List<sObject> sobjList)
    {
        if(sobjList != null && !sobjList.isEmpty()){
            delete sobjList;
        } 
    }
}