/***********************************************************************************************************   
Apex Batch Class Name :  CARE_BatchEnrollmentDataXportTest
Version              :  1.0                                                                          
Created Date         :  07/27/2020                                                         
Function             :  This is the Test Class for CARE_BatchEnrollmentDataXportScheduler scheduler apex class, CARE_BatchEnrollmentDataXport batch apex class, CARE_EnrollmentProcessingController apex class, CARE_AutoUtilityController apex class.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 07/27/2020            K1VM                   Initial Version.
*                                              CARE Application: 
****************************************************************************************************************************************/

@istest (SeeAllData = false)
class CARE_BatchEnrollmentDataXportTest {
    
    @testSetup
    static void createTestData() {
        // Create CARE_TYPE records defining the Source Channel Priority, base object, batch class
        List<CARE_TYPE__c> sourceChannelList = CARE_TestDataFactory.createSourceChannelsPriority();
        if (sourceChannelList != null && !sourceChannelList.isEmpty()) {
            insert sourceChannelList;
        }
        
        // Create Email Address to which email should be sent with Batch Processing Statistics or Error details
        List<CARE_SYSTEM_VALUE__c> careSysList = CARE_TestDataFactory.createEmailAddrForBatchJobs();
        if (careSysList != null && !careSysList.isEmpty()) {
            insert careSysList;
        }
        
        
        // Create CARE_TYPE records for Valid SA Status, Valid Rate Schedule, etc.
        List<CARE_TYPE__c> careTypeRecsList = createCareTypeRecords();
        if (careTypeRecsList != null && !careTypeRecsList.isEmpty()) {
            insert careTypeRecsList;
        }
        System.Debug('careTypeRecsList = ' + careTypeRecsList);
        
        // Fetch "System Administrator" Profile
        Profile sysAdmProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        System.Debug('sysAdmProfile = ' + sysAdmProfile);
        
        // Create a User with "System Administrator" profile
        User sysAdmUser = PM_EI_TestDataUtility.createUser();
        sysAdmUser.ProfileId = sysAdmProfile.Id;
        insert sysAdmUser;
        System.Debug('sysAdmUser = ' + sysAdmUser);
        
        String perId = '1234567890';
        String billAccId = '1212121212';
        String premId = '3333333333';
        
        // Create Premise records
        List<EI_Premise__c> premList = new List<EI_Premise__c> ();
        EI_Premise__c premiseRec = new EI_Premise__c ();
        premiseRec.Name = 'Premise Name';
        premiseRec.External_Id_EI__c = premId;
        premList.add(premiseRec);
        insert premList;
        System.Debug('premList = ' + premList);
        
        // Create Account records
        List<Account> accList = new List<Account> ();
        Account accRec = PM_EI_TestDataUtility.createAccount();
        accRec.AccountNumber = '1224590385';
        accRec.CARE_DISCOUNT_TYPE__c = 'FERA';
        accRec.Encrypted_Account_Name__c = 'Test Dummy Acct FERA';
        accRec.SAID__c = '8888888888';
        accRec.Phone = '9065231';
        accRec.Discount__c = 'F';
        accRec.Billing_Account_ID_EI__c = billAccId;
        accRec.Billing_Person_ID_EI__c = perId;
        accRec.Premise_ID__c = premId;
        accRec.Service_Address__c = 'Search1234';
        accRec.SA_Type__c = 'E';
        accRec.Encrypted_Account_Name__c = 'Encrypted';
        accRec.Type = 'Type';
        accRec.Rate__c = 'HAG1A';
        accRec.Branch_Code_EI__c = 'Get';
        accRec.Original_Tree_Level_EI__c = 2.0;
        accList.add(accRec);
        insert accList;
        System.Debug('accList = ' + accList);
        
        // Create SA (Site) records  
        List<EI_Site__c> SAList = createSARecords(new List<String> {billAccId}, premList, accList, 'E1');
        insert SAList;
        System.Debug('SAList = ' + SAList);
        
        // Create DataXport Staging records
        List<CARE_APP_STAGING__c> stgRecsList = createDXStagingRecords(new List<String> {billAccId});
        insert stgRecsList;
        System.Debug('stgRecsList = ' + stgRecsList);
    }
    
    // Create CARE_TYPE__c records for Valid SA Status, Valid Rate Schedule, etc.
    private static List<CARE_TYPE__c> createCareTypeRecords(){
        List<CARE_TYPE__c> lstCareTypes = new List<CARE_TYPE__c>();
        
        //Create records in Care Type for Valid Status and Valid Rate Schedule
        CARE_TYPE__c careType1 = new CARE_TYPE__c ();
        careType1.TYPE_DESC__c = '10,20';
        careType1.TYPE_NO__c = '6041';
        careType1.START_DATE__c = DATE.Today().addYears(-1);
        careType1.END_DATE__c = DATE.Today().addYears(1);
        careType1.CATEGORY__c = 'Valid SA status';
        careType1.IS_ACTIVE__c = true;
        lstCareTypes.add(careType1);
        
        CARE_TYPE__c careType2 = new CARE_TYPE__c ();
        careType2.TYPE_CODE__c = 'CARE';
        careType2.TYPE_DESC__c = 'HEV2AN,HEVAN,HEV2A,H2EV2AN,EV2A,E1,E6,HE1,HE6,HETOUA,HETOUB,HETOUC,ABS-TX2,ETOUA,ETOUB,ETOUC,G1,G1NGV,H2E6N,H2ETOUAN,H2ETOUBN,H2ETOUCN,HE1N,HE6N,HG1,HG1NGV,HETOUAN,HETOUBN,HETOUCN,STANDARD';
        careType2.TYPE_NO__c = '6042';
        careType2.START_DATE__c = DATE.Today().addYears(-1);
        careType2.END_DATE__c = DATE.Today().addYears(1);
        careType2.CATEGORY__c = 'Valid Rate Schedule';
        careType2.IS_ACTIVE__c = true;
        lstCareTypes.add(careType2);
        
        CARE_TYPE__c careType3 = new CARE_TYPE__c ();
        careType3.TYPE_CODE__c = 'FERA';
        careType3.TYPE_DESC__c = 'HEV2AN,HEVAN,HEV2A,H2EV2AN,EV2A,E1,E6,HE1,HE6,HETOUA,HETOUB,HETOUC,ABS-TX2,ETOUA,ETOUB,ETOUC,H2E6N,H2ETOUAN,H2ETOUBN,H2ETOUCN,HE1N,HE6N,HETOUAN,HETOUBN,HETOUCN';
        careType3.TYPE_NO__c = '6043';
        careType3.START_DATE__c = DATE.Today().addYears(-1);
        careType3.END_DATE__c = DATE.Today().addYears(1);
        careType3.CATEGORY__c = 'Valid Rate Schedule';
        careType3.IS_ACTIVE__c = true;
        lstCareTypes.add(careType3);
        
        return lstCareTypes;
    }    
    
    //Create Site records
    private static List<EI_Site__c> createSARecords(List<String> billAccIdList, List<EI_Premise__c> premList, List<Account> accList, String rateSchedule)
    {
        List<EI_Site__c> SAList = new List<EI_Site__c> ();
        Integer i = 0;
        for (String billAccId :billAccIdList)
        {
            // Create Electric SA
            EI_Site__c SARec1 = new EI_Site__c ();
            SARec1.Billing_Account_ID_EI__c = billAccId;
            SARec1.Account_EI__c = accList[i].Id;
            SARec1.Person_ID_EI__c = accList[i].Billing_Person_ID_EI__c;
            SARec1.Name = 'SA' + i;
            SARec1.Rate_Schedule_EI__c = rateSchedule;
            SARec1.Imported_Site_Name_EI__c = 'Customer SA ' + i;
            SARec1.Site_Premise_ID_EI__c = premList[i].External_Id_EI__c;
            SARec1.Care_Start_Date_EI__c = Date.Today().addYears(-1);
            SARec1.Care_Stop_Date_EI__c = Date.Today().addYears(1);
            SARec1.Svc_Status_Code_EI__c = '10';
            SARec1.Svc_Type_Code_EI__c = 'E';
            SAList.add(SARec1);
            
            // Create Gas SA
            EI_Site__c SARec2 = new EI_Site__c ();
            SARec2.Billing_Account_ID_EI__c = billAccId;
            SARec2.Account_EI__c = accList[i].Id;
            SARec2.Person_ID_EI__c = accList[i].Billing_Person_ID_EI__c;
            SARec2.Name = 'SA' + i;
            SARec2.Rate_Schedule_EI__c = rateSchedule;
            SARec2.Imported_Site_Name_EI__c = 'Customer SA ' + i;
            SARec2.Site_Premise_ID_EI__c = premList[i].External_Id_EI__c;
            SARec2.Care_Start_Date_EI__c = Date.Today().addYears(-1);
            SARec2.Care_Stop_Date_EI__c = Date.Today().addYears(1);
            SARec2.Svc_Status_Code_EI__c = '10';
            SARec2.Svc_Type_Code_EI__c = 'G';
            SAList.add(SARec2);
            
            // Create (inactive) Electric SA
            EI_Site__c SARec3 = new EI_Site__c ();
            SARec3.Billing_Account_ID_EI__c = billAccId;
            SARec3.Account_EI__c = accList[i].Id;
            SARec3.Person_ID_EI__c = accList[i].Billing_Person_ID_EI__c;
            SARec3.Name = 'SA' + i;
            SARec3.Rate_Schedule_EI__c = rateSchedule;
            SARec3.Imported_Site_Name_EI__c = 'Customer SA ' + i;
            SARec3.Site_Premise_ID_EI__c = premList[i].Id;
            SARec3.Care_Start_Date_EI__c = Date.Today().addYears(-1);
            SARec3.Care_Stop_Date_EI__c = Date.Today().addYears(1);
            SARec3.Svc_Status_Code_EI__c = '50';
            SARec3.Svc_Type_Code_EI__c = 'E';
            SAList.add(SARec3);
            
            i++;
        }
        
        return SAList;
    }
    
    private static List<CARE_APP_STAGING__c> createDXStagingRecords(List<String> billAccIdList)
    {
        List<CARE_APP_STAGING__c> stgRecsList = new List<CARE_APP_STAGING__c> ();
        
        // Create Staging records with Bad Account Id for DataXport source channel
        CARE_APP_STAGING__c stgRec01 = new CARE_APP_STAGING__c ();
        stgRec01.ACCT_ID__c = '12345678';
        stgRec01.APPLICATION_TYPE__c = 'RESIDENTIAL';
        stgRec01.ENROLLMENT_STATUS__c = 'Pending';
        stgRec01.ENROLLMENT_TYPE__c = 'ENROLLMENT';
        stgRec01.SOURCE_CHANNEL_TYPE__c = 'DataXport Enrollment';
        stgRecsList.add(stgRec01);
        
        // Create Staging records with Bad Account Id for Force.com source channel
        CARE_APP_STAGING__c stgRec02 = stgRec01.clone(false, false, false, false);
        stgRec02.SOURCE_CHANNEL_TYPE__c = 'CARE Force.com';
        stgRecsList.add(stgRec02);
        
        // Create Staging records with Bad Account Id for SMS source channel
        CARE_APP_STAGING__c stgRec03 = stgRec01.clone(false, false, false, false);
        stgRec03.SOURCE_CHANNEL_TYPE__c = 'CARE SMS';
        stgRecsList.add(stgRec03);
        
        
        // Create Staging records with Dupliates for DataXport source channel
        CARE_APP_STAGING__c stgRec11 = new CARE_APP_STAGING__c ();
        stgRec11.ACCT_ID__c = '1111122222';
        stgRec11.APPLICATION_TYPE__c = 'RESIDENTIAL';
        stgRec11.ENROLLMENT_STATUS__c = 'Pending';
        stgRec11.ENROLLMENT_TYPE__c = 'ENROLLMENT';
        stgRec11.SOURCE_CHANNEL_TYPE__c = 'DataXport Enrollment';
        stgRecsList.add(stgRec11);
        
        // Create Staging records with Duplicates for Force.com source channel
        CARE_APP_STAGING__c stgRec12 = stgRec11.clone(false, false, false, false);
        stgRec12.SOURCE_CHANNEL_TYPE__c = 'CARE Force.com';
        stgRecsList.add(stgRec12);
        
        // Create Staging records with Duplicates for SMS source channel
        CARE_APP_STAGING__c stgRec13 = stgRec11.clone(false, false, false, false);
        stgRec13.SOURCE_CHANNEL_TYPE__c = 'CARE SMS';
        stgRecsList.add(stgRec13);
        
        
        for (String billAccId :billAccIdList) {
            // Create Staging record for DataXport source channel
            CARE_APP_STAGING__c stgRec1 = new CARE_APP_STAGING__c ();
            stgRec1.ACCT_ID__c = billAccId;
            stgRec1.APPLICATION_TYPE__c = 'RESIDENTIAL';
            stgRec1.ENROLLMENT_STATUS__c = 'Pending';
            stgRec1.ENROLLMENT_TYPE__c = 'ENROLLMENT';
            stgRec1.SOURCE_CHANNEL_TYPE__c = 'DataXport Enrollment';
            stgRec1.REQUEST_DROP__c = 'N';
            stgRec1.EMAIL_ADDRESS__c = 'testEmailAddr@gmail.com';
            stgRec1.PHONE__c = '1234567890';
            stgRec1.PHONE_TYPE__c = 'Mobile';
            stgRec1.ALT_PHONE__c = '2345678901';
            stgRec1.ALT_PHONE_TYPE__c = 'Home';
            stgRec1.LANGUAGE_PREFERENCE__c = '1';
            stgRec1.MAIL_PREFERRED__c = 'Y';
            stgRec1.EMAIL_PREFERRED__c = 'N';
            stgRec1.PHONE_PREFERRED__c = 'N';
            stgRec1.TEXT_PREFERRED__c = 'N';
            stgRec1.NO_ADULT__c = 2;
            stgRec1.NO_CHILD__c = 1;
            stgRec1.LIHEAP__c = 'Y';
            stgRec1.WIC__c = 'N';
            stgRec1.CALFRESH_SNAP__c = 'N';
            stgRec1.CALWORKS_TANF__c = 'N';
            stgRec1.HEAD_START_INCOME__c = 'N';
            stgRec1.SSI__c = 'N';
            stgRec1.HEALTHY_FAMILIES__c = 'N';
            stgRec1.NSLP__c = 'N';
            stgRec1.BUREAU_INDIAN_AFFAIRS__c = 'N';
            stgRec1.MEDICAID_UNDER65__c = 'N';
            stgRec1.MEDICAID_OVER65__c = 'N';
            stgRec1.IS_FIXED_INCOME__c = 'N';
            stgRec1.ANNUAL_INCOME__c = 33820;
            stgRec1.IS_SIGNED__c = 'Y';
            stgRec1.DOC_RECEIVED_DATE__c = System.Today();
            stgRec1.APPCODE__c = '1234';
            stgRec1.IMAGE_ID__c = '1234567890';
            stgRec1.EXTERNAL_ID__c = 'RESDX_06/20/2020_EN_3787591698';
            stgRec1.APPLICANT_NAME__c = 'Customer Name';
            stgRec1.NO_PAGE__c = 0;
            stgRec1.COC_CODE__c = 'BILL';
            stgRec1.IS_RECERT__c = 'N';
            
            stgRecsList.add(stgRec1);
            
            // Create Staging record for Force.com source channel
            CARE_APP_STAGING__c stgRec2 = stgRec1.clone(false, false, false, false);
            stgRec2.SOURCE_CHANNEL_TYPE__c = 'CARE Force.com';
            stgRecsList.add(stgRec2);
            
            // Create Staging record for SMS source channel
            CARE_APP_STAGING__c stgRec3 = stgRec1.clone(false, false, false, false);
            stgRec3.SOURCE_CHANNEL_TYPE__c = 'CARE SMS';
            stgRecsList.add(stgRec3);
        }
        System.Debug('stgRecsList = ' + stgRecsList);
        
        return stgRecsList;
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXportSchedulerTest1() {
        
        Test.StartTest();
        
        CARE_BatchEnrollmentDataXportScheduler dXSchdlr = new CARE_BatchEnrollmentDataXportScheduler ();
        
        String cronExpr = '0 ' + (DateTime.Now().addMinutes(1)).Minute() + ' ' + DateTime.Now().Hour() + ' * * ?';
        String jobId = System.Schedule('Automated Enrollments Batch Processing', cronExpr, dXSchdlr);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cronExpr, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        // System.assertEquals(System.Today().Year() + '-' + System.Today().Month() + '-' + System.Today().Day() + ' 15:30:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
        
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXportSchedulerTest2() {
        // Delete CARE_TYPE__c records
        List<CARE_TYPE__c> sourceChannelList = [SELECT Id FROM CARE_TYPE__c];
        if (sourceChannelList != null && !sourceChannelList.isEmpty()) {
            delete sourceChannelList;
        }
        
        Test.StartTest();
        
        CARE_BatchEnrollmentDataXportScheduler dXSchdlr = new CARE_BatchEnrollmentDataXportScheduler ();
        
        // String cronExpr = '0 30 15 * * ?';
        String cronExpr = '0 ' + (DateTime.Now().addMinutes(1)).Minute() + ' ' + DateTime.Now().Hour() + ' * * ?';
        String jobId = System.Schedule('Automated Enrollments Batch Processing', cronExpr, dXSchdlr);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cronExpr, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        // System.assertEquals(System.Today().Year() + '-' + System.Today().Month() + '-' + System.Today().Day() + ' 15:30:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport1() {
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch1 = new CARE_BatchEnrollmentDataXport();
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport2() {
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch2 = new CARE_BatchEnrollmentDataXport('DataXport Enrollment');
        CARE_BatchEnrollmentDataXport dxBatch2_1 = new CARE_BatchEnrollmentDataXport('CARE Force.com');
        CARE_BatchEnrollmentDataXport dxBatch2_2 = new CARE_BatchEnrollmentDataXport('Phone Enrollment');
        CARE_BatchEnrollmentDataXport dxBatch2_3 = new CARE_BatchEnrollmentDataXport('CARE SMS');
        CARE_BatchEnrollmentDataXport dxBatch2_4 = new CARE_BatchEnrollmentDataXport('CARE LIHEAP');
        CARE_BatchEnrollmentDataXport dxBatch2_5 = new CARE_BatchEnrollmentDataXport('CARE New Mover');
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport3() {
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch3 = new CARE_BatchEnrollmentDataXport('DataXport Enrollment', true);
        CARE_BatchEnrollmentDataXport dxBatch3_1 = new CARE_BatchEnrollmentDataXport('CARE Force.com', true);
        CARE_BatchEnrollmentDataXport dxBatch3_2 = new CARE_BatchEnrollmentDataXport('Phone Enrollment', true);
        CARE_BatchEnrollmentDataXport dxBatch3_3 = new CARE_BatchEnrollmentDataXport('CARE SMS', true);
        CARE_BatchEnrollmentDataXport dxBatch3_4 = new CARE_BatchEnrollmentDataXport('CARE LIHEAP', true);
        CARE_BatchEnrollmentDataXport dxBatch3_5 = new CARE_BatchEnrollmentDataXport('CARE New Mover', true);
        // Execute the batch job
        Id batchJobId = Database.executeBatch(dxBatch3);
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport4() {
        List<EI_Site__c> SAList = new List<EI_Site__c> ();
        
        for (EI_Site__c SARec :[SELECT Id,Care_Start_Date_EI__c,Care_Stop_Date_EI__c FROM EI_Site__c]) {
            SARec.Care_Start_Date_EI__c = null;
            SARec.Care_Stop_Date_EI__c = null;
            SAList.add(SARec);
        }
        System.Debug('SAList = ' + SAList);
        
        if (SAList != null && !SAList.isEmpty()) {
            update SAList;
        }
        
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch4 = new CARE_BatchEnrollmentDataXport('DataXport Enrollment', true);
        // Execute the batch job
        Id batchJobId = Database.executeBatch(dxBatch4);
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport5() {
        List<EI_Site__c> SAList = new List<EI_Site__c> ();
        
        for (EI_Site__c SARec :[SELECT Id,Care_Start_Date_EI__c,Care_Stop_Date_EI__c FROM EI_Site__c]) {
            SARec.Care_Start_Date_EI__c = null;
            SARec.Care_Stop_Date_EI__c = null;
            SAList.add(SARec);
        }
        System.Debug('SAList = ' + SAList);
        
        if (SAList != null && !SAList.isEmpty()) {
            update SAList;
        }
        
        // Retain only 'CARE Force.com' Staging record and Delete all other Staging records
        List<CARE_APP_STAGING__c> stgRecsList = [SELECT Id FROM CARE_APP_STAGING__c WHERE Source_Channel_Type__c != 'CARE Force.com'];
        System.Debug('stgRecsList = ' + stgRecsList);
        delete stgRecsList;
        
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch4 = new CARE_BatchEnrollmentDataXport('CARE Force.com', true);
        // Execute the batch job
        Id batchJobId = Database.executeBatch(dxBatch4);
        Test.stopTest();
    }
    
    public static TestMethod void CARE_BatchEnrollmentDataXport6() {
        List<EI_Site__c> SAList = new List<EI_Site__c> ();
        
        for (EI_Site__c SARec :[SELECT Id,Care_Start_Date_EI__c,Care_Stop_Date_EI__c FROM EI_Site__c]) {
            SARec.Care_Start_Date_EI__c = null;
            SARec.Care_Stop_Date_EI__c = null;
            SAList.add(SARec);
        }
        System.Debug('SAList = ' + SAList);
        
        if (SAList != null && !SAList.isEmpty()) {
            update SAList;
        }
        
        // Retain only 'CARE SMS' Staging record and Delete all other Staging records
        List<CARE_APP_STAGING__c> stgRecsList = [SELECT Id FROM CARE_APP_STAGING__c WHERE Source_Channel_Type__c != 'CARE SMS'];
        System.Debug('stgRecsList = ' + stgRecsList);
        delete stgRecsList;
        
        Test.startTest();
        CARE_BatchEnrollmentDataXport dxBatch4 = new CARE_BatchEnrollmentDataXport('CARE SMS', true);
        // Execute the batch job
        Id batchJobId = Database.executeBatch(dxBatch4);
        Test.stopTest();
    }
    
}