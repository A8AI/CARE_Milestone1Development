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
            set<Id> setCBSId = new Set<Id>();
            CARE_AutoUtilityController.stampVCodeWrapper WrapperResponse = new CARE_AutoUtilityController.stampVCodeWrapper();
            List<CARE_Batch_Staging__c> listOfVCodeRecords = new List<CARE_Batch_Staging__c>();
            Map<String, List<CARE_Batch_Staging__c>> mapOfVCodeRecords = new Map<String, List<CARE_Batch_Staging__c>>();
            String sJobNo = 'CBJ-0016';
            String sResFileName = 'VCode_result_';
            DynamicApex.returnWrapper rtnJSON = new DynamicApex.returnWrapper();
            try{
                
                Map<String, Object> mObjMap =  (Map<String, Object>) JSON.deserializeUntyped(arg);
            	String buhId    = String.valueOf(mObjMap.get('buhId'));
            	String libName  = String.valueOf(mObjMap.get('libraryName'));
                
                system.debug('buhId--->'+buhId);
                system.debug('libName--->'+libName);
                system.debug('mObjMap--->'+mObjMap);
              
                mapOfVCodeRecords = CARE_ManualUpload.getRecordsForManualLoad(sJobNo);
                
                if(mapOfVCodeRecords.size() > 0){
                    listOfVCodeRecords = mapOfVCodeRecords.get('Need To Process');                    
                        for(CARE_Batch_Staging__c ccCBS : mapOfVCodeRecords.get('All Records')){                           
                                setCBSId.add(ccCBS.Id);                            
                        }
                    
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
                CARE_ManualUpload.prepareResultCSV(setCBSId, buhId, libName, sResFileName);
                
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
            String sJobNo = 'CBJ-0017';
            String sResFileName = 'VHCode_result_';
            set<Id> setCBSId = new Set<Id>();
            Map<String, Set<Id>> responseObjMap = new Map<String, Set<Id>>();
            CARE_AutoUtilityController.StampVHCodeWrapper WrapperResponseVH = new CARE_AutoUtilityController.StampVHCodeWrapper();                
            List<CARE_Batch_Staging__c> listOfVHCodeRecords = new List<CARE_Batch_Staging__c>();
            Map<String, List<CARE_Batch_Staging__c>> mapOfVHCodeRecords = new Map<String, List<CARE_Batch_Staging__c>>();
            DynamicApex.returnWrapper rtnJSON = new DynamicApex.returnWrapper();
            
            try{
                Map<String, Object> mObjMap =  (Map<String, Object>) JSON.deserializeUntyped(arg);
            	String buhId    = String.valueOf(mObjMap.get('buhId'));
            	String libName  = String.valueOf(mObjMap.get('libraryName'));
                
                mapOfVHCodeRecords = CARE_ManualUpload.getRecordsForManualLoad(sJobNo);
                
                if(mapOfVHCodeRecords.size() > 0){
                    listOfVHCodeRecords = mapOfVHCodeRecords.get('Need To Process');                    
                        for(CARE_Batch_Staging__c ccCBS : mapOfVHCodeRecords.get('All Records')){                           
                                setCBSId.add(ccCBS.Id);                            
                        }
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
                CARE_ManualUpload.prepareResultCSV(setCBSId, buhId, libName, sResFileName);
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
    
    @TestVisible
    private static Map<String, List<CARE_Batch_Staging__c>> getRecordsForManualLoad(String jobNumber){
        
        List<CARE_Batch_Staging__c> listManualLoadRecords = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listCBSNotDuplicate = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listCBSErrorRecord = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listFinalCBS = new List<CARE_Batch_Staging__c>();
        Map<String, List<CARE_Batch_Staging__c>> mapOfCBSRecords = new Map<String, List<CARE_Batch_Staging__c>>();
        Set<String> setPerIdFromCBS = new Set<String>();
        Set<String> setDupPerId = new Set<String>();
        Set<String> sitePerIdSet = new Set<String>();
        
        try{ 
            listManualLoadRecords = [SELECT Id, PER_ID__c, JOB_NO__c, APPLICANT_NAME__c, CARE_BILLING_ACCT_ID__c, EI_ACCOUNT__c, 
                                     Processing_Message__c, Processing_Status__c, Source_Channel_Type__c
                                     FROM CARE_Batch_Staging__c WHERE Processing_Status__c =: CARE_Constants.CARE_PROCESSING_LOADED AND JOB_NO__c =: jobNumber];
            system.debug('listManualLoadRecords--->'+listManualLoadRecords);
            
            if(listManualLoadRecords.size() > 0){
                mapOfCBSRecords.put('All Records', listManualLoadRecords);
                
                for(CARE_Batch_Staging__c cbsRecord : listManualLoadRecords){
                   // system.debug('listManualLoadRecordsRow--->'+cbsRecord);
                  /*  if((cbsRecord.PER_ID__c != null && cbsRecord.PER_ID__c.isNumeric() && cbsRecord.PER_ID__c.length() == 10) && (setPerIdFromCBS.isEmpty() || !setPerIdFromCBS.contains(cbsRecord.PER_ID__c))){
                        setPerIdFromCBS.add(cbsRecord.PER_ID__c);
                        listCBSNotDuplicate.add(cbsRecord);
                    }else if(cbsRecord.PER_ID__c != null && (cbsRecord.PER_ID__c.length() < 10 || cbsRecord.PER_ID__c.isAlphaNumeric()) && (setPerIdFromCBS.isEmpty() || !setPerIdFromCBS.contains(cbsRecord.PER_ID__c))){
                        cbsRecord.Processing_Message__c = 'Invalid Person Id';
                        cbsRecord.Processing_Status__c = 'Error';
                        listCBSErrorRecord.add(cbsRecord);
                    }else{
                        cbsRecord.Processing_Message__c = 'Duplicate Record';
                        cbsRecord.Processing_Status__c = 'Error';
                        listCBSErrorRecord.add(cbsRecord); 
                    }
                   */
                    if(String.isNotBlank(cbsRecord.PER_ID__c) && cbsRecord.PER_ID__c.length() == 10){
                        if(setPerIdFromCBS.contains(cbsRecord.PER_ID__c)){
                            cbsRecord.Processing_Message__c = 'Duplicate Record';
                            cbsRecord.Processing_Status__c = 'Error';
                            listCBSErrorRecord.add(cbsRecord); 
                        }else{
                           setPerIdFromCBS.add(cbsRecord.PER_ID__c);
                           listCBSNotDuplicate.add(cbsRecord); 
                        }
                    }else{
                        cbsRecord.Processing_Message__c = 'Invalid Person Id';
                        cbsRecord.Processing_Status__c = 'Error';
                        listCBSErrorRecord.add(cbsRecord);
                    } 
                    
                     system.debug('listManualLoadRecordsRowFinal--->'+cbsRecord);
                }
            }
            system.debug('setPerIdFromCBS--->'+setPerIdFromCBS);
            system.debug('listCBSNotDuplicate--->'+listCBSNotDuplicate);
            system.debug('listCBSErrorRecordcountFirst--->'+listCBSErrorRecord.size()); 
               for(CARE_Batch_Staging__c cbs : listCBSErrorRecord){
                system.debug('listCBSErrorRecordRow--->'+cbs);
            }
         
            if(listCBSNotDuplicate.size() > 0){
                List<EI_Site__c> listPerIdFromSite = [Select Id, Person_ID_EI__c from EI_Site__c where Person_ID_EI__c IN: setPerIdFromCBS];
                for(EI_Site__c siteRec : listPerIdFromSite){
                    if(siteRec.Person_ID_EI__c != null){
                        sitePerIdSet.add(siteRec.Person_ID_EI__c); 
                    }
                }
                system.debug('sitePerIdSet--->'+sitePerIdSet);
                for(CARE_Batch_Staging__c cbs : listCBSNotDuplicate){
                    if(sitePerIdSet.contains(cbs.PER_ID__c)){
                        listFinalCBS.add(cbs); 
                    }else{
                        cbs.Processing_Message__c = 'Per Id not present in Site Object';
                        cbs.Processing_Status__c = 'Error';
                        listCBSErrorRecord.add(cbs);
                    } 
                }
            }else{
                listFinalCBS = listManualLoadRecords;
            }
            mapOfCBSRecords.put('Need To Process', listFinalCBS);
            
            system.debug('listFinalCBS--->'+listFinalCBS);
            system.debug('listCBSErrorRecord--->'+listCBSErrorRecord);
            system.debug('listCBSErrorRecordcount--->'+listCBSErrorRecord.size());
            if(listCBSErrorRecord.size() > 0){
                update listCBSErrorRecord;
            }
            
        }catch(DmlException ex) 
        {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI API runtime error: ' , new EI_BatchException(ex.getMessage())));
            CARE_UtilityController.sendExceptionEmail('CARE_ManualUpload', '', '', '', ex);
        } 
        
        return mapOfCBSRecords;
    }
    
    @TestVisible
    private static void prepareResultCSV(Set<Id> setCBSId, String buhId, String libName, String sResFileName){
        String resultCsvFile       = 'PERSON ID, STATUS, STATUS MESSAGE\r\n';
        Set<Id> errorIdSet = new Set<Id>();
        Set<Id> successIdSet = new Set<Id>();
        Set<Id> UnprocessedIdSet = new Set<Id>();
        
        List<CARE_Batch_Staging__c> updatedCBSList = [SELECT Id, PER_ID__c, Processing_Message__c, Processing_Status__c 
                                                     FROM CARE_Batch_Staging__c WHERE Id IN: setCBSId ];
        
        for(CARE_Batch_Staging__c cbss : updatedCBSList){
            String sConcatRes = cbss.PER_ID__c+','+cbss.Processing_Status__c+','+cbss.Processing_Message__c+'\r\n';
            resultCsvFile = resultCsvFile + sConcatRes;
            if(cbss.Processing_Status__c == 'Error'){
                errorIdSet.add(cbss.Id);
            }
            else if(cbss.Processing_Status__c == 'Processed'){
                successIdSet.add(cbss.Id);
            }else{
                UnprocessedIdSet.add(cbss.Id);
            }
        }
        Integer iTotalCnt = errorIdSet.size() + successIdSet.size() + UnprocessedIdSet.size();
        String sSummary = ('Success Count: '+successIdSet.size()+', Error Count: '+errorIdSet.size()+', Total Count: '+iTotalCnt);
        
		Blob   resultfile      = Blob.valueof(resultCsvFile);
		String resultFileName  = sResFileName + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
		String resultFileTitle = sResFileName + Datetime.now().format('YYYYMMdd_hhmm');

		EI_Bulkload.insertFile(resultfile, resultFileTitle, resultFileName, buhId, libName);
        EI_Bulkload.setPlacSummary(buhId, sSummary);

    }
}