/***********************************************************************************************************   
Apex Util class Name :  CARE_CCBHistoryController
Version              :  1.0                                                                          
Created Date         :  05/19/2020                                                         
Function             :  This is the Apex Controller for CC&B History button of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                                Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/09/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/
public class CARE_CCBHistoryController {
    
    @AuraEnabled(cacheable=true)
    
    public static List<DataTableWrapper> getCCBHistory(string sPerID){
        
        system.debug('sPerID----->' + sPerID);
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        List<CARE_CC_Batch_Detail__c> resList = [select DATE1__c, DATE2__c,SA_ID__c,SERVICE_TYPE_CODE__c,CARE_CI_CC__r.DESCR254__c, CARE_CI_CC__r.CC_DTTM__c, CARE_CI_CC__r.CC_CL_CD__c, 
                                                 CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.USER_ID__c from CARE_CC_Batch_Detail__c where PER_ID__C =: sPerID];
        
        
        
        for(CARE_CC_Batch_Detail__c res : resList){            
            DataTableWrapper obj = new DataTableWrapper();
            obj.date1            = res.DATE1__c;
            obj.date2            = res.DATE2__c;
            obj.sa_id            = res.SA_ID__c;
            obj.descr            = res.CARE_CI_CC__r.DESCR254__c;
            obj.dttm             = res.CARE_CI_CC__r.CC_DTTM__c;
            obj.cl_cd            = res.CARE_CI_CC__r.CC_CL_CD__c;
            obj.cc_type_cd       = res.CARE_CI_CC__r.CC_TYPE_CD__c;
            obj.userid           = res.CARE_CI_CC__r.USER_ID__c;
            obj.sa_type          = res.SERVICE_TYPE_CODE__c;
            response.add(obj);
        }
        return response;
    }
 /* @AuraEnabled(Cacheable = true)
    public static List<DataTableWrapper> getSAType(){  
        List<DataTableWrapper> saType = new List<DataTableWrapper>();
        List<EI_Site__c> saTypeList = [SELECT Svc_Type_Code_EI__c from EI_Site__c where SAID_EI__c = '1243668790'];
        
        for(EI_Site__c sa : saTypeList){
            DataTableWrapper obj = new DataTableWrapper();
            obj.sa_type            = sa.Svc_Type_Code_EI__c;
            saType.add(obj);
        }
        return saType;  
    } */
    
    private class DataTableWrapper{
		@AuraEnabled
public Date date1 {get;set;}
        @AuraEnabled
public Date date2 {get;set;}
        @AuraEnabled
public String sa_id {get;set;}
        @AuraEnabled
public String descr {get;set;}
        @AuraEnabled
public Date dttm {get;set;}
        @AuraEnabled
public String cl_cd {get;set;}
        @AuraEnabled
public String cc_type_cd {get;set;}
        @AuraEnabled
public String userid {get;set;}
           @AuraEnabled
public String sa_type {get;set;}
    }
}