/**************************************************************************************************
Apex Class Name :  DynamicApex
Version         :  1.0
Created Date    :  07/17/2020
Function        :  Run Apex Class passed as a String parameter
Argument        :  apexClass in  Apex Class to be execuated
                :  arg       in  data in JOSN format
return          :  JSON String from deserialization of returnWrapper class
returnCode      :  -1: error, >= 0: records processed
Modification Log:
--------------------------------------------------------------------------------------------------
Developer         Date         Description
--------------------------------------------------------------------------------------------------
LXX1              07/17/2020   Initial Version
**************************************************************************************************/

global class DynamicApex {

    global static String execute(String apexClass, String arg){
        Type t = Type.forName(apexClass.trim());
        System.debug('Type = ' + t);
        DynamicApexInterface apexInstance = (DynamicApexInterface)t.newInstance();
        return apexInstance.execute(arg);
    }  
 
    global interface DynamicApexInterface { String execute(String arg); }
 
    public class returnWrapper{
         public Integer returnCode;
         public String  message;
         public String  requestSuccess;
         public String  data;              // JSON String
    }
   
    public Class MyClassName implements DynamicApex.DynamicApexInterface {
         public String execute(String arg) {
 
             System.debug('Input JSON String ==================================== ' + arg);
 
             Map<String, Object> m =  (Map<String, Object>) JSON.deserializeUntyped(arg);
             String buhId   = String.valueOf(m.get('buhId'));
             String libName = String.valueOf(m.get('libraryName'));
             System.debug('\r\nbuhId======================buhId============================ ' + buhId);
             System.debug('\r\nlibName====================libName========================== ' + libName);
             
             String resultCsv       = 'Id,Fisrt Name,Last Name,Notes\r\n' + 
                                      '01,Hello,Kitty,Testing Only\r\n' + 
                                      '02,Micky,Mouse,Testing Only\r\n';
             Blob   resultfile      = Blob.valueof(resultCsv);
             String resultFileName  = 'test_result_' + Datetime.now().format('YYYYMMdd_hhmm') + '.csv';
             String resultFileTitle = 'test_result_' + Datetime.now().format('YYYYMMdd_hhmm');
             EI_Bulkload.insertFile(resultfile, resultFileTitle, resultFileName, buhId, libName);
             EI_Bulkload.setPlacSummary(buhId, 'PLP: 10 successes and 3 errors.');

             DynamicApex.returnWrapper rtnJSON = new DynamicApex.returnWrapper();
             rtnJSON.returnCode     = 1;
             rtnJSON.message        = 'Everything is good';
             rtnJSON.requestSuccess = 'true';
             rtnJSON.data           = 'MyClassName Class Runs with arg = ' + arg;
             return JSON.serialize(rtnJSON);
         }
    }
 } // class DynamicApex
 
 /* Sample usage
 
 1. Create a class which implements DynamicApex.DynamicApexInterface, e.g., MyClassName on Line 35
 2. In the class, implement your logic/processing in method execute(String arg) w/ JSON return value,
    where arg will will passed by caller as DynamicApex.execute('YourClassName', 'Your JSON arg String');
 
 String rtnString = DynamicApex.execute('DynamicApex.MyClassName', '{"name":"Hello Kitty", "title":"Manager"}');
 DynamicApex.returnWrapper rtnJSON = (DynamicApex.returnWrapper)JSON.deserialize(rtnString, DynamicApex.returnWrapper.class);
 system.debug('\r\n\r\ndata = ' + rtnJSON.data + '\r\n');
 
 */