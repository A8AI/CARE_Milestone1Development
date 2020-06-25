/***********************************************************************************************************   
Apex Util class Name :  CARE_ReinstateController
Version              :  1.0                                                                          
Created Date         :  05/27/2020                                                         
Function             :  This is the Apex Controller for Reinstate functionality for CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/08/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_ReinstateController {
    
    //Constants 
     Private Static final Date dTodaysDate = Date.today();     
    
    //response Wrapper class for Reinstate Section
    public class WrapperReinstateResponse{
        @AuraEnabled
        public List<WrapperReinstate> listReinstate = new List<WrapperReinstate>();
        @AuraEnabled
        public List<WrapperReinstateReason> listReinstateReason = new List <WrapperReinstateReason>();
        @AuraEnabled
        public String sCommentWithAdjustment{get;set;}
        @AuraEnabled
        public String sCommentWithOutAdjustment{get;set;}
        @AuraEnabled 
        public Date dTodaysDate{get;set;}
        @AuraEnabled 
        public Date dDateBeforeNinetyDays{get;set;}
        @AuraEnabled
        public String sContactCode {get; set;}
        
        public WrapperReinstateResponse(){
            listReinstate = new List<WrapperReinstate>();
            listReinstateReason = new List<WrapperReinstateReason>();
            sCommentWithOutAdjustment = '';
            sCommentWithAdjustment = '';
            sContactCode = '';
        }
    }
    
    //response Wrapper class for Reinstate Section
    public class WrapperReinstate{
        @AuraEnabled
        public Id idSARecID {get; set;}
        @AuraEnabled
        public Id idAccountID {get; set;}
        @AuraEnabled
        public String sBillingAccountId {get; set;}
        @AuraEnabled
        public String sPremiseId {get; set;} 
        @AuraEnabled
        public String sSAId {get; set;}
        @AuraEnabled
        public String sSAType {get; set;}
        @AuraEnabled
        public String sDiscountType {get; set;}
        @AuraEnabled 
        public String sRateSchedule {get; set;}
        @AuraEnabled
        public Date dEndDate {get; set;}
        @AuraEnabled
        public Date dRetroStartDate {get; set;}
        @AuraEnabled
        public Date dRetroEndDate {get; set;}
        @AuraEnabled
        public Date dSAStartDate {get; set;}
        @AuraEnabled
        public String sApplicantName {get; set;}
    }
    
    public class WrapperReinstateReason{
        @AuraEnabled 
        public String label {get;set;}
        @AuraEnabled 
        public String value {get;set;}
    }
    
    //Input parameter from UI selected value
    public class ReinstateInputWrapper{
        @AuraEnabled 
        public String sPerId{get;set;}
        @AuraEnabled 
        public String sReason{get;set;}
        @AuraEnabled 
        public String sComment{get;set;}
        @AuraEnabled
        public String sContactCode{get;set;}
        
    }
    
    //Method to get the SA details for Reinstate modal pop up
    @AuraEnabled 
    public static WrapperReinstateResponse getReinstateDetails (String sPerId) {
        WrapperReinstateResponse reinstateResponse = new WrapperReinstateResponse();
        List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
        String sLatestCareAppID;
        try{
            
            Map <String, EI_SITE__C> mapActiveSADiscountEnrollment = new Map <String ,EI_SITE__C >();
            mapActiveSADiscountEnrollment = CARE_UtilityController.getActiveSADetailsForPersonId(sPerId);   
            //check if customer is having an existing discount.
            if(!mapActiveSADiscountEnrollment.isEmpty()){
                
                return null;
            }
            else{                      
                //check if customer is having a previous active enrollent with Valid CC Code & Future End Date            
                List<CARE_App_Enrolled_SA__c> listCareAppEnrolledSA = new List <CARE_App_Enrolled_SA__c> ([SELECT SA_ID__c, START_DATE__c, END_DATE__c,Service_Agreement__r.Id, 
                                                                                                           Service_Agreement__r.Svc_Type_Code_EI__c, Service_Agreement__r.CARE_DISCOUNT_TYPE__c,
                                                                                                           Service_Agreement__r.SA_Start_Date_EI__c,
                                                                                                           Service_Agreement__r.Imported_Site_Name_EI__c,
                                                                                                           RS_CD__c, APPLICATION__c, ACCT_ID__c,
                                                                                                           PREM_ID__c, CC_CL_CD__c,
                                                                                                           RETRO_START_DATE__c, RETRO_END_DATE__c,APPLICATION__r.Id, 
                                                                                                           APPLICATION__r.CARE_Account_ID__c
                                                                                                           FROM CARE_App_Enrolled_SA__C 
                                                                                                           WHERE END_DATE__c>:dTodaysDate
                                                                                                           AND APPLICATION__r.PER_ID__C = : sPerID 
                                                                                                           AND  ((APPLICATION__r.CC_CL_CD__c =:CARE_Constants.CARE_CARE_DISCOUNT_TYPE AND APPLICATION__r.CCB_CONTACT_CODE__c IN: CARE_Constants.CARE_CC_CODE_CARE)
                                                                                                                 OR (APPLICATION__r.CC_CL_CD__c =:CARE_Constants.CARE_FERA_DISCOUNT_TYPE AND APPLICATION__r.CCB_CONTACT_CODE__c IN: CARE_Constants.CARE_CC_CODE_FERA)
                                                                                                                ) 
                                                                                                           ORDER BY APPLICATION__r.CreatedDate DESC]);
                //get the latest transaction record with a valid Rate Schedule & Status Code from history transaction
                if  (listCareAppEnrolledSA!= null && listCareAppEnrolledSA.size()>0 ){                    
                   sLatestCareAppID = listCareAppEnrolledSA[0].APPLICATION__c;
                    
                    for (CARE_App_Enrolled_SA__c careAppobj : listCareAppEnrolledSA){
                        
                        if(careAppobj.APPLICATION__c == sLatestCareAppID ){
                        
                        WrapperReinstate objRec = new WrapperReinstate ();
                        objRec.idSARecID = careAppobj.Service_Agreement__r.Id;
                        objRec.idAccountID = careAppobj.APPLICATION__r.CARE_Account_ID__c;
                        objRec.sBillingAccountId = careAppobj.ACCT_ID__C;
                        objRec.sPremiseId = careAppobj.PREM_ID__c;
                        objRec.sSAId = careAppobj.SA_ID__c;
                        objRec.sSAType = careAppobj.Service_Agreement__r.Svc_Type_Code_EI__c; 
                        objRec.sDiscountType = careAppobj.CC_CL_CD__c;
                        objRec.dEndDate = careAppobj.END_DATE__c;
                        objRec.sRateSchedule = careAppobj.RS_CD__c; 
                        objRec.dSAStartDate = careAppobj.Service_Agreement__r.SA_Start_Date_EI__c;
                        objRec.sApplicantName = careAppobj.Service_Agreement__r.Imported_Site_Name_EI__c;
                        
                        reinstateResponse.listReinstate.add(objRec);                        
                        }
                    }

                    //get the Transfer reason list  
                    List <String> listReinstateReason = CARE_UtilityController.getReasonList('Reinstatement Reason');
                    for(String sReasonRec : listReinstateReason){
                        
                        WrapperReinstateReason objReinstateReason = new WrapperReinstateReason ();
                        objReinstateReason.label = sReasonRec;
                        objReinstateReason.value = sReasonRec;  
                        reinstateResponse.listReinstateReason.add(objReinstateReason);
                    } 
                  
                    //get the cc code details for Reinstate reason without adjustment
                    listCareType = CARE_UtilityController.getCCCode(CARE_COnstants.CARE_CC_REINSTATE_NO_ADJUSTMENT,null,null);                
                    reinstateResponse.sCommentWithAdjustment = listCareType[0].TYPE_DESC_LONG__c;
                    
                    //get the cc code details for Reinstare reason with adjustment
                    listCareType = CARE_UtilityController.getCCCode(CARE_Constants.CARE_CC_REINSTATE_ADJUSTMENT,null,null);                
                    reinstateResponse.sCommentWithOutAdjustment = listCareType[0].TYPE_DESC_LONG__c;                    
                    reinstateResponse.dTodaysDate = dTodaysDate;
                    reinstateResponse.dDateBeforeNinetyDays = dTodaysDate.addDays(-90);
					reinstateResponse.sContactCode = listCareType[0].TYPE_CODE__c;
                        
                    return reinstateResponse;   
                }
                else{
                    return null;
                }                
            }
            
        }
        catch(Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return reinstateResponse ;
    }
    
    @AuraEnabled
    public static Boolean reinstateSA(String sPerId ,List<WrapperReinstate> listReinstateSA, ReinstateInputWrapper objReinstateInput, Boolean bIfAdjustment){
        Boolean bStatus;
        String sTypeNo;
        try{
            List<CARE_Type__c> listCareType = new List<CARE_Type__c>();
            List<CARE_App_Enrolled_SA__c>listCareAppEnrolledSA = new List<CARE_App_Enrolled_SA__c>();
            //get the cc code details for Reinstate based on Adjustment value.
            if(bIfAdjustment){
                sTypeNo = CARE_Constants.CARE_CC_REINSTATE_ADJUSTMENT;
                listCareType = CARE_UtilityController.getCCCode(sTypeNo,null,null);
            }
            else{
                sTypeNo = CARE_Constants.CARE_CC_REINSTATE_NO_ADJUSTMENT;
                listCareType = CARE_UtilityController.getCCCode(sTypeNo,null,null);
            }
            
            //get RecordType id from constant class
             Id careAppRecTypeId = CARE_UtilityController.getObjectRecordTypeId(CARE_Constants.RES_CUST_DEVELOPER_NAME);
            
            //create CARE APP Transaction To record the Resintate transaction         
            CARE_Application__c careAppObj = new CARE_Application__c();
            
            careAppobj.RecordTypeId = careAppRecTypeId;
            careAppobj.APPLICANT_NAME__c =  listReinstateSA[0].sApplicantName;
            careAppObj.APPLICATION_STATUS__c = 'Decision Made';
            careAppObj.ENROLLMENT_TYPE__c = 'OTHER';
            careAppobj.SOURCE_CHANNEL_TYPE__c = CARE_Constants.CARE_REINSTATE_SRC;
            careAppObj.PROCESSED_DATE__c  = dTodaysDate;
            careAppObj.PER_ID__c = sPerID;    
            careAppObj.CCB_CONTACT_CODE__c = listCareType[0].TYPE_CODE__c;
            careAppObj.CCB_CONTACT_DESC__c= listCareType[0].TYPE_DESC__c;
            careAppObj.CCB_CONTACT_COMMENT__c = objReinstateInput.sComment;//Comment updated in Modal 
            careAppObj.REASON_DESC__c = objReinstateInput.sReason; //Reason selected in Modal        
            careAppObj.CARE_Account_ID__c = listReinstateSA[0].idAccountID;//EI Account Id
            careAppObj.ACCT_ID__c = listReinstateSA[0].sBillingAccountId;
            careAppObj.CC_CL_CD__c = listReinstateSA[0].sDiscountType;            
            careAppobj.IS_ADJUSTMENT__c = bIfAdjustment;
            
            Insert careAppObj;            
            
            for ( WrapperReinstate reinstateSAObj :listReinstateSA ){
                CARE_App_Enrolled_SA__c careEnrolledSAObj = new CARE_App_Enrolled_SA__c(); 
                
                careEnrolledSAObj.ACCT_ID__c = reinstateSAObj.sBillingAccountId;
                careEnrolledSAObj.APPLICATION__c = careAppObj.Id;
                careEnrolledSAObj.Service_Agreement__c = reinstateSAObj.idSARecID;
                careEnrolledSAObj.CC_CL_CD__c = reinstateSAObj.sDiscountType;
                careEnrolledSAObj.CCB_CONTACT_TYPE__c = sTypeNo;
                careEnrolledSAObj.PER_ID__c = sPerID;
                careEnrolledSAObj.PREM_ID__c = reinstateSAObj.sPremiseId;
                careEnrolledSAObj.RS_CD__c = reinstateSAObj.sRateSchedule;
                careEnrolledSAObj.SA_ID__c = reinstateSAObj.sSAId;    
                careEnrolledSAObj.END_DATE__c = reinstateSAObj.dEndDate ;
                careEnrolledSAObj.SA_START_DATE__c = reinstateSAObj.dSAStartDate;
                
                //If adjustment is Selected record start Date & end Date
                if(bIfAdjustment){
                    careEnrolledSAObj.RETRO_START_DATE__c = reinstateSAObj.dRetroStartDate;
                    careEnrolledSAObj.RETRO_END_DATE__c = reinstateSAObj.dRetroEndDate;                    
                }
                //If Adjustment is not involved record last Billing cycle start date as Yes Date for each SA id ,time being stamp todaysDate
                else{
                    careEnrolledSAObj.START_DATE__C = dTodaysDate;
                }
                listCareAppEnrolledSA.add(careEnrolledSAObj);
                
            }           
            Insert listCareAppEnrolledSA;
            
            bStatus = true;
            
        }
        catch(Exception ex){
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        }
        return bStatus ;
    }
}