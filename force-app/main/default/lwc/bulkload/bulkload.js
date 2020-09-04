import { LightningElement, track, api} from 'lwc';
import {ShowToastEvent}            from 'lightning/platformShowToastEvent';
import loadCSVFile                 from '@salesforce/apex/EI_BulkLoad.loadCSVFile';
import getBuhList                 from '@salesforce/apex/EI_BulkLoad.getBuhList';

export default class Bulkload extends LightningElement {
    @track batchApexJobId;
    @track errorMsg;
           inputObject;
    @api   inputString;
    @api   pageTitle = 'BulkLoad of CSV File';
    @api   hideInstruction = Boolean(0);
    @api   objectApi;
    @api   dateFormat;
    @api   csvFieldMap = '[{"tgtFieldAPI":"name","srcFieldAPI":"name","datatype":""}';
    @api   parmList    = '[{"objectAPI":"EI_Bulk_Upload_History__c","fieldAPI":"Account_EI__c","value":"0013K00000MHZSdQAP"}]';
    @api   batchSize   = 200;
    @api   reqFields   = '["FirstName","LastName"]';
    @api   dmlAction   = 'INSERT';
    @api   extFieldApi;
    @api   className;
    @api   libraryName;
    @api   storeSourceFile   = Boolean(0);
    @api   tgtObjectApi;
    @api   tgtArg;
    @api   dynamicProcessing = Boolean(0);

    connectedCallback() {
       var jsonObject = new Object();
       console.log('connectedCallback pageTitle ========================= '  + this.pageTitle);
       console.log('connectedCallback batchSize ========================= '  + this.batchSize);
       console.log('connectedCallback csvFieldMap =========================' + this.csvFieldMap);
       console.log('connectedCallback reqFields ========================= '  + this.reqFields);
       jsonObject.pageTitle       = this.pageTitle;
       jsonObject.objectApi       = this.objectApi;
       jsonObject.csvFieldMap     = JSON.parse(this.csvFieldMap);
       jsonObject.batchSize       = this.batchSize;
       jsonObject.className       = this.className;
       jsonObject.reqFields       = JSON.parse(this.reqFields);
       jsonObject.parmList        = JSON.parse(this.parmList);
       jsonObject.dmlAction       = this.dmlAction;
       jsonObject.libraryName     = this.libraryName;             
       jsonObject.storeSourceFile = this.storeSourceFile;
       jsonObject.tgtObjectApi    = this.tgtObjectApi;
       jsonObject.tgtArg          = this.tgtArg;
       // jsonObject.extFieldApi= reserved for future
       // jsonObject.showData   = reserved for future
       // jsonObject.documentId = will be set after the file is loaded
       // jsonObject.csvData    = will be set after the file is loaded

       this.inputObject           = jsonObject;
       this.inputString           = JSON.stringify(jsonObject);

       console.log('connectedCallback inputString ========================= ' + this.inputString);
    }

    handleUploadFinished(event) {
        var uploadedFiles = event.detail.files;
        var message = "File " + uploadedFiles[0].name + " is Uploaded Successfully! (DocId=" + uploadedFiles[0].documentId + ")'";
        this.dispatchEvent(
            new ShowToastEvent({
                title: message,
                message: '',
                variant: 'success',
            }),
        );
        
        console.log('Initial inputString ========================= ' + this.inputString);
        console.log('Initial inputObject ========================= ' + this.inputObject.toString());

        if (this.dynamicProcessing) {
            const selectedEvent = new CustomEvent('bulkloadfinish', { detail: {files: event.detail.files} } );
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            return;
        }

        try {
            this.inputObject.documentId = uploadedFiles[0].documentId;
            console.log('documentId ========================= ' + this.inputObject.documentId);
            this.inputString = JSON.stringify(this.inputObject);
            console.log('Post-loading inputString ========================= ' + this.inputString);
        }
        catch(e) {
            this.errorMsg = e.message + ',' + e.name + ',' + e.stack;
            return;
        }
        
        loadCSVFile({argJSON: this.inputString})
            .then(result => {
                console.log('result ========================= ' + result);
                var obj = JSON.parse(result);
                console.log('obj ========================= ' + obj.toString());
                this.batchApexJobId = obj.AsyncApexJobId;
                console.log('this.batchApexJobId ========================= ' + this.batchApexJobId);
                if (obj.errorcode == '-1') {
                    this.errorMsg = 'Error occurred when process the loaded data: ' + obj.message;
                    console.log('errorMsg ========================= ' + this.errorMsg);
                }
            })
            .catch(error => {
                this.error = error;
                var e = this.error;
                this.errorMsg = e.message + ',' + e.name + ',' + e.stack;
                console.log('errorMsg ========================= ' + this.errorMsg);
            });
    }

    buhColumns = [
        { label: 'BUH No.',        fieldName: 'name',         fixedWidth:   120, hideDefaultActions: true   },
        { label: 'file Name',      fieldName: 'fileName',       initialWidth: 200, hideDefaultActions: true   },
        { label: 'Status',         fieldName: 'Status',         initialWidth: 200, hideDefaultActions: true   },
        { label: 'Record #',       fieldName: 'recordCount',    fixedWidth:   80,  cellAttributes: { alignment: 'center' } , hideDefaultActions: true},
        { label: 'Success #',      fieldName: 'successCount',   fixedWidth:   90, cellAttributes: { alignment: 'center' } , hideDefaultActions: true},
        { label: 'Error #',        fieldName: 'errorCount',     fixedWidth:   70,  cellAttributes: { alignment: 'center' } , hideDefaultActions: true},
        { label: 'Success File',   fieldName: 'successFile',    fixedWidth:   100, type: 'url', typeAttributes: {label: 'success.csv',  target: '_blank'} , hideDefaultActions: true},
        { label: 'Error File',     fieldName: 'errorFile',      fixedWidth:   90,  type: 'url', typeAttributes: {label: 'error.csv',    target: '_blank'} , hideDefaultActions: true},
        { label: 'Result File',    fieldName: 'resultFile',     fixedWidth:   90,  type: 'url', typeAttributes: {label: 'result.csv',   target: '_blank'} , hideDefaultActions: true},
        { label: 'Result Summary', fieldName: 'resultSummary',  initialWidth: 250, hideDefaultActions: true },
        { label: 'Upload Date',    fieldName: 'uploadDate',     fixedWidth:   120, hideDefaultActions: true},
        { label: 'Upload By',      fieldName: 'uploadBy',       fixedWidth:   150, hideDefaultActions: true}
    ]

    buhList;

    getBulkloadHistory(event) {
        getBuhList()
            .then(result => {
                console.log('BHU List Result ========================= ' + result);
                this.buhList = JSON.parse(result);
                console.log('BHU List obj ========================= ' + this.buhList.toString());
            })
            .catch(error => {
                this.error = error;
                var e = this.error;
                this.errorMsg = e.message + ',' + e.name + ',' + e.stack;
                console.log('errorMsg ========================= ' + this.errorMsg);
            });

    }

    @api loadSelectedFile (argJSONString) {
        
        loadCSVFile({argJSON: argJSONString})
            .then(result => {
                console.log('result ========================= ' + result);
                var obj = JSON.parse(result);
                console.log('obj ========================= ' + obj.toString());
                this.batchApexJobId = obj.AsyncApexJobId;
                console.log('this.batchApexJobId ========================= ' + this.batchApexJobId);
                if (obj.errorcode == '-1') {
                    this.errorMsg = 'Error occurred when process the loaded data: ' + obj.message;
                    console.log('errorMsg ========================= ' + this.errorMsg);
                }
            })
            .catch(error => {
                this.error = error;
                var e = this.error;
                this.errorMsg = e.message + ',' + e.name + ',' + e.stack;
                console.log('errorMsg ========================= ' + this.errorMsg);
            });
    }
}