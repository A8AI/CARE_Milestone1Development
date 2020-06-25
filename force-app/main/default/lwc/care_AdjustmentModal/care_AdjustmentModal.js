import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getAdjustmentRelatedSA from '@salesforce/apex/CARE_AdjustmentControllerBackup.getAdjustmentRelatedSA';
import handleButtonClickOnAdjustModal from '@salesforce/apex/CARE_AdjustmentController.handleButtonClickOnAdjustModal';
import revertRetroDatesOnly from '@salesforce/apex/CARE_AdjustmentControllerBackup.revertRetroDatesOnly';
import typeDescLongPopulate from '@salesforce/apex/CARE_AdjustmentControllerBackup.typeDescLongPopulate';

const columns = [

    { label: 'Billing Account ID', fieldName: 'billAcctId', type: 'text' },

    { label: 'SA ID', fieldName: 'saID', type: 'text' },
    //{label: 'Application ID', fieldName: 'Name', type: 'text'},    

    { label: 'Yes Date', fieldName: 'startDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },

    { label: 'No Date', fieldName: 'endDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },

    { label: 'Retro Yes date', fieldName: 'rStartDate', type: 'date-local', typeAttributes: { day: "2-digit", month: "2-digit" }, editable: true },

    { label: 'Retro No Date', fieldName: 'rEndDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },

];

const columnsWithEdit = [

    { label: 'Billing Account ID', fieldName: 'billAcctId', type: 'text' },

    { label: 'SA ID', fieldName: 'saID', type: 'text' },
    //{label: 'Application ID', fieldName: 'Name', type: 'text'},

    { label: 'Yes Date', fieldName: 'startDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },

    { label: 'No Date', fieldName: 'endDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },

    { label: 'Retro Yes date', fieldName: 'rStartDate', type: 'date-local', typeAttributes: { day: "2-digit", month: "2-digit" }, editable: true },

    { label: 'Retro No Date', fieldName: 'rEndDate', type: 'date-local', typeAttributes: { day: "2-digit", month: "2-digit" }, editable: true },

];


export default class Care_AdjustmentModal extends LightningElement {

    @track isModalOpen = false;
    @track bShowConfirmationModal = false;
    @track bFormEdited = false;
    @track careApplicationId = '';
    @track newCareAppId = '';
    @track yesDateAdjustOnly = false;
    @track isRetroStartDateEditable = false;
    @track lenOfSAValues = 0;
    @track reasonValueChange = '';
    //@track retroStartDate = '';
    //@track retroEndDate = '';
    @track careSADataValue;
    @track adjustReasonList;
    @track typeDescLongValue = '';
    _wiredCareAppResult;
    @track columns = columns;
    @track columnsWithEdit = columnsWithEdit;
    @api sSelectedPerId;
    //@track selectPerId = '5555555555';
    @api listSelectedPremIds = [];
    @track draftValues = [];
    @api bModalFlag;
    @track bRecordInputs = true;
    @track showLoadingSpinner = false;
    @track retroDateValuesFinal = [];
    @track bReasonCheck = false;
    @track bAdjustDisabled = true;


    @wire(typeDescLongPopulate)
    typeDesc({ error, data }) {
        if (data) {
            this.typeDescLongValue = data;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    showDataSA() {
        getAdjustmentRelatedSA({ selectedPerId: this.sSelectedPerId })
            .then(result => {
                // console.log('result==>' + JSON.stringify(result)); 

                this.careSADataValue = result.listAdjust;
                this.adjustReasonList = result.listAdjustReason;
                //this.typeDescLongValue = result.listDescLong;
                this.careApplicationId = this.careSADataValue[0].careAppId;
                //this.isModalOpen = true;
                this.lenOfSAValues = this.careSADataValue.length;
                //console.log('result for adjustment is==>' + JSON.stringify(result));
                console.log('result for this.careSADataValue==>', this.careSADataValue);
                //console.log('result for this.typeDescLongValue==>' , this.typeDescLongValue);
                //console.log('result for careApplicationId==>' , this.careApplicationId);
                //console.log('length of lenOfSAValues==>' , this.lenOfSAValues);

                //this.careApplicationId = result[0].careAppId;

                //this._wiredCareAppResult = this.careSADataValue;
                if (this.lenOfSAValues > 0) {
                    this.isModalOpen = true;
                    this.showLoadingSpinner = false;
                } else {
                    this.isModalOpen = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Selected Customer is Not enrolled in CARE/FERA!!',
                        variant: 'error'
                    }));
                }
                if (this.isModalOpen) {
                    this.showLoadingSpinner = false;
                }

            })
            .catch(error => {
                this.error = error;
                this.showLoadingSpinner = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: error.message,
                    variant: 'error'
                }));
            });


    }

    openModal() {
        //this.isModalOpen = true;
        this.showLoadingSpinner = true;
        this.bAdjustDisabled = true;
        this.showDataSA();
    }

    handleDataTableSave(event) {
        let today = new Date();
        let dateToday = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);

        //console.log(` today's date: `, dateToday);

        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            console.log(` field draft values: `, fields);
            //console.log(` field draft values recordInputs: `, recordInputs);
            return { fields };

        });
        //validateRetroDates({recordInputValues : recordInputs})
        let retroDateValues = [];
        console.log(` field draft values RECORDINPUTS: `, recordInputs);
        //bRecordInputs = true;
        if (recordInputs) {
            recordInputs.forEach(element => {
                let rdates = { ...element };
                //let d = Date.parse(elementId.fields.rStartDate);
                //let startDate = new Date(d);
                if (rdates.fields.rStartDate >= dateToday || rdates.fields.rEndDate > dateToday || rdates.fields.rEndDate < rdates.fields.rStartDate) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Retro Start Date cannot be greater than Retro End Date/Retro Start and End Date cannot be greater than Todays Date. ',
                            variant: 'error'
                        })
                    );
                    this.bRecordInputs = false;
                    this.bFormEdited = true;
                    this.bAdjustDisabled = true;
                    console.log('elementId.fields.rStartDate---->:' + rdates.fields.rStartDate);
                    // return this.bRecordInputs;
                } else {
                    this.bRecordInputs = true;
                    this.bAdjustDisabled = false;

                }
                //elementId.fields.rStartDate;

            });
        }

        if (recordInputs) {
            //if(this.bRecordInputs){
            for (let i = 0; i < recordInputs.length; i++) {
                if (recordInputs[i].fields.hasOwnProperty('rStartDate') && recordInputs[i].fields.hasOwnProperty('rEndDate')) {
                    retroDateValues.push({ 'fields': { 'RETRO_START_DATE__c': recordInputs[i].fields.rStartDate, 'RETRO_END_DATE__c': recordInputs[i].fields.rEndDate, 'Id': recordInputs[i].fields.Id } })
                } else if (recordInputs[i].fields.hasOwnProperty('rStartDate')) {
                    retroDateValues.push({ 'fields': { 'RETRO_START_DATE__c': recordInputs[i].fields.rStartDate, 'Id': recordInputs[i].fields.Id } })

                } else {
                    retroDateValues.push({ 'fields': { 'RETRO_END_DATE__c': recordInputs[i].fields.rEndDate, 'Id': recordInputs[i].fields.Id } })
                }

            }

            //fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        }
        this.retroDateValuesFinal = retroDateValues;
        //this.retroStartDate = retroDateValues[0].fields.RETRO_START_DATE__c;
        //this.retroEndDate = retroDateValues[0].fields.RETRO_END_DATE__c;

        console.log(` field draft values retroDateValues: `, retroDateValues);
        //console.log(` field draft values retroSTARTDAte: `, this.retroStartDate);
        //console.log(` field draft values retroENDDAte: `, this.retroEndDate);
        const promises = retroDateValues.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(result => {
            //this.returedDataTable = result;
            //console.log(` result values: `, result);
            console.log(` result values: `, JSON.stringify(result));
            console.log(` result: `, result);
            /*this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Retro Dates updated',
                    variant: 'success'
                })
            );*/
            // Clear all draft values
            this.draftValues = [];

            if (result) {
                this.showDataSA();
                this.bFormEdited = true;
                /*let currentData = [];
    
                result.forEach((row) => {
                	
                     let rowData = {};
                	
                    rowData.billAcctId = row.fields.ACCT_ID__c.value;
                    rowData.saID = row.fields.SA_ID__c.value;
                    rowData.startDate = row.fields.START_DATE__c.value;
                    rowData.endDate = row.fields.END_DATE__c.value;
                    rowData.rStartDate = row.fields.RETRO_START_DATE__c.value;
                    rowData.rEndDate = row.fields.RETRO_END_DATE__c.value;
                    //rowData.PBI_Number__c = row.fields.RETRO_END_DATE__c.value;
                    currentData.push(rowData);
                    console.log(` current data values: `, currentData);
                });
    
                this.careSADataValue = currentData;
                console.log(` careSADataValue data values after update: `, this.careSADataValue);*/

            } else if (error) {
                this.error = error;
                this.data = undefined;
            }

        }).catch(error => {
            // Handle error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error editing record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    handleChange(event) {
        let value;
        if (event.target.type === 'checkbox') {
            value = event.target.checked;
            //alert("checked value: "+ value);   
        } else {
            value = event.target.value;
            //alert("checked value1: "+ value);
        }
        if (event.target.dataset.id === 'yesDateAdjustField') {
            this.yesDateAdjustOnly = value;

        } else if (event.target.dataset.id === 'reasonField') {
            this.reasonValueChange = value;
            this.bReasonCheck = true;
        }
        if (this.yesDateAdjustOnly === true) {
            this.isRetroStartDateEditable = true;

        } else if (this.yesDateAdjustOnly === false) {
            this.isRetroStartDateEditable = false;
        }
        console.log('Reason VAlue ===> ', this.reasonValueChange);

        this.bFormEdited = true;
    }

    submitAdjustDetails(event) {
        let nameEvent;
        if (event.target.name === 'adjust') {
            nameEvent = event.target.name;
        }

        if(this.bReasonCheck === false && this.retroDateValues != []){
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Please select a Reason for Adjustment to proceed!!',
                //message: error.message,
                variant: 'error',
            }),
        )
        }else if(this.bReasonCheck === true && this.retroDateValues === []){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please adjust the Retro Dates as well for Adjustment to proceed!!',
                    //message: error.message,
                    variant: 'error',
                }),
            )
        }
        else{
        this.showLoadingSpinner = true;
        handleButtonClickOnAdjustModal({ selectedCareAppId: this.careApplicationId, eventName: nameEvent, reasonValue: this.reasonValueChange, typeDescLong: this.typeDescLongValue })
            .then(result => {
                // Clear the user enter values
                //this.EnrollObjFields = {};
                console.log('result ===> ' + JSON.stringify(result));
                console.log('result before stringify ===> ' + result);
                //this.newCareAppId = result;

                //console.log(` new CareAppId VALUE---->: `, this.newCareAppId); 

                // Show success messsage
                if (result != '' || result != null) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Adjustment transaction successful. Click on History tab to view transaction details record Created Successfully!!',
                        variant: 'success'

                    }));
                    this.showLoadingSpinner = false;
                    this.careApplicationId = '';
                    this.lenOfSAValues = 0;
                    this.adjustReasonList = null;
                    this.bReasonCheck = false;
                    this.careSADataValue = null;
                    this.reasonValueChange = '';
                    this.isModalOpen = false;
                    this.bFormEdited = false;
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!!',
                        message: 'Adjustment transaction  was not successful. Please try after some time!!',
                        variant: 'error'

                    }));
                    this.showLoadingSpinner = false;
                    this.careApplicationId = '';
                    this.lenOfSAValues = 0;
                    this.bReasonCheck = false;
                    this.adjustReasonList = null;
                    this.reasonValueChange = '';
                    this.careSADataValue = null;
                    this.isModalOpen = true;
                    this.bFormEdited = false;
                }

            })
            .catch(error => {
                this.error = error.message;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Internal Error. Please contact System Administrator!!',
                    variant: 'error'
                }));
                this.showLoadingSpinner = false;
                this.isModalOpen = true;
            });
        }

    }

    closeConfirmationModal(event) {
        this.bShowConfirmationModal = event.detail.showChildModal;
    }

    //confirmed to close the transaction in between
    cancelTransaction(event) {
        if (this.retroDateValuesFinal != []) {
            revertRetroDatesOnly({ selectedCareAppId: this.careApplicationId })
            this.isModalOpen = event.detail.showParentModal;
            this.bReasonCheck = false;
            this.bShowConfirmationModal = event.detail.showChildModal;
            this.bFormEdited = false;
        } else {
            this.bReasonCheck = false;
            this.isModalOpen = event.detail.showParentModal;
            this.reasonValueChange = '';
            this.bShowConfirmationModal = event.detail.showChildModal;
            this.bFormEdited = false;
        }
    }

    closeModal() {


        if (this.bFormEdited) {
            this.bShowConfirmationModal = true;
        } else {
            //revertRetroDatesOnly({ selectedCareAppId: this.careApplicationId})
            this.careApplicationId = '';
            this.lenOfSAValues = 0;
            this.adjustReasonList = null;
            this.bReasonCheck = false;
            this.reasonValueChange = '';
            this.careSADataValue = null;

            this.isModalOpen = false;

        }



    }
    refresh() {
        return refreshApex(this.showDataSA());
    }
}