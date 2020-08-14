/**************************************************************************************************   
Apex Batch Name      :  CARE_ESAFortyFiveDayExpireBatch
Version              :  1.0                                                                          
Created Date         :  07/30/2020                                                              
Function             :  This batch class is invoked to check if customer is not ESA enrolled 
                        after 45 days of H RAND CERT cc code stamp.
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   07/30/2020                First Iteration  

***************************************************************************************************/

global class CARE_ESAFortyFiveDayExpireBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    global Integer iSystemValue = 0;
    global Date dTodaysDate = Date.today();
    global Date dFortyFiveDay;
    global Date dDateTwoYearsBefore;
    global Integer recordsProcessed = 0;
    global Set<Id> setDropAppIdESA = new Set<Id>();
    global Set<Id> setDropErrorIdESA = new Set<Id>();
    global Set<String> setDropErrorPerIdESA = new Set<String>();
    global String sESACodeExpire = CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK;

    
    /**
    * Method name  : start
    * Description  : Querying all records to check ESA enrollment after 45 days.
    * Return Type  : Database.QueryLocator
    * Parameter    : Database.BatchableContext
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<Integer> listCareSystemValue = new List<Integer>{CARE_Constants.CARE_ESA_SystemValueCode};
        listGetSystemValue = CARE_UtilityController.getCareSystemValue(listCareSystemValue);
            
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
        dDateTwoYearsBefore = dFortyFiveDay.addDays(-CARE_Constants.CARE_BeforeTwoYearsInDays);
        system.debug('dFortyFiveDay--->'+dFortyFiveDay);
        system.debug('dDateTwoYearsBefore--->'+dDateTwoYearsBefore);
        
        String query = 'SELECT APPLICATION__c, PER_ID__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c from CARE_CC_Batch_Detail__c where CARE_CI_CC__r.CC_TYPE_CD__c =: sESACodeExpire AND CARE_CI_CC__r.CC_DTTM__c <=: dFortyFiveDay AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore';
        system.debug('query---->'+query);
        return Database.getQueryLocator(query);
            /*'SELECT APPLICATION__c, PER_ID__c, CARE_APP_ENROLLED_SA__r.PREM_ID__c from CARE_CC_Batch_Detail__c' +
            'where CARE_CI_CC__r.CC_TYPE_CD__c =: CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK' + 
            'AND CARE_CI_CC__r.CC_DTTM__c <=: dFortyFiveDay AND CARE_CI_CC__r.CC_DTTM__c >=: dDateTwoYearsBefore'
        );*/
        
    }
    
    /**
    * Method name  : execute
    * Description  : this method will execute validations to check customer has been enrolled in ESA or not
    *                and subsequently create transaction records
    * Return Type  : void
    * Parameter    : Database.BatchableContext, List<sObject>
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        system.debug('inside execute method----->');
        recordsProcessed+=scope.size();
        
        List<CARE_CC_Batch_Detail__c> listHRandCert = (List<CARE_CC_Batch_Detail__c>)scope;
        System.debug('listHRandCert---> '+listHRandCert);
        system.debug('listHRandCert size--->'+listHRandCert.size());
        CARE_AutoUtilityController.ESAThresholdCheckWrapper WrapperResponse = new CARE_AutoUtilityController.ESAThresholdCheckWrapper();
        
        if(listHRandCert.size() > 0){
           WrapperResponse = CARE_AutoUtilityController.notEnrolledESADropCustomers(listHRandCert);
            if(WrapperResponse.setESADropAppId.size() > 0){
                for(Id recId : WrapperResponse.setESADropAppId){
                    setDropAppIdESA.add(recId); 
                }
            }
            if(WrapperResponse.setESADropErrId.size() > 0){
                for(Id recId : WrapperResponse.setESADropErrId){
                    setDropErrorIdESA.add(recId); 
                }
            }
            if(WrapperResponse.setESADropErrPerId.size() > 0){
                for(String perId : WrapperResponse.setESADropErrPerId){
                    setDropErrorPerIdESA.add(perId); 
                }
            }
        }
    }
    
    /**
    * Method name  : finish
    * Description  : this method holds all the success and drop records
    * Return Type  : void
    * Parameter    : Database.BatchableContext 
    **/
    global void finish(Database.BatchableContext BC) {
        
        system.debug('All fail ESA Drop Ids===' +setDropErrorIdESA);
        system.debug('All failed ESA Drop per Id===' +setDropErrorPerIdESA);
        system.debug('All success ESA Drop Id---' +setDropAppIdESA);
    }
    

}