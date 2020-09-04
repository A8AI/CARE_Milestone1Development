/***********************************************************************************************************   
Apex Util class Name :  CARE_ImageUploadController
Version              :  1.0                                                                          
Created Date         :  06/05/2020                                                         
Function             :  This is the Apex COntroller for Image ID entry and Image Uplaod of CARE Application Component.
Story                :                                                                               
Work Task            :                                                                               
Modification Log     :                                                                               
*----------------------------------------------------------------------------------------------------------  
* When                  Who                    Description                                     
* ---------------------------------------------------------------------------------------------------------  
* 06/05/2020            SKMN                   Initial Version CARE Application
* 07/28/2020            SKMN                   1.0: Updated with DataXport URL
* 09/02/2020            SKMN                   2.0: QA issue fix for filename of more than 100 characters
****************************************************************************************************************************************/
public class CARE_ImageUploadController {
    
    //Constants   
    private Static final Integer iDataXportTokenCode = 707;
    private Static final Integer iDataXportUrlCode = 740;
    private static Id careAppImgResRecTypeId = CARE_UtilityController.getCareAppImgListRecordTypeId(CARE_Constants.CARE_APP_IMG_RES_DEVELOPER_NAME);
    private static Id careAppImgNonResRecTypeId = CARE_UtilityController.getCareAppImgListRecordTypeId(CARE_Constants.CARE_APP_IMG_NON_RES_DEVELOPER_NAME);
    
    /*********************************WRAPPER CLASS*********************************************************/
    //ContentVersionWrapper
    public class ContentVersionWrapper{        
        @AuraEnabled public String sContentVersionId{get;set;}
        @AuraEnabled public String sTitle{get;set;}
        @AuraEnabled public String sContentDocumentId{get;set;}
        @AuraEnabled public String sPathOnClient{get;set;}
        @AuraEnabled public String sFileExtension{get;set;}
        @AuraEnabled public Map<String, String> mapContentDocumentUrls{get;set;}     
        @AuraEnabled public Date dReceivedDate{get;set;}
    }
    
    //ContentVersionWrapper
    public class CareAppImageWrapper{
        @AuraEnabled public String sId{get;set;}
        @AuraEnabled public Integer iImageIndex{get;set;}
        @AuraEnabled public Integer iNumber{get;set;}         
        @AuraEnabled public String sImageId{get;set;}
        @AuraEnabled public String sDataXportUrl{get;set;}
        @AuraEnabled public Date sReceivedDate{get;set;}
        @AuraEnabled public String sDocTitle{get;set;}
    }
    
    /*********************************WRAPPER CLASS*********************************************************/
    
    /*********************************PUBLIC METHODS*********************************************************/
    
    //This method is used to save the Image IDs entered from Care Application screen agaisnt Application Id
    @AuraEnabled
    public static List<CARE_APP_Image_List__c> createCareAppImageList(List<CareAppImageWrapper> listImagesWrap, Id idApplication){
        List<CARE_APP_Image_List__c> listCareAppImgList =  new List<CARE_APP_Image_List__c>();
        try{
            for(CareAppImageWrapper imageWrap : listImagesWrap){
                CARE_APP_Image_List__c careAppImgList = new CARE_APP_Image_List__c();
                
                String imageType = (imageWrap.sImageId.length() == 8) ? CARE_Constants.CARE_DATAXPORT : CARE_Constants.CARE_CASE;
                
                if(String.isNotEmpty(imageWrap.sId)){ //For update
                    careAppImgList.Id = imageWrap.sId;
                }            
                careAppImgList.SOURCE_SYSTEM__c  = imageType;
                careAppImgList.IMAGE_TYPE__c = imageType;
                if(String.isEmpty(imageWrap.sId)){ //For insert
                    careAppImgList.Application__c = idApplication;
                }
                careAppImgList.EXTERNAL_IMAGE_ID__c = imageWrap.sImageId;
                careAppImgList.RecordTypeId = careAppImgResRecTypeId;
                
                listCareAppImgList.add(careAppImgList);
            }
            
            upsert listCareAppImgList; 
        }catch (Exception ex) {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        } 
        
        return listCareAppImgList;
    }
    
    //This method is used to get the Image IDs against the applicationId
    @AuraEnabled
    public static List<CareAppImageWrapper> getCareAppImageList(Id idApplication){
        List<CareAppImageWrapper> listCareAppImageWrapper =  new List<CareAppImageWrapper>();
        String sToken = '';
        String sUrl = '';
        try{            
            Map<Integer, String> mapDataExportConfig = getDataExportConfig();
            sToken = mapDataExportConfig.get(iDataXportTokenCode);
            sUrl = mapDataExportConfig.get(iDataXportUrlCode);            
            sUrl = sUrl.replace('<\'TOKEN\'>', sToken);
            
            List<CARE_APP_Image_List__c> listCareAppImgList = [SELECT Id, Name, IMAGE_ID__c, EXTERNAL_IMAGE_ID__c, Application__c, IMAGE_TYPE__c, SOURCE_SYSTEM__c 
                                                               FROM CARE_APP_Image_List__c
                                                               WHERE Application__c =:idApplication
                                                               ORDER by Name];
            for(CARE_APP_Image_List__c careAppImg : listCareAppImgList){
                CareAppImageWrapper careAppImgWrap =  new CareAppImageWrapper();
                careAppImgWrap.sImageId = careAppImg.EXTERNAL_IMAGE_ID__c;
                careAppImgWrap.sId = careAppImg.Id;
                careAppImgWrap.sDataXportUrl = sUrl.replace('<\'IMAGEID\'>', careAppImg.EXTERNAL_IMAGE_ID__c);
                
                listCareAppImageWrapper.add(careAppImgWrap);
                
            }            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }     
        return listCareAppImageWrapper;
    }
    
    //This method is used to delete the Image ID against the Id of the CARE_APP_Image_List__c
    @AuraEnabled
    public static void deleteCareAppImageList(String sId){
        try {
            List<CARE_APP_Image_List__c> listCareAppImgList = [SELECT Id, Name, IMAGE_ID__c, EXTERNAL_IMAGE_ID__c
                                                               FROM CARE_APP_Image_List__c
                                                               WHERE Id =:sId];
            
            delete listCareAppImgList;
        } catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
    }
    
    //This method is used to fetch all the uploaded files along with the Preview Url and Download Url
    @AuraEnabled
    public static List<ContentVersionWrapper> getUploadedFiles(Id idParent){
        List<ContentVersionWrapper> listContentVersionWrapper = new List<ContentVersionWrapper>();
        List<Id> listConDocIds = new List<Id>();
        List<Id> listConVerIds = new List<Id>();
        try{
            //Select the ContentDocumentId from ContentDocumentLink where LinkedEntityId is equal to the application Id
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idParent]) {
                listConDocIds.add(cntLink.ContentDocumentId);
            }
            
            if(!listConDocIds.isEmpty()) {
                List<ContentVersion> listConVers = [SELECT Id, Title, ContentDocumentId, PathOnClient, FileExtension, CreatedDate FROM ContentVersion 
                                                    WHERE ContentDocumentId IN :listConDocIds AND IsLatest = TRUE
                                                    ORDER BY CreatedDate];
                //select all the ContentVersions for those ContentDocuments 
                for(ContentVersion cv : listConVers){
                    listConVerIds.add(cv.Id);
                }
                
                //////Create record in ContentDistribution to generate URLs/////
                createContentDistribution(listConVers);
                
                //Create a map to hold the contentversionid and map of the urls
                Map<String, Map<String, String>> mapConDist = generateMapOfContDist(listConVerIds);     
                
                for(ContentVersion cv : listConVers){
                    ContentVersionWrapper conVerWrapper = new ContentVersionWrapper();
                    conVerWrapper.sContentVersionId = cv.Id;
                    conVerWrapper.sTitle = cv.Title;
                    conVerWrapper.sContentDocumentId = cv.ContentDocumentId;
                    conVerWrapper.sPathOnClient = cv.PathOnClient;
                    conVerWrapper.sFileExtension = cv.FileExtension;
                    conVerWrapper.mapContentDocumentUrls = mapConDist.get(cv.Id);
                    conVerWrapper.dReceivedDate = Date.valueOf(cv.CreatedDate);
                    
                    listContentVersionWrapper.add(conVerWrapper);
                }  
                return listContentVersionWrapper;
            }
            else {
                return null;
            }        
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }        
    }
    
    //This method is used to delete the uploaded files against the ContentDocument Id
    @AuraEnabled
    public static void deleteUploadedFile(String sId){
        try {
            List<ContentDocument> listContentDoc = [SELECT Id FROM ContentDocument
                                                    WHERE Id =:sId];
            
            delete listContentDoc;
        } catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
    }   
    
    /***************ImageUploadFacility******************/
    //This method is used to save the Image IDs, Received Date and Description/Notes entered from Care Application screen against Facility Id
    @AuraEnabled
    public static List<CARE_APP_Image_List__c> createCareAppImageListFacility(List<CareAppImageWrapper> listImagesWrap, Id idFacility){
        List<CARE_APP_Image_List__c> listCareAppImgList =  new List<CARE_APP_Image_List__c>();
        try{
            for(CareAppImageWrapper imageWrap : listImagesWrap){
                CARE_APP_Image_List__c careAppImgList = new CARE_APP_Image_List__c();
                
                String imageType = (imageWrap.sImageId.length() == 8) ? CARE_Constants.CARE_DATAXPORT : CARE_Constants.CARE_CASE;
                
                if(String.isNotEmpty(imageWrap.sId)){ //For update
                    careAppImgList.Id = imageWrap.sId;
                }            
                careAppImgList.SOURCE_SYSTEM__c  = imageType;
                careAppImgList.IMAGE_TYPE__c = imageType;
                if(String.isEmpty(imageWrap.sId)){ //For insert
                    careAppImgList.Facility__c = idFacility;
                }
                careAppImgList.EXTERNAL_IMAGE_ID__c = imageWrap.sImageId;
                careAppImgList.ENTRY_DATE_CARE1__c = imageWrap.sReceivedDate;
                careAppImgList.COMMENTS__c = imageWrap.sDocTitle;
                careAppImgList.RecordTypeId = careAppImgNonResRecTypeId;
                
                listCareAppImgList.add(careAppImgList);
            }
            
            upsert listCareAppImgList; 
        }catch (Exception ex) {
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        } 
        
        return listCareAppImgList;
    }
    
    //This method is used to get the Image IDs against the Facility Id
    @AuraEnabled
    public static List<CareAppImageWrapper> getCareAppImageListFacility(Id idFacility){
        List<CareAppImageWrapper> listCareAppImageWrapper =  new List<CareAppImageWrapper>();
        String sToken = '';
        String sUrl = '';
        try{            
            Map<Integer, String> mapDataExportConfig = getDataExportConfig();
            sToken = mapDataExportConfig.get(iDataXportTokenCode);
            sUrl = mapDataExportConfig.get(iDataXportUrlCode);            
            sUrl = sUrl.replace('<\'TOKEN\'>', sToken);
            
            List<CARE_APP_Image_List__c> listCareAppImgList = [SELECT Id, Name, IMAGE_ID__c, EXTERNAL_IMAGE_ID__c, Facility__c, 
                                                               ENTRY_DATE_CARE1__c, COMMENTS__c, IMAGE_TYPE__c, SOURCE_SYSTEM__c 
                                                               FROM CARE_APP_Image_List__c
                                                               WHERE Facility__c =:idFacility
                                                               ORDER by Name];
            for(CARE_APP_Image_List__c careAppImg : listCareAppImgList){
                CareAppImageWrapper careAppImgWrap =  new CareAppImageWrapper();
                careAppImgWrap.sImageId = careAppImg.EXTERNAL_IMAGE_ID__c;
                careAppImgWrap.sId = careAppImg.Id;
                careAppImgWrap.sDataXportUrl = sUrl.replace('<\'IMAGEID\'>', careAppImg.EXTERNAL_IMAGE_ID__c);
                careAppImgWrap.sReceivedDate = careAppImg.ENTRY_DATE_CARE1__c;
                careAppImgWrap.sDocTitle = careAppImg.COMMENTS__c;
                
                listCareAppImageWrapper.add(careAppImgWrap);
                
            }            
        }
        catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }     
        return listCareAppImageWrapper;
    }
    
    /***************ImageUploadFacility******************/
    
    /*********************************PUBLIC METHODS*********************************************************/
    
    /*********************************PRIVATE METHODS*********************************************************/
    
    //This method creates ContentDistribution for each of the ContentVersion
    private static void createContentDistribution(List<ContentVersion> listContVer){
        List<ContentVersion> listContVerToUse =  new List<ContentVersion>();
        List<ContentDistribution> listContentDistributionToCreate = new List<ContentDistribution>();
        
        for(ContentVersion contVer : listContVer){
            List<ContentDistribution> listContDist = [select Id from ContentDistribution 
                                                      where ContentVersionId =:contVer.Id 
                                                      and ContentDocumentId =:contVer.ContentDocumentId];
            if(listContDist.isEmpty()){
                listContVerToUse.add(contVer);
            }            
        }
        for(ContentVersion cv : listContVerToUse){
            ContentDistribution contDist = new ContentDistribution();
            String contDistName = '';
            if(cv.Title.length() > 20){
                contDistName = cv.Title.Substring(0, 20); // This is done because contDist.Name field is String(100) while uploaded filename can be more than 100 characters
            }
            else{
                contDistName = cv.Title;
            }
            contDist.Name = contDistName;
            contDist.ContentVersionId = cv.Id;
            contDist.PreferencesAllowViewInBrowser= true;
            contDist.PreferencesLinkLatestVersion=true;
            contDist.PreferencesNotifyOnVisit=false;
            contDist.PreferencesPasswordRequired=false;
            contDist.PreferencesAllowOriginalDownload= true;
            
            listContentDistributionToCreate.add(contDist);     
        }
        insert listContentDistributionToCreate;
    }
    
    //This method returns a map of ContentVersionId as key and value (DistributionPublicUrl and ContentDownloadURL of ContentDistribution)
    private static Map<String, Map<String, String>> generateMapOfContDist(List<Id> listConVerIds){
        Map<String, Map<String, String>> mapConDist = new Map<String, Map<String, String>>();
        
        List<ContentDistribution> listConDist = [SELECT ID, DistributionPublicUrl, ContentDownloadURL, ContentVersionId, ContentDocumentId 
                                                 FROM ContentDistribution 
                                                 WHERE ContentVersionId IN :listConVerIds];
        for(ContentDistribution conDist : listConDist){
            Map<String, String> mapUrl = new Map<String, String>();
            if(!mapConDist.containsKey(conDist.ContentVersionId)){
                mapUrl.put(CARE_Constants.CARE_DISTRIBUTION_PUBLIC_URL, conDist.DistributionPublicUrl);
                mapUrl.put(CARE_Constants.CARE_CONTENT_DOWNLOAD_URL, conDist.ContentDownloadURL);
                
                mapConDist.put(conDist.ContentVersionId, mapUrl);                    
            }
        }
        return mapConDist;
    }
    
    //This method is used to return the DataExport Url and Token in a map
    private static Map<Integer, String> getDataExportConfig(){
        List<Integer> listSysValCode = new List<Integer>{iDataXportTokenCode, iDataXportUrlCode};
        Map<Integer, String> mapSysVal = new Map<Integer, String>();
        try {
            List<CARE_System_Value__c> listCareSysval = CARE_UtilityController.getCareSystemValue(listSysValCode);
            
            for(CARE_System_Value__c sysVal : listCareSysval){
                mapSysVal.put(Integer.valueOf(sysVal.SYSTEM_VALUE_CODE__c), sysVal.SYSTEM_VALUE__c);
            }
            
        } catch(Exception ex){
            EI_CreateErrorLog.upsertException(EI_CreateErrorLog.logException(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, ex));
            CARE_UtilityController.sendExceptionEmail(CARE_Constants.CLASS_NAME_CARE_IMAGE_CONTROLLER, '', '', '', ex);
            
            throw new AuraHandledException(ex.getLineNumber()+': >'+ ex.getMessage()+': >'+ex.getStackTraceString());
        }
        return mapSysVal;
    }
    
    /*********************************PRIVATE METHODS*********************************************************/
}