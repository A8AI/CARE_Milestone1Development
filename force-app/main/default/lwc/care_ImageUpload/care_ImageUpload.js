//#region Import
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createCareAppImageList from '@salesforce/apex/CARE_ImageUploadController.createCareAppImageList';
import getCareAppImageList from '@salesforce/apex/CARE_ImageUploadController.getCareAppImageList';
import deleteCareAppImageList from '@salesforce/apex/CARE_ImageUploadController.deleteCareAppImageList';
import getUploadedFiles from '@salesforce/apex/CARE_ImageUploadController.getUploadedFiles';
import deleteUploadedFile from '@salesforce/apex/CARE_ImageUploadController.deleteUploadedFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//#endregion

//Labels
import CARE_ImageIdLengthMismatchMsg from '@salesforce/label/c.CARE_ImageIdLengthMismatchMsg';
import CARE_ImageIdPatternMismatchMsg from '@salesforce/label/c.CARE_ImageIdPatternMismatchMsg';
import CARE_ImageIdSaveSuccessMsg from '@salesforce/label/c.CARE_ImageIdSaveSuccessMsg';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_ImageDeleteMsg from '@salesforce/label/c.CARE_ImageDeleteMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_ConfirmationDeleteMsg from '@salesforce/label/c.CARE_ConfirmationDeleteMsg';

//#region  Constants
const DELAY = 350;
const columns = [
    { label: 'Title', fieldName: 'sTitle', type: 'text', initialWidth: 240 },
    { label: 'Preview / Download', fieldName: 'sLink', type: 'url', initialWidth: 240, typeAttributes: { label: { fieldName: 'sPathOnClient' }, target: '_blank' } },
    {
        type: "button", initialWidth: 100, typeAttributes: {
            label: '',
            name: 'Delete',
            title: 'Delete',
            disabled: false,
            value: 'delete',
            iconPosition: 'centre',
            iconName: 'action:delete',
            variant: 'destructive',
            size: 'x-large'
        }
    }

];
const columnsViewOnly = [
    { label: 'Title', fieldName: 'sTitle', type: 'text' },
    { label: 'Preview / Download', fieldName: 'sLink', type: 'url', typeAttributes: { label: { fieldName: 'sPathOnClient' }, target: '_blank' } }
];
//#endregion

export default class Care_ImageUpload extends NavigationMixin(LightningElement) {
    //#region Variables
    @api recordId;
    @api viewOnly;// = false;
    @track columns = columns;
    @track fileData;
    @track bShowLoadingSpinner = false;
    @track bShowModal = false;
    @track bShowDeleteModal = false;
    @track bShowUploadSection = false;
    @track bShowImageSection = true;
    @track imageList = [{
        sobjectType: 'CARE_APP_Image_List__c',
        iImageIndex: 0,
        iNumber: 1,
        sImageId: '',
        sDataXportUrl: '',
        sId: ''
    }];
    @track recImageList = [];
    @track sLabelUpload = 'Expand Upload Section';
    @track uIconName = 'utility:right';
    selectedRecords;
    wiredUploadedFileList; // declare this property for holding the provisioned value
    startIdx;
    sectionName;    
    //#endregion

    //declare custom label
    label = {
        CARE_ImageIdLengthMismatchMsg,
        CARE_ImageIdPatternMismatchMsg,
        CARE_ImageIdSaveSuccessMsg,
        CARE_SuccessHeader,
        CARE_ErrorHeader,
        CARE_ImageDeleteMsg,
        CARE_TransactionErrorMsg,
        CARE_ConfirmationDeleteMsg
     }

    get rowId() {
        return this._rowId;
    }
    set rowId(value) {
        this._rowId = value;
    }

    get showViewOnly() {
        return this.viewOnly === "true";
    };

    // accepted parameters
    get acceptedFormats() {
        //return ['.pdf', '.png', '.jpg', '.jpeg', '.msg'];
    }

    showToastMessage(toastTitle, msg, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: msg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    connectedCallback() {
        this.getFiles();
    }

    // to open modal window set 'bShowModal' tarck value as true
    openModal() {
        this.bShowModal = true;
        this.getImageIDs();

    }
    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        if (!this.bShowDeleteModal) { // This is done to prevent closing of parent modal, if Delete modal for confirmation is open
            this.bShowModal = false;

            this.recImageList = [];
            this.imageList = [];
        }
    }

    closeDeleteModal() {
        this.bShowDeleteModal = false;
    }

    //#region File Uplaod
    //Use this to toggle the view of the upload file section
    handleUpload() {
        if (!this.bShowUploadSection) {
            this.bShowUploadSection = true;
            this.sLabelUpload = 'Collapse Upload Section';
            this.uIconName = 'utility:down';
        }
        else {
            this.bShowUploadSection = false;
            this.sLabelUpload = 'Expand Upload Section';
            this.uIconName = 'utility:right';
        }
    }

    //To view the files in a datatable
    getFiles() {
        //Declare the columns to be displayed from History and Enroll tab
        if (this.showViewOnly) {
            //To hide the delete column
            this.columns = columnsViewOnly;
        }
        else {
            //To show the delete column
            this.columns = columns;
        }
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);

        this.bShowLoadingSpinner = true;
        this.delayTimeout = setTimeout(() => {
            getUploadedFiles({ idParent: this.recordId })
                .then(result => {
                    if (result) {
                        this.fileList = [];
                        result.forEach(element => {
                            let fileObj = { ...element };
                            fileObj.sTitle = fileObj.sTitle;
                            fileObj.sPathOnClient = fileObj.sPathOnClient;
                            fileObj.sLink = (fileObj.sFileExtension === 'msg') ? fileObj.mapContentDocumentUrls.ContentDownloadURL : fileObj.mapContentDocumentUrls.DistributionPublicUrl;
                            fileObj.sContentDocumentId = fileObj.sContentDocumentId;
                            fileObj.sContentVersionId = fileObj.sContentVersionId;
                            this.fileList.push(fileObj);
                        });
                        this.fileData = [...this.fileList];
                        this.bShowLoadingSpinner = false;
                    }
                    else {
                        this.fileData = [];
                        this.bShowLoadingSpinner = false;
                    }

                })
                .catch(error => {
                    this.bShowLoadingSpinner = false;
                    //this.showToastMessage('Application Error', error.body.message, 'error');
                });
        }, DELAY);
    }

    //This method is fired when all the files are uploaded in Content Version. Use this to generate the urls
    handleUploadFinished(event) {
        let strFileNames = '';
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        let listUploadedFileNames = [];
        for (let i = 0; i < uploadedFiles.length; i++) {
            strFileNames += uploadedFiles[i].name + ', ';
            listUploadedFileNames.push(uploadedFiles[i].name);
        }

        //Retrieve the uploaded files along with the urls
        this.getFiles();

        this.showToastMessage('Files uploaded', strFileNames + ' Files uploaded Successfully!!!', 'success');
    }

    //#endregion

    //#region  Image ID
    //To view the Image IDs in a datatable
    getImageIDs() {
        this.bShowLoadingSpinner = true;
        this.imageList = [];
        getCareAppImageList({ idApplication: this.recordId })
            .then(result => {
                console.log('result-->'+JSON.stringify(result));
                result.forEach((element, idx) => {
                    let imageObj = { ...element };
                    imageObj.sobjectType = 'CARE_APP_Image_List__c';
                    imageObj.sId = imageObj.sId;
                    imageObj.sImageId = String(imageObj.sImageId);
                    imageObj.sDataXportUrl = imageObj.sDataXportUrl;
                    imageObj.iNumber = idx + 1; // iNumber starts from 1, 2, 3, 4, etc.
                    imageObj.iImageIndex = idx; // id starts from 0, 1, 2, 3 etc.
                    this.imageList.push(imageObj);
                });
                this.bShowLoadingSpinner = false;

                //For ViewOnly (called from History-->View), if there are any Image IDs in Care_App_Omage_List object,
                //then display that, else display uploaded images
                if (this.viewOnly === "true") {
                    this.bShowImageSection = (this.imageList.length > 0) ? true : false;
                    this.bShowUploadSection = true; //(this.imageList.length > 0) ? false : true;
                }
                else {
                    this.bShowImageSection = true;
                    if (this.imageList.length === 0) { //Initialise with extra row in the ImageID section for no imageList
                        this.handleAdd();
                    }
                }
            })
            .catch(error => {
                this.bShowLoadingSpinner = false;
                sytem.debug('error-->'+error.body.message);
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
            });

    }

    //handle row action of lightning data table Delete button click for Uploaded Images
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        //let selectedrow = event.detail.selectedrow;
        let row = event.detail.row;
        //this.rowId = row;
        console.log('row ====> ', row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'Delete':
                this.bShowDeleteModal = true;
                this.rowId = row.sContentDocumentId;
                this.sectionName = 'UploadedFiles';
                break;
        }
    }

    //This methods adds an extra row in the table
    handleAdd() {
        this.imageList.push({
            sobjectType: 'CARE_APP_Image_List__c',
            iImageIndex: 0,
            iNumber: 1,
            sImageId: '',
            sDataXportUrl: '',
            sId: ''
        });
        this.imageList.forEach((image, idx) => {
            image.iNumber = idx + 1; // iNumber starts from 1, 2, 3, 4, etc.
            image.iImageIndex = idx; // id starts from 0, 1, 2, 3 etc.
        });
    }

    //Onfocusout() : capture the entered ImageIDs in a list for further population
    handleUpdateImageIDRows(event) {
        //fetch the template input fields to check if all input values are valid
        const allInputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                var value = inputCmp.value.trim();
                if (!(value.length === 8 || value.length === 15 || value.length === 18)) {
                    inputCmp.setCustomValidity(this.label.CARE_ImageIdLengthMismatchMsg);
                }
                else if (value.length === 8 && !(/^\d+$/.test(value))) {
                    inputCmp.setCustomValidity(this.label.CARE_ImageIdPatternMismatchMsg);
                }
                else {
                    inputCmp.setCustomValidity("");
                    //if one input is valid, populate that in the imageList
                    this.populateImageList(event);
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
    }

    populateImageList(event) {
        //find the index of the changed data-id and then use it for finding the record
        let recId;
        let recordFound = true;
        recId = this.recImageList.findIndex(x => x.iImageIndex === Number(event.target.dataset.id));
        if (this.recImageList[recId] === undefined) {
            recId = this.imageList.findIndex(x => x.iImageIndex === Number(event.target.dataset.id));
            recordFound = false
        }
        let imageListToBeUpdated = (recordFound ? { ...this.recImageList[recId] } : { ...this.imageList[recId] });  //retrieve the record against the recId and clone the record to make it editable      

        let imageIdEntered = event.target.value.trim();
        imageListToBeUpdated[event.target.dataset.api] = imageIdEntered; // set the value inputted by the user in the data-api='imageId'
        imageListToBeUpdated.sImageId = imageIdEntered; // set the value inputted by the user in the property 'sImageId'

        //Populate the array to be updated
        //check if the record element exists in the array to be used for update
        let idx = this.recImageList.findIndex(elem => {
            return elem.iImageIndex === Number(event.target.dataset.id);
        })
        if (idx !== -1) {
            //the element exist, hence update the array at the index                
            this.recImageList[idx] = imageListToBeUpdated;
        }
        else {
            //the element doesn't exist, hence insert into the array
            this.recImageList.push(imageListToBeUpdated);
        }

        console.log('this.imageList3==>' + JSON.stringify(this.imageList));
        console.log('this.recImageList==>' + JSON.stringify(this.recImageList));
    }

    //This method is used to save the full set of record
    handleSave() {
        //fetch the template input fields to check if all input values are valid
        const allInputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                var value = inputCmp.value.trim();
                if (!(value.length === 8 || value.length === 15 || value.length === 18)) {
                    inputCmp.setCustomValidity(this.label.CARE_ImageIdLengthMismatchMsg);
                }
                else if (value.length === 8 && !(/^\d+$/.test(value))) {
                    inputCmp.setCustomValidity(this.label.CARE_ImageIdPatternMismatchMsg);
                }
                else {
                    inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        //if all inputs are valid, save the record
        if (allInputValid) {
            createCareAppImageList({ listImagesWrap: this.recImageList, idApplication: this.recordId })
                .then(result => {
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_ImageIdSaveSuccessMsg, 'success');
                    this.getImageIDs();
                })
                .catch(error => {
                    console.log('err-->'+error.body.message);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                });
            this.recImageList = [];
            this.imageList = [];
        }
    }

    //This method deletes the rows of the Image IDs
    handleDelete(event) {
        this.startIdx = Number(event.target.dataset.id);

        let sId = event.target.dataset.api;
        if (sId !== '' && sId !== undefined) {
            this.bShowDeleteModal = true;
            this.sectionName = 'UploadedImageID';
            this.rowId = sId;
        }
        else {
            this.imageList.splice(this.startIdx, 1);
            this.recImageList.splice(this.startIdx, 1);
        }
    }

    handlePreview(event) {
        this.startIdx = Number(event.target.dataset.id);

        //generate the Url
        let sImgIDVal = this.imageList[this.startIdx].sImageId;
        if(sImgIDVal.length === 8){ //to redirect to Care_App_Image_List record page
            let sId = event.target.dataset.api;
            let urlDataExport = '';
            if (sId !== '' && sId !== undefined) {
                this.sectionName = 'UploadedImageID';
                this.rowId = sId;
                urlDataExport = event.target.dataset.url;
            }
    
            // var baseURL = window.location.hostname;
            // baseURL = 'https://' + baseURL + '/lightning/r/Care_App_Image_List__c/' + this.rowId + '/view';
            // window.open(baseURL, '_blank');
            /*this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.rowId,
                    actionName: 'view',
                },
            }).then(url => {
                window.open(url);
            });*/
            console.log('urlDataExport-->'+urlDataExport);
            window.open(urlDataExport, '_blank');
        }
        else{ //to redirect to Case record page because the saved image ID is 15/18 digit Salesforce Case Id
            // var baseURL = window.location.hostname;
            // baseURL = 'https://' + baseURL + '/lightning/r/Case/' + sImgIDVal + '/view';
            // window.open(baseURL, '_blank');

            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: sImgIDVal,
                    actionName: 'view',
                },
            }).then(url => {
                window.open(url);
            });
        }
    }
    //#endregion

    //#region Common
    //Common method called from 'Yes' confirmation either to delete Image IDs or uploaded files
    delRec() {
        this.closeDeleteModal();
        console.log('this.rowId==>' + this.rowId)

        if (this.sectionName === 'UploadedImageID') {
            deleteCareAppImageList({ sId: this.rowId })
                .then(result => {
                    this.imageList.splice(this.startIdx, 1);
                    this.recImageList.splice(this.startIdx, 1);
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_ImageDeleteMsg, 'success');
                    this.getImageIDs();
                })
                .catch(error => {
                    console.log('err-->'+error.body.message);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                });
        }
        else if (this.sectionName === 'UploadedFiles') {
            deleteUploadedFile({ sId: this.rowId })
                .then(() => {
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_ImageDeleteMsg, 'success');
                    this.getFiles();
                })
                .catch((error) => {
                    console.log('err-->'+error.body.message);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                });
        }
    }
    //#endregion

}