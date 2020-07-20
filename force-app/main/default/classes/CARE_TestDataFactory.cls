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
    public static EI_SA_CONTERM__c objConterm(EI_Site__c eiSite,CARE_App_Enrolled_SA__c appEnrol){
        EI_SA_CONTERM__c obCont = new EI_SA_CONTERM__c();
        obCont.SERVICE_AGREEMENT__c = eiSite.Id;
        obCont.SA_ID__c = appEnrol.SA_ID__c;
        return obCont;
    }
    
    // Insert all the necessary pre-requisite custom setttings which is being used in the WebService test Apex Callout Requests
   public static void setup(){
        
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
  
}