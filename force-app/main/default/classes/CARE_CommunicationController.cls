/***********************************************************************************************************   
Apex Util class Name :  CARE_CommunicationController
Version              :  1.0                                                                          
Created Date         :  05/27/2020                                                         
Function             :  This is the apex class for Communication Modals in CARE Enrollment tab.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/27/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
* 09/03/2020			SKMN				   Updated Account.PREFERRED_CONTACT_METHOD__c for existing records
****************************************************************************************************************************************/

public class CARE_CommunicationController {
    
    public class DataTableWrapper{
        @AuraEnabled
        public String phone1 {get;set;}
        @AuraEnabled
        public String phone2 {get;set;}
        @AuraEnabled
        public String mobile1 {get;set;}
        @AuraEnabled
        public String home {get;set;}
        @AuraEnabled
        public String work {get;set;}
        @AuraEnabled
        public String mobile {get;set;}
        @AuraEnabled 
        public String sLabel {get;set;}
        @AuraEnabled 
        public String sValue {get;set;}
    }
    
    @AuraEnabled(cacheable=false)    
    public static List<DataTableWrapper> getPhoneDetails(Id selectedAccountId){
        
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        List<Account> resList = [select Id, Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c from Account where id =: selectedAccountId];
        system.debug('resList-->'+resList);
        DataTableWrapper obj = new DataTableWrapper();
        for(Account res : resList){
            obj.phone1           = res.Bus_Phone_1_EI__c;
            obj.phone2           = res.Bus_Phone_2_EI__c;
            obj.mobile1          = res.Primary_Contact_Mobile_EI__c;
            response.add(obj);
        }
        system.debug('response-->'+response);
        return response;
    }
    
    @AuraEnabled
    public static Boolean savePhoneDetails(DataTableWrapper updatePhoneRec, String perIdValue) {
        // Describe the SObject using its object type.
        Boolean bStatus;
        try{
            List<Account> saveResList = [select id,Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c, PREFERRED_CONTACT_METHOD__c 
                                         from Account 
                                         where Billing_Person_ID_EI__c =: perIdValue];
            for(Account res : saveResList){
                res.Bus_Phone_1_EI__c= updatePhoneRec.home;
                res.Bus_Phone_2_EI__c= updatePhoneRec.work;
                res.Primary_Contact_Mobile_EI__c= updatePhoneRec.mobile;
                if(string.isBlank(res.PREFERRED_CONTACT_METHOD__c)){ //This field is a required field, hence update the existing record having blank value
                    res.PREFERRED_CONTACT_METHOD__c = CARE_Constants.ACC_PREFERRED_CONTACT_DEFAULT;
                }
            }
            update saveResList;
            
            bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }
        
        return bStatus;
    }  
    
    
    @AuraEnabled(cacheable = true)
    public static List < DataTableWrapper > fetchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
        
        // Get a map of fields for the SObject
        map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list <Schema.PicklistEntry> values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
        
        // Create a list of wrapper to store picklist value/lable
        list <DataTableWrapper> objWrapper = new list < DataTableWrapper > ();
        
        for (Schema.PicklistEntry a: values) {
            DataTableWrapper oFetchValueWrapper = new DataTableWrapper();
            oFetchValueWrapper.sLabel = a.getLabel();
            oFetchValueWrapper.sValue = a.getValue();
            objWrapper.add(oFetchValueWrapper);
        }
        return objWrapper;
        
    }
    
    @AuraEnabled(cacheable = false)
    public static List <Account> getCommDetails(Id selectedAccountId) {
        // Describe the SObject using its object type.
        
        LIST<Account> acc = [Select Id, Billing_Person_ID_EI__c, NAME, PREFERRED_CONTACT_METHOD__c from Account where id =: selectedAccountId];
        return acc;
    }   
    
    @AuraEnabled
    public static Boolean saveCommDetails(string updateCommRec, String perIdValue) {
        // Describe the SObject using its object type.
        Boolean bStatus = false; 
        try{ 
            List<Account> saveResList = [Select Id,PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: perIdValue];
            for(Account res : saveResList){
                res.PREFERRED_CONTACT_METHOD__c = updateCommRec;
            }
            update saveResList;
            bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }
        return bStatus;
        
        
        
        
    } 
    
    @AuraEnabled(cacheable = false)
    public static List <Account> getLangDetails(Id selectedAccountId) {
        // Describe the SObject using its object type.
        LIST<Account> acc = [Select Id,Languages_Other_Than_English_EI__c from Account where Id =: selectedAccountId LIMIT 1 ];
        return acc;
    } 
    
    @AuraEnabled
    public static Boolean saveLangDetails(string updateLangRec, String perIdValue) {
        // Describe the SObject using its object type.
        Boolean bStatus = false; 
        
        try{
            List<Account> saveResList = [Select Id,Languages_Other_Than_English_EI__c, PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: perIdValue];
            for(Account res : saveResList){
                res.Languages_Other_Than_English_EI__c = updateLangRec;
                if(string.isBlank(res.PREFERRED_CONTACT_METHOD__c)){ //This field is a required field, hence update the existing record having blank value
                    res.PREFERRED_CONTACT_METHOD__c = CARE_Constants.ACC_PREFERRED_CONTACT_DEFAULT;
                }
            }
            update saveResList;
            bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }
        return bStatus;
        
        
        
    }         
}