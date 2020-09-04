/**************************************************************************************************   
Apex Batch Name      :  CARE_LoadUserFileTest
Version              :  1.0                                                                          
Created Date         :  08/04/2020                                                              
Function             :  Test class for CARE_LoadUserFile
Story                :                                                                               
Work Task            :                                                                            
Modification Log     :                                                                            
*--------------------------------------------------------------------------------------------------  
* Developer                 Date                   Description                                     
* -------------------------------------------------------------------------------------------------  
* A8AI                   08/10/2020               First Iteration  

***************************************************************************************************/
@isTest(SeeAllData = false)
public class CARE_LoadUserFileTest {
    
    public static EI_ApexClassCatelog__c eiApexCategory;
    
    public static EI_ApexParameter__c eiApexParameter1;
    public static EI_ApexParameter__c eiApexParameter2;
    public static EI_ApexParameter__c eiApexParameter3;
    public static EI_ApexParameter__c eiApexParameter4;
    public static EI_ApexParameter__c eiApexParameter5;
    public static EI_ApexParameter__c eiApexParameter6;
    public static EI_ApexParameter__c eiApexParameter7;
    public static EI_ApexParameter__c eiApexParameter8;
    public static EI_ApexParameter__c eiApexParameter9;
    public static EI_ApexParameter__c eiApexParameter10;
    
    public static List<EI_ApexParameter__c> listEIApexParameter = new List<EI_ApexParameter__c>();
    
    @isTest
    public static void testFortyFiveDaysCheck(){
        
        String argFileName = 'VH-CODEUPLOAD';
        String fileSearchKey = 'VH-CODEUPLOAD.CSV';
        String argDocId = '';
        
        eiApexCategory = new EI_ApexClassCatelog__c(Category__c = 'CARE.USERLOAD', FileNameRegex__c = 'VH-CODEUPLOAD.CSV');
        insert eiApexCategory;
        
        eiApexParameter1 = new EI_ApexParameter__c(Name = 'objectApi', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = 'CARE_Batch_Staging__c');
        eiApexParameter2 = new EI_ApexParameter__c(Name = 'reqFields', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '["PER_ID__c"]');
        eiApexParameter3 = new EI_ApexParameter__c(Name = 'dmlAction', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = 'Insert');
        eiApexParameter4 = new EI_ApexParameter__c(Name = 'csvFieldMap', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '[{"tgtFieldAPI":"PER_ID__c","srcFieldAPI":"Person ID","datatype":""},{"tgtFieldAPI":"APPLICANT_NAME__c","srcFieldAPI":"Customer Name","datatype":""},{"tgtFieldAPI":"EI_ACCOUNT__c","srcFieldAPI":"EI Account ID","datatype":""}]');
        eiApexParameter5 = new EI_ApexParameter__c(Name = 'parmList', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '[{"value":"CBJ-0016","objectAPI":"CARE_Batch_Staging__c","fieldAPI":"JOB_NO__c"}]');
        eiApexParameter6 = new EI_ApexParameter__c(Name = 'className', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = 'CARE_ManualUpload.processVHCode');
        eiApexParameter7 = new EI_ApexParameter__c(Name = 'libraryName', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = 'Bulkload Home');
        eiApexParameter8 = new EI_ApexParameter__c(Name = 'storeSourceFile', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '');
        eiApexParameter9 = new EI_ApexParameter__c(Name = 'batchSize', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '2000');
        eiApexParameter10 = new EI_ApexParameter__c(Name = 'tgtArg', EI_ApexClassCatelog__c = eiApexCategory.Id, Value__c = '');
        listEIApexParameter.add(eiApexParameter1);
        listEIApexParameter.add(eiApexParameter2);
        listEIApexParameter.add(eiApexParameter3);
        listEIApexParameter.add(eiApexParameter4);
        listEIApexParameter.add(eiApexParameter5);
        listEIApexParameter.add(eiApexParameter6);
        listEIApexParameter.add(eiApexParameter7);
        listEIApexParameter.add(eiApexParameter8);
        listEIApexParameter.add(eiApexParameter9);
        listEIApexParameter.add(eiApexParameter10);
        insert listEIApexParameter;
        
        Test.startTest();
        CARE_LoadUserFile.getParameters(argFileName, argDocId, fileSearchKey);
        Test.stopTest();
    }

}