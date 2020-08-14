/***********************************************************************************************************   
Apex Util class Name :  CARE_EmployeeDiscountController
Version              :  1.0                                                                          
Created Date         :  06/01/2020                                                         
Function             :  This is the Apex class for Identifying Customer has employee Discount or Not 
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    						Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/01/2020            CTS                  			 			Initial Version.
*                                             	 					CARE Application: 
****************************************************************************************************************************************/

public class CARE_EmployeeDiscountController {
    
    Private Static final Date dTodaysDate = Date.today();
    
    @InvocableMethod
    public static list<FlowOutputs> checkEmployeeDiscount(list<FlowInputs> listInputValues)
    {
        Boolean bEmpDiscount;
        String sPersId=listInputValues[0].sPersId;
        try{
            List <EI_SA_CONTERM__C> listEmpDiscount = [SELECT SA_ID__c, BF_CD__C, END_DT__C FROM EI_SA_CONTERM__C
                                                       WHERE SERVICE_AGREEMENT__r.Person_ID_EI__c = :sPersId AND BF_CD__C = :CARE_Constants.CARE_EMP_DISCOUNT_CODE
                                                       AND (END_DT__C >= :dTodaysDate OR END_DT__C = NULL)];
            if(listEmpDiscount.size()>0){
                bEmpDiscount = true;
            }
            else{
                bEmpDiscount = false;
            }
        }
        catch (Exception ex) {        
       EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException('CARE_EmployeeDiscountController',ex));
       CARE_UtilityController.sendExceptionEmail('CARE_EmployeeDiscountController', '','', sPersId, ex);
        } 
        
        FlowOutputs outPut=new FlowOutputs();
        outPut.bHasEmployeeDiscount=bEmpDiscount;
        List<FlowOutputs> listResults =new List<FlowOutputs>();  
        listResults.add(outPut); 
        return listResults;
    }
    
   //Wrapper class for Recieving input from flow 
    public class FlowInputs{
        @InvocableVariable
        public String sPersId;        
        
    }
    
    //Wrapper class for Recieving input from flow 
    public class FlowOutputs{
        @InvocableVariable
        public Boolean bHasEmployeeDiscount;        
        
    }
     
}