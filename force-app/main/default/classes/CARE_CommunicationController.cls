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
****************************************************************************************************************************************/

public with sharing class CARE_CommunicationController {
     @AuraEnabled(cacheable=false)
    
    public static List<DataTableWrapper> getPhoneDetails(String selectedPerId){
      
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        List<Account> resList = [select Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c from Account where Billing_Person_ID_EI__c =: selectedPerId LIMIT 1];
         
        DataTableWrapper obj = new DataTableWrapper();
        for(Account res : resList){
            obj.phone1           = res.Bus_Phone_1_EI__c;
            obj.phone2           = res.Bus_Phone_2_EI__c;
            obj.mobile1          = res.Primary_Contact_Mobile_EI__c;
            response.add(obj);
        }
        
        return response;
    }
    
    public with sharing class DataTableWrapper{
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
        /* @AuraEnabled
        public String communication {get;set;}
         @AuraEnabled
        public String comDetails {get;set;}*/
        @AuraEnabled 
        public String sLabel {get;set;}
        @AuraEnabled 
        public String sValue {get;set;}
        /*@AuraEnabled 
        public String contactMethod {get;set;}
        @AuraEnabled 
        public String lang {get;set;}
        @AuraEnabled 
        public String id {get;set;} */
    
    }
    
    @AuraEnabled
    public static Boolean savePhoneDetails(DataTableWrapper updatePhoneRec, String perIdValue) {
        // Describe the SObject using its object type.
        Boolean bStatus;
        try{
        List<Account> saveResList = [select id,Bus_Phone_1_EI__c, Bus_Phone_2_EI__c, Primary_Contact_Mobile_EI__c from Account where Billing_Person_ID_EI__c =: perIdValue];
        for(Account res : saveResList){
            //upRec.home          = res1.Bus_Phone_1_EI__c = ;
            res.Bus_Phone_1_EI__c= updatePhoneRec.home;
            res.Bus_Phone_2_EI__c= updatePhoneRec.work;
            res.Primary_Contact_Mobile_EI__c= updatePhoneRec.mobile;
            //upRec.mobile        = res1.Primary_Contact_Mobile_EI__c;
            //update res1;
        }
        update saveResList;
        
        bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }

        
        //System.debug('upRec---> '+upRec);
       return bStatus;
    }  
    
   /* @AuraEnabled(cacheable=true)
    
    public static List<DataTableWrapper> getCommunicationDetails(){
      
        List<DataTableWrapper> response2 = new List<DataTableWrapper>();
        List<Account> resList2 = [select PREFERRED_CONTACT_METHOD__c  from Account where Billing_Person_ID_EI__c = '0123456001'LIMIT 1];
         
        DataTableWrapper obj = new DataTableWrapper();
        for(Account res2 : resList2){
            obj.communication           = res2.PREFERRED_CONTACT_METHOD__c ;
            response2.add(obj);
        }
        
        return response2;
    } 
    
    @AuraEnabled
    public static void saveCommunicationDetails(DataTableWrapper upRec2) {
        // Describe the SObject using its object type.
        List<Account> saveResList2 = [select id,PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c = '0123456001'];
        for(Account res2 : saveResList2){
            
            res2.PREFERRED_CONTACT_METHOD__c = upRec2.comDetails;
            update res2;
            system.debug('res2:' +res2);g
        }
        
        
        System.debug('upRec---> '+upRec2);
        //return upRec;
    }  */
    
     @AuraEnabled(cacheable = true)
    public static List < DataTableWrapper > fetchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
 
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
 
        // Create a list of wrapper to store picklist value/lable
        list < DataTableWrapper > objWrapper = new list < DataTableWrapper > ();
 
        for (Schema.PicklistEntry a: values) {
            DataTableWrapper oFetchValueWrapper = new DataTableWrapper();
            oFetchValueWrapper.sLabel = a.getLabel();
            oFetchValueWrapper.sValue = a.getValue();
            objWrapper.add(oFetchValueWrapper);
        }
        return objWrapper;
 
    }
    @AuraEnabled(cacheable = false)
    public static List < Account > getCommDetails(String selectedPerId) {
        // Describe the SObject using its object type.
        //List<Account> ac = [select Billing_Person_ID_EI__c from Account where Billing_Person_ID_EI__c!=null ];
        LIST<Account> acc = [Select Id, Billing_Person_ID_EI__c, NAME, PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: selectedPerId and PREFERRED_CONTACT_METHOD__c !=null LIMIT 1 ];
        return acc;
    }     
    @AuraEnabled
    public static Boolean saveCommDetails(string updateCommRec, String perIdValue) {
        // Describe the SObject using its object type.
       /* update upRec1;
        System.debug('upRec1---> '+upRec1); */
        //return upRec1;
        Boolean bStatus = false; 
        try{ 
        List<Account> saveResList = [Select Id,PREFERRED_CONTACT_METHOD__c from Account where Billing_Person_ID_EI__c =: perIdValue];
        for(Account res : saveResList){
            //upRec.home          = res1.Bus_Phone_1_EI__c = ;
            res.PREFERRED_CONTACT_METHOD__c = updateCommRec;
            //upRec.mobile        = res1.Primary_Contact_Mobile_EI__c;
            //update res2;
        }
        update saveResList;
             bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }

        
        //System.debug('upRec---> '+upRec);
       return bStatus;
   
        
        
       
    } 
    
     @AuraEnabled(cacheable = false)
    public static List < Account > getLangDetails(String selectedPerId) {
        // Describe the SObject using its object type.
        //List<Account> ac = [select Billing_Person_ID_EI__c from Account where Billing_Person_ID_EI__c!=null ];
        LIST<Account> acc = [Select Id,Languages_Other_Than_English_EI__c from Account where Billing_Person_ID_EI__c =: selectedPerId LIMIT 1 ];
        return acc;
    } 

    @AuraEnabled
    public static Boolean saveLangDetails(string updateLangRec, String perIdValue) {
        // Describe the SObject using its object type.
       /* update upRec1;
        System.debug('upRec1---> '+upRec1); */
        //return upRec1;
        Boolean bStatus = false; 
        
        try{
                List<Account> saveResList = [Select Id,Languages_Other_Than_English_EI__c from Account where Billing_Person_ID_EI__c =: perIdValue];
            for(Account res : saveResList){
                //upRec.home          = res1.Bus_Phone_1_EI__c = ;
                res.Languages_Other_Than_English_EI__c = updateLangRec;
                //upRec.mobile        = res1.Primary_Contact_Mobile_EI__c;
                //update res3;
            }
                update saveResList;
                bStatus = true;
            
        }
        catch (Exception ex){
            bStatus = false;
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());     
        }

        
        //System.debug('upRec---> '+upRec);
       return bStatus;

        
       
    }         
}