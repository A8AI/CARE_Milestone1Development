import {LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import getReinstateDetails from '@salesforce/apex/CARE_ReinstateController.getReinstateDetails';
import reinstateSA from '@salesforce/apex/CARE_ReinstateController.reinstateSA';

//Label
import CARE_NotEligiblePersonMsg from '@salesforce/label/c.CARE_NotEligiblePersonMsg';
import CARE_TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CARE_CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import CARE_SelectReasonMsg from '@salesforce/label/c.CARE_SelectReasonMsg';
import CARE_SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg'
import CARE_RetroStartDateValidationMsg from '@salesforce/label/c.CARE_RetroStartDateValidationMsg';
import CARE_RetroDateValidationMsg from '@salesforce/label/c.CARE_RetroDateValidationMsg';
import CARE_CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import CARE_CommentFieldLengthValidationMsg from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CARE_NotModifiedRstREndMsg from '@salesforce/label/c.CARE_NotModifiedRstREndMsg';

export default class Care_Reinstate extends LightningElement {

    @api sSelectedPerId;
    @track bShowModal = false;
    @track bShowConfirmationModal = false;
    @track showLoadingSpinner = false;
    @track bFormEdited = false;
    @track error;
    @track dataReinstateTo;
    @track dataReasonOptions;
    @track listRetroStartEndDate = [];
    @track reasonSelected = false;
    @track bAdjustment = false;
    @track bEditDisabled = true;
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sComment: '',
        sContactCode: ''
    }
    @track dTodaysDate;
    @track dDateBforeNinetyDays;
    @track sAdjustedComment;
    @track sNonAdjustedComment;
    @track sAdjustedCommentESACOMP;
    @track sNonAdjustedCommentESACOMP;
//declare custom label
   label = {
    CARE_NotEligiblePersonMsg,
    CARE_TransactionSuccessMsg,
    CARE_TransactionErrorMsg,
    CARE_ErrorHeader,
    CARE_SuccessHeader,
    CARE_ConfirmationMsg,
    CARE_CancelHeader,
    CARE_SelectReasonMsg,
    CARE_SelectCommentMsg,
    CARE_RetroStartDateValidationMsg,
    CARE_RetroDateValidationMsg,
    CARE_CommentFieldValidationMsg,
    CARE_CommentFieldLengthValidationMsg,
    CARE_NotModifiedRstREndMsg
 }
    //open Reinstate modalPopup based on the valid customer result
    openReinstateModal() {

        this.showLoadingSpinner = true;
        getReinstateDetails({
                sPerId: this.sSelectedPerId
            })
            .then(result => {
                console.log('result1==>', JSON.stringify(result));
                if (result) {
                    this.bShowModal = true;
                    this.dataReinstateTo = result.listReinstate;
                    this.dataReasonOptions = result.listReinstateReason;
                    this.objInputFields.sComment = result.sCommentWithOutAdjustment;
                    this.sAdjustedComment = result.sCommentWithAdjustment;
                    this.sNonAdjustedComment = result.sCommentWithOutAdjustment;
                    this.sAdjustedCommentESACOMP = result.sCommentWithAdjustmentESACOMP;
                    this.sNonAdjustedCommentESACOMP = result.sCommentWithOutAdjustmentESACOMP;
                    this.dTodaysDate = result.dTodaysDate;
                    this.dDateBforeNinetyDays = result.dDateBeforeNinetyDays;
                    this.objInputFields.sContactCode = result.sContactCode;
                    this.showLoadingSpinner = false;
                } else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotEligiblePersonMsg, 'error');   
                    this.showLoadingSpinner = false;
                }

            })
            .catch(error => {
                this.error = error;
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;

            });
    }

    //logic for Adjustment box selected 
    handleAdjustmentChecked(event) {
        this.bFormEdited = true;
        this.bAdjustment = event.target.checked;
       /* if (this.bAdjustment) {
            this.objInputFields.sComment = this.sAdjustedComment;
            this.bEditDisabled = false;
        } else {
            this.objInputFields.sComment = this.sNonAdjustedComment;
            this.bEditDisabled = true;
        }*/
        this.handleCommentAssignment();
    }
    handleDateChange(event) {
        let elemName = event.target.name;
        let index = event.target.dataset.index;
        let selectedValue = event.target.value;
        //Date is changed for Retro Start Date
        if (elemName === "retroStartDate") {
            this.dataReinstateTo[index].dRetroStartDate = selectedValue;
        }
        //Date is changed for Retro End Date
        else if (elemName === "retroEndDate") {
            this.dataReinstateTo[index].dRetroEndDate = selectedValue;
        }
    }

    //handle save logic once reason is selected
    handleChange(event) {
        let elemName = event.target.name;
        let value = event.target.value;
        //reason picklist is selected
        if (elemName === "reasonField") {
            this.objInputFields.sReason = value;
            this.reasonSelected = true;
            this.handleCommentAssignment();
        }
        //comment text area is selected
        else if (elemName === "commentField") {
            this.objInputFields.sComment = value;
        }
        this.bFormEdited = true;
    }

   //handle logic for showing the comments based on the "Is Adjustment" && "Reason" selection
    handleCommentAssignment(){
        if (this.bAdjustment) {
            this.bEditDisabled = false;
            if (this.objInputFields.sReason === 'ESA COMP Reinstatement') {
                this.objInputFields.sComment = this.sAdjustedCommentESACOMP;
            } else {
                this.objInputFields.sComment = this.sAdjustedComment;
            }
        } else {
            this.bEditDisabled = true;
            if (this.objInputFields.sReason === 'ESA COMP Reinstatement') {
                this.objInputFields.sComment = this.sNonAdjustedCommentESACOMP;
            } else {
                this.objInputFields.sComment = this.sNonAdjustedComment;
            }
        }
    }
//handle logic once Reinstate button is clicked
handleReinstate() {
    let bValidInput = true;
    //check if Reason is selected
    if (!this.reasonSelected) {
        bValidInput = false;
        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectReasonMsg, 'error');
    }
    //check if ReasonComment is selected or not
    else if (this.objInputFields.sComment == null || this.objInputFields.sComment == '' || this.objInputFields.sComment == undefined) {
        bValidInput = false;
        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectCommentMsg, 'error');
    }
    //check if Comment is valid (char length <256 and should not contain ',')
    else if (this.objInputFields.sComment.includes(",")) {
        bValidInput = false;
        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldValidationMsg, 'error');
    } else if (this.objInputFields.sComment.length > 256) {
        bValidInput = false;
        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldLengthValidationMsg, 'error');
    }
    //check if retro StartDate & end Date are correct since Adjustment checkbox is selected
    else if (this.bAdjustment) {

        //Check if atleast one record is edited or updated or has existing value with RetroStart Date and Retro End Date
        this.dataReinstateTo.forEach(element => {
            if (element.dRetroStartDate !== null && element.dRetroStartDate !== undefined || element.dRetroEndDate !== null && element.dRetroEndDate !== undefined) {
                this.listRetroStartEndDate.push(element);
            }
        });
        console.log('listRetroStartEndDate1' + JSON.stringify(this.listRetroStartEndDate));
        if (this.listRetroStartEndDate.length === 0) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotModifiedRstREndMsg, 'error');
            bValidInput = false;
        } else {
            //check Date validity for rows where Retro dates are available
            this.listRetroStartEndDate.forEach(element => {
                //retro start Date should be less than todays date
                //commented condition to check if start date is with in past 90 days
                // if (element.dRetroStartDate > this.dTodaysDate || element.dRetroStartDate < this.dDateBforeNinetyDays || element.dRetroStartDate == null) {
                if (element.dRetroStartDate > this.dTodaysDate || element.dRetroStartDate == null) {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroStartDateValidationMsg, 'error');
                    bValidInput = false;
                    this.listRetroStartEndDate = [];
                } else if (element.dRetroEndDate <= element.dRetroStartDate || element.dRetroEndDate > this.dTodaysDate || element.dRetroEndDate == null) {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroDateValidationMsg, 'error');
                    bValidInput = false;
                    this.listRetroStartEndDate = [];
                }
            });
        }
    }
    //validation passed proceed with Apex call
    if (bValidInput) {
        this.doReinstate();
    }
}

doReinstate() {
    const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
        detail: 'History'   //To refresh History Tab
    });
    this.showLoadingSpinner = true;
    reinstateSA({
            sPerId: this.sSelectedPerId,
            listReinstateSA: this.dataReinstateTo,
            objReinstateInput: this.objInputFields,
            bIfAdjustment: this.bAdjustment
        })
        .then(result => {

            if (result) {
                this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_TransactionSuccessMsg, 'success');
                this.bFormEdited = false;
                this.listRetroStartEndDate = [];
                this.showLoadingSpinner = false;
                this.dispatchEvent(historyTabRefreshEvent);
                this.closeModal();
            } else {
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;
            }
        })
        .catch(error => {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
            this.showLoadingSpinner = false;
        });

}
    //close confirmation modal Popup
    closeConfirmationModal(event) {
        this.bShowConfirmationModal = event.detail.showChildModal; //read from child lwc and assign here
    }

    //confirmed to close the transaction in between
    cancelTransaction(event) {
        this.bFormEdited = false;
        this.bShowModal = event.detail.showParentModal; //read from child lwc and assign here
        this.bShowConfirmationModal = event.detail.showChildModal; //read from child lwc and assign here
        this.closeModal();
    }
    //Close Transfer button Modal Popup
    closeModal() {
        if (this.bFormEdited) {
            this.bShowConfirmationModal = true;
        } else {
            //re-initialize the track variable after successful transaction
            this.reasonSelected = false;
            this.bFormEdited = false;
            this.bIfAdjustment = false;
            this.bEditDisabled = true;            
            this.dataReasonOptions = null;
            this.dataReinstateTo = null;
            this.listRetroStartEndDate = [];
            this.bShowModal = false;
        }
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

}