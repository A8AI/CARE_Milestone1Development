/***********************************************************************************************************   
Apex Batch Class Name :  CARE_BatchEnrollmentDataXportScheduler
Version              :  1.0                                                                          
Created Date         :  07/27/2020                                                         
Function             :  This is the scheduler apex class to process enrollments received from DataXport system.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/27/2020            K1VM                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

global class CARE_BatchEnrollmentDataXportScheduler implements Schedulable {
    public final String sourceChannelType;
    global final Map<String, CARE_Type__c> sourceChannelMap;
    
    public CARE_BatchEnrollmentDataXportScheduler () {
        // Get the Source Channels with its Priority Order
        sourceChannelMap = CARE_AutoUtilityController.getAutoEnrollSourceChannels();
        System.Debug('sourceChannelMap = ' + sourceChannelMap);
    }
    
    public CARE_BatchEnrollmentDataXportScheduler (String sourceChannelType) {
        this.sourceChannelType = sourceChannelType;
        System.Debug('this.sourceChannelType = ' + this.sourceChannelType);
    }
    
    global void execute(SchedulableContext SC) {
        System.Debug('sourceChannelType = ' + sourceChannelType);
        System.Debug('sourceChannelMap = ' + sourceChannelMap);
        
        // Execute batch job to process enrollments of the provided Source Channel only
        if (String.isNotBlank(sourceChannelType)) {
            Id batchJobId = Database.executeBatch(new CARE_BatchEnrollmentDataXport(sourceChannelType, true));
            System.Debug('batchJobId = ' + batchJobId);
        
        } else {
            // Process enrollments of all Source Channels starting with the highest priority defined
            System.Debug('sourceChannelMap = ' + sourceChannelMap);
            
            String firstSourceChannel = '';
            
            // Get the base object for the first Source Channel
            for (String scType :sourceChannelMap.KeySet()) {
                firstSourceChannel = scType;
                System.Debug('firstSourceChannel = ' + firstSourceChannel);
                break;
            }
            if (String.isNotBlank(firstSourceChannel)) {
                if (sourceChannelMap.get(firstSourceChannel).TYPE_CODE__c == 'CARE_APP_Staging__c') {
                    Id batchJobId = Database.executeBatch(new CARE_BatchEnrollmentDataXport(firstSourceChannel));
                    System.Debug('batchJobId = ' + batchJobId);
                }
            } else {
                System.Debug('Unable to find the proper Batch Apex for the identified first Source Channel = ' + firstSourceChannel);
                
                List<String> toEmailAddrList = new List<String> ();
                
                // Get List of Email Address to which Processing Statistics should be sent at the end of batch processing
                toEmailAddrList = CARE_AutoUtilityController.getEmailList(CARE_Constants.CARE_STG_ENR_EMAIL_ADDR);
                System.Debug('toEmailAddrList = ' + toEmailAddrList);
                
                String emailSubject = 'Unable to find Batch Apex for the first Source Channel Type';
                String emailBody = 'Dear Salesforce COE Support Team,'
                                + '<br/><br/>'
                                + 'Unable to find the Batch Apex for the first Source Channel = ' + firstSourceChannel
                                + '<br/><br/>'
                                + 'Thanks & Regards,'
                                + '<br/>'
                                + 'Energy Insight Support Team.';
            System.Debug('emailBody = ' + emailBody);
                
                // Send an email to the email address (maintained in CARE_SYSTEM_VALUE object)
                CARE_AutoUtilityController.sendEmail('CARE_BatchEnrollmentDataXportScheduler', emailSubject, emailBody, toEmailAddrList);
            }
        }
   }
}