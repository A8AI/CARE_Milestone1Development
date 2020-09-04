/**************************************************************************************************
Apex Class Name      :  EI_BulkLoad
Version              :  1.0
Created Date         :  07/17/2020
Function             :  Library to convert data between csv, tab, and JSON
Story                :
Work Task            :
Modification Log     :
*--------------------------------------------------------------------------------------------------
* Developer          Date                   Description
* -------------------------------------------------------------------------------------------------
* LXX1               07/17/2020             Initial Version
***************************************************************************************************/
Public Class JSONLib {

   static private final String DELIMITER         = ',';
   static private final String RECORD_DELIMITER  = '\r\n';
   static private Pattern[] patternList = new Pattern[] 
   {
      Pattern.compile('^(^\\d)'),
      Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/(\\d{4})'),
      Pattern.compile('(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])-(\\d{4})')
   };

   public static Integer loadJSONData ( String jsonData, String objectApiName ) {
       
      Type t = Type.forName('List<' + objectApiName + '>');
      system.debug('Type = ' + t);

      list<sObject> objList = (List<sObject>)JSON.deserialize(jsonData , t);
      
      system.debug('objList =' + objList );
      
      return objList.size();
   }

   public static Integer loadCsvFile ( String csvData, String objectApiName ) {

      String   jsonData = csvToJSON(csvData);

      Type t = Type.forName('List<' + objectApiName + '>');
      system.debug('Type = ' + t);

      list<sObject> objList = (List<sObject>)JSON.deserialize(jsonData , t);

      insert objList;
      
      String query = 'select id, name from ' + objectApiName + ' where id in (';
      for (sObject so : objList ) query = query + '\'' + (String)so.id + '\','; 
      query = query + '\'\')';
      
      sObject[] sobjList = Database.query(query);
      for (sObject so : sobjList ) system.debug('\r\nobject created ============' + so );
      
      system.debug('\r\nQuery ===========================================\r\n' + query );
      
      return objList.size();
   }
   
   public static Object csvToObject ( String argCsvData, String argTypeName ) {
       
      String jsonData = csvToJSON(argCsvData);
      
      Type t = Type.forName('List<' + argTypeName + '>');
      system.debug('Type = ' + t);

      Object objList = JSON.deserialize(jsonData , t);
      
      system.debug('objList =' + objList );
      
      return objList;
   }

   public static String csvToJSON ( String csvData ) {
        
      String   headerRow, rtnJSON = '{"Error": "Unexpected eror."}';
      Integer  headerCount;
      String[] headerList, dataList;
      String[] fileRows = csvData.split(RECORD_DELIMITER);
      

         if ( fileRows <> null && fileRows.size() > 1 ) {
            headerRow   = fileRows.remove(0).toUpperCase();
            headerList  = parseCsvLine(headerRow);
            headerCount   = headerList.size();
            if ( !(headerCount> 0) ) return '{ "Error": "There is no header in the csv file."}';
         } else {
             rtnJSON = '{"Error": "There is no data in the csv file"}';
             return rtnJSON;
         }

         JSONGenerator gen = JSON.createGenerator(true);
         gen.writeStartArray();

         for(String r : fileRows) {
            Integer i = 0;
            dataList = parseCsvLine(r);

            if (dataList.size() <> headerCount ) {
               rtnJSON = '{"Error": "Number of fields at line ' + String.valueOf(i+1) + ' not equal to number of headers."}';
               return rtnJSON;
            }

            gen.writeStartObject();
            for (String value : dataList) gen.writeStringField(headerList[i++].trim(), getJSONValue(value));
            gen.writeEndObject();

         }

         gen.writeEndArray();
         rtnJSON = gen.getAsString();
         
         system.debug('\r\n====================\r\nRetrun Variable rtnJSON =\r\n' + rtnJSON );
         return rtnJSON;

   }

   public static String tabToJSON ( String tabData ) {

      String   headerRow, rtnJSON = '{"Error": "Unexpected eror."}';
      String   TAB = '\t', RECORD_DELIMITER = '\r\n';
      Integer  headerCount;
      String[] headerList, dataList;
      String[] fileRecords = tabData.split(RECORD_DELIMITER);
              
         if ( fileRecords <> null && fileRecords.size() > 1 ) {
            headerRow   = fileRecords.remove(0).toUpperCase();
            headerList  = headerRow.split(TAB);
            headerCount = headerList.size();
            if ( !(headerCount> 0) ) return '{ "Error": "There is no header in the data file."}';
         } else {
            return '{"Error": "There is no data in the data file"}';
         }

         JSONGenerator gen = JSON.createGenerator(true);
         gen.writeStartArray();

         for(String record : fileRecords) {
            Integer i = 0;
            dataList = record.split(TAB);

            if (dataList.size() <> headerCount ) {
               rtnJSON = '{"Error": "Number of fields at line ' + String.valueOf(i+1) + ' not equal to number of headers."}';
               return rtnJSON;
            }

            gen.writeStartObject();
            for (String value : dataList) gen.writeStringField(headerList[i++].trim(), getJSONValue(value));
            gen.writeEndObject();

         }

         gen.writeEndArray();
         rtnJSON = gen.getAsString();
         
         system.debug('\r\n====================\r\nRetrun Variable rtnJSON =\r\n' + rtnJSON );
         return rtnJSON;
   }

   public static Object tabToObject ( String argTabData, String argTypeName ) {

      String jsonData = tabToJSON(argTabData);

      Type t = Type.forName('List<' + argTypeName + '>');
      system.debug('Type = ' + t);

      Object objList = JSON.deserialize(jsonData , t);

      system.debug('objList =' + objList );

      return objList;
   }

   public static Object tabArrayToObject ( String[] argTabData, String argTypeName ,String[] headerList, String dateFormat ) {

      String   TAB           = '\t';
      String[] dataList;
      Integer  headerCount;
      Pattern  datePattern   = Pattern.compile('');
      
      switch on dateFormat.trim().toUpperCase() {
         when 'MM/DD/YYYY' {
            datePattern  = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/(\\d{4})');
         }
         when 'MM-DD-YYYY' {
            datePattern  = Pattern.compile('(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])-(\\d{4})');
         }
         when 'YYYY-MM-DD' {

         }
         when else {

         }
      }

      headerCount = headerList.size();
      if ( !(headerCount> 0) ) return null;

      JSONGenerator gen = JSON.createGenerator(true);
      gen.writeStartArray();

      for(String record : argTabData) {
         Integer i = 0;
         dataList = record.split(TAB);

         if (dataList.size() <> headerCount ) {
            return null;
         }

         gen.writeStartObject();
         for (String value : dataList) {
            // convert the date format to yyyy-mm-dd
            Matcher  dateMatcher = datePattern.matcher(value.trim());
            String fieldValue = dateMatcher.matches()?getSFDate(dateMatcher, dateFormat):value.trim();
            gen.writeStringField(headerList[i++].trim(), fieldValue);
         }
         gen.writeEndObject();
      }

      gen.writeEndArray();
      String jsonData = gen.getAsString();
      
      system.debug('\r\n====================\r\njsonData =\r\n' + jsonData );
      
      Type t = Type.forName('List<' + argTypeName + '>');
      system.debug('Type = ' + t);

      Object objList = JSON.deserialize(jsonData , t);

      system.debug('objList =' + objList );

      return objList;
   }    // tabArrayToObject

   // convert date value to string in yyyy-mm-dd
   public static String getSFDate(Matcher dateMatcher, String dateFormat) {
      String dateString;
      switch on dateFormat.trim().toUpperCase() {
         when 'MM/DD/YYYY' {
            dateString = dateMatcher.group(3) + '-' + dateMatcher.group(1)  + '-' + dateMatcher.group(2);
         }
         when 'MM-DD-YYYY' {
            dateString = dateMatcher.group(3) + '-' + dateMatcher.group(1)  + '-' + dateMatcher.group(2);
         }
         when 'YYYY-MM-DD' {

         }
         when else {

         }
      }
      return dateString;
   }
   
   // convert date value to string in yyyy-mm-dd
   public static String getJSONValue(String argValue) {

      String    jsonDateSting = argValue.trim() ;
      Pattern[] patterns      = new List<Pattern>(patternList);

      if (patterns[0].matcher(jsonDateSting).matches()) return jsonDateSting; 
      else  patterns.remove(0);

      for (Pattern p: patterns) {
         Matcher dateMatcher = p.matcher(jsonDateSting);
         if ( dateMatcher.matches() ) {
            jsonDateSting = dateMatcher.group(3) + '-' + dateMatcher.group(1).leftPad(2,'0')  + '-' + dateMatcher.group(2).leftPad(2,'0');
            break;
         }
      }
      return jsonDateSting;
   }
   
   public static void logMessage ( 
      String  className,
      String  methodName,
      String  variableName,
      Integer lineNumer,
      String  message       ) 
   {
      EI_Exception_Log__c logMessage = new EI_Exception_Log__c(
         Apex_Class_Name_EI__c = className, 
         Line_Number_EI__c     = lineNumer, 
         Exception_Type_EI__c  = 'Log', 
         SSL_Record_ID__c      = methodName,
         SSL_Record_Name__c    = variableName,
         Error_Message_EI__c   = message.length() > 32768? message.substring(0, 32767) : message 
      );

      EI_CreateErrorLog.upsertExceptionForSetupObject(logMessage);
   }

   static public String[] parseCsvLine(String csvRow){  
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
    

}


/* test csv to JSON to SF Object which is passed as a String parameter -----------------------

String jsonData = '[ { "Name": "Bank Account", "AccountNumber": "acct-1234567", "CARE_PROBATION_START_DATE__c": "2019-12-21"}, ' +
           '  { "Name": "Salesforce Account", "AccountNumber": "acct-9874563", "CARE_PROBATION_START_DATE__c": "2019-09-21"} ]';
String objectApiName  = 'Account';

Integer rtn = JSONLib.loadJSONData(jsonData, objectApiName  );

system.debug('rtn =' + rtn );

--------------------------------------------------------------------------------------------*/

/* convert csv file to JSON String -----------------------------------------------------------
// makes sure the trim the all fields data before write it to JSON String
   
String csvFile = 'name,BillingStreet,BillingCity,AnnualRevenue,CARE_PROBATION_START_DATE__c\r\n';
csvFile = csvFile  + 'Hello Kitty,100 Main Street,Fremont,2002.00,2019-07-12\r\n';
csvFile = csvFile  + 'Donald Duck,200 Main Street,Fremont,3003.00,2019-07-13\r\n';
csvFile = csvFile  + 'Micky\'s Caffe,400 Main Street,Fremont,4004.00,2019-07-14\r\n';
csvFile = csvFile  + 'Magic_Character"&!#,500 Main Street,Fremont,5005.00,2019-07-15\r\n';

system.debug('\r\n====================\r\ncsvFile = \r\n' + csvFile );

String jsonData = JSONLib.csvToJSON(csvFile);

Account[] accounts = (List<Account>)JSON.deserialize(jsonData , List<Account>.class);

system.debug('\r\n====================\r\nTest Account List = \r\n' + accounts + '\r\n\r\n' );

// 1. convert csv file to JSON String
// 2. convert to JSON String SF Object which is passed as a String parameter
String objectApiName  = 'Account';
Integer rtn = JSONLib.loadJSONData(jsonData, objectApiName  );

system.debug('\r\n====================\r\nNumber of sObject created = \r\n' + rtn + '\r\n\r\n' );

select name,BillingStreet,BillingCity,AnnualRevenue,CARE_PROBATION_START_DATE__c, createddate
from account
order by createddate desc


/*==============================================================================================
// Load csv file to Contact object
// Hard Delete
sObject[] itemList = [select id, name, title, firstname, lastname, email, AccountId, Birthdate from contact  where title = 'test manager'];
delete itemList ;  
database.emptyRecycleBin( itemList );

String csvFile = 'Title,FirstName,LastName,Email,AccountId,Birthdate\r\n';
csvFile = csvFile  + 'test manager,Super,Man,helloemail@sfdc.com,0013K000008ejB5QAI,1980-01-02\r\n';
csvFile = csvFile  + 'test manager,Sleeping,Beauty,helloemail@sfdc.com,0013K000008ejB5QAI,1980-01-30\r\n';
csvFile = csvFile  + 'test manager,Hello,Catty,Caty@hello.com,0013K000008ejB5QAI,1980-08-27\r\n';
csvFile = csvFile  + 'test manager,Snow,White,Caty@hello.com,0013K000008ejB5QAI,1980-10-02\r\n';
csvFile = csvFile  + 'test manager,Little,Mermaid,Caty@hello.com,0013K000008ejB5QAI,1980-12-23\r\n';

String objectApiName  = 'Contact';

system.debug('\r\n====================\r\ncsvFile = \r\n' + csvFile );

Integer rtn = JSONLib.loadCsvFile(csvFile , objectApiName  );

system.debug('\r\n====================\r\nNumber of sObject created = \r\n' + rtn + '\r\n\r\n' );

==================================================================================================
String tabDelimitedFile = 'Id\tSvc_Status_Code_EI__c\tBilling_Account_ID_EI__c\tSAID_EI__c\tCust_Type_EI__c\tStreet_Adr_Line_1_EI__c	City_EI__c\tRate_Schedule_EI__c\r\n' +
'a0t1R00000HTsy5QAD\t20\t7592726094\t7593391900\tRES\t2950 DOHR ST APT E\tBERKELEY\tE1\r\n' +
'a0t1R00000HTsy6QAD\t20\t1801980603\t1809077706\tRES\t2371 COLLEGE AVE\tLIVERMORE\tE1\r\n' +
'a0t1R00000HTsynQAD\t20\t3210772716\t3211563682\tRES\t95 PHILLIPSVILLE RD\tPHILLIPSVILLE\tE1\r\n' +
'a0t1R00000HTsyoQAD\t20\t8799219098\t8797682070\tRES\t815 ARLINGTON AVE\tOAKLAND\tEM\r\n' +
'a0t1R00000HTszYQAT\t20\t9384658983\t9383085793\tRES\t14411 BIG BASIN WAY APT 8\tBOULDER CREEK\tHE1\r\n';

String className = 'ei_site__c';

// String test = JSONLib.tabToJSON(tabDelimitedFile);

system.debug('\r\ntabDelimitedFile======\r\n' + tabDelimitedFile);

Object objList = JSONLib.tabToObject(tabDelimitedFile, className );

ei_site__c[] siteList = (ei_site__c[])objList;

System.debug('\r\n==================================================== ' + siteList.size() + ' sites are loaded ========\r\n');
for (ei_site__c site : siteList) 
System.debug('\r\n=============================================== ' + site);

==============================================================================
JSONLib.logMessage('EI_BulkLoad', 
   'Method',
   'variableName',
   300, 
   'debug message');

select Apex_Class_Name_EI__c, Line_Number_EI__c, Exception_Type_EI__c, SSL_Record_ID__c, SSL_Record_Name__c,
Error_Message_EI__c, createddate
from EI_Exception_Log__c
where Exception_Type_EI__c = 'Log'
order by createddate desc


====================================================================================================
String argValue = '12-4-1998';
String jsonDateSting = JSONLib.getJSONValue(argValue );

system.debug('jsonDateSting  ================================== ' + jsonDateSting );


=======================================================================================================

String csvFileContact = 'Title,FirstName,LastName,Email,Birthdate,notExist\r\n'           +
                        'test manager,Super,Man,helloemail@sfdc.com,01/21/1980,1\r\n'       +
                        'test manager,Sleeping,Beauty,helloemail@sfdc.com,12/23/1980,2\r\n' +
                        'test manager,Hello,Catty,Caty@hello.com,06/7/1980,3\r\n'           +
                        'test manager,Snow,White,Caty@hello.com,2/9/1980,4\r\n'             +
                        'test manager,Little,Mermaid,Caty@hello.com,11/5/1999,5\r\n';

String   className  = 'Contact';

Object objList = JSONLib.csvToObject( csvFileContact , className ) ;

Contact[] contactList = (Contact[])objList;

for (Contact c : contactList) 
System.debug('\r\n================ Contact =============================== ' + c);

=======================================================================================================
String tabFileContact = 'Title\tFirst Name\tLast Name\tEmail\tBirthdate\tnotExist\r\n'           +
                        'test manager\tSuper\tMan\thelloemail@sfdc.com\t01/21/1980\t1\r\n'       +
                        'test manager\tSleeping\tBeauty\thelloemail@sfdc.com\t12/23/1980\t2\r\n' +
                        'test manager\tHello\tCatty\tCaty@hello.com\t06/7/1980\t3\r\n'           +
                        'test manager\tSnow\tWhite\tCaty@hello.com\t2/9/1980\t4\r\n'             +
                        'test manager\tLittle\tMermaid\tCaty@hello.com\t11/5/1999\t5\r\n';

String   className  = 'Contact';

Object objList = JSONLib.tabToObject( tabFileContact , className ) ;

Contact[] contactList = (Contact[])objList;

for (Contact c : contactList) 
System.debug('\r\n================ Contact =============================== ' + c);

=================================================================================================
String tabFileContact = 'Title\tFirst Name\tLast Name\tEmail\tBirthdate\tnotExist\r\n'           +
                        'test manager\tSuper\tMan\thelloemail@sfdc.com\t01/21/1980\t1\r\n'       +
                        'test manager\tSleeping\tBeauty\thelloemail@sfdc.com\t12/23/1980\t2\r\n' +
                        'test manager\tHello\tCatty\tCaty@hello.com\t06/7/1980\t3\r\n'           +
                        'test manager\tSnow\tWhite\tCaty@hello.com\t2/9/1980\t4\r\n'             +
                        'test manager\tLittle\tMermaid\tCaty@hello.com\t11/5/1999\t5\r\n';

String   className  = 'Contact';
String[] argTabData = tabFileContact.split('\r\n');
String   header     = argTabData.remove(0);
String[] headerList = header.split('\t');
String   dateFormat  = 'MM/DD/YYYY';

Object objList = JSONLib.tabArrayToObject( argTabData, className ,headerList, dateFormat ) ;

Contact[] contactList = (Contact[])objList;

for (Contact c : contactList)
System.debug('\r\n================ Contact =============================== ' + c);

================================================================================================*/