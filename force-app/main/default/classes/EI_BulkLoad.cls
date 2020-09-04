/**************************************************************************************************
Apex Class Name      :  EI_BulkLoad
Version              :  1.0
Created Date         :  03/17/2020
Function             :  bulkload of csv file
Story                :
Work Task            :
Modification Log     :
*--------------------------------------------------------------------------------------------------
* Developer          Date                   Description
* -------------------------------------------------------------------------------------------------
* LXX1               01/20/2020             Initial Version
* V1BW               07/20/2020             Enhancement
***************************************************************************************************/
global Class EI_BulkLoad implements Database.Batchable<String>, Database.Stateful 
{
   private final  String   CLASSNAME        = 'EI_BULKLOAD';
   private final  String   DELIMITER        = ',';
   private final  String   RECORD_DELIMITER = '\r\n';
   private final  String   inJSON;
   private final  String   originHeader;

   private final  BulkUploadWrapper inArg;
   private final  Map<String, String> reqFeildMap = new Map<String, String>();

   global BulkloadResult  result = new BulkloadResult('0', 'No data is loaded', 0);
   global String      outJSON    = JSON.serialize(result);
   global String      header     = '';
   global String      parmHeader = '';
   global String      parmValue  = '';
   global String[]    csvRows    = new String[0];

   global EI_BulkLoad(String inputJSON) 
   {
      String    METHOD                = 'CONSTRUCTOR';
      String    acctId                = '';   
      String[]  fileRows              = new String[0];
      Map<String,String> csvHeaderMap = new Map<String,String>();

      try {

         result     = new BulkloadResult('0', 'In Progress', 0);
         result.buh = new EI_Bulk_Upload_History__c();
         inJSON     = inputJSON;
         inArg      = (BulkUploadWrapper)JSON.deserialize(inputJSON, BulkUploadWrapper.class);

         system.debug('\r\n============ bulkload JSON Arg inside EI_BulkLoad.bulkLoad() ============ \r\n' + inputJSON );
         system.debug('\r\n============ bulkload sObj Arg inside EI_BulkLoad.bulkLoad() ============ \r\n' + inArg);
         system.debug('\r\n =========== inArg.csvFieldMap ======================== \r\n' + inArg.csvFieldMap);
         JSONLib.logMessage(CLASSNAME, METHOD, 'inputJSON',   50, String.valueOf(inputJSON));
         JSONLib.logMessage(CLASSNAME, METHOD, 'inArg',       51, String.valueOf(inArg));
         if ( inArg.csvFieldMap <> null ) JSONLib.logMessage(CLASSNAME, METHOD, 'csvFieldMap', 52, String.valueOf(inArg.csvFieldMap));

         result.buh.Account_EI__c          = getAccountId();
         result.buh.File_Name_EI__c        = inArg.csvFileName;
         result.buh.Bulk_Upload_Sta_EI__c  = 'In Progress';
         result.buh.File_Upload_Date_EI__c = System.now();
         insert result.buh;
         
         parmHeader += ',' + 'Bulk_Upload_History__c';
         parmValue  += ',' + String.valueOf(result.buh.id);

         // csvHeaderMap: map from csv header ==> fieldApiName
         if (inArg.csvFieldMap <> null) for (FieldMapSection fm : inArg.csvFieldMap) csvHeaderMap.put(fm.srcFieldAPI.toUpperCase(), fm.tgtFieldAPI);

         if (inArg.reqFields <> null && inArg.reqFields.size() > 0) {
            for (String apiName : inArg.reqFields) for (String oneHeader : csvHeaderMap.keySet()) {
               if (csvHeaderMap.get(oneHeader) == apiName ) reqFeildMap.put(apiName, oneHeader); else reqFeildMap.put(apiName, apiName);
            }
         }

         system.debug('\r\n ======================== csvHeaderMap ======================== \r\n' + csvHeaderMap);

         fileRows                        = inArg.csvData.split(RECORD_DELIMITER);

         result.recordCount              = fileRows.size() - 1;
         result.buh.File_Rec_Count_EI__c = fileRows.size() - 1;

         if ( fileRows.size() > 0 ) {
            originHeader = fileRows.remove(0).toUpperCase();
            if (csvHeaderMap.size() > 0) {
               String[] headerList    = parseCsvLine(originHeader);
               String[] newHeaderList = new String[0];
               Integer  headerCount   = headerList<>null?headerList.size():0;

               System.debug('\r\n================ fileRows ================\r\n' + fileRows);

               if ( headerList <> null && headerList.size() > 0) {
                  for(String h : headerList) {
                     String newHeader = csvHeaderMap.containsKey(h)?csvHeaderMap.get(h):h;
                     newHeaderList.add(newHeader);
                  }
               }

               header = String.join(newHeaderList, DELIMITER);
               
               // add the constants in the parmList
               if( parmHeader.length() > 0) {
                  header += parmHeader;
                  for (String row : fileRows) csvRows.add(row + parmValue);
               } else csvRows = fileRows;

            } else {
               header  = originHeader;
               csvRows = fileRows;
            }
         } else {
            header  = '';             // no header
            csvRows = new String[0];  // no data in the csv file 
            originHeader = '';
         }

         System.debug('\r\n================ header ================\r\n' + header);
         System.debug('\r\n================ csvRows ===============\r\n' + csvRows);
         System.debug('\r\n================ originHeader ==========\r\n' + originHeader);

         if(header == null || fileRows == null || !(fileRows.size()>0) ) {
            result.errorcode = '-1';
            result.message   = 'No data is on the csv file';
         }

         result.recordCount                = csvRows.size();
         result.buh.File_Upload_Date_EI__c = System.Now();
         result.buh.File_Rec_Count_EI__c   = csvRows.size();
         result.buh.Error_Count_EI__c      = 0;
         result.buh.Success_Count_EI__c    = 0;

      }  catch (Exception e) {
          EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI_CSVBulkload.bulkload', e));
          String errMsg       = 'Error occurred in Constructor: Line=' + e.getLineNumber() + ', ErrMsg=' + e.getMessage();
          result.errorcode    = '-1'; 
          result.message      = errMsg; 
          csvRows             = null;
          result.successCount = 0;
          result.buh.File_Upload_Date_EI__c = System.Now();
          result.buh.Bulk_Upload_Sta_EI__c  = 'Upload Failed (Technical Error)' ;
          if (result.buh.File_Name_EI__c == null) result.buh.File_Name_EI__c = 'NA';
          if (result.buh.Account_EI__c   == null) {
             result.buh.Account_EI__c = [select id from account where name like '%ummy%' ][0].id;
          }
      }

      update result.buh;
      outJSON = JSON.serialize(result);

      return;
   }    //  end of constructor

   private Id getAccountId() {
      ID acctId = null;
      if (inArg.parmList == null ) inArg.parmList = new ei_bulkload.ParmSection[0];
      for ( ParmSection parm : inArg.parmList) {
         if (parm.fieldAPI.toUpperCase()   == 'ACCOUNT_EI__C' &&  
             parm.objectAPI.toUpperCase()  == 'EI_BULK_UPLOAD_HISTORY__C') 
         {
            acctId = (id)parm.value;
         }  else if ( parm.objectAPI.toUpperCase()  == inArg.objectAPI.toUpperCase() ) 
         {
            parmHeader += ',' + parm.fieldAPI;
            parmValue  += ',' + parm.Value;
            System.debug('\r\n++++++++++++++++++ parmHeader +++++++++++++++\r\n' + parmHeader);
            System.debug('\r\n++++++++++++++++++ parmValue +++++++++++++++\r\n'  + parmValue);
         }
      }

      System.debug('\r\n================ parmHeader ================\r\n' + parmHeader);
      System.debug('\r\n================ parmValue =================\r\n' + parmValue);

      if (acctId<>null) return acctId;

      Account[] acct = [ SELECT Id FROM Account WHERE Name = 'Energy Savings Dummy Account' ];
      if( acct.size() > 0 ) return acct[0].id;

      acct.add(new Account( name = 'Dummy Account for Bulkload', description = 'Dummy Account for Bulkload.' )) ;
      insert acct;
      return acct[0].id;
   }

   @AuraEnabled
   global static String loadCSVFile ( String argJSON) {

      try {
         system.debug('argJSON ==================== ' + argJSON );
         BulkUploadWrapper buw = (BulkUploadWrapper)JSON.deserialize(argJSON, BulkUploadWrapper.class);
         if (buw.csvData == null) {
            ContentVersion    con = [select id, Title, VersionData, PathOnClient
                                       from ContentVersion
                                      where id IN ( SELECT LatestPublishedVersionId 
                                                      FROM ContentDocument 
                                                     WHERE id = :buw.documentId ) ][0];
            buw.csvData = con.VersionData.toString();
            if ( buw.csvFileName == null ) buw.csvFileName = con.PathOnClient;
         }

         if ( buw.csvFileName == null ) buw.csvFileName = 'FileName is not provided';
         if ( buw.batchSize == null || buw.batchSize <=0 ) buw.batchSize = 200;

         String newArgJSON = JSON.serialize(buw);
         // system.debug('File Content = ' + con.VersionData.toString() );

         EI_BulkLoad bulkLoadJob = new EI_BulkLoad(newArgJSON);
         ID batchProcessid = Database.executeBatch(bulkLoadJob, buw.batchSize);

         bulkLoadJob.result.AsyncApexJobId = String.valueOf(batchProcessid);
         bulkLoadJob.outJSON               = JSON.serialize(bulkLoadJob.result);

         return bulkLoadJob.outJSON;
      } catch (Exception e) {
         EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI_BulkLoad.loadCSVFile()', e));
         String errMsg = 'Encountered unexpected Apex error in loadCSVFile at Line=' + e.getLineNumber() + ', the ErrMsg=' + e.getMessage();
         //result.status.add('Upload Failed (Technical Error)');
         //result.message = '[Unexpected Error: ' + errMsg + ']' + result.message;
         //outJSON = JSON.serialize(result);
         String jsonReturn = '{"errorcode":"-1", "message":"' + errMsg + '"}';
         return jsonReturn;
      }

   }

   global Iterable<String> start(Database.BatchableContext BC) 
   {
      return new csvRowIterator(csvRows);
   }

   // ========================== EXECUTE ===============================
   global void execute(Database.BatchableContext BC, List<String> scope)
   {
      try {
         String[] rows  = new String[]{header};
         rows.addAll(scope);
         
         System.debug('\r\nheader in execute ========\r\n' + header);

         String csvData = String.join(rows, RECORD_DELIMITER);
         System.debug('\r\nNew csv Data ========\r\n' + csvData);

         BulkloadResult dmlResult = new BulkloadResult();
         Integer cnt = saveCsv2object(csvData ,        inArg.objectAPI,   reqFeildMap,
                                      inArg.dmlAction, inArg.extFieldAPI, dmlResult ) ;

         result.add(dmlResult);
         outJSON = JSON.serialize(result);
         system.debug('Execute dmlResult - =' + dmlResult);

      } catch (Exception e) {
        EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI_BulkLoad.SaveCsvToObject.execute()', e));
        String errMsg = 'Line=' + e.getLineNumber() + ', ErrMsg=' + e.getMessage();
        result.status.add('Upload Failed (Technical Error)');
        result.message = '[Unexpectred Error at ' + errMsg + ']' + result.message;
        outJSON = JSON.serialize(result);
      }
      return;
   }  // execute

   global void finish(Database.BatchableContext BC)
   {
        result.buh.File_Upload_Date_EI__c = System.Now();
        result.buh.Error_Count_EI__c      = result.errorCount;
        result.buh.Success_Count_EI__c    = result.successCount;
        if ( result.status.contains('Upload Failed (Technical Error)') ) {
           result.buh.Bulk_Upload_Sta_EI__c = 'Upload Failed (Technical Error)';
        } else if ( result.errorCount > 0 ) {
             result.buh.Bulk_Upload_Sta_EI__c = 'Completed with Errors';
        } else if ( result.errorCount == 0 && result.successCount == result.recordCount) {
           result.buh.Bulk_Upload_Sta_EI__c = 'Completed Successfully';
        }
        System.debug('\r\nresult ==============\r\n' + result);

        update result.buh;

        String buhName = [SELECT id, name FROM EI_Bulk_Upload_History__c WHERE id = :result.buh.id].name;

        outJSON = JSON.serialize(result);

        system.debug('\r\nresult.successRows ================== \r\n' + result.successRows);

        // 
        String successCsv       = 'Id,'+ header + RECORD_DELIMITER + 
                                  String.join(result.successRows,RECORD_DELIMITER);
        Blob   successfile      = Blob.valueof(successCsv);
        String successFileName  = buhName + '_success_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
        String successFileTitle = buhName + '_success_' + Datetime.now().format('YYYYMMdd_hhmm');
        if ( result.successCount > 0 ) 
           insertFile(successfile, successFileTitle, successFileName, result.buh.id, inArg.libraryName);

        String errorCsv         = header + ',Message' + RECORD_DELIMITER + 
                                  String.join(result.errorRows,RECORD_DELIMITER);
        Blob   errorfile        = Blob.valueof(errorCsv);
        String errorFileName    = buhName + '_error_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
        String errorFileTitle   = buhName + '_error_' + Datetime.now().format('YYYYMMdd_hhmm');
        if ( result.errorCount > 0 ) 
           insertFile(errorfile, errorFileTitle, errorFileName,  result.buh.id, inArg.libraryName);
        
        if (!inArg.storeSourceFile && inArg.documentId <> null) {
           // Delete source csv file loaded to Salesforce Files
           ContentDocument[] srcList =[select Title, Description, parentid
                                         from ContentDocument  
                                        where id = :inArg.documentId ];
           
           if (srcList <> null && srcList.size() > 0) {
              delete srcList ;  
              database.emptyRecycleBin(srcList);
           }
        }
        
        String jsonPass = (inArg.tgtArg == null)?'':inArg.tgtArg.trim();
        if (jsonPass == '' ) {
           
           jsonPass = '{"buhId":"' + String.valueOf(result.buh.id) + '", "libraryName":"' + inArg.libraryName + '"}';
        } else {
        	 Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonPass);
           m.put('buhId', result.buh.id);
           m.put('libraryName', inArg.libraryName);

           jsonPass = JSON.serialize(m);
           System.debug('jsonPass ======================jsonPass ======================== \r\n' + jsonPass );
        }

        String rtnJSON = '';
        if (inArg.className<> null && inArg.className.length() > 0 )  
           rtnJSON = DynamicApex.execute(inArg.className, jsonPass);
        System.debug('rtnJSON ===================================== ' + rtnJSON );

   }  //  finish  

   public static Integer saveCsv2object ( String argCsvData, String argObjectApiName, 
                                          Map<String,String> mapReqFields,
                                          String argDML,     String argExtField, 
                                          BulkloadResult outResult ) 
   {
      String    RECORD_DELIMITER  = '\r\n';
      Integer   intReturn         = 0;
      Integer   successCnt        = 0;
      Integer   errorCnt          = 0;
      ID[]      successIDs        = new ID[0];
      String    strHeader;
      String[]  csvRecords        = new String[0];
      String[]  validCsvRecords   = new String[0];

      sObject[] objList           = new sObject[0];

      system.debug('\r\nargCsvData =============================== ' + argCsvData);

      SavePoint sp = Database.setSavePoint();
      try {
         // remove header
         csvRecords  = argCsvData.split(RECORD_DELIMITER);
         strHeader = csvRecords.remove(0) + ',Processing_Status__c';
         System.debug('strHeader === ' + strHeader);

         outResult.processedCount = csvRecords.size();
         // review

         Type t = Type.forName('List<' + argObjectApiName + '>');
         for(String r: csvRecords) {

            String  csvRecord = strHeader + RECORD_DELIMITER + r + ',Loaded';
            System.debug('csvRecord === ' + csvRecord);
            String    jsonRecord = JSONLib.csvToJSON(csvRecord);
            sObject[] objectList = (List<sObject>)JSON.deserialize(jsonRecord , t );
            sObject   objRecord  = objectList[0];

            System.debug('jsonRecord === ' + jsonRecord);
            System.debug('objRecord === ' + objRecord);

            // check required fields
            String errMsg = '', value;
            for ( String fieldApi : mapReqFields.keySet()) {
               value = (String)objRecord.get(fieldApi);
               if (value == null || value == '')  
                  errMsg += (errMsg.length() > 0 )?',':'' + mapReqFields.GET(fieldApi);
            }
            System.debug('errMsg === ' + errMsg);
            if (errMsg.length() > 0 ) {
               // missing required fields
               outResult.errorRows.add(r + ',Required field(s) ' + errMsg + ') missing');
               outResult.errorCount++;
            } else {
               objList.add(objRecord);
               validCsvRecords.add(r);
            }
         }

         System.debug('objList size === ' + objList.size());
         System.debug('objList === ' + objList);

         String dmlAction = (argDML==null)?'INSERT':argDML.toUpperCase();
         switch on dmlAction {
            when 'INSERT' { 
               Database.SaveResult[] srList = Database.insert(objList, false);
               Integer srIndex = 0;
               for (Database.SaveResult sr : srList) {
                  if (sr.isSuccess()) {
                     String strId = String.valueOf(sr.getId());
                     outResult.successRows.add(strId + ',' + validCsvRecords[srIndex++]);
                     outResult.successCount++;
                     outResult.successIds.add(strId);
                  } else {
                     // Operation failed, so get all errors
                     String errMsg = '';
                     for(Database.Error err : sr.getErrors()) {
                        errMsg += (errMsg.length() > 0 )?'; ':'' + err.getMessage() + '(' + err.getFields() + ')';
                        // System.debug('The following error has occurred.');
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                     }
                     errMsg = 'The following error has occurred: ' + errMsg;
                     outResult.errorRows.add(validCsvRecords[srIndex++] + ',' + errMsg);
                     outResult.errorCount++;
                  }
               }
            }
            when 'UPSERT' { 
               Database.UpsertResult[] urList = Database.upsert(objList, false);
               Integer usIndex = 0;
               for (Database.UpsertResult ur : urList) {
                  if (ur.isSuccess()) {
                     String strId = String.valueOf(ur.getId());
                     outResult.successRows.add(strId + ',' + validCsvRecords[usIndex++]);
                     outResult.successCount++;
                     outResult.successIds.add(strId);
                  } else {
                     // Operation failed, so get all errors
                     String errMsg = '';
                     for(Database.Error err : ur.getErrors()) {
                        errMsg += (errMsg.length() > 0 )?'; ':'' + err.getMessage() + '(' + err.getFields() + ')';
                        // System.debug('The following error has occurred.');
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                     }
                     errMsg = 'The following error has occurred: ' + errMsg;
                     outResult.errorRows.add(validCsvRecords[usIndex++] + ',' + errMsg);
                     outResult.errorCount++;
                  }
               }
            }
            when 'UPDATE' { 
               Database.SaveResult[] upList = Database.update(objList, false);
               Integer upIndex = 0;
               for (Database.SaveResult sr : upList) {
                  if (sr.isSuccess()) {
                     String strId = String.valueOf(sr.getId());
                     outResult.successRows.add(strId + ',' + validCsvRecords[upIndex++]);
                     outResult.successCount++;
                     outResult.successIds.add(strId);
                  } else {
                     // Operation failed, so get all errors
                     String errMsg = '';
                     for(Database.Error err : sr.getErrors()) {
                        errMsg += (errMsg.length() > 0 )?'; ':'' + err.getMessage() + '(' + err.getFields() + ')';
                        // System.debug('The following error has occurred.');
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                     }
                     errMsg = 'The following error has occurred: ' + errMsg;
                     outResult.errorRows.add(validCsvRecords[upIndex++] + ',' + errMsg);
                     outResult.errorCount++;
                  }
               }
            }
            when else { // default block, optional
            }
         }

         // fom the SOQL to retrieve the created records with SFIDs
         String query = 'select id, name from ' + argObjectApiName + ' where id in (\'';
         query = query + String.join(outResult.successIds, '\',\'') + '\')';
         sObject[] savedObjects = Database.query(query);
         for (sObject so : savedObjects ) system.debug('\r\n============ object created ============\r\n' + so );
         system.debug('\r\nQuery ===========================================\r\n' + query );

         if (outResult.errorCount > 0 ) { 
            outResult.errorcode = '-1';
            outResult.message   = 'Completed with Errors';
            outResult.status.add('Completed with Errors');
         } else if (outResult.successCount > 0) {
              outResult.errorcode = '0';
            outResult.message   = 'Completed Successfully';
            outResult.status.add('Completed Successfully');
         }

         intReturn = outResult.successCount;
         system.debug('outResult In saveCsv2Object ==== ' + outResult);
      } catch (Exception e) {
           Database.rollback(sp);
           EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('EI_BulkLoad.saveCsv2object()', e));
           outResult.status.add('Upload Failed (Technical Error)');
           outResult.successCount = 0;
           outResult.errorCount   = outResult.processedCount;
           outResult.errorcode    = '-1';
           outResult.message      = 'Upload Failed (Technical Error)';
           intReturn = 0;
      }  
      return intReturn;
   }  // saveCsv2object

   public static void insertFile(Blob argFile, String argTitle, String argFileName, 
                                    Id argRecordId, String argLib) 
   {
       ContentWorkspace[]  bulkLibs = [ select id, name from ContentWorkspace where name = :argLib];
       
       ContentVersion conVer = new ContentVersion();
       conVer.PathOnClient   = argFileName; 
       conVer.Title          = argTitle; 
       conVer.Description    = argFileName; 
       conVer.VersionData    = argFile; 
       if ( bulkLibs.size() > 0 ) conVer.FirstPublishLocationId = bulkLibs[0].id;
       insert conVer;    

       // Get Content Documents
       ContentDocument conDoc = [SELECT Id, Title, ParentId
                                   FROM ContentDocument 
                                  WHERE LatestPublishedVersionId =: conVer.Id];
       //Create ContentDocumentLink 
       ContentDocumentLink conDocLink = New ContentDocumentLink();
       conDocLink.LinkedEntityId      = argRecordId;
       conDocLink.ContentDocumentId   = conDoc.Id;
       conDocLink.shareType           = 'V';
       Insert conDocLink; 
       
       // conDoc.ParentId                = bulkLib.id;
       // update conDoc;
   }  // insertFile

   public static void setPlacSummary(Id buhId, String placSummary) 
   {
       EI_Bulk_Upload_History__c buh = [ select id, Error_Sum_EI__c
                                           from EI_Bulk_Upload_History__c 
                                          where id = :buhId];
       String summary                = (buh.Error_Sum_EI__c== null)?'':buh.Error_Sum_EI__c;
       buh.Error_Sum_EI__c           = summary + ' ' + placSummary;

       update buh;
       
       return;
   }  // setPLACCount

   public static Object csvToObject ( String argCsvData, String argTypeName ) {
       
      String jsonData = JSONLib.csvToJSON(argCsvData);
      
      Type t = Type.forName('List<' + argTypeName + '>');
      system.debug('Type = ' + t);

      Object objList = JSON.deserialize(jsonData , t);
      
      system.debug('objList =' + objList );
      
      return objList;
   }

   @AuraEnabled
    global static String getBuhList() {
       BuhWrapper[] buhwLIst               = new BuhWrapper[0];
       EI_Bulk_Upload_History__c[] buhList = 
          [select id, name,  Bulk_Upload_Sta_EI__c, File_Rec_Count_EI__c, Success_Count_EI__c, 
                  Error_Count_EI__c, File_Upload_Date_EI__c, File_Name_EI__c, Account_EI__c, 
                  createddate, createdby.name, Error_Sum_EI__c,
                  (SELECT Id, ContentDocumentId, LinkedEntityId, contentdocument.title   
                     FROM contentdocumentlinks ) 
             from EI_Bulk_Upload_History__c
            where createddate = LAST_N_DAYS:10
            order by createddate desc];

       for (EI_Bulk_Upload_History__c buh : buhList) {
           BuhWrapper buhw = new BuhWrapper();
           buhw.buhId           = (String)buh.id;
           buhw.uploadBy        = buh.createdby.name;
           buhw.name            = buh.name;
           buhw.fileName        = buh.File_Name_EI__c;
           buhw.Status          = buh.Bulk_Upload_Sta_EI__c;
           buhw.recordCount     = buh.File_Rec_Count_EI__c.intValue();
           buhw.successCount    = buh.Success_Count_EI__c.intValue();
           buhw.errorCount      = buh.Error_Count_EI__c.intValue();
           buhw.uploadDate      = buh.File_Upload_Date_EI__c.format('MM/dd/YYYY');
           buhw.resultSummary   = buh.Error_Sum_EI__c;
           
           ContentDocumentLink[] documents = buh.contentdocumentlinks;
           if(documents <> null) { 
              for(ContentDocumentLink doc :documents) {
                 if( doc.ContentDocument.Title.containsIgnoreCase('success') ) {
                    buhw.successFileId = doc.ContentDocumentid;
                    buhw.successFile   = '/' + doc.ContentDocumentid;
                 } else if ( doc.ContentDocument.Title.containsIgnoreCase('error') ){
                    buhw.errorFileId = doc.ContentDocumentid;
                    buhw.errorFile   = '/' + doc.ContentDocumentid;
                 } else       //if ( doc.ContentDocument.Title.containsIgnoreCase('result') ){
                 {
                    buhw.resultFileId = doc.ContentDocumentid;
                    buhw.resultFile   = '/' + doc.ContentDocumentid;
                 }
              }
           }
           buhwLIst.add(buhw);
       }

       String jsonReturn = JSON.serialize(buhwLIst);
       return jsonReturn;
    }

   static public String[] parseCsvLine(String csvRow){  
        final String DELIMITER = ',';
        if(csvRow == null || csvRow == '')  return null;
        String line = csvRow;
        String[] parts = new String[] {};

            try {
                
                while(line != ''){
                    Integer next = 0;
                    if(line.startsWith('"')){
                        line = line.substring(1); // strip initial
                        Integer quoteIndex = findQuote(line, 0);
                        while(quoteIndex == -1){
                            quoteIndex = line.length();
                        }
                        // advance to comma
                        next = quoteIndex + 1;
                        parts.add(line.substring(0, quoteIndex).replace('""', '"'));
                    } else {
                        next = line.indexOf(DELIMITER, next);
                        if(next == -1)
                            next = line.length();
                        // NB in Substring, "endindex" is the index of the character AFTER the last index to get
                        parts.add(line.substring(0, next));
                    }
                    if(next == line.length() - 1)
                        // case of a terminating comma.
                        parts.add('');
                    line = next < line.length() ? line.substring(next+1) : '';
                }
                if(parts.size() == 0) parts = null;
            } catch (Exception e) {
                EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('DGPS_Migration.start()', e));
                parts = null;
            }
        return parts;
    }

    static private Pattern quotePattern = Pattern.compile('(?<!")"(?!")'); 

    static private Integer findQuote(String line, Integer skip){            
        Matcher m = quotePattern.matcher(line);
        m.region(skip, m.regionEnd());
        if(!m.find()) return -1;
        return m.start();
    }
    
    // custom iterator to represent the rows in the csv file
    global class csvRowIterator implements Iterator<String>, Iterable<String>
    {
       private Iterator<String>     rowsIterator;

       public csvRowIterator (List<String> argCsvRows) {
          rowsIterator = argCsvRows.iterator();
       }

       global Boolean hasNext() {
          return rowsIterator.hasNext(); 
       }

       global String next() {
          return rowsIterator.next();
       }
       
       global Iterator<String> Iterator() {
          // returns all rows in the csv file in the form of a single iterator object.
          return this;
       }
    }

    //wrapper classes
    public class BulkUploadWrapper {
        public String   objectAPI;
        public String   csvData;
        public String   csvFileName;
        public String   dmlAction;
        public String   extFieldAPI;
        public String   showData;
        public String   className;
        public String   tgtObjectAPI;
        public String   tgtArg;
        public String   documentId; 
        public String   libraryName;
        public Integer  batchSize = 2000;
        public boolean  storeSourceFile = false;
        public String[]               reqFields;
        public List<FieldMapSection>  csvFieldMap;
        public List<ParmSection>      parmList;
    }

    public class FieldMapSection{
        public String srcFieldAPI;
        public String tgtFieldAPI;
        public String datatype;
        public FieldMapSection(String a1,String a2,String a3) {
           srcFieldAPI = a1; tgtFieldAPI = a2; datatype    = a3;
        }
    }

    public class ParmSection{
        public String objectAPI;
        public String fieldAPI;
        public String value;
        public ParmSection(String a1,String a2,String a3) {
           objectAPI = a1; fieldAPI = a2; value = a3;
        }
    }

    // status:    In Progress, Upload Failed (Technical Error),
    //            Completed with Errors, Completed Successfully
    //            same as picklist of EI_Bulk_Upload_History__c.Bulk_Upload_Sta_EI__c
    // errorcode: 0: no error -1: there is error
    public class BulkloadResult{
       public String   errorcode            = '0';           
       public String   message              = '';  
       public Integer  recordCount          = 0;
       public Integer  successCount         = 0;
       public Integer  errorCount           = 0;
       public Integer  processedCount       = 0;
       public String   AsyncApexJobId;
       public String[] successRows          = new String[0];
       public String[] errorRows            = new String[0];
       public String[] successIds           = new String[0];
       public String[]     status           = new String[0];
       public EI_Bulk_Upload_History__c buh = new EI_Bulk_Upload_History__c();

       public BulkloadResult(String a1, String a2, Integer a3) {
          errorcode = a1; message = a2; successCount = a3; 
       }
       public BulkloadResult(){
          message = 'loading data';
       }

       public void add(BulkloadResult arg) {
          if (errorcode == '-1' || arg.errorcode =='-1')      {
             errorcode = '-1';
          } else if (errorcode == '0' && arg.errorcode =='0') {
              errorcode = '0';
          } 
          status.addAll(arg.status);
          message        += (message.length() > 0)?',':'' + arg.message;
          processedCount += arg.processedCount;
          successCount   += arg.successCount;
          errorCount     += arg.errorCount;
          successRows.addALL(arg.successRows);
          errorRows.addALL(arg.errorRows);
          successIds.addALL(arg.successIds);
       }
    }

    public class BuhWrapper{
       public String  buhId;
       public String  name;
       public String  fileName;
       public String  Status;
       public Integer recordCount;
       public Integer successCount;
       public Integer errorCount;
       public String  successFileId;
       public String  errorFileId;
       public String  resultFileId;
       public String  successFile;
       public String  errorFile;
       public String  resultFile;
       public String  resultSummary;
       public String  uploadDate;
       public String  uploadBy;
    }

}

/*========================= load csv file to list of Apex class in memory  ===================
// Sample code for PSPS_EI2CCBPersonWrapper.personIdentifiers
String csvFile = 'idType,idValue\r\n' + 'TIN,123456701\r\n' + 'TIN,123456702\r\n' + 'TIN,123456703\r\n' + 'TIN,123456704\r\n' + 'TIN,123456705\r\n' + 'TIN,123456706\r\n';

String className = 'PSPS_EI2CCBPersonWrapper.personIdentifiers';
Object objList = EI_BulkLoad.csvToObject(csvFile, className );

PSPS_EI2CCBPersonWrapper.personIdentifiers[] personIDs = (PSPS_EI2CCBPersonWrapper.personIdentifiers[])objList;

System.debug('\r\n==================================================== ' + personIDs.size() + ' Person Identifiers are loaded ========\r\n');
for ( PSPS_EI2CCBPersonWrapper.personIdentifiers p: personIDs) 
System.debug('\r\n=============================================== ' + p);

==============================================================================================*/