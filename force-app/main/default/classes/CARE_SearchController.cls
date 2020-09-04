/***********************************************************************************************************   
Apex Util class Name :  CARE_SearchController
Version              :  1.0                                                                          
Created Date         :  05/09/2020                                                         
Function             :  This is the Apex COntroller for Search Panel of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/09/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

public inherited sharing class CARE_SearchController {
    
    /*********************************WRAPPER CLASS*********************************************************/
    public class AutoCompleteSearch{        
        @AuraEnabled public Set<String> listResults{get;set;} 
        @AuraEnabled public List<String> listResultsSession{get;set;}
        public AutoCompleteSearch()
        {
            listResults = new Set<String>(); 
            listResultsSession = new List<String>();
        }
    }
    
    //SearchWrapperRequest class
    public class SearchWrapperRequest{
        //@AuraEnabled public String sId{get;set;}
        @AuraEnabled public String sAccountID{get;set;}
        @AuraEnabled public String sPersonID{get;set;}
        @AuraEnabled public String sPremiseID{get;set;}
        @AuraEnabled public boolean bInactiveCustomer{get;set;}
        @AuraEnabled public String sSAID{get;set;}
        @AuraEnabled public String sName{get;set;}
        @AuraEnabled public String sPhone{get;set;}
        @AuraEnabled public String sStreet{get;set;}
        @AuraEnabled public String sCity{get;set;}
        @AuraEnabled public String sZip{get;set;}
        @AuraEnabled public String sSpace{get;set;}
        @AuraEnabled public boolean bNPFacilityType{get;set;}
        @AuraEnabled public boolean bAGRFacilityType{get;set;}
        @AuraEnabled public boolean bMFHCFacilityType{get;set;}
        @AuraEnabled public boolean bSMFacilityType{get;set;}
        @AuraEnabled public String sFacilityHousingOrgVal{get;set;}
        @AuraEnabled public boolean bEnrolledTenant{get;set;}
        @AuraEnabled public boolean bProbation{get;set;}
    }
    
    //SearchWrapperResponse
    public class SearchWrapperResponse{
        @AuraEnabled public List<CustomerWrapper> listCustomers{get;set;} 
        @AuraEnabled public boolean success{get;set;}
        @AuraEnabled public String errorCode{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        public SearchWrapperResponse()
        {
            success = true;
            errorCode = '';
            errorMessage = '';
            listCustomers = new List<CustomerWrapper>();
        }        
    }
    
    //SearchWrapperResponse
    public class CustomerWrapper{        
        @AuraEnabled public Id idcustId{get;set;}
        @AuraEnabled public String sCustName{get;set;}
        @AuraEnabled public String sResNonRes{get;set;}
        @AuraEnabled public String sFHType{get;set;}
        @AuraEnabled public String sAccId{get;set;}
        @AuraEnabled public String sSAId{get;set;}
        @AuraEnabled public String sSAType{get;set;}
        @AuraEnabled public String sSAStatus{get;set;}
        @AuraEnabled public String sDiscount{get;set;}
        @AuraEnabled public String sRate{get;set;}
        @AuraEnabled public String sSvcAddr{get;set;}
        @AuraEnabled public String sFacilityId{get;set;}
        @AuraEnabled public String sSpaceUnit{get;set;}
        @AuraEnabled public String sPerId{get;set;}
        @AuraEnabled public String sPremId{get;set;}
        @AuraEnabled public String sEIAccountId{get;set;}
        @AuraEnabled public String sProbation{get;set;}
        @AuraEnabled public String sEIAccountEmail{get;set;}
        @AuraEnabled public String sFacilityName{get;set;}
        
        //DEL
        @AuraEnabled public String sCustomSAId{get;set;}
        @AuraEnabled public String sCustomAcctId{get;set;}
    }    
    
    public class PremiseSiteDetails{
        @AuraEnabled public EI_PREMISE__c premise {get;set;}
        @AuraEnabled public String siteContactName {get;set;} 
        @AuraEnabled public String SiteContactPhoneNumber{get;set;}
        @AuraEnabled public String SiteSAIds{get;set;}   
    }
    
    public class FacilityHousingWrapper{
        @AuraEnabled public List<GroupFacilityWrapper> listAllFacility {get;set;}
        @AuraEnabled public List<GroupFacilityWrapper> listNPFacility {get;set;}
        @AuraEnabled public List<GroupFacilityWrapper> listAGRFacility {get;set;}
        @AuraEnabled public List<GroupFacilityWrapper> listMFHCFacility {get;set;}
        @AuraEnabled public List<GroupFacilityWrapper> listSMFacility {get;set;}       
        
        public FacilityHousingWrapper(){
            listAllFacility = new List <GroupFacilityWrapper>();
            listNPFacility = new List <GroupFacilityWrapper>();
            listAGRFacility = new List <GroupFacilityWrapper>();
            listMFHCFacility = new List <GroupFacilityWrapper>();
            listSMFacility = new List <GroupFacilityWrapper>();            
        }        
    }
    
    public class GroupFacilityWrapper{
        @AuraEnabled public String sId {get;set;}
        @AuraEnabled public Integer sFacilityId {get;set;}
        @AuraEnabled public String sFacilityType {get;set;}
        @AuraEnabled public String sFacilityName {get;set;}
    }
    /*********************************WRAPPER CLASS*********************************************************/
    
    /*********************************PUBLIC METHODS*********************************************************/
    
    //This method is used to do an exact serach from an object based on a single field search. 
    //Object name and field name are dynamically populated from the parameters
    @AuraEnabled   
    public static AutoCompleteSearch getListOfStrings(String searchKey, String objectApiName, String fieldApiName){
        AutoCompleteSearch objAutoCompleteSearch = new  AutoCompleteSearch();
        if(String.isNotBlank(searchKey)){
            List<List<SObject>> SOSLResult = new List<List<SObject>>();
            try{
                //Trim and append with leading zeroes in the searchKey to make it 10 digits           
                String sSearchString = String.escapeSingleQuotes(searchKey.trim().leftPad(10, '0')); //Sanitizing the input searchkey parameter before SOQL Query to avoid query injection
                String sSearchQuery  = 'FIND \'' + sSearchString + '\'  IN ALL FIELDS RETURNING ' + objectApiName + ' (' + fieldApiName + ' WHERE ' + fieldApiName +' = \'' + sSearchString + '\' AND Account_EI__r.Id != NULL)' ;
                
                
                SOSLResult = search.query(sSearchQuery);
                if (SOSLResult != null && SOSLResult.size() >0){
                    for(sObject sObjResult : SOSLResult[0]){
                        //system.debug('sObjResult==>' +sObjResult);
                        //system.debug('val==>' +String.valueOf(sObjResult.get(fieldApiName)));
                        String sfieldValue = String.valueOf(sObjResult.get(fieldApiName));
                        objAutoCompleteSearch.listResults.add(sfieldValue);
                    }
                }
            }
            catch(Exception ex){
                //system.debug('ex==>' +ex);
                throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
            }
        }else{
            Switch on fieldApiName {
                when 'Billing_Account_ID_EI__c' {
                    objAutoCompleteSearch.listResultsSession = getSearchedKeySession('AccountId');
                }
                when 'Site_Premise_ID_EI__c' {
                    objAutoCompleteSearch.listResultsSession = getSearchedKeySession('PremiseId');
                }
                when 'SAID_EI__c' {
                    objAutoCompleteSearch.listResultsSession = getSearchedKeySession('SAId');
                }
                when 'Person_ID_EI__c' {
                    objAutoCompleteSearch.listResultsSession = getSearchedKeySession('PersonId');
                }
            }
            
        }
        return objAutoCompleteSearch;
    }
    
    //This method is used to return the list of customers as a result of Search
    @AuraEnabled   
    public static SearchWrapperResponse getCustomerList(SearchWrapperRequest searchDetails){
        SearchWrapperResponse searchResponse = new SearchWrapperResponse();
        List<EI_Site__c> listSiteServAgreement =  new List<EI_Site__c>();
        boolean bOnlyAccountID = true;
        String sPerId = '';
        String soqlWhereClause = '';
        String soqlSearchQuery =''; 
        try{
            // Set Searached Key into session kept into each if
            if(String.isNotBlank(searchDetails.sAccountID)){
                setSearchedKeySession(searchDetails.sAccountID,'AccountId');
            }
            if(String.isNotBlank(searchDetails.sSAID)){
                setSearchedKeySession(searchDetails.sSAID,'SAId');
            }
            if(String.isNotBlank(searchDetails.sPersonID)){
                setSearchedKeySession(searchDetails.sPersonID,'PersonId');
            }
            if(String.isNotBlank(searchDetails.sPremiseID)){
                setSearchedKeySession(searchDetails.sPremiseID,'PremiseId');
            }
            
            //If any field is entered other than Account Id, then set the flag as false, and proceed with step 2
            if(String.isNotBlank(searchDetails.sPersonID) || String.isNotBlank(searchDetails.sFacilityHousingOrgVal)  || String.isNotBlank(searchDetails.sPremiseID) || String.isNotBlank(searchDetails.sSAID) || String.isNotBlank(searchDetails.sName)
               || String.isNotBlank(searchDetails.sPhone) || String.isNotBlank(searchDetails.sStreet) || String.isNotBlank(searchDetails.sCity) || String.isNotBlank(searchDetails.sZip) ){ //TBD:add more conditions for the fields
                   bOnlyAccountID = false;
               }
            
            //Step 1: If only Account ID is entered, select the person id for that account id, and then select all the records under that person id
            if(bOnlyAccountID){               
                List<EI_Site__c> listEISite = [SELECT Person_ID_EI__c FROM EI_Site__c WHERE Billing_Account_ID_EI__c =:searchDetails.sAccountID AND Account_EI__r.Id != NULL LIMIT 1];
                for(EI_Site__c eiSite : listEISite){
                    sPerId = eiSite.Person_ID_EI__c;
                }
                
                //If checkbox is unchecked for 'Include Inactive Customer', then select only Active customer, else select All
                if(searchDetails.bInactiveCustomer != null && !searchDetails.bInactiveCustomer){
                    //List<String> listStatus = new List<String>{'10', '20'}; //TBD: put in constant class
                    List<String> listStatus = CARE_UtilityController.getCareActiveStatusCode();
                    listSiteServAgreement = [SELECT Id, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, SAID_EI__c, Svc_Type_Code_EI__c,
                                             Svc_Status_Code_EI__c, CARE_DISCOUNT_TYPE__c, Rate_Schedule_EI__c, Svc_Full_Adr_EI__c,
                                             Person_ID_EI__c, Account_EI__r.Id, Account_EI__r.CARE_ON_PROBATION__c, Site_Premise_ID_EI__c, Res_Ind_EI__c, 
                                             Account_EI__r.Email_adr_EI__c, (SELECT Id, CARE_Facility_Name__c, Facility_Name__c, FACILITY_TYPE__c, TRANS_TYPE__c FROM CARE_Facility_Enrolled_SA__r where TRANS_TYPE__c !='DR')
                                             FROM EI_Site__c
                                             WHERE Person_ID_EI__c =:sPerId 
                                             AND Account_EI__r.Id != NULL
                                             AND Svc_Status_Code_EI__c IN:listStatus
                                            // AND Id IN (SELECT CARE_Site__c FROM CARE_Facility_Enrolled_SA__c where TRANS_TYPE__c !='DR')
                                             ORDER BY Person_ID_EI__c, Site_Premise_ID_EI__c, Svc_Type_Code_EI__c
                                            ];
                }
                else{ //Else select All
                    listSiteServAgreement = [SELECT Id, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, SAID_EI__c, Svc_Type_Code_EI__c,
                                             Svc_Status_Code_EI__c, CARE_DISCOUNT_TYPE__c, Rate_Schedule_EI__c, Svc_Full_Adr_EI__c,
                                             Person_ID_EI__c, Account_EI__r.Id, Account_EI__r.CARE_ON_PROBATION__c, Site_Premise_ID_EI__c, Res_Ind_EI__c,
                                             Account_EI__r.Email_adr_EI__c , (SELECT Id, CARE_Facility_Name__c, Facility_Name__c, FACILITY_TYPE__c, TRANS_TYPE__c FROM CARE_Facility_Enrolled_SA__r where TRANS_TYPE__c !='DR')
                                             FROM EI_Site__c 
                                             WHERE Person_ID_EI__c =:sPerId
                                             AND Account_EI__r.Id != NULL
                                            // AND Id IN (SELECT CARE_Site__c FROM CARE_Facility_Enrolled_SA__c where TRANS_TYPE__c !='DR')
                                             ORDER BY Person_ID_EI__c, Site_Premise_ID_EI__c, Svc_Type_Code_EI__c
                                            ];
                }
            }
            else{ //Step 2: If any other field is chosen along with Account Id, do a search with all the related fields entered by the user
                Date todayDate = Date.Today();
                soqlWhereClause = populateWhereClauseForSearch(searchDetails);
                string sFacilitySearchWhere = populateWhereClauseForFacilitySearch(searchDetails);
                System.debug('soqlWhereClause==>' + soqlWhereClause );
                System.debug('sFacilitySearchWhere==>' + sFacilitySearchWhere );
                if ((soqlWhereClause != null && soqlWhereClause != '')){
                    
                    if(soqlWhereClause.startsWithIgnoreCase(' AND') ){
                       // soqlWhereClause = soqlWhereClause.replaceFirst(' AND', ''); //remove and from beginning commentted due added account id check
                        soqlSearchQuery = 'SELECT Id, Imported_Site_Name_EI__c, Billing_Account_ID_EI__c, SAID_EI__c, Svc_Type_Code_EI__c,'
                            + ' Svc_Status_Code_EI__c, CARE_DISCOUNT_TYPE__c, Rate_Schedule_EI__c, Svc_Full_Adr_EI__c,'
                            + ' Person_ID_EI__c, Site_Premise_ID_EI__c, Res_Ind_EI__c, Account_EI__r.CARE_ON_PROBATION__c, Account_EI__r.Id, Account_EI__r.CARE_PROBATION_START_DATE__c, Account_EI__r.CARE_PROBATION_END_DATE__c, Account_EI__r.Email_adr_EI__c,'
                            +' (SELECT Id, CARE_Facility_Name__c, Facility_Name__c, FACILITY_TYPE__c, TRANS_TYPE__c FROM CARE_Facility_Enrolled_SA__r '
                            + 'where TRANS_TYPE__c !=\'DR\' ' + sFacilitySearchWhere + ')'
                            + ' FROM EI_Site__c WHERE Account_EI__r.Id != NULL ' + soqlWhereClause  + ' ORDER BY Person_ID_EI__c, Site_Premise_ID_EI__c, Svc_Type_Code_EI__c LIMIT 10000';
                        
                        System.debug('soqlSearchQuery==>' + soqlSearchQuery );
                        listSiteServAgreement = Database.query(soqlSearchQuery);
                        System.debug('listSiteServAgreement---> '+listSiteServAgreement);
                    }
                }                
            }
            List<CustomerWrapper> listTempCustomerWrapper = new List<CustomerWrapper>();
            for(EI_Site__c listEISite :listSiteServAgreement){
                CustomerWrapper custWrapper = getDisplaySearchResultRow(listEISite);
                listTempCustomerWrapper.add(custWrapper);
            }
            for(CustomerWrapper custWrapper :listTempCustomerWrapper){
                //put the wrapper in the response list
                searchResponse.listCustomers.add(custWrapper);
                searchResponse.success = true;
                system.debug('custWrapper==>'+custWrapper);
            }
            
      /*      if(searchDetails.bProbation != null && !searchDetails.bProbation){
                for(CustomerWrapper custWrapper :listTempCustomerWrapper){
                    //put the wrapper in the response list
                    searchResponse.listCustomers.add(custWrapper);
                    searchResponse.success = true;
                    system.debug('custWrapper==>'+custWrapper);
                }
            }else{
                //Performed Mutiple For loop to avoid multiple check for probabtion of person id  
                Set<String> listPersonId = new Set<String>();
                List<String> listAllProbPersonId = new List<String>();  
                for(CustomerWrapper custWrapper :listTempCustomerWrapper){
                    listPersonId.add(custWrapper.sPerId); // to get unique personid
                }
                
                for(String sPerIdTemp :listPersonId){
                    if(CARE_UtilityController.checkCustomerOnProbation (sPerIdTemp)){
                        listAllProbPersonId.add(sPerIdTemp); // identified person under probabtion 
                    }
                }
                
                for(CustomerWrapper custWrapper :listTempCustomerWrapper){
                    if(listAllProbPersonId.contains(custWrapper.sPerId)){
                        //put the wrapper in the response list
                        searchResponse.listCustomers.add(custWrapper);
                        searchResponse.success = true;
                        system.debug('custWrapper==>'+custWrapper);
                    } 
                }
            }
           */  

            
        }
        catch(Exception ex){
            //system.debug('ex==>' +ex);
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
        return searchResponse;
    }
 
    //This method is used to populate Facility Housing Org picklist
    @AuraEnabled(Cacheable = true)
    public static FacilityHousingWrapper getFacilityHousingOrg(Boolean bResCustomerTab){ 
        FacilityHousingWrapper response = new FacilityHousingWrapper();
        try{
            List<CARE_Facility__c> listCareFacility = [select Id, FACILITY_ID__c, FACILITY_TYPE__c, FACILITY_NAME__c
                                                       from CARE_Facility__c
                                                       ORDER BY FACILITY_NAME__c ASC];
            
            for(CARE_Facility__c careFacility : listCareFacility){
                GroupFacilityWrapper objAllFacilityWrapper = new GroupFacilityWrapper();
                objAllFacilityWrapper.sId            = careFacility.Id;
                objAllFacilityWrapper.sFacilityId  = Integer.valueOf(careFacility.FACILITY_ID__c);     
                objAllFacilityWrapper.sFacilityType  = careFacility.FACILITY_TYPE__c; 
                objAllFacilityWrapper.sFacilityName  = careFacility.FACILITY_NAME__c;             
                
                response.listAllFacility.add(objAllFacilityWrapper);      
                
                if(careFacility.FACILITY_TYPE__c == 'NP'){
                    GroupFacilityWrapper objNPFacilityWrapper = new GroupFacilityWrapper();
                    objNPFacilityWrapper.sId            = careFacility.Id;
                    objNPFacilityWrapper.sFacilityId  = Integer.valueOf(careFacility.FACILITY_ID__c);     
                    objNPFacilityWrapper.sFacilityType  = careFacility.FACILITY_TYPE__c; 
                    objNPFacilityWrapper.sFacilityName  = careFacility.FACILITY_NAME__c;             
                    
                    response.listNPFacility.add(objNPFacilityWrapper);      
                }
                else if(careFacility.FACILITY_TYPE__c == 'AG'){
                    GroupFacilityWrapper objAGRFacilityWrapper = new GroupFacilityWrapper();
                    objAGRFacilityWrapper.sId            = careFacility.Id;
                    objAGRFacilityWrapper.sFacilityId  = Integer.valueOf(careFacility.FACILITY_ID__c);     
                    objAGRFacilityWrapper.sFacilityType  = careFacility.FACILITY_TYPE__c; 
                    objAGRFacilityWrapper.sFacilityName  = careFacility.FACILITY_NAME__c;             
                    
                    response.listAGRFacility.add(objAGRFacilityWrapper);      
                }
                else if(careFacility.FACILITY_TYPE__c == 'MF'){
                    GroupFacilityWrapper objMFHCFacilityWrapper = new GroupFacilityWrapper();
                    objMFHCFacilityWrapper.sId            = careFacility.Id;
                    objMFHCFacilityWrapper.sFacilityId  = Integer.valueOf(careFacility.FACILITY_ID__c);     
                    objMFHCFacilityWrapper.sFacilityType  = careFacility.FACILITY_TYPE__c; 
                    objMFHCFacilityWrapper.sFacilityName  = careFacility.FACILITY_NAME__c;             
                    
                    response.listMFHCFacility.add(objMFHCFacilityWrapper);      
                }
                else if(careFacility.FACILITY_TYPE__c == 'SM'){
                    GroupFacilityWrapper objSMFacilityWrapper = new GroupFacilityWrapper();
                    objSMFacilityWrapper.sId            = careFacility.Id;
                    objSMFacilityWrapper.sFacilityId  = Integer.valueOf(careFacility.FACILITY_ID__c);     
                    objSMFacilityWrapper.sFacilityType  = careFacility.FACILITY_TYPE__c; 
                    objSMFacilityWrapper.sFacilityName  = careFacility.FACILITY_NAME__c;             
                    
                    response.listSMFacility.add(objSMFacilityWrapper);      
                }
            } 
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_PEVHU_CONTROLLER, '', '', '', ex);
            
            //throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
        return response;        
    }
  
    /*********************************PUBLIC METHODS*********************************************************/
    
    /*********************************PRIVATE METHODS*********************************************************/  
    
    private Static String populateWhereClauseForFacilitySearch(SearchWrapperRequest searchDetails){        
        system.debug('searchDetails@@@' + searchDetails);
        String soqlWhereClause ='';
        String inQuery = '';
        List<String> listFacilityType = new List<String>();

        if(searchDetails.sFacilityHousingOrgVal != null && searchDetails.sFacilityHousingOrgVal.trim() != ''){
            soqlWhereClause += ' AND Facility_Name__c = \''+ searchDetails.sFacilityHousingOrgVal.trim() + '\''; 
        }
        if(searchDetails.bNPFacilityType != null && searchDetails.bNPFacilityType){
            listFacilityType.add('NP'); 
        }
        if(searchDetails.bAGRFacilityType != null && searchDetails.bAGRFacilityType){
            listFacilityType.add('AG'); 
        }
        if(searchDetails.bMFHCFacilityType != null && searchDetails.bMFHCFacilityType){
            listFacilityType.add('MF'); 
        }
        if(searchDetails.bSMFacilityType != null && searchDetails.bSMFacilityType){
            listFacilityType.add('SM'); 
        }
        if(listFacilityType.size() > 0){
             inQuery = string.join(listFacilityType, ',');
             string finalString = inQuery.replace(',', '\'' + ',' + '\''); 
             soqlWhereClause += ' AND FACILITY_TYPE__c IN (\'' + finalString + '\')';
        }
        return soqlWhereClause;        
             
    }
    
    private Static String populateWhereClauseForSearch(SearchWrapperRequest searchDetails){        
        String soqlWhereClause ='';        
        
        if(searchDetails.sAccountID != null && searchDetails.sAccountID.trim() != ''){
            soqlWhereClause += ' AND Billing_Account_ID_EI__c = \''+ searchDetails.sAccountID.trim().leftPad(10, '0') + '\''; 
        }        
        if(searchDetails.sPersonID != null && searchDetails.sPersonID.trim() != ''){
            soqlWhereClause += ' AND Person_ID_EI__c = \''+ searchDetails.sPersonID.trim().leftPad(10, '0') + '\''; 
        }        
        if(searchDetails.sPremiseID != null && searchDetails.sPremiseID.trim() != ''){
            soqlWhereClause += ' AND Site_Premise_ID_EI__c = \''+ searchDetails.sPremiseID.trim().leftPad(10, '0') + '\''; 
        }    
        if(searchDetails.sSAID != null && searchDetails.sSAID.trim() != ''){
            soqlWhereClause += ' AND SAID_EI__c = \''+ searchDetails.sSAID.trim().leftPad(10, '0') + '\''; 
        }
        if(searchDetails.sName != null && searchDetails.sName.trim() != ''){
            soqlWhereClause += ' AND Imported_Site_Name_EI__c = \''+ searchDetails.sName + '\'';  //TBD: use wildcard serach, decision is to use exact serach
        }        
        if(searchDetails.sPhone != null && searchDetails.sPhone.trim() != ''){
            soqlWhereClause += ' AND Phone_1_EI__c = \''+ searchDetails.sPhone + '\''; 
        }        
        if(searchDetails.sStreet != null && searchDetails.sStreet.trim() != ''){
            String sStreet = '\'' + String.escapeSingleQuotes(searchDetails.sStreet) + '%\'';
            soqlWhereClause += ' AND Svc_Full_Adr_EI__c LIKE ' + sStreet; // use wildcard serach
        }        
        if(searchDetails.sCity != null && searchDetails.sCity.trim() != ''){
            soqlWhereClause += ' AND City_EI__c = \''+ searchDetails.sCity + '\''; 
        }        
        if(searchDetails.sZip != null && searchDetails.sZip.trim() != ''){
            soqlWhereClause += ' AND Zip_Code_EI__c = \''+ searchDetails.sZip + '\''; 
        }        
        if(searchDetails.bInactiveCustomer != null && !searchDetails.bInactiveCustomer){
            //List<String> listStatus = new List<String>{'10', '20'}; //TBD: put in constant class
            List<String> listStatus = CARE_UtilityController.getCareActiveStatusCode();
            String sStatusStr = '' ;
            for(String st : listStatus){
                sStatusStr += '\'' + st + '\',';                
            }    
            sStatusStr = sStatusStr.lastIndexOf(',') > 0 ? '(' + sStatusStr.substring(0,sStatusStr.lastIndexOf(',')) + ')' : sStatusStr ;
            soqlWhereClause += ' AND Svc_Status_Code_EI__c IN ' + sStatusStr; 
        }
       /* if(searchDetails.bProbation != null && searchDetails.bProbation){
            soqlWhereClause += ' AND Account_EI__r.CARE_PROBATION_START_DATE__c <= :todayDate AND Account_EI__r.CARE_PROBATION_END_DATE__c >= :todayDate'; 
        }
       */
        
        //TBD
        //MFHC, Enrolled Tenant, facility/housing, probation
        string sFacilitySearchWhere = populateWhereClauseForFacilitySearch(searchDetails);
        if((sFacilitySearchWhere != null && sFacilitySearchWhere != '')){
            soqlWhereClause += ' AND Id IN (SELECT CARE_Site__c FROM CARE_Facility_Enrolled_SA__c where TRANS_TYPE__c !=\'DR\' ' + sFacilitySearchWhere + ')';
        }
                   
        
        return soqlWhereClause;        
    }
    
    private Static void setSearchedKeySession(String sSearchedKey, String sMapKeyName ){
        
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CareSessionCache');
            system.debug('sessionPart==>'+sessionPart);
            if (sessionPart.contains('CareSearchedSessionData')) {
                Map<String,List<String>> mapSearchedSessionTemp  = (Map<String,List<String>>)sessionPart.get('CareSearchedSessionData');
                system.debug('mapSearchedSessionTemp==>'+mapSearchedSessionTemp);
                if(!mapSearchedSessionTemp.get(sMapKeyName).contains(sSearchedKey)){
                    
                    if(mapSearchedSessionTemp.get(sMapKeyName).size() == 5){
                        mapSearchedSessionTemp.get(sMapKeyName).remove(0);
                    }
                    mapSearchedSessionTemp.get(sMapKeyName).add(sSearchedKey);
                    
                }
                sessionPart.put('CareSearchedSessionData', mapSearchedSessionTemp);
            }else{
                Map<String,List<String>> mapSearchedSessionTemp = new Map<String,List<String>>{'AccountId' => new List<String>(), 'PersonId' => new List<String>(), 'SAId' => new List<String>(), 'PremiseId' => new List<String>()};
                    mapSearchedSessionTemp.get(sMapKeyName).add(sSearchedKey);
                system.debug('mapSearchedSessionTempSetElse==>'+mapSearchedSessionTemp);
                sessionPart.put('CareSearchedSessionData', mapSearchedSessionTemp);
            }
        }
        catch(Exception ex){
            system.debug('session ex==>' +ex);
            //throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
        
        
        
    }
    
    private Static List<String> getSearchedKeySession(String sMapKeyName ){
        List<String> listResult = new List<String>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CareSessionCache');
        if (sessionPart.contains('CareSearchedSessionData')) {
            Map<String,List<String>> mapSearchedSessionTemp  = (Map<String,List<String>>)sessionPart.get('CareSearchedSessionData');
            system.debug('mapSearchedSessionTempGet==>'+mapSearchedSessionTemp);
            if(mapSearchedSessionTemp.get(sMapKeyName).size() > 0){
                listResult = mapSearchedSessionTemp.get(sMapKeyName);
            }
        }
        return listResult;
    } 
    
    private Static CustomerWrapper getDisplaySearchResultRow(EI_Site__c listEISite){
        CustomerWrapper custWrapper = new CustomerWrapper();
        List<CARE_Facility_Enrolled_SA__c> listFacilityEnrolledSA = listEISite.CARE_Facility_Enrolled_SA__r;
        system.debug('listFacilityEnrolledSA@@' + listFacilityEnrolledSA);
        if(listFacilityEnrolledSA.size() > 0){
           //custWrapper.sFHType = (listFacilityEnrolledSA[0].FACILITY_TYPE__c != null) ? listFacilityEnrolledSA[0].FACILITY_TYPE__c : '';
           custWrapper.sFHType = (listFacilityEnrolledSA[0].FACILITY_TYPE__c != null) ? listFacilityEnrolledSA[0].FACILITY_TYPE__c : '';
           custWrapper.sFacilityName = (listFacilityEnrolledSA[0].Facility_Name__c != null) ? listFacilityEnrolledSA[0].Facility_Name__c : '';
           custWrapper.sFacilityId = (listFacilityEnrolledSA[0].CARE_Facility_Name__c != null) ? listFacilityEnrolledSA[0].CARE_Facility_Name__c : '';
        }
        custWrapper.idcustId = (listEISite.Id != null) ? listEISite.Id : '';
        custWrapper.sCustName = (listEISite.Imported_Site_Name_EI__c != null) ? listEISite.Imported_Site_Name_EI__c : '';
        custWrapper.sResNonRes = (listEISite.Res_Ind_EI__c == 'Y') ? 'Res' : 'Non Res';
        
        custWrapper.sAccId = (listEISite.Billing_Account_ID_EI__c != null) ? listEISite.Billing_Account_ID_EI__c : '';
        custWrapper.sSAId = (listEISite.SAID_EI__c != null) ? listEISite.SAID_EI__c : '';
        custWrapper.sSAType = (listEISite.Svc_Type_Code_EI__c != null) ? listEISite.Svc_Type_Code_EI__c : '';
        custWrapper.sSAStatus = (listEISite.Svc_Status_Code_EI__c != null) ? listEISite.Svc_Status_Code_EI__c : '';
        custWrapper.sDiscount = (listEISite.CARE_DISCOUNT_TYPE__c != null) ? listEISite.CARE_DISCOUNT_TYPE__c : '';
        custWrapper.sRate = (listEISite.Rate_Schedule_EI__c != null) ? listEISite.Rate_Schedule_EI__c : '';
        custWrapper.sSvcAddr = (listEISite.Svc_Full_Adr_EI__c != null) ? listEISite.Svc_Full_Adr_EI__c : '';
        //custWrapper.sSpaceUnit = (listEISite.Imported_Site_Name_EI__c != null) ? listEISite.Imported_Site_Name_EI__c : ''; //TBD
        custWrapper.sPerId = (listEISite.Person_ID_EI__c != null) ? listEISite.Person_ID_EI__c : '';
        custWrapper.sPremId = (listEISite.Site_Premise_ID_EI__c != null) ? listEISite.Site_Premise_ID_EI__c : '';
        custWrapper.sEIAccountId = (listEISite.Account_EI__r.Id != null) ? listEISite.Account_EI__r.Id : ''; 
        custWrapper.sProbation = (listEISite.Account_EI__r.CARE_ON_PROBATION__c) ? 'Y' : 'N'; 
        custWrapper.sEIAccountEmail = (listEISite.Account_EI__r.Email_adr_EI__c != null) ? listEISite.Account_EI__r.Email_adr_EI__c : '';
        
        ///DEL
        custWrapper.sCustomSAId = (listEISite.SAID_EI__c != null) ? listEISite.SAID_EI__c + ' (' + listEISite.Svc_Type_Code_EI__c + ')' + ','+'6767676787 (G)': '';
        custWrapper.sCustomAcctId = (listEISite.Billing_Account_ID_EI__c != null) ? listEISite.Billing_Account_ID_EI__c + ','+'8800000000': '';
        
        
        return custWrapper;
    }    
    
    
    
    
    /*********************************PRIVATE METHODS*********************************************************/
    
}