@isTest
public class EI_BulkloadTest {

   @isTest static void test() {  

      // create the test csv file and load it into Salesforce Files
      String csvFileContact = 'Title,First Name,Last Name,Email,Birthdate,notExist\r\n'                    +
                              'test manager,Super,Man,helloemail@sfdc.com,1980-01-02,1\r\n'       +
                              'test manager,Sleeping,Beauty,helloemail@sfdc.com,1980-01-30,2\r\n' +
                              'test manager,Hello,Catty,Caty@hello.com,1980-08-27,3\r\n'          +
                              'test manager,Snow,White,Caty@hello.com,1980-10-02,4\r\n'           +
                              'test manager,Little,Mermaid,Caty@hello.com,1980-12-23,5\r\n';
      // load the test csv file into Salesforce Files
      ContentVersion conVer = new ContentVersion();
      conVer.PathOnClient   = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
      conVer.Title          = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm');
      conVer.Description    = 'Source csv file [contact]';
      conVer.VersionData    = Blob.valueOf(csvFileContact);
      insert conVer;
      
      // Get Content Documents
      ContentDocument conDoc = [SELECT Id, Title, ParentId
                                  FROM ContentDocument 
                                 WHERE LatestPublishedVersionId =: conVer.Id];
      
      // field map of csv header and field ApiName
      EI_BulkLoad.FieldMapSection[] csvFmsList = new EI_BulkLoad.FieldMapSection[0];
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('name', 'name', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('BillingStreet', 'BillingStreet', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('City', 'BillingCity', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Annual sales', 'AnnualRevenue', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Contract Start Date', 'Contract_Start_Date_EI__c', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('First Name', 'FirstName', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Last Name', 'LastName', '') );
      
      // set up constants
      EI_BulkLoad.ParmSection[] parmList = new EI_BulkLoad.ParmSection[0];
      parmList.add(new EI_BulkLoad.ParmSection('Contact', 'DoNotCall', 'true' ) );
      
      // other parameters
      EI_BulkLoad.BulkUploadWrapper blkArg = new EI_BulkLoad.BulkUploadWrapper();
      blkArg.objectAPI       = 'Contact';
      blkArg.csvFileName     = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
      blkArg.reqFields       = new String[]{'FirstName','LastName'};
      blkArg.dmlAction       = 'INSERT';
      blkArg.csvFieldMap     = csvFmsList;  
      blkArg.parmList        = parmList;   
      blkArg.className       = 'DynamicApex.MyClassName';
      blkArg.documentId      = (String)conDoc.id;
      blkArg.libraryName     = 'Bulkload Home';
      blkArg.storeSourceFile = false;
      blkArg.batchSize       = 200;

      Test.startTest();
      
      Object objList     = EI_BulkLoad.csvToObject(csvFileContact, 'Contact' );

      String jsonInArg   = JSON.serialize(blkArg);
      String jsonReturn  = EI_BulkLoad.loadCSVFile(jsonInArg);
      
      blkArg.dmlAction   = 'UPSERT';
      String jsonInArg2  = JSON.serialize(blkArg);
      String jsonReturn2 = EI_BulkLoad.loadCSVFile(jsonInArg2);
      
      Test.stopTest();

      String buhList = EI_BulkLoad.getBuhList();
      

      system.debug('\r\n\r\njsonINArg===================================================================== '  + jsonINArg);
      system.debug('\r\n\r\njsonReturn===================================================================== ' + jsonReturn);
   }
   
   @isTest static void testUpdate() {  
      Contact[] cc = new Contact[0];

      cc.add(new Contact(FirstName='Hello_01', lastName='Kitty_01', Title='test manager') );
      cc.add(new Contact(FirstName='Micky_01', lastName='Mouse_01', Title='test manager') );
      
      insert cc;
      
      String Id_00 = String.valueOf(cc[0].id);
      String Id_01 = String.valueOf(cc[1].id);
      
      String csvFileContact = 'ID,Title,First Name,Last Name,Email,Birthdate,notExist\r\n'            +
                              Id_00 + ',test manager,Snow,White,Caty@hello.com,1981-10-02,4\r\n'      +
                              Id_01 + ',test manager,Little,Mermaid,Caty@hello.com,1980-12-23,5\r\n';

      // load the test csv file into Salesforce Files
      ContentVersion conVer = new ContentVersion();
      conVer.PathOnClient   = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
      conVer.Title          = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm');
      conVer.Description    = 'Source csv file [contact]';
      conVer.VersionData    = Blob.valueOf(csvFileContact);
      insert conVer;
      
      // Get Content Documents
      ContentDocument conDoc = [SELECT Id, Title, ParentId
                                  FROM ContentDocument 
                                 WHERE LatestPublishedVersionId =: conVer.Id];
      
      // field map of csv header and field ApiName
      EI_BulkLoad.FieldMapSection[] csvFmsList = new EI_BulkLoad.FieldMapSection[0];
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('name', 'name', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('BillingStreet', 'BillingStreet', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('City', 'BillingCity', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Annual sales', 'AnnualRevenue', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Contract Start Date', 'Contract_Start_Date_EI__c', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('First Name', 'FirstName', '') );
      csvFmsList.add(new EI_BulkLoad.FieldMapSection('Last Name', 'LastName', '') );
      
      // set up constants
      EI_BulkLoad.ParmSection[] parmList = new EI_BulkLoad.ParmSection[0];
      parmList.add(new EI_BulkLoad.ParmSection('Contact', 'DoNotCall', 'true' ) );
      
      // other parameters
      EI_BulkLoad.BulkUploadWrapper blkArg = new EI_BulkLoad.BulkUploadWrapper();
      blkArg.objectAPI       = 'Contact';
      blkArg.csvFileName     = 'Contact_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
      blkArg.reqFields       = new String[]{'FirstName','LastName'};
      blkArg.dmlAction       = 'UPDATE';
      blkArg.csvFieldMap     = csvFmsList;  
      blkArg.parmList        = parmList;   
      blkArg.className       = 'DynamicApex.MyClassName';
      blkArg.documentId      = (String)conDoc.id;
      blkArg.libraryName     = 'Bulkload Home';
      blkArg.storeSourceFile = false;
      blkArg.batchSize       = 200;

      String jsonInArg   = JSON.serialize(blkArg);
      String jsonReturn  = EI_BulkLoad.loadCSVFile(jsonInArg);
   }
   
}