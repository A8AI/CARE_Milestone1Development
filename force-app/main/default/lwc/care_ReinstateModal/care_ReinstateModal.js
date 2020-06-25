import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReinstateDetails from '@salesforce/apex/CARE_ReinstateController.getReinstateDetails';
import reinstateSA from '@salesforce/apex/CARE_ReinstateController.reinstateSA';

export default class Care_ReinstateModal extends LightningElement {


    @api sSelectedPerId = '5555555555';
    @track bShowModal = false;
    @track bShowConfirmationModal = false;
    @track showLoadingSpinner = false;
    @track bFormEdited = false;
    @track error;

    @track dataReinstateTo;
    @track dataReasonOptions;
    @track reasonSelected = false;
    @track sReason;
    @track bAdjustment = false;
    @track bEditDisabled = true;

    openReinstateModal() {

        this.showLoadingSpinner = true;
        this.bShowModal = true;
        getReinstateDetails({ sPerId: this.sSelectedPerId })
            .then(result => {
                console.log('result2==>', JSON.stringify(result));
                console.log('personId2==>', this.sSelectedPerId);
                if (result) {
                    this.dataReinstateTo = result.listReinstate;
                    this.dataReasonOptions = result.listReinstateReason;
                    console.log('dataReinstateTo1==>', this.dataReinstateTo);
                    console.log('dataReasonOptions1==>', this.dataReasonOptions);
                    this.showLoadingSpinner = false;
                }
                else {
                    this.showToastMessage('Application Error', 'Reinstate is not applicable for selected person', 'error');
                    this.showLoadingSpinner = false;
                }

            })
            .catch(error => {
                this.error = error;
                this.showLoadingSpinner = false;
                console.log('ERROR==>', this.error);
            });
    }

    //logic for Adjustment box selected 
    handleAdjustmentChecked(event) {
        this.bFormEdited = true;
        this.bAdjustment = event.target.checked;
        if (this.bAdjustment) {
            this.bEditDisabled = false;
        }
        else {
            this.bEditDisabled = true;
        }
    }
    handleDateChange(event) {
        let elemName = event.target.name;
        let index = event.target.dataset.index;
        //Date is changed for Retro Start Date
        if (elemName === "retroStartDate") {
            this.dataReinstateTo[index].dRetroStartDate = event.target.value;
            console.log('retroStartDate is changed', event.target.value);
        }
        //Date is changed for Retro End Date
        else if (elemName === "retroEndDate") {
            this.dataReinstateTo[index].dRetroEndDate = event.target.value;
            console.log('retroEndDate is changed', event.target.value);
        }
        console.log('dataReinstateTo', this.dataReinstateTo);
    }

    //handle save logic once reason is selected
    handleReasonSelected(event) {
        this.sReason = event.target.value;
        this.reasonSelected = true;
        this.bFormEdited = true;
    }

    handleReinstate() {
        //check if Reason is selected
        if (!this.reasonSelected) {
            this.showToastMessage('Application Error', 'Please select Reason', 'error');
        }
        //validation passed proceed with Apex call
        else {
            this.showLoadingSpinner = true;
            reinstateSA({
                sPerId: this.sSelectedPerId,
                listReinstateSA: this.dataReinstateTo,
                sReason: this.sReason,
                bIfAdjustment: this.bAdjustment
            })
                .then(result => {
                    console.log('resultafterApex call==>' + JSON.stringify(result));

                    if (result) {
                        this.showToastMessage('Success', 'Reinstate transaction successful. Click on History tab to view transaction details', 'success');
                        this.bFormEdited = false;
                        this.showLoadingSpinner = false;
                        this.closeModal();
                    }
                    else {
                        this.showToastMessage('Application Error', 'Unable to Reinstate Discount, Please try after sometime.', 'error');
                        this.showLoadingSpinner = false;
                    }
                })
                .catch(error => {
                    //this.error = error.body.message;
                    this.showToastMessage('Application Error', 'Internal Error', 'error');
                    this.showLoadingSpinner = false;
                });
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
            this.bIfAdjustment = false;
            this.bEditDisabled = true;
            this.dataReasonOptions = null;
            this.dataReinstateTo = null;

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