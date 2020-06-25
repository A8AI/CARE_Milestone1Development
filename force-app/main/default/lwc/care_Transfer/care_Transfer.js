import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTranferDetails from '@salesforce/apex/CARE_TransferController.getTranferDetails';
import updateSADetails from '@salesforce/apex/CARE_TransferController.updateSADetails';

//Labels
import CARE_NotEligiblePersonMsg from '@salesforce/label/c.CARE_NotEligiblePersonMsg';
import CARE_NotSelectedMsg from '@salesforce/label/c.CARE_NotSelectedMsg';
import CARE_SelectReasonMsg from '@salesforce/label/c.CARE_SelectReasonMsg';
import CARE_SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg';
import CARE_TransferOverrideValidationMsg from '@salesforce/label/c.CARE_TransferOverrideValidationMsg';
import CARE_TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import CARE_TransferHeader from '@salesforce/label/c.CARE_TransferHeader';

//column definition of From Section
const columnTransferFrom = [
    { label: 'Account', fieldName: 'sAccountId', type: 'text'},
    { label: 'Premise', fieldName: 'sPremiseId', type: 'text' },
    { label: 'SA', fieldName: 'sSAId', type: 'text'  },
    { label: 'SA Type', fieldName: 'sSAType', type: 'text' },
    { label: 'Discount Type', fieldName: 'sDiscountType', type: 'text'  }
];

export default class Care_Tranfer extends LightningElement {
    @api sSelectedPerId ;
    @track bShowModal = false;
    @track bShowConfirmationModal = false;
    @track bFormEdited = false;
    @track dataTransferFrom;
    @track dataTransferTo;
    @track dataReasonOptions;
    @track listValidTranferTo = [];
    @track listValidPremise = [];
    @track columnTransferFrom = columnTransferFrom;
    @track error;
    @track selectedTranferToSA = [];
    @track reasonSelected = false;
    @track showLoadingSpinner = false;
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sComment: '',
        sContactCode: ''
}
//declare custom label
label = {
    CARE_NotEligiblePersonMsg,
    CARE_NotSelectedMsg,
    CARE_SelectReasonMsg,
    CARE_SelectCommentMsg,
    CARE_TransferOverrideValidationMsg,
    CARE_TransactionSuccessMsg,
    CARE_TransactionErrorMsg,
    CARE_ConfirmationMsg,
    CARE_ErrorHeader,
    CARE_SuccessHeader,
    CARE_CancelHeader,
    CARE_TransferHeader
 }

    //Open Transfer button Modal Popup
    openModal() {       
        this.showLoadingSpinner = true;
        getTranferDetails({ sPerId: this.sSelectedPerId })
            .then(result => {
                 console.log('Transfer Section result===>' + JSON.stringify(result)); 

                if (result.listTransferTo.length>0 && result.listTransferFrom.length>0) {
                    this.bShowModal = true;
                    this.dataTransferFrom = result.listTransferFrom;
                    this.dataTransferTo = result.listTransferTo;
                    this.dataReasonOptions = result.listTransferReason;
                    this.objInputFields.sComment = result.sComment;
                    this.objInputFields.sContactCode = result.sContactCode;

                    this.showLoadingSpinner = false;                   
                }
                else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotEligiblePersonMsg, 'error');
                    this.showLoadingSpinner = false;
                    this.closeModal();
                }
            })
            .catch(error => {
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;

            });

    }
    //handle save logic once reason is selected
    handleChange(event) {
        let elemName = event.target.name;
        let value = event.target.value;
        //reason picklist is selected
        if (elemName === "reasonCombo"){
            this.objInputFields.sReason = value;
            this.reasonSelected = true;
        }
        //comment text area is selected
        else if (elemName === "commentField"){
            this.objInputFields.sComment = value;
        }          
        this.bFormEdited = true;
    }

    //handle Tranfer To SA selection for Transferring discount
    handleSelectChecked(event) {

        let elemName = event.target.name;
        let index = event.target.dataset.index;
        this.bFormEdited = true;
        //checkbox is selected for "Selection" checkbox
        if (elemName === "selected") {
            this.dataTransferTo[index].sSelectedRecord = event.target.checked;
        }
        //checkbox is selected for "OverRide" checkbox
        else if (elemName === "override") {
            this.dataTransferTo[index].bOverRide = event.target.checked;
        }
    }

    handleTransfer() {

        let isFirstRecord = false;
        let firstRecordPremId;
        let firstRecordOverRide;
        let overRideErrorCondition;
        let errorSelection;
    
        this.dataTransferTo.forEach(ele => {
            if(ele.sSelectedRecord){
                this.listValidPremise.push(ele.sPremiseId)
            }
});

        this.dataTransferTo.forEach(element => {

            //check if record is in selected premise & is a valid SA (active & Rate scedhule)
            if (this.listValidPremise.includes(element.sPremiseId) && !element.bSelectionDisabled){

                this.listValidTranferTo.push(element);
            }
            //this loop is executed only once to get the premId 
            if (!isFirstRecord && element.sSelectedRecord) {
                firstRecordPremId = element.sPremiseId;
                firstRecordOverRide = element.bOverRide;
                isFirstRecord = true;
            }
           //loop through other records and check if selected records is having same premise
            else {
                if (element.sSelectedRecord && firstRecordPremId != element.sPremiseId) {
                    overRideErrorCondition = true;
                }
            }
        });
        //check if atleast one SA is selected
        console.log('listValidPremise===>', JSON.stringify(this.listValidPremise));
        console.log('listValidTranferTo===>',  JSON.stringify(this.listValidTranferTo));
        console.log('reasonSelected===>', this.objInputFields.sReason);
        if (this.listValidTranferTo.length === 0) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotSelectedMsg, 'error');
            this.listValidTranferTo = [];
            this.listValidPremise = [];
        }
        //check if Reason is selected
        else if (!this.reasonSelected) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectReasonMsg, 'error');
            this.listValidTranferTo = [];
            this.listValidPremise = [];
        }
        //check if ReasonComment is selected or not
        else if (this.objInputFields.sComment == null || this.objInputFields.sComment == '' || this.objInputFields.sComment == undefined) {
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectCommentMsg, 'error');
            this.listValidTranferTo = [];
            this.listValidPremise = [];
        }
         //premise are different , check if overide is checked for each selected record
        else {
            if (overRideErrorCondition) {
                errorSelection = false;

                this.dataTransferTo.forEach(element => {
                    if (element.sSelectedRecord && !element.bOverRide) {
                        errorSelection = true;
                    }
                });
            }
            //Selected SA is having different premise ID & OverRide is not selected
            if (errorSelection) {
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransferOverrideValidationMsg, 'error');
                this.listValidTranferTo = [];
                this.listValidPremise = [];
            }
            //validation passed, Proceed with Transfer transaction
            else {
                this.doTranfer();
            }
        }       
    }
    //call Apex method for updating Transfer Transaction
    doTranfer() {
        this.showLoadingSpinner = true;
        this.objInputFields.sPerId = this.sSelectedPerId;
        updateSADetails({
            listTranferFrom: this.dataTransferFrom,
            listTranferTo: this.listValidTranferTo,
            objTransferInput: this.objInputFields
        })
            .then(result => {
                console.log('resultafter Transfer Apex call==>' + JSON.stringify(result));
                if (result) {
                    this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_TransactionSuccessMsg, 'success');
                    this.bFormEdited = false;
                    this.showLoadingSpinner = false;
                    this.closeModal();
                }
                else {
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
        }
        else {
            //re-initialize the track variable after successful transaction
            this.listValidTranferTo = [];
            this.listValidPremise = [];
            this.selectedTranferToSA = [];
            this.reasonSelected = false;
            this.dataTransferFrom = null;
            this.dataTransferTo = null;
            this.dataReasonOptions = null;
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