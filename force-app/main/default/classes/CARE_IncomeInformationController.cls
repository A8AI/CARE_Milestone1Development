/**************************************************************************************************************************************   
Apex Util class Name :  CARE_IncomeInformationController
Version              :  1.0                                                                          
Created Date         :  06/29/2020                                                         
Function             :  This is the Apex Controller for Income Information for Individual Household members.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/29/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_IncomeInformationController {
    //constant
    Private Static final Date dTodaysDate = Date.today();
    
    //Wrapper class for Income Information response
    public class WrapperIncomeInformation{ 
        @AuraEnabled
        public List<WrapperHouseholdIncome>listHouseholdIncome {get;set;}
        @AuraEnabled
        Public Decimal dMemberAnnualSalary {get;set;} 
        @AuraEnabled
        public List<WrapperIncomeSource> listIncomeSource {get;set;} 
        
        public WrapperIncomeInformation(){
            listHouseholdIncome = new List<WrapperHouseholdIncome>();
            dMemberAnnualSalary = null;
            listIncomeSource = new List<WrapperIncomeSource>(); 
        }
    }
    //Wrapper class for Household income
    public class WrapperHouseholdIncome{
        @AuraEnabled
        public String idHouseholdMember {get;set;}
        @AuraEnabled
        public String sIncomeSource {get;set;}
        @AuraEnabled
        public String sDocumentType {get;set;}
        @AuraEnabled 
        public String sFormType {get;set;}
        @AuraEnabled
        public Decimal dEstAnnualSalary {get;set;}
        @AuraEnabled
        public String sIncomeStatus {get;set;}
        @AuraEnabled
        public Decimal dDiscountLength {get;set;}
    }
    //Wrapper class for Income Source
    public class WrapperIncomeSource{
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value {get;set;}
    }
    //Wrapper class for Income Document Type
    public class WrapperIncomeDocument{ 
        @AuraEnabled 
        public List<WrapperIncomeSource> listIncomeDocument {get;set;} 
        public WrapperIncomeDocument(){
            listIncomeDocument = new List<WrapperIncomeSource>(); 
        }
    }
    //Wrapper class for Income Form Type
    public class WrapperIncomeForm{
        @AuraEnabled 
        public String sFormType {get;set;}
        @AuraEnabled 
        public String sDocTypeName{get;set;}
        @AuraEnabled 
        public String sSourceTypeName {get;set;}
        @AuraEnabled 
        public Decimal dDiscountLength {get;set;}
        public WrapperIncomeForm(){
            sFormType = '';
            sDocTypeName = '';
            sSourceTypeName = '';
            dDiscountLength = null;
        }
    }
    //Wrapper class for input Selected from UI for Form Selection
    public class WrapperIncomeInput{
        @AuraEnabled public String sIncomeSource{get;set;}
        @AuraEnabled public String sDocumentType{get;set;}
    }
    //Wrapper class for input Selected from Selected Form
    public class WrapperFormInput{
        @AuraEnabled public Id idCareApp{get;set;}
        @AuraEnabled public Id idCareHouseholdDetail{get;set;}
        @AuraEnabled public Id idCareHouseholdmemberIncome{get;set;}
        @AuraEnabled public Decimal dDiscountLength{get;set;}
        @AuraEnabled public String sIncomeSourceType{get;set;}
        @AuraEnabled public String sDocumentType{get;set;}
        @AuraEnabled public String sFormType{get;set;}
        @AuraEnabled public String sIncomeSourceStatus{get;set;}
        @AuraEnabled public Boolean bIsCategorical{get;set;}
        @AuraEnabled public Boolean bIsValidDoc{get;set;}
        @AuraEnabled public Boolean bIsFillingJointly{get;set;}
        @AuraEnabled public Boolean bRollover{get;set;}
        @AuraEnabled public Boolean bIsSchedule1{get;set;}
        @AuraEnabled public Boolean bSchedule1DocValid{get;set;}
        @AuraEnabled public Boolean bScheduleCDocComplete{get;set;}
        @AuraEnabled public Integer iMonthNo{get;set;}
        @AuraEnabled public String sPeriodType{get;set;}   
        @AuraEnabled public Decimal dAmount1{get;set;}  
        @AuraEnabled public Decimal dAmount2{get;set;}  
        @AuraEnabled public Decimal dAmount3{get;set;}  
        @AuraEnabled public Decimal dAmount4{get;set;}  
        @AuraEnabled public Decimal dAmount5{get;set;}  
        @AuraEnabled public Decimal dAmount6{get;set;} 
        @AuraEnabled public Decimal dAmount7{get;set;}  
        @AuraEnabled public Decimal dAmount8{get;set;}  
        @AuraEnabled public Decimal dAmount9{get;set;}  
        @AuraEnabled public Decimal dTotalAmount{get;set;}  
        @AuraEnabled public Decimal dLine1{get;set;}
        @AuraEnabled public Decimal dLine1Adjusted{get;set;}
        @AuraEnabled public Decimal dLine2{get;set;}
        @AuraEnabled public Decimal dLine2Adjusted{get;set;}
        //@AuraEnabled public Decimal dLine2a{get;set;}
        //@AuraEnabled public Decimal dLine2aAdjusted{get;set;}
        @AuraEnabled public Decimal dLine2b{get;set;}
        @AuraEnabled public Decimal dLine2bAdjusted{get;set;}
        @AuraEnabled public Decimal dLine3{get;set;}
        @AuraEnabled public Decimal dLine3Adjusted{get;set;}
        @AuraEnabled public Decimal dLine3b{get;set;}
        @AuraEnabled public Decimal dLine3bAdjusted{get;set;}
        //@AuraEnabled public Decimal dLine4{get;set;}
        //@AuraEnabled public Decimal dLine4Adjusted{get;set;}
        @AuraEnabled public Decimal dLine4a{get;set;}
        @AuraEnabled public Decimal dLine4aAdjusted{get;set;}
        @AuraEnabled public Decimal dLine4c{get;set;}
        @AuraEnabled public Decimal dLine4cAdjusted{get;set;}
        @AuraEnabled public Decimal dLine5{get;set;}
        @AuraEnabled public Decimal dLine5Adjusted{get;set;}
        @AuraEnabled public Decimal dLine5a{get;set;}
        @AuraEnabled public Decimal dLine5aAdjusted{get;set;}
        @AuraEnabled public Decimal dLine6{get;set;}
        @AuraEnabled public Decimal dLine6Adjusted{get;set;}
        @AuraEnabled public Decimal dLine7Adjusted{get;set;}
        //@AuraEnabled public Decimal dLine8{get;set;}
        //@AuraEnabled public Decimal dLine8Adjusted{get;set;}
        //@AuraEnabled public Decimal dLine9Adjusted{get;set;}
        @AuraEnabled public Decimal dLine11{get;set;}
        @AuraEnabled public Decimal dLine11Adjusted{get;set;}
        @AuraEnabled public Decimal dLine12{get;set;}
        @AuraEnabled public Decimal dLine12Adjusted{get;set;}
        @AuraEnabled public Decimal dLine13{get;set;}
        @AuraEnabled public Decimal dLine13Adjusted{get;set;}
        @AuraEnabled public Decimal dLine14{get;set;}
        @AuraEnabled public Decimal dLine14Adjusted{get;set;}
        @AuraEnabled public Decimal dLine17{get;set;}
        @AuraEnabled public Decimal dLine17Adjusted{get;set;}
        @AuraEnabled public Decimal dLine18{get;set;}
        @AuraEnabled public Decimal dLine18Adjusted{get;set;}
        @AuraEnabled public Decimal dLine19{get;set;}
        @AuraEnabled public Decimal dLine19Adjusted{get;set;}
        @AuraEnabled public Decimal dLine21{get;set;}
        @AuraEnabled public Decimal dLine21Adjusted{get;set;}
        @AuraEnabled public Decimal dLine22Adjusted{get;set;}
        @AuraEnabled
        public List<WrapperHouseholdMemberIncomeC>listHouseholdMemberIncomeC {get;set;}
        
        public WrapperFormInput(){
            listHouseholdMemberIncomeC = new List <WrapperHouseholdMemberIncomeC >();
        }
    }
    //Wrapper class for HouseHoldMember IncomeC
    public class WrapperHouseholdMemberIncomeC{
        
        @AuraEnabled public Decimal dLine3{get;set;}
        @AuraEnabled public Decimal dLine29{get;set;}
        @AuraEnabled public Decimal dLine31{get;set;}
        @AuraEnabled public String sId{get;set;}
        @AuraEnabled public String sNumber{get;set;}
        @AuraEnabled public Integer iScheduleCIndex{get;set;}
        
    }
    
    
    //method to get the CARE app Income Source Details
    @AuraEnabled(Cacheable = true)
    public static WrapperIncomeInformation getPersonIncomeInformation (Id idHouseholdDetail ,Id idCareApplication, String sApplicationType){
        WrapperIncomeInformation incomeInformationResponse = new  WrapperIncomeInformation();
        
        try{
            
            //get the income details based on household member
            List<CARE_Household_Member_Income__c> listHouseholdMemberIncome = [SELECT Id, INCOME_DOC_TYPE__c, INCOME_SOURCE_TYPE__c,
                                                                               INCOME_FORM_TYPE__c, EST_SALARY__c,INCOME_SOURCE_STATUS__c,
                                                                               HOUSEHOLDDETAIL__r.EST_ANNUAL_SALARY__c, DISCOUNT_LENGTH_IN_DAYS__c 
                                                                               FROM CARE_Household_Member_Income__c
                                                                               WHERE HOUSEHOLDDETAIL__c = : idHouseholdDetail
                                                                               AND HOUSEHOLDDETAIL__r.APPLICATION__C = :idCareApplication];
            
            if(listHouseholdMemberIncome!=null && listHouseholdMemberIncome.size() > 0){
                for(CARE_Household_Member_Income__c householdRec :listHouseholdMemberIncome){
                    WrapperHouseholdIncome objHouseholdIncome = new WrapperHouseholdIncome();
                    objHouseholdIncome.idHouseholdMember = householdRec.Id;
                    objHouseholdIncome.sIncomeSource = householdRec.INCOME_SOURCE_TYPE__c;
                    objHouseholdIncome.sDocumentType = householdRec.INCOME_DOC_TYPE__c;
                    objHouseholdIncome.dEstAnnualSalary = householdRec.EST_SALARY__c;
                    objHouseholdIncome.sIncomeStatus  = householdRec.INCOME_SOURCE_STATUS__c;
                    objHouseholdIncome.sFormType = householdRec.INCOME_FORM_TYPE__c;
                    objHouseholdIncome.dDiscountLength = householdRec.DISCOUNT_LENGTH_IN_DAYS__c;                
                    
                    incomeInformationResponse.listHouseholdIncome.add(objHouseholdIncome);
                }
                
                //get the total income
                incomeInformationResponse.dMemberAnnualSalary = (listHouseholdMemberIncome[0].HOUSEHOLDDETAIL__r.EST_ANNUAL_SALARY__c != null) ? 
                    //Integer.valueOf(listHouseholdMemberIncome[0].HOUSEHOLDDETAIL__r.EST_ANNUAL_SALARY__c) : 0;
                     listHouseholdMemberIncome[0].HOUSEHOLDDETAIL__r.EST_ANNUAL_SALARY__c : 0;
            }
            //get the income source details
            List<CARE_Income_Sources__c>listCareIncomeSource = new List<CARE_Income_Sources__c>();
            
            if(sApplicationType == CARE_Constants.CARE_APP_PEV){
                listCareIncomeSource = [SELECT Id, Name, Source_No__c  
                                        FROM CARE_Income_Sources__c
                                        WHERE START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate
                                        AND Name NOT IN :CARE_Constants.CARE_PEV_HU_INCOME_SOURCE ORDER BY Name ASC];
            }
            else if(sApplicationType == CARE_Constants.CARE_APP_HU){
                listCareIncomeSource = [SELECT Id, Name, Source_No__c  
                                        FROM CARE_Income_Sources__c
                                        WHERE START_DATE__c <:dTodaysDate AND END_DATE__c >:dTodaysDate
                                        AND Name IN :CARE_Constants.CARE_PEV_HU_INCOME_SOURCE];
            }
            
            for (CARE_Income_Sources__c incomeDocRec :listCareIncomeSource ){
                
                WrapperIncomeSource objIncomeSource = new WrapperIncomeSource ();
                
                objIncomeSource.label = incomeDocRec.Name;
                objIncomeSource.value = incomeDocRec.Name ;
                
                incomeInformationResponse.listIncomeSource.add(objIncomeSource);
                
            }
            
        }
        catch (exception ex){   
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return incomeInformationResponse;     
    }        
    
    //method to get the CARE app Income Document details based on selected Income source in UI
    @AuraEnabled
    public static WrapperIncomeDocument getIncomeDocumentType(WrapperIncomeInput objIncomeInput){
        
        WrapperIncomeDocument incomeInformationResponse = new  WrapperIncomeDocument();
        try{
            List<CARE_INCOME_SOURCE_DOC__c>listCareIncomeDoc = [ SELECT Id, DOC_TYPE_NO__r.Name , DOC_TYPE_NO__r.Doc_Type_No__c 
                                                                FROM CARE_INCOME_SOURCE_DOC__c
                                                                WHERE Source_No__r.Name =:objIncomeInput.sIncomeSource  
                                                                AND DOC_TYPE_NO__r.START_DATE__c <:dTodaysDate 
                                                                AND DOC_TYPE_NO__r.END_DATE__c >:dTodaysDate
                                                                ORDER BY DOC_TYPE_NO__r.Name ASC];
            
            for(CARE_INCOME_SOURCE_DOC__c incomeSourceRec :listCareIncomeDoc ){
                WrapperIncomeSource objIncomeDocument = new WrapperIncomeSource ();
                objIncomeDocument.label = incomeSourceRec.DOC_TYPE_NO__r.Name;
                objIncomeDocument.value = incomeSourceRec.DOC_TYPE_NO__r.Name ;
                incomeInformationResponse.listIncomeDocument.add(objIncomeDocument);
            }
            
        }
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return incomeInformationResponse;
    }
    
    //method to get the CARE app Income Form type details based on selected Income source & Document Type in UI
    @AuraEnabled
    public static WrapperIncomeForm getIncomeFormType(WrapperIncomeInput objIncomeInput){
        
        WrapperIncomeForm incomeFormResponse = new  WrapperIncomeForm();         
        try{
            
            List<CARE_INCOME_SOURCE_DOC__c> listCareIncomeForm = [SELECT Form_Type_No__r.Name, DOC_TYPE_NO__r.Name,
                                                                  SOURCE_NO__r.Name, DISCOUNT_LENGTH_IN_DAYS__c 
                                                                  FROM CARE_INCOME_SOURCE_DOC__c
                                                                  WHERE Source_No__r.Name =:objIncomeInput.sIncomeSource    
                                                                  AND DOC_TYPE_NO__r.Name =:objIncomeInput.sDocumentType LIMIT 1];
            
            if(listCareIncomeForm.size()>0){
                for(CARE_INCOME_SOURCE_DOC__c incomeFormRec :listCareIncomeForm ){
                    incomeFormResponse.sFormType = incomeFormRec.FORM_TYPE_NO__r.Name;
                    incomeFormResponse.sDocTypeName = incomeFormRec.DOC_TYPE_NO__r.Name;
                    incomeFormResponse.sSourceTypeName = incomeFormRec.SOURCE_NO__r.Name ;
                    incomeFormResponse.dDiscountLength = incomeFormRec.DISCOUNT_LENGTH_IN_DAYS__c;
                }            
            }
            
            else{                
                return null;
            }
            
        }
        catch (exception ex){    
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return incomeFormResponse;
    }
    
    //method to get the income form submitted details based on the view button
    @AuraEnabled(Cacheable = true)
    public static WrapperFormInput getHouseMemberIncomeDetails(Id  IdCareHouseholdmemberIncome){
        
        WrapperFormInput objWrapperFormInput = new WrapperFormInput();
        try{                      
            List<CARE_Household_Member_Income__c> listHouseholdIncome =[SELECT ID, CARE_Application__c, HOUSEHOLDDETAIL__c, DISCOUNT_LENGTH_IN_DAYS__c, 
                                                                        INCOME_SOURCE_TYPE__c,INCOME_DOC_TYPE__c, INCOME_FORM_TYPE__c, IS_CATEGORICAL__c, 
                                                                        IS_DOC_VALID__c,IS_FILING_JOINTLY__c, NO_MONTHS__c, PERIOD_TYPE__c,ROLLOVER__c,                                                                          
                                                                        SCHEDULE_1__c, SCHEDULE_1_VALID__c, Document_Complete__c, 
                                                                        AMOUNT1__c, AMOUNT2__c,
                                                                        Amount_3__c, Amount_4__c, Amount_5__c, Amount_6__c,Amount_7__c, Amount_8__c, Amount_9__c,
                                                                        LINE_1__c, ADJ_1__c, LINE_2__c, ADJ_2__c, LINE_2B__c, ADJ_2B__c, 
                                                                        LINE_3__c, Adj_3__c, LINE_3B__c, ADJ_3B__c, 
                                                                        LINE_4A__c, ADJ_4A__c, Line_4C__c, Adj_4C__c, 
                                                                        LINE_5__c, ADJ_5__c, LINE_5A__c, ADJ_5A__c, LINE_6__c, ADJ_6__c, ADJ_7__c,
                                                                        LINE_11__c, ADJ_11__c, LINE_12__c, ADJ_12__C, LINE_13__c,                                                                         
                                                                        ADJ_13__c, LINE_14__c, ADJ_14__c, LINE_17__c, ADJ_17__c, LINE_18__c, ADJ_18__c, LINE_19__c, 
                                                                        ADJ_19__c, LINE_21__c, ADJ_21__c, ADJ_22__c,
                                                                        EST_SALARY__c  
                                                                        FROM CARE_Household_Member_Income__c 
                                                                        WHERE ID =:IdCareHouseholdmemberIncome];
            if(listHouseholdIncome.size()>0){
                
                for(CARE_Household_Member_Income__c careHouseholdIncomeObj : listHouseholdIncome){
                    
                    objWrapperFormInput.idCareHouseholdDetail = careHouseholdIncomeObj.HOUSEHOLDDETAIL__c ;
                    objWrapperFormInput.dDiscountLength = careHouseholdIncomeObj.DISCOUNT_LENGTH_IN_DAYS__c ;
                    objWrapperFormInput.sIncomeSourceType = careHouseholdIncomeObj.INCOME_SOURCE_TYPE__c  ;
                    objWrapperFormInput.sDocumentType = careHouseholdIncomeObj.INCOME_DOC_TYPE__c  ;
                    objWrapperFormInput.sFormType = careHouseholdIncomeObj.INCOME_FORM_TYPE__c  ;
                    objWrapperFormInput.bIsCategorical = careHouseholdIncomeObj.IS_CATEGORICAL__c  ;
                    objWrapperFormInput.bIsValidDoc = careHouseholdIncomeObj.IS_DOC_VALID__c  ;
                    objWrapperFormInput.bIsFillingJointly = careHouseholdIncomeObj.IS_FILING_JOINTLY__c;
                    objWrapperFormInput.sPeriodType = careHouseholdIncomeObj.PERIOD_TYPE__c;    
                    objWrapperFormInput.iMonthNo = Integer.valueOf (careHouseholdIncomeObj.NO_MONTHS__c ) ;
                    objWrapperFormInput.sPeriodType = careHouseholdIncomeObj.PERIOD_TYPE__c  ;
                    objWrapperFormInput.bRollover = careHouseholdIncomeObj.ROLLOVER__c;
                    objWrapperFormInput.bIsSchedule1 = careHouseholdIncomeObj.SCHEDULE_1__c;
                    objWrapperFormInput.bSchedule1DocValid = careHouseholdIncomeObj.SCHEDULE_1_VALID__c;
                    objWrapperFormInput.bScheduleCDocComplete = careHouseholdIncomeObj.Document_Complete__c;
                    objWrapperFormInput.dAmount1 = careHouseholdIncomeObj.AMOUNT1__c == null?0:careHouseholdIncomeObj.AMOUNT1__c;
                    objWrapperFormInput.dAmount2 = careHouseholdIncomeObj.AMOUNT2__c == null?0:careHouseholdIncomeObj.AMOUNT2__c;
                    objWrapperFormInput.dAmount3 = careHouseholdIncomeObj.Amount_3__c == null?0:careHouseholdIncomeObj.Amount_3__c;
                    objWrapperFormInput.dAmount4 = careHouseholdIncomeObj.Amount_4__c == null?0:careHouseholdIncomeObj.Amount_4__c;
                    objWrapperFormInput.dAmount5 = careHouseholdIncomeObj.Amount_5__c == null?0:careHouseholdIncomeObj.Amount_5__c;
                    objWrapperFormInput.dAmount6 = careHouseholdIncomeObj.Amount_6__c == null?0:careHouseholdIncomeObj.Amount_6__c;
                    objWrapperFormInput.dAmount7 = careHouseholdIncomeObj.Amount_7__c == null?0:careHouseholdIncomeObj.Amount_7__c;
                    objWrapperFormInput.dAmount8 = careHouseholdIncomeObj.Amount_8__c == null?0:careHouseholdIncomeObj.Amount_8__c;
                    objWrapperFormInput.dAmount9 = careHouseholdIncomeObj.Amount_9__c == null?0:careHouseholdIncomeObj.Amount_9__c;
                    
                    objWrapperFormInput.dLine1 = careHouseholdIncomeObj.LINE_1__c == null?0:careHouseholdIncomeObj.LINE_1__c;
                    objWrapperFormInput.dLine1Adjusted = careHouseholdIncomeObj.ADJ_1__c == null?0:careHouseholdIncomeObj.ADJ_1__c;
                    objWrapperFormInput.dLine2 = careHouseholdIncomeObj.LINE_2__c == null?0:careHouseholdIncomeObj.LINE_2__c;
                    objWrapperFormInput.dLine2Adjusted = careHouseholdIncomeObj.ADJ_2__c == null?0:careHouseholdIncomeObj.ADJ_2__c;
                    //objWrapperFormInput.dLine2a = careHouseholdIncomeObj.Line_2A__c == null?0:careHouseholdIncomeObj.Line_2A__c;
                    //objWrapperFormInput.dLine2aAdjusted = careHouseholdIncomeObj.Adj_2A__c == null?0:careHouseholdIncomeObj.Adj_2A__c;
                    objWrapperFormInput.dLine2b = careHouseholdIncomeObj.LINE_2B__c == null?0:careHouseholdIncomeObj.LINE_2B__c;
                    objWrapperFormInput.dLine2bAdjusted = careHouseholdIncomeObj.ADJ_2B__c == null?0:careHouseholdIncomeObj.ADJ_2B__c;
                    objWrapperFormInput.dLine3 = careHouseholdIncomeObj.LINE_3__c == null?0:careHouseholdIncomeObj.LINE_3__c;
                    objWrapperFormInput.dLine3Adjusted = careHouseholdIncomeObj.Adj_3__c == null?0:careHouseholdIncomeObj.Adj_3__c;                    
                    objWrapperFormInput.dLine3b = careHouseholdIncomeObj.LINE_3B__c  == null?0:careHouseholdIncomeObj.LINE_3B__c ;    
                    objWrapperFormInput.dLine3bAdjusted = careHouseholdIncomeObj.ADJ_3B__c  == null?0:careHouseholdIncomeObj.ADJ_3B__c ;
                    //objWrapperFormInput.dLine4 = careHouseholdIncomeObj.LINE_4__c == null?0:careHouseholdIncomeObj.LINE_4__c;
                    //objWrapperFormInput.dLine4Adjusted = careHouseholdIncomeObj.Adj_4__c == null?0:careHouseholdIncomeObj.Adj_4__c;
                    objWrapperFormInput.dLine4a = careHouseholdIncomeObj.LINE_4A__c == null?0:careHouseholdIncomeObj.LINE_4A__c;
                    objWrapperFormInput.dLine4aAdjusted = careHouseholdIncomeObj.ADJ_4A__c == null?0:careHouseholdIncomeObj.ADJ_4A__c;
                    objWrapperFormInput.dLine4c = careHouseholdIncomeObj.Line_4C__c == null?0:careHouseholdIncomeObj.Line_4C__c;
                    objWrapperFormInput.dLine4cAdjusted = careHouseholdIncomeObj.Adj_4C__c == null?0:careHouseholdIncomeObj.Adj_4C__c;
                    objWrapperFormInput.dLine5 = careHouseholdIncomeObj.LINE_5__c == null?0:careHouseholdIncomeObj.LINE_5__c;
                    objWrapperFormInput.dLine5Adjusted = careHouseholdIncomeObj.ADJ_5__c == null?0:careHouseholdIncomeObj.ADJ_5__c ;
                    objWrapperFormInput.dLine5a = careHouseholdIncomeObj.LINE_5A__c == null?0:careHouseholdIncomeObj.LINE_5A__c;
                    objWrapperFormInput.dLine5aAdjusted = careHouseholdIncomeObj.ADJ_5A__c  == null?0:careHouseholdIncomeObj.ADJ_5A__c ;   
                    objWrapperFormInput.dLine6 = careHouseholdIncomeObj.LINE_6__c  == null?0:careHouseholdIncomeObj.LINE_6__c ;
                    objWrapperFormInput.dLine6Adjusted = careHouseholdIncomeObj.ADJ_6__c  == null?0:careHouseholdIncomeObj.ADJ_6__c ;
                    objWrapperFormInput.dLine7Adjusted = careHouseholdIncomeObj.ADJ_7__c  == null?0:careHouseholdIncomeObj.ADJ_7__c;     
                    //objWrapperFormInput.dLine8 = careHouseholdIncomeObj.Line_8__c  == null?0:careHouseholdIncomeObj.Line_8__c;    
                    //objWrapperFormInput.dLine8Adjusted = careHouseholdIncomeObj.Adj_8__c  == null?0:careHouseholdIncomeObj.Adj_8__c;    
                    //objWrapperFormInput.dLine9Adjusted = careHouseholdIncomeObj.Line_9__c  == null?0:careHouseholdIncomeObj.Line_9__c;    
                    objWrapperFormInput.dLine11 = careHouseholdIncomeObj.LINE_11__c == null?0:careHouseholdIncomeObj.LINE_11__c;//Line 11 (IRS 2018)||Line 2a(IRS 2019/IRS 2019)in Schedule 1 section
                    objWrapperFormInput.dLine11Adjusted = careHouseholdIncomeObj.ADJ_11__c == null?0:careHouseholdIncomeObj.ADJ_11__c;//Line 11 Adjusted(IRS 2018)||Line 2a Adjusted(IRS 2019/IRS 2019)in Schedule 1 section
                    objWrapperFormInput.dLine12 = careHouseholdIncomeObj.LINE_12__c  == null?0:careHouseholdIncomeObj.LINE_12__c ;//Line 12 (IRS 2018)||Line 3(Business income)(IRS 2019/IRS 2019)in Schedule 1 
                    objWrapperFormInput.dLine12Adjusted = careHouseholdIncomeObj.ADJ_12__C == null?0:careHouseholdIncomeObj.ADJ_12__C;//Line 12 Adjusted(IRS 2018)||Line 3 Adjusted(Business income)(IRS 2019/IRS 2019)in Schedule 1 
                    objWrapperFormInput.dLine13 = careHouseholdIncomeObj.LINE_13__c  == null?0:careHouseholdIncomeObj.LINE_13__c ; 
                    objWrapperFormInput.dLine13Adjusted = careHouseholdIncomeObj.ADJ_13__c  == null?0:careHouseholdIncomeObj.ADJ_13__c ;
                    objWrapperFormInput.dLine14 = careHouseholdIncomeObj.LINE_14__c == null?0:careHouseholdIncomeObj.LINE_14__c;//Line 13 (IRS 2018)||Line 4(other)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine14Adjusted = careHouseholdIncomeObj.ADJ_14__c  == null?0:careHouseholdIncomeObj.ADJ_14__c ;//Line 13 Adjusted (IRS 2018)||Line 4 Adjusted(other)(IRS 2019/IRS 2019)in Schedule 1                       
                    objWrapperFormInput.dLine17 = careHouseholdIncomeObj.LINE_17__c  == null?0:careHouseholdIncomeObj.LINE_17__c ;//Line 17 (IRS 2018)||Line 5(Rental Income)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine17Adjusted = careHouseholdIncomeObj.ADJ_17__c == null?0:careHouseholdIncomeObj.ADJ_17__c;//Line 17 Adjusted(IRS 2018)||Line 5 Adjusted(Rental Income)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine18 = careHouseholdIncomeObj.LINE_18__c  == null?0:careHouseholdIncomeObj.LINE_18__c ;//Line 18 (IRS 2018)||Line 6 (Farm Income)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine18Adjusted = careHouseholdIncomeObj.ADJ_18__c == null?0:careHouseholdIncomeObj.ADJ_18__c;//Line 18 Adjusted(IRS 2018)||Line 6 Adjusted(Farm Income)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine19 = careHouseholdIncomeObj.LINE_19__c == null?0:careHouseholdIncomeObj.LINE_19__c;//Line 19 (IRS 2018)||Line7 (Unemployment)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine19Adjusted = careHouseholdIncomeObj.ADJ_19__c == null?0:careHouseholdIncomeObj.ADJ_19__c;//Line 19 Adjusted (IRS 2018)||Line7 Adjusted (Unemployment)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine21 = careHouseholdIncomeObj.LINE_21__c == null?0:careHouseholdIncomeObj.LINE_21__c;//Line 19 (IRS 2018)||Line8 (other)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine21Adjusted = careHouseholdIncomeObj.ADJ_21__c == null?0:careHouseholdIncomeObj.ADJ_21__c;//Line 19 Adjusted(IRS 2018)||Line8 Adjusted (other)(IRS 2019/IRS 2019)in Schedule 1
                    objWrapperFormInput.dLine22Adjusted = careHouseholdIncomeObj.ADJ_22__c == null?0:careHouseholdIncomeObj.ADJ_22__c;//Line 22 Adjusted(IRS 2018)||Line9 Adjusted(IRS 2019/IRS 2019)in Schedule 1
                    
                    objWrapperFormInput.dTotalAmount = careHouseholdIncomeObj.EST_SALARY__c == null?0:careHouseholdIncomeObj.EST_SALARY__c;
                }
                
                List <CARE_Household_Member_IncomeC__c >listHouseholdMemberIncomeC = [SELECT ID, LINE29__c, LINE3__c, LINE31__c 
                                                                                      FROM CARE_Household_Member_IncomeC__c
                                                                                      WHERE DETAIL_INCOME__c = :IdCareHouseholdmemberIncome];
                
                for(CARE_Household_Member_IncomeC__c careHouseholdMemberIncomeCObj : listHouseholdMemberIncomeC){
                    
                    WrapperHouseholdMemberIncomeC WrapperHouseholdIncomeObj = new WrapperHouseholdMemberIncomeC();
                    
                    WrapperHouseholdIncomeObj.SId = careHouseholdMemberIncomeCObj.Id;
                    WrapperHouseholdIncomeObj.dLine3 = careHouseholdMemberIncomeCObj.LINE3__c;
                    WrapperHouseholdIncomeObj.dLine29 = careHouseholdMemberIncomeCObj.LINE29__c;
                    WrapperHouseholdIncomeObj.dLine31 = careHouseholdMemberIncomeCObj.LINE31__c;
                    
                    objWrapperFormInput.listHouseholdMemberIncomeC.add(WrapperHouseholdIncomeObj);
                }    
                
            }
            else{
                return null;   
            }
        }
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return objWrapperFormInput;
    }
    
    //method to save the income source details for house member
    @AuraEnabled
    public static Boolean saveHouseholdIncome(WrapperFormInput objWrapperFormInput){
        
        Boolean bstatus;
        
        try{            
            CARE_Household_Member_Income__c careHouseholdIncomeObj = new CARE_Household_Member_Income__c();
            
            careHouseholdIncomeObj.Id = objWrapperFormInput.idCareHouseholdmemberIncome;
            careHouseholdIncomeObj.CARE_Application__c = objWrapperFormInput.idCareApp;
            careHouseholdIncomeObj.HOUSEHOLDDETAIL__c = objWrapperFormInput.idCareHouseholdDetail;
            careHouseholdIncomeObj.DISCOUNT_LENGTH_IN_DAYS__c = objWrapperFormInput.dDiscountLength;
            careHouseholdIncomeObj.INCOME_SOURCE_TYPE__c = objWrapperFormInput.sIncomeSourceType;
            careHouseholdIncomeObj.INCOME_DOC_TYPE__c = objWrapperFormInput.sDocumentType;
            careHouseholdIncomeObj.INCOME_FORM_TYPE__c = objWrapperFormInput.sFormType;           
            careHouseholdIncomeObj.IS_DOC_VALID__c = objWrapperFormInput.bIsValidDoc;
            careHouseholdIncomeObj.IS_FILING_JOINTLY__c = objWrapperFormInput.bIsFillingJointly;
            careHouseholdIncomeObj.NO_MONTHS__c = objWrapperFormInput.iMonthNo;
            careHouseholdIncomeObj.PERIOD_TYPE__c = objWrapperFormInput.sPeriodType;
            careHouseholdIncomeObj.ROLLOVER__c = objWrapperFormInput.bRollover;
            careHouseholdIncomeObj.SCHEDULE_1__c = objWrapperFormInput.bIsSchedule1;
            careHouseholdIncomeObj.SCHEDULE_1_VALID__c = objWrapperFormInput.bSchedule1DocValid;
            careHouseholdIncomeObj.Document_Complete__c = objWrapperFormInput.bScheduleCDocComplete;
            
            careHouseholdIncomeObj.AMOUNT1__c = objWrapperFormInput.dAmount1;
            careHouseholdIncomeObj.AMOUNT2__c = objWrapperFormInput.dAmount2;
            careHouseholdIncomeObj.Amount_3__c = objWrapperFormInput.dAmount3;
            careHouseholdIncomeObj.Amount_4__c = objWrapperFormInput.dAmount4;
            careHouseholdIncomeObj.Amount_5__c = objWrapperFormInput.dAmount5;
            careHouseholdIncomeObj.Amount_6__c = objWrapperFormInput.dAmount6;
            careHouseholdIncomeObj.Amount_7__c = objWrapperFormInput.dAmount7;
            careHouseholdIncomeObj.Amount_8__c = objWrapperFormInput.dAmount8;
            careHouseholdIncomeObj.Amount_9__c = objWrapperFormInput.dAmount9;
            
            careHouseholdIncomeObj.LINE_1__c = objWrapperFormInput.dLine1;
            careHouseholdIncomeObj.ADJ_1__c = objWrapperFormInput.dLine1Adjusted;
            careHouseholdIncomeObj.LINE_2__c = objWrapperFormInput.dLine2; 
            careHouseholdIncomeObj.ADJ_2__c = objWrapperFormInput.dLine2Adjusted;  
            //careHouseholdIncomeObj.Line_2A__c = objWrapperFormInput.dLine2a;
            //careHouseholdIncomeObj.Adj_2A__c = objWrapperFormInput.dLine2aAdjusted;
            careHouseholdIncomeObj.LINE_2B__c = objWrapperFormInput.dLine2b;
            careHouseholdIncomeObj.ADJ_2B__c = objWrapperFormInput.dLine2bAdjusted;
            careHouseholdIncomeObj.LINE_3__c = objWrapperFormInput.dLine3 ;
            careHouseholdIncomeObj.Adj_3__c = objWrapperFormInput.dLine3Adjusted;         
            careHouseholdIncomeObj.LINE_3B__c  = objWrapperFormInput.dLine3b;
            careHouseholdIncomeObj.ADJ_3B__c = objWrapperFormInput.dLine3bAdjusted;
            //careHouseholdIncomeObj.LINE_4__c = objWrapperFormInput.dLine4;
            //careHouseholdIncomeObj.Adj_4__c = objWrapperFormInput.dLine4Adjusted;
            careHouseholdIncomeObj.LINE_4A__c = objWrapperFormInput.dLine4a;
            careHouseholdIncomeObj.ADJ_4A__c = objWrapperFormInput.dLine4aAdjusted;
            careHouseholdIncomeObj.Line_4C__c = objWrapperFormInput.dLine4c;
            careHouseholdIncomeObj.Adj_4C__c = objWrapperFormInput.dLine4cAdjusted;
            careHouseholdIncomeObj.LINE_5__c = objWrapperFormInput.dLine5;
            careHouseholdIncomeObj.ADJ_5__c = objWrapperFormInput.dLine5Adjusted;              
            careHouseholdIncomeObj.LINE_5A__c = objWrapperFormInput.dLine5a;              
            careHouseholdIncomeObj.ADJ_5A__c  = objWrapperFormInput.dLine5aAdjusted;  
            careHouseholdIncomeObj.LINE_6__c = objWrapperFormInput.dLine6;
            careHouseholdIncomeObj.ADJ_6__c  = objWrapperFormInput.dLine6Adjusted;
            careHouseholdIncomeObj.ADJ_7__c = objWrapperFormInput.dLine7Adjusted;
            //careHouseholdIncomeObj.Line_8__c = objWrapperFormInput.dLine8;    
            //careHouseholdIncomeObj.Adj_8__c =  objWrapperFormInput.dLine8Adjusted;    
            //careHouseholdIncomeObj.Line_9__c = objWrapperFormInput.dLine9Adjusted;    
            careHouseholdIncomeObj.LINE_11__c = objWrapperFormInput.dLine11;
            careHouseholdIncomeObj.Adj_11__c=objWrapperFormInput.dLine11Adjusted;
            careHouseholdIncomeObj.LINE_12__c  = objWrapperFormInput.dLine12;
            careHouseholdIncomeObj.ADJ_12__C = objWrapperFormInput.dLine12Adjusted;
            careHouseholdIncomeObj.LINE_13__c  = objWrapperFormInput.dLine13;
            careHouseholdIncomeObj.ADJ_13__c  = objWrapperFormInput.dLine13Adjusted;
            careHouseholdIncomeObj.LINE_14__c = objWrapperFormInput.dLine14;
            careHouseholdIncomeObj.ADJ_14__c  = objWrapperFormInput.dLine14Adjusted;              
            careHouseholdIncomeObj.LINE_17__c  = objWrapperFormInput.dLine17;
            careHouseholdIncomeObj.ADJ_17__c = objWrapperFormInput.dLine17Adjusted;
            careHouseholdIncomeObj.LINE_18__c  = objWrapperFormInput.dLine18;
            careHouseholdIncomeObj.ADJ_18__c = objWrapperFormInput.dLine18Adjusted;
            careHouseholdIncomeObj.LINE_19__c = objWrapperFormInput.dLine19;
            careHouseholdIncomeObj.ADJ_19__c = objWrapperFormInput.dLine19Adjusted;
            careHouseholdIncomeObj.LINE_21__c = objWrapperFormInput.dLine21;
            careHouseholdIncomeObj.ADJ_21__c = objWrapperFormInput.dLine21Adjusted;
            careHouseholdIncomeObj.ADJ_22__c = objWrapperFormInput.dLine22Adjusted;
            
            careHouseholdIncomeObj.EST_SALARY__c = objWrapperFormInput.dTotalAmount;        
            if(CARE_Constants.CARE_PEV_INCOME_DOCUMENT_CATEGORICAL.contains(careHouseholdIncomeObj.INCOME_DOC_TYPE__c )){
                careHouseholdIncomeObj.IS_CATEGORICAL__c = true;
            }
            if(CARE_Constants.CARE_PEV_INCOME_DOCUMENT_CATEGORICAL_FIXED.contains(careHouseholdIncomeObj.INCOME_DOC_TYPE__c )){
                careHouseholdIncomeObj.IS_CATEGORICAL_FIXED__c = true;
            }
            if(objWrapperFormInput.bIsValidDoc){
                if(objWrapperFormInput.bIsSchedule1){
                    
                    if(objWrapperFormInput.bSchedule1DocValid && objWrapperFormInput.bScheduleCDocComplete){
                        careHouseholdIncomeObj.INCOME_SOURCE_STATUS__c = 'Valid';
                    }  
                    else{ 
                        careHouseholdIncomeObj.INCOME_SOURCE_STATUS__c = 'Invalid';
                    }                      
                }   
                else{
                    careHouseholdIncomeObj.INCOME_SOURCE_STATUS__c = 'Valid';
                }               
            }         
            else{
                careHouseholdIncomeObj.INCOME_SOURCE_STATUS__c = 'Invalid';
            }
            
            Upsert careHouseholdIncomeObj; 
            
            //Insert into HouseholdMember IncomeC
            
            if(objWrapperFormInput.bIsSchedule1){            
                
                //check if the records is removed from UI,If yes add the record in deleteList
                List<CARE_Household_Member_IncomeC__c>listHouseholdIncomeCToDelete = new List<CARE_Household_Member_IncomeC__c>();
                //get the IncomeC Records based on IncomeRecord
                List<CARE_Household_Member_IncomeC__c> listHouseholdIncomeCRec= [SELECT ID FROM CARE_Household_Member_IncomeC__c
                                                                                 WHERE DETAIL_INCOME__c = :careHouseholdIncomeObj.Id];
                String sId;
                Set<String>listHouseholdIncomeCId = new Set<String>();
                
                if(listHouseholdIncomeCRec != null && listHouseholdIncomeCRec.size() > 0){
                    for(CARE_Household_Member_IncomeC__c incomeCRecObj:listHouseholdIncomeCRec )
                    {
                        sId = String.valueOf(incomeCRecObj.ID);
                        listHouseholdIncomeCId.add(sId);
                    }                    
                    //create the SetOf IncomecRecord Id's from UI
                    Set<String>listHouseholdIncomeCIdFromUI = new Set<String>();
                    
                    for( WrapperHouseholdMemberIncomeC IncomeCObJ :objWrapperFormInput.listHouseholdMemberIncomeC){
                        sId = IncomeCObJ.sId;
                        listHouseholdIncomeCIdFromUI.add(sId);
                    }   
                    
                    //Check if any ScheduleC record is Removed from UI after intial record creation
                    for(String SRecId :listHouseholdIncomeCId){
                        //record is not availble in the new UI list but available in the SF,add to delete lits
                        if(!(listHouseholdIncomeCIdFromUI).contains(SRecId)){
                            CARE_Household_Member_IncomeC__c incomeCobj = new CARE_Household_Member_IncomeC__c();
                            incomeCobj.Id = SRecId;
                            listHouseholdIncomeCToDelete.add(incomeCobj);
                        }
                    }
                    if(listHouseholdIncomeCToDelete != null && listHouseholdIncomeCToDelete.size() > 0)   {
                        Delete listHouseholdIncomeCToDelete;
                    } 
                }
                
                List<CARE_Household_Member_IncomeC__c> listHouseholdIncomeC = new list<CARE_Household_Member_IncomeC__c>();
                for(WrapperHouseholdMemberIncomeC householdIncomeCObj : objWrapperFormInput.listHouseholdMemberIncomeC){
                    CARE_Household_Member_IncomeC__c careHouseholdIncomeCObj = new CARE_Household_Member_IncomeC__c();
                    
                    careHouseholdIncomeCObj.Id = householdIncomeCObj.sId;
                    careHouseholdIncomeCObj.Application__c = objWrapperFormInput.idCareApp;
                    careHouseholdIncomeCObj.DETAIL_INCOME__c = careHouseholdIncomeObj.Id;
                    careHouseholdIncomeCObj.HOUSEHOLD_DETAIL__c = objWrapperFormInput.idCareHouseholdDetail;
                    careHouseholdIncomeCObj.LINE3__c = householdIncomeCObj.dLine3;
                    careHouseholdIncomeCObj.LINE29__c = householdIncomeCObj.dLine29;
                    careHouseholdIncomeCObj.LINE31__c = householdIncomeCObj.dLine31;
                    
                    listHouseholdIncomeC.add(careHouseholdIncomeCObj);
                }
                upsert listHouseholdIncomeC;
                
            }
            
            //delete IncomeScheduleC record if ScheduleC Record if Schedule1 is unchecked from UI while updating again
            else{
                List<CARE_Household_Member_IncomeC__c> listHouseholdIncomeCToDelete = [SELECT ID FROM CARE_Household_Member_IncomeC__c
                                                                                       WHERE DETAIL_INCOME__c = :careHouseholdIncomeObj.Id];
                
                if(listHouseholdIncomeCToDelete.size()>0){
                    delete listHouseholdIncomeCToDelete;}
            }
                      
            bstatus = updateAnnualIncomeAndDocValidity(objWrapperFormInput.idCareApp, objWrapperFormInput.idCareHouseholdDetail);
        }
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return bstatus;
    }
    
    //method to delete the Househod member record on record selection from UI
    @AuraEnabled
    public static boolean deleteHouseholdIncomeRecord( Id idHouseholdMember, Id idCareApp, Id idHouseholdDetail){
        Boolean bStatus;
        try{
            
            CARE_Household_Member_Income__c[] householdMember = [SELECT ID, HOUSEHOLDDETAIL__c FROM CARE_Household_Member_Income__c
                                                                 WHERE ID=:idHouseholdMember];
            Delete householdMember;
            
            //Delete HouseholdMemberIncomeC
            List<CARE_Household_Member_IncomeC__c> listCareHouseholdMemIncC = [SELECT Id
                                                                               FROM CARE_Household_Member_IncomeC__c
                                                                               WHERE DETAIL_INCOME__c =:idHouseholdMember];
            if(listCareHouseholdMemIncC != null && listCareHouseholdMemIncC.size() > 0){
             Delete listCareHouseholdMemIncC;   
            }
            
            
            bStatus = updateAnnualIncomeAndDocValidity(idCareApp, idHouseholdDetail);
        }   
        catch (exception ex){   
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
            
        }
        return bStatus;
    }
    
    
    //*******************************Private Methods********************************
    //update the total income in HouseholdMember
    
    private static Boolean updateAnnualIncomeAndDocValidity(Id idCareApp, Id idCareHouseholdDetail ){
        
        Boolean bStatus;
        Boolean bInvalid = false;
        Decimal dTotalSalaryForMember = 0;
        Decimal dTotalSalaryForPerson = 0;
        try{
            CARE_Household_Detail__c careHouseholdDetailObj = [SELECT ID,EST_ANNUAL_SALARY__c 
                                                               FROM CARE_Household_Detail__c WHERE ID = :idCareHouseholdDetail];
            
            for(CARE_Household_Member_Income__c careHouseholdIncome :[SELECT ID, EST_SALARY__c 
                                                                      FROM CARE_Household_Member_Income__c
                                                                      WHERE HOUSEHOLDDETAIL__c= :idCareHouseholdDetail]){                  
                                                                          if(careHouseholdIncome.EST_SALARY__c==null){
                                                                              careHouseholdIncome.EST_SALARY__c=0;
                                                                          }															
                                                                          dTotalSalaryForMember += careHouseholdIncome.EST_SALARY__c;                                                                           
                                                                      }
            careHouseholdDetailObj.EST_ANNUAL_SALARY__c = dTotalSalaryForMember;
            
            update careHouseholdDetailObj;
            
            //update the total income in Care App for allHousehold Member
            for(CARE_Household_Detail__c careHouseholdDetail :[SELECT ID,EST_ANNUAL_SALARY__c 
                                                               FROM CARE_Household_Detail__c
                                                               WHERE APPLICATION__c = :idCareApp]){
                                                                   if(careHouseholdDetail.EST_ANNUAL_SALARY__c==null){
                                                                       careHouseholdDetail.EST_ANNUAL_SALARY__c=0;
                                                                   }
                                                                   dTotalSalaryForPerson += careHouseholdDetail.EST_ANNUAL_SALARY__c;                                                                               
                                                               }
            CARE_Application__c careAppObj = new CARE_Application__c();
            careAppObj.Id = idCareApp;
            careAppObj.ANNUAL_HOUSEHOLD_INCOME__c = dTotalSalaryForPerson;              
            Update careAppObj;  
            
            //update Doc vaidity status for HouseholdMember
            //CARE_Household_Detail__c careHouseholdDetailObj =[SELECT ID, INCOME_SOURCE_STATUS__c
            //                                                 FROM CARE_Household_Detail__c 
            //                                                 WHERE ID =:objWrapperFormInput.idCareHouseholdDetail];
            
            List<CARE_Household_Member_Income__c> listHouseholdIncomeDoc = [SELECT ID,INCOME_SOURCE_STATUS__c
                                                                            FROM CARE_Household_Member_Income__c 
                                                                            WHERE HOUSEHOLDDETAIL__c =:idCareHouseholdDetail];
                                                                            //AND INCOME_SOURCE_STATUS__c = 'Invalid'
            /*if(listHouseholdIncomeDoc != null && listHouseholdIncomeDoc.size() > 0){
                
                careHouseholdDetailObj.INCOME_SOURCE_STATUS__c = 'Invalid';
            }
            else {
                careHouseholdDetailObj.INCOME_SOURCE_STATUS__c = 'Valid';
            }*/
            //check if Income record is valid/Invalid
            if(listHouseholdIncomeDoc != null && listHouseholdIncomeDoc.size() > 0){
                
                for(CARE_Household_Member_Income__c incomeCObj :listHouseholdIncomeDoc){                    
                    if(incomeCObj.INCOME_SOURCE_STATUS__c =='Invalid'){
                        bInvalid = true;
                    }
                }
            }
            //there is not record available default the validity of record to 'Invalid'
            else {
                bInvalid = true;
            }
            if(bInvalid){
                careHouseholdDetailObj.INCOME_SOURCE_STATUS__c = 'Invalid';
            }
            else{
                careHouseholdDetailObj.INCOME_SOURCE_STATUS__c = 'Valid';
            }
            update careHouseholdDetailObj;
            
            bStatus = true;
        }
        
        catch (exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_IncomeInformationController',ex));
            CARE_UtilityController.sendExceptionEmail('CARE_IncomeInformationController','','',null, ex);
        }
        return bStatus;
    }    
    
}