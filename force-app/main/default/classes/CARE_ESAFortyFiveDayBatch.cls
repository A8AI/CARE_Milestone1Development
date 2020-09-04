/**************************************************************************************************   
Apex Batch Name      :  CARE_ESAFortyFiveDayBatch
Version              :  1.0                                                                          
Created Date         :  07/30/2020                                                              
Function             :  This batch class is invoked to check if customer has enrolled in ESA
					    within 45 days of stamping H RAND CERT code.
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   07/30/2020                First Iteration  

***************************************************************************************************/

global class CARE_ESAFortyFiveDayBatch implements Database.Batchable<sObject>,Database.Stateful{
	
    global Integer iSystemValue = 0;
    global Date dTodaysDate = Date.today();
    global Date dFortyFiveDay;
    global Integer recordsProcessed = 0;
    global Set<Id> setCareAppESA = new Set<Id>();
    global Set<Id> setErrorIdESA = new Set<Id>();
    global Set<String> setErrorPerIdESA = new Set<String>();
    global String sESACode = CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK;
    //global Date dDateTwoYearsBefore;
    
    /**
    * Method name  : start
    * Description  : Querying all records to check ESA enrollment within 45 days.
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>{CARE_Constants.CARE_ESA_SystemValueCode};
        listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
            system.debug('listGetSystemValue---->'+listGetSystemValue);
        
            if(listGetSystemValue.size() > 0){
                for(CARE_System_Value__c careSystemRecord : listGetSystemValue){
                    if(careSystemRecord.SYSTEM_VALUE_CODE__c == CARE_Constants.CARE_ESA_SystemValueCode){
                        iSystemValue = Integer.valueOf(careSystemRecord.SYSTEM_VALUE__c); 
                    }
                } 
            }else{
                iSystemValue = CARE_Constants.CARE_FortyFiveDay;
            }
        dFortyFiveDay = dTodaysDate.addDays(-iSystemValue);
        
        String query = 'SELECT APPLICATION__c, PER_ID__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c from CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: sESACode AND CARE_CI_CC__r.CC_DTTM__c >=: dFortyFiveDay';
        
        return Database.getQueryLocator(query);
            /*'SELECT APPLICATION__c, PER_ID__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c' + 
            'from CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK' + 
            'AND CARE_CI_CC__r.CC_DTTM__c >=: dFortyFiveDay'
        );*/
    }
    
    /**
    * Method name  : execute
    * Description  : this method will execute validations to check if person Id has been enrolled in ESA or not
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        system.debug('inside execute method----->');
        
        recordsProcessed = scope.size();
        List<CARE_CC_Batch_Detail__c> listHRandCert = (List<CARE_CC_Batch_Detail__c>)scope;
        CARE_AutoUtilityController.ESAThresholdCheckWrapper eSAWrapper = new CARE_AutoUtilityController.ESAThresholdCheckWrapper();
        
        system.debug('listHRandCert--->'+listHRandCert);
        if(listHRandCert.size() > 0){
           eSAWrapper = CARE_AutoUtilityController.eSAFortyFiveDaysCheck(listHRandCert);
            system.debug('eSAWrapper---->'+eSAWrapper.setESACareAppId);
            if(eSAWrapper.setESACareAppId.size() > 0){
                for(Id recId : eSAWrapper.setESACareAppId){
                    setCareAppESA.add(recId); 
                }
            }
            if(eSAWrapper.setESAErrorId.size() > 0){
                for(Id recId : eSAWrapper.setESAErrorId){
                    setErrorIdESA.add(recId); 
                }
            }
            if(eSAWrapper.setErrorPerId.size() > 0){
                for(String perId : eSAWrapper.setErrorPerId){
                    setErrorPerIdESA.add(perId); 
                }
            }
           /* if(eSAWrapper.setThresholdAppId.size() > 0){
                for(Id recId : eSAWrapper.setThresholdAppId){
                    setCareAppIdThreshold.add(recId); 
                }
            }
            if(eSAWrapper.setThresholdErrId.size() > 0){
                for(Id recId : eSAWrapper.setThresholdErrId){
                    setErrorIdThreshold.add(recId); 
                }
            }
            if(eSAWrapper.setThresholdErrPerId.size() > 0){
                for(String perId : eSAWrapper.setThresholdErrPerId){
                    setErrorPerIdThreshold.add(perId); 
                }
            }*/
        }
    }
    
    /**
    * Method name  : finish
    * Description  : this method holds all the success and drop records Ids which got inserted in CARE APP and CARE APP ENROLL SA
    * Return Type  : void
    * Parameter    : Database.BatchableContext 
    **/
    global void finish(Database.BatchableContext BC) {
        
        string sEmail = '';
        
        // get email address for this job from CARE_System__c object.  If not value, use "mdsscareonesupport@pge.com"
        List<CARE_System_Value__c> systemValLst = [Select Name,SYSTEM_VALUE__c,SYSTEM_VALUE_TYPE__c from CARE_System_Value__c where Name ='Internal Support Email List' and SYSTEM_VALUE_TYPE__c = 'EMAIL' LIMIT 1];
        if(systemValLst.size() > 0 && systemValLst[0].SYSTEM_VALUE__c != null){
            sEmail = systemValLst[0].SYSTEM_VALUE__c;
        }
        else{
            sEmail = 'mdsscareonesupport@pge.com';
        }
        
        // get job status
        AsyncApexJob a = 
            [SELECT Id, CompletedDate, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
             FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        CARE_UtilityController.sendBatchCompletionEmail(sEmail, a.Status, a.CompletedDate, a.TotalJobItems, setCareAppESA.size(), setErrorIdESA.size());
        
        system.debug('All fail ESA Ids===' +setErrorIdESA);
        system.debug('All failed ESA per Id===' +setErrorPerIdESA);
        system.debug('All success ESA Id---' +setCareAppESA);
        
        system.debug('Total number of records processed' +recordsProcessed);
        
    }
}