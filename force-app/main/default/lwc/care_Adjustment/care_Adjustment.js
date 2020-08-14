import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAdjustmentDetails from '@salesforce/apex/CARE_AdjustmentController.getAdjustmentDetails';
import createAdjustmentSA from '@salesforce/apex/CARE_AdjustmentController.createAdjustmentSA';
import { formatString, isBlank, isNotBlank } from 'c/care_Utilities';

//Labels
import CARE_NotModifiedMsg from '@salesforce/label/c.CARE_NotModifiedMsg';
import CARE_SelectReasonMsg from '@salesforce/label/c.CARE_SelectReasonMsg';
import CARE_SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg'
import CARE_TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CARE_CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import CARE_RetroStartDateValidationMsg from '@salesforce/label/c.CARE_RetroStartDateValidationMsg';
import CARE_RetroDateValidationMsg from '@salesforce/label/c.CARE_RetroDateValidationMsg';
import CARE_NotModifiedRstREndMsg from '@salesforce/label/c.CARE_NotModifiedRstREndMsg';
import CARE_AdjustmentHeader from '@salesforce/label/c.CARE_AdjustmentHeader';
import CARE_CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import CARE_NotEligiblePersonMsg from '@salesforce/label/c.CARE_NotEligiblePersonMsg';
import CARE_CommentFieldLengthValidationMsg  from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CARE_StartDateValidationMsg  from '@salesforce/label/c.CARE_StartDateValidationMsg';


export default class Care_Adjustment extends LightningElement {
    @api sSelectedPerId;
    //@api sSelectedPerId = '1111111118';
    @track showLoadingSpinner = false;
    @track bShowModal = false;
    @track bShowConfirmationModal = false;
    @track dataAdjustment;
    @track dataReasonOptions;
    @track reasonSelected = false;
    @track dTodaysDate;    
    @track bFormEdited = false;
    @track bAdjustment = false;
    @track bEditDisabled = false;
    @track listRetroStartEndDate = [];
    @track listRetroStartDate = [];
    @track listErrorStartDate = [];
    @track listErrorStartEndDate = [];
    @track listErrorEndDate = [];
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sComment: ''
    }

    //declare custom label
    label = {
        CARE_NotModifiedMsg,
        CARE_SelectReasonMsg,
        CARE_SelectCommentMsg,
        CARE_TransactionSuccessMsg,
        CARE_TransactionErrorMsg,
        CARE_ErrorHeader,
        CARE_SuccessHeader,
        CARE_ConfirmationMsg,
        CARE_CancelHeader,
        CARE_RetroStartDateValidationMsg,
        CARE_RetroDateValidationMsg,
        CARE_NotModifiedRstREndMsg,
        CARE_AdjustmentHeader,
        CARE_CommentFieldLengthValidationMsg,
        CARE_CommentFieldValidationMsg,
        CARE_NotEligiblePersonMsg,
        CARE_StartDateValidationMsg
     }

    //Toast Message to show 
    showToastMessage(toastTitle, msg, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: msg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showDataSA() {
        getAdjustmentDetails({ sPerId: this.sSelectedPerId })
            .then(result => {
                console.log('result1==>', JSON.stringify(result));

                if (result) {
                    this.bShowModal = true;
                    this.dataAdjustment = result.listAdjustment;
                    this.dataReasonOptions = result.listAdjustmentReason;
                    this.objInputFields.sComment = result.sComment;
                    this.dTodaysDate = result.dTodaysDate;
                    //this.objInputFields.sContactCode = result.sContactCode;

                    this.label.CARE_AdjustmentHeader = formatString(this.label.CARE_AdjustmentHeader, result.sContactCode);
                    this.showLoadingSpinner = false;
                }
                else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotEligiblePersonMsg, 'error');
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.showLoadingSpinner = true;
                console.log('ERROR==>', this.error);
            });
    }

    openModal() {
        this.showLoadingSpinner = true;
        this.showDataSA();
    }

    //logic for Adjustment box selected 
    handleAdjustmentChecked(event) {
        this.bFormEdited = true;
        this.bAdjustment = event.target.checked;
        if (this.bAdjustment) {
            this.bEditDisabled = true;
        }
        else {
            this.bEditDisabled = false;
        }
    }

    //Date fields are edited
    handleDateChange(event) {
        this.bFormEdited = true;
        let elemName = event.target.name;
        let index = event.target.dataset.index;
        let selectedValue = event.target.value;
        //Date is changed for Retro Start Date
        if (elemName === "retroStartDate") {
            this.dataAdjustment[index].dRetroStartDate = selectedValue;
        }
        //Date is changed for Retro End Date
        else if (elemName === "retroEndDate") {
            this.dataAdjustment[index].dRetroEndDate = selectedValue;
        }
    }

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

    //handle logic once Reinstate button is clicked
    handleAdjust() {
        let bValidInput = true;

        //Check if atleast one record is edited or updated or has existing value with RetroStart Date and Retro End Date
        //Put that value in list, and check the length later on
        if (!this.bAdjustment) { // Check for both Start Date and End Date, put that record containing both values
            this.dataAdjustment.forEach(element => {
                if (isNotBlank(element.dRetroStartDate) && isNotBlank(element.dRetroEndDate)) {
                    this.listRetroStartEndDate.push(element);
                }
            });
        }
        else { // Check for only Start Date, put that record containing StarDate
            this.dataAdjustment.forEach(element => {
                if (isNotBlank(element.dRetroStartDate)) {
                    this.listRetroStartDate.push(element);
                }
            });
        }

        //check if retro StartDate & end Date selected or present are correct, populate lists accordingly
        this.dataAdjustment.forEach(element => {
            console.log('element.dRetroStartDate', element.dRetroStartDate);
            console.log('element.dRetroEndDate', element.dRetroEndDate)
            //retro start Date should be less than todays date
            //Retro end date should be greater than Retro start date and not greater than yes date
            //For no 'Yes date only', if retro start date is entered, end date can't be left blank
            //Put that erroneous record in the list
            if (element.dRetroStartDate >= this.dTodaysDate && isNotBlank(element.dRetroStartDate)) {
                this.listErrorStartDate.push(element);
            } 
            else if (!this.bAdjustment && (element.dRetroEndDate <= element.dRetroStartDate || element.dRetroEndDate > element.dStartDate)
                && (isNotBlank(element.dRetroStartDate) && isNotBlank(element.dRetroEndDate))) {
                this.listErrorStartEndDate.push(element);
            }
            else if (!this.bAdjustment && element.dRetroEndDate > element.dStartDate && isNotBlank(element.dRetroEndDate)) {
                this.listErrorStartEndDate.push(element);
            }
            else if(!this.bAdjustment && (isNotBlank(element.dRetroStartDate) && isBlank(element.dRetroEndDate))){
                this.listErrorEndDate.push(element);
            }
        });

        //VALIDATIONS
        if (!this.bAdjustment && this.listRetroStartEndDate.length === 0) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotModifiedRstREndMsg, 'error');
            this.resetErrorLists();
        }
        else if (this.bAdjustment && this.listRetroStartDate.length === 0) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotModifiedMsg, 'error');
            this.resetErrorLists();
        }
        else if (this.listErrorStartDate.length > 0) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroStartDateValidationMsg, 'error');
            this.resetErrorLists();
        }
        else if (!this.bAdjustment && this.listErrorStartEndDate.length > 0) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroDateValidationMsg, 'error');
            this.resetErrorLists();
        }
        else if (!this.bAdjustment && this.listErrorEndDate.length > 0) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_StartDateValidationMsg, 'error');
            this.resetErrorLists();
        }
        //check if Reason is selected
        else if (!this.reasonSelected) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectReasonMsg, 'error');
            this.resetErrorLists();
        }
        //check if ReasonComment is selected or not
        else if (this.objInputFields.sComment == null || this.objInputFields.sComment == '' || this.objInputFields.sComment == undefined) {
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectCommentMsg, 'error');
            this.resetErrorLists();
        }
        else if(this.objInputFields.sComment.length > 256){
            bValidInput = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldLengthValidationMsg, 'error');
            this.resetErrorLists();
        }
        else if(this.objInputFields.sComment.indexOf(',') !== -1){
                bValidInput = false;
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldValidationMsg, 'error');
                this.resetErrorLists();
        }
        //validation passed proceed with Apex call
        if (bValidInput) {
            this.doAdjust();
            console.log('this.sSelectedPerId==>' + this.sSelectedPerId);
            console.log('this.dataAdjustment==>' + JSON.stringify(this.dataAdjustment));
            console.log('this.objInputFields==>' + JSON.stringify(this.objInputFields));
            console.log('this.bAdjustment==>' + this.bAdjustment);
        }
    }

    doAdjust() {
        const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
            detail: 'History'   //To refresh History Tab
        });
        this.showLoadingSpinner = true;
        this.objInputFields.sPerId = this.sSelectedPerId;
        createAdjustmentSA({
            listAdjustmentSA: this.dataAdjustment,
            objAdjustmentInput: this.objInputFields,
            bRetroStartDateOnly: this.bAdjustment
        })
            .then(result => {
                console.log('resultafterApex call==>' + JSON.stringify(result));

                if (result) {
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_TransactionSuccessMsg, 'success');
                    this.bFormEdited = false;
                    this.showLoadingSpinner = false;
                    this.dispatchEvent(historyTabRefreshEvent);
                    this.closeModal();
                } else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                    this.reasonSelected = false;
                    this.bFormEdited = false;
                    this.bAdjustment = false;
                    this.bEditDisabled = false;
                    this.dataReasonOptions = null;
                    this.dataAdjustment = null;
                    this.showLoadingSpinner = false;
                    this.resetErrorLists();
                }
            })
            .catch(error => {
                //this.error = error.body.message;
                this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
                this.reasonSelected = false;
                this.bFormEdited = false;
                this.bAdjustment = false;
                this.bEditDisabled = false;
                this.dataReasonOptions = null;
                this.dataAdjustment = null;
                this.showLoadingSpinner = false;
                this.resetErrorLists();
            });

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

        this.reasonSelected = false;
        this.bFormEdited = false;
        this.bEditDisabled = false;
        this.bAdjustment = false;
        this.dataReasonOptions = null;
        this.dataAdjustment = null;
        this.listRetroStartEndDate = [];
        this.listRetroStartDate = [];
        this.listErrorStartDate = [];
        this.listErrorStartEndDate = [];

    }
    //Close Transfer button Modal Popup
    closeModal() {
        if (this.bFormEdited) {
            this.bShowConfirmationModal = true;
        }
        else {
            //re-initialize the track variable after successful transaction
            this.reasonSelected = false;
            this.bFormEdited = false;
            this.bAdjustment = false;
            this.bEditDisabled = false;
            this.dataReasonOptions = null;
            this.dataAdjustment = null;
            this.listRetroStartEndDate = [];
            this.listRetroStartDate = [];
            this.listErrorStartDate = [];
            this.listErrorStartEndDate = [];

            this.bShowModal = false;
        }
    }

    resetErrorLists(){
        this.listRetroStartEndDate = [];
        this.listRetroStartDate = [];
        this.listErrorStartDate = [];
        this.listErrorStartEndDate = [];
        this.listErrorEndDate = [];
    }
}