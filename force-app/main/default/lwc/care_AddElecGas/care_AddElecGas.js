//#region Import
import { LightningElement, track, api } from 'lwc';
import getSAListForPerId from '@salesforce/apex/CARE_AddElecGasController.getSAListForPerId';
import createElecGasSA from '@salesforce/apex/CARE_AddElecGasController.createElecGasSA';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { formatString } from 'c/care_Utilities';
//#endregion

//Labels
import CARE_NotSelectedMsg from '@salesforce/label/c.CARE_NotSelectedMsg';
import CARE_SelectReasonMsg from '@salesforce/label/c.CARE_SelectReasonMsg';
import CARE_SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg'
import CARE_TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CARE_CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import CARE_RecordsWithNoDiscNotFound from '@salesforce/label/c.CARE_RecordsWithNoDiscNotFound';
import CARE_AddElecGasHeader from '@salesforce/label/c.CARE_AddElecGasHeader';
import CARE_CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import CARE_CommentFieldLengthValidationMsg  from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CARE_NotEligiblePersonMsg  from '@salesforce/label/c.CARE_NotEligiblePersonMsg';

//#region  Constants
//column definition of Existing Section
const columnExisting = [
    { label: 'Account', fieldName: 'sBillingAccountId', type: 'text' },
    { label: 'Premise ID', fieldName: 'sPremiseId', type: 'text' },
    { label: 'SA ID', fieldName: 'sSAId', type: 'text' },
    { label: 'SA Type', fieldName: 'sSAType', type: 'text' },
    { label: 'Discount Type', fieldName: 'sSADiscountType', type: 'text', initialWidth: 201 }
];
//#endregion

export default class Care_AddElecGas extends LightningElement {
    //#region Variables
    @api sSelectedPerId; // = '5555555555';
    @track bShowModal = false;
    @track columnExisting = columnExisting;
    @track dataExisting;
    @track dataNew;
    @track dataReasonOptions;
    @track reasonSelected = false;
    @track bFormEdited = false;
    @track bShowLoadingSpinner = false;
    @track bShowConfirmationModal = false;
    @track listSelectedRecords = [];
    @track listValidPremise = [];
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sComment: '',
        dHighestDtOfExistingComm: new Date()
    }
    @track bDisabled = false;
    //#endregion

    //declare custom label
     label = {
        CARE_NotSelectedMsg,
        CARE_SelectReasonMsg,
        CARE_SelectCommentMsg,
        CARE_TransactionSuccessMsg,
        CARE_TransactionErrorMsg,
        CARE_ErrorHeader,
        CARE_SuccessHeader,
        CARE_ConfirmationMsg,
        CARE_CancelHeader,
        CARE_RecordsWithNoDiscNotFound,
        CARE_AddElecGasHeader,
        CARE_CommentFieldLengthValidationMsg,
        CARE_CommentFieldValidationMsg,
        CARE_NotEligiblePersonMsg
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

    get showDiscountToBeAdded(){
        return this.dataNew.length > 0;
    }

    //method fired when 'Add Elec / Gas' button is clicked
    openModal() {
        console.log(` Person Id from parent `, this.sSelectedPerId);
        this.bShowLoadingSpinner = true;
        getSAListForPerId({ sPersonId: this.sSelectedPerId })
            .then(result => {
                console.log('result==>' + JSON.stringify(result));
                if (result.bSuccess || result.bValidCustomer) {
                    this.bShowModal = true;
                    this.dataExisting = result.listAddElecGasExisting;
                    this.dataNew = result.listAddElecGasNew;
                    this.dataReasonOptions = result.listAddElecGasReason;
                    this.objInputFields.sComment = result.sComment;
                    //this.objInputFields.sContactCode = result.sContactCode;
                    this.bDisabled = (this.showDiscountToBeAdded) ? false : true;

                    this.label.CARE_AddElecGasHeader = formatString(this.label.CARE_AddElecGasHeader, result.sContactCode);
                    this.bShowLoadingSpinner = false;
                }
                else if (!result.bValidCustomer) {
                    this.bShowModal = false;
                    this.bShowLoadingSpinner = false;
                    //Throw error for invalid customer having either FERA discount or NO discount
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotEligiblePersonMsg, 'error');
                }
            }).catch(error => {
                this.bShowLoadingSpinner = false;
                this.error = error.message;
                console.log('error in getting the list', error.message);
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
            });

    }

    //handle Reason selection
    handleChange(event) {
        let elemName = event.target.name;
        let value = event.target.value;
        //reason picklist is selected
        if (elemName === "reasonField") {
            this.objInputFields.sReason = value;
            this.reasonSelected = true;
        }
        //comment text area is selected
        else if (elemName === "commentField") {
            this.objInputFields.sComment = value;
        }

        this.bFormEdited = true;
    }

    //handle row selection
    handleSelectChecked(event) {
        let index = event.target.dataset.index;
        this.bFormEdited = true;
        this.dataNew[index].sSelectedRecord = event.target.checked;
    }

    //This is called when Submit button is clicked. It validates and fires doSubmit()
    handleSubmit() {
        this.dataNew.forEach(element => {
            //get the list of PremiseId based on the selection from Data New
            if (element.sSelectedRecord) {
                this.listValidPremise.push(element.sPremiseId)
            }
            //check if record is in selected premise & is a valid SA (active & Rate scedhule)
            if (this.listValidPremise.includes(element.sPremiseId)) {
                this.listSelectedRecords.push(element);
            }
        });

        //check if at least one row is selected or not
        if (this.listSelectedRecords.length === 0) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotSelectedMsg, 'error');
            this.listSelectedRecords = [];
            this.listValidPremise = [];
        }
        //check if Reason is selected or not
        else if (!this.reasonSelected) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectReasonMsg, 'error');
            this.listSelectedRecords = [];
            this.listValidPremise = [];
        }
        //check if ReasonComment is selected or not
        else if (this.objInputFields.sComment == null || this.objInputFields.sComment == '' || this.objInputFields.sComment == undefined) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectCommentMsg, 'error');
            this.listSelectedRecords = [];
            this.listValidPremise = [];
        }
        else if(this.objInputFields.sComment.length > 256) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldLengthValidationMsg, 'error');
            this.listSelectedRecords = [];
            this.listValidPremise = [];
        }
        else if(this.objInputFields.sComment.indexOf(',') !== -1){
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldValidationMsg, 'error');
                this.listSelectedRecords = [];
                this.listValidPremise = [];
        }
        else{
            this.doSubmit(); 
        }
    }

    //call Apex method for updating Add Elec / Gas Transaction
    doSubmit() {
        const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
            detail: 'History'   //To refresh History Tab
        });
        this.bShowLoadingSpinner = true;

        //Find the highest end date of the other commodity and pass to the method as a parameter
        let dHighestDtOfExistingComm;
        //console.log('this.dataExisting'+this.dataExisting.length);
        if (this.dataExisting.length > 1) {
            const max = this.dataExisting.reduce(function (prev, current) {
                dHighestDtOfExistingComm = (prev.dEndDate > current.dEndDate) ? prev.dEndDate : current.dEndDate;
                return dHighestDtOfExistingComm;
            }) //returns object.dEndDate
        }
        else {
            dHighestDtOfExistingComm = this.dataExisting[0].dEndDate;
        }

        console.log('dHighestDtOfExistingComm' + dHighestDtOfExistingComm);
        this.objInputFields.dHighestDtOfExistingComm = dHighestDtOfExistingComm;
        this.objInputFields.sPerId = this.sSelectedPerId;
        createElecGasSA({
            listAddElecGas: this.listSelectedRecords,
            objAddElecGasInput: this.objInputFields
        })
            .then(result => {
                //console.log('resultafterApex call==>' + JSON.stringify(result));
                if (result) {
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_TransactionSuccessMsg, 'success');
                    this.bFormEdited = false;
                    this.bShowLoadingSpinner = false;
                    this.dispatchEvent(historyTabRefreshEvent);
                    this.closeModal();
                }
                else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                    this.bShowLoadingSpinner = false;
                    this.listSelectedRecords = [];
                    this.listValidPremise = [];
                    this.reasonSelected = false;
                    this.dataExisting = null;
                    this.dataNew = null;
                    this.dataReasonOptions = null;
                    this.bFormEdited = false;
                }
            })
            .catch(error => {
                //this.error = error.body.message;
                this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
                this.bShowLoadingSpinner = false;
                this.listSelectedRecords = [];
                this.listValidPremise = [];
                this.reasonSelected = false;
                this.dataExisting = null;
                this.dataNew = null;
                this.dataReasonOptions = null;
                this.bFormEdited = false;
            });
    }

    //Close Add Elec Gas Modal Popup
    closeModal() {
        if (this.bFormEdited) {
            this.bShowConfirmationModal = true;
        }
        else {
            //re-initialize the track variable after successful transaction
            this.listSelectedRecords = [];
            this.listValidPremise = [];
            this.reasonSelected = false;
            this.dataExisting = null;
            this.dataNew = null;
            this.dataReasonOptions = null;
            this.bFormEdited = false;
            this.bShowLoadingSpinner = false;

            this.bShowModal = false;
        }
    }

    //close confirmation modal Popup
    closeConfirmationModal(event) {
        //this.bShowConfirmationModal = false;

        this.bShowConfirmationModal = event.detail.showChildModal; //read from child lwc and assign here
    }

    //confirmed to close the transaction in between
    cancelTransaction(event) {
        //this.bShowModal = false;
        //this.bShowConfirmationModal = false;
        this.bFormEdited = false;

        this.bShowModal = event.detail.showParentModal; //read from child lwc and assign here
        this.bShowConfirmationModal = event.detail.showChildModal; //read from child lwc and assign here

        this.listSelectedRecords = [];
        this.listValidPremise = [];
        this.reasonSelected = false;
        this.dataExisting = null;
        this.dataNew = null;
        this.dataReasonOptions = null;
        this.bFormEdited = false;
        this.bShowLoadingSpinner = false;
    }

}