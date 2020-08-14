import { LightningElement, track, wire, api } from 'lwc';
import getParameters from '@salesforce/apex/CARE_LoadUserFile.getParameters';
export default class CareLoadUserFile extends LightningElement {
    @track csvFieldMap = '[{"tgtFieldAPI":"name","srcFieldAPI":"name","datatype":""}]';
    @track   parmList    = '[{"objectAPI":"EI_Bulk_Upload_History__c","fieldAPI":"Account_EI__c","value":"0013K00000MHZSdQAP"}]';
  
    loadCsvFile(event) {
        var uploadedFiles = event.detail.files;
        var filename      = uploadedFiles[0].name;
        let filenameKey      = uploadedFiles[0].name.replace(/\d|\//g, "");;
        console.log('filename',filename);
        var docId         = uploadedFiles[0].documentId;
        getParameters({'argFileName':filename, 'argDocId':docId, 'fileSearchKey':filenameKey}).then(result => {
            console.log('result ===> ' + JSON.stringify(result));
            var argJSON = result;
            this.template.querySelector('c-bulkload').loadSelectedFile(argJSON);
        })
        .catch(error => {

            this.error = error.message;
            console.log('err:' + this.error);
            //this.showToastMessage('Error', formatString(this.label.CARE_PEVHUCreateErrorMsg, this.sPEVorHU), 'error');
        });    
        
     }
      
}