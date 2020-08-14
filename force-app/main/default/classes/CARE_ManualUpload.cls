/***********************************************************************************************************   
Apex Batch Class Name :  CARE_ManualUpload
Version               :  1.0                                                                          
Created Date          :  08/13/2020
Function              :  This is the apex class to process Manual uploads for V code and VH code.
Story                 :                                                                               
Work Task             :                                                                               
Modification Log      :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 08/13/2020            A8AI                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

global class CARE_ManualUpload{
    
    public Class processVCode implements DynamicApex.DynamicApexInterface {
        
        public String execute(String arg) {
            System.debug('MyClassName Class Runs with arg = ' + arg);
            //String jsonReturn;
            //Map<String, Object> responseObj = new Map<String, Object>();
            Map<String, Set<Id>> responseObjMap = new Map<String, Set<Id>>();
            String jobNo = 'CBJ-0016';
            DynamicApex.returnWrapper rtnJSON = new DynamicApex.returnWrapper();
            try{
            
            CARE_AutoUtilityController.stampVCodeWrapper WrapperResponse = new CARE_AutoUtilityController.stampVCodeWrapper();
            
            List<CARE_Batch_Staging__c> listOfVCodeRecords = new List<CARE_Batch_Staging__c>();
            
            listOfVCodeRecords = CARE_ManualUpload.getRecordsForManualLoad(jobNo);
            
            if(listOfVCodeRecords.size() > 0){
                WrapperResponse = CARE_AutoUtilityController.determineVCodeStamping(listOfVCodeRecords);
                responseObjMap.put('processVCode Runs with arg = ', WrapperResponse.careAppSet);
                responseObjMap.put('processVCode Runs with arg = ', WrapperResponse.careAppErrorIdSet);
                
            	rtnJSON.returnCode     = 1;
            	rtnJSON.message        = 'Operation Completed';
            	rtnJSON.requestSuccess = 'true';
            	rtnJSON.data           = 'processVCode Runs with arg = ' + responseObjMap;
            	//return JSON.serialize(rtnJSON);
                //jsonReturn = JSON.serialize(rtnJSON);
            }
            else{
                rtnJSON.returnCode     = 1;
            	rtnJSON.message        = 'Operation Failed';
            	rtnJSON.requestSuccess = 'false';
            	rtnJSON.data           = 'No Records Founds with arg = ' + responseObjMap;
            	//return JSON.serialize(rtnJSON);
                //jsonReturn = JSON.serialize(rtnJSON);
            }
        }catch(DmlException ex) 
            {
                    rtnJSON.message    = 'Operation Failed';
                    rtnJSON.requestSuccess = 'false'; 
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI API runtime error: ' , new EI_BatchException(ex.getMessage())));
                    CARE_UtilityController.sendExceptionEmail('CARE_ManualUpload', '', '', '', ex);
            }           
            String jsonReturn = JSON.serialize(rtnJSON);
            return  jsonReturn;           
        }
        
    }
    
    public Class processVHCode implements DynamicApex.DynamicApexInterface {
        
        public String execute(String arg) {
            System.debug('MyClassName Class Runs with arg = ' + arg);
            //String jsonReturn;
            //Map<String, Object> responseObj = new Map<String, Object>();
            String jobNo = 'CBJ-0017';
            Map<String, Set<Id>> responseObjMap = new Map<String, Set<Id>>();
            DynamicApex.returnWrapper rtnJSON = new DynamicApex.returnWrapper();
            try{
            
            CARE_AutoUtilityController.StampVHCodeWrapper WrapperResponseVH = new CARE_AutoUtilityController.StampVHCodeWrapper();
            
            List<CARE_Batch_Staging__c> listOfVHCodeRecords = new List<CARE_Batch_Staging__c>();
            
            listOfVHCodeRecords = CARE_ManualUpload.getRecordsForManualLoad(jobNo);
            
            if(listOfVHCodeRecords.size() > 0){
                WrapperResponseVH = CARE_AutoUtilityController.determineVHCodeStamping(listOfVHCodeRecords);
                responseObjMap.put('processVHCode Runs with arg = ', WrapperResponseVH.careAppSet);
                responseObjMap.put('processVHCode Runs with arg = ', WrapperResponseVH.careAppErrorIdSet);
                
            	rtnJSON.returnCode     = 1;
            	rtnJSON.message        = 'Operation Completed';
            	rtnJSON.requestSuccess = 'true';
            	rtnJSON.data           = 'processVCode Runs with arg = ' + responseObjMap;
            	//return JSON.serialize(rtnJSON);
                //jsonReturn = JSON.serialize(rtnJSON);
            }
            else{
                rtnJSON.returnCode     = 1;
            	rtnJSON.message        = 'Operation Failed';
            	rtnJSON.requestSuccess = 'false';
            	rtnJSON.data           = 'No Records Founds with arg = ' + responseObjMap;
            	//return JSON.serialize(rtnJSON);
                //jsonReturn = JSON.serialize(rtnJSON);
            }
        }catch(DmlException ex) 
            {
                    rtnJSON.message    = 'Operation Failed';
                    rtnJSON.requestSuccess = 'false'; 
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI API runtime error: ' , new EI_BatchException(ex.getMessage())));
                    CARE_UtilityController.sendExceptionEmail('CARE_ManualUpload', '', '', '', ex);
            }           
            String jsonReturn = JSON.serialize(rtnJSON);
            return  jsonReturn;           
        }
        
    }
    
    private static List<CARE_Batch_Staging__c> getRecordsForManualLoad(String jobNumber){
        
       List<CARE_Batch_Staging__c> listManualLoadRecords = new List<CARE_Batch_Staging__c>();
       
        try{
       listManualLoadRecords = [SELECT Id, PER_ID__c, JOB_NO__c, APPLICANT_NAME__c, CARE_BILLING_ACCT_ID__c, EI_ACCOUNT__c, 
                                Processing_Message__c, Processing_Status__c, Source_Channel_Type__c
                                 FROM CARE_Batch_Staging__c WHERE Processing_Status__c =: CARE_Constants.CARE_PROCESSING_LOADED AND JOB_NO__c =: jobNumber];
        
        }catch(DmlException ex) 
            {
                 EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI API runtime error: ' , new EI_BatchException(ex.getMessage())));
                 CARE_UtilityController.sendExceptionEmail('CARE_ManualUpload', '', '', '', ex);
            } 
        
        return listManualLoadRecords;
    }


}