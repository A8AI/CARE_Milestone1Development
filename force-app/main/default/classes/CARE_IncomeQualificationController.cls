/***********************************************************************************************************   
Apex Util class Name :  CARE_IncomeQualificationController
Version              :  1.0                                                                          
Created Date         :  05/20/2020                                                         
Function             :  This is the Apex class for Identifying Discount Type (CARE/FERA) based on household Income 
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    						Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 05/20/2020            CTS                  			 			Initial Version.
*                                             	 					CARE Application: 
****************************************************************************************************************************************/

public with sharing class CARE_IncomeQualificationController {
    
    //Method to get the Eligible Discount Type(CARE/FERA) Based on No of Households and Total Income 
    @InvocableMethod
    public static List<FlowOutputs> getEnrollmentType(List<FlowInputs> listInputValues){
       List<FlowOutputs> listResults =new List<FlowOutputs>(); 
       try{
        //Get Input values from Flow
        Integer iNumOfHouseholds=listInputValues[0].iNoOfHouseholds;
        Decimal dTotalIncome= listInputValues[0].dTotalIncome;       
        String sEnrollmentType = CARE_Constants.CARE_INCOME_NOT_QUALIFIED;        
        Map<String,List<CAREFERAWrapper>> mapWrappersByType = new Map<String,List<CAREFERAWrapper>>();
        for(Low_Income_Qualification__c objQualification : [SELECT Id, Name, Low_Income_Type__c, No_of_Household__c, 
                                                         Qualifying_Income_Range_from__c, Qualifying_Income_Range_To__c
                                                         FROM Low_Income_Qualification__c
                                                         ORDER BY Low_Income_Type__c, No_of_Household__c])
        {
            List<CAREFERAWrapper> wrappers = (mapWrappersByType.containsKey(objQualification.Low_Income_Type__c)) ? 
                mapWrappersByType.get(objQualification.Low_Income_Type__c) : new List<CAREFERAWrapper>();
            wrappers.add(new CAREFERAWrapper(objQualification.No_of_Household__c, objQualification.Qualifying_Income_Range_from__c, objQualification.Qualifying_Income_Range_To__c));
            mapWrappersByType.put(objQualification.Low_Income_Type__c, wrappers);
        }
        
        if(null != mapWrappersByType && !mapWrappersByType.isEmpty())
        {
            for(String sEnrollType : mapWrappersByType.keySet()){
                List<CAREFERAWrapper> listWrappers = mapWrappersByType.get(sEnrollType);
                Set<Integer> setHouseholds = new Set<Integer>();
                Map<Integer,MinMaxWrapper> minMaxWrapperMap = new Map<Integer,MinMaxWrapper>();
                for(CAREFERAWrapper wrapper : listWrappers){
                    setHouseholds.add(Integer.valueOf(wrapper.noOfHouseholds));
                    minMaxWrapperMap.put(Integer.valueOf(wrapper.noOfHouseholds), new MinMaxWrapper(wrapper.minRange,wrapper.maxRange));
                }
                if(null != setHouseholds){
                    if(setHouseholds.contains(iNumOfHouseholds)){
                        MinMaxWrapper minMaxWrapper = minMaxWrapperMap.get(iNumOfHouseholds);
                        if(dTotalIncome > minMaxWrapper.minRange && dTotalIncome < minMaxWrapper.maxRange){
                            sEnrollmentType = sEnrollType;
                            break;
                        }
                    }else{
                        Integer iSize = setHouseholds.size();
                        Integer iMaxValInSet = new list<Integer>(setHouseholds)[iSize-1]; 
                        Integer iSecondMaxValInSet = new list<Integer>(setHouseholds)[iSize-2];
                        if(iNumOfHouseholds > iSecondMaxValInSet && iNumOfHouseholds < iMaxValInSet)
                        {
                            MinMaxWrapper secondMaxWrapper = minMaxWrapperMap.get(iSecondMaxValInSet);
                            MinMaxWrapper maxWrapper = minMaxWrapperMap.get(iMaxValInSet);
                            Integer iRemaining = iNumOfHouseholds - iSecondMaxValInSet;
                            Decimal dMinEligibleRange = (maxWrapper.minRange == 0) ? 0 : (secondMaxWrapper.minRange + (iRemaining * maxWrapper.minRange));
                                Decimal dMaxEligibleIncome = secondMaxWrapper.maxRange + (iRemaining * maxWrapper.maxRange);
                            if(dTotalIncome > dMinEligibleRange && dTotalIncome < dMaxEligibleIncome){
                                sEnrollmentType = sEnrollType;
                                break;
                            }
                        }
                    }
                }
            }
        }
        FlowOutputs outPut=new FlowOutputs();
        outPut.sDiscountType=sEnrollmentType;        
        listResults.add(outPut);       
       
       }
        catch (Exception ex) {
            system.debug(ex.getLineNumber()+ ': >' + ex.getMessage() + ': >' + ex.getStackTraceString());
        } 
        return listResults;
    } 
    
    
    //Wrapper class for Recieving input from flow 
    public class FlowInputs{
        @InvocableVariable
        public Integer iNoOfHouseholds;
        @InvocableVariable
        public Decimal dTotalIncome;
        
    }
    
    //Wrapper class for Recieving input from flow 
    public class FlowOutputs{
        @InvocableVariable
        public String sDiscountType;        
        
    }
    
    
    //Wrapper class for Storing Min and Max Range of Income based on No.Of household
    public class CAREFERAWrapper {
        public Decimal noOfHouseholds {get; set;}
        public Decimal minRange {get; set;}
        public Decimal maxRange {get; set;}
        
        public CAREFERAWrapper(Decimal noOfHouseholds, Decimal minRange, Decimal maxRange){
            this.noOfHouseholds = noOfHouseholds;
            this.minRange = minRange;
            this.maxRange = maxRange;
        }
    }
    
    //Wrapper class for Storing Min and Max Range of CARE/FERA 
    public class MinMaxWrapper {
        public Decimal minRange {get; set;}
        public Decimal maxRange {get; set;}
        public MinMaxWrapper(Decimal minRange, Decimal maxRange){
            this.minRange = minRange;
            this.maxRange = maxRange;
        }
    }
    
}