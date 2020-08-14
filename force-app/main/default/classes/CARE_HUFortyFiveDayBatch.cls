/**************************************************************************************************   
Apex Batch Name      :  CARE_HUFortyFiveDayBatch
Version              :  1.0                                                                          
Created Date         :  07/30/2020                                                              
Function             :  This batch class is invoked to check if customer has responded with Income
						documents within 45 days of stamping VH code.
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   07/30/2020                First Iteration  

***************************************************************************************************/

global class CARE_HUFortyFiveDayBatch implements Database.Batchable<sObject>,Database.Stateful{
	
    global Integer iSystemValue = 0;
    global Date dTodaysDate = Date.today();
    global Date dFortyFiveDay;
    global Date dDateTwoYearsBefore;
    global Integer recordsProcessed = 0;
    global Set<Id> careAppHUSet = new Set<Id>();
    global Set<Id> errorIdSetHU = new Set<Id>();
    global Set<String> errorPerIdSet = new Set<String>();
    global String sVHCode = CARE_Constants.CARE_CC_HU;
    
    /**
    * Method name  : start
    * Description  : Querying all records which has VH code stamped and not responding within 45 days.
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>{CARE_Constants.CARE_HU_SystemValueCode};
                listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
        system.debug('listGetSystemValue--->'+listGetSystemValue);    
        
            if(listGetSystemValue.size() > 0){
                for(CARE_System_Value__c careSystemRecord : listGetSystemValue){
                    if(careSystemRecord.SYSTEM_VALUE_CODE__c == CARE_Constants.CARE_HU_SystemValueCode){
                        iSystemValue = Integer.valueOf(careSystemRecord.SYSTEM_VALUE__c); 
                    }
                } 
            }else{
                iSystemValue = CARE_Constants.CARE_FortyFiveDay;
            }
            dFortyFiveDay = dTodaysDate.addDays(-iSystemValue);
            dDateTwoYearsBefore = dFortyFiveDay.addDays(-CARE_Constants.CARE_BeforeTwoYearsInDays);
        
        String query = 'SELECT Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c from CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: sVHCode AND CARE_CI_CC__r.CC_DTTM__c <=: dFortyFiveDay AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore';
        
        return Database.getQueryLocator(query);
            /*'SELECT Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c' +
            'from CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: CARE_Constants.CARE_CC_HU' + 
            'AND CARE_CI_CC__r.CC_DTTM__c <=: dFortyFiveDay AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore'
        );*/
    }
    
    /**
    * Method name  : execute
    * Description  : this method will execute validations to check if person Id has responded after VH code stamping
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        system.debug('inside execute method----->');
        recordsProcessed+=scope.size();
        
        List<CARE_CC_Batch_Detail__c> listOfVHCode = (List<CARE_CC_Batch_Detail__c>)scope;
        system.debug('listOfVHCode size--->'+listOfVHCode.size());
        CARE_AutoUtilityController.HUResponseCheckWrapper WrapperResponseHU = new CARE_AutoUtilityController.HUResponseCheckWrapper();
        
        if(listOfVHCode.size() > 0){
           WrapperResponseHU = CARE_AutoUtilityController.HUFortyFiveDaysCheck(listOfVHCode);
            if(WrapperResponseHU.careAppHUSet.size() > 0){
                for(Id recId : WrapperResponseHU.careAppHUSet){
                    careAppHUSet.add(recId); 
                }
            }
            if(WrapperResponseHU.errorIdSetHU.size() > 0){
                for(Id recId : WrapperResponseHU.errorIdSetHU){
                    errorIdSetHU.add(recId); 
                }
            }
            if(WrapperResponseHU.errorPerIdSet.size() > 0){
                for(String perId : WrapperResponseHU.errorPerIdSet){
                    errorPerIdSet.add(perId); 
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
        
        /*AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id =: BC.getJobId()];*/
        
        system.debug('All fail Ids===' +errorIdSetHU);
        system.debug('All failed per Id===' +errorPerIdSet);
        system.debug('All success Id---' +careAppHUSet);
        system.debug('Total number of records processed' +recordsProcessed);
        
    }
}