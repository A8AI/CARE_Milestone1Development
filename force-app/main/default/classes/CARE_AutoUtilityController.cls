/***********************************************************************************************************   
Apex Util class Name :  CARE_AutoUtilityController
Version              :  1.0                                                                          
Created Date         :  07/22/2020                                                         
Function             :  This is the Utiltity Class for re-usable components which are referred in Automatic 
enrollment and batch classes for CARE Application.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                                 Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/22/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_AutoUtilityController {
    
    //************Wrapper Class***************//
    public class StampVCodeWrapper{
        @AuraEnabled 
        public Set<Id> careAppSet {get;set;}
        @AuraEnabled 
        public Set<Id> careAppErrorIdSet {get;set;}
        @AuraEnabled 
        public Set<String> setErrorPerId {get;set;}
        
        public StampVCodeWrapper(){
            careAppSet = new Set<Id>();
            careAppErrorIdSet = new Set<Id>();
            setErrorPerId = new Set<String>();
        }
    }
    
    public class StampVHCodeWrapper{
        @AuraEnabled 
        public Set<Id> careAppSet {get;set;}
        @AuraEnabled 
        public Set<Id> careAppErrorIdSet {get;set;}
        @AuraEnabled 
        public Set<String> setErrorPerId {get;set;}
        
        public StampVHCodeWrapper(){
            careAppSet = new Set<Id>();
            careAppErrorIdSet = new Set<Id>();
            setErrorPerId = new Set<String>();
        }
    }
    
    public class PEVResponseCheckWrapper{
        @AuraEnabled 
        public Set<Id> careAppPEVSet {get;set;}
        @AuraEnabled 
        public Set<Id> careAppErrorIdSet {get;set;}
        @AuraEnabled 
        public Set<String> setErrorPerId {get;set;}
        
        public PEVResponseCheckWrapper(){
            careAppPEVSet = new Set<Id>();
            careAppErrorIdSet = new Set<Id>();
            setErrorPerId = new Set<String>();
        }
    }
    
    public class HUResponseCheckWrapper{
        @AuraEnabled 
        public Set<Id> careAppHUSet {get;set;}
        @AuraEnabled 
        public Set<Id> errorIdSetHU {get;set;}
        @AuraEnabled 
        public Set<String> errorPerIdSet {get;set;}
        
        public HUResponseCheckWrapper(){
            careAppHUSet = new Set<Id>();
            errorIdSetHU = new Set<Id>();
            errorPerIdSet = new Set<String>();
        }
    }
    
    public class ESAThresholdCheckWrapper{
        @AuraEnabled 
        public Set<Id> setESACareAppId {get;set;}
        @AuraEnabled 
        public Set<Id> setESAErrorId {get;set;}
        @AuraEnabled 
        public Set<String> setErrorPerId {get;set;}
        @AuraEnabled 
        public Set<Id> setThresholdAppId {get;set;}
        @AuraEnabled 
        public Set<Id> setThresholdErrId {get;set;}
        @AuraEnabled 
        public Set<String> setThresholdErrPerId {get;set;}
        @AuraEnabled 
        public Set<Id> setESADropAppId {get;set;}
        @AuraEnabled 
        public Set<Id> setESADropErrId {get;set;}
        @AuraEnabled 
        public Set<String> setESADropErrPerId {get;set;}
        
        public ESAThresholdCheckWrapper(){
            setESACareAppId = new Set<Id>();
            setESAErrorId = new Set<Id>();
            setErrorPerId = new Set<String>();
            setThresholdAppId = new Set<Id>();
            setThresholdErrId = new Set<Id>();
            setThresholdErrPerId = new Set<String>();
            setESADropAppId = new Set<Id>();
            setESADropErrId = new Set<Id>();
            setESADropErrPerId = new Set<String>();
        }
    }
    
    /************************************Public Methods****************************************************/
    
    // This method is used to determine person Id's eligible for probation
    public static List<String> determineProbationStatusForAccount( List<String> perIdList){
        
        Date dTodaysDate = Date.today();
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTwoYears);
        //string sCCCode;
        Map<string, List<CARE_CC_Batch_Detail__c>> mapOfProbationRecord = new Map<string, List<CARE_CC_Batch_Detail__c>>();
        List<String> personIdList = new List<String>();
        List<String> personIdListForProbation = new List<String>();
        Set<String> personIdSetForProbation = new Set<String>();
        boolean bIsOnProbation = false;
        set<string> setOfDCode = new set<string>();
        set<string> setRemoveMediAllot = new set<string>();
        set<string> setOfMedAllot = new set<string>();
        
        
        
        List<CARE_CC_Batch_Detail__c> probationCheckList = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c
                                                            from CARE_CC_Batch_Detail__c 
                                                            where PER_ID__c IN : perIdList and CARE_CI_CC__r.CC_TYPE_CD__c != null and CARE_CI_CC__r.CC_DTTM__c >=: dDateBeforeTwoYears
                                                            order by CARE_CI_CC__r.CC_DTTM__c DESC];
        
        List<CARE_CC_Batch_Detail__c> CheckListMedi = [select Id, PER_ID__c, CARE_CI_CC__r.CC_TYPE_CD__c
                                                       from CARE_CC_Batch_Detail__c 
                                                       where PER_ID__c IN : perIdList and ((CARE_CI_CC__r.CC_TYPE_CD__c =: CARE_Constants.CARE_CC_DROPESA) OR (CARE_CI_CC__r.CC_TYPE_CD__c =: CARE_Constants.CARE_CC_DROPHU)) and CARE_CI_CC__r.CC_DTTM__c >=: dDateBeforeTwoYears];
        try{
            if(CheckListMedi.size() > 0){
                for(CARE_CC_Batch_Detail__c bDetail : CheckListMedi){
                    setOfDCode.add(bDetail.PER_ID__c);  
                } 
            }
            
            if(probationCheckList.size() > 0){
                for(CARE_CC_Batch_Detail__c probCheck : probationCheckList){
                    if(CARE_Constants.CARE_CC_CODE_NOT_PROBATION_ONE.contains(probCheck.CARE_CI_CC__r.CC_TYPE_CD__c) || CARE_Constants.CARE_CC_CODE_PROBATION_ONE.contains(probCheck.CARE_CI_CC__r.CC_TYPE_CD__c) ||
                       CARE_Constants.CARE_CC_CODE_PROBATION_TWO.contains(probCheck.CARE_CI_CC__r.CC_TYPE_CD__c) || CARE_Constants.CARE_CC_CODE_NOT_PROBATION_THREE.contains(probCheck.CARE_CI_CC__r.CC_TYPE_CD__c) ||
                       (probCheck.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_HUAPPEAL && probCheck.CCB_Contact_Type_No__c == CARE_Constants.CARE_CC_HUAPPEAL_NO) || (probCheck.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_REINSTATEHU && CARE_Constants.CARE_CC_CODE_NOT_PROBATION_TYPENO_ESACOMP.contains(probCheck.CCB_Contact_Type_No__c)) ||
                      probCheck.CARE_CI_CC__r.CC_TYPE_CD__c == 'C AE CARE' && CARE_Constants.CARE_CC_CAECARE_TYPENO.contains(probCheck.CCB_Contact_Type_No__c)){               
                           
                           if(!mapOfProbationRecord.containskey(probCheck.PER_ID__c)){
                               mapOfProbationRecord.put(probCheck.PER_ID__c ,new List<CARE_CC_Batch_Detail__c>{probCheck});
                           }else{
                               if(mapOfProbationRecord.get(probCheck.PER_ID__c).size() != 2){
                                   mapOfProbationRecord.get(probCheck.PER_ID__c).add(probCheck);                       
                               }
                           }
                       }
                }
            }
            system.debug('mapOfProbationRecord---->'+ mapOfProbationRecord);
            system.debug('size of map---->'+ mapOfProbationRecord.size());
            
            String sMapCCVal1;
            String sMapCCVal2;
            String sMaptypeNoVal1;
            String sMaptypeNoVal2;
            
            for(String perIdKey : mapOfProbationRecord.keyset()){
                Integer i = 0;
                for(CARE_CC_Batch_Detail__c ccBatch : mapOfProbationRecord.get(perIdKey)){
                    system.debug('CCB_Contact_Type_No__c---->'+ ccBatch.CCB_Contact_Type_No__c);
                    system.debug('CARE_CI_CC__r.CC_TYPE_CD__c---->'+ ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c);
                    i = i + 1;
                    if(mapOfProbationRecord.get(perIdKey).size() == 1){
                        
                        if(CARE_Constants.CARE_CC_CODE_PROBATION.contains(ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c)){
                            bIsOnProbation = true;
                            personIdList.add(perIdKey); 
                        }
                        
                        
                    }
                    else if(mapOfProbationRecord.get(perIdKey).size() == 2){
                        //String sMapCCVal1;
                        //String sMapCCVal2;
                        //String sMaptypeNoVal1;
                        //String sMaptypeNoVal2;
                        if(i == 1){
                            sMapCCVal1 = ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c;
                            sMaptypeNoVal1 = ccBatch.CCB_Contact_Type_No__c;
                            
                        }
                        else{
                            sMapCCVal2 = ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c;
                            sMaptypeNoVal2 = ccBatch.CCB_Contact_Type_No__c;
                            
                            if(((CARE_Constants.CARE_CC_CODE_NOT_PROBATION_ONE.contains(sMapCCVal1) || CARE_Constants.CARE_CC_CAECARE_TYPENO.contains(sMaptypeNoVal1)) && (CARE_Constants.CARE_CC_CODE_PROBATION_ONE.contains(sMapCCVal2))) ||
                               ((CARE_Constants.CARE_CC_CODE_NOT_PROBATION_THREE.contains(sMapCCVal1) || CARE_Constants.CARE_CC_CODE_NOT_PROBATION_TYPENO.contains(sMaptypeNoVal1)) && (CARE_Constants.CARE_CC_CODE_PROBATION_TWO.contains(sMapCCVal2)))){
                                   bIsOnProbation = false;
                               }
                            else if(CARE_Constants.CARE_CC_CODE_PROBATION.contains(sMapCCVal1)){                            
                                system.debug('inside 1st else if---->');
                                bIsOnProbation = true;
                                personIdList.add(perIdKey);                             
                            }
                            else if(((!CARE_Constants.CARE_CC_CODE_NOT_PROBATION_ONE.contains(sMapCCVal1) || !CARE_Constants.CARE_CC_CAECARE_TYPENO.contains(sMaptypeNoVal1)) && (CARE_Constants.CARE_CC_CODE_PROBATION_ONE.contains(sMapCCVal2))) ||
                                    ((!CARE_Constants.CARE_CC_CODE_NOT_PROBATION_THREE.contains(sMapCCVal1) || !CARE_Constants.CARE_CC_CODE_NOT_PROBATION_TYPENO.contains(sMaptypeNoVal1)) && (CARE_Constants.CARE_CC_CODE_PROBATION_TWO.contains(sMapCCVal2)))){
                                        system.debug('inside 2nd else if---->');
                                        bIsOnProbation = true;
                                        personIdList.add(perIdKey);
                                    }
                            
                        }
                        
                    }
                }
            }
            
            List<EI_SA_Char__c> listEIChar = [select Id, SERVICE_AGREEMENT__r.Person_ID_EI__c from EI_SA_Char__c
                                              where CHAR_TYPE_CD__c = 'MEDALLOT' AND EFFDT__c >:dDateBeforeTwoYears AND CHAR_VAL__c >=: '1'
                                              AND SERVICE_AGREEMENT__r.Person_ID_EI__c IN: setOfDCode];
            
            if(listEIChar.size() > 0){
                for(EI_SA_Char__c saChar : listEIChar){
                    setOfMedAllot.add(saChar.SERVICE_AGREEMENT__r.Person_ID_EI__c);  
                } 
            }else{
                personIdSetForProbation.addAll(personIdList);
            }
            system.debug('setOfMedAllot--->'+setOfMedAllot);
            
            for(CARE_CC_Batch_Detail__c cCare : CheckListMedi){
                if(setOfMedAllot.contains(cCare.PER_ID__c)){
                    setRemoveMediAllot.add(cCare.PER_ID__c);
                }
            }
            system.debug('setRemoveMediAllot--->'+setRemoveMediAllot);
            
            for(String ssPerId : personIdList){
                if(!setRemoveMediAllot.contains(ssPerId)){
                    personIdSetForProbation.add(ssPerId);  
                }
            }
            
            personIdListForProbation.addAll(personIdSetForProbation);
            
            system.debug('bIsOnProbation boolean----->'+ bIsOnProbation);
            system.debug('personIdListForProbation contents----->'+personIdListForProbation);
            
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
        
        return personIdListForProbation;
        
    }
    
    // This method is used to stamp probation checkbox in Account object
    public static void setProbationStatusOnAccount(List<String> perIdListForProbation){
        
        List<String> probationList = new List<String>();
        List<Account> accListToUpdate = new List<Account>();
        
        try{
            probationList = CARE_AutoUtilityController.determineProbationStatusForAccount(perIdListForProbation);
            
            system.debug('probationList of records returned----->'+probationList);
            
            List<Account> listOfAccounts = [select Id, CARE_ON_PROBATION__c from Account where Billing_Person_ID_EI__c IN: probationList];
            
            if(listOfAccounts.size() > 0){
                for(Account acct : listOfAccounts){
                    acct.CARE_ON_PROBATION__c = true;
                    accListToUpdate.add(acct);
                }
            }
            
            if(accListToUpdate.size() > 0){
                update accListToUpdate;
            }
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
    }
    
    // This method is invoked from CARE_StampVCodeBatch used to determine person Id's eligible 
    // for V Code stamping in CARE Application
    public static StampVCodeWrapper determineVCodeStamping(List<CARE_Batch_Staging__c> listOfVCodeRecords){
        
        system.debug('inside V code stamping criteria check method');
        system.debug('list of v code records in utility-->'+listOfVCodeRecords);
        
        Date dTodaysDate = Date.today();
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTwoYears);
        Date dDateBeforeSixMonths = dTodaysDate.addDays(-CARE_Constants.CARE_BeforeSixMonths);
        Date dDateAfterSixMonths = dTodaysDate.addDays(+CARE_Constants.CARE_BeforeSixMonths);
        
        StampVCodeWrapper wrappers = new StampVCodeWrapper();
        Set<Id> setId = new Set<Id>();
        Set<Id> errorIdSet = new Set<Id>();
        Set<String> errorPerIdSet = new Set<String>();
        Set<String> perIdSet = new Set<String>();
        String sysAdminError = '';
        Set<String> perIdFinalSetFromSite = new Set<String>();
        Map<string, List<CARE_CC_Batch_Detail__c>> mapOfVCodeRecord = new Map<string, List<CARE_CC_Batch_Detail__c>>();
        //Map<string,string> mapOfErrorRecordReason = new Map<string,string>();
        Set<String> personIdSet = new Set<String>();
        Set<String> setPerId = new Set<String>();
        Set<String> setPerIdFromCBS = new Set<String>();
        List<CARE_Batch_Staging__c> finalList = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> dropListCBS = new List<CARE_Batch_Staging__c>();
        Set<String> finalListPerId = new Set<String>();
        List<CARE_Batch_Staging__c> VCodeFinalList = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listUpdateCBS = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listOfSuccessCBS = new List<CARE_Batch_Staging__c>();
        List<EI_Site__c> activeSiteList = new List<EI_Site__c>();
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        
        try{
            listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_V_HU,null,null);
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            if(listOfVCodeRecords.size() > 0){
                for(CARE_Batch_Staging__c careUploadRec : listOfVCodeRecords){
                    if(careUploadRec.PER_ID__c != null){
                        setPerIdFromCBS.add(careUploadRec.PER_ID__c); 
                    } 
                }
                
                List<CARE_CC_Batch_Detail__c> CheckListForVCode = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c
                                                                   from CARE_CC_Batch_Detail__c 
                                                                   where PER_ID__c IN: setPerIdFromCBS AND CARE_CI_CC__r.CC_DTTM__c >=: dDateBeforeTwoYears
                                                                   order by CARE_CI_CC__r.CC_DTTM__c DESC];
                
                
                if(CheckListForVCode.size() > 0){
                        for(CARE_CC_Batch_Detail__c batchCheck : CheckListForVCode){
                            setPerId.add(batchCheck.PER_ID__c); 
                            if(mapOfVCodeRecord.get(batchCheck.PER_ID__c) == null){
                                mapOfVCodeRecord.put(batchCheck.PER_ID__c ,new List<CARE_CC_Batch_Detail__c>{batchCheck});
                            }else{
                                mapOfVCodeRecord.get(batchCheck.PER_ID__c).add(batchCheck);                       
                            }                
                        }
                    
                    system.debug('mapOfVCodeRecord value for criteria check--->'+mapOfVCodeRecord);
                    for(String perIdKey : mapOfVCodeRecord.keyset()){
                        for(CARE_CC_Batch_Detail__c ccBatch : mapOfVCodeRecord.get(perIdKey)){
                            system.debug('CCB_Contact_Type_No__c---->'+ ccBatch.CCB_Contact_Type_No__c);
                            system.debug('CARE_CI_CC__r.CC_TYPE_CD__c---->'+ ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c);
                            system.debug('CARE_CI_CC__r.CC_DTTM__c---->'+ ccBatch.CARE_CI_CC__r.CC_DTTM__c);
                            
                            if(ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_HU && ccBatch.CARE_CI_CC__r.CC_DTTM__c >=  dDateBeforeSixMonths){
                                system.debug('inside 1st if block--->');
                                personIdSet.add(perIdKey);
                                //mapOfErrorRecordReason.put(perIdKey, 'PEV Customer Filter Reason - Already V wi 45 days');
                                break;
                            }
                            else if(CARE_Constants.CARE_CC_CODE_VSTAMP.contains(ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c) || //ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'RANDOM CERT' || ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'H RAND CERT' || ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'C RANDOM' ||
                                    (ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'C AE CARE' && ccBatch.CCB_Contact_Type_No__c == CARE_Constants.CARE_CC_REACH) || (ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'C AE CARE' && ccBatch.CCB_Contact_Type_No__c == CARE_Constants.CARE_CC_LIHEAP) || (ccBatch.CARE_CI_CC__r.CC_TYPE_CD__c == 'C AE CARE' && ccBatch.CCB_Contact_Type_No__c == CARE_Constants.CARE_CC_ESA)){
                                        system.debug('inside 1st else if block--->');
                                        personIdSet.add(perIdKey);
                                        //mapOfErrorRecordReason.put(perIdKey, 'PEV Customer Filter Reason - In LiHeap, EPO, REACH');
                                        break;  
                                    }
                        
                        }
                    }
             
                //personIdSet.addAll(perIdFinalSetFromSite);
                system.debug('personIdSet----->'+ personIdSet);
                
                if(personIdSet.size() > 0){    
                    for(CARE_Batch_Staging__c cb : listOfVCodeRecords){
                        
                        if(!personIdSet.contains(cb.PER_ID__c)){
                            finalListPerId.add(cb.PER_ID__c);
                            finalList.add(cb);
                        }else {
                            cb.Processing_Message__c = CARE_Constants.CARE_VCODE_VALIDATIONFAIL;
                            cb.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                            dropListCBS.add(cb);
                        }
                    }
                }else{
                    finalListPerId = setPerId;
                }
                system.debug('finalListPerId----->'+finalListPerId);
                    
                if(finalListPerId.size() > 0){
                List<EI_Site__c> perIdListSite = [select Person_ID_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dDateAfterSixMonths AND Person_ID_EI__c IN: finalListPerId];
                            
                    for(EI_Site__c objSite : perIdListSite){
                        perIdSet.add(objSite.Person_ID_EI__c); 
                    }
                }
                
                if(finalList.size() > 0){    
                    for(CARE_Batch_Staging__c cbRec : finalList){
                        
                        if(!perIdSet.contains(cbRec.PER_ID__c)){
                            VCodeFinalList.add(cbRec); 
                        }
                        else{
                            cbRec.Processing_Message__c = CARE_Constants.CARE_VCODE_VALIDATIONFAIL;
                            cbRec.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                            dropListCBS.add(cbRec);
                        }
                    }
                }else{
                    VCodeFinalList = finalList;
                }
                 system.debug('VCodeFinalList---->'+VCodeFinalList); 
                    
                 if(VCodeFinalList.size() > 0){
                     for(CARE_Batch_Staging__c objSite : VCodeFinalList){
                         CARE_Application__c careApp = new CARE_Application__c();
                         careApp.RecordTypeId = careAppRecTypeId;
                         careApp.APPLICANT_NAME__c = objSite.APPLICANT_NAME__c;
                         careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
                         careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT_OTHER;
                         careApp.RECEIVED_DATE__c = dTodaysDate; 
                         careApp.PROCESSED_DATE__c = dTodaysDate;
                         careApp.PER_ID__c = objSite.PER_ID__c;
                         careApp.CARE_Account_ID__c = objSite.EI_ACCOUNT__c;
                         careApp.ACCT_ID__c = objSite.CARE_BILLING_ACCT_ID__c;
                         careApp.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                         careApp.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                         careApp.CCB_Contact_Type_No__c = listCareTypeDesc[0].TYPE_NO__c;
                         careApp.CCB_CONTACT_COMMENT__c = listCareTypeDesc[0].TYPE_DESC_LONG__c;
                         careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                         careAppList.add(careApp);
                         
                         //updating processing status and processing message for success records
                         objSite.Processing_Status__c = CARE_Constants.CARE_PROCESSING_SUCCESS;
                         objSite.Processing_Message__c = CARE_Constants.CARE_VCODE_SUCCESSMSG;
                         listOfSuccessCBS.add(objSite);
                         
                         system.debug('careAppList--->'+careAppList); 
                     }
                     
                     Database.SaveResult[] srList = Database.insert(careAppList, false);
                     
                     for(Integer i =0; i < srList.size(); i++) {
                         if(srList.get(i).isSuccess()){
                             setId.add(srList.get(i).Id);
                         }
                         else if(!srList.get(i).isSuccess()){
                             Database.Error errors =  srList.get(i).getErrors().get(0);
                             errorIdSet.add(srList.get(i).Id);
                             errorPerIdSet.add(careAppList[i].PER_ID__c); 
                             sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                             
                         }
                     }
                     if(!String.isBlank(sysAdminError)) {
                         EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_AutoUtilityController', new EI_BatchException(sysAdminError)));
                     }
                     
                     }   
                    
                }else{
                      for(CARE_Batch_Staging__c cb : listOfVCodeRecords){
                            cb.Processing_Message__c = CARE_Constants.CARE_VCODE_VALIDATIONFAIL;
                            cb.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                            dropListCBS.add(cb);
                       }
                }     
                    
                    if(dropListCBS.size() > 0){
                       update dropListCBS;
                    }
                    if(listOfSuccessCBS.size() > 0){
                       update listOfSuccessCBS;
                    }
                    
            }
            //system.debug('VCodeFinalList----->'+VCodeFinalList);
            wrappers.careAppSet = setId;
            wrappers.careAppErrorIdSet = errorIdSet;
            wrappers.setErrorPerId = errorPerIdSet;
            
        }catch(exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_AutoUtilityController', ex));
            CARE_UtilityController.sendExceptionEmail('CARE_AutoUtilityController', '', '', '', ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
        return wrappers;
    }
    
    // This method is invoked from CARE_StampVCodeBatch used to determine person Id's eligible 
    // for V Code stamping in CARE Application
    public static StampVHCodeWrapper determineVHCodeStamping(List<CARE_Batch_Staging__c> listOfVHCodeRecords){
        system.debug('inside VH code stamping criteria check method');
        system.debug('list of VH code records in utility-->'+listOfVHCodeRecords);
        
        Date dTodaysDate = Date.today();
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTwoYears);
        Date dDateBeforeSixMonths = dTodaysDate.addDays(-CARE_Constants.CARE_BeforeSixMonths);
        Date dDateAfterSixMonths = dTodaysDate.addDays(+CARE_Constants.CARE_BeforeSixMonths);
        
        StampVHCodeWrapper vHwrappers = new StampVHCodeWrapper();
        String sysAdminError = '';
        Set<String> setPerIdCBS = new Set<String>();
        Set<String> setPerId = new Set<String>();
        Set<Id> setId = new Set<Id>();
        Set<Id> errorIdSet = new Set<Id>();
        Set<String> errorPerIdSet = new Set<String>();
        Set<String> setPerIdSite = new Set<String>();
        Set<String> notDropPerIdSet = new Set<String>();
        Set<String> finalListPerId = new Set<String>();
        //Set<String> setOfVHPerId = new Set<String>();
        List<CARE_Batch_Staging__c> listOfVHRecFinal = new List<CARE_Batch_Staging__c>();
        Map<string, List<CARE_CC_Batch_Detail__c>> mapOfVHCodeRecord = new Map<string, List<CARE_CC_Batch_Detail__c>>();
        List<EI_Site__c> perIdListSite = new List<EI_Site__c>();
        List<CARE_Batch_Staging__c> finalList = new List<CARE_Batch_Staging__c>();
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<EI_Site__c> activeSiteList = new List<EI_Site__c>();
        List<CARE_Batch_Staging__c> dropVHListCBS = new List<CARE_Batch_Staging__c>();
        List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        List<CARE_Batch_Staging__c> listUpdateCBS = new List<CARE_Batch_Staging__c>();
        List<CARE_Batch_Staging__c> listOfSuccessCBS = new List<CARE_Batch_Staging__c>();
        
        
        
        try{
            listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_VH_HU,null,null);
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            if(listOfVHCodeRecords.size() > 0){
                for(CARE_Batch_Staging__c careUploadRecord : listOfVHCodeRecords){
                    if(careUploadRecord.PER_ID__c != null){
                        setPerIdCBS.add(careUploadRecord.PER_ID__c); 
                    } 
                }
                
                List<CARE_CC_Batch_Detail__c> CheckListForVHCode = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c
                                                                   //CARE_APP_ENROLLED_SA__r.Service_Agreement__r.Care_Stop_Date_EI__c
                                                                   from CARE_CC_Batch_Detail__c 
                                                                   where PER_ID__c IN: setPerIdCBS AND CARE_CI_CC__r.CC_DTTM__c >=: dDateBeforeTwoYears
                                                                   order by CARE_CI_CC__r.CC_DTTM__c DESC];
                
                if(CheckListForVHCode.size() > 0){
                    for(CARE_CC_Batch_Detail__c batchCheck : CheckListForVHCode){
                        setPerId.add(batchCheck.PER_ID__c); 
                        if(mapOfVHCodeRecord.get(batchCheck.PER_ID__c) == null){
                            mapOfVHCodeRecord.put(batchCheck.PER_ID__c ,new List<CARE_CC_Batch_Detail__c>{batchCheck});
                        }else{
                            mapOfVHCodeRecord.get(batchCheck.PER_ID__c).add(batchCheck);                       
                        }                
                    }
                    
                    system.debug('mapOfVHCodeRecord value for criteria check--->'+mapOfVHCodeRecord);
                    
                    for(String perIdKey : mapOfVHCodeRecord.keyset()){
                        for(CARE_CC_Batch_Detail__c ccBatchRec : mapOfVHCodeRecord.get(perIdKey)){
                            system.debug('CCB_Contact_Type_No__c---->'+ ccBatchRec.CCB_Contact_Type_No__c);
                            system.debug('CARE_CI_CC__r.CC_TYPE_CD__c---->'+ ccBatchRec.CARE_CI_CC__r.CC_TYPE_CD__c);
                            system.debug('CARE_CI_CC__r.CC_DTTM__c---->'+ ccBatchRec.CARE_CI_CC__r.CC_DTTM__c);
                            
                            if(ccBatchRec.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_PEV && ccBatchRec.CARE_CI_CC__r.CC_DTTM__c >=  dDateBeforeSixMonths){
                              notDropPerIdSet.add(perIdKey);
                                break;
                            }
                            else if(ccBatchRec.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_ESA_ENROLLMENTCHECK || ccBatchRec.CARE_CI_CC__r.CC_TYPE_CD__c == CARE_Constants.CARE_CC_CRANDOM){
                              notDropPerIdSet.add(perIdKey);
                                break;
                            }
                        }
                    }
                
                    system.debug('notDropPerIdSet----->'+ notDropPerIdSet);
                    if(notDropPerIdSet.size() > 0){
                        for(CARE_Batch_Staging__c cbRec : listOfVHCodeRecords){
                            if(!notDropPerIdSet.contains(cbRec.PER_ID__c)){
                                finalList.add(cbRec);
                                finalListPerId.add(cbRec.PER_ID__c);
                            }else {
                                cbRec.Processing_Message__c = CARE_Constants.CARE_VHCODE_VALIDATIONFAIL;
                                cbRec.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                                dropVHListCBS.add(cbRec); 
                            }
                        }
                    }else{
                        finalListPerId = setPerId;
                    }
                    system.debug('finalListPerId---->'+finalListPerId);
                    system.debug('finalList---->'+finalList);
                    system.debug('dropVHListCBS---->'+dropVHListCBS);
                    if(finalListPerId.size() > 0){
                        perIdListSite = [select Person_ID_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dDateAfterSixMonths AND Person_ID_EI__c IN: finalListPerId];
                        for(EI_Site__c objSite : perIdListSite){
                            setPerIdSite.add(objSite.Person_ID_EI__c); 
                        }
                    }
                    if(finalList.size() > 0){
                        for(CARE_Batch_Staging__c cBRecord : finalList){
                            if(!setPerIdSite.contains(cBRecord.PER_ID__c)){
                                listOfVHRecFinal.add(cBRecord); 
                            }
                            else {
                                cBRecord.Processing_Message__c = CARE_Constants.CARE_VHCODE_VALIDATIONFAIL;
                                cBRecord.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                                dropVHListCBS.add(cBRecord); 
                            }
                        }
                    }else{
                        listOfVHRecFinal = finalList;
                    }
                    system.debug('listOfVHRecFinal----->'+listOfVHRecFinal);
                    
                    if(listOfVHRecFinal.size() > 0){                    
                        for(CARE_Batch_Staging__c objSite : listOfVHRecFinal){
                            CARE_Application__c careApp = new CARE_Application__c();
                            careApp.RecordTypeId = careAppRecTypeId;
                            careApp.APPLICANT_NAME__c = objSite.APPLICANT_NAME__c;
                            careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
                            careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT_OTHER;
                            careApp.PER_ID__c = objSite.PER_ID__c;
                            careApp.RECEIVED_DATE__c = dTodaysDate; 
                            careApp.PROCESSED_DATE__c = dTodaysDate;
                            careApp.CARE_Account_ID__c = objSite.EI_ACCOUNT__c;
                            careApp.ACCT_ID__c = objSite.CARE_BILLING_ACCT_ID__c;
                            careApp.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                            careApp.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                            careApp.CCB_Contact_Type_No__c = listCareTypeDesc[0].TYPE_NO__c;
                            careApp.CCB_CONTACT_COMMENT__c = listCareTypeDesc[0].TYPE_DESC_LONG__c;
                            careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                            careAppList.add(careApp);
                            
                            objSite.Processing_Status__c = CARE_Constants.CARE_PROCESSING_SUCCESS;
                            objSite.Processing_Message__c = CARE_Constants.CARE_VHCODE_SUCCESSMSG;
                            listOfSuccessCBS.add(objSite);
                        }
                        system.debug('careAppList--->'+careAppList); 
                        Database.SaveResult[] srList = Database.insert(careAppList, false);
                        
                        for(Integer i =0; i < srList.size(); i++) {
                            if(srList.get(i).isSuccess()){
                                setId.add(srList.get(i).Id);
                            }
                            else if(!srList.get(i).isSuccess()){
                                Database.Error errors =  srList.get(i).getErrors().get(0);
                                errorIdSet.add(srList.get(i).Id);
                                errorPerIdSet.add(careAppList[i].PER_ID__c); 
                                sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                                
                            }
                        }
                        system.debug('setId--->'+setId); 
                        system.debug('errorIdSet--->'+errorIdSet); 
                        system.debug('errorPerIdSet--->'+errorPerIdSet); 
                        if(!String.isBlank(sysAdminError)) {
                            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_AutoUtilityController', new EI_BatchException(sysAdminError)));
                        }

                    }
                                  
                }else{
                    for(CARE_Batch_Staging__c cBRecord : listOfVHCodeRecords){
                                cBRecord.Processing_Message__c = CARE_Constants.CARE_VHCODE_VALIDATIONFAIL;
                                cBRecord.Processing_Status__c = CARE_Constants.CARE_PROCESSING_ERROR;
                                dropVHListCBS.add(cBRecord); 
                        }
                }
                
                    
                if(dropVHListCBS.size() > 0){
                    update dropVHListCBS;
                }
                if(listOfSuccessCBS.size() > 0){
                    update listOfSuccessCBS;
                }
                
         }
            vHwrappers.careAppSet = setId;
            vHwrappers.careAppErrorIdSet = errorIdSet;
            vHwrappers.setErrorPerId = errorPerIdSet;
            
        }catch(exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_AutoUtilityController', ex));
            CARE_UtilityController.sendExceptionEmail('CARE_AutoUtilityController', '', '', '', ex);
            //system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
        return vHwrappers;
    }
    
    
    // This method is used to drop PEV customer after 45 days of V code stamping
    public static PEVResponseCheckWrapper PEVFortyFiveDaysCheck(List<CARE_CC_Batch_Detail__c> listOfVCode){
        
        Integer iSystemValue;
        String sysAdminError = '';
        Date dTodaysDate = Date.today();
        Date dFortyFiveDay;
        Date dDateTwoYearsBefore;
        boolean bDropCustomer = false;
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<CARE_App_Enrolled_SA__c> careAppEnrollSAList = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_CC_Batch_Detail__c> listOfVCodeRem = new List<CARE_CC_Batch_Detail__c>();
        List<CARE_Application__c> careAppListOfRec = new List<CARE_Application__c>();
        //List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        //List<CARE_CC_Batch_Detail__c> listOfDropVCodeFinal = new List<CARE_CC_Batch_Detail__c>();
        Set<String> setOfVPerId = new Set<String>();
        Set<String> setOfCaePerId = new Set<String>();
        Set<String> setPerIdFinal = new Set<String>();
        Set<String> remVCodeSet = new Set<String>();
        Set<String> setOfOtherPerId = new Set<String>();        
        Set<Id> setId = new Set<Id>();
        Set<Id> setIdAppEnroll = new Set<Id>();
        Set<Id> errorIdSet = new Set<Id>();
        Set<String> errorPerIdSet = new Set<String>();
        PEVResponseCheckWrapper responseWrapper = new PEVResponseCheckWrapper();
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        try{
            system.debug('listOfVCode in AutoUtilityController--->'+listOfVCode);
            
            if(listOfVCode.size() > 0){
                for(CARE_CC_Batch_Detail__c cc : listOfVCode){
                    setOfVPerId.add(cc.PER_ID__c);
                }
                
                system.debug('setOfVPerId--->'+setOfVPerId);
                
                List<CARE_CC_Batch_Detail__c> listOfCAECode = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c
                                                               from CARE_CC_Batch_Detail__c where ((CARE_CI_CC__r.CC_TYPE_CD__c = 'C AE CARE' AND CCB_Contact_Type_No__c =: CARE_Constants.CARE_CC_REACH) OR (CARE_CI_CC__r.CC_TYPE_CD__c = 'C AE CARE' AND CCB_Contact_Type_No__c =: CARE_Constants.CARE_CC_LIHEAP) OR
                                                                                                   (CARE_CI_CC__r.CC_TYPE_CD__c = 'C AE CARE' AND CCB_Contact_Type_No__c =: CARE_Constants.CARE_CC_ESA))
                                                               AND CARE_CI_CC__r.CC_DTTM__c >=: dFortyFiveDay AND PER_ID__c IN: setOfVPerId];
                
                if(listOfCAECode.size() > 0){
                    for(CARE_CC_Batch_Detail__c cc : listOfCAECode){
                        setOfCaePerId.add(cc.PER_ID__c);
                    }
                    for(CARE_CC_Batch_Detail__c ccBD : listOfVCode){
                        if(!setOfCaePerId.contains(ccBD.PER_ID__c)){
                            listOfVCodeRem.add(ccBD);
                            remVCodeSet.add(ccBD.PER_ID__c);
                        } 
                    } 
                }else{
                    remVCodeSet = setOfVPerId;
                    listOfVCodeRem = listOfVCode; 
                }
                system.debug('setOfCaePerId--->'+setOfCaePerId);       
                system.debug('listOfVCodeRem--->'+listOfVCodeRem);
                
                List<CARE_CC_Batch_Detail__c> listOfOtherCode = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c
                                                                 from CARE_CC_Batch_Detail__c 
                                                                 where (CARE_CI_CC__r.CC_TYPE_CD__c = 'H RAND CERT' OR CARE_CI_CC__r.CC_TYPE_CD__c = 'RANDOM CERT' OR 
                                                                        CARE_CI_CC__r.CC_TYPE_CD__c = 'C RANDOM') 
                                                                 AND CARE_CI_CC__r.CC_DTTM__c >=: dFortyFiveDay AND PER_ID__c IN: remVCodeSet ORDER by CARE_CI_CC__r.CC_DTTM__c DESC];
                system.debug('listOfOtherCode--->'+listOfOtherCode);
                
                if(listOfOtherCode.size() > 0){
                    for(CARE_CC_Batch_Detail__c ccB : listOfOtherCode){
                        setOfOtherPerId.add(ccB.PER_ID__c);
                    }
                    for(CARE_CC_Batch_Detail__c careBatch : listOfVCodeRem){
                        if(!setOfOtherPerId.contains(careBatch.PER_ID__c)){
                            //listOfDropVCodeFinal.add(careBatch);
                            setPerIdFinal.add(careBatch.PER_ID__c);
                        } 
                    }  
                }else{
                    setPerIdFinal = remVCodeSet; //no Per Id present as H RAND CERT 
                }
                system.debug('setOfOtherPerId--->'+setOfOtherPerId);
                
                system.debug('setPerIdFinal--->'+setPerIdFinal);
                
                List<EI_Site__c> customerDropList = [select Id, Person_ID_EI__c, Account_EI__c, Svc_Type_Code_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Rate_Schedule_EI__c,
                                                     Site_Premise_ID_EI__c, SAID_EI__c, Imported_Site_Name_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dTodaysDate
                                                     AND Person_ID_EI__c IN: setPerIdFinal];
                
                if(customerDropList.size() > 0){
                    for(EI_Site__c objSite : customerDropList){
                        CARE_Application__c careApp = new CARE_Application__c();
                        careApp.RecordTypeId = careAppRecTypeId;
                        careApp.APPLICANT_NAME__c = objSite.Imported_Site_Name_EI__c;
                        careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;
                        careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_STAGED_CCB;
                        careApp.PER_ID__c = objSite.Person_ID_EI__c;
                        careApp.CARE_Account_ID__c = objSite.Account_EI__c;
                        careApp.ACCT_ID__c = objSite.Billing_Account_ID_EI__c;
                        careApp.CCB_CONTACT_CODE__c = CARE_Constants.CARE_CC_PEVDROP;
                        careApp.CCB_CONTACT_DESC__c = CARE_Constants.CARE_PEV_DROP;
                        careApp.CCB_Contact_Type_No__c = CARE_Constants.CARE_CC_PEVDROP_NO;
                        careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                        careApp.PROCESSED_DATE__c = dTodaysDate;
                        careApp.RECEIVED_DATE__c = dTodaysDate;
                        careApp.CC_CL_CD__c = objSite.Account_EI__r.CARE_DISCOUNT_TYPE__c;
                        careAppList.add(careApp);
                        system.debug('careAppList--->'+careAppList);
                    }
                }
                system.debug('careAppList size-->'+careAppList.size());
                
                if(careAppList.size() > 0){
                    Database.SaveResult[] srList = Database.insert(careAppList, false);
                    
                    for(Integer i =0; i < srList.size(); i++) {
                        if(srList.get(i).isSuccess()){
                            setId.add(srList.get(i).Id);
                        }
                        else if(!srList.get(i).isSuccess()){
                            Database.Error errors =  srList.get(i).getErrors().get(0);
                            errorIdSet.add(srList.get(i).Id);
                            errorPerIdSet.add(careAppList[i].PER_ID__c); 
                            sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                            
                        }
                    }
                }
                
                if(!String.isBlank(sysAdminError)) {
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_PEVFortyFiveDayBatch', new EI_BatchException(sysAdminError)));
                }
                
                if(setId.size() > 0){
                    careAppListOfRec = [Select Id, PER_ID__c from CARE_Application__c where Id IN: setId AND CCB_Contact_Type_No__c =: CARE_Constants.CARE_CC_PEVDROP_NO];
                                        
                }
                system.debug('careAppListOfRec---->'+careAppListOfRec);
                
                if(careAppListOfRec.size() > 0){
                    for(EI_Site__c objSA : customerDropList){
                        for(CARE_Application__c careObj : careAppListOfRec){
                            if(objSA.Person_ID_EI__c == careObj.PER_ID__c){
                                CARE_App_Enrolled_SA__c careAppEnroll = new CARE_App_Enrolled_SA__c();
                                careAppEnroll.ACCT_ID__c =  objSA.Billing_Account_ID_EI__c;
                                careAppEnroll.APPLICATION__c =  careObj.Id;
                                careAppEnroll.CC_CL_CD__c =  objSA.Account_EI__r.CARE_DISCOUNT_TYPE__c;//remove hardcode and bring from account object
                                careAppEnroll.PER_ID__c =  careObj.PER_ID__c;
                                careAppEnroll.PREM_ID__c =  objSA.Site_Premise_ID_EI__c;
                                careAppEnroll.RS_CD__c =  objSA.Rate_Schedule_EI__c;
                                careAppEnroll.SA_ID__c =  objSA.SAID_EI__c;
                                careAppEnroll.CCB_CONTACT_TYPE__c =  CARE_Constants.CARE_CC_PEVDROP_NO;
                                careAppEnroll.END_DATE__c = dTodaysDate;
                                careAppEnroll.SERVICE_TYPE_CODE__c = objSA.Svc_Type_Code_EI__c;
                                careAppEnroll.Service_Agreement__c = objSA.Id;
                                careAppEnrollSAList.add(careAppEnroll);
                            } 
                        } 
                    }
                } 
                
                Database.SaveResult[] srL = Database.insert(careAppEnrollSAList, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srL) {
                    if (sr.isSuccess()) {
                        //System.debug('Successfully inserted careAppEnroll--->: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors               
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('CAre Application fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            responseWrapper.careAppPEVSet = setId;
            responseWrapper.careAppErrorIdSet = errorIdSet;
            responseWrapper.setErrorPerId = errorPerIdSet;
            
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
            //EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_StampVCodeBatch', new EI_BatchException(sysAdminError)));
        }
        return responseWrapper;
    }
    
    // This method is used to drop customer HU Customers after 45 days of VH code stamping
    public static HUResponseCheckWrapper HUFortyFiveDaysCheck(List<CARE_CC_Batch_Detail__c> listOfVHCode){
        
        String sysAdminError = '';
        Date dTodaysDate = Date.today();
        Date dFortyFiveDay; 
        Date dDateTwoYearsBefore;
        boolean bDropCustomer = false;
        Integer iSystemValue;
        Set<String> setOfVHPerId = new Set<String>();
        Set<String> setOfOtherPerId = new Set<String>();
        Set<String> setOfHUDropPerId = new Set<String>();
        Set<String> remVCodeSet = new Set<String>();
        Set<String> errorPerIdSet = new Set<String>();
        Set<Id> setId = new Set<Id>();
        Set<Id> errorIdSetHU = new Set<Id>();
        //List<CARE_System_Value__c> listGetSystemValue = new List<CARE_System_Value__c>();
        List<EI_Site__c> customerDropListHU = new List<EI_Site__c>();
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<CARE_Application__c> careAppListOfRec = new List<CARE_Application__c>();
        List<CARE_App_Enrolled_SA__c> careAppEnrollSAList = new List<CARE_App_Enrolled_SA__c>();
        HUResponseCheckWrapper hUResponseWrapper = new HUResponseCheckWrapper();
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        try{
            system.debug('listOfVHCode in autocontroller--->'+listOfVHCode);
            
            if(listOfVHCode.size() > 0){
                for(CARE_CC_Batch_Detail__c ccVH : listOfVHCode){
                    setOfVHPerId.add(ccVH.PER_ID__c); 
                }
                system.debug('setOfVHPerId---->'+setOfVHPerId);
                
                List<CARE_CC_Batch_Detail__c> listOfOtherVHCode = [select Id, PER_ID__c, CCB_Contact_Type_No__c, CARE_CI_CC__r.CC_TYPE_CD__c, CARE_CI_CC__r.CC_DTTM__c
                                                                   from CARE_CC_Batch_Detail__c 
                                                                   where (CARE_CI_CC__r.CC_TYPE_CD__c = 'H RAND CERT' OR CARE_CI_CC__r.CC_TYPE_CD__c = 'C RANDOM') 
                                                                   AND CARE_CI_CC__r.CC_DTTM__c >: dFortyFiveDay AND PER_ID__c IN: setOfVHPerId ORDER by CARE_CI_CC__r.CC_DTTM__c DESC];
                
                if(listOfOtherVHCode.size() > 0){
                    for(CARE_CC_Batch_Detail__c cc : listOfOtherVHCode){
                        setOfOtherPerId.add(cc.PER_ID__c);
                    }
                    for(CARE_CC_Batch_Detail__c ccBD : listOfVHCode){
                        if(!setOfOtherPerId.contains(ccBD.PER_ID__c)){
                            setOfHUDropPerId.add(ccBD.PER_ID__c);
                        }
                    }
                }else{
                    setOfHUDropPerId = setOfVHPerId;
                    
                }
                system.debug('setOfHUDropPerId--->'+setOfHUDropPerId);
                
                if(setOfHUDropPerId.size() > 0){
                    customerDropListHU = [select Id, Person_ID_EI__c, Svc_Type_Code_EI__c, Account_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Rate_Schedule_EI__c,
                                          Site_Premise_ID_EI__c, SAID_EI__c, Imported_Site_Name_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dTodaysDate
                                          AND Person_ID_EI__c IN: setOfHUDropPerId];
                }
                
                if(customerDropListHU.size() > 0){
                    for(EI_Site__c sa : customerDropListHU){
                        CARE_Application__c careApp = new CARE_Application__c();
                        careApp.RecordTypeId = careAppRecTypeId;
                        careApp.APPLICANT_NAME__c = sa.Imported_Site_Name_EI__c;
                        careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_STAGED_CCB;
                        careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT_OTHER;
                        careApp.PER_ID__c = sa.Person_ID_EI__c;
                        careApp.CARE_Account_ID__c = sa.Account_EI__c;
                        careApp.ACCT_ID__c = sa.Billing_Account_ID_EI__c;
                        careApp.CC_CL_CD__c = sa.Account_EI__r.CARE_DISCOUNT_TYPE__c;
                        careApp.CCB_CONTACT_CODE__c = CARE_Constants.CARE_CC_HU_NORESPONSE;
                        careApp.CCB_CONTACT_DESC__c = CARE_Constants.CARE_PEV_DROP_HU;
                        careApp.CCB_Contact_Type_No__c = CARE_Constants.CARE_CC_HU_NORESPONSE_NO;
                        careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                        careApp.PROCESSED_DATE__c = dTodaysDate;
                        careApp.RECEIVED_DATE__c = dTodaysDate;
                        careAppList.add(careApp);
                        //system.debug('careAppList--->'+careAppList); 
                    }
                }
                system.debug('careAppList--->'+careAppList); 
                if(careAppList.size() > 0){
                    Database.SaveResult[] srList = Database.insert(careAppList, false);
                    for(Integer i =0; i < srList.size(); i++) {
                        if(srList.get(i).isSuccess()){
                            setId.add(srList.get(i).Id);
                        }
                        else if(!srList.get(i).isSuccess()){
                            Database.Error errors =  srList.get(i).getErrors().get(0);
                            errorIdSetHU.add(srList.get(i).Id);
                            errorPerIdSet.add(careAppList[i].PER_ID__c); 
                            sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                            
                        }
                    }
                }
                
                if(!String.isBlank(sysAdminError)) {
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_PEVFortyFiveDayBatch', new EI_BatchException(sysAdminError)));
                }
                
                if(setId.size() > 0){
                    careAppListOfRec = [Select Id, PER_ID__c from CARE_Application__c where Id IN: setId AND CCB_Contact_Type_No__c =: CARE_Constants.CARE_CC_HU_NORESPONSE_NO];
                                        
                }
                system.debug('careAppListOfRec---->'+careAppListOfRec);
                
                if(careAppListOfRec.size() > 0){
                    for(EI_Site__c objSA : customerDropListHU){
                        for(CARE_Application__c careObj : careAppListOfRec){
                            if(objSA.Person_ID_EI__c == careObj.PER_ID__c){
                                CARE_App_Enrolled_SA__c careAppEnroll = new CARE_App_Enrolled_SA__c();
                                careAppEnroll.ACCT_ID__c =  objSA.Billing_Account_ID_EI__c;
                                careAppEnroll.APPLICATION__c =  careObj.Id;
                                careAppEnroll.CC_CL_CD__c =  objSA.Account_EI__r.CARE_DISCOUNT_TYPE__c;//remove hardcode and bring from account object
                                careAppEnroll.PER_ID__c =  careObj.PER_ID__c;
                                careAppEnroll.PREM_ID__c =  objSA.Site_Premise_ID_EI__c;
                                careAppEnroll.RS_CD__c =  objSA.Rate_Schedule_EI__c;
                                careAppEnroll.SA_ID__c =  objSA.SAID_EI__c;
                                careAppEnroll.CCB_CONTACT_TYPE__c =  CARE_Constants.CARE_CC_HU_NORESPONSE_NO;
                                careAppEnroll.END_DATE__c = dTodaysDate;
                                careAppEnroll.SERVICE_TYPE_CODE__c = objSA.Svc_Type_Code_EI__c;
                                careAppEnroll.Service_Agreement__c = objSA.Id;
                                careAppEnrollSAList.add(careAppEnroll);
                            } 
                        } 
                    }
                } 
                system.debug('careAppEnrollSAList--->'+careAppEnrollSAList); 
                Database.SaveResult[] srL = Database.insert(careAppEnrollSAList, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srL) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted careAppEnroll--->: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors               
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('CAre Application fields that affected this error: ' + err.getFields());
                        }
                    }
                }    
            }
            hUResponseWrapper.careAppHUSet = setId;
            hUResponseWrapper.errorIdSetHU = errorIdSetHU;
            hUResponseWrapper.errorPerIdSet = errorPerIdSet;
        }
        catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
        return hUResponseWrapper;
    }
    
    /**
* @Description: Static method for identifying BAD ACC IDs that are not 10 digits
* @Parameter: Set<String>, List<String>
* @Return: Set<String>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To filter out CARE_App_Staging records that have bad ACC IDs that are not 10 digits
**/
    public static Set<String> getBadBillAccIDs(Set<String> billAccIdSet, List<String> validRSList) {
        System.Debug('billAccIdSet = ' + billAccIdSet);
        System.Debug('validRSList = ' + validRSList);
        
        Set<String> badBillAccIdSet = new Set<String> ();
        
        try {
            // Identify Billing ACC IDs that are not 10 digits
            for (String billAccId :billAccIdSet) {
                if (String.isBlank(billAccId) || billAccId.length() != 10) {
                    badBillAccIdSet.add(billAccId);
                }
            }
            System.Debug('badBillAccIdSet = ' + badBillAccIdSet);
            
            // Remove all identified bad Billing ACC IDs from billAccIdSet
            billAccIdSet.removeAll(badBillAccIdSet);
            System.Debug('billAccIdSet = ' + billAccIdSet);
            
            // Fetch SAs using Billing ACC IDs and generate a Map with ACC ID as KEY and List of SAs as VALUE
            Map<String, List<EI_Site__c>> billAccIdSAsMap = new Map<String, List<EI_Site__c>> ();
            if (!billAccIdSet.isEmpty()) {
                billAccIdSAsMap = getValidSAsForBillingAccIds(billAccIdSet, validRSList);
                System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
                
                // Check if none of the Billing ACC IDs has at-least one valid SA (which is active and has valid Rate Schedule)
                if (billAccIdSAsMap.isEmpty()) {
                    badBillAccIdSet.addAll(billAccIdSet);
                } else {
                    // Iterate through all Billing ACC IDs and find if each has at-least one valid SA (which is active and has valid Rate Schedule)
                    for (String billAccId :billAccIdSet) {
                        if (!billAccIdSAsMap.containsKey(billAccId)) {
                            badBillAccIdSet.add(billAccId);
                        }
                    }
                }
                System.Debug('badBillAccIdSet = ' + badBillAccIdSet);
            }
            System.Debug('badBillAccIdSet = ' + badBillAccIdSet);
            
        } catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollmentProcessingController.apex', ex));
        }
        
        return badBillAccIdSet;
    }
    
    /**
* @Description: Static method for identifying duplicate Staging records
* @Parameter: Map<Id, CARE_APP_Staging__c>, String, Map<String, CARE_Type__c>, List<String>, boolean
* @Return: Map<Id, CARE_APP_Staging__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To find duplicate CARE_App_Staging records based on ACCT_ID__C
**/
    public static List<List<CARE_APP_Staging__c>> findDuplicateRecords(Map<Id, CARE_APP_Staging__c> stgMap, String enrollmentType, Map<String, CARE_Type__c> sourceChannelMap, List<String> validRSList, boolean isPEVArrivalNotice)
    {
        System.Debug('stgMap = ' + stgMap);
        System.Debug('enrollmentType = ' + enrollmentType);
        System.Debug('sourceChannelMap = ' + sourceChannelMap);
        System.Debug('validRSList = ' + validRSList);
        
        Set<String> perIdSet = new Set<String> ();
        
        // Collect PER ID from Staging records
        for (Id stgRecId :stgMap.KeySet()) {
            perIdSet.add(stgMap.get(stgRecId).PER_ID__c);
        }
        System.Debug('perIdSet = ' + perIdSet);
        
        Set<String> saActiveStatusSet = new Set<String> ();
        saActiveStatusSet.addAll(CARE_Constants.CARE_SA_ACTIVE_STATUSES);
        System.Debug('saActiveStatusSet = ' + saActiveStatusSet);
        
        // Fetch all Billing ACC IDs for the PER_ID that has at-least one SA which is active
        String query = 'SELECT Person_ID_EI__c, Billing_Account_ID_EI__c FROM EI_Site__c WHERE Person_ID_EI__c IN :perIdSet '
            + ' AND Account_EI__c != NULL AND Svc_Status_Code_EI__c IN :saActiveStatusSet ';
        if (validRSList != null && !validRSList.isEmpty()) {
            query += ' AND Rate_Schedule_EI__c IN :validRSList ';
        }
        query += ' ORDER BY CreatedDate DESC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        System.Debug('query = ' + query);
        
        // Create a Map with PER ID as KEY and all its Billing ACC IDs (having at-least one SA which is active & has valid Rate Schedule) as VALUE
        Map<String, Set<String>> perIdBillAccIdsMap = new Map<String, Set<String>> ();
        Map<String, String> billAccIdPerIdMap = new Map<String, String> ();
        Set<String> allBillAccIdSet = new Set<String> ();
        
        for (EI_Site__c SARec : Database.Query(query))
        {
            Set<String> billAccIdsSet = perIdBillAccIdsMap.get(SARec.Person_ID_EI__c);
            if (billAccIdsSet == null) {
                billAccIdsSet = new Set<String> ();
            }
            billAccIdsSet.add(SARec.Billing_Account_ID_EI__c);
            perIdBillAccIdsMap.put(SARec.Person_ID_EI__c, billAccIdsSet);
            
            billAccIdPerIdMap.put(SARec.Billing_Account_ID_EI__c, SARec.Person_ID_EI__c);
            
            allBillAccIdSet.add(SARec.Billing_Account_ID_EI__c);
            
        }
        System.Debug('perIdBillAccIdsMap = ' + perIdBillAccIdsMap);
        System.Debug('billAccIdPerIdMap = ' + billAccIdPerIdMap);
        System.Debug('allBillAccIdSet = ' + allBillAccIdSet);
        
        // Get all fields of CARE_APP_Staging object using dynamic apex
        query = 'SELECT ';
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_APP_Staging__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        String todayDate = String.valueOf(System.Today());
        
        Set<String> sourceChannelSet = new Set<String> ();
        sourceChannelSet.addAll(sourceChannelMap.KeySet());
        System.Debug('sourceChannelSet = ' + sourceChannelSet);
        
        // Get CARE_APP_Staging enrollment records for all Billing ACC IDs of all PER IDs identified
        query += ' FROM CARE_APP_Staging__c WHERE APPLICATION_TYPE__c = \'Residential\'' 
            // + ' AND ENROLLMENT_TYPE__c = \'ENROLLMENT\' AND '
            + ' AND ENROLLMENT_TYPE__c = :enrollmentType AND '
            + ' (ENROLLMENT_STATUS__c = \'Pending\' OR '
            + ' ( ENROLLMENT_STATUS__c = \'Completed\' AND PROCESSED_DATE__c = ' + todayDate + ') )'
            + ' AND SOURCE_CHANNEL_TYPE__c IN :sourceChannelSet AND ACCT_ID__c IN :allBillAccIdSet '
            + ' ORDER BY ENTRY_DATE_CARE1__c DESC';
        
        Map<String, Map<String, List<CARE_APP_Staging__c>>> perIdSourceChnStgRecsMap = new Map<String, Map<String, List<CARE_APP_Staging__c>>> ();
        Map<Id, CARE_APP_Staging__c> uniqueStgRecsMap = new Map<Id, CARE_APP_Staging__c> ();
        Map<Id, CARE_APP_Staging__c> duplicateStgRecsMap = new Map<Id, CARE_APP_Staging__c> ();
        Set<String> uniqueStgPerIdSet = new Set<String> ();
        Set<String> uniqueStgBillAccIdSet = new Set<String> ();
        System.Debug('query = ' + query);
        for (CARE_App_Staging__c stgRec : Database.Query(query))
        {
            // Check if at-least one SA (which is active and has valid Rate Schedule) is identified for this Billing ACC ID
            if (billAccIdPerIdMap.containsKey(stgRec.ACCT_ID__c)) {
                String perId = billAccIdPerIdMap.get(stgRec.ACCT_ID__c);
                String sourceChannel = stgRec.SOURCE_CHANNEL_TYPE__c;
                
                // Get all Staging records grouped by each Source Channel for this PER ID
                Map<String, List<CARE_APP_Staging__c>> sourceChannelStgRecsMap = perIdSourceChnStgRecsMap.get(perId);
                if (sourceChannelStgRecsMap == null) {
                    sourceChannelStgRecsMap = new Map<String, List<CARE_APP_Staging__c>> ();
                }
                
                // Get all Staging records for this Source Channel
                List<CARE_APP_Staging__c> stgRecsList = sourceChannelStgRecsMap.get(sourceChannel);
                if (stgRecsList == null) {
                    stgRecsList = new List<CARE_APP_Staging__c> ();
                }
                
                // Add current Staging record
                stgRecsList.add(stgRec);
                
                // Include updated Staging records list for this Source Channel
                sourceChannelStgRecsMap.put(sourceChannel, stgRecsList);
                
                // Include updated Staging records with Source Channel for this PER ID
                perIdSourceChnStgRecsMap.put(perId, sourceChannelStgRecsMap);
            }
            System.Debug('perIdSourceChnStgRecsMap = ' + perIdSourceChnStgRecsMap);
        }
        System.Debug('perIdSourceChnStgRecsMap = ' + perIdSourceChnStgRecsMap);
        
        // Iterate through all Staging records for each PER ID across all Source Channels to consider the Staging record for processing based on Source Channel priority or latest received
        for (String perId :perIdSourceChnStgRecsMap.KeySet()) {
            Map<String, List<CARE_APP_Staging__c>> sourceChannelStgRecsMap = perIdSourceChnStgRecsMap.get(perId);
            System.Debug('sourceChannelStgRecsMap = ' + sourceChannelStgRecsMap);
            
            if (sourceChannelStgRecsMap != null && !sourceChannelStgRecsMap.isEmpty()) {
                
                // Check if any Staging record for this PER ID is already processed today
                boolean isAnyStgRecProcessedToday = false;
                for (String sourceChannelType :sourceChannelStgRecsMap.KeySet()) {
                    for (CARE_APP_Staging__c stgRec :sourceChannelStgRecsMap.get(sourceChannelType)) {
                        if (stgRec.ENROLLMENT_STATUS__c == 'Completed') {
                            System.Debug('Already a Staging record is processed today for this customer !');
                            isAnyStgRecProcessedToday = true;
                            break;
                        }
                    }
                    if (isAnyStgRecProcessedToday == true) {
                        break;
                    }
                }
                
                if (isAnyStgRecProcessedToday == true) {
                    // Add all Staging records of this PER ID to update as Duplicate
                    for (String sourceChannelType :sourceChannelStgRecsMap.KeySet()) {
                        for (CARE_APP_Staging__c stgRec :sourceChannelStgRecsMap.get(sourceChannelType)) {
                            duplicateStgRecsMap.put(stgRec.Id, stgRec);
                        }
                    }
                    System.Debug('duplicateStgRecsMap = ' + duplicateStgRecsMap);
                    
                } else {
                    boolean isUniqueStgRecFoundForProcessing = false;
                    
                    // Iterate through Source Channel Priority Order and identify the only Staging record that need to be processed
                    for (String sourceChannelType :sourceChannelMap.KeySet()) {
                        System.Debug('sourceChannelType = ' + sourceChannelType);
                        System.Debug('isUniqueStgRecFoundForProcessing = ' + isUniqueStgRecFoundForProcessing);
                        
                        // Check if any Staging record is received from this Source Channel
                        if (sourceChannelStgRecsMap.containsKey(sourceChannelType)) {
                            // Get all Staging records of this Source Channel
                            List<CARE_APP_Staging__c> stgRecsList = sourceChannelStgRecsMap.get(sourceChannelType);
                            System.Debug('stgRecsList = ' + stgRecsList);
                            
                            System.Debug('isUniqueStgRecFoundForProcessing = ' + isUniqueStgRecFoundForProcessing);
                            
                            if (isUniqueStgRecFoundForProcessing == false) {
                                // Since Staging records are retrieved using SOQL by sorting on ENTRY_DATE_CARE1__c DESC which means the latest Staging record is the first record from the list for each Source Channel
                                // Consider the first Staging record that is received from this Source Channel
                                // Which means, the latest Staging record from the highest prioritized Source Channel will be considered for processing
                                // And rest of the Staging records from the same Source Channel and from all other lower priority Source Channels are considered as Duplicates
                                CARE_APP_Staging__c stgRecToConsiderForProcessing = sourceChannelStgRecsMap.get(sourceChannelType)[0];
                                uniqueStgRecsMap.put(stgRecToConsiderForProcessing.Id, stgRecToConsiderForProcessing);
                                // Collect Billing ACC ID of all Staging records that need to be processed
                                uniqueStgBillAccIdSet.add(stgRecToConsiderForProcessing.ACCT_ID__c);
                                isUniqueStgRecFoundForProcessing = true;
                                
                                // Consider all other Staging records from this Source Channel as Duplicates
                                if (stgRecsList.size() > 1) {
                                    for (Integer i=1; i < stgRecsList.size(); i++) {
                                        duplicateStgRecsMap.put(stgRecsList[i].Id, stgRecsList[i]);
                                    }
                                }
                            } else {
                                // Since a Staging record from higher Priority Source Channel is identified,
                                // Consider all Staging records from this Source Channel as Duplicates
                                for (Integer i=0; i < stgRecsList.size(); i++) {
                                    duplicateStgRecsMap.put(stgRecsList[i].Id, stgRecsList[i]);
                                }
                            }
                            
                            System.Debug('isUniqueStgRecFoundForProcessing = ' + isUniqueStgRecFoundForProcessing);
                        }
                    }
                    System.Debug('uniqueStgRecsMap = ' + uniqueStgRecsMap);
                    System.Debug('duplicateStgRecsMap = ' + duplicateStgRecsMap);
                }
            }
        }
        System.Debug('uniqueStgRecsMap = ' + uniqueStgRecsMap);
        System.Debug('uniqueStgBillAccIdSet = ' + uniqueStgBillAccIdSet);
        System.Debug('duplicateStgRecsMap = ' + duplicateStgRecsMap);
        
        Map<String, List<EI_Site__c>> billAccIdSAsMap = new Map<String, List<EI_Site__c>> ();
        // Fetch SAs using Billing ACC IDs (from the latest Staging records that may be from any Source Channel) and generate a Map with ACC ID as KEY and Map of SAs as VALUE
        if (uniqueStgBillAccIdSet != null && !uniqueStgBillAccIdSet.isEmpty()) {
            billAccIdSAsMap = getValidSAsForBillingAccIds(uniqueStgBillAccIdSet, validRSList);
        }
        System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
        
        // Update Customer Info from SA (EI_Site__c) onto Staging records
        // Need to perform this again since there could be Staging records from other Source Channels considered for processing
        if (!uniqueStgRecsMap.isEmpty() && !billAccIdSAsMap.isEmpty()) {
            uniqueStgRecsMap = changeCustInfoInStgRecsFromSAs(uniqueStgRecsMap, billAccIdSAsMap);
        }
        System.Debug('uniqueStgRecsMap = ' + uniqueStgRecsMap);
        System.Debug('duplicateStgRecsMap = ' + duplicateStgRecsMap);
        
        if (!isPEVArrivalNotice) {
            // Collect PER ID from all Unique Staging records (that need to be processed)
            for (Id stgRecId :uniqueStgRecsMap.KeySet()) {
                uniqueStgPerIdSet.add(uniqueStgRecsMap.get(stgRecId).PER_ID__c);
            }
            System.Debug('uniqueStgPerIdSet = ' + uniqueStgPerIdSet);
            
            // Identify Duplicates based on OPEN CARE_Application records for each PER ID
            Set<String> perIdHavingOpenCareAppsSet = getPerIdHavingOpenCAREApps(uniqueStgPerIdSet);
            System.Debug('perIdHavingOpenCareAppsSet = ' + perIdHavingOpenCareAppsSet);
            
            // Remove Staging records from uniqueStgRecsMap and include in duplicateStgRecsMap, if its corresponding PER ID is present in perIdHavingOpenCareAppsSet
            for (Id stgRecId :uniqueStgRecsMap.KeySet()) {
                if (perIdHavingOpenCareAppsSet.contains(uniqueStgRecsMap.get(stgRecId).PER_ID__c)) {
                    // Include this Staging record in duplicateStgRecsMap since it has OPEN CARE_Application record
                    duplicateStgRecsMap.put(stgRecId, uniqueStgRecsMap.get(stgRecId));
                    // Remove this Staging record from uniqueStgRecsMap since it has OPEN CARE_Application record
                    uniqueStgRecsMap.remove(stgRecId);
                }
            }
            System.Debug('uniqueStgRecsMap = ' + uniqueStgRecsMap);
            System.Debug('duplicateStgRecsMap = ' + duplicateStgRecsMap);
        }
        
        List<List<CARE_App_Staging__c>> dupAndUniqueStgList = new List<List<CARE_App_Staging__c>> ();
        // Add Duplicate records
        dupAndUniqueStgList.add(duplicateStgRecsMap.Values());
        // Add Unique records
        dupAndUniqueStgList.add(uniqueStgRecsMap.Values());
        System.Debug('dupAndUniqueStgList = ' + dupAndUniqueStgList);
        
        return dupAndUniqueStgList;
    }
    
    /**
* @Description: Static method to identify the correct Premise to be used for Full Qualification Logic for each Staging record
* @Parameter: Set<String>, Map<String, List<String>>, Map<String, List<EI_Site__c>>
* @Return: Map<String, String>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To identify the correct Premise to be used for Full Qualification Logic
**/
    public static Map<String, String> getPremiseForFullQualif(Set<String> billAccIdSet, Map<String, List<String>> billAccIdPremIdsMap, Map<String, List<EI_Site__c>> premIdWithValidSAsMap)
    {
        System.Debug('billAccIdSet = ' + billAccIdSet);
        System.Debug('billAccIdPremIdsMap = ' + billAccIdPremIdsMap);
        System.Debug('premIdWithValidSAsMap = ' + premIdWithValidSAsMap);
        
        Map<String, String> billAccIdPremIdMap = new Map<String, String> ();
        
        // Get Premises with valid SA having earliest CARE/FERA discount
        Map<String, EI_Site__c> premIdWithSAHavingEarliestDiscountMap = new Map<String, EI_Site__c> ();
        premIdWithSAHavingEarliestDiscountMap = getPremsWithSAHavingEarliestDiscount(premIdWithValidSAsMap);
        System.Debug('premIdWithSAHavingEarliestDiscountMap = ' + premIdWithSAHavingEarliestDiscountMap);
        
        // Iterate through all remaining Staging records and find if any of the Billing ACC IDs have single Premise with SAs (that are Active and have Valid Rate Schedule)
        for (String billAccId :billAccIdSet) {
            String premIdTobeConsidered = '';
            if (billAccIdPremIdsMap.containsKey(billAccId)) {
                List<String> premList = billAccIdPremIdsMap.get(billAccId);
                if (premList == null || premList.isEmpty()) {
                    premIdTobeConsidered = '';
                } else if (premList.size() == 1) {
                    premIdTobeConsidered = premList[0];
                } else {
                    // Since multiple Premises with Valid SAs are available, check if any of the Premises have SAs with CARE/FERA Discount
                    // If any of the Premises have SAs with CARE/FERA Discount, then identify the Premise with SA having earliest Discount Date
                    Date earliestDiscDate;
                    String premIdWithEarliestSADiscDate;
                    for (String premId :premList) {
                        if (premIdWithSAHavingEarliestDiscountMap.containsKey(premId)) {
                            if (earliestDiscDate == null) {
                                earliestDiscDate = premIdWithSAHavingEarliestDiscountMap.get(premId).Care_Start_Date_EI__c;
                                premIdWithEarliestSADiscDate = premId;
                            } else {
                                if (premIdWithSAHavingEarliestDiscountMap.get(premId).Care_Start_Date_EI__c < earliestDiscDate) {
                                    earliestDiscDate = premIdWithSAHavingEarliestDiscountMap.get(premId).Care_Start_Date_EI__c;
                                    premIdWithEarliestSADiscDate = premId;
                                }
                            }
                        }
                    }
                    
                    // Consider the Premise with Earliest Discount Date, if found.
                    if (String.isBlank(premIdTobeConsidered) && !String.isBlank(premIdWithEarliestSADiscDate)) {
                        premIdTobeConsidered = premIdWithEarliestSADiscDate;
                    } else {
                        // Find the Premise with valid SA that was created latest
                        DateTime latestCreatedDate;
                        String premIdWithLatestSACreatedDate;
                        for (String premId :premList) {
                            if (premIdWithValidSAsMap.containsKey(premId)) {
                                if (latestCreatedDate == null) {
                                    latestCreatedDate = premIdWithValidSAsMap.get(premId)[0].CreatedDate;
                                    premIdWithLatestSACreatedDate = premId;
                                } else {
                                    if (premIdWithValidSAsMap.get(premId)[0].CreatedDate > latestCreatedDate) {
                                        latestCreatedDate = premIdWithValidSAsMap.get(premId)[0].CreatedDate;
                                        premIdWithLatestSACreatedDate = premId;
                                    }
                                }
                            }
                        }
                        
                        // Consider the Premise with valid SA that was created latest
                        if (String.isBlank(premIdTobeConsidered) && !String.isBlank(premIdWithLatestSACreatedDate)) {
                            premIdTobeConsidered = premIdWithLatestSACreatedDate;
                        }
                    }
                }
            } else {
                premIdTobeConsidered = '';
            }
            System.Debug('premIdTobeConsidered = ' + premIdTobeConsidered);
            
            // Include identified Premise in billAccIdPremIdMap
            billAccIdPremIdMap.put(billAccId, premIdTobeConsidered);
        }
        System.Debug('billAccIdPremIdMap = ' + billAccIdPremIdMap);
        
        return billAccIdPremIdMap;
    }
    
    /**
* @Description: Static method for retrieving SAs for ACC IDs
* @Parameter: Set<Id>
* @Return: Map<String, List<EI_Site__c>>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To retrieve SAs based on ACC IDs
**/
    public static Map<String, List<EI_Site__c>> getValidSAsForBillingAccIds(Set<String> billAccIdSet, List<String> validRSList)
    {
        System.Debug('billAccIdSet = ' + billAccIdSet);
        System.Debug('validRSList = ' + validRSList);
        
        Map<String, List<EI_Site__c>> billAccIdSAsMap = new Map<String, List<EI_Site__c>> ();
        try{
            String query = 'SELECT ';
            
            // Get all fields using dynamic apex
            for (String fieldApiName :Schema.getGlobalDescribe().get('EI_Site__c').getDescribe().fields.getMap().KeySet()) {
                query += fieldApiName + ', ';
            }
            if (query.length() == 7) {
                query += ' Id';
            } else {
                query = query.subString(0, query.length()-2);
            }
            
            Set<String> saActiveStatusSet = new Set<String> ();
            saActiveStatusSet.addAll(CARE_Constants.CARE_SA_ACTIVE_STATUSES);
            query += ' FROM EI_Site__c WHERE Billing_Account_ID_EI__c IN :billAccIdSet AND Account_EI__c != NULL '
                // + ' AND Svc_Status_Code_EI__c IN :saActiveStatusSet AND Rate_Schedule_EI__c IN :validRSList '
                + ' AND Svc_Status_Code_EI__c IN :saActiveStatusSet ';
            if (validRSList != null && !validRSList.isEmpty()) {
                query += ' AND Rate_Schedule_EI__c IN :validRSList ';
            }
            query += ' ORDER BY CreatedDate DESC';
            if (Test.isRunningTest()) {
                query += ' LIMIT 10';
            }
            System.Debug('query = ' + query);
            for (EI_Site__c SARec : Database.Query(query))
            {
                List<EI_Site__c> SAsList = billAccIdSAsMap.get(SARec.Billing_Account_ID_EI__c);
                if (SAsList == null) {
                    SAsList = new List<EI_Site__c> ();
                }
                SAsList.add(SARec);
                System.Debug('SAsList = ' + SAsList);
                
                billAccIdSAsMap.put(SARec.Billing_Account_ID_EI__c, SAsList);
                System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
            }
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EnrollmentProcessingController.apex', ex));
        }
        return billAccIdSAsMap;
    }
    
    /**
* @Description: Static method for identifying BAD ACC IDs that are not 10 digits
* @Parameter: Map<String, List<EI_Site__c>>, List<String>
* @Return: Map<String, List<EI_Site__c>>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To filter out SAs that do not have valid CARE Rate Scheudle
**/
    public static Map<String, List<EI_Site__c>> removeInvalidSAs(Map<String, List<EI_Site__c>> billAccIdSAsMap, List<String> validRSList) {
        Set<String> validRSSet = new Set<String> ();
        validRSSet.addAll(validRSList);
        System.Debug('validRSSet = ' + validRSSet);
        
        // Remove SAs that are having invalid CARE Rate Schedule
        for (String billAccId :billAccIdSAsMap.KeySet()) {
            List<EI_Site__c> SAsList = billAccIdSAsMap.get(billAccId);
            if (SAsList != null && !SAsList.isEmpty()) {
                for (Integer i = 0; i<SAsList.size(); i++) {
                    if (!validRSSet.contains(SAsList[i].Rate_Schedule_EI__c)) {
                        // Since this SA's Rate Schedule is not related to CARE Rate Schedules, remove this SA from list
                        SAsList.remove(i);
                        i--;
                    }
                }
                
                // Update the Map with latest SAsList
                billAccIdSAsMap.put(billAccId, SAsList);
            }
        }
        
        System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
        
        return billAccIdSAsMap;
    }
    
/**
* @Description: Static method for identifying BAD ACC IDs that are not 10 digits
* @Parameter: Map<Id, CARE_APP_Staging__c>
* @Return: Map<Id, CARE_APP_Staging__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To filter out CARE_App_Staging records that have bad ACC IDs that are not 10 digits
**/
    public static void updateCustInfoOnAllEIAccs (List<CARE_Application__c> careAppList) {
        System.Debug('careAppList = ' + careAppList);
        
        Set<String> perIdSet = new Set<String> ();
        
        // Collect PER ID from Staging records
        for (CARE_Application__c careAppRec :careAppList) {
            perIdSet.add(careAppRec.PER_ID__c);
        }
        System.Debug('perIdSet = ' + perIdSet);
        
        // Get all EI_Accounts
        String query = 'SELECT ';
        
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        
        Set<String> saActiveStatusSet = new Set<String> ();
        saActiveStatusSet.addAll(CARE_Constants.CARE_SA_ACTIVE_STATUSES);
        query += ' FROM Account WHERE Billing_Person_ID_EI__c IN :perIdSet '
            + ' ORDER BY CreatedDate DESC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        System.Debug('query = ' + query);
        Map<String, List<Account>> perIdEIAccsMap = new Map<String, List<Account>> ();
        for (Account accRec :Database.Query(query))
        {
            List<Account> allAccsList = perIdEIAccsMap.get(accRec.Billing_Person_ID_EI__c);
            if (allAccsList == null) {
                allAccsList = new List<Account> ();
            }
            allAccsList.add(accRec);
            perIdEIAccsMap.put(accRec.Billing_Person_ID_EI__c, allAccsList);
        }
        System.Debug('perIdEIAccsMap = ' + perIdEIAccsMap);
        
        List<Account> updateAccList = new List<Account> ();
        
        // Iterate through each newly create CARE_Application and update details in all of its EI_Account records
        for (CARE_Application__c careAppRec :careAppList) {
            if (perIdEIAccsMap.containsKey(careAppRec.PER_ID__c)) {
                for (Account accRec :perIdEIAccsMap.get(careAppRec.PER_ID__c)) {
                    if (String.isNotBlank(careAppRec.EMAIL_ADDRESS__c)) {
                        accRec.Email_adr_EI__c = careAppRec.EMAIL_ADDRESS__c;
                    }
                    if (String.isNotBlank(careAppRec.Language_Preference__c)) {
                        accRec.PREFERRED_LANGUAGE__c = careAppRec.Language_Preference__c;
                        if (careAppRec.Language_Preference__c != 'English') {
                            accRec.Languages_Other_Than_English_EI__c = careAppRec.Language_Preference__c;
                        }
                    }
                    if (String.isNotBlank(careAppRec.CARE_Preferred_Method_of_Communication__c)) {
                        accRec.PREFERRED_CONTACT_METHOD__c = careAppRec.CARE_Preferred_Method_of_Communication__c;
                    }
                    if (String.isNotBlank(careAppRec.PHONE_NO__c)) {
                        accRec.Primary_Contact_Mobile_EI__c = careAppRec.PHONE_NO__c;
                    }
                    if (String.isNotBlank(careAppRec.CARE_Phone_Type__c)) {
                        accRec.PREFERRED_PHONE_TYPE__c = careAppRec.CARE_Phone_Type__c;
                    }
                    if (String.isNotBlank(careAppRec.CARE_Alternate_Phone_Number__c)) {
                        accRec.Add_Phone_EI__c = careAppRec.CARE_Alternate_Phone_Number__c;
                    }
                    if (String.isNotBlank(careAppRec.CARE_Alternate_Phone_Type__c)) {
                        accRec.ALTERNATIVE_PHONE_TYPE__c = careAppRec.CARE_Alternate_Phone_Type__c;
                    }
                    if (String.isNotBlank(careAppRec.HOME_PHONE_NO__c)) {
                        accRec.Bus_Phone_1_EI__c = careAppRec.HOME_PHONE_NO__c;
                    }
                    if (String.isNotBlank(careAppRec.WORK_PHONE_NO__c)) {
                        accRec.Bus_Phone_2_EI__c = careAppRec.WORK_PHONE_NO__c;
                    }
                    
                    updateAccList.add(accRec);
                }
            }
        }
        System.Debug('updateAccList = ' + updateAccList);
        
        // Update all EI_Account records
        if (!updateAccList.isEmpty()) {
            Database.SaveResult[] srList = Database.update(updateAccList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // This condition will be executed for successful records and will fetch the ids of successful records
                    System.debug('Successfully updated Account record. ID = ' + sr.getId());
                } else {
                    // This condition will be executed for failed records
                    for(Database.Error objErr : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        
                        // Printing error message in Debug log
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Account object field which are affected by the error:' + objErr.getFields());
                    }
                }
            }
        }
    }
    
    /**
* @Description: Static method to update Customer info from SA (EI_Site__c) onto Staging records
* @Parameter: Map<Id, CARE_APP_Staging__c>, Map<String, List<EI_Site__c>>
* @Return: Map<Id, CARE_APP_Staging__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To update Customer info from SA onto Staging record
**/
    public static Map<Id, CARE_APP_Staging__c> changeCustInfoInStgRecsFromSAs(Map<Id, CARE_APP_Staging__c> stgMap, Map<String, List<EI_Site__c>> billAccIdSAsMap)
    {
        System.Debug('stgMap = ' + stgMap);
        System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
        
        for (Id stgRecId :stgMap.KeySet()) {
            if (billAccIdSAsMap.containsKey(stgMap.get(stgRecId).ACCT_ID__c)) {
                // Update PER_ID
                System.Debug('billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Person_ID_EI__c = ' + billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Person_ID_EI__c);
                stgMap.get(stgRecId).PER_ID__c = billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Person_ID_EI__c;
                System.Debug('stgMap.get(stgRecId).PER_ID__c = ' + stgMap.get(stgRecId).PER_ID__c);
                
                // Update Customer Name
                System.Debug('billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Imported_Site_Name_EI__c = ' + billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Imported_Site_Name_EI__c);
                stgMap.get(stgRecId).APPLICANT_NAME__c = billAccIdSAsMap.get(stgMap.get(stgRecId).ACCT_ID__c)[0].Imported_Site_Name_EI__c;
                System.Debug('stgMap.get(stgRecId).APPLICANT_NAME__c = ' + stgMap.get(stgRecId).APPLICANT_NAME__c);
            }
        }
        return stgMap;
    }
    
    /**
* @Description: Static method for identifying bad Account IDs
* @Parameter: Map<Id, CARE_APP_Staging__c>, String, String, String
* @Return: Map<Id, CARE_APP_Staging__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To update CARE_App_Staging records with relevant status, error code, error message
**/
    public static Map<Id, CARE_APP_Staging__c> changeStageRecStatus(Map<Id, CARE_APP_Staging__c> stgMap, String enrStatus, String errCode, String errMsg)
    {
        System.Debug('stgMap = ' + stgMap);
        System.Debug('enrStatus = ' + enrStatus);
        System.Debug('errCode = ' + errCode);
        System.Debug('errMsg = ' + errMsg);
        
        // Update details in CARE_APP_Staging records
        for (Id stgRecId :stgMap.KeySet()) {
            stgMap.get(stgRecId).ENROLLMENT_STATUS__c = enrStatus;
            stgMap.get(stgRecId).ERROR_CODE__c = errCode;
            stgMap.get(stgRecId).ERROR_MESSAGE__c = errMsg;
            stgMap.get(stgRecId).PROCESSED_DATE__c = System.Today();
        }
        return stgMap;
    }
    
    /**
* @Description: Static method to get Source Channels and its Priority Preference Order
* @Parameter: none
* @Return: List<String>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To get Source Channels and its Priority preference order
**/
    public static Set<String> getPerIdHavingOpenCAREApps(Set<String> perIdSet)
    {
        System.Debug('perIdSet = ' + perIdSet);
        
        String query = 'SELECT ';
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_Application__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        Set<String> openStatusSet1 = new Set<String> ();
        openStatusSet1.addAll(CARE_Constants.CARE_STG_ENR_CARE_APP_OPEN_STATUSES);
        System.Debug('openStatusSet1 = ' + openStatusSet1);
        query += ' FROM CARE_Application__c WHERE PER_ID__c IN :perIdSet '
            + ' AND APPLICATION_STATUS__c IN :openStatusSet1';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        System.Debug('query = ' + query);
        Set<String> perIdFoundSet = new Set<String> ();
        
        // Collect PER ID for which OPEN CARE_Application records are found
        for (CARE_Application__c careAppRec :Database.Query(query))
        {
            System.Debug('CARE_Application.Id = ' + careAppRec.Id + ' :: ' + 'PER ID = ' + careAppRec.PER_ID__c + ' :: ' + 'Status = ' + careAppRec.Application_Status__c);
            perIdFoundSet.add(careAppRec.PER_ID__c);
        }
        System.Debug('perIdFoundSet = ' + perIdFoundSet);
        
        // Remove PER ID (for which OPEN CARE_Application records are found) from perIdSet
        perIdSet.removeAll(perIdFoundSet);
        
        // Find if any OPEN CARE_Application records are present in CARE_CC_Batch object
        if (!perIdSet.isEmpty()) {
            query = 'SELECT ';
            // Get all fields using dynamic apex
            for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_CC_Batch_Detail__c').getDescribe().fields.getMap().KeySet()) {
                query += fieldApiName + ', ';
            }
            
            if (query.length() == 7) {
                query += ' Id';
            } else {
                query = query.subString(0, query.length()-2);
            }
            String todayDate = String.valueOf(System.Today());
            Set<String> openStatusSet2 = new Set<String> ();
            openStatusSet2.addAll(CARE_Constants.CARE_STG_ENR_CARE_APP_OPEN_STATUS_FOR_TODAY);
            System.Debug('openStatusSet2 = ' + openStatusSet2);
            query += ' , APPLICATION__r.PER_ID__c FROM CARE_CC_Batch_Detail__c '
                + ' WHERE CARE_CC_Batch__c != null AND '
                + ' (CARE_CC_Batch__r.BATCH_STATUS_CODE__c = \'Completed\' OR CARE_CC_Batch__r.CC_SENT_DATE__c = ' + todayDate + ')'
                + ' AND APPLICATION__c != null AND APPLICATION__r.PER_ID__c IN :perIdSet '
                + ' AND APPLICATION__r.APPLICATION_STATUS__c IN :openStatusSet2 ';
            if (Test.isRunningTest()) {
                query += ' LIMIT 10';
            }
            System.Debug('query = ' + query);
            // Collect PER ID for which OPEN CARE_Application records are found in CARE_CC_Batch object
            for (CARE_CC_Batch_Detail__c careCcBatchDetRec :Database.Query(query))
            {
                if (careCcBatchDetRec.APPLICATION__c != null && String.isNotBlank(careCcBatchDetRec.APPLICATION__r.PER_ID__c)) {
                    // System.Debug('PER ID = ' + careCcBatchDetRec.APPLICATION__r.PER_ID__c + ' :: ' + 'Status = ' + careCcBatchDetRec.APPLICATION__r.Application_Status__c);
                    perIdFoundSet.add(careCcBatchDetRec.APPLICATION__r.PER_ID__c);
                }
            }
            System.Debug('perIdFoundSet = ' + perIdFoundSet);
        }
        System.Debug('perIdFoundSet = ' + perIdFoundSet);
        
        return perIdFoundSet;
    }
    
    /**
* @Description: Static method to get Source Channels and its Priority Preference Order related to PEV Arrival Notices
* @Parameter: none
* @Return: Map<String, CARE_Type__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To get Source Channels and its Priority preference order
**/
    public static Map<String, CARE_Type__c> getAutoPEVArrivalNoticeSourceChannels()
    {
        Map<String, CARE_Type__c> sourceChannelMap = new Map<String, CARE_Type__c> ();
        
        String query = 'SELECT ';
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_Type__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        String sourceChannelCategory = CARE_Constants.CARE_STG_PEV_ARRV_SOURCE_CHANNEL_CATEGORY;
        query += ' FROM CARE_TYPE__c WHERE CATEGORY__c = :sourceChannelCategory '
            + ' AND IS_ACTIVE__c = TRUE ORDER BY DISPLAY_ORDER__c ASC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        
        // Get Source Channels based on defined Priority Order
        for (CARE_Type__c careTypeRec : Database.Query(query)) 
        {
            sourceChannelMap.put(careTypeRec.TYPE_DESC__c, careTypeRec);
        }
        return sourceChannelMap;
    }
    
    /**
* @Description: Static method to get Source Channels and its Priority Preference Order
* @Parameter: none
* @Return: Map<String, CARE_Type__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To get Source Channels and its Priority preference order
**/
    public static Map<String, CARE_Type__c> getAutoEnrollSourceChannels()
    {
        Map<String, CARE_Type__c> sourceChannelMap = new Map<String, CARE_Type__c> ();
        
        String query = 'SELECT ';
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_Type__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        String sourceChannelCategory = CARE_Constants.CARE_STG_ENR_SOURCE_CHANNEL_CATEGORY;
        query += ' FROM CARE_TYPE__c WHERE CATEGORY__c = :sourceChannelCategory '
            + ' AND IS_ACTIVE__c = TRUE ORDER BY DISPLAY_ORDER__c ASC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        
        // Get Source Channels based on defined Priority Order
        for (CARE_Type__c careTypeRec : Database.Query(query)) 
        {
            sourceChannelMap.put(careTypeRec.TYPE_DESC__c, careTypeRec);
        }
        return sourceChannelMap;
    }
    
    /**
* @Description: Static method to get Language and Integer Mapping
* @Parameter: none
* @Return: Map<Integer, String>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To get Language and Integer Mapping
**/
    public static Map<Integer, String> getLanguageNumberMappings()
    {
        String query = 'SELECT ';
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_Type__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        String langSourceCategory = CARE_Constants.CARE_STG_ENR_LANGUAGE_SOURCE_CATEGORY;
        query += ' FROM CARE_TYPE__c WHERE CATEGORY__c = :langSourceCategory '
            + ' AND IS_ACTIVE__c = TRUE ORDER BY DISPLAY_ORDER__c ASC';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        
        Map<Integer, String> langNumMap = new Map<Integer, String> ();
        
        // Get Source Channels based on defined Priority Order
        for (CARE_Type__c careTypeRec : Database.Query(query)) 
        {
            langNumMap.put((Integer)careTypeRec.DISPLAY_ORDER__c, careTypeRec.TYPE_DESC__c);
        }
        return langNumMap;
    }
    
    /**
* @Description: Static method for generating a Map with ACC ID as KEY and Premise IDs as VALUE based on SAs
* @Parameter: Map<Id, List<EI_Site__c>>
* @Return: Map<Id, List<String>>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To  generate a Map with ACC ID as KEY and Premise IDs as VALUE based on SAs
**/
    public static Map<String, List<String>> getPremsForAccIds(Map<String, List<EI_Site__c>> billAccIdSAsMap)
    {
        System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
        
        Map<String, List<String>> billAccIdPremIdsMap = new Map<String, List<String>> ();
        for (String billAccId :billAccIdSAsMap.KeySet()) {
            List<String> premIdList = new List<String> ();
            for (EI_SIte__c SARec :billAccIdSAsMap.get(billAccId)) {
                // premIdList.add(SARec.EI_Premise__c);
                premIdList.add(SARec.Site_Premise_ID_EI__c);
            }
            billAccIdPremIdsMap.put(billAccId, premIdList);
        }
        return billAccIdPremIdsMap;
    }
    
    /**
* @Description: Static method for generating a Map with PREM ID as KEY and SAs as VALUE if atleast one of the SAs is Active and have valid Rate Schedule
* @Parameter: Map<Id, List<EI_Site__c>>
* @Return: Map<String, List<EI_Site__c>>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To  generate a Map with PREM ID as KEY and SAs as VALUE if atleast one of the SAs is Active and have valid Rate Schedule
**/
    public static Map<String, List<EI_Site__c>> getPremsWithValidSAs(Map<String, List<EI_Site__c>> billAccIdSAsMap)
    {
        System.Debug('billAccIdSAsMap = ' + billAccIdSAsMap);
        
        Map<String, List<EI_Site__c>> premIdWithValidSAsMap = new Map<String, List<EI_Site__c>> ();
        for (String billAccId :billAccIdSAsMap.KeySet()) {
            for (EI_Site__c SARec :billAccIdSAsMap.get(billAccId)) {
                // SAsMap = premIdWithValidSAsMap.get(SARec.EI_Premise__c);
                List<EI_SIte__c> SAsList = premIdWithValidSAsMap.get(SARec.Site_Premise_ID_EI__c);
                if (SAsList == null) {
                    SAsList = new List<EI_SIte__c> ();
                }
                SAsList.add(SARec);
                premIdWithValidSAsMap.put(SARec.Site_Premise_ID_EI__c, SAsList);
            }
        }
        
        return premIdWithValidSAsMap;
    }
    
    /**
* @Description: Static method for generating a Map with PREM ID as KEY and SAs as VALUE if atleast one of the SAs have Discount (CARE/FERA)
* @Parameter: Map<String, List<EI_Site__c>>
* @Return: Map<String, EI_Site__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To  generate a Map with PREM ID as KEY and SAs as VALUE if atleast one of the SAs have Discount (CARE/FERA)
**/
    public static Map<String, EI_Site__c> getPremsWithSAHavingEarliestDiscount(Map<String, List<EI_Site__c>> premsWithValidSAsMap)
    {
        System.Debug('premsWithValidSAsMap = ' + premsWithValidSAsMap);
        
        Map<String, EI_Site__c> premsWithSAHavingEarliestDiscountMap = new Map<String, EI_Site__c> ();
        for (String premId :premsWithValidSAsMap.KeySet()) {
            for (EI_SIte__c SARec :premsWithValidSAsMap.get(premId)) {
                // Check if SA has CARE/FERA discount
                if (SARec.Care_Start_Date_EI__c <= System.Today() && SARec.Care_Stop_Date_EI__c >= System.Today()) {
                    if (!premsWithSAHavingEarliestDiscountMap.containsKey(premId)) {
                        premsWithSAHavingEarliestDiscountMap.put(premId, SARec);
                    } else {
                        // Check if this SA's Discount Start Date is earlier to already identified SA
                        if (SARec.Care_Start_Date_EI__c < premsWithSAHavingEarliestDiscountMap.get(premId).Care_Start_Date_EI__c) {
                            premsWithSAHavingEarliestDiscountMap.put(premId, SARec);
                        }
                    }
                }
            }
        }
        System.Debug('premsWithSAHavingEarliestDiscountMap = ' + premsWithSAHavingEarliestDiscountMap);
        
        return premsWithSAHavingEarliestDiscountMap;
    }
    
    /**
* @Description: Static method for sending an email
* @Parameter: String
* @Return: List<String>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To send an email with details like Batch Job statistics
**/
    public static List<String> getEmailList(String str)
    {
        System.Debug('str = ' + str);
        
        List<String> emailAddrList = new List<String> ();
        String query = 'SELECT ';
        
        // Get all fields using dynamic apex
        for (String fieldApiName :Schema.getGlobalDescribe().get('CARE_System_Value__c').getDescribe().fields.getMap().KeySet()) {
            query += fieldApiName + ', ';
        }
        if (query.length() == 7) {
            query += ' Id';
        } else {
            query = query.subString(0, query.length()-2);
        }
        
        String autoEnrollEmailAddr = CARE_Constants.CARE_STG_ENR_EMAIL_ADDR;
        // query += ' FROM CARE_System_Value__c WHERE Name = :autoEnrollEmailAddr AND SYSTEM_VALUE_TYPE__c = \'EMAIL\' ';
        query += ' FROM CARE_System_Value__c WHERE SYSTEM_VALUE_CODE__c = 522 ';
        if (Test.isRunningTest()) {
            query += ' LIMIT 10';
        }
        System.Debug('query = ' + query);
        for (CARE_System_Value__c sysValRec : Database.Query(query)) 
        {
            if (String.isNotBlank(sysValRec.SYSTEM_VALUE__c)) {
                for (String emailAddr :sysValRec.SYSTEM_VALUE__c.split(';')) {
                    emailAddrList.add(emailAddr);
                }
            }
        }
        System.Debug('emailAddrList = ' + emailAddrList);
        
        return emailAddrList;
    }
    
    /**
* @Description: Static method for sending an email
* @Parameter: Integer, Integer, Integer, Integer, String, String, String, List<String>
* @Return: void
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To send an email with details like Batch Job statistics
**/
    public static void sendEmail(String classname, String subject, String emailBody, List<String> toEmailAddrList)
    {
        System.Debug('classname = ' + classname);
        System.Debug('subject = ' + subject);
        System.Debug('emailBody = ' + emailBody);
        System.Debug('toEmailAddrList = ' + toEmailAddrList);
        
        // Create an email message object and send email to the currently logged user!
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toEmailAddrList);
        mail.setSubject(subject);
        mail.setHTMLBody(emailBody);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /**
* @Description: Static method to get Record Types with Id as a Map
* @Parameter: String
* @Return: Map<String, Id>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To get Record Type Name with Id as a Map
**/
    public static Map<String, Id> getRecordTypeNameWithId (String objectAPIName) {
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfosByName();
        Map<String, Id> recTypeNameIdMap = new Map<String, Id> ();
        
        for (String recordTypeName :recordTypeInfoMap.KeySet()) {
            // System.Debug('Record Type Name = ' + recordTypeName);
            // System.Debug('Record Type Id = ' + recordTypeInfoMap.get(recordTypeName).getRecordTypeId());
            recTypeNameIdMap.put(recordTypeName, recordTypeInfoMap.get(recordTypeName).getRecordTypeId());
        }
        System.Debug('recTypeNameIdMap = ' + recTypeNameIdMap);
        
        return recTypeNameIdMap;
    }

/**
* @Description: Static method for creating CARE_Application records for Staging records where single Premise with SAs are identified for Full Qualification Logic
* @Parameter: Map<Id, CARE_APP_Staging__c>, Map<String, List<EI_Site__c>>
* @Return: Map<Id, CARE_Application__c>
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To create CARE_Application records for Staging records where single Premise with SAs are identified for Full Qualification Logic
**/
    public static Map<Id, CARE_Application__c> createCareAppRecsForCAREAppStgRecs(Map<Id, CARE_APP_Staging__c> stgRecsMap, Map<String, List<EI_Site__c>> premIdWithValidSAsMap)
    {
        System.Debug('stgRecsMap = ' + stgRecsMap);
        System.Debug('premIdWithValidSAsMap = ' + premIdWithValidSAsMap);
        
        // Get Record Types of CARE_APPLICATION__c object
        Map<String, Id> careAppRecTypeNameIdMap = new Map<String, Id> ();
        careAppRecTypeNameIdMap = getRecordTypeNameWithId('CARE_Application__c');
        System.Debug('careAppRecTypeNameIdMap = ' + careAppRecTypeNameIdMap);
        
        List<Id> stgIdList = new List<Id> ();
        Map<Id, CARE_Application__c> stgIdCareAppRecMap = new Map<Id, CARE_Application__c> ();
        Map<Integer, String> langNumMap = new Map<Integer, String> ();
        langNumMap = getLanguageNumberMappings();
        System.Debug('langNumMap = ' + langNumMap);
        
        for (Id stgRecId :stgRecsMap.KeySet()) {
            // Get Premise Id
            String premId = stgRecsMap.get(stgRecId).PREM_ID__c;
            
            // Get EI_Account Id from latest created SA for that Premise
            Id eiAccId;
            if (premIdWithValidSAsMap.containsKey(premId) != null && premIdWithValidSAsMap.get(premId) != null) {
                eiAccId = premIdWithValidSAsMap.get(premId)[0].Account_EI__c;
            }
            
            // Create CARE_Application record
            CARE_Application__c careAppRec = createCareAppRec(stgRecsMap.get(stgRecId), eiAccId, langNumMap, careAppRecTypeNameIdMap);
            
            stgIdCareAppRecMap.put(stgRecId, careAppRec);
            stgIdList.add(stgRecId);
        }
        System.Debug('stgIdCareAppRecMap = ' + stgIdCareAppRecMap);
        System.Debug('stgIdList = ' + stgIdList);
        
        if (stgIdCareAppRecMap != null && !stgIdCareAppRecMap.isEmpty()) {
            // Create CARE_Application records
            Database.SaveResult[] srList = Database.insert(stgIdCareAppRecMap.Values(), false);
            for (Integer i=0; i<srList.size(); i++) {
                if (srList[i].isSuccess()) {
                    // This condition will be executed for successful records and will fetch the ids of successful records
                    System.debug('Successfully created CARE_Application record. ID = ' + srList[i].getId());
                } else {
                    // This condition will be executed for failed records
                    for(Database.Error objErr : srList[i].getErrors()) {
                        System.debug('The following error has occurred.');
                        
                        // Printing error message in Debug log
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('CARE_Application object field which are affected by the error:' + objErr.getFields());
                        
                        // Remove the Staging record from stgIdCareAppRecMap
                        stgIdCareAppRecMap.remove(stgIdList[i]);
                    }
                }
            }
        }
        System.Debug('stgIdCareAppRecMap = ' + stgIdCareAppRecMap);
        System.Debug('stgIdList = ' + stgIdList);
        
        // Create CARE_APP_Image_List__c records
        List<CARE_APP_Image_List__c> careAppImgList = new List<CARE_APP_Image_List__c> ();
        Id careAppImgResRecTypeId = CARE_UtilityController.getCareAppImgListRecordTypeId(CARE_Constants.CARE_APP_IMG_RES_DEVELOPER_NAME);
        stgIdList.clear();
        for (Id stgRecId :stgIdCareAppRecMap.KeySet()) {
            if (String.isNotBlank(stgRecsMap.get(stgRecId).IMAGE_ID__c) && stgRecsMap.get(stgRecId).SOURCE_CHANNEL_TYPE__c == 'DataXport Enrollment') {
                CARE_APP_Image_List__c careAppImgRec = new CARE_APP_Image_List__c ();
                // Associate CARE_APP_Image_List record with CARE_Application record
                careAppImgRec.Application__c = stgIdCareAppRecMap.get(stgRecId).Id;
                careAppImgRec.IMAGE_ID__c = Integer.ValueOf(stgRecsMap.get(stgRecId).IMAGE_ID__c);
                if (stgRecsMap.get(stgRecId).SOURCE_CHANNEL_TYPE__c == 'DataXport Enrollment') {
                    careAppImgRec.IMAGE_TYPE__c = 'DATAXPORT';
                    careAppImgRec.SOURCE_SYSTEM__c = 'DATAXPORT';
                }
                careAppImgRec.RecordTypeId = careAppImgResRecTypeId;
                careAppImgList.add(careAppImgRec);
                stgIdList.add(stgRecId);
            }
        }
        
        if (!careAppImgList.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(careAppImgList, false);
            for (Integer i=0; i<srList.size(); i++) {
                if (srList[i].isSuccess()) {
                    // This condition will be executed for successful records and will fetch the ids of successful records
                    System.debug('Successfully created CARE_APP_Image_List record. ID = ' + srList[i].getId());
                } else {
                    // This condition will be executed for failed records
                    for(Database.Error objErr : srList[i].getErrors()) {
                        System.debug('The following error has occurred.');
                        
                        // Printing error message in Debug log
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('CARE_APP_Image_List object field which are affected by the error:' + objErr.getFields());
                        
                        // Remove the Staging record from stgIdCareAppRecMap
                        stgIdCareAppRecMap.remove(stgIdList[i]);
                    }
                }
            }
        }
        
        System.Debug('stgIdCareAppRecMap = ' + stgIdCareAppRecMap);
        return stgIdCareAppRecMap;
    }
    
    /**
* @Description: Static method for creating CARE_Application records for Staging records where single Premise with SAs are identified for Full Qualification Logic
* @Parameter: CARE_APP_Staging__c, Id
* @Return: CARE_Application__c
* @Usage:
Where it is called: Invoked in CARE_BatchEnrollmentDataXport
When it is called: To create CARE_Application record for a Staging record
**/
    public static CARE_Application__c createCareAppRec(CARE_APP_Staging__c stgRec, Id eiAccId, Map<Integer, String> langNumMap, Map<String, Id> careAppRecTypeNameIdMap)
    {
        System.Debug('stgRec = ' + stgRec);
        System.Debug('eiAccId = ' + eiAccId);
        System.Debug('langNumMap = ' + langNumMap);
        
        CARE_Application__c careAppRec = new CARE_Application__c ();
        
        Id userId = UserInfo.getUserId();            
        List<User> userDetails = new List<User>();
        userDetails = CARE_UtilityController.getUserDetails(userId);
        System.Debug('userDetails = ' + userDetails);
        
        if (String.isNotBlank(stgRec.APPLICATION_TYPE__c) && stgRec.APPLICATION_TYPE__c.toUpperCase() == 'RESIDENTIAL' && careAppRecTypeNameIdMap.containsKey('Residential Customer')) {
            careAppRec.RecordTypeId = careAppRecTypeNameIdMap.get('Residential Customer');
        }
        
        careAppRec.ACCT_ID__c = stgRec.ACCT_ID__c;
        careAppRec.PER_ID__c = stgRec.PER_ID__c;
        careAppRec.PREM_ID__c = stgRec.PREM_ID__c;
        careAppRec.APPLICANT_NAME__c = stgRec.APPLICANT_NAME__c;
        careAppRec.DOC_RECEIVED_DATE__c = stgRec.DOC_RECEIVED_DATE__c;
        careAppRec.ENROLLMENT_TYPE__c = stgRec.ENROLLMENT_TYPE__c;
        careAppRec.RECEIVED_DATE__c = ( (stgRec.DOC_RECEIVED_DATE__c != null) ? stgRec.DOC_RECEIVED_DATE__c : 
                                        ( (stgRec.SCANDATE__c != null) ? stgRec.SCANDATE__c : DATE.ValueOf(stgRec.CreatedDate) )
                                        );
        careAppRec.SOURCE_CHANNEL_TYPE__c = stgRec.SOURCE_CHANNEL_TYPE__c;
        
        if (stgRec.Source_Channel_Type__c == 'DataXport Enrollment') {
            careAppRec.APPLICATION_STATUS__c = 'Pending';
            
            careAppRec.REQUEST_DROP__c = ( (String.isNotBlank(stgRec.REQUEST_DROP__c) && stgRec.REQUEST_DROP__c.toUpperCase() == 'Y') ? true : false);
            if (String.isNotBlank(stgRec.EMAIL_ADDRESS__c)) {
                careAppRec.EMAIL_ADDRESS__c = stgRec.EMAIL_ADDRESS__c;
            }
            /*
            if (String.isNotBlank(stgRec.PHONE__c)) {
                careAppRec.PHONE_NO__c = stgRec.PHONE__c;
            }
            if (String.isNotBlank(stgRec.PHONE_TYPE__c)) {
                careAppRec.CARE_Phone_Type__c = stgRec.PHONE_TYPE__c;
            }
            */
            if (String.isNotBlank(stgRec.ALT_PHONE__c)) {
                careAppRec.CARE_Alternate_Phone_Number__c = stgRec.ALT_PHONE__c;
            }
            if (String.isNotBlank(stgRec.ALT_PHONE_TYPE__c)) {
                careAppRec.CARE_Alternate_Phone_Type__c = stgRec.ALT_PHONE_TYPE__c;
            }
            
            // Mobile Phone No
            if (stgRec.PHONE_TYPE__c == 'Mobile' && String.isNotBlank(stgRec.PHONE__c))
            {
                careAppRec.PHONE_NO__c = stgRec.PHONE__c;
                careAppRec.CARE_Phone_Type__c = 'Mobile';
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Mobile' && String.isNotBlank(stgRec.ALT_PHONE__c)) {
                careAppRec.PHONE_NO__c = stgRec.ALT_PHONE__c;
                careAppRec.CARE_Phone_Type__c = 'Mobile';
            }
            
            // Home Phone No
            if (stgRec.PHONE_TYPE__c == 'Home' && String.isNotBlank(stgRec.PHONE__c))
            {
                careAppRec.HOME_PHONE_NO__c = stgRec.PHONE__c;
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Home' && String.isNotBlank(stgRec.ALT_PHONE__c)) {
                careAppRec.HOME_PHONE_NO__c = stgRec.ALT_PHONE__c;
            }
            
            // Work Phone No
            if (stgRec.PHONE_TYPE__c == 'Work' && String.isNotBlank(stgRec.PHONE__c))
            {
                careAppRec.WORK_PHONE_NO__c = stgRec.PHONE__c;
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Work' && String.isNotBlank(stgRec.ALT_PHONE__c)) {
                careAppRec.WORK_PHONE_NO__c = stgRec.ALT_PHONE__c;
            }
            
            // Preferred Language
            if (String.isNotBlank(stgRec.LANGUAGE_PREFERENCE__c)) {
                careAppRec.Language_Preference__c = langNumMap.get(Integer.ValueOf(stgRec.LANGUAGE_PREFERENCE__c));
            }
            
            // Preferred Contact Method
            careAppRec.CARE_Preferred_Method_of_Communication__c = (
                (String.isNotBlank(stgRec.EMAIL_PREFERRED__c) && stgRec.EMAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                'Email' : 
                (
                    (String.isNotBlank(stgRec.MAIL_PREFERRED__c) && stgRec.MAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                    'Mail' : 
                    (
                        (String.isNotBlank(stgRec.PHONE_PREFERRED__c) && stgRec.PHONE_PREFERRED__c.toUpperCase() == 'Y') ?
                        'Phone' : 
                        (
                            (String.isNotBlank(stgRec.TEXT_PREFERRED__c) && stgRec.TEXT_PREFERRED__c.toUpperCase() == 'Y') ?
                            'Text' :
                            ''
                        )
                    )
                )
            );
            careAppRec.NO_ADULT__c = stgRec.NO_ADULT__c;
            careAppRec.NO_CHILD__c = stgRec.NO_CHILD__c;
            careAppRec.LIHEAP__c = ( (String.isNotBlank(stgRec.LIHEAP__c) && stgRec.LIHEAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.WIC__c = ( (String.isNotBlank(stgRec.WIC__c) && stgRec.WIC__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALFRESH_SNAP__c = ( (String.isNotBlank(stgRec.CALFRESH_SNAP__c) && stgRec.CALFRESH_SNAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALWORKS_TANF__c = ( (String.isNotBlank(stgRec.CALWORKS_TANF__c) && stgRec.CALWORKS_TANF__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEAD_START_INCOME__c = ( (String.isNotBlank(stgRec.HEAD_START_INCOME__c) && stgRec.HEAD_START_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.SSI__c = ( (String.isNotBlank(stgRec.SSI__c) && stgRec.SSI__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEALTHY_FAMILIES__c = ( (String.isNotBlank(stgRec.HEALTHY_FAMILIES__c) && stgRec.HEALTHY_FAMILIES__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.NSLP__c = ( (String.isNotBlank(stgRec.NSLP__c) && stgRec.NSLP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.BUREAU_INDIAN_AFFAIRS__c = ( (String.isNotBlank(stgRec.BUREAU_INDIAN_AFFAIRS__c) && stgRec.BUREAU_INDIAN_AFFAIRS__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_UNDER65__c = ( (String.isNotBlank(stgRec.MEDICAID_UNDER65__c) && stgRec.MEDICAID_UNDER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_OVER65__c = ( (String.isNotBlank(stgRec.MEDICAID_OVER65__c) && stgRec.MEDICAID_OVER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.FIXED_INCOME__c = ( (String.isNotBlank(stgRec.IS_FIXED_INCOME__c) && stgRec.IS_FIXED_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.ANNUAL_HOUSEHOLD_INCOME__c = stgRec.ANNUAL_INCOME__c;
            careAppRec.IS_SIGNED__c = ( (String.isNotBlank(stgRec.IS_SIGNED__c) && stgRec.IS_SIGNED__c == 'Y') ? true : false);
            // careAppRec.RECEIVED_DATE__c = stgRec.DOC_RECEIVED_DATE__c;
            careAppRec.APPCODE__c = stgRec.APPCODE__c;
            // careAppRec.IMAGE_ID__c = stgRec.IMAGE_ID__c;
            // Create CARE_APP_Image_List record with IMAGE_ID__c and IMAGE_TYPE__c = 'DataXport'
            careAppRec.APPLICATION_EXTERNAL_ID__c = stgRec.EXTERNAL_ID__c;
            careAppRec.APPLICATION_TYPE__c = 'Enrollment';
            careAppRec.NO_PAGE__c = stgRec.NO_PAGE__c;
            careAppRec.CARE_Account_ID__c = eiAccId;
            careAppRec.COC_CODE__c = stgRec.COC_CODE__c;
            careAppRec.IS_RECERT__c = ( (String.isNotBlank(stgRec.IS_RECERT__c) && stgRec.IS_RECERT__c == 'Y') ? true : false);
            // careAppRec.CARE_DISCOUNT_TYPE__c = stgRec.CC_CL_CD__c;
            
        } else if (stgRec.Source_Channel_Type__c == 'DataXport PEV Notice') {
            careAppRec.APPLICATION_EXTERNAL_ID__c = stgRec.EXTERNAL_ID__c;
            careAppRec.APPLICATION_STATUS__c = 'Completed';
            careAppRec.APPLICATION_TYPE__c = 'Notice';
            careAppRec.NO_PAGE__c = stgRec.NO_PAGE__c;
            careAppRec.CARE_Account_ID__c = eiAccId;
            careAppRec.PROCESSED_DATE__c = System.Today();
            if (userDetails != null && !userDetails.isEmpty()) {
                careAppRec.USER_NAME_CARE1__c = (String.isNotBlank(userDetails[0].LAN_ID_EI__c) ? userDetails[0].LAN_ID_EI__c : '');
            }
            careAppRec.RESULT_DATE__c = System.Today();
            
            
        } else if (stgRec.Source_Channel_Type__c == 'CARE Force.com') {
            careAppRec.APPLICATION_STATUS__c = 'Pending';
            
            // Preferred Language
            if (String.isNotBlank(stgRec.LANGUAGE_PREFERENCE__c)) {
                careAppRec.Language_Preference__c = langNumMap.get(Integer.ValueOf(stgRec.LANGUAGE_PREFERENCE__c));
            }
            
            // Preferred Contact Method
            careAppRec.CARE_Preferred_Method_of_Communication__c = (
                (String.isNotBlank(stgRec.EMAIL_PREFERRED__c) && stgRec.EMAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                'Email' : 
                (
                    (String.isNotBlank(stgRec.MAIL_PREFERRED__c) && stgRec.MAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                    'Mail' : 
                    (
                        (String.isNotBlank(stgRec.PHONE_PREFERRED__c) && stgRec.PHONE_PREFERRED__c.toUpperCase() == 'Y') ?
                        'Phone' : 
                        (
                            (String.isNotBlank(stgRec.TEXT_PREFERRED__c) && stgRec.TEXT_PREFERRED__c.toUpperCase() == 'Y') ?
                            'Text' :
                            ''
                        )
                    )
                )
            );
            careAppRec.NO_ADULT__c = stgRec.NO_ADULT__c;
            careAppRec.NO_CHILD__c = stgRec.NO_CHILD__c;
            careAppRec.LIHEAP__c = ( (String.isNotBlank(stgRec.LIHEAP__c) && stgRec.LIHEAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.WIC__c = ( (String.isNotBlank(stgRec.WIC__c) && stgRec.WIC__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALFRESH_SNAP__c = ( (String.isNotBlank(stgRec.CALFRESH_SNAP__c) && stgRec.CALFRESH_SNAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALWORKS_TANF__c = ( (String.isNotBlank(stgRec.CALWORKS_TANF__c) && stgRec.CALWORKS_TANF__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEAD_START_INCOME__c = ( (String.isNotBlank(stgRec.HEAD_START_INCOME__c) && stgRec.HEAD_START_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.SSI__c = ( (String.isNotBlank(stgRec.SSI__c) && stgRec.SSI__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEALTHY_FAMILIES__c = ( (String.isNotBlank(stgRec.HEALTHY_FAMILIES__c) && stgRec.HEALTHY_FAMILIES__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.NSLP__c = ( (String.isNotBlank(stgRec.NSLP__c) && stgRec.NSLP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.BUREAU_INDIAN_AFFAIRS__c = ( (String.isNotBlank(stgRec.BUREAU_INDIAN_AFFAIRS__c) && stgRec.BUREAU_INDIAN_AFFAIRS__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_UNDER65__c = ( (String.isNotBlank(stgRec.MEDICAID_UNDER65__c) && stgRec.MEDICAID_UNDER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_OVER65__c = ( (String.isNotBlank(stgRec.MEDICAID_OVER65__c) && stgRec.MEDICAID_OVER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.FIXED_INCOME__c = ( (String.isNotBlank(stgRec.IS_FIXED_INCOME__c) && stgRec.IS_FIXED_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.ANNUAL_HOUSEHOLD_INCOME__c = stgRec.ANNUAL_INCOME__c;
            careAppRec.IS_SIGNED__c = ( (String.isNotBlank(stgRec.IS_SIGNED__c) && stgRec.IS_SIGNED__c == 'Y') ? true : false);
            careAppRec.APPLICATION_EXTERNAL_ID__c = stgRec.EXTERNAL_ID__c;
            careAppRec.APPLICATION_TYPE__c = 'Enrollment';
            careAppRec.CARE_Account_ID__c = eiAccId;
            careAppRec.COC_CODE__c = stgRec.COC_CODE__c;
            
        } else if (stgRec.Source_Channel_Type__c == 'CARE SMS') {
            careAppRec.APPLICATION_STATUS__c = 'Pending';
            careAppRec.NO_ADULT__c = stgRec.NO_ADULT__c;
            careAppRec.NO_CHILD__c = stgRec.NO_CHILD__c;
            careAppRec.ANNUAL_HOUSEHOLD_INCOME__c = stgRec.ANNUAL_INCOME__c;
            careAppRec.IS_SIGNED__c = true;
            careAppRec.APPLICATION_EXTERNAL_ID__c = stgRec.EXTERNAL_ID__c;
            careAppRec.APPLICATION_TYPE__c = 'Enrollment';
            careAppRec.CARE_Account_ID__c = eiAccId;
            
        } else if (stgRec.Source_Channel_Type__c == 'Phone Enrollment') {
            careAppRec.APPLICATION_STATUS__c = 'Pending';
            careAppRec.CARE_ALTERNATE_PHONE_NUMBER__c = stgRec.ALT_PHONE__c;
            careAppRec.CARE_ALTERNATE_PHONE_TYPE__c = stgRec.ALT_PHONE_TYPE__c;
            if (stgRec.PHONE_TYPE__c == 'Mobile') {
                careAppRec.PHONE_NO__c = stgRec.PHONE__c;
                careAppRec.CARE_PHONE_TYPE__c = 'Mobile';
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Mobile' && careAppRec.PHONE_NO__c == null) {
                careAppRec.PHONE_NO__c = stgRec.ALT_PHONE__c;
                careAppRec.CARE_PHONE_TYPE__c = 'Mobile';
            }
            
            // Mobile Phone
            if (stgRec.MOBILE_PHONE__c != null && careAppRec.PHONE_NO__c == null) {
                careAppRec.PHONE_NO__c = stgRec.MOBILE_PHONE__c;
                careAppRec.CARE_PHONE_TYPE__c = 'Mobile';
            } else if (stgRec.MOBILE_ALT_PHONE__c != null && careAppRec.PHONE_NO__c == null) {
                careAppRec.PHONE_NO__c = stgRec.MOBILE_ALT_PHONE__c;
                careAppRec.CARE_PHONE_TYPE__c = 'Mobile';
            }
            
            // Home Phone
            if (stgRec.PHONE_TYPE__c == 'Home') {
                careAppRec.HOME_PHONE_NO__c = stgRec.PHONE__c;
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Home' && careAppRec.HOME_PHONE_NO__c == null) {
                careAppRec.HOME_PHONE_NO__c = stgRec.ALT_PHONE__c;
            }
            
            // Work Phone
            if (stgRec.PHONE_TYPE__c == 'Work') {
                careAppRec.WORK_PHONE_NO__c = stgRec.PHONE__c;
            } else if (stgRec.ALT_PHONE_TYPE__c == 'Work' && careAppRec.WORK_PHONE_NO__c == null) {
                careAppRec.WORK_PHONE_NO__c = stgRec.ALT_PHONE__c;
            }
            
            careAppRec.COC_CODE__c = stgRec.COC_CODE__c;
            careAppRec.COC_Status__c = stgRec.COC_Status__c;
            
            // Preferred Language
            if (String.isNotBlank(stgRec.LANGUAGE_PREFERENCE__c)) {
                careAppRec.Language_Preference__c = langNumMap.get(Integer.ValueOf(stgRec.LANGUAGE_PREFERENCE__c));
            }
            
            // Preferred Contact Method
            careAppRec.CARE_Preferred_Method_of_Communication__c = (
                (String.isNotBlank(stgRec.EMAIL_PREFERRED__c) && stgRec.EMAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                'Email' : 
                (
                    (String.isNotBlank(stgRec.MAIL_PREFERRED__c) && stgRec.MAIL_PREFERRED__c.toUpperCase() == 'Y') ?
                    'Mail' : 
                    (
                        (String.isNotBlank(stgRec.PHONE_PREFERRED__c) && stgRec.PHONE_PREFERRED__c.toUpperCase() == 'Y') ?
                        'Phone' : 
                        (
                            (String.isNotBlank(stgRec.TEXT_PREFERRED__c) && stgRec.TEXT_PREFERRED__c.toUpperCase() == 'Y') ?
                            'Text' :
                            ''
                        )
                    )
                )
            );
            careAppRec.REQUEST_DROP__c = ( (String.isNotBlank(stgRec.REQUEST_DROP__c) && stgRec.REQUEST_DROP__c.toUpperCase() == 'Y') ? true : false);
            if (String.isNotBlank(stgRec.EMAIL_ADDRESS__c)) {
                careAppRec.EMAIL_ADDRESS__c = stgRec.EMAIL_ADDRESS__c;
            }
            
            careAppRec.CCB_CONTACT_COMMENT__c = stgRec.CCB_CONTACT_COMMENT__c;
            careAppRec.NO_ADULT__c = stgRec.NO_ADULT__c;
            careAppRec.NO_CHILD__c = stgRec.NO_CHILD__c;
            careAppRec.LIHEAP__c = ( (String.isNotBlank(stgRec.LIHEAP__c) && stgRec.LIHEAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.WIC__c = ( (String.isNotBlank(stgRec.WIC__c) && stgRec.WIC__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALFRESH_SNAP__c = ( (String.isNotBlank(stgRec.CALFRESH_SNAP__c) && stgRec.CALFRESH_SNAP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.CALWORKS_TANF__c = ( (String.isNotBlank(stgRec.CALWORKS_TANF__c) && stgRec.CALWORKS_TANF__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEAD_START_INCOME__c = ( (String.isNotBlank(stgRec.HEAD_START_INCOME__c) && stgRec.HEAD_START_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.SSI__c = ( (String.isNotBlank(stgRec.SSI__c) && stgRec.SSI__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.HEALTHY_FAMILIES__c = ( (String.isNotBlank(stgRec.HEALTHY_FAMILIES__c) && stgRec.HEALTHY_FAMILIES__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.NSLP__c = ( (String.isNotBlank(stgRec.NSLP__c) && stgRec.NSLP__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.BUREAU_INDIAN_AFFAIRS__c = ( (String.isNotBlank(stgRec.BUREAU_INDIAN_AFFAIRS__c) && stgRec.BUREAU_INDIAN_AFFAIRS__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_UNDER65__c = ( (String.isNotBlank(stgRec.MEDICAID_UNDER65__c) && stgRec.MEDICAID_UNDER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.MEDICAID_OVER65__c = ( (String.isNotBlank(stgRec.MEDICAID_OVER65__c) && stgRec.MEDICAID_OVER65__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.FIXED_INCOME__c = ( (String.isNotBlank(stgRec.IS_FIXED_INCOME__c) && stgRec.IS_FIXED_INCOME__c.toUpperCase() == 'Y') ? true : false);
            careAppRec.ANNUAL_HOUSEHOLD_INCOME__c = stgRec.ANNUAL_INCOME__c;
            careAppRec.IS_SIGNED__c = ( (String.isNotBlank(stgRec.IS_SIGNED__c) && stgRec.IS_SIGNED__c == 'Y') ? true : false);
            careAppRec.APPLICATION_EXTERNAL_ID__c = stgRec.EXTERNAL_ID__c;
            careAppRec.APPLICATION_TYPE__c = 'Enrollment';
            careAppRec.CARE_Account_ID__c = eiAccId;
            careAppRec.COC_CODE__c = stgRec.COC_CODE__c;
            careAppRec.ENTRY_DATE_CARE1__c = stgRec.ENTRY_DATE_CARE1__c;
            careAppRec.USER_NAME_CARE1__c = stgRec.USER_NAME_CARE1__c;
        }
        
        return careAppRec;
    }
    
    /**
    * @Description: Static method to get the Email Subject for the batch job based on Source Channel
    * @Parameter: String
    * @Return: String
    * @Usage:
            Where it is called: Invoked in CARE_BatchEnrollmentDataXport
            When it is called: To get the email subject of a batch job based on Source Channel
    **/
    public static String getSourceChannelEmailSubject(String sourceChannelType)
    {
        String emailSubject = (sourceChannelType == 'DataXport Enrollment' ? '"CARE: Daily enrollment file from DX"' :
                                (sourceChannelType == 'CARE Force.com' ? '"CARE: Daily enrollments from PGE.com"' :
                                    (sourceChannelType == 'Phone Enrollment' ? '"CARE: Daily enrollments from IVR"' :
                                        (sourceChannelType == 'CARE SMS' ? '"CARE: Daily enrollment file from SMS"' :
                                            (sourceChannelType == 'CARE LIHEAP' ? '"CARE: Monthly enrollment file from LIHEAP"' :
                                                (sourceChannelType == 'CARE New Mover' ? '"CARE: Daily enrollment file from New Mover"' :
                                                    (sourceChannelType == 'CARE Auto Recertification' ? '"CARE: Monthly enrollment file from Auto Recertification"' : '')
                                                )
                                            )
                                        )
                                    )
                                )
                            );
        System.Debug('emailSubject = ' + emailSubject);
        
        return emailSubject;
    }
    
    /**
    * @Description: Static method to get the Email Subject for the batch job based on Source Channel
    * @Parameter: String
    * @Return: String
    * @Usage:
            Where it is called: Invoked in CARE_BatchEnrollmentDataXport
            When it is called: To get the email subject of a batch job based on Source Channel
    **/
    public static void checkAndRunBatchForSameSourceChannel(String sourceChannelType, Boolean executeOnlyThisBatchJob, Map<String, CARE_Type__c> sourceChannelMap)
    {
        if (!sourceChannelMap.containsKey(sourceChannelType)) {
            return;
        }
        
        // Get the Staging Object based on Source Channel
        String objAPIName = sourceChannelMap.get(sourceChannelType).TYPE_CODE__c;
        System.Debug('objAPIName = ' + objAPIName);
        
        String countQuery = 'SELECT COUNT() FROM ' + objAPIName;
        System.Debug('countQuery = ' + countQuery);
        
        // Include WHERE CLAUSE based on the object type to find the "Pending" records
        if (objAPIName.toUpperCase() == 'CARE_APP_STAGING__c') {
            countQuery += ' WHERE APPLICATION_TYPE__c = \'Residential\' AND ENROLLMENT_TYPE__C = \'ENROLLMENT\' AND '
                + 'ENROLLMENT_STATUS__C = \'Pending\' '
                + ' AND SOURCE_CHANNEL_TYPE__C = :sourceChannelType';
        }
        if (Test.isRunningTest()) {
            countQuery += ' LIMIT 10';
        }
        System.Debug('countQuery = ' + countQuery);
        
        Integer pendingStgRecsCount = Database.CountQuery(countQuery);
        System.Debug('pendingStgRecsCount = ' + pendingStgRecsCount);
        
        if (pendingStgRecsCount > 0) {
            // Execute the batch class based on the Staging Object
            if (objAPIName.toUpperCase() == 'CARE_APP_STAGING__c' && !Test.isRunningTest()) {
                Id batchJobId = Database.executeBatch(new CARE_BatchEnrollmentDataXport(sourceChannelType, executeOnlyThisBatchJob));
            }
        }
    }
    
    /**
    * @Description: Static method to get the Email Subject for the batch job based on Source Channel
    * @Parameter: String
    * @Return: String
    * @Usage:
            Where it is called: Invoked in CARE_BatchEnrollmentDataXport
            When it is called: To get the email subject of a batch job based on Source Channel
    **/
    public static void runBatchForNextSourceChannel(String sourceChannelType, Boolean executeOnlyThisBatchJob, Map<String, CARE_Type__c> sourceChannelMap)
    {
        System.Debug('sourceChannelType = ' + sourceChannelType);
        System.Debug('executeOnlyThisBatchJob = ' + executeOnlyThisBatchJob);
        System.Debug('sourceChannelMap = ' + sourceChannelMap);
        
        // Check if Batch Job for next Source Channel needs to be executed or not.
        // Means, whether current Batch Job was executed only for this Source Channel but not required to execute for other Source Channels
        if (executeOnlyThisBatchJob == false) {
            // Identify the next Source Channel from CARE_TYPE records, its base object (CARE_APP_Staging or CARE_BATCH_UPLOAD_DETAIL or any other) along with its corresponding Batch Apex Class and run the corresponding batch job.
            boolean isThisCurrentSourceChannelType = false;
            String nextSourceChannelType = '';
            for (String scType :sourceChannelMap.KeySet()) {
                System.Debug('scType = ' + scType);
                if (isThisCurrentSourceChannelType == true) {
                    nextSourceChannelType = scType;
                    break;
                }
                if (sourceChannelType == scType) {
                    isThisCurrentSourceChannelType = true;
                }
            }
            System.Debug('nextSourceChannelType = ' + nextSourceChannelType);
            if (String.isNotBlank(nextSourceChannelType) && sourceChannelMap.containsKey(nextSourceChannelType)) {
                System.Debug('Next Source Channel Object API Name = ' + sourceChannelMap.get(nextSourceChannelType).TYPE_CODE__c);
                System.Debug('Next Source Channel Batch Apex Class Name = ' + sourceChannelMap.get(nextSourceChannelType).TYPE_DESC_LONG__c);
            }
            
            if (String.isNotBlank(nextSourceChannelType) && sourceChannelMap.containsKey(nextSourceChannelType)) {
                // Execute the batch class based on the Staging Object
                if (sourceChannelMap.get(nextSourceChannelType).TYPE_CODE__c.toUpperCase() == 'CARE_APP_STAGING__C' && !Test.isRunningTest()) {
                    Id batchJobId = Database.executeBatch(new CARE_BatchEnrollmentDataXport(nextSourceChannelType));
                }
                /*
                else if (sourceChannelMap.get(nextSourceChannelType).TYPE_CODE__c.toUpperCase() == 'CARE_BATCH_STAGING__c' && !Test.isRunningTest()) {
                }
                */
            } else {
                if (!Test.isRunningTest()) {
                    // Since no other Source Channel is available next, run the 2nd batch job to processes newly created CARE_Application records
                    Id batchJobId = Database.executeBatch(new Care_VerifyEnrollmentBatch(), 1);
                }
            }
        } else {
            if (!Test.isRunningTest()) {
                // Since batch job is executed for this Source Channel alone, run the 2nd batch job to processes newly created CARE_Application records
                Id batchJobId = Database.executeBatch(new Care_VerifyEnrollmentBatch(), 1);
            }
        }
    }
    
    // This method is used to drop customer not enrolled in ESA after 45 days of H RAND CERT code stamping
    public static ESAThresholdCheckWrapper eSAFortyFiveDaysCheck(List<CARE_CC_Batch_Detail__c> listHRandCert){
        
        Boolean bRecordInsert = false;
        Boolean bThresholdCheck = false;
        Boolean bFortyFiveDayCheck = false;
        Date dTodaysDate = Date.today();
        //Date dFortyFiveDay = dTodaysDate.addDays(-45);
        Date dDateBeforeTenYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTenYears);
        Set<Id> careAppIdSet = new Set<Id>();
        Set<String> perIdSet = new Set<String>();
        //Set<Id> careAppIdFromCareEnrollSet = new Set<Id>();
        Set<Id> eSACompCareAppIdSet = new Set<Id>();
        Set<String> premIdSet = new Set<String>();
        Set<String> perIdSetESA = new Set<String>();
        Set<String> premIdSetFromPremise = new Set<String>();       
        //List<CARE_App_Enrolled_SA__c> careAppEnrollList = new List<CARE_App_Enrolled_SA__c>();
        List<EI_PREMISE__c> premiseList = new List<EI_PREMISE__c>();
        ESAThresholdCheckWrapper wrapperESAThreshold = new ESAThresholdCheckWrapper();
        
        
        try{
            system.debug('listHRandCert---->'+listHRandCert);
            if(listHRandCert.size() > 0){
                for(CARE_CC_Batch_Detail__c ccB : listHRandCert){
                    careAppIdSet.add(ccB.APPLICATION__c);
                    perIdSet.add(ccB.PER_ID__c);
                    premIdSet.add(ccB.CARE_APP_ENROLLED_SA__r.PREM_ID__c);
                }
                
                if(premIdSet.size() > 0){
                    premiseList = [select Name from EI_PREMISE__c where Name IN: premIdSet 
                                   AND (Last_ESA_Enrollment_Date__c >: dDateBeforeTenYears OR ESA_Last_Treated_EI__c >: dDateBeforeTenYears)];
                    for(EI_PREMISE__c prem : premiseList){
                        premIdSetFromPremise.add(prem.Name);
                    }
                }else{
                    premIdSetFromPremise = premIdSet;
                }
                system.debug('premIdSetFromPremise---->'+ premIdSetFromPremise);
                if(premIdSetFromPremise.size() > 0){
                    for(CARE_CC_Batch_Detail__c sEnroll : listHRandCert){
                        if(premIdSetFromPremise.contains(sEnroll.CARE_APP_ENROLLED_SA__r.PREM_ID__c)){
                            eSACompCareAppIdSet.add(sEnroll.APPLICATION__c); 
                            perIdSetESA.add(sEnroll.PER_ID__c);
                        }
                    }
                }else{
                    perIdSetESA = perIdSet;
                    eSACompCareAppIdSet = careAppIdSet;
                }
                
                system.debug('perIdSetESA--->'+perIdSetESA);
                system.debug('eSACompCareAppIdSet--->'+eSACompCareAppIdSet);
                if(eSACompCareAppIdSet.size() > 0){
                    wrapperESAThreshold = createEsaCompRecord(eSACompCareAppIdSet);
                    //wrapperESAThreshold = thresholdExceedCheckMethod(perIdSetESA, wrapperESAThreshold);
                }
                system.debug('wrapperESAThreshold----create ESA'+wrapperESAThreshold);
                //system.debug('wrapperESAThreshold----create Threshold'+wrapperESAThreshold);
                
            }
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());    
        }
        return wrapperESAThreshold;
    }
    
    //this method is used to create ESA COMP transaction for ESA enrolled records.
    public static ESAThresholdCheckWrapper createEsaCompRecord(Set<Id> careAppIdForEsaComp){
        
        system.debug('inside CreateEsaCompRecord method---->');
        //Boolean bIsRecordInsert = false;
        String sysAdminError = '';
        Date dTodaysDate = Date.today();
        Set<Id> newCareAppId = new Set<Id>();
        Set<Id> errorIdSetESA = new Set<Id>();
        Set<String> errorPerIdSetESA = new Set<String>();
        List<CARE_Application__c> careAppNewRecord = new List<CARE_Application__c>();
        List<CARE_App_Enrolled_SA__c> careEnrolledSAList = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_App_Enrolled_SA__c> careEnrolledSaListInsert = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_APP_Image_List__c> careAppImageList = new List<CARE_APP_Image_List__c>();
        List<CARE_APP_Image_List__c> careAppImageListInsert = new List<CARE_APP_Image_List__c>();
        List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        Id currentLoggedInUser = UserInfo.getUserId();
        ESAThresholdCheckWrapper eSAWrapper = new ESAThresholdCheckWrapper();
        Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
        
        try{
            //get the cc code details for Transfer Drop
            listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ESA_ENROLLED,null,null);
            
            if(careAppIdForEsaComp.size() > 0){
                list<CARE_Application__c> careAppList = [select IS_RECERT__c, NO_ADULT__c, APPLICANT_NAME__c, APPLICATION_STATUS__c,
                                                         NO_CHILD__c, IS_SIGNED__c, REQUEST_DROP__c, NEED_NAME_CHANGE__c, RECEIVED_DATE__c,
                                                         SOURCE_CHANNEL_TYPE__c, PROCESSED_DATE__c, FORM_CODE__c, COC_CODE__c, LIHEAP__c, 
                                                         MEDICAID_UNDER65__c, MEDICAID_OVER65__c, EMAIL_ADDRESS__c, ANNUAL_HOUSEHOLD_INCOME__c,
                                                         FIXED_INCOME__c, WIC__c, CALFRESH_SNAP__c, CALWORKS_TANF__c, HEAD_START_INCOME__c,
                                                         SSI__c, HEALTHY_FAMILIES__c, PROCESS_NOTES__c, NSLP__c, BUREAU_INDIAN_AFFAIRS__c,CCB_CONTACT_CODE__c,
                                                         CCB_CONTACT_DESC__c, CCB_CONTACT_COMMENT__c, PER_ID__c, ENROLLMENT_TYPE__c,
                                                         DROP_SOURCE__c, APPLICATION_TYPE__c, CARE_Account_ID__c,  CC_CL_CD__c
                                                         from CARE_Application__c where Id IN: careAppIdForEsaComp];
                
                system.debug('careAppList---->'+careAppList);
                for(CARE_Application__c careAppRecord : careAppList){
                    CARE_Application__c appCare = new CARE_Application__c();
                    appCare.RecordTypeId = careAppRecTypeId;
                    appCare.IS_RECERT__c = careAppRecord.IS_RECERT__c;
                    appCare.NO_ADULT__c = careAppRecord.NO_ADULT__c;
                    appCare.NO_CHILD__c = careAppRecord.NO_CHILD__c;
                    appCare.IS_SIGNED__c = careAppRecord.IS_SIGNED__c;
                    appCare.REQUEST_DROP__c = careAppRecord.REQUEST_DROP__c;
                    appCare.NEED_NAME_CHANGE__c = careAppRecord.NEED_NAME_CHANGE__c;
                    appCare.APPLICANT_NAME__c = careAppRecord.APPLICANT_NAME__c;
                    appCare.RECEIVED_DATE__c = careAppRecord.RECEIVED_DATE__c != null ? careAppRecord.RECEIVED_DATE__c : careAppRecord.PROCESSED_DATE__c;
                    appCare.PROCESSED_DATE__c = dTodaysDate; //careAppRecord[0].PROCESSED_DATE__c;
                    appCare.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                    appCare.FORM_CODE__c = careAppRecord.FORM_CODE__c;
                    appCare.COC_CODE__c = careAppRecord.COC_CODE__c;
                    appCare.APPLICATION_STATUS__c = CARE_Constants.CARE_DECISION_MADE;       
                    appCare.LIHEAP__c = careAppRecord.LIHEAP__c;
                    appCare.WIC__c = careAppRecord.WIC__c;
                    appCare.CALFRESH_SNAP__c = careAppRecord.CALFRESH_SNAP__c;
                    appCare.CALWORKS_TANF__c = careAppRecord.CALWORKS_TANF__c;
                    appCare.HEAD_START_INCOME__c = careAppRecord.HEAD_START_INCOME__c;
                    appCare.SSI__c = careAppRecord.SSI__c;
                    appCare.HEALTHY_FAMILIES__c = careAppRecord.HEALTHY_FAMILIES__c;
                    appCare.NSLP__c = careAppRecord.NSLP__c;
                    appCare.BUREAU_INDIAN_AFFAIRS__c = careAppRecord.BUREAU_INDIAN_AFFAIRS__c;
                    appCare.MEDICAID_UNDER65__c = careAppRecord.MEDICAID_UNDER65__c;
                    appCare.MEDICAID_OVER65__c = careAppRecord.MEDICAID_OVER65__c;
                    appCare.EMAIL_ADDRESS__c = careAppRecord.EMAIL_ADDRESS__c;
                    appCare.ANNUAL_HOUSEHOLD_INCOME__c = careAppRecord.ANNUAL_HOUSEHOLD_INCOME__c;
                    appCare.FIXED_INCOME__c = careAppRecord.FIXED_INCOME__c;
                    appCare.PER_ID__c = careAppRecord.PER_ID__c;
                    appCare.APPLICATION_TYPE__c = CARE_Constants.CARE_APPLICATION_TYPE;
                    appCare.CARE_Account_ID__c = careAppRecord.CARE_Account_ID__c;
                    appCare.PROCESS_NOTES__c = careAppRecord.PROCESS_NOTES__c;
                    appCare.ENROLLMENT_TYPE__c = careAppRecord.ENROLLMENT_TYPE__c != null ? careAppRecord.ENROLLMENT_TYPE__c : 'OTHER';                
                    appCare.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                    appCare.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                    appCare.CCB_CONTACT_COMMENT__c = careAppRecord.CCB_CONTACT_COMMENT__c;
                    appCare.CCB_Contact_Type_No__c = listCareTypeDesc[0].TYPE_NO__c;
                    appCare.DROP_SOURCE__c = careAppRecord.DROP_SOURCE__c != null ? careAppRecord.DROP_SOURCE__c : '';
                    //appCare.REASON_DESC__c = careAppRecord[0].REASON_DESC__c;
                    appCare.CC_CL_CD__c = careAppRecord.CC_CL_CD__c;
                    careAppNewRecord.add(appCare);
                }
            }
            system.debug('careAppNewRecord list Value: ' + careAppNewRecord);
            if(careAppNewRecord.size() > 0){
                Database.SaveResult[] srList = Database.insert(careAppNewRecord, false);
                for(Integer i =0; i < srList.size(); i++) {
                    if(srList.get(i).isSuccess()){
                        newCareAppId.add(srList.get(i).Id);
                    }
                    else if(!srList.get(i).isSuccess()){
                        Database.Error errors =  srList.get(i).getErrors().get(0);
                        errorIdSetESA.add(srList.get(i).Id);
                        errorPerIdSetESA.add(careAppNewRecord[i].PER_ID__c); 
                        sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                        
                    }
                }
            }
            
            if(!String.isBlank(sysAdminError)) {
                EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_ESAFortyFiveDayBatch', new EI_BatchException(sysAdminError)));
            }
            system.debug('newCareAppId set Value: ' + newCareAppId);
            system.debug('errorIdSetESA set Value: ' + errorIdSetESA);
            system.debug('errorPerIdSetESA set Value: ' + errorPerIdSetESA);
            //create care app enrolled sa records
            if(newCareAppId.size() > 0){
                careEnrolledSAList = [select Id, ACCT_ID__c, APPLICATION__c,RETRO_START_DATE__c, RETRO_END_DATE__c,
                                      CC_CL_CD__c, PER_ID__c, PREM_ID__c, SA_ID__c, START_DATE__c,END_DATE__c,  Service_Agreement__c,
                                      CCB_CONTACT_TYPE__c, RS_CD__c, SA_START_DATE__c, LAST_BILL_DATE__c, CSR_USER__c
                                      from CARE_App_Enrolled_SA__c where APPLICATION__r.Id IN: careAppIdForEsaComp]; 
                
                for(CARE_App_Enrolled_SA__c caEnroll : careEnrolledSAList){
                    for(Id careAppIds : newCareAppId){
                        CARE_App_Enrolled_SA__c careEnrollSa = new CARE_App_Enrolled_SA__c();
                        careEnrollSa.ACCT_ID__c = caEnroll.ACCT_ID__c;
                        careEnrollSa.CC_CL_CD__c = caEnroll.CC_CL_CD__c;
                        careEnrollSa.Service_Agreement__c = caEnroll.Service_Agreement__c;
                        careEnrollSa.RETRO_START_DATE__c = caEnroll.RETRO_START_DATE__c;
                        careEnrollSa.RETRO_END_DATE__c = caEnroll.RETRO_END_DATE__c;
                        careEnrollSa.PER_ID__c = caEnroll.PER_ID__c;
                        careEnrollSa.PREM_ID__c = caEnroll.PREM_ID__c;
                        careEnrollSa.SA_ID__c = caEnroll.SA_ID__c;
                        careEnrollSa.RS_CD__c = caEnroll.RS_CD__c;
                        careEnrollSa.START_DATE__c = caEnroll.START_DATE__c;
                        careEnrollSa.END_DATE__c =  caEnroll.END_DATE__c;
                        careEnrollSa.CCB_CONTACT_TYPE__c = listCareTypeDesc[0].TYPE_NO__c;
                        careEnrollSa.APPLICATION__c = careAppIds;
                        careEnrollSa.SA_START_DATE__c = caEnroll.SA_START_DATE__c;
                        //careEnrollSa.SA_END_DATE__c = caEnroll.SA_END_DATE__c;
                        careEnrollSa.LAST_BILL_DATE__c = caEnroll.LAST_BILL_DATE__c;
                        careEnrollSa.CSR_USER__c = currentLoggedInUser;
                        careEnrolledSaListInsert.add(careEnrollSa);
                    } 
                }
            }
            Database.SaveResult[] srListAppEnroll = Database.insert(careEnrolledSaListInsert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srListAppEnroll) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted careAppEnrolledSA records--->: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors               
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('care App Enrolled fields that affected this error: ' + err.getFields());
                    }
                }            
            }
            
            eSAWrapper.setESACareAppId = newCareAppId;
            eSAWrapper.setESAErrorId = errorIdSetESA;
            eSAWrapper.setErrorPerId = errorPerIdSetESA;
            
            system.debug('eSAWrapper.setESACareAppId--->'+eSAWrapper.setESACareAppId);
            system.debug('eSAWrapper--->'+eSAWrapper);
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return eSAWrapper;
    }
    
    //this method is used to create ESA COMP transaction for ESA enrolled records.
    //public static ESAThresholdCheckWrapper thresholdExceedCheckMethod(Set<String> perIdSetESA, ESAThresholdCheckWrapper wrapperESAThreshold){
    public static ESAThresholdCheckWrapper thresholdExceedCheckMethod(List<CARE_CC_Batch_Detail__c> esaThresholdCheckList){
        
        //Boolean bThresholdCheck = false;
        String sysAdminError = '';
        Date dTodaysDate = Date.today();
        //Date dFortyFiveDay = dTodaysDate.addDays(-45);
        Date dDateBeforeTwoYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTwoYears);
        Set<String> setOfPerId = new Set<String>();
        Set<Id> setId = new Set<Id>();
        Set<Id> setThresholdErrorId = new Set<Id>();
        Set<String> setThresholdErrorPerId = new Set<String>();
        Set<String> setPerIdForThreshold = new Set<String>();
        Set<String> setPerIdToDrop = new Set<String>();
        List<CARE_CC_Batch_Detail__c> listCCCodeSeven = new List<CARE_CC_Batch_Detail__c>();
        List<EI_SA_Char__c> listEIChar = new List<EI_SA_Char__c>();
        List<EI_Site__c> customerDropListESA = new List<EI_Site__c>();
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<CARE_Application__c> careAppListOfRec = new List<CARE_Application__c>();
        List<CARE_App_Enrolled_SA__c> careAppEnrollSAList = new List<CARE_App_Enrolled_SA__c>();
        List<CARE_CC_Batch_Detail__c> listEsaCompRec = new List<CARE_CC_Batch_Detail__c>();
        List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        ESAThresholdCheckWrapper wrapperThreshold = new ESAThresholdCheckWrapper();
        
        try{           
            //get the cc code details for Transfer Drop
            listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_HU_DROP,null,null);
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            system.debug('esaThresholdCheckList---->'+esaThresholdCheckList);
            if(esaThresholdCheckList.size() > 0){
                for(CARE_CC_Batch_Detail__c careCC : esaThresholdCheckList){
                    setOfPerId.add(careCC.PER_ID__c);
                }
                system.debug('setOfPerId---->'+setOfPerId);
                
                if(setOfPerId.size() > 0){
                    listCCCodeSeven = [select APPLICATION__c, PER_ID__c, CARE_CI_CC__r.CC_DTTM__c from CARE_CC_Batch_Detail__c
                                       where ((CARE_CI_CC__r.CC_TYPE_CD__c = '7' AND CCB_Contact_Type_No__c = '6036') OR (CARE_CI_CC__r.CC_TYPE_CD__c = '7' AND CCB_Contact_Type_No__c = '6041')) 
                                       AND PER_ID__c IN: setOfPerId ORDER by CARE_CI_CC__r.CC_DTTM__c DESC];
                    
                }/*else{
                    setPerIdForThreshold = setOfPerId;
                }*/
                system.debug('listCCCodeSeven--->'+listCCCodeSeven);
                
                if(esaThresholdCheckList.size() > 0 && listCCCodeSeven.size() > 0){
                    for(CARE_CC_Batch_Detail__c eSACompRecord : esaThresholdCheckList){
                        setPerIdForThreshold.add(eSACompRecord.PER_ID__c);
                        for(CARE_CC_Batch_Detail__c careCCB : listCCCodeSeven){
                            if(eSACompRecord.PER_ID__c == careCCB.PER_ID__c){
                            Date dEsaCompPlusTwoYear = eSACompRecord.CARE_CI_CC__r.CC_DTTM__c.addYears(+2);
                            System.debug('dEsaCompPlusTwoYear---> '+dEsaCompPlusTwoYear);
                            System.debug('careDate---> '+careCCB.CARE_CI_CC__r.CC_DTTM__c);
                            if(dEsaCompPlusTwoYear > careCCB.CARE_CI_CC__r.CC_DTTM__c){ // && eSACompRecord.CARE_CI_CC__r.CC_DTTM__c < careCCB.CARE_CI_CC__r.CC_DTTM__c){
                                setPerIdForThreshold.remove(eSACompRecord.PER_ID__c); 
                            }
                          }
                        }
                    }
                } else{
                    setPerIdForThreshold = setOfPerId;
                }
                system.debug('setPerIdForThreshold---->'+setPerIdForThreshold);
                if(setPerIdForThreshold.size() > 0){
                    listEIChar = [select Id, SA_ID__c, SERVICE_AGREEMENT__r.Person_ID_EI__c from EI_SA_Char__c
                                  where CHAR_TYPE_CD__c = 'CARE-USG' AND CHAR_VAL__c = 'GT-600'
                                  AND SERVICE_AGREEMENT__r.Person_ID_EI__c IN: setPerIdForThreshold]; 
                    for(EI_SA_Char__c sAChar : listEIChar){
                        setPerIdToDrop.add(sAChar.SERVICE_AGREEMENT__r.Person_ID_EI__c);  
                    }
                }else{
                    setPerIdToDrop = setPerIdForThreshold;
                }
                system.debug('setPerIdToDrop---->'+setPerIdToDrop);
                
                if(setPerIdToDrop.size() > 0){
                    customerDropListESA = [select Id, Person_ID_EI__c, Account_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Rate_Schedule_EI__c,
                                           Site_Premise_ID_EI__c, SAID_EI__c, Imported_Site_Name_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dTodaysDate
                                           AND Person_ID_EI__c IN: setPerIdToDrop];
                }
                system.debug('customerDropListESA---->'+customerDropListESA);
                if(customerDropListESA.size() > 0){
                    for(EI_Site__c objSite : customerDropListESA){
                        CARE_Application__c careApp = new CARE_Application__c();
                        careApp.RecordTypeId = careAppRecTypeId;
                        careApp.APPLICANT_NAME__c = objSite.Imported_Site_Name_EI__c;
                        careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_STAGED_CCB;
                        careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT_OTHER;
                        careApp.RECEIVED_DATE__c = dTodaysDate; //DATE__c : careAppRecord.PROCESSED_DATE__c;
                        careApp.PROCESSED_DATE__c = dTodaysDate; //careAppRecord[0].PROCESSED_DATE__c;
                        careApp.PER_ID__c = objSite.Person_ID_EI__c;
                        careApp.CARE_Account_ID__c = objSite.Account_EI__c;
                        careApp.CC_CL_CD__c = objSite.Account_EI__r.CARE_DISCOUNT_TYPE__c;
                        careApp.ACCT_ID__c = objSite.Billing_Account_ID_EI__c;
                        careApp.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                        careApp.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                        careApp.CCB_Contact_Type_No__c = listCareTypeDesc[0].TYPE_NO__c;
                        careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                        careAppList.add(careApp);
                    } 
                }
                system.debug('careAppList--->'+careAppList);
                
                if(careAppList.size() > 0){
                    Database.SaveResult[] srList = Database.insert(careAppList, false);
                    
                    for(Integer i =0; i < srList.size(); i++) {
                        if(srList.get(i).isSuccess()){
                            setId.add(srList.get(i).Id);
                            System.debug('setId---> '+srList.get(i).id);
                        }
                        else if(!srList.get(i).isSuccess()){
                            Database.Error errors =  srList.get(i).getErrors().get(0);
                            setThresholdErrorId.add(srList.get(i).Id);
                            setThresholdErrorPerId.add(careAppList[i].PER_ID__c); 
                            sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                            
                        }
                    }
                }
                if(!String.isBlank(sysAdminError)) {
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_ESAFortyFiveDayBatch', new EI_BatchException(sysAdminError)));
                }
                system.debug('setId--->'+setId);
                system.debug('setThresholdErrorId--->'+setThresholdErrorId);
                system.debug('setThresholdErrorPerId--->'+setThresholdErrorPerId);
                
                if(setId.size() > 0){
                    careAppListOfRec = [Select Id, PER_ID__c from CARE_Application__c where Id IN: setId AND CCB_Contact_Type_No__c =: listCareTypeDesc[0].TYPE_NO__c];
                }
                system.debug('careAppListOfRec---->'+careAppListOfRec);
                
                if(careAppListOfRec.size() > 0){
                    for(EI_Site__c objSA : customerDropListESA){
                        for(CARE_Application__c careObj : careAppListOfRec){
                            if(objSA.Person_ID_EI__c == careObj.PER_ID__c){
                                CARE_App_Enrolled_SA__c careAppEnroll = new CARE_App_Enrolled_SA__c();
                                careAppEnroll.ACCT_ID__c =  objSA.Billing_Account_ID_EI__c;
                                careAppEnroll.APPLICATION__c =  careObj.Id;
                                careAppEnroll.CC_CL_CD__c =  objSA.Account_EI__r.CARE_DISCOUNT_TYPE__c;//remove hardcode and bring from account object
                                careAppEnroll.PER_ID__c =  careObj.PER_ID__c;
                                careAppEnroll.PREM_ID__c =  objSA.Site_Premise_ID_EI__c;
                                careAppEnroll.RS_CD__c =  objSA.Rate_Schedule_EI__c;
                                careAppEnroll.SA_ID__c =  objSA.SAID_EI__c;
                                careAppEnroll.CCB_CONTACT_TYPE__c =  listCareTypeDesc[0].TYPE_NO__c;
                                careAppEnroll.END_DATE__c = dTodaysDate;
                                careAppEnroll.Service_Agreement__c = objSA.Id;
                                careAppEnrollSAList.add(careAppEnroll);
                            } 
                        } 
                    }
                } 
                
                Database.SaveResult[] srL = Database.insert(careAppEnrollSAList, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srL) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted careAppEnroll--->: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors               
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('CAre Application fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            wrapperThreshold.setThresholdAppId = setId;
            wrapperThreshold.setThresholdErrId = setThresholdErrorId;
            wrapperThreshold.setThresholdErrPerId = setThresholdErrorPerId;
            
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        
        return wrapperThreshold;
    }
    
    //this method is used to drop records not enrolled in ESA after 45 days.
    public static ESAThresholdCheckWrapper notEnrolledESADropCustomers(List<CARE_CC_Batch_Detail__c> listHRandCert){
        
        system.debug('inside NotEnrolledESADropCustomers method----->');
        Boolean bCheckFortyFiveDays = false;
        //Boolean bThresholdCheck = false;
        String sysAdminError = '';
        Set<String> remPerIdSet = new Set<String>();
        Date dTodaysDate = Date.today();
        //Date dFortyFiveDay = dTodaysDate.addDays(-45);
        //Date dDaysBeforeTwoYears = dFortyFiveDay.addDays(-CARE_Constants.CARE_BeforeTwoYearsInDays);
        Date dDateBeforeTenYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTenYears);
        Set<String> premIdSet = new Set<String>();
        Set<String> dropPremIdSet = new Set<String>();
        Set<String> perIdSetESADrop = new Set<String>();
        Set<Id> careAppIdFromCareEnrollSet = new Set<Id>();
        //Set<Id> remcareAppId = new Set<Id>();
        Set<Id> setId = new Set<Id>();
        Set<Id> setErrorIdNotEsa = new Set<Id>();
        Set<String> setErrorPerIdNotEsa = new Set<String>();
        //List<CARE_App_Enrolled_SA__c> ListcareAppEnroll = new List<CARE_App_Enrolled_SA__c>();
        List<EI_PREMISE__c> premiseList = new List<EI_PREMISE__c>();
        List<EI_Site__c> DropListESA = new List<EI_Site__c>();
        List<CARE_Application__c> careAppList = new List<CARE_Application__c>();
        List<CARE_Application__c> careAppListOfRec = new List<CARE_Application__c>();
        List<CARE_App_Enrolled_SA__c> careAppEnrollSAList = new List<CARE_App_Enrolled_SA__c>();
        List<EI_PREMISE__c> enrolledESAPremList = new List<EI_PREMISE__c>();
        Set<String> enrolledESAPremiseList = new Set<String>();
        List<CARE_Type__c> listCareTypeDesc = new List<CARE_Type__c>();
        ESAThresholdCheckWrapper wrapperESAThreshold = new ESAThresholdCheckWrapper();
        
        try{ 
            system.debug('listHRandCert inside AutoUtility---->'+listHRandCert);
            //get the cc code details for Transfer Drop
            listCareTypeDesc = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_ESA_EXPIRE,null,null);
            Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            if(listHRandCert.size() > 0){                
                //call method for point 3 ESASixEightyFiveDaysCheck.pass list listHRandCert
                wrapperESAThreshold = CARE_AutoUtilityController.eSASixEightyFiveDaysCheck(listHRandCert);
                system.debug('returned from eSASixEightyFiveDaysCheck method---->');
                for(CARE_CC_Batch_Detail__c batchDetail : listHRandCert){
                    //remcareAppId.add(batchDetail.APPLICATION__c);  
                    remPerIdSet.add(batchDetail.PER_ID__c);
                    premIdSet.add(batchDetail.CARE_APP_ENROLLED_SA__r.PREM_ID__c);   
                }
                system.debug('premIdSet---->'+premIdSet);
                system.debug('remPerIdSet---->'+remPerIdSet);
                
                if(premIdSet.size() > 0){
                    
                    enrolledESAPremList = [select Name from EI_PREMISE__c where Name IN: premIdSet 
                                           AND (Last_ESA_Enrollment_Date__c >: dDateBeforeTenYears OR ESA_Last_Treated_EI__c >: dDateBeforeTenYears)];
                    
                    for(EI_PREMISE__c premRecord : enrolledESAPremList){
                        enrolledESAPremiseList.add(premRecord.Name);
                    }
                    
                    //AND (Last_ESA_Enrollment_Date__c <: dDateBeforeTenYears OR ESA_Last_Treated_EI__c <: dDateBeforeTenYears)];
                }else{
                    enrolledESAPremiseList = premIdSet;
                }
                
                if(enrolledESAPremiseList.size() > 0){
                    premiseList = [select Name, ESA_Installation_Exception__c from EI_PREMISE__c where Name IN: premIdSet AND Name NOT IN: enrolledESAPremiseList]; 
                    for(EI_PREMISE__c prem : premiseList){
                        if(prem.ESA_Installation_Exception__c == null){
                            dropPremIdSet.add(prem.Name);
                        }else{
                            dropPremIdSet = enrolledESAPremiseList;
                        }           
                    }
                }else{
                    dropPremIdSet = enrolledESAPremiseList; 
                }
                
                if(dropPremIdSet.size() > 0){
                    for(CARE_CC_Batch_Detail__c sEnroll : listHRandCert){
                        if(dropPremIdSet.contains(sEnroll.CARE_APP_ENROLLED_SA__r.PREM_ID__c)){ 
                            perIdSetESADrop.add(sEnroll.PER_ID__c);
                        }else{
                            perIdSetESADrop = remPerIdSet;
                        }
                    }
                }else{
                    perIdSetESADrop = remPerIdSet;
                }
                
                if(perIdSetESADrop.size() > 0){
                    DropListESA = [select Id, Person_ID_EI__c, Account_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Rate_Schedule_EI__c,
                                   Site_Premise_ID_EI__c, SAID_EI__c, Imported_Site_Name_EI__c from EI_Site__c where Care_Stop_Date_EI__c >: dTodaysDate
                                   AND Person_ID_EI__c IN: perIdSetESADrop];
                }
                
                if(DropListESA.size() > 0){
                    for(EI_Site__c objSite : DropListESA){
                        CARE_Application__c careApp = new CARE_Application__c();
                        careApp.RecordTypeId = careAppRecTypeId;
                        careApp.APPLICANT_NAME__c = objSite.Imported_Site_Name_EI__c;
                        careApp.APPLICATION_STATUS__c = CARE_Constants.CARE_STAGED_CCB;
                        careApp.ENROLLMENT_TYPE__c = CARE_Constants.CARE_ENROLLMENT_OTHER;
                        careApp.RECEIVED_DATE__c = dTodaysDate; //DATE__c : careAppRecord.PROCESSED_DATE__c;
                        careApp.PROCESSED_DATE__c = dTodaysDate;
                        careApp.PER_ID__c = objSite.Person_ID_EI__c;
                        careApp.CARE_Account_ID__c = objSite.Account_EI__c;
                        careApp.ACCT_ID__c = objSite.Billing_Account_ID_EI__c;
                        careApp.CC_CL_CD__c = objSite.Account_EI__r.CARE_DISCOUNT_TYPE__c;
                        careApp.CCB_CONTACT_CODE__c = listCareTypeDesc[0].TYPE_CODE__c;
                        careApp.CCB_CONTACT_DESC__c = listCareTypeDesc[0].TYPE_DESC__c;
                        careApp.CCB_Contact_Type_No__c = listCareTypeDesc[0].TYPE_NO__c;
                        careApp.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_CHANNEL_TYPE_BATCH;
                        careAppList.add(careApp);
                        system.debug('careAppList--->'+careAppList);
                    } 
                }
                
                if(careAppList.size() > 0){
                    Database.SaveResult[] srList = Database.insert(careAppList, false);
                    for(Integer i =0; i < srList.size(); i++) {
                        if(srList.get(i).isSuccess()){
                            setId.add(srList.get(i).Id);
                        }
                        else if(!srList.get(i).isSuccess()){
                            Database.Error errors =  srList.get(i).getErrors().get(0);
                            setErrorIdNotEsa.add(srList.get(i).Id);
                            setErrorPerIdNotEsa.add(careAppList[i].PER_ID__c); 
                            sysAdminError += srList.get(i).Id+'-'+errors.getMessage()+'\n';
                            
                        }
                    }
                }
                if(!String.isBlank(sysAdminError)) {
                    EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_ESAFortyFiveDayExpireBatch', new EI_BatchException(sysAdminError)));
                }
                
                if(setId.size() > 0){
                    careAppListOfRec = [Select Id, PER_ID__c from CARE_Application__c where Id IN: setId AND CCB_Contact_Type_No__c =: listCareTypeDesc[0].TYPE_NO__c];
                }
                system.debug('careAppListOfRec---->'+careAppListOfRec);
                
                if(careAppListOfRec.size() > 0){
                    for(EI_Site__c objSA : DropListESA){
                        for(CARE_Application__c careObj : careAppListOfRec){
                            if(objSA.Person_ID_EI__c == careObj.PER_ID__c){
                                CARE_App_Enrolled_SA__c careAppEnroll = new CARE_App_Enrolled_SA__c();
                                careAppEnroll.ACCT_ID__c =  objSA.Billing_Account_ID_EI__c;
                                careAppEnroll.APPLICATION__c =  careObj.Id;
                                careAppEnroll.CC_CL_CD__c =  objSA.Account_EI__r.CARE_DISCOUNT_TYPE__c;//remove hardcode and bring from account object
                                careAppEnroll.PER_ID__c =  careObj.PER_ID__c;
                                careAppEnroll.PREM_ID__c =  objSA.Site_Premise_ID_EI__c;
                                careAppEnroll.RS_CD__c =  objSA.Rate_Schedule_EI__c;
                                careAppEnroll.SA_ID__c =  objSA.SAID_EI__c;
                                careAppEnroll.CCB_CONTACT_TYPE__c =  listCareTypeDesc[0].TYPE_NO__c;
                                careAppEnroll.END_DATE__c = dTodaysDate;
                                careAppEnroll.Service_Agreement__c = objSA.Id;
                                careAppEnrollSAList.add(careAppEnroll);
                            } 
                        } 
                    }
                } 
                
                Database.SaveResult[] srL = Database.insert(careAppEnrollSAList, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srL) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted careAppEnroll--->: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors               
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('CAre Application fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            wrapperESAThreshold.setESADropAppId = setId;
            wrapperESAThreshold.setESADropErrId = setErrorIdNotEsa;
            wrapperESAThreshold.setESADropErrPerId = setErrorPerIdNotEsa;
            
            system.debug('wrapperESAThreshold in notenrolledESAmethod---->'+wrapperESAThreshold);
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return wrapperESAThreshold;       
        
    }
    
    // This method is used to check for next 685 days if cusomer is getting ESA enrolled after dropping
    public static ESAThresholdCheckWrapper eSASixEightyFiveDaysCheck(List<CARE_CC_Batch_Detail__c> listHRandCert){
        
        system.debug('inside eSASixEightyFiveDaysCheck method---->');
        
        Boolean bRecordInsert = false;
        Boolean bThresholdCheck = false;
        Boolean bFortyFiveDayCheck = false;
        Date dTodaysDate = Date.today();
        Date dSixEightyFiveDay = dTodaysDate.addDays(-CARE_Constants.CARE_BeforeSixEightyFiveDays);
        Date dDateBeforeTenYears = dTodaysDate.addYears(-CARE_Constants.CARE_BeforeTenYears);
        Set<Id> careBatchAppIdSet = new Set<Id>();
        //Set<String> perIdSet = new Set<String>();
        //Set<Id> careAppIdFromCareEnrollSet = new Set<Id>();
        Set<Id> eSACompCareAppIdSet = new Set<Id>();
        Set<String> premIdSet = new Set<String>();
        Set<String> setOfHRandCertPerId = new Set<String>();
        Set<String> perIdSetESA = new Set<String>();
        Set<String> premIdSetFromPremise = new Set<String>();
        Map<String, String> mapOfHrandCert = new Map<String, String>();
        //List<CARE_App_Enrolled_SA__c> careAppEnrollList = new List<CARE_App_Enrolled_SA__c>();
        List<EI_PREMISE__c> premiseList = new List<EI_PREMISE__c>();
        ESAThresholdCheckWrapper wrapperESAThreshold = new ESAThresholdCheckWrapper();
        
        try{
            system.debug('listHRandCert inside eSASixEightyFiveDaysCheck--->'+listHRandCert);
            if(listHRandCert.size() > 0){
                for(CARE_CC_Batch_Detail__c careBatchRecord : listHRandCert){
                    mapOfHrandCert.put(careBatchRecord.PER_ID__c, careBatchRecord.APPLICATION__c);
                    setOfHRandCertPerId.add(careBatchRecord.PER_ID__c);
                    careBatchAppIdSet.add(careBatchRecord.APPLICATION__c);
                }
                
                
                List<CARE_CC_Batch_Detail__c> listOfDERecords = [select APPLICATION__c, PER_ID__c,CARE_APP_ENROLLED_SA__r.PREM_ID__c from CARE_CC_Batch_Detail__c
                                                                 where CARE_CI_CC__r.CC_TYPE_CD__c = 'DE' AND CARE_CI_CC__r.CC_DTTM__c >=: dSixEightyFiveDay
                                                                 AND PER_ID__c IN: setOfHRandCertPerId];
                
                for(CARE_CC_Batch_Detail__c ccB : listOfDERecords){
                    //careAppIdSet.add(ccB.APPLICATION__c);
                    premIdSet.add(ccB.CARE_APP_ENROLLED_SA__r.PREM_ID__c);
                    //perIdSet.add(ccB.PER_ID__c);
                }
                system.debug('premIdSet---->'+premIdSet);
                if(premIdSet.size() > 0){
                    premiseList = [select Name from EI_PREMISE__c where Name IN: premIdSet 
                                   AND (Last_ESA_Enrollment_Date__c >: dDateBeforeTenYears OR ESA_Last_Treated_EI__c >: dDateBeforeTenYears)];
                    for(EI_PREMISE__c prem : premiseList){
                        premIdSetFromPremise.add(prem.Name);
                    }
                }else{
                    premIdSetFromPremise = premIdSet;
                }
                
                if(premIdSetFromPremise.size() > 0){
                    for(CARE_CC_Batch_Detail__c sEnroll : listOfDERecords){
                        if(premIdSetFromPremise.contains(sEnroll.CARE_APP_ENROLLED_SA__r.PREM_ID__c)){
                            perIdSetESA.add(sEnroll.PER_ID__c);
                            eSACompCareAppIdSet.add(mapOfHrandCert.get(sEnroll.PER_ID__c)); //created clone of H RAND CERT Application Id
                            
                        }else{
                            eSACompCareAppIdSet = careBatchAppIdSet;
                            perIdSetESA = setOfHRandCertPerId;
                        }
                    }
                }else{
                    eSACompCareAppIdSet = careBatchAppIdSet;
                    perIdSetESA = setOfHRandCertPerId;
                }
                system.debug('eSACompCareAppIdSet--->'+eSACompCareAppIdSet);
                system.debug('perIdSetESA--->'+perIdSetESA);
                if(eSACompCareAppIdSet.size() > 0){
                    wrapperESAThreshold = CARE_AutoUtilityController.createEsaCompRecord(eSACompCareAppIdSet);
                    //wrapperESAThreshold = CARE_AutoUtilityController.thresholdExceedCheckMethod(perIdSetESA, wrapperESAThreshold);
                }
            }
            system.debug('wrapperESAThreshold in eSASixEightyFiveDaysCheck--->'+wrapperESAThreshold);
        }catch(exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return wrapperESAThreshold;
    }
    /*
    //p1nm; Processing method for CDW I6 batch
    public static void processI6UsageList(String fileRecords ){
        
        //P1NM; commenting the parsing the Tab delimited data changes start here
        List<String> headerList = new List<String>();
        List<String> lstDateFields = new List<String>();
        String headerRecord = '';
        for(EI_BatchInterface_Setup__c I6_Item :[SELECT HEADER_COLUMN__c,datatype__c,Id,SEQ_NO__c,Source_Object__c,Taregt_Object__c,Target_Field_Name__c FROM EI_BatchInterface_Setup__c WHERE Taregt_Object__c = 'EI_Usage__c' ORDER BY SEQ_NO__c ASC])
        {   headerRecord += I6_Item.Target_Field_Name__c + '\t';
            if(I6_Item.DataType__c == 'Date')
                lstDateFields.add(I6_Item.Target_Field_Name__c);
        }
        system.debug('@@@ headerRecord ' + headerRecord);
            
        fileRecords = headerRecord + '\r\n' + fileRecords;
        //Calling generic method from JSONLib
        System.debug('@@@ Before calling JSONLib.tabToObject ' + fileRecords.length());
            
        Object obj = p1nmJSON.tabToObject(fileRecords,'EI_Usage__c');
        List<sObject> listsObj = (ei_usage__c[])obj;
        List<EI_Usage__c> lstOfEIUsgToUpsert = new List<EI_Usage__c>();
        for(sObject ei_usage: listsObj)
        {
            for(String strDtfield:lstDateFields)
            {
                ei_usage.put(strDtField.substring(3,strDtField.length()), formatDate(string.valueOf(ei_usage.get(strDtfield)))); 
            }
            //converting as External Id cannot be stamped from sobject
            EI_Usage__c EI_Usage_Item = (EI_Usage__c)ei_usage;
            EI_Site__c SA = new EI_Site__c();
            SA.External_ID_EI__c = EI_Usage_Item.External_ID_EI__c;
            EI_Usage_Item.Site_EI__r = SA;
            EI_Usage_Item.External_ID_EI__c = ei_usage.get('External_ID_EI__c')   + ':'+ei_usage.get('Period_End_EI__c');
            lstOfEIUsgToUpsert.add(EI_Usage_Item);
        }
        System.debug('####' + lstOfEIUsgToUpsert);
            

        //p1nm changes end here
        if(lstOfEIUsgToUpsert.size() > 0){
            Schema.SObjectField extIdField = EI_Usage__c.Fields.External_ID_EI__c;
            Database.UpsertResult[] srList = Database.upsert(lstOfEIUsgToUpsert,extIdField,false);
            List<string> lstUpsertedRec = new List<String>();
            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                    //p1nm; changes start here to update the processed records Completed.
                    // Store the external ids of the successful upserts.
                    lstUpsertedRec.add(sr.getId());
                    system.debug('@@@@@@ successfully upserted' + sr.getId());
                    //p1nm; changes end here to update the processed records Completed.
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
    }
public static void processI6SAList(String fileRecords ){
        
        //P1NM; commenting the parsing the Tab delimited data changes start here
        List<String> headerList = new List<String>();
        List<String> lstDateFields = new List<String>();
        String headerRecord = '';
        for(EI_BatchInterface_Setup__c I6_Item :[SELECT HEADER_COLUMN__c,datatype__c,Id,SEQ_NO__c,Source_Object__c,Taregt_Object__c,Target_Field_Name__c FROM EI_BatchInterface_Setup__c WHERE Taregt_Object__c = 'EI_Site__c' ORDER BY SEQ_NO__c ASC])
        {   headerRecord += I6_Item.Target_Field_Name__c + '\t';
            if(I6_Item.DataType__c == 'Date')
                lstDateFields.add(I6_Item.Target_Field_Name__c);
        }
        system.debug('@@@ headerRecord ' + headerRecord);
            
        fileRecords = headerRecord + '\r\n' + fileRecords;
        //Calling generic method from JSONLib
        System.debug('@@@ Before calling JSONLib.tabToObject ' + fileRecords.length());
            
        Object obj = p1nmJSON.tabToObject(fileRecords,'EI_Site__c');
        List<sObject> listsObj = (ei_usage__c[])obj;
        List<EI_Site__c> lstOfEISAToUpsert = new List<EI_Site__c>();
        for(sObject ei_usage: listsObj)
        {
            for(String strDtfield:lstDateFields)
            {
                ei_usage.put(strDtField.substring(3,strDtField.length()), formatDate(string.valueOf(ei_usage.get(strDtfield)))); 
            }
            //converting as External Id cannot be stamped from sobject
            EI_Site__c EI_SA_Item = (EI_Site__c)ei_usage;
            EI_NAICS_Code__c Naics = new EI_NAICS_Code__c();
            Naics.External_ID_EI__c = EI_SA_Item.strNAICS_Code_relation_EI__c;
            EI_SA_Item.NAICS_Code_relation_EI__r =Naics;
            lstOfEISAToUpsert.add(EI_SA_Item);
        }
        System.debug('####' + lstOfEISAToUpsert);
            


        //p1nm changes end here
        if(lstOfEISAToUpsert.size() > 0){
            Schema.SObjectField extIdField = EI_Site__c.Fields.External_ID_EI__c;
            Database.UpsertResult[] srList = Database.upsert(lstOfEISAToUpsert,extIdField,false);
            List<string> lstUpsertedRec = new List<String>();
            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                    //p1nm; changes start here to update the processed records Completed.
                    // Store the external ids of the successful upserts.
                    lstUpsertedRec.add(sr.getId());
                    system.debug('@@@@@@ successfully upserted' + sr.getId());
                    //p1nm; changes end here to update the processed records Completed.
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
        }
    }
    
    public static Date formatDate(String originaldate)
    {
            
            Integer day     = Integer.valueOf(originaldate.substringBefore('/'));
            Integer month   = Integer.valueOf(originaldate.substringBetween('/'));
            Integer year    = Integer.valueOf(originaldate.substringAfterLast('/'));
            Date newDate    = Date.newInstance(year, month, day);  
        return newDate;
    }*/
}