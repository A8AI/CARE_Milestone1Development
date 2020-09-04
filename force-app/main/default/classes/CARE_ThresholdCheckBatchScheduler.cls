/***********************************************************************************************************   
Apex Batch Class Name :  CARE_ThresholdCheckBatchScheduler
Version               :  1.0                                                                          
Created Date          :  08/14/2020
Function              :  This is the scheduler apex class to process threshold check.
Story                 :                                                                               
Work Task             :                                                                               
Modification Log      :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 08/14/2020            A8AI                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

global class CARE_ThresholdCheckBatchScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        Id batchJobId = Database.executeBatch(new CARE_ThresholdCheckBatch());
        System.Debug('batchJobId = ' + batchJobId);
   }

}