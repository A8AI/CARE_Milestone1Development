/***********************************************************************************************************   
Apex Util class Name :  CARE_DiscountDateController
Version              :  1.0                                                                          
Created Date         :  06/10/2020                                                         
Function             :  This is the Apex class for Identifying Start date and end date for Discount 
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    						Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/10/2020            CTS                  			 			Initial Version.
*                                             	 					CARE Application: 
****************************************************************************************************************************************/


public class CARE_DiscountDateController {
 Private Static final Date dTodaysDate = Date.today();
    
    @InvocableMethod
    public static list<FlowOutputs> getDiscountDates(list<FlowInputs> listInputValues)
    {       
        Date dFinalStartDate=null;
        Date dFinalEndDate=null;        
        Date dSAStartdate=null;        
        //Date dLastBillingStartDate=null;
        //Date dLastBillingEndDate=null;
        Integer iNoOfYears;
        
        //if(inputValues[0].dLastBillingStartDate !=null ){
        // dLastBillingStartDate=inputValues[0].dLastBillingStartDate;  }     
        // if(inputValues[0].dLastBillingEndDate !=null){
        //  dLastBillingEndDate=inputValues[0].dLastBillingEndDate;}        
        if(listInputValues[0].iNoOfYears !=null){
            iNoOfYears=listInputValues[0].iNoOfYears;}
        if(listInputValues[0].dSAStartDate !=null){
            dSAStartdate=listInputValues[0].dSAStartDate;}        
        
        if(dSAStartdate !=null)    
        {
            dFinalStartDate= dSAStartdate;         
        }
        else // If Start date is not available use Today as start date
        {
            dFinalStartDate= dTodaysDate;  
        }
        if(iNoOfYears==2) 
        {   
            dFinalEndDate=dFinalStartDate.addDays(820);
        }
        else if(iNoOfYears==4) 
        {
            dFinalEndDate=dFinalStartDate.addDays(1550);             
        }            
        
        FlowOutputs outPut=new FlowOutputs();
        outPut.dDiscountStartDate=dFinalStartDate;
        outPut.dDiscountEndDate=dFinalEndDate;        
        List<FlowOutputs> listResults =new List<FlowOutputs>();  
        listResults.add(outPut); 
        return listResults;         
    }
    
    //Wrapper class for Recieving input from flow 
    public class FlowInputs{
        @InvocableVariable
        public String sSAID; 
        @InvocableVariable
        public Date dSAStartDate; 
        @InvocableVariable
        public Date dLastBillingStartDate;
        @InvocableVariable
        public Date dLastBillingEndDate;
        @InvocableVariable
        public Integer iNoOfYears;
        
    }
    
    //Wrapper class for Recieving input from flow 
    public class FlowOutputs{
        @InvocableVariable
        public date dDiscountStartDate;   
        @InvocableVariable
        public date dDiscountEndDate;  
        
    }
}