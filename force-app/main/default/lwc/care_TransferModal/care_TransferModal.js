import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTranferDetails from '@salesforce/apex/CARE_TransferController.getTranferDetails';
import updateSADetails from '@salesforce/apex/CARE_TransferController.updateSADetails';

//column definition of From Section
const columnTransferFrom = [
    { label: 'Account', fieldName: 'sAccountId', type: 'text'},
    { label: 'Premise', fieldName: 'sPremiseId', type: 'text' },
    { label: 'SA', fieldName: 'sSAId', type: 'text'  },
    { label: 'SA Type', fieldName: 'sSAType', type: 'text' },
    { label: 'Discount Type', fieldName: 'sDiscountType', type: 'text'  }
];
//column definition of To Section
/*
const columnTransferTo = [
    { label: 'Billing Account', fieldName: 'sAccountId', type: 'text' },
    { label: 'Premise ID', fieldName: 'sPremiseId', type: 'text' },
    { label: 'Address ID', fieldName: 'sAddress', type: 'text' },
    { label: 'SA ID', fieldName: 'sSAId', type: 'text' },
    { label: 'SA Type', fieldName: 'sSAType', type: 'text' },
    { label: 'SA Status', fieldName: 'sSAStatus', type: 'text' },
    { label: 'Rate Schedule', fieldName: 'sRateSchedule', type: 'text' },
    { label: 'Adjusted', fieldName: 'bOverRide', type: 'boolean', editable: true }
];
*/

export default class TranferModalInLWC extends LightningElement {
    @api sSelectedPerId = '5555555555';
    @track bShowModal = false;
    @track bShowConfirmationModal = false;
    @track bFormEdited = false;
    @track dataTransferFrom;
    @track dataTransferTo;
    @track dataReasonOptions;
    @track listValidTranferTo = [];
    @track listValidPremise = [];
    @track columnTransferFrom = columnTransferFrom;
    //@track columnTransferTo = columnTransferTo;
    @track error;
    @track selectedTranferToSA = [];
    @track reasonSelected = false;
    //@track sReason;
    @track showLoadingSpinner = false;
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sComment: ''
}

    //Open Transfer button Modal Popup
    openModal() {

        
        this.showLoadingSpinner = true;
        getTranferDetails({ sPerId: this.sSelectedPerId })
            .then(result => {
                 console.log('result2==>' + JSON.stringify(result)); 
                 //console.log('listTranferTosize==>' + JSON.stringify(result.listTranferTo.size())); 
                //this.dataTransferFrom = result.listTransferFrom;
                //this.dataTransferTo = result.listTransferTo;
                //this.dataReasonOptions = result.listTransferReason;
                // console.log('dataTransferFrom==>' + JSON.stringify(this.dataTransferFrom));
                // console.log('dataTransferTo==>' + JSON.stringify(this.dataTransferTo));
                // console.log('dataReasonOption==>' + JSON.stringify(this.dataReasonOptions));
                //this.showLoadingSpinner = false;

                if (result.listTransferTo.length>0 && result.listTransferFrom.length>0) {
                    this.bShowModal = true;
                    this.dataTransferFrom = result.listTransferFrom;
                    this.dataTransferTo = result.listTransferTo;
                    this.dataReasonOptions = result.listTransferReason;
                    this.objInputFields.sComment = result.sComment;
                    this.showLoadingSpinner = false;                   
                }
                else {
                    this.showToastMessage('Application Error', 'There are no valid records to Transfer Discount', 'error');
                    this.showLoadingSpinner = false;
                    this.closeModal();
                }
            })
            .catch(error => {
                this.error = error;
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
        
        //this.sReason = event.target.value;
        //this.reasonSelected = true;
        this.bFormEdited = true;
    }

    //handle Tranfer To SA selection for Transferring discount
    handleSelectChecked(event) {

console.log('update value3',event.target.checked);
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
            //get the list of PremiseId based on the selection from Transfer To
            //if(element.sSelectedRecord){
            //    this.listValidPremise.push(element.sPremiseId)
            //}
            console.log('inside123==>' + JSON.stringify(element));
            //check if record is in selected premise & is a valid SA (active & Rate scedhule)
            if (this.listValidPremise.includes(element.sPremiseId) && !element.bSelectionDisabled){
               console.log('element.sPremiseId===>',element.sPremiseId);
               console.log('element.bSelectionDisabled===>',element.bSelectionDisabled);
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
        console.log('listValidPremise3===>', JSON.stringify(this.listValidPremise));
        console.log('listValidTranferTo===>',  JSON.stringify(this.listValidTranferTo));
        console.log('reasonSelected1===>', this.objInputFields.sReason);
        if (this.listValidTranferTo.length === 0) {

            this.showToastMessage('Application Error', 'Please select Tranfer to SA', 'error');
            this.listValidTranferTo = [];
            this.listValidPremise = [];
        }
        //check if Reason is selected
        else if (!this.reasonSelected) {
            this.showToastMessage('Application Error', 'Please select Reason', 'error');
            this.listValidTranferTo = [];
            this.listValidPremise = [];
        }
        //check if ReasonComment is selected or not
        else if (this.objInputFields.sComment == null || this.objInputFields.sComment == '' || this.objInputFields.sComment == undefined) {
            this.showToastMessage('Application Error', 'Please enter Comment.', 'error');
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
            //selected SA's is having same premise ID
            /*else {
                //close modalpopup for testing

                this.doTranfer();
                console.log('selected SAs is having same premise ID');
                //this.bShowModal = false;
                //this.closeModal();
            }*/
            //Selected SA is having different premise ID & OverRide is not selected
            if (errorSelection) {
                this.showToastMessage('Application Error', 'Please select SA from same Premise or select overRide', 'warning');
                this.listValidTranferTo = [];
                this.listValidPremise = [];
            }
            //validation passed, Proceed with Transfer transaction
            else {
                //close modalpopup for testing
                this.doTranfer();
            }
        }
        
    }
    //call Apex method for updating Transfer Transaction
    doTranfer() {
        this.showLoadingSpinner = true;
        this.objInputFields.sPerId = this.sSelectedPerId;
        updateSADetails({
            //sPerId: this.sSelectedPerId,
            listTranferFrom: this.dataTransferFrom,
            listTranferTo: this.listValidTranferTo,
            //sReason: this.sReason
            objTransferInput: this.objInputFields
        })
            .then(result => {
                console.log('resultafterApex call==>' + JSON.stringify(result));

                if (result) {
                    //this.sReason = null;
                    //this.bFormEdited = false;
                    this.showToastMessage('Success', 'Transfer transaction successful. Click on History tab to view transaction details', 'success');
                    //this.bShowModal = false;
                    this.bFormEdited = false;
                    this.showLoadingSpinner = false;
                    this.closeModal();
                }
                else {
                    this.showToastMessage('Application Error', 'Unable to Transfer Discount, Please try after sometime.', 'error');
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                //this.error = error.body.message;
                this.showToastMessage('Application Error', 'Internal Error', 'error');
                this.showLoadingSpinner = false;
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