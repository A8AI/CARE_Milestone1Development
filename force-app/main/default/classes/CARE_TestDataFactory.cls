public class CARE_TestDataFactory {
    
    /*public static List<Account> retrieveAcc(Integer numberOfAccs) {
List<Account> lstAcc = new List<Account>();
for (integer i=0;i<numberOfAccs;i++)
{
Account Obj = new Account();
Obj.Name = 'Test'+i;
Obj.Premise_ID__c = 'A1234BC';
Obj.AccountNumber = '12245903841';
Obj.SAID__c = 'E';
//obj.F_Person_ID_EI__c = 'A786HI';
obj.Discount__c = 'F';
obj.Service_Address__c = 'Search1234';
obj.SA_Type__c = 'G';
obj.Encrypted_Account_Name__c = 'Encrypted';
obj.Type = 'Type';
obj.Rate__c = 'HAG1A';
obj.Branch_Code_EI__c = 'Get';
obj.Original_Tree_Level_EI__c = 2.0;

lstAcc.add(Obj);
}
return lstAcc;
}
public static List<User> userSearch(Integer numberOfUsers){ 
Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
List<User> lstUser = new List<User>();
for(integer i=0;i<=numberOfUsers;i++){
User u = new User(Alias = 'standt', Email='standarduser0@testorg.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='America/Los_Angeles', UserName='standarduser0'+(i+1)+'@testorg.com');
lstUser.add(u);
}
return lstUser;
}

public static List<EI_Site__c> SiteData(Integer numberOfSite) {
List<EI_Site__c> lstSite = new List<EI_Site__c>();
List<Account> acc = retrieveAcc(1);
insert acc;
for(integer i=0;i<numberOfSite;i++){
EI_Site__c SiteObj = new EI_Site__c();
SiteObj.Account_EI__c = acc[0].id;
SiteObj.Billing_Account_ID_EI__c = acc[0].id;
SiteObj.Person_ID_EI__c = 'TestPerId';
SiteObj.Batch_Reference_Key_EI__c = 'TestABC';
SiteObj.Base_Interr_Prog_Ind_EI__c = 'TestSite';
SiteObj.Avg_Cost_Per_kWh_EI__c = 789.00;
SiteObj.Svc_Status_Code_EI__c = '10';
}
return(lstSite);
} 
*/
    public static CARE_Application__c  careApplication(Account acc){
        CARE_Application__c objcareApp = new CARE_Application__c();
        objcareApp.CARE_Account_ID__c = acc.Id;
        objcareApp.APPLICATION_STATUS__c = 'New';
        objcareApp.APPLICANT_NAME__c = 'Test Care';
        objcareApp.PER_ID__c = 'TestPerId';
        return objcareApp ;
    }
    
    public static CARE_App_Enrolled_SA__c careAppEnrolledSa(CARE_Application__c careAppObj,EI_Site__c eiSite){
        CARE_App_Enrolled_SA__c objCareAppEnroll = new CARE_App_Enrolled_SA__c();
        objCareAppEnroll.APPLICATION__c = careAppObj.Id;
        objCareAppEnroll.SA_ID__c = eiSite.SAID_EI__c;
        objCareAppEnroll.PREM_ID__c = eiSite.Site_Premise_ID_EI__c;
        objCareAppEnroll.ACCT_ID__c = '123456789';
        objCareAppEnroll.CC_CL_CD__c = eiSite.Account_EI__r.Discount__c;
        objCareAppEnroll.Service_Agreement__c = eiSite.Id;
        objCareAppEnroll.PER_ID__c = eiSite.Person_ID_EI__c;
        objCareAppEnroll.END_DATE__c = eiSite.Care_Stop_Date_EI__c;
        objCareAppEnroll.SERVICE_FULL_ADDRESS__c = eiSite.Svc_Full_Adr_EI__c;
        objCareAppEnroll.CC_CL_CD__c = 'C';
        objCareAppEnroll.CCB_CONTACT_TYPE__c = '6042';
        objCareAppEnroll.RS_CD__c = '4213122121';
        return objCareAppEnroll;
    }
    
    public static CARE_Type__c careType(){
        CARE_Type__c objCareType = new CARE_Type__c ();
        objCareType.TYPE_CODE__c = 'D';
        objCareType.TYPE_DESC__c = 'PEV Incomplete';
        objCareType.TYPE_DESC_LONG__c = 'NEED AWARD LETTER OR LETTER OF PARTICIPATION WITH CURRENT DATE.';
        objCareType.TYPE_NO__c = '6042';
        objCareType.START_DATE__c = date.today()-1;
        objCareType.END_DATE__c = date.today()+3;
        objCareType.CATEGORY__c = 'Valid SA status';
        objCareType.IS_ACTIVE__c = true;
        return objCareType;
    }
    
    public static Case objCase(){
        Case obCase = new Case();
        obCase.Origin = 'Phone';
        obCase.Status = 'New';
        obCase.SSL_Date_Received__c = date.today()-1;
        obCase.SSL_Date_Appeal_Filed__c = date.today()-3;
        return obCase;
    }
    
    public static CARE_APP_Image_List__c careImage(CARE_Application__c careAppObj,case objCase){
        CARE_APP_Image_List__c careImg = new CARE_APP_Image_List__c();
        careImg.SOURCE_SYSTEM__c = 'DOCUMENTUM';
        careImg.Application__c = careAppObj.Id;
        careImg.CASE__c = objCase.Id;
        careImg.IMAGE_ID__c = Long.valueOf('178953235');
        return careImg;
    }
    
    public static CARE_APP_Image_List__c careImage(CARE_Application__c careAppObj){
        CARE_APP_Image_List__c careImg = new CARE_APP_Image_List__c();
        careImg.SOURCE_SYSTEM__c = 'DOCUMENTUM';
        careImg.Application__c = careAppObj.Id;
        careImg.IMAGE_ID__c = Long.valueOf('1234567890');
        return careImg;
    }
    
    public static EI_PREMISE__c createPremise(String sPremiseName, String sExtId){
        EI_PREMISE__c prmemiseRecord = new EI_PREMISE__c();
        prmemiseRecord.Name = sPremiseName;
        prmemiseRecord.External_Id_EI__c = sExtId;
        
        return prmemiseRecord;
    }
    
    public static EI_Site__c createSite(List<Account> listAccountRecords){
        EI_Site__c objSite = new EI_Site__c();
        objSite.Name='TestSite';
        objSite.Account_EI__c = listAccountRecords[0].Id;
        objSite.Peak_Demand_EI__c='< 100 kW';
        objSite.Rate_Schedule_EI__c='STANDARD';
        objSite.Billing_Account_ID_EI__c = listAccountRecords[0].AccountNumber;
        objSite.Person_ID_EI__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        objSite.Site_Premise_ID_EI__c = 'TestPrem';
        objSite.Care_Start_Date_EI__c = date.today();
        objSite.Care_Stop_Date_EI__c = date.today()+30;
        objSite.Res_Ind_EI__c = 'Y';
        objSite.SAID_EI__c = listAccountRecords[0].SAID__c;
        objSite.Phone_1_EI__c = listAccountRecords[0].Phone;
        objSite.Svc_Full_Adr_EI__c = 'WASHINGTON ST CA 23432';
        objSite.Svc_Status_Code_EI__c = '20'; //'PEV Incomplete';
        objSite.Svc_Type_Code_EI__c = 'E';
        
        return objSite;
    }
    
    public static ContentVersion createContentVersion(){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        return contentVersion;
    }
    public static List<ContentDocumentLink> createContentDocumentLink(CARE_Application__c careAppObj, List<ContentDocument> documents){
        List<ContentDocumentLink> lstContDocLink = new List<ContentDocumentLink>();
        for(ContentDocument doc :documents){
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = careAppObj.Id;
            cdl1.ContentDocumentId = doc.Id;
            cdl1.shareType = 'V';
            lstContDocLink.add(cdl1);
        }
        return lstContDocLink;
    }
    
    public static CARE_System_Value__c createSystemValue(String sSysValName, Integer iSysCode, String sSysVal){
        CARE_System_Value__c careSysVal = new CARE_System_Value__c();
        careSysVal.Name = sSysValName;
        careSysVal.SYSTEM_VALUE_TYPE__c = 'SYSTEM';
        careSysVal.SYSTEM_VALUE_CODE__c = iSysCode;
        careSysVal.SYSTEM_VALUE__c  = sSysVal;
        
        return careSysVal;
    }
    public static EI_SA_CONTERM__c objConterm(EI_Site__c eiSite,CARE_App_Enrolled_SA__c appEnrol){
        EI_SA_CONTERM__c obCont = new EI_SA_CONTERM__c();
        obCont.SERVICE_AGREEMENT__c = eiSite.Id;
        obCont.SA_ID__c = appEnrol.SA_ID__c;
        return obCont;
    }
/***************************** Milestone 2***********************/    
    public static CARE_Household_Detail__c  createHouseholdDetail(CARE_Application__c careAppObj){
        CARE_Household_Detail__c objHouseholdDetail = new CARE_Household_Detail__c();
        objHouseholdDetail.APPLICATION__c = careAppObj.Id;
        objHouseholdDetail.PERSON_NAME__c = 'Test Person 1';
        objHouseholdDetail.EST_ANNUAL_SALARY__c  = 0;
        objHouseholdDetail.INCOME_SOURCE_STATUS__c = 'Invalid';  
        
        return objHouseholdDetail ;
    }
    
    public static CARE_Household_Member_Income__c  createHouseholdMemberIncome(CARE_Household_Detail__c careHouseholdDetailObj){
        CARE_Household_Member_Income__c objHouseholdMemberIncome = new CARE_Household_Member_Income__c();
        objHouseholdMemberIncome.CARE_Application__c = careHouseholdDetailObj.APPLICATION__c;
        objHouseholdMemberIncome.HOUSEHOLDDETAIL__c = careHouseholdDetailObj.Id; 
        objHouseholdMemberIncome.DISCOUNT_LENGTH_IN_DAYS__c = 0;
        objHouseholdMemberIncome.NO_MONTHS__c = 0;
        objHouseholdMemberIncome.INCOME_SOURCE_STATUS__c = 'Valid';  
        objHouseholdMemberIncome.PERIOD_TYPE__c = 'Not Applicable';
        
        return objHouseholdMemberIncome ;
    }
    
        public static CARE_Household_Member_IncomeC__c  createHouseholdMemberIncomeC(CARE_Household_Member_Income__c careHouseholdMemberIncomeObj){
        CARE_Household_Member_IncomeC__c objHouseholdMemberIncomeC = new CARE_Household_Member_IncomeC__c();
        objHouseholdMemberIncomeC.Application__c = careHouseholdMemberIncomeObj.CARE_Application__c;
        objHouseholdMemberIncomeC.DETAIL_INCOME__c = careHouseholdMemberIncomeObj.Id;
        objHouseholdMemberIncomeC.HOUSEHOLD_DETAIL__c = careHouseholdMemberIncomeObj.HOUSEHOLDDETAIL__c; 
       
        return objHouseholdMemberIncomeC ;
    }
    
    public static CARE_Income_Sources__c  createIncomeSource(){
        CARE_Income_Sources__c objIncomeSource = new CARE_Income_Sources__c();
        objIncomeSource.START_DATE__c = date.today()-1;
        objIncomeSource.END_DATE__c = date.today()+30; 
        
        return objIncomeSource ;
    }
    public static CARE_Income_Document_Type__c  createIncomeDocument(){
        CARE_Income_Document_Type__c objIncomeDocument= new CARE_Income_Document_Type__c();
        objIncomeDocument.START_DATE__c = date.today()-1;
        objIncomeDocument.END_DATE__c = date.today()+30; 
        
        return objIncomeDocument ;
    }
    
    public static CARE_CC_Batch_Detail__c  createCCBatchDetail(List<Account> listAccountRecords){
        CARE_CC_Batch_Detail__c objCCBatch = new CARE_CC_Batch_Detail__c();
        objCCBatch.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        objCCBatch.CC_DTTM__c = Date.today()-30;
        objCCBatch.ACCT_ID__c = listAccountRecords[0].AccountNumber;
        objCCBatch.USER_ID_CARE1__c = 'a';
        objCCBatch.DETAIL_STATUS_CODE__c = 'Validate';
        
        return objCCBatch ;
    }
    
    public static CARE_CI_CC__c  createCICC(List<Account> listAccountRecords){
        CARE_CI_CC__c objCareCICC = new CARE_CI_CC__c();
        objCareCICC.PER_ID__c = listAccountRecords[0].Billing_Person_ID_EI__c;
        objCareCICC.CC_TYPE_CD__c = 'V';
        objCareCICC.USER_ID__c = '1234';
        
        return objCareCICC ;
    }
    
    // Insert all the necessary pre-requisite custom setttings which is being used in the WebService test Apex Callout Requests
/*      public static void setup(){

List<CARE_End_Point_URL__c> EndPointURLs = New List<CARE_End_Point_URL__c>();

List<CARE_Environment_Details__c> currEnvDetails = New List<CARE_Environment_Details__c>();
CARE_Environment_Details__c currEnv = new CARE_Environment_Details__c();
currEnv.Name = 'Environment Name';
currEnv.Environment__c = 'dev';
currEnvDetails.add(currEnv);
insert currEnvDetails;

CARE_End_Point_URL__c getLastBillDateServParam = new CARE_End_Point_URL__c();
getLastBillDateServParam.Name = 'GetLastBillDate';
getLastBillDateServParam.URL__c = 'https://pge.com/service/billingservice/getlastbilldate/';
getLastBillDateServParam.Timeout__c = 60000;
EndPointURLs.add(getLastBillDateServParam);

insert EndPointURLs;
}
*/
    
    public static List<CARE_TYPE__c> createSourceChannelsPriority(){
        // Create CARE_TYPE records defining the Source Channel Priority, base object, batch class
        List<CARE_TYPE__c> sourceChannelList = new List<CARE_TYPE__c> ();
        
        CARE_TYPE__c dxSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 1, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_APP_STAGING__c', TYPE_DESC__c = 'DataXport Enrollment', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9001');
        sourceChannelList.add(dxSC);
        
        CARE_TYPE__c forceSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 2, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_APP_STAGING__c', TYPE_DESC__c = 'CARE Force.com', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9002');
        sourceChannelList.add(forceSC);
        
        CARE_TYPE__c ivrSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 3, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_APP_STAGING__c', TYPE_DESC__c = 'Phone Enrollment', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9003');
        sourceChannelList.add(ivrSC);
        
        CARE_TYPE__c smsSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 4, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_BATCH_UPLOAD_DETAIL__c', TYPE_DESC__c = 'CARE SMS', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9004');
        sourceChannelList.add(smsSC);
        
        CARE_TYPE__c liheapSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 5, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_BATCH_UPLOAD_DETAIL__c', TYPE_DESC__c = 'CARE LIHEAP', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9005');
        sourceChannelList.add(liheapSC);
        
        CARE_TYPE__c esaSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 6, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = '', TYPE_DESC__c = 'ESA Enrollment', TYPE_DESC_LONG__c = '', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9006');
        sourceChannelList.add(esaSC);
        
        CARE_TYPE__c dacGtSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 6, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = '', TYPE_DESC__c = 'DAC GT Enrollment', TYPE_DESC_LONG__c = '', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9007');
        sourceChannelList.add(dacGtSC);
        
        CARE_TYPE__c newMoverSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 6, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_BATCH_UPLOAD_DETAIL__c', TYPE_DESC__c = 'CARE New Mover', TYPE_DESC_LONG__c = 'CARE_BatchEnrollmentDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9008');
        sourceChannelList.add(newMoverSC);
        
        CARE_TYPE__c waterAgencySC = new CARE_TYPE__c (DISPLAY_ORDER__c = 6, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = '', TYPE_DESC__c = 'Water Agency/IOU', TYPE_DESC_LONG__c = '', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging Enrollments Priority Order', TYPE_NO__c = '9009');
        sourceChannelList.add(waterAgencySC);
        
        return sourceChannelList;
    }
    
    public static List<CARE_TYPE__c> createAutoPEVArrivalNoticeSourceChannels(){
        // Create CARE_TYPE records defining the Source Channel Priority, base object, batch class
        List<CARE_TYPE__c> sourceChannelList = new List<CARE_TYPE__c> ();
        
        CARE_TYPE__c dxSC = new CARE_TYPE__c (DISPLAY_ORDER__c = 1, END_DATE__c=System.Today().addYears(1), START_DATE__c=System.Today().addYears(-1), TYPE_CODE__c = 'CARE_APP_STAGING__c', TYPE_DESC__c = 'DataXport PEV Notice', TYPE_DESC_LONG__c = 'CARE_BatchPEVArrivalDataXport', IS_ACTIVE__c = true, CATEGORY__c = 'Automated Staging PEV Arrival Notice Priority Order', TYPE_NO__c = '9100');
        sourceChannelList.add(dxSC);
        
        return sourceChannelList;
    }
    
    public static List<CARE_SYSTEM_VALUE__c> createEmailAddrForBatchJobs(){
        // Create CARE_SYSTEM_VALUE__c records to define the email address at which an email with details like Batch Processing Statistics or errors should be sent
        List<CARE_SYSTEM_VALUE__c> careSysList = new List<CARE_SYSTEM_VALUE__c> ();
        
        CARE_SYSTEM_VALUE__c careSysRec = new CARE_SYSTEM_VALUE__c(Name = 'Internal Client Email List ops', SYSTEM_VALUE__c = UserInfo.getUserEmail(), SYSTEM_VALUE_TYPE__c = 'EMAIL', SYSTEM_VALUE_CODE__c = 522);
        careSysList.add(careSysRec);
        
        return careSysList;
    }
/***************************** Milestone 2 End***********************/ 
}