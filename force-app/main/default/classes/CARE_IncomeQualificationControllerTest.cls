/***********************************************************************************************************   
Apex Util class Name :  CARE_IncomeQualificationControllerTest
Version              :  1.0                                                                          
Created Date         :  06/15/2020                                                         
Function             :  Test class for Income Qualification Which is getting called from Full Qualification Logic.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/15/2020            Cognizant Technology Solutions                     Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

@istest(SeeAllData=false)
public class CARE_IncomeQualificationControllerTest {

    
    @testSetup
    public static void setData()
    {
        List<Low_Income_Qualification__c> listIncomeRecords =createLowIncomeQualificationRecords();
        insert listIncomeRecords;
    }
    
    @isTest
    static void testGetEnrollmentType()
    {
        Test.startTest();
        //CARE Qualified
        CARE_IncomeQualificationController.FlowInputs flowInputs=new CARE_IncomeQualificationController.FlowInputs();
        flowInputs.iNoOfHouseholds=7;
        flowInputs.dTotalIncome=65000;
        List<CARE_IncomeQualificationController.FlowInputs> listFlowInputs =new List<CARE_IncomeQualificationController.FlowInputs>();
        listFlowInputs.add(flowInputs);        
        List<CARE_IncomeQualificationController.FlowOutputs> listFlowOutputs=new List<CARE_IncomeQualificationController.FlowOutputs>();
        listFlowOutputs =CARE_IncomeQualificationController.getEnrollmentType(listFlowInputs);
        System.assertEquals('CARE', listFlowOutputs[0].sDiscountType);
        
        //FERA Qualified
        listFlowInputs.clear();  
        flowInputs.iNoOfHouseholds=7;
        flowInputs.dTotalIncome=80000;
    	listFlowInputs.add(flowInputs);
        listFlowOutputs =CARE_IncomeQualificationController.getEnrollmentType(listFlowInputs);
        System.assertEquals('FERA', listFlowOutputs[0].sDiscountType);
        
        //Ineligibe Scenario
		listFlowInputs.clear();  
        flowInputs.iNoOfHouseholds=13;
        flowInputs.dTotalIncome=75000;
    	listFlowInputs.add(flowInputs);
        listFlowOutputs =CARE_IncomeQualificationController.getEnrollmentType(listFlowInputs);
        System.assertEquals('CARE', listFlowOutputs[0].sDiscountType);
        Test.stopTest();
    }
    
    private static List<Low_Income_Qualification__c> createLowIncomeQualificationRecords(){
        List<Low_Income_Qualification__c> listQualificationRecords = new List<Low_Income_Qualification__c>();        
        Low_Income_Qualification__c qualificationRecord1 = new Low_Income_Qualification__c();
        qualificationRecord1.Name = 'CARE < 78,020 - #of household = 7';
        qualificationRecord1.Low_Income_Type__c = 'CARE';
        qualificationRecord1.No_of_Household__c = 7;
        qualificationRecord1.Qualifying_Income_Range_from__c = 0;
        qualificationRecord1.Qualifying_Income_Range_To__c = 78020;
        qualificationRecord1.Start_Date__c=Date.today()-30;
        qualificationRecord1.End_Date__c=Date.today()+30;
        qualificationRecord1.Additional_Person_Limit_Amount__c=884;
        listQualificationRecords.add(qualificationRecord1);
        
        Low_Income_Qualification__c qualificationRecord2 = new Low_Income_Qualification__c();
        qualificationRecord2.Name = 'CARE - Each additional person add  8,84';
        qualificationRecord2.Low_Income_Type__c = 'CARE';
        qualificationRecord2.No_of_Household__c = 99;
        qualificationRecord2.Qualifying_Income_Range_from__c = 0;
        qualificationRecord2.Qualifying_Income_Range_To__c = 8840;
        qualificationRecord2.Start_Date__c=Date.today()-30;
        qualificationRecord2.End_Date__c=Date.today()+30;
        qualificationRecord2.Additional_Person_Limit_Amount__c=884;
        listQualificationRecords.add(qualificationRecord2);
        
        Low_Income_Qualification__c qualificationRecord3 = new Low_Income_Qualification__c();
        qualificationRecord3.Name = 'FERA  income between  78,021 - 97,525 / #of household = 7';
        qualificationRecord3.Low_Income_Type__c = 'FERA';
        qualificationRecord3.No_of_Household__c = 7;
        qualificationRecord3.Qualifying_Income_Range_from__c = 78021;
        qualificationRecord3.Qualifying_Income_Range_To__c = 97525;
        qualificationRecord3.Start_Date__c=Date.today()-30;
        qualificationRecord3.End_Date__c=Date.today()+30;
        qualificationRecord3.Additional_Person_Limit_Amount__c=11050;
        listQualificationRecords.add(qualificationRecord3);
        
        Low_Income_Qualification__c qualificationRecord4 = new Low_Income_Qualification__c();
        qualificationRecord4.Name = 'FERA  - Each additional person per household - 11,050';
        qualificationRecord4.Low_Income_Type__c = 'FERA';
        qualificationRecord4.No_of_Household__c = 99;
        qualificationRecord4.Qualifying_Income_Range_from__c = 8840;
        qualificationRecord4.Qualifying_Income_Range_To__c = 11050;
        qualificationRecord4.Start_Date__c=Date.today()-30;
        qualificationRecord4.End_Date__c=Date.today()+30;
        qualificationRecord4.Additional_Person_Limit_Amount__c= 11050;
        listQualificationRecords.add(qualificationRecord4);
        
        return listQualificationRecords;        
    }
}