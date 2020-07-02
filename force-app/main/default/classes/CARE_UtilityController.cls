/***********************************************************************************************************   
Apex Util class Name :  CARE_UtilityController
Version              :  1.0                                                                          
Created Date         :  05/28/2020                                                         
Function             :  This is the Utiltity Class for re-usable components in CARE Application.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                                                 Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/28/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_UtilityController {
    
    //Constants   
    Private Static final Date dTodaysDate = Date.today();
    
    //************Wrapper Class***************
    //re usable method to split the string into List of string using comma seperator
    public Static List<String> StrToList(String sInput) {
        List<String> listResponse = new List<String>();
        listResponse = sInput.split(',');
        return listResponse;
    }
    //get Active Status code for CARE Program 
    public static List<String> getCareActiveStatusCode (){
        
        List<String> listActiveStatusCode ;
        try{
            String sActiveStatusCode = [SELECT TYPE_DESC__c 
                                        FROM CARE_TYPE__c WHERE CATEGORY__c = :CARE_Constants.CARE_VALID_SA_CAT
                                        AND START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate LIMIT 1].TYPE_DESC__c;    
            if(String.isNotBlank(sActiveStatusCode)){
                listActiveStatusCode = StrToList(sActiveStatusCode);
            }            
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }         
        return listActiveStatusCode;
    }
    
    //get Valid RateSchedule for CARE Program 
    
    public static List<String> getCareValidRateSchedule (String sDiscountType){
        
        List<String> listValidRateSchedule ;
        try{
            if(string.isBlank(sDiscountType)){
                //get default Rate schedule as 'CARE'
                sDiscountType = CARE_Constants.CARE_DEFAULT_RATE_SC;
            }
            
            String sValidRateSchedule = [SELECT TYPE_DESC__c 
                                         FROM CARE_TYPE__c WHERE CATEGORY__c =: CARE_Constants.CARE_VALID_RATE_CAT
                                         AND TYPE_CODE__c =:sDiscountType AND START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate].TYPE_DESC__c;            
            if(String.isNotBlank(sValidRateSchedule)){
                listValidRateSchedule = StrToList(sValidRateSchedule);
            }
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }        
        return listValidRateSchedule;
    }
    
    //get Current Discount of customer based on PerID
    public static String getDiscountType (String sPerID){
        String sDiscountType;
        try{
            sDiscountType = [SELECT CARE_DISCOUNT_TYPE__c 
                             FROM Account 
                             WHERE  Billing_Person_ID_EI__c =:sPerID AND CARE_DISCOUNT_TYPE__c !=Null
                             LIMIT 1 ].CARE_DISCOUNT_TYPE__c;
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return sDiscountType;
    }
    
    //get the SA details along with discount type 
    public static Map <String, EI_SITE__C > getSADetailsForPersonId (string sPerID)
    {
        Map <string,EI_SITE__C> mapSARecords = new map <String, EI_SITE__C> ();
        try{
            for (EI_SITE__C listEISiteRecords : [SELECT ID, SAID_EI__c, Svc_Type_Code_EI__c, Site_Premise_ID_EI__c, Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c,Imported_Site_Name_EI__c,SA_Start_Date_EI__c, 
                                                 Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, CARE_DISCOUNT_TYPE__c,  Billing_Account_ID_EI__c, Account_EI__r.Id, Rate_Schedule_EI__c  
                                                 FROM EI_Site__c 
                                                 WHERE Person_Id_EI__C =:sPerID])
            {            
                mapSARecords.put(listEISiteRecords.SAID_EI__c, listEISiteRecords);
                
            }
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return mapSARecords ;
    }
    
    //get the Active SA details along with discount type
    public static Map <String, EI_SITE__C> getActiveSADetailsForPersonId (string sPerID)
    {
        Map <string,EI_SITE__C> mapSARecords = new map <String, EI_SITE__C> ();
        
        try{
            
            String sDiscountType = getDiscountType(sPerID);            
            List<String> listActiveStatusCode = getCareActiveStatusCode();
            system.debug('listActiveStatusCode'+listActiveStatusCode);
            List<String> listValidRateSchedule = getCareValidRateSchedule(sDiscountType);
            system.debug('listValidRateSchedule'+listValidRateSchedule);
            for (EI_SITE__C listEISiteRecords : [SELECT ID, SAID_EI__c, Svc_Type_Code_EI__c, Site_Premise_ID_EI__c, Svc_Full_Adr_EI__c,Rate_Schedule_EI__c,Imported_Site_Name_EI__c, SA_Start_Date_EI__c, 
                                                 Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Account_EI__r.Id
                                                 FROM EI_Site__c WHERE Person_Id_EI__C =:sPerID AND Svc_Status_Code_EI__c IN:listActiveStatusCode
                                                 AND Care_Stop_Date_EI__c >: dTodaysDate AND Rate_Schedule_EI__c IN :listValidRateSchedule ])
            {            
                mapSARecords.put(listEISiteRecords.SAID_EI__c, listEISiteRecords);                
            }   
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return mapSARecords ;
    }
    
    //get the Active SA details which doesn't have any active discount
    public static Map <String, EI_SITE__C> getActiveSADetailsWithNoDiscForPersonId (string sPerID){
        Map <string,EI_SITE__C> mapSARecords = new map <String, EI_SITE__C> ();
        
        try{
            String sDiscountType = getDiscountType(sPerID); 
            List<String> listActiveStatusCode = getCareActiveStatusCode();
            List<String> listValidRateSchedule = getCareValidRateSchedule(sDiscountType);
            
            for (EI_SITE__C listEISiteRecords : [SELECT ID, SAID_EI__c, Svc_Type_Code_EI__c, Site_Premise_ID_EI__c, Svc_Full_Adr_EI__c,Rate_Schedule_EI__c,Imported_Site_Name_EI__c, SA_Start_Date_EI__c, 
                                                 Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c,CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Svc_Status_Code_EI__c, Account_EI__r.Id
                                                 FROM EI_Site__c
                                                 WHERE Person_Id_EI__C =:sPerID
                                                 AND Svc_Status_Code_EI__c IN:listActiveStatusCode
                                                 AND (Care_Stop_Date_EI__c = NULL OR Care_Stop_Date_EI__c <: dTodaysDate)
                                                 AND Rate_Schedule_EI__c IN : listValidRateSchedule ])
            {      
                system.debug('listEISiteRecords==> '+listEISiteRecords);
                mapSARecords.put(listEISiteRecords.SAID_EI__c, listEISiteRecords);               
            }  
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return mapSARecords ;
    }
    
    
    //get the CCCode Details based on TypeNo / category && TypeCode
    public static list <CARE_Type__c> getCCCode(String sCareTypeNo, String sTypeCode, String sCategory ){
        
        List <CARE_Type__c> listCareTypeResult = new List <CARE_Type__c>();
        List <CARE_Type__c> listCareType = new List <CARE_Type__c>();
        try
        {
            if(String.isNotBlank(sCareTypeNo)) 
            {
                listCareType = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c  FROM CARE_Type__c 
                                WHERE TYPE_NO__c = :sCareTypeNo AND START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate ];
                
            }
            else
            {
                listCareType = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c  FROM CARE_Type__c 
                                WHERE TYPE_CODE__C = :sTypeCode AND CATEGORY__c = :sCategory AND START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate ];
            }
            
            for (CARE_Type__c careTypeRecord :listCareType)
            {
                listCareTypeResult.add(careTypeRecord);
            }            
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return listCareTypeResult;
    }
    
    
    //method to check if Customer on probation
    public static Boolean checkCustomerOnProbation (String sPerID){
        Boolean bProbation ;
        try{
            
            list<Account> listProbationAccount = [SELECT ID,CARE_ON_PROBATION__c FROM ACCOUNT 
                                                  WHERE Billing_Person_ID_EI__c = : sPerID AND CARE_PROBATION_START_DATE__c <:dTodaysDate 
                                                  AND CARE_PROBATION_END_DATE__c >:dTodaysDate];
            
            if(listProbationAccount.size()>0){
                bProbation = true;
            }
            else {
                bProbation = false;
            }
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString()); 
        }
        return bProbation;
    }
    
    //method to check if customer is having employee discount
    public static Boolean checkEmployeeDiscount (String sPerId){
        
        Boolean bEmpDiscount;
        try{
            List <EI_SA_CONTERM__C> listEmpDiscount = [SELECT SA_ID__c, BF_CD__C, END_DT__C FROM EI_SA_CONTERM__C
                                                       WHERE SERVICE_AGREEMENT__r.Person_ID_EI__c = :sPerId AND BF_CD__C = 'EMP-DSC'
                                                       AND (END_DT__C >= :dTodaysDate OR END_DT__C = NULL)];
            if(listEmpDiscount.size()>0){
                bEmpDiscount = true;
            }
            else{
                bEmpDiscount = false;
            }
        }
        catch (Exception ex) {
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        } 
        return bEmpDiscount;
    }
    
    @Auraenabled
    public static void validateRetroDates(List<String> recordInputValues){
        
        system.debug('recordInputValues---->'+ recordInputValues);
    }
    
    //method to get the reason picklist values based on category
    
    public static List<String> getReasonList(String sCategory){
        
        List<String> listReason = new List<String>();
        try{
            
            List <CARE_TYPE__c> careType  = [SELECT TYPE_DESC__c FROM CARE_TYPE__c 
                                             WHERE CATEGORY__c =:sCategory AND IS_ACTIVE__C = true
                                             AND START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate]; 
            
            for(CARE_TYPE__c careTypeobj :careType  ){
                
                listReason.add(careTypeobj.TYPE_DESC__c);
            }
        }
        catch (Exception ex) {
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        } 
        return listReason;
    }
    
    //method to get session received date
    @AuraEnabled(Cacheable = true)
    public static Date getReceivedDateSession (){
        Date dTodaysDate = Date.today();
        try{
            
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CareSessionCache');
            if (sessionPart.contains('CareEnrollmentReceivedDateSession')) {
                Date ReceivedSessionTemp  = (Date)sessionPart.get('CareEnrollmentReceivedDateSession');
                system.debug('ReceivedSessionTemp==>'+ReceivedSessionTemp);
                if(ReceivedSessionTemp !=null){
                    dTodaysDate = ReceivedSessionTemp;
                }
            }
        }
        catch (Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString()); 
        }
        return dTodaysDate;
    }
    
    //This method is used to check if Image ID exsist in Care_Application__c object for the application id
    @AuraEnabled
    public static Boolean checkIfImageIDExists(Id idApplication){
        try{
            Boolean bImageIDExists = true;            
            List<CARE_APP_Image_List__c> listCareAppImgList = [SELECT Id, Name
                                                               FROM CARE_APP_Image_List__c
                                                               WHERE Application__c =:idApplication
                                                               ORDER by Name];
            if(listCareAppImgList.size() > 0){
                bImageIDExists = true;
            }
            else{
                bImageIDExists = false;
            }
            return bImageIDExists;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
    }
    
    //This method is used to check if uploaded image exists in ContentVersion for the application id
    @AuraEnabled
    public static Boolean checkIfUploadedImageExists(Id idApplication){
        try{
            Boolean bUploadedImageExists = true;
            List<Id> listConDocIds = new List<Id>();
            List<Id> listConVerIds = new List<Id>();
            
            //Select the ContentDocumentId from ContentDocumentLink where LinkedEntityId is equal to the application Id
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idApplication]) {
                listConDocIds.add(cntLink.ContentDocumentId);
            }
            
            if(!listConDocIds.isEmpty()){
                bUploadedImageExists = true;
                List<ContentVersion> listConVers = [SELECT Id, Title, ContentDocumentId, PathOnClient, FileExtension FROM ContentVersion 
                                                    WHERE ContentDocumentId IN :listConDocIds AND IsLatest = TRUE
                                                    ORDER BY CreatedDate];
                if(listConVers.size() > 0){
                    bUploadedImageExists = true;
                }
            }
            else{
                bUploadedImageExists = false;
            }
            return bUploadedImageExists;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
    }
    
    //This method is used to delete all the records of ContentDocument and related object records against the application Id
    @AuraEnabled
    public static Boolean deleteUploadedContents(Id idApplication){
        Boolean bDeleteSuccess = false;
        List<Id> listConDocIds = new List<Id>();
        List<Id> listConVerIds = new List<Id>();
        try{
            //Select the ContentDocumentId from ContentDocumentLink where LinkedEntityId is equal to the application Id
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idApplication]) {
                listConDocIds.add(cntLink.ContentDocumentId);
            }
            
            if(!listConDocIds.isEmpty()){
                List<ContentDocument> listContentDoc = [SELECT Id FROM ContentDocument 
                                                        WHERE Id IN :listConDocIds];
                
                Database.DeleteResult[] listDelRes = Database.delete(listContentDoc, true); //set true, so that for this parameter and a record fails, the remainder of the DML operation can still succeed.
                system.debug('listDelRes-->'+listDelRes);
                // Iterate through each returned result
                for(Database.DeleteResult dr : listDelRes) {
                    if (dr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully deleted account with ID: ' + dr.getId());
                        bDeleteSuccess = true;
                    }
                    else {
                        bDeleteSuccess = false;
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }                
            }
            system.debug('bDeleteSuccess-->'+bDeleteSuccess);
            return bDeleteSuccess;
        }
        catch(Exception ex){
            bDeleteSuccess = false;
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
    }
    
    //This method returns the RecordTypeId
    public static Id getObjectRecordTypeId(String sRecordTypeDevName){
        return Schema.SObjectType.CARE_Application__c.getRecordTypeInfosByDeveloperName().get(sRecordTypeDevName).getRecordTypeId();
    }
    
}