@isTest
public class DynamicApexTest {

   @isTest static void test() {  
      Account acct = new Account( name = 'Dummy Account for test', description = 'Dummy Account for test.' ) ;
      insert acct;
      
      EI_Bulk_Upload_History__c buh  = new EI_Bulk_Upload_History__c();
      buh.Account_EI__c              = acct.id;
      buh.File_Name_EI__c            = 'Test.csv';
      buh.Bulk_Upload_Sta_EI__c      = 'In Progress';
      buh.File_Upload_Date_EI__c     = System.now();
      insert buh;
      
      Map<String, Object> m = new Map<String, Object>{'buhId' => buh.id, 'libraryName' => null};
      String jsonArg = JSON.serialize(m);
      String rtnString = DynamicApex.execute('DynamicApex.MyClassName', jsonArg);

    }
}