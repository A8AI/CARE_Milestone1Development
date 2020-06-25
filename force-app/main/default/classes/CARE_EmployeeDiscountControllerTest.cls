/***********************************************************************************************************   
Apex Util class Name :  CARE_EmployeeDiscountControllerTest
Version              :  1.0                                                                          
Created Date         :  06/15/2020                                                         
Function             :  Test class for Identifying Customer has employee Discount or Not (Used in Flow to verify Full Qualification Logic) 
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    						Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/15/2020            CTS                  			 			Initial Version.
*                                             	 					CARE Application: 
****************************************************************************************************************************************/
@istest
public class CARE_EmployeeDiscountControllerTest {
@TestSetup
    public static void setData()
    {
                Account objCareAccount = PM_EI_TestDataUtility.createAccount(); //called testdatafactory for creation of account
                objCareAccount.Premise_ID__c = '1233333333';
                objCareAccount.AccountNumber = '1224590694';
        		objCareAccount.CARE_DISCOUNT_TYPE__c = 'CARE';
        		objCareAccount.Encrypted_Account_Name__c = 'Test Dummy Acct';
                objCareAccount.SAID__c = '000000000E';
        		objCareAccount.Phone = '9065231234';               
                objCareAccount.Discount__c = 'C';
        		objCareAccount.Billing_Person_ID_EI__c = '1224590555';
                objCareAccount.Service_Address__c = 'Search1234';
                objCareAccount.SA_Type__c = 'G';
                objCareAccount.Encrypted_Account_Name__c = 'Encrypted';
                objCareAccount.Type = 'Type';
                objCareAccount.Rate__c = 'HAG1A';
                objCareAccount.Branch_Code_EI__c = 'Get';
                objCareAccount.Original_Tree_Level_EI__c = 2.0;
                
        insert objCareAccount;	//inserted account
        EI_NAICS_Code__c oNAICSCode = PM_EI_TestDataUtility.createNAICSCode();
        insert oNAICSCode;
        EI_Site__c objSiteAgreement = PM_EI_TestDataUtility.createSite(objCareAccount,oNAICSCode);//called testdatafactory for creation of Site
        objSiteAgreement.Billing_Account_ID_EI__c = objCareAccount.Id;
        objSiteAgreement.Imported_Site_Name_EI__c = objCareAccount.Name;
        objSiteAgreement.Person_ID_EI__c = '1224590555';
        objSiteAgreement.Site_Premise_ID_EI__c = objCareAccount.Premise_ID__c;
        objSiteAgreement.Rate_Schedule_EI__c = 'STANDARD';
        objSiteAgreement.Care_Stop_Date_EI__c = date.today()+1;
        objSiteAgreement.Res_Ind_EI__c = 'N';
        objSiteAgreement.SAID_EI__c = objCareAccount.SAID__c;
        objSiteAgreement.Phone_1_EI__c = objCareAccount.Phone;
      	objSiteAgreement.Svc_Full_Adr_EI__c = 'WASHINGTON ST CA 23432';
        objSiteAgreement.Svc_Status_Code_EI__c = '20';
        objSiteAgreement.Svc_Type_Code_EI__c = 'E';
        objSiteAgreement.Site_Premise_ID_EI__c = '1234567890';
        insert objSiteAgreement; //inserted site
      
     	EI_SA_CONTERM__C objConterm =new EI_SA_CONTERM__C();
        objConterm.BF_CD__c='EMP-DSC';
        objConterm.SERVICE_AGREEMENT__c=objSiteAgreement.Id;       
        objConterm.SA_ID__c= objSiteAgreement.SAID_EI__c;
        objConterm.END_DT__c=Date.today()+30;
        objConterm.EXTERNAL_ID__c='1224590555';  
        objConterm.START_DT__c=Date.today();
        insert objConterm;    
    }
    
    @istest
    static void testcheckEmployeeDiscount(){
       	Test.startTest(); 
        //Positive Scenario : Person id has Employee Discount
        CARE_EmployeeDiscountController.FlowInputs flowInputs=new CARE_EmployeeDiscountController.FlowInputs();
        flowInputs.sPersId='1224590555';
      
        List<CARE_EmployeeDiscountController.FlowInputs> listFlowInputs =new List<CARE_EmployeeDiscountController.FlowInputs>();
        listFlowInputs.add(flowInputs);
        
        List<CARE_EmployeeDiscountController.FlowOutputs> listFlowOutputs=new List<CARE_EmployeeDiscountController.FlowOutputs>();
    	listFlowOutputs =CARE_EmployeeDiscountController.checkEmployeeDiscount(listFlowInputs);       
        System.assertEquals(true, listFlowOutputs[0].bHasEmployeeDiscount);
        //Negative Scenario: Non Employee Discount Person Id
        listFlowInputs.clear();
        flowInputs.sPersId='0004590555';
        listFlowInputs.add(flowInputs);
        listFlowOutputs =CARE_EmployeeDiscountController.checkEmployeeDiscount(listFlowInputs);
		System.assertEquals(false, listFlowOutputs[0].bHasEmployeeDiscount);        
        Test.stopTest();
    }
    
}