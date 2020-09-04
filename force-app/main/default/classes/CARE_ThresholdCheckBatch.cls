/**************************************************************************************************   
Apex Batch Name      :  CARE_ThresholdCheckBatch
Version              :  1.0                                                                          
Created Date         :  07/30/2020                                                              
Function             :  This batch class is invoked to check if custome exceeds threshold limit after
                        ESA enrolled.
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   08/20/2020                First Iteration  

***************************************************************************************************/

global class CARE_ThresholdCheckBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global Integer iSystemValue = 0;
    global Date dTodaysDate = Date.today();
    global Date dNinetyDays;
    global Date dDateTwoYearsBefore;
    global Integer recordsProcessed = 0;
    global Set<Id> setCareAppIdThreshold = new Set<Id>();
    global Set<Id> setErrorIdThreshold = new Set<Id>();
    global Set<String> setErrorPerIdThreshold = new Set<String>();
    global String sESACompRec = CARE_Constants.CARE_CC_ESACOMP;
    
    /**
    * Method name  : start
    * Description  : Querying all records to check threshold after 90 days.
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>{CARE_Constants.CARE_ThresholdCheckCode};
        listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
            system.debug('listGetSystemValue---->'+listGetSystemValue);
        
            if(listGetSystemValue.size() > 0){
                for(CARE_System_Value__c careSystemRecord : listGetSystemValue){
                    if(careSystemRecord.SYSTEM_VALUE_CODE__c == CARE_Constants.CARE_ThresholdCheckCode){
                        iSystemValue = Integer.valueOf(careSystemRecord.SYSTEM_VALUE__c); 
                    }
                } 
            }else{
                iSystemValue = CARE_Constants.CARE_NinetyDay;
            }
        dNinetyDays = dTodaysDate.addDays(-iSystemValue);
        dDateTwoYearsBefore = dTodaysDate.addDays(-CARE_Constants.CARE_BeforeTwoYearsInDays);
        
        String query = 'SELECT APPLICATION__c, PER_ID__c, CARE_CI_CC__r.CC_DTTM__c FROM CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: sESACompRec AND CARE_CI_CC__r.CC_DTTM__c <=: dNinetyDays AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore';
        
        return Database.getQueryLocator(query);
    }
    
    /**
    * Method name  : execute
    * Description  : this method will execute validations to check if person has exceeded threshold limit
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        system.debug('inside execute method----->');
        recordsProcessed = scope.size();
        List<CARE_CC_Batch_Detail__c> esaThresholdCheckList = (List<CARE_CC_Batch_Detail__c>)scope;
        system.debug('esaThresholdCheckList--->'+esaThresholdCheckList);
        
        CARE_AutoUtilityController.ESAThresholdCheckWrapper WrapperResponse = new CARE_AutoUtilityController.ESAThresholdCheckWrapper();
        
        if(esaThresholdCheckList.size() > 0){
           WrapperResponse = CARE_AutoUtilityController.thresholdExceedCheckMethod(esaThresholdCheckList);
            if(WrapperResponse.setThresholdAppId.size() > 0){
                for(Id recId : WrapperResponse.setThresholdAppId){
                    setCareAppIdThreshold.add(recId); 
                }
            }
            if(WrapperResponse.setThresholdErrId.size() > 0){
                for(Id recId : WrapperResponse.setThresholdErrId){
                    setErrorIdThreshold.add(recId); 
                }
            }
            if(WrapperResponse.setThresholdErrPerId.size() > 0){
                for(String perId : WrapperResponse.setThresholdErrPerId){
                    setErrorPerIdThreshold.add(perId); 
                }
            }
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
        
        CARE_UtilityController.sendBatchCompletionEmail(sEmail, a.Status, a.CompletedDate, a.TotalJobItems, setCareAppIdThreshold.size(), setErrorIdThreshold.size());
    }

}