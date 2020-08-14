public class CARE_LoadUserFile {
   @AuraEnabled 
   public static String getParameters (String argFileName, String argDocId, String fileSearchKey) {
       
       string sFileName = fileSearchKey;
       system.debug('@@@@@@fileSearchKey' + fileSearchKey);       
       string soqlQuery = 'select name, value__c from EI_ApexParameter__c where EI_ApexClassCatelog__r.Category__c = ' + '\'CARE.USERLOAD\' and EI_ApexClassCatelog__r.FileNameRegex__c like \'%' + sFileName + '%\''; 
       system.debug('@@@soqlQuery' + soqlQuery);
       List<EI_ApexParameter__c> listParm = Database.query(soqlQuery); 
       EI_BulkLoad.BulkUploadWrapper blkArg = new EI_BulkLoad.BulkUploadWrapper();
       system.debug('@@@@@@loaduser' + listParm);
       for(EI_ApexParameter__c parm :listParm){
           switch on parm.name {
               when 'objectApi' {		
                   blkArg.objectAPI = parm.value__c;
               }	
               when 'reqFields' {
                   blkArg.reqFields = (String[])JSON.deserialize(parm.value__c, String[].class);
               }
               when 'dmlAction' {		
                   blkArg.dmlAction = parm.value__c;
               }
               when 'csvFieldMap' {		
                   blkArg.csvFieldMap = (EI_BulkLoad.FieldMapSection[])JSON.deserialize(parm.value__c, EI_BulkLoad.FieldMapSection[].class);
               }	
               when 'parmList' {
                   blkArg.parmList = (EI_BulkLoad.ParmSection[])JSON.deserialize(parm.value__c , EI_BulkLoad.ParmSection[].class);
               }
               when 'className' {		
                   blkArg.className = parm.value__c;
               }
               when 'libraryName' {		
                   blkArg.libraryName = parm.value__c;
               }
               when 'storeSourceFile' {		
                   blkArg.storeSourceFile = (parm.value__c == 'true')?Boolean.valueOf(parm.value__c):false;
               }
               when 'batchSize' {		
                   blkArg.batchSize = (parm.value__c !='')?Integer.valueOf(parm.value__c):200;
               }
               when 'tgtArg' {		
                   blkArg.tgtArg = parm.value__c;
               }
           }
       }
       
       blkArg.csvFileName     = argFileName;
       blkArg.documentId      = argDocId;
       String jsonReturn = JSON.serialize(blkArg);
       system.debug('@@@@jsonReturn' + jsonReturn);
       return jsonReturn;
   } 
}