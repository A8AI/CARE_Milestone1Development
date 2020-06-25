import {LightningElement, wire, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

import getEnrollHistoryData from '@salesforce/apex/CARE_HistoryTabController.getEnrollHistoryData';
import deleteEnrollmentRecord from '@salesforce/apex/CARE_HistoryTabController.deleteEnrollmentRecord';

import DeleteSuccessMsg from '@salesforce/label/c.CARE_DeleteSuccessMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import ConfirmationDeleteMsg from '@salesforce/label/c.CARE_ConfirmationDeleteMsg';
import DeleteMsgHeader from '@salesforce/label/c.CARE_DeleteMsgHeader';


// datatable columns with rows actions
const columns = [{label: 'Send/Rcv Date',fieldName: 'dReceiveDate', type: 'date',
                        typeAttributes: {day: "numeric", month: "numeric",year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Transaction Number', fieldName: 'sApplicationName',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Contact',fieldName: 'sContact',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Discount Type',fieldName: 'sDiscountType',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Status',fieldName: 'sApplicationStatus',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'SA ID', fieldName: 'sSAID', type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'SA Type',fieldName: 'sSAType',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Yes date', fieldName: 'dStartDate', type: 'date', 
                        typeAttributes: {day: "numeric", month: "numeric", year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'No Date',fieldName: 'dEndDate',type: 'date',
                        typeAttributes: {day: "numeric",month: "numeric", year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
               //{ label: 'CC&B Comment', fieldName: 'sCCBComment', type: 'text', cellAttributes: { class: { fieldName: 'sFormatText' }}},
                {label: 'App Source', fieldName: 'sAppSource', type: 'text', 
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {type: "button", 
                        typeAttributes: {label: 'View', name: 'View', title: 'View',
                                        disabled: false, value: 'view', iconPosition: 'left',
                        class: {fieldName: 'sViewButton'}}},
                {type: "button",
                        typeAttributes: {label: 'Msg', name: 'Msg', title: 'Msg',
                                        disabled: false, value: 'Msg', iconPosition: 'left',}},
                {type: "button",
                        typeAttributes: {label: 'Delete', name: 'Delete', title: 'Delete',
                                        disabled: {fieldName: 'bDeleteButton'},value: 'Delete',iconPosition: 'left'}}
                ];

export default class Care_History extends LightningElement {
    @api rowDataId;
    @api sSelectedHistoryPerId;
    @api sLiveCall;
    @api listSelectedHistoryPremIds;

    @track data = [];
    @track columns = columns;
    @track bShowModal = false;
    @track bShowDeleteModal = false;
    @track bShowMessageModal = false;
    @track isEditForm = false;
    @track showLoadingSpinner = true;
    @track error;
    @track selectedRecord;
    @track bShowReadonly = true;                
    @track sApplicationNo;
    @track typeNumber;
    label = {
        DeleteSuccessMsg,
        TransactionErrorMsg,
        ConfirmationDeleteMsg,
        DeleteMsgHeader
    };

    /** Wired Apex result so it can be refreshed programmatically */
    _wiredHistoryResult;

    @wire(getEnrollHistoryData, {
        sPerID: '$sSelectedHistoryPerId',
        sMakeLiveCall: '$sLiveCall'
    })
    wiredHistoryResp(resp) {
        this._wiredHistoryResult = resp;
        const {
            data,
            error
        } = resp;

        console.log(this.sSelectedHistoryPerId + '  HistoryFlag  ');
        if (data) {
            this.data = data;
            this.error = undefined;
            if (this.data) {
                this.showLoadingSpinner = false;
            }

        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    //call refresh data after Delete click to update the wired hisotry cache
    @api refreshData() {
        return refreshApex(this._wiredHistoryResult);
    }

    //handle row action of lightning data table for View & Delete button click
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let selectedrow = event.detail.selectedrow;
        let row = event.detail.row;
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'View':
                this.viewCurrentRecord(row);
                break;

            case 'Delete':
                this.deleteCurrentRecord(row);
                break;

            case 'Msg':
                this.showSpecialMessageModal(row);
                break;
        }
    }

    // view the current record details
    viewCurrentRecord(currentRow) {
        this.bShowModal = true;
        this.isEditForm = false;
        this.selectedRecord = currentRow.sId;
    }

    // delete the current record details after user confirmation
    delRec() {
        this.closeModal();
        deleteEnrollmentRecord({
                sEnrollmentId: this.selectedRecord
            })

            .then(() => {
                this.showToastMessage('Record Deleted', this.label.DeleteSuccessMsg, 'success');
                this.refreshData();
                this.bShowDeleteModal = false;
            })
            .catch((error) => {
                this.showToastMessage('Application Error', this.label.TransactionErrorMsg, 'error');
            });
    }
    // delete the current record details
    deleteCurrentRecord(currentRow) {
        this.bShowDeleteModal = true;
        this.selectedRecord = currentRow.sId;
        console.log('currentRow1---> ' + currentRow.sId);
    }
    //show message based on ApplicationRecord
    showSpecialMessageModal(currentRow) {
        this.sApplicationNo = currentRow.sApplicationName;
        this.typeNumber = currentRow.sTypeNo;
        this.bShowMessageModal = true;
    }
    //close Special msg modal Popup
    closeMessageModal(event) {
        this.bShowMessageModal = event.detail.showChildModal; //read from child lwc and assign here
    }

    // close modal popup
    closeModal() {
        this.bShowModal = false;
        this.bShowDeleteModal = false;

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

    get checkHistoryData() {
        return this.data.length > 0;
    }

}