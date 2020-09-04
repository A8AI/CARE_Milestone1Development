@isTest
public class JSONLibTest {

   @isTest static void test() {  
      //========  test: convert array of tab delimited data into custom objects or class
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
      
      //========  test csv to JSON to custom Object which is passed as a String parameter -

      String jsonData = '[ { "Name": "Bank Account", "AccountNumber": "acct-1234567", "CARE_PROBATION_START_DATE__c": "2019-12-21"}, ' +
                        '  { "Name": "Salesforce Account", "AccountNumber": "acct-9874563", "CARE_PROBATION_START_DATE__c": "2019-09-21"} ]';
      String objectApiName  = 'Account';

      Integer rtn = JSONLib.loadJSONData(jsonData, objectApiName  );

      system.debug('rtn =' + rtn );
      
      //========  test: load csv file into Account object
     /* String csvFile = 'Title,FirstName,LastName,Email,AccountId,Birthdate\r\n';
      csvFile = csvFile  + 'test manager,Super,Man,helloemail@sfdc.com,0013K000008ejB5QAI,1980-01-02\r\n';
      csvFile = csvFile  + 'test manager,Sleeping,Beauty,helloemail@sfdc.com,0013K000008ejB5QAI,1980-01-30\r\n';
      csvFile = csvFile  + 'test manager,Hello,Catty,Caty@hello.com,0013K000008ejB5QAI,1980-08-27\r\n';
      csvFile = csvFile  + 'test manager,Snow,White,Caty@hello.com,0013K000008ejB5QAI,1980-10-02\r\n';
      csvFile = csvFile  + 'test manager,Little,Mermaid,Caty@hello.com,0013K000008ejB5QAI,1980-12-23\r\n';
     */
      String csvFile = 'Title,FirstName,LastName,Email,Birthdate\r\n';
      csvFile = csvFile  + 'test manager,Super,Man,helloemail@sfdc.com,1980-01-02\r\n';
      csvFile = csvFile  + 'test manager,Sleeping,Beauty,helloemail@sfdc.com,1980-01-30\r\n';
      csvFile = csvFile  + 'test manager,Hello,Catty,Caty@hello.com,1980-08-27\r\n';
      csvFile = csvFile  + 'test manager,Snow,White,Caty@hello.com,1980-10-02\r\n';
      csvFile = csvFile  + 'test manager,Little,Mermaid,Caty@hello.com,1980-12-23\r\n'; 
       
       
      objectApiName  = 'Contact';
      
      system.debug('\r\n====================\r\ncsvFile = \r\n' + csvFile );
      
      rtn = JSONLib.loadCsvFile(csvFile , objectApiName  );
      
      system.debug('\r\n====================\r\nNumber of sObject created = \r\n' + rtn + '\r\n\r\n' );
      
      //========  test: convert csv data to Contact object
      objList = JSONLib.csvToObject( csvFile , 'Contact' ) ;
      
      contactList = (Contact[])objList;
      
      for (Contact c : contactList) 
      System.debug('\r\n================ Contact =============================== ' + c);
      
      //========  test: convert tab delimited data/file into custom objects or class
      String tabDelimitedFile = 'Id\tSvc_Status_Code_EI__c\tBilling_Account_ID_EI__c\tSAID_EI__c\tCust_Type_EI__c\tStreet_Adr_Line_1_EI__c	City_EI__c\tRate_Schedule_EI__c\r\n' +
      'a0t1R00000HTsy5QAD\t20\t7592726094\t7593391900\tRES\t2950 DOHR ST APT E\tBERKELEY\tE1\r\n' +
      'a0t1R00000HTsy6QAD\t20\t1801980603\t1809077706\tRES\t2371 COLLEGE AVE\tLIVERMORE\tE1\r\n' +
      'a0t1R00000HTsynQAD\t20\t3210772716\t3211563682\tRES\t95 PHILLIPSVILLE RD\tPHILLIPSVILLE\tE1\r\n' +
      'a0t1R00000HTsyoQAD\t20\t8799219098\t8797682070\tRES\t815 ARLINGTON AVE\tOAKLAND\tEM\r\n' +
      'a0t1R00000HTszYQAT\t20\t9384658983\t9383085793\tRES\t14411 BIG BASIN WAY APT 8\tBOULDER CREEK\tHE1\r\n';
      
      className = 'ei_site__c';
      system.debug('\r\ntabDelimitedFile======\r\n' + tabDelimitedFile);
      
      objList = JSONLib.tabToObject(tabDelimitedFile, className );
      ei_site__c[] siteList = (ei_site__c[])objList;

      System.debug('\r\n==================================================== ' + siteList.size() + ' sites are loaded ========\r\n');
      for (ei_site__c site : siteList) 
      System.debug('\r\n=============================================== ' + site);
      
      //========  test: log message for debug and monitoring
      JSONLib.logMessage ( 'className', 'methodName', 'variableName', 100, 'Test logging message');
   }
}