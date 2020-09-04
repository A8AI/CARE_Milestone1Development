/***********************************************************************************************************   
Apex Batch Class Name :  CARE_PEVFortyFiveDayBatchScheduler
Version               :  1.0                                                                          
Created Date          :  08/14/2020
Function              :  This is the scheduler apex class to process CARE PEV 45 days response check.
Story                 :                                                                               
Work Task             :                                                                               
Modification Log      :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 08/14/2020            A8AI                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

global class CARE_PEVFortyFiveDayBatchScheduler implements Schedulable{
	
    global void execute(SchedulableContext SC) {
        Id batchJobId = Database.executeBatch(new CARE_PEVFortyFiveDayBatch());
        System.Debug('batchJobId = ' + batchJobId);
   }
}