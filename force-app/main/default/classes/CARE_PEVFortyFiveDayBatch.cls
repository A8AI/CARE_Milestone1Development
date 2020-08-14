/**************************************************************************************************   
Apex Batch Name      :  CARE_PEVFortyFiveDayBatch
Version              :  1.0                                                                          
Created Date         :  07/30/2020                                                              
Function             :  This batch class is invoked to check if customer has responded with Income
documents within 45 daysof stamping V code.
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   07/30/2020                First Iteration  

***************************************************************************************************/

global class CARE_PEVFortyFiveDayBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global Integer iSystemValue = 0;
    global Date dTodaysDate = Date.today();
    global Date dFortyFiveDay;
    global Date dDateTwoYearsBefore;
    global Integer recordsProcessed = 0;
    global Set<Id> careAppPEVSet = new Set<Id>();
    global Set<Id> careAppErrorIdSet = new Set<Id>();
    global Set<String> setErrorPerId = new Set<String>();
    global String sVCode = CARE_Constants.CARE_CC_PEV;
    
    /**
* Method name  : start
* Description  : Querying all records which has V code stamped and not responding within 45 days.
* Return Type  : Database.QueryLocator
* Parameter    : Database.BatchableContext
**/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        system.debug('inside start method----->');
        
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>();//{CARE_Constants.CARE_PEV_SystemValueCode};
        listCareSystemValue.add(CARE_Constants.CARE_PEV_SystemValueCode);
            system.debug('listCareSystemValue---->'+listCareSystemValue);
            if(listCareSystemValue.size() > 0){
            listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
              system.debug('listGetSystemValue size if---->'+listGetSystemValue.size());
            }else{
               listGetSystemValue = [select SYSTEM_VALUE__c, SYSTEM_VALUE_CODE__c from CARE_System_Value__c where SYSTEM_VALUE_CODE__c = 810];
            system.debug('listGetSystemValue size else---->'+listGetSystemValue.size());
            }
        
        
        if(listGetSystemValue.size() > 0){
            for(CARE_System_Value__c careSystemRecord : listGetSystemValue){
                if(careSystemRecord.SYSTEM_VALUE_CODE__c == CARE_Constants.CARE_PEV_SystemValueCode){
                    iSystemValue = Integer.valueOf(careSystemRecord.SYSTEM_VALUE__c); 
                }else{
                    iSystemValue = CARE_Constants.CARE_FortyFiveDay;
                }
            } 
        }else{
           iSystemValue = CARE_Constants.CARE_FortyFiveDay; 
        }
        dFortyFiveDay = dTodaysDate.addDays(-iSystemValue);
        dDateTwoYearsBefore = dFortyFiveDay.addDays(-CARE_Constants.CARE_BeforeTwoYearsInDays);
        
        String query = 'SELECT ID, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c from CARE_CC_Batch_Detail__c Where CARE_CI_CC__r.CC_TYPE_CD__c =: sVCode AND CARE_CI_CC__r.CC_DTTM__c <=: dFortyFiveDay AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore';
        
        return Database.getQueryLocator(query);
          
    }
    
    /**
* Method name  : execute
* Description  : this method will execute validations to check if person Id has responded after V code stamping
* Return Type  : void
* Parameter    : Database.BatchableContext, List<sObject>
**/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        system.debug('inside execute method----->');
        recordsProcessed = scope.size();
        List<CARE_CC_Batch_Detail__c> listOfVCode = (List<CARE_CC_Batch_Detail__c>)scope;
        CARE_AutoUtilityController.PEVResponseCheckWrapper WrapperResponse = new CARE_AutoUtilityController.PEVResponseCheckWrapper();
        
        system.debug('listOfVCode size--->'+listOfVCode);
        
        if(listOfVCode.size() > 0){
            WrapperResponse = CARE_AutoUtilityController.PEVFortyFiveDaysCheck(listOfVCode);
            if(WrapperResponse.careAppPEVSet.size() > 0){
                for(Id recId : WrapperResponse.careAppPEVSet){
                    careAppPEVSet.add(recId); 
                }
            }
            if(WrapperResponse.careAppErrorIdSet.size() > 0){
                for(Id recId : WrapperResponse.careAppErrorIdSet){
                    careAppErrorIdSet.add(recId); 
                }
            }
            if(WrapperResponse.setErrorPerId.size() > 0){
                for(String perId : WrapperResponse.setErrorPerId){
                    setErrorPerId.add(perId); 
                }
            }
            
            
        }
        
        
    }
    
    /**
* Method name  : finish
* Description  : this method holds all the success records Ids which got inserted in CARE APP and CARE APP ENROLL SA
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
        
        CARE_UtilityController.sendBatchCompletionEmail(sEmail, a.Status, a.CompletedDate, a.TotalJobItems, careAppPEVSet.size(), careAppErrorIdSet.size());
               
        system.debug('All fail Ids===' +careAppErrorIdSet);
        system.debug('All failed per Id===' +setErrorPerId);
        system.debug('All success Id---' +careAppPEVSet);
        system.debug('Total number of records processed' +recordsProcessed);
    }
}