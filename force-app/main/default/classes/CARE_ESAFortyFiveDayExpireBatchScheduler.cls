/***********************************************************************************************************   
Apex Batch Class Name :  CARE_ESAFortyFiveDayExpireBatchScheduler
Version               :  1.0                                                                          
Created Date          :  08/14/2020
Function              :  This is the scheduler apex class to process ESA Expired 45 days response check.
Story                 :                                                                               
Work Task             :                                                                               
Modification Log      :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 08/14/2020            A8AI                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

global class CARE_ESAFortyFiveDayExpireBatchScheduler implements Schedulable{
	
    global void execute(SchedulableContext SC) {
        Id batchJobId = Database.executeBatch(new CARE_ESAFortyFiveDayExpireBatch());
        System.Debug('batchJobId = ' + batchJobId);
   }
}