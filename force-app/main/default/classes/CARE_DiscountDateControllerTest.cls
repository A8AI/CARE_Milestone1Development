/***********************************************************************************************************   
Apex Util class Name :  CARE_DiscountDateControllerTest
Version              :  1.0                                                                          
Created Date         :  06/16/2020                                                         
Function             :  This is the Test class for Identifying Start date and end date for SA 
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    						Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/16/2020            CTS                  			 			Initial Version.
*                                             	 					CARE Application: 
****************************************************************************************************************************************/

@istest
public class CARE_DiscountDateControllerTest {
  
    @isTest
    public static void testGetDiscountDates()
    {  
    Test.startTest();
    date dFinalEndDate;
    //2 Year Discount Scenario
    List<CARE_DiscountDateController.FlowInputs>listFlowInputs =new List<CARE_DiscountDateController.FlowInputs>();
    listFlowInputs=createFlowInputs('1122334455',Date.today()-30,Date.today()+30,Date.today()-30,2);
    List<CARE_DiscountDateController.FlowOutputs> listFlowOutputs =new List<CARE_DiscountDateController.FlowOutputs>();
    listFlowOutputs= CARE_DiscountDateController.getDiscountDates(listFlowInputs);
  	dFinalEndDate=(Date.today()-30).addDays(820);
    System.assertEquals(dFinalEndDate, listFlowOutputs[0].dDiscountEndDate);
        
    //4 Year Discount Scenario
    listFlowInputs.clear();
    listFlowInputs=createFlowInputs('1122334455',Date.today()-30,Date.today()+30,Date.today()-30,4);
    listFlowOutputs= CARE_DiscountDateController.getDiscountDates(listFlowInputs);
    dFinalEndDate=(Date.today()-30).addDays(1550);
    System.assertEquals(dFinalEndDate, listFlowOutputs[0].dDiscountEndDate);
    
    //SA Start Date=null Scenario
    listFlowInputs.clear();
    listFlowInputs=createFlowInputs('1122334455',Date.today()-30,Date.today()+30,null,4);
    listFlowOutputs= CARE_DiscountDateController.getDiscountDates(listFlowInputs);
    dFinalEndDate=Date.today().addDays(1550);
    System.assertEquals(dFinalEndDate, listFlowOutputs[0].dDiscountEndDate);    
    Test.stopTest();
    }
	//Method to create inputs     
    private static List<CARE_DiscountDateController.FlowInputs> createFlowInputs(string sSAID,date dLastBillingStartDate,date dLastBillingEndDate,date dSAStartDate,integer iNoOfYears )
    {   
    CARE_DiscountDateController.FlowInputs flowInputs=new CARE_DiscountDateController.FlowInputs();
    List<CARE_DiscountDateController.FlowInputs>listFlowInputs =new List<CARE_DiscountDateController.FlowInputs>();
    flowInputs.sSAID=sSAID;
    flowInputs.dLastBillingStartDate=dLastBillingStartDate;
    flowInputs.dLastBillingEndDate=dLastBillingEndDate;
    flowInputs.dSAStartDate=dSAStartDate;
    flowInputs.iNoOfYears=iNoOfYears;   
    listFlowInputs.add(flowInputs);
    return listFlowInputs;
    }
        
}