import {LightningElement, wire, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSpecialMessage from '@salesforce/apex/CARE_HistoryTabController.getSpecialMessage';

import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';

export default class Care_SpecialMessageModal extends LightningElement {
   
    @api typeNumber;
    @api sApplicationNo;
    @track bodyText;
    @track showLoadingSpinner = false;
    @track error; 
    label = {
        TransactionErrorMsg
    };
                
//Wire method to show the special message based on CC Code
    @wire(getSpecialMessage, {
        sTypeNo: '$typeNumber',
        sApplicationNo: '$sApplicationNo'
    })
    wiredSpecialMessage({        
        data,
        error
    }) {
        if (data) {    

                this.bodyText = data;
                this.showLoadingSpinner = false;           
         
        } else if (error) {
            this.error = error;
            this.closeModal();
            this.showToastMessage('Application Error', this.label.TransactionErrorMsg, 'error');
            this.showLoadingSpinner = false;
        }
    }

//Close Modal to create a event from child
closeModal() {
            // Creates the event with the data.
            const closeMessageModal = new CustomEvent("closeevent", {
                detail: {showChildModal: false }
            });
            // Dispatches the event.
            this.dispatchEvent(closeMessageModal);
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