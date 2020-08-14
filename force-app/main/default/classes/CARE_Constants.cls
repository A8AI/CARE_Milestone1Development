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
    public final static String CARE_DISCOUNT_TYPE_PLACEHOLDER = '<CARE or FERA>';
    public final static String CARE_DISCOUNT_TYPE_SELECT = 'CARE or FERA';
    public final static String CARE_CC_DATE_PLACEHOLDER = '<cc date>';
    public final static String CARE_SA_ID_PLACEHOLDER = '<SA ID>';
    public final static String CARE_INCOME_NOT_QUALIFIED='Not Eligible';
    public final static String CARE_EMP_DISCOUNT_CODE='EMP-DSC';    
    public final static String CARE_DEFAULT_RATE_SC = 'CARE';
    public final static String CARE_FERA_DISCOUNT_TYPE = 'FERA';
    public final static String CARE_CARE_DISCOUNT_TYPE = 'CARE';
    public final static String CARE_Customer_OnProbation = 'On Probation';
    public final static String CARE_Customer_Not_OnProbation = 'Not On Probation';
    
    //Integer Variables
    public final static Integer CARE_BeforeTwoYears = 2;
    public final static Integer CARE_FortyFiveDay = 45;
    public final static Integer CARE_BeforeTenYears = 10;
    public final static Integer CARE_BeforeSixMonths = 180;
    public final static Integer CARE_BeforeTwoYearsInDays = 730;
    public final static Integer CARE_BeforeSixEightyFiveDays = 685;
    public final static Integer CARE_PEV_SystemValueCode = 810;
    public final static Integer CARE_HU_SystemValueCode = 820;
    public final static Integer CARE_ESA_SystemValueCode = 830;
    
    //Reason Category
    public final static String CARE_ADD_ELEC_GAS_RSN_CAT = 'Add Electric Gas Reason';
    public final static String CARE_ADJUSTMENT_RSN_CAT = 'Adjustment Reason';
    public final static String CARE_TRANSFER_RSN_CAT = 'Transfer Reason';
    public final static String CARE_REINSTATE_RSN_CAT = 'Reinstatement Reason';
    public final static String CARE_OnDemandStatus_RSN_CAT = 'On Demand Status Reason';
    public final static String CARE_SEND_APP_RSN_CAT = 'CARE Enrollment Contact Codes';
    public final static String CARE_SEND_APP_CC_CODE = 'A'; //No longer in use
    public final static String CARE_VALID_SA_CAT = 'Valid SA status';
    public final static String CARE_VALID_RATE_CAT = 'Valid Rate Schedule';
    public final static String CARE_REINSTATE_SRC = 'CASE/Reinstatement';
    public final static String CARE_TRANSFER_SRC = 'CASE/Transfer';
    public final static String CARE_ADD_ELEC_GAS_SRC = 'CASE/Commodity';
    public final static String CARE_ADJUSTMENT_SRC = 'CASE/Adjustment';
    public final static Set<String> CARE_REINSTATE_RSN_ESA_COMP =  new Set<string>{'ESA COMP Reinstatement'};
    
    //Source Channel Type
    public final static String CARE_CHANNEL_TYPE_REGULAR_APP = 'Regular App';
    public final static String CARE_CHANNEL_TYPE_BATCH = 'Batch';
    
    //ENROLLMENT TYPE
    public final static String CARE_ENROLLMENT = 'ENROLLMENT';
    public final static String CARE_ENROLLMENT_OTHER = 'OTHER';
    public final static String CARE_APPLICATION_TYPE = 'Other';
    public final static String CARE_PEV = 'PEV';
    public final static String CARE_PEV_HU = 'PEV HU';
    public final static String CARE_PEV_SENT = 'PEV Sent';
    
    //App Type
    public final static String CARE_APP_PEV = 'PEV';
    public final static String CARE_APP_HU = 'HU';
    
    //CC Code
    public final static Set<String> CARE_CC_CODE_CARE =  new Set<string>{'C','FC','R','FR','RANDOM CERT','H RAND CERT','7','TRANSFER','C AE CARE', 'ESA COMP'};
    public final static Set<String> CARE_CC_CODE_FERA =  new Set<string>{'C','R','C RANDOM','7','TRANSFER'};
    public final static String CARE_CC_REINSTATE_ADJUSTMENT = '6035';
    public final static String CARE_CC_REINSTATE_NO_ADJUSTMENT = '6040';   
    public final static String CARE_CC_REINSTATE_ADJUSTMENT_ESA_COMP = '6041';
    public final static String CARE_CC_REINSTATE_NO_ADJUSTMENT_ESA_COMP = '6036';   
    public final static String CARE_CC_TRANSFER_FROM = '6042';
    public final static String CARE_CC_TRANSFER_TO = '6037';
    public final static String CARE_CC_OnDemandTRANSFER = '6044';   
    public final static String CARE_CC_ADD_ELEC_GAS = '6033';
    public final static String CARE_CC_ADJUSTMENT = '6034';
    public final static String CARE_CC_SEND_APP = '6045';
    public final static String CARE_CC_OnDemandDrop = '6026';
    public final static String CARE_CC_PEVOnDemand = '6027';
    public final static String CARE_CC_PEVHighUsageOnDemand = '6028';
    public final static String CARE_History_QueryLimit = '10';
    public final static String CARE_OnDemandDrop_QueryLimit = '1';
    public final static Set<String> CARE_CC_CODE_PEV_OR_HU =  new Set<string>{'V', 'VE', 'VH', 'VHE'};
    public final static String CARE_CC_DROPESA = 'DE';
    public final static String CARE_CC_DROPHU = 'DH';
    public final static String CARE_CC_HU = 'VH';
    public final static String CARE_CC_HU_NORESPONSE = 'NH';
    public final static String CARE_CC_HU_NORESPONSE_NO = '129';
    public final static String CARE_CC_PEV = 'V';
    public final static String CARE_CC_HUAPPEAL = 'M';
    public final static String CARE_CC_HUAPPEAL_NO = '6046';
    public final static String CARE_CC_REINSTATEHU = '7';
    public final static String CARE_CC_REACH = '119';
    public final static String CARE_CC_LIHEAP = '120';
    public final static String CARE_CC_ESA = '121';
    public final static String CARE_CC_PEVDROP = 'N';
    public final static String CARE_CC_PEVDROP_NO = '101';
    public final static String CARE_CC_ESA_ENROLLMENTCHECK = 'H RAND CERT';
    public final static String CARE_CC_CRANDOM = 'C RANDOM';
    public final static String CARE_CC_ESA_ENROLLED = '127';
    public final static String CARE_CC_HU_DROP = '128';
    public final static String CARE_CC_ESA_EXPIRE = '132';
    public final static String CARE_CC_VH_HU = '124';
    public final static String CARE_CC_V_HU = '116';
    
    //Probation logic CC Codes
    public final static Set<String> CARE_CC_CODE_PROBATION_ONE =  new Set<string>{'N','3','J'};
    public final static Set<String> CARE_CC_CODE_PROBATION_TWO =  new Set<string>{'NH','DE','DH'};
    public final static Set<String> CARE_CC_CODE_NOT_PROBATION_ONE =  new Set<string>{'H RAND CERT','RANDOM CERT'};
    public final static Set<String> CARE_CC_CODE_VSTAMP =  new Set<string>{'H RAND CERT','RANDOM CERT', 'C RANDOM'};
    public final static Set<String> CARE_CC_CODE_NOT_PROBATION_TWO =  new Set<string>{'H RAND CERT','ESA COMP','6036','6041','6046'};
    public final static Set<String> CARE_CC_CODE_NOT_PROBATION_THREE =  new Set<string>{'H RAND CERT','ESA COMP'};
    public final static Set<String> CARE_CC_CODE_NOT_PROBATION_TYPENO =  new Set<string>{'6036','6041','6046'};
    public final static Set<String> CARE_CC_CODE_NOT_PROBATION_TYPENO_ESACOMP =  new Set<string>{'6036','6041'};
    public final static Set<String> CARE_CC_CODE_PROBATION =  new Set<string>{'NH','DE','DH','N','3','J'};
    
    //Messages
    public final static String CARE_INVALID_CUST_CODE = 'Customer not Eligible!!!';
    public final static String CARE_INVALID_CUST_MSG = 'Customer is currently on FERA discount or NO discount.';
    public final static String CARE_NO_SPECIAL_MSG = 'No Message Exists';
    public final static String CARE_APPLICATION_ERROR = 'Application Error. Please try again later.';
    public final static String CARE_ONDEMANDPEV_ERROR = 'Selected Customer is not eligible for PEV/HU.';
    public final static String CARE_PEV_DROP = 'PEV Dropped - No Response';
    public final static String CARE_PEV_DROP_HU = 'DROPPED FOR HIGH USAGE';
    public final static String CARE_PEV_VH_HU = 'PEV Sent High Usage';
    public final static String CARE_VCODE_VALIDATIONFAIL = 'V Code Loading Validation Check Failed';
    public final static String CARE_VHCODE_VALIDATIONFAIL = 'VH Code Loading Validation Check Failed';
    public final static String CARE_PROCESSING_ERROR = 'Error';
    public final static String CARE_PROCESSING_SUCCESS = 'Processed';
    public final static String CARE_PROCESSING_LOADED = 'Loaded';
    
    
    //ImageUpload
    public final static String CARE_DISTRIBUTION_PUBLIC_URL = 'DistributionPublicUrl';
    public final static String CARE_CONTENT_DOWNLOAD_URL = 'ContentDownloadURL';
    public final static String CARE_DOCUMENTUM = 'DOCUMENTUM';
    public final static String CARE_DATAXPORT = 'DATAXPORT';
    public final static String CARE_CASE = 'CASE';
    
    // SA Statuses
    public final static Set<String> CARE_SA_ACTIVE_STATUSES = new Set<string>{'10','20'};
    
    //SA TYPE
    public final static String CARE_GAS_SA_TYPE= 'G';
    public final static String CARE_ELECTRIC_SA_TYPE= 'E';
    
    //Application Status
    public final static String CARE_IN_PROGRESS = 'In-Progress';
    public final static String CARE_DECISION_MADE = 'Decision Made';
    public final static String CARE_STAGED_CCB = 'Staged for CC&B';
    
    //Income Source
    public final static Set<String> CARE_PEV_HU_INCOME_SOURCE = new Set<string>{'High Usage'};
    public final static Set<String> CARE_PEV_INCOME_SOURCE_CATEGORICAL = new Set<string>{'Categorical'};
    public final static Set<String> CARE_PEV_INCOME_SOURCE_CATEGORICAL_FIXED = new Set<string>{'Categorical Fixed'};
    public final static Set<String> CARE_PEV_INCOME_DOCUMENT_CATEGORICAL = new Set<string>{'Award Letter -Categorical'};
    public final static Set<String> CARE_PEV_INCOME_DOCUMENT_CATEGORICAL_FIXED = new Set<string>{'Award Letter -Categorical Fixed'};
    
    // CARE_APP_Staging - Enrollment Statuses
    public final static String CARE_STG_ENR_STATUS_NEW = 'New';
    public final static String CARE_STG_ENR_STATUS_PENDING = 'Pending';
    public final static String CARE_STG_ENR_STATUS_COMPLETED = 'Completed';
    public final static String CARE_STG_ENR_STATUS_ERROR = 'Error';
    public final static String CARE_STG_ENR_STATUS_IGNORED = 'Ignored';
    public final static String CARE_STG_ENR_STATUS_IN_PROGRESS = 'In-Progress';
    public final static String CARE_STG_ENR_STATUS_CANCELLED = 'Cancelled';
    
    // CARE_APP_Staging - Category Name used for Source Channels Priority order in CARE_TYPE object
    public final static String CARE_STG_ENR_SOURCE_CHANNEL_CATEGORY = 'Automated Staging Enrollments Priority Order';
    public final static String CARE_STG_PEV_ARRV_SOURCE_CHANNEL_CATEGORY = 'Automated Staging PEV Arrival Notice Priority Order';
    public final static String CARE_STG_ENR_LANGUAGE_SOURCE_CATEGORY = 'Language Source';
    
    // List of CARE_Application__c.APPLICATION_STATUS__c values that need to be considered as OPEN CARE_Application for Duplicates check in Automated Enrollments Batch Processes
    public final static Set<String> CARE_STG_ENR_CARE_APP_OPEN_STATUSES = new Set<string>{'NEW', 'PENDING', 'IN-PROGRESS', 'DECISION MADE', 'STAGED FOR CC&B'};
    public final static Set<String> CARE_STG_ENR_CARE_APP_OPEN_STATUS_FOR_TODAY = new Set<string>{'SENT TO CC&B'};
    
    // CARE_APP_Staging - Error Codes
    public final static String CARE_STG_ENR_ERROR_CODE_BAD_ACC = 'Bad ACC ID';
    public final static String CARE_STG_ENR_ERROR_CODE_DUP = 'Duplicate';
    public final static String CARE_STG_ENR_ERROR_CODE_IRS = 'Invalid Rate Schedule';
    
    // Email Address to which automated enrollments statistics details to be sent
    public final static String CARE_STG_ENR_EMAIL_ADDR = 'Automated Enrollments BatchJob Email List';
    
    //System Code To Fetch To Email Address From CARE SYSTEM VALUE For Exception Logging 
    public final static List<Integer> CARE_SUPPORT_TEAM_EMAIL_CODE= New List<Integer>{500,510};
    //System Code To Fetch To Flag for Enable Internal Email Functionality  From CARE SYSTEM VALUE For Exception Logging 
    public final static List<Integer> CARE_SUPPORT_TEAM_EMAIL_FLAG_CODE= New List<Integer>{505};
    
    // CRON expression to process automated enrollments statistics details to be sent
    public final static String CARE_STG_ENR_CRON_EXPR = 'Automated Enrollments BatchJob CRON Expression'; 
    
    // CARE_APP_Staging - Error Messages
    public final static String CARE_STG_ENR_ERROR_MSG_BAD_ACC = 'INVALID ACCT or ACCT NOT IN CCB DOWNLOAD.';
    public final static String CARE_STG_ENR_ERROR_MSG_DUP = 'DUPLICATE ENTRY BASED ON BILLING ACCT ID.';
    public final static String CARE_STG_ENR_ERROR_MSG_IRS = 'INVALID RATE SCHEDULE.';
    
    //Care Household Detail status
    public final static String CARE_HH_DET_INC_STS_VALID = 'Valid';
    public final static String CARE_HH_DET_INC_STS_INVALID = 'Invalid';
    
    //Class Names
    public final static String CLASS_NAME_CARE_PEVHU_CONTROLLER = 'CARE_PEVHUController';
    public final static String CLASS_NAME_CARE_ADJUSTMENT_CONTROLLER = 'CARE_AdjustmentController';
    public final static String CLASS_NAME_CARE_SEND_APP_CONTROLLER = 'CARE_SendAppController';
    public final static String CLASS_NAME_CARE_IMAGE_CONTROLLER = 'CARE_ImageUploadController';
    public final static String CLASS_NAME_CARE_ADD_ELECGAS_CONTROLLER = 'CARE_AddElecGasController';
    
}