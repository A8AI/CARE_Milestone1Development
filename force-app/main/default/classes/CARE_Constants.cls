/***********************************************************************************************************   
Apex Util class Name :  CARE_Constants
Version              :  1.0                                                                          
Created Date         :  06/18/2020                                                         
Function             :  Class to hold all constant variables used in all Apex Classes
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/18/2020            SKMN                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/
public class CARE_Constants {

    //Record types of Care_Application
    public final static String RES_CUST_DEVELOPER_NAME = 'Residential_Customer';
    
    //Profiles
    public final static String SYS_ADMIN_PROFILE = 'System Administration';
    public final static String CARE_PROCESSOR_PROFILE = 'CARE Base Profile';
    public final static String CARE_PROCESSOR_ADMIN_PROFILE = '';
    
    //Variables
    
    public final static String CARE_LAN_ID_PLACEHOLDER = '<LAN ID>';
    public final static String CARE_DISCOUNT_TYPE_PLACEHOLDER = '[CARE or FERA]';
    public final static String CARE_CC_DATE_PLACEHOLDER = '[cc date]';
    public final static String CARE_SA_ID_PLACEHOLDER = '<SA ID>';
    public final static String CARE_INCOME_NOT_QUALIFIED='Not Eligible';
    public final static String CARE_EMP_DISCOUNT_CODE='EMP-DSC';    
    public final static String CARE_DEFAULT_RATE_SC = 'CARE';
    public final static String CARE_FERA_DISCOUNT_TYPE = 'FERA';
    public final static String CARE_CARE_DISCOUNT_TYPE = 'CARE';
    
    //Reason Category
    public final static String CARE_ADD_ELEC_GAS_RSN_CAT = 'Add Electric Gas Reason';
    public final static String CARE_ADJUSTMENT_RSN_CAT = 'Adjustment Reason';
    public final static String CARE_TRANSFER_RSN_CAT = 'Transfer Reason';
    public final static String CARE_REINSTATE_RSN_CAT = 'Reinstatement Reason';
    public final static String CARE_SEND_APP_RSN_CAT = 'CARE Enrollment Contact Codes';
    public final static String CARE_SEND_APP_CC_CODE = 'A';
    public final static String CARE_VALID_SA_CAT = 'Valid SA status';
    public final static String CARE_VALID_RATE_CAT = 'Valid Rate Schedule';
    public final static String CARE_REINSTATE_SRC = 'CASE/Reinstatement';
    public final static String CARE_TRANSFER_SRC = 'CASE/Transfer';
    public final static String CARE_ADD_ELEC_GAS_SRC = 'CASE/Commodity';
    public final static String CARE_ADJUSTMENT_SRC = 'CASE/Adjustment';
    
    public final static String CARE_CHANNEL_TYPE_REGULAR_APP = 'Regular App';
    
    //CC Code
    public final static Set<String> CARE_CC_CODE_CARE =  new Set<string>{'C','FC','R','FR','RANDOM CERT','H RAND CERT','7','TRANSFER','C AE CARE', 'ESA COMP'};
    public final static Set<String> CARE_CC_CODE_FERA =  new Set<string>{'C','R','C RANDOM','7','TRANSFER'};
    public final static String CARE_CC_REINSTATE_ADJUSTMENT = '6035';
    public final static String CARE_CC_REINSTATE_NO_ADJUSTMENT = '6040';   
    public final static String CARE_CC_TRANSFER_FROM = '6042';
    public final static String CARE_CC_TRANSFER_TO = '6044';   
    public final static String CARE_CC_ADD_ELEC_GAS = '6033';
    public final static String CARE_CC_ADJUSTMENT = '6034';
    public final static String CARE_CC_OnDemandDrop = '6026';
    
    //Messages
    public final static String CARE_INVALID_CUST_CODE = 'Customer not Eligible!!!';
    public final static String CARE_INVALID_CUST_MSG = 'Customer is currently on FERA discount or NO discount.';
    public final static String CARE_NO_SPECIAL_MSG = 'No Message Exists';
    public final static String CARE_APPLICATION_ERROR = 'Application Error. Please try again later.';
    
    
    //ImageUpload
    public final static String CARE_DISTRIBUTION_PUBLIC_URL = 'DistributionPublicUrl';
    public final static String CARE_CONTENT_DOWNLOAD_URL = 'ContentDownloadURL';
    public final static String CARE_DOCUMENTUM = 'DOCUMENTUM';
    public final static String CARE_DATAXPORT = 'DATAXPORT';
    
    //Application Status
    public final static String CARE_DECISION_MADE = 'Decision Made';
    
    
    
}