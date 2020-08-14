/***********************************************************************************************************   
Apex Util class Name :  CARE_HistoryTabControllerTest
Version              :  1.0                                                                          
Created Date         :  06/05/2020                                                         
Function             :  This is the Test class for Apex Controller of Care Transfer Controller.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                   Who                   								Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/05/2020             AATG                                              Initial Version.
*                                                                          CARE Application: 
****************************************************************************************************************************************/

@istest

public class CARE_TransferControllerTest {
   
    static final String CARE_PROCESSOR_USR = 'CareProcessorUser'; 
    
    @testSetup
    public static void makeData(){
        
        Profile p = [select id from Profile where name =: CARE_Constants.CARE_PROCESSOR_PROFILE LIMIT 1];
        
        //Create user record
        User usr = PM_EI_TestDataUtility.createUser();
        usr.LastName = CARE_PROCESSOR_USR;
        usr.profileid = p.Id;
        insert usr;
        
        //Create Account record
            
        List<Account> listAccountRecords = createAccountRecords();
        insert listAccountRecords;
        
        //Create Site record
        List<EI_Site__c> listSiteRecords = createSiteRecords(listAccountRecords);
        insert listSiteRecords;
        
        //Create CareType record
        List<CARE_Type__c> lstCareTypes = createCareTypeRecords();
        insert lstCareTypes;
 
    }
   
    @isTest
    static void testGetTranferDetails(){
        Test.startTest();
        String sPerId = '0123456003';
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        CARE_TransferController.WrapperTranferResponse transferResponse = new CARE_TransferController.WrapperTranferResponse();      
        System.runAs(user1[0]){  
            transferResponse =  CARE_TransferController.getTranferDetails(sPerId);
            system.assertEquals('E', transferResponse.listTransferFrom[0].sSAType);
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testupdateSADetails(){
        Test.startTest();
        
        List<CARE_TransferController.WrapperTransfer> listTranferFrom = new List<CARE_TransferController.WrapperTransfer>();
        List<CARE_TransferController.WrapperTransfer> listTranferTo= new List<CARE_TransferController.WrapperTransfer>();
        CARE_TransferController.WrapperTransferInput objTransferInputWrapper = new CARE_TransferController.WrapperTransferInput();
        list<User> user1 = [select id from user where lastname = :CARE_PROCESSOR_USR];
        String sPerId = '0123456003'; 
        
        EI_SITE__C EISiteActiveRec = [SELECT ID, SAID_EI__c, Svc_Type_Code_EI__c, Site_Premise_ID_EI__c, Svc_Full_Adr_EI__c,Rate_Schedule_EI__c,Imported_Site_Name_EI__c, SA_Start_Date_EI__c, 
                                      Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, CARE_DISCOUNT_TYPE__c, Billing_Account_ID_EI__c, Account_EI__r.Id
                                      FROM EI_Site__c WHERE Person_Id_EI__C =:sPerID AND Care_Stop_Date_EI__c >: Date.Today() LIMIT 1];
        
        CARE_TransferController.WrapperTransfer objTransferFrom = new CARE_TransferController.WrapperTransfer();
        
        objTransferFrom.idSARecID =  EISiteActiveRec.Id;
        objTransferFrom.sAccountId =  EISiteActiveRec.Billing_Account_ID_EI__c;
        objTransferFrom.sAccId =  EISiteActiveRec.Account_EI__r.Id;
        objTransferFrom.sPremiseId =  EISiteActiveRec.Site_Premise_ID_EI__c;
        objTransferFrom.sSAId =  EISiteActiveRec.SAID_EI__c;
        objTransferFrom.sSAType =  EISiteActiveRec.Svc_Type_Code_EI__c;
        objTransferFrom.sDiscountType =  EISiteActiveRec.Account_EI__r.CARE_DISCOUNT_TYPE__c;
        objTransferFrom.sSADiscountType = EISiteActiveRec.CARE_DISCOUNT_TYPE__c;
        objTransferFrom.dEndDate = EISiteActiveRec.Care_Stop_Date_EI__c;
        objTransferFrom.sRateSchedule = EISiteActiveRec.Rate_Schedule_EI__c; 
        objTransferFrom.dSAStartDate = EISiteActiveRec.SA_Start_Date_EI__c;
        objTransferFrom.sApplicantName = EISiteActiveRec.Imported_Site_Name_EI__c;
        
        listTranferFrom.add(objTransferFrom); 
        
        EI_SITE__C EISiteInActiveRec =  [SELECT ID, SAID_EI__c, Svc_Type_Code_EI__c, Site_Premise_ID_EI__c, Svc_Full_Adr_EI__c, Svc_Status_Code_EI__c,Imported_Site_Name_EI__c,SA_Start_Date_EI__c, 
                                         Care_Start_Date_EI__c, Care_Stop_Date_EI__c, Account_EI__r.CARE_DISCOUNT_TYPE__c, CARE_DISCOUNT_TYPE__c,  Billing_Account_ID_EI__c, Account_EI__r.Id, Rate_Schedule_EI__c  
                                         FROM EI_Site__c 
                                         WHERE Person_Id_EI__C =:sPerID And Care_Stop_Date_EI__c <:Date.Today() LIMIT 1];
        
        CARE_TransferController.WrapperTransfer objTransferTo = new CARE_TransferController.WrapperTransfer();
        
        objTransferTo.idSARecID =  EISiteInActiveRec.Id;
        objTransferTo.sAccountId =  EISiteInActiveRec.Billing_Account_ID_EI__c;
        objTransferTo.sAccId =  EISiteInActiveRec.Account_EI__r.Id;
        objTransferTo.sAddress = EISiteInActiveRec.Svc_Full_Adr_EI__c;
        objTransferTo.sPremiseId =  EISiteInActiveRec.Site_Premise_ID_EI__c;
        objTransferTo.sSAId =  EISiteInActiveRec.SAID_EI__c;
        objTransferTo.sSAType =  EISiteInActiveRec.Svc_Type_Code_EI__c;                  
        objTransferTo.sSAStatus = EISiteInActiveRec.Svc_Status_Code_EI__c;
        objTransferTo.sRateSchedule = EISiteInActiveRec.Rate_Schedule_EI__c; 
        objTransferTo.dSAStartDate = EISiteInActiveRec.SA_Start_Date_EI__c;               
        objTransferTo.bOverRide = false; 
        objTransferTo.sSelectedRecord = true;    
        objTransferTo.bSelectionDisabled = true; 
        
        listTranferTo.add(objTransferTo);
        
        //Details Selected From UI    
        CARE_Type__c objCareTpe = [SELECT ID,TYPE_CODE__c, TYPE_DESC__c, TYPE_DESC_LONG__c  FROM CARE_Type__c 
                                   WHERE TYPE_NO__c ='6037'];
        objTransferInputWrapper.sComment = objCareTpe.TYPE_DESC_LONG__c ;
        objTransferInputWrapper.sPerId = sPerId;
        objTransferInputWrapper.sReason ='Customer Request';
        
        System.runAs(user1[0]){  
            
            Boolean Result = CARE_TransferController.updateSADetails( listTranferFrom, listTranferTo, objTransferInputWrapper);
            system.assertEquals(true, Result);
        }
        Test.stopTest();
    }
    
  
    
   private static List<CARE_Type__c> createCareTypeRecords(){
        List<CARE_Type__c> lstCareTypes = new List<CARE_Type__c>();
        
        //Create records in Care Type for displaying in Reason dropdown
        CARE_Type__c careType2 = CARE_TestDataFactory.careType();
        careType2.TYPE_NO__c = '6044';
        careType2.TYPE_DESC__c = 'Customer Request';
        careType2.CATEGORY__c  = 'Transfer Reason';
        lstCareTypes.add(careType2);
        
        CARE_Type__c careType3 = CARE_TestDataFactory.careType();
        careType3.TYPE_NO__c = '6037';
        careType3.TYPE_DESC__c = 'DISCOUNT TRANSFER TO DIFFERENT SA <SA ID>';
         careType3.TYPE_CODE__c = 'TRANSFER';
        careType3.CATEGORY__c  = 'Account Transfer';
        lstCareTypes.add(careType3);
        
        //Create records in Care Type for Valid Status and Valid Rate Schedule
        CARE_Type__c careType4 = CARE_TestDataFactory.careType();
        careType4.TYPE_NO__c = '6042';
        careType4.TYPE_CODE__c = 'CARE';
        careType4.TYPE_DESC__c = '10,20';
        careType4.CATEGORY__c  = 'Valid SA status';
        lstCareTypes.add(careType4);
        
        CARE_Type__c careType5 = CARE_TestDataFactory.careType();
        careType5.TYPE_NO__c = '14';
        careType5.TYPE_CODE__c = 'CARE';
        careType5.TYPE_DESC__c = 'STANDARD,E-RES,G-RES,HE-RES,HG-RES,PT-E-RES,HN-E-RES';
        careType5.CATEGORY__c  = 'Valid Rate Schedule';
        lstCareTypes.add(careType5);
        
        return lstCareTypes;
    }
    private static List<Account> createAccountRecords(){
        List<Account> listAccountRecords = new List<Account>();
               
        Account objAccountRecord = PM_EI_TestDataUtility.createAccount();
        objAccountRecord.AccountNumber = '1224590384';
        objAccountRecord.CARE_DISCOUNT_TYPE__c = 'CARE';
        objAccountRecord.Encrypted_Account_Name__c = 'Test Dummy Acct';
        objAccountRecord.SAID__c = '7777777777';
        objAccountRecord.Phone = '9065231';
        objAccountRecord.Discount__c = 'C';
        objAccountRecord.Billing_Person_ID_EI__c = '0123456003';
        objAccountRecord.Service_Address__c = 'Search1234';
        objAccountRecord.SA_Type__c = 'E';
        objAccountRecord.Encrypted_Account_Name__c = 'Encrypted';
        objAccountRecord.Type = 'Type';
        objAccountRecord.Rate__c = 'HAG1A';
        objAccountRecord.Branch_Code_EI__c = 'Get';
        objAccountRecord.Original_Tree_Level_EI__c = 2.0;
        listAccountRecords.add(objAccountRecord);  
        
        return listAccountRecords;
    }
    private static List<EI_Site__c> createSiteRecords(List<Account> listAccountRecords){
        List<EI_Site__c> listSiteRecords = new List<EI_Site__c>();
        
        //Site record with status as '20', with valid Rate Schedule, and discount in 'Electric'
        EI_Site__c objSite1 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite1.Name='Site1';
        objSite1.Rate_Schedule_EI__c='STANDARD';
        objSite1.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite1.Site_Premise_ID_EI__c = 'Prem1';
        objSite1.Care_Start_Date_EI__c = date.today();
        objSite1.Care_Stop_Date_EI__c = date.today()+30;
        objSite1.Svc_Status_Code_EI__c = '20';
        objSite1.Svc_Type_Code_EI__c = 'E';
        listSiteRecords.add(objSite1);
        
        //Site record with status as '30', with invalid Rate Schedule, and discount in 'Gas'
        EI_Site__c objSite2 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite2.Name='Site2';
        objSite2.Rate_Schedule_EI__c='EVA';
        objSite2.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite2.Site_Premise_ID_EI__c = 'Prem2';
        objSite2.Care_Start_Date_EI__c = date.today();
        objSite2.Care_Stop_Date_EI__c = date.today()+60;
        objSite2.Svc_Status_Code_EI__c = '30';
        objSite2.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite2);    
        
        //Site record with status as '10', and Care_Stop_Date_EI__c <todays date, so that it is not in any discount for 'Gas'
        EI_Site__c objSite3 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite3.Name='Site3';
        objSite3.Rate_Schedule_EI__c='STANDARD';
        objSite3.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite3.Site_Premise_ID_EI__c = 'Prem1';
        objSite3.Care_Start_Date_EI__c = date.today()-10;
        objSite3.Care_Stop_Date_EI__c = date.today()-5;
        objSite3.Svc_Status_Code_EI__c = '10';
        objSite3.Svc_Type_Code_EI__c = 'G';
        listSiteRecords.add(objSite3);    
        
        //Create record with valid status, valid Rate schedule, Care Stop Date > todays date
        EI_Site__c objSite4 = CARE_TestDataFactory.createSite(listAccountRecords);
        objSite4.Name='Site4';
        objSite4.Rate_Schedule_EI__c='STANDARD';
        objSite4.Billing_Account_ID_EI__c = '6767676767';
        objSite4.Imported_Site_Name_EI__c = 'MEDRANO,JOSE';
        objSite4.Site_Premise_ID_EI__c = 'Prem3';
        objSite4.Care_Start_Date_EI__c = date.today()-10;
        objSite4.Care_Stop_Date_EI__c = date.today()+5;
        objSite4.SAID_EI__c = '6456456456';
        objSite4.Svc_Status_Code_EI__c = 'E';
        listSiteRecords.add(objSite4);
        
        return listSiteRecords;
    }
    
   }