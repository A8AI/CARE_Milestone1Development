import {LightningElement,api,wire,track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import PERIOD_TYPE from '@salesforce/schema/CARE_Household_Member_Income__c.PERIOD_TYPE__c';

import saveHouseholdIncome from '@salesforce/apex/CARE_IncomeInformationController.saveHouseholdIncome';
import getHouseMemberIncomeDetails from '@salesforce/apex/CARE_IncomeInformationController.getHouseMemberIncomeDetails';

//Labels
import IncomeDocSuccessMsg from '@salesforce/label/c.CARE_IncomeDocSuccessMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_CurrencySymbol from '@salesforce/label/c.CARE_CurrencySymbol';
import CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';

export default class Care_IRS1040_2018 extends LightningElement {
    @api idCareApp;
    @api idHouseholdMember;
    @api sIncomeSource;
    @api sDocumentType;
    @api sFormType;
    @api dDiscountLength;
    @api idMemberIncome;
    @api bViewMode;

    @track showLoadingSpinner;
    @track results = [];
    @track error;
    @track periodOptions;
    @track bPeriodDisabled = true;
    @track viewOnly;
    @track scheduleCList = [{
        iScheduleCIndex: 0,
        sNumber: '1',
        dLine3: 0,
        dLine29: 0,
        dLine31: 0,
        sId: null
    }];
    @track dLine3Total = 0;
    @track dLine29Total = 0;
    @track dLine31Total = 0;

    @track bShowScheduleC = false;
    @track bLine3Disabled = false;
    @track bLine29_31Disabled = false;

    @track objInputFields = {
        idCareApp: '',
        idCareHouseholdDetail: '',
        idCareHouseholdmemberIncome: '',
        dDiscountLength: null,
        sIncomeSourceType: '',
        sDocumentType: '',
        sFormType: '',
        iMonthNo: 0,
        sPeriodType: 'Annually',
        bIsValidDoc: false,
        bIsFillingJointly: false,
        bIsSchedule1: false,
        bSchedule1DocValid: false,
        bScheduleCDocComplete: false,
        bRollover: false,
        dLine1: null,
        dLine1Adjusted: null,
        dLine2b: null,
        dLine2bAdjusted: null,
        dLine3b: null,
        dLine3bAdjusted: null,
        dLine4a: null,
        dLine4aAdjusted: null,
        dLine5a: null,
        dLine5aAdjusted: null,
        dLine6Adjusted: null,
        dLine11: null,
        dLine11Adjusted: null,
        dLine12: null,
        dLine12Adjusted: null,
        dLine13: null,
        dLine13Adjusted: null,
        dLine14: null,
        dLine14Adjusted: null,
        dLine17: null,
        dLine17Adjusted: null,
        dLine18: null,
        dLine18Adjusted: null,
        dLine19: null,
        dLine19Adjusted: null,
        dLine21: null,
        dLine21Adjusted: null,
        dLine22Adjusted: null,
        dTotalAmount: 0
    }
    label = {
        IncomeDocSuccessMsg,
        TransactionErrorMsg,
        ErrorHeader,
        SuccessHeader,
        CARE_CurrencySymbol,
        CancelHeader,
        ConfirmationMsg,
    };

    get showViewOnly() {
        return this.viewOnly === "true";
    };

    get rowId() {
        return this._rowId;
    }
    set rowId(value) {
        this._rowId = value;
    }
    //wired picklist value for Period
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: PERIOD_TYPE
    })
    wiredPickListValue({
        data,
        error
    }) {
        if (data) {
            console.log(` Picklist values are `, data.values);
            this.periodOptions = data.values;
            this.error = undefined;
        }
        if (error) {
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
            this.periodOptions = undefined;
        }
    }
    /** Wired Apex result so it can be refreshed programmatically */
    _wiredIncomeDocResult;
    //get uploaded income document details
    @wire(getHouseMemberIncomeDetails, {
        IdCareHouseholdmemberIncome: '$idMemberIncome'
    })
    wiredIncomeInformation(value) {
        this._wiredIncomeDocResult = value;
        const {
            data,
            error
        } = value;

        if (data) {
            console.log('Apex call is refreshed for showing in the child updated' + JSON.stringify(data));
            this.objInputFields = data;
            this.objInputFields = {
                ...this.objInputFields
            };
            //Start: Populate the Schedule C Info
            this.scheduleCList = [];
            data.listHouseholdMemberIncomeC.forEach((element, idx) => {
                let scheduleCInfoObj = {
                    ...element
                };

                scheduleCInfoObj.sId = scheduleCInfoObj.sId;
                scheduleCInfoObj.iScheduleCIndex = idx; // id starts from 0, 1, 2, 3 etc.
                scheduleCInfoObj.sNumber = (idx + 1);; // iNumber starts from 1, 2, 3, 4, etc.
                scheduleCInfoObj.dLine3 = scheduleCInfoObj.dLine3;
                scheduleCInfoObj.dLine29 = scheduleCInfoObj.dLine29;
                scheduleCInfoObj.dLine31 = scheduleCInfoObj.dLine31;
                this.scheduleCList.push(scheduleCInfoObj);
            });
            console.log('this.scheduleCList' + JSON.stringify(this.scheduleCList));
            if (this.scheduleCList.length === 0) { //Initialise with extra row in the table for no incomeInfolist
                this.handleAdd(); //no rows are present ,add a new row
            }
            this.updateScheduleCTotalAmount(); //update ScheduleC total amount
            this.handleScheduleCLineEnable(); //handling logic for enabling/disabling the row
            if (this.bViewMode) { //disable ScheduleC if opened in view mode
                this.bLine3Disabled = true;
                this.bLine29_31Disabled = true;
            }
            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.showLoadingSpinner = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
        }
    }
    //handle logic for checkbox change
    handleChecked(event) {
        let elemName = event.target.name;
        //checkbox is selected for "Is Document Valid" checkbox
        if (elemName === "DocValidChecked") {
            this.objInputFields.bIsValidDoc = event.target.checked;
        } else if (elemName === "FillingJointlyChecked") {
            this.objInputFields.bIsFillingJointly = event.target.checked;
        } else if (elemName === "RolloverChecked") {
            this.objInputFields.bRollover = event.target.checked;
            if (this.objInputFields.bRollover) {
                this.objInputFields.dLine5aAdjusted = 0;
            } else {
                this.objInputFields.dLine5aAdjusted = this.objInputFields.dLine5a;
            }
            //handle logic fo roll over checkbox change
            this.handleAmountChangeRollover();
        } else if (elemName === "Schedule1Checked") {
            this.objInputFields.bIsSchedule1 = event.target.checked;
            //clear values if Schedule1 is unchecked
            if (!this.objInputFields.bIsSchedule1) {
                this.handleSchedule1Unchecked();
            }
            //update the total Amount based on schedule1 Change
            this.handleAmountChangeSchedule1();
        } else if (elemName === "bSchedule1DocChecked") {
            this.objInputFields.bSchedule1DocValid = event.target.checked;
        }
    }

    //handle logic when an amount is entered
    handleAmountChange(event) {
        let elemName = event.target.name;
        let elemValue = Number(event.detail.value);
        let value = Math.trunc(elemValue);

        if (elemName === "line1AmountTextBox") {
            this.objInputFields.dLine1 = value;
            this.objInputFields.dLine1Adjusted = this.objInputFields.dLine1;
        } else if (elemName === "line2bAmountTextBox") {
            this.objInputFields.dLine2b = value;
            this.objInputFields.dLine2bAdjusted = this.objInputFields.dLine2b;
        } else if (elemName === "line3bAmountTextBox") {
            this.objInputFields.dLine3b = value;
            this.objInputFields.dLine3bAdjusted = this.objInputFields.dLine3b;
        } else if (elemName === "line4aAmountTextBox") {
            this.objInputFields.dLine4a = value;
            this.objInputFields.dLine4aAdjusted = this.objInputFields.dLine4a;
        } else if (elemName === "line5aAmountTextBox") {
            this.objInputFields.dLine5a = value;
            //check if Rollover checkbox is checked
            if (!this.objInputFields.bRollover) {
                this.objInputFields.dLine5aAdjusted = value;
            }
        } else if (elemName === "line11AmountTextBox") {
            this.objInputFields.dLine11 = value;
            this.objInputFields.dLine11Adjusted = this.objInputFields.dLine11;
        } else if (elemName === "line12AmountTextBox") {
            this.objInputFields.dLine12 = value;
            //check Schedule1 doc validity
            this.checkSchedule1DocValidity();
        } else if (elemName === "line13AmountTextBox") {
            this.objInputFields.dLine13 = value;
            let adjustedValue = (value < 0) ? 0 : value;
            this.objInputFields.dLine13Adjusted = adjustedValue;
        } else if (elemName === "line14AmountTextBox") {
            this.objInputFields.dLine14 = value;
            let adjustedValue = (value < 0) ? 0 : value;
            this.objInputFields.dLine14Adjusted = adjustedValue;
        } else if (elemName === "line17AmountTextBox") {
            this.objInputFields.dLine17 = value;
            let adjustedValue = (value < 0) ? 0 : value;
            this.objInputFields.dLine17Adjusted = adjustedValue;
        } else if (elemName === "line18AmountTextBox") {
            this.objInputFields.dLine18 = value;
            let adjustedValue = (value < 0) ? 0 : value;
            this.objInputFields.dLine18Adjusted = adjustedValue;
        } else if (elemName === "line19AmountTextBox") {
            this.objInputFields.dLine19 = value;
            let adjustedValue = (value < 0) ? 0 : value;
            this.objInputFields.dLine19Adjusted = adjustedValue;
        } else if (elemName === "line21AmountTextBox") {
            this.objInputFields.dLine21 = value;
            this.objInputFields.dLine21Adjusted = this.objInputFields.dLine21;
        }
        //handle logic for Line6      
        if (elemName === "line1AmountTextBox" || elemName === "line2bAmountTextBox" || elemName === "line3bAmountTextBox" ||
            elemName === "line4aAmountTextBox" || elemName === "line5aAmountTextBox") {
            this.objInputFields.dLine6Adjusted = 0;
            this.objInputFields.dLine6Adjusted = this.objInputFields.dLine1Adjusted + this.objInputFields.dLine2bAdjusted +
                this.objInputFields.dLine3bAdjusted + this.objInputFields.dLine4aAdjusted +
                this.objInputFields.dLine5aAdjusted;

        }
        //handle logic for Line22
        else if (elemName === "line11AmountTextBox" || elemName === "line12AmountTextBox" || elemName === "line13AmountTextBox" ||
            elemName === "line14AmountTextBox" || elemName === "line17AmountTextBox" || elemName === "line18AmountTextBox" ||
            elemName === "line19AmountTextBox" || elemName === "line21AmountTextBox") {
            this.objInputFields.dLine22Adjusted = 0;
            this.objInputFields.dLine22Adjusted = this.objInputFields.dLine11Adjusted + this.objInputFields.dLine12Adjusted + this.objInputFields.dLine13Adjusted +
                this.objInputFields.dLine14Adjusted + this.objInputFields.dLine17Adjusted + this.objInputFields.dLine18Adjusted +
                this.objInputFields.dLine19Adjusted + this.objInputFields.dLine21Adjusted;

        }
        if (!this.objInputFields.bIsSchedule1) {
            this.objInputFields.dLine22Adjusted = 0;
        }
        this.objInputFields.dTotalAmount = 0;
        this.objInputFields.dTotalAmount = this.objInputFields.dLine6Adjusted + this.objInputFields.dLine22Adjusted;
    }

    //handle logic for Income calcualtion when RollOver is checked
    handleAmountChangeRollover() {

        this.objInputFields.dLine6Adjusted = 0;
        this.objInputFields.dLine6Adjusted = this.objInputFields.dLine1Adjusted + this.objInputFields.dLine2bAdjusted +
            this.objInputFields.dLine3bAdjusted + this.objInputFields.dLine4aAdjusted +
            this.objInputFields.dLine5aAdjusted;

        this.objInputFields.dTotalAmount = 0;
        this.objInputFields.dTotalAmount = this.objInputFields.dLine6Adjusted + this.objInputFields.dLine22Adjusted;

    }

    //handle logic for Income calcualtion when RollOver is checked
    handleAmountChangeSchedule1() {

        this.objInputFields.dLine22Adjusted = 0;
        this.objInputFields.dLine22Adjusted = this.objInputFields.dLine11Adjusted + this.objInputFields.dLine12Adjusted + this.objInputFields.dLine13Adjusted +
            this.objInputFields.dLine14Adjusted + this.objInputFields.dLine17Adjusted + this.objInputFields.dLine18Adjusted +
            this.objInputFields.dLine19Adjusted + this.objInputFields.dLine21Adjusted;

        this.objInputFields.dTotalAmount = 0;
        this.objInputFields.dTotalAmount = this.objInputFields.dLine6Adjusted + this.objInputFields.dLine22Adjusted;

    }

    //handle logic for Income caluclation when Schedule 1  is Unchecked
    handleSchedule1Unchecked() {
        this.objInputFields.dLine11 = null;
        this.objInputFields.dLine11Adjusted = null;
        this.objInputFields.dLine12 = null;
        this.objInputFields.dLine12Adjusted = null;
        this.objInputFields.dLine13 = null;
        this.objInputFields.dLine13Adjusted = null;
        this.objInputFields.dLine14 = null;
        this.objInputFields.dLine14Adjusted = null;
        this.objInputFields.dLine17 = null;
        this.objInputFields.dLine17Adjusted = null;
        this.objInputFields.dLine18 = null;
        this.objInputFields.dLine18Adjusted = null;
        this.objInputFields.dLine19 = null;
        this.objInputFields.dLine19Adjusted = null;
        this.objInputFields.dLine21 = null;
        this.objInputFields.dLine21Adjusted = null;
        this.objInputFields.dLine22Adjusted = 0;
        //clear the ScheduleC List
        this.scheduleCList.splice(0, this.scheduleCList.length);
        this.dLine3Total = 0;
        this.dLine29Total = 0;
        this.dLine31Total = 0;
        //update the total amount
        this.objInputFields.dTotalAmount = 0;
        this.objInputFields.dTotalAmount = this.objInputFields.dLine6Adjusted + this.objInputFields.dLine22Adjusted;
    }
    //Schedule C button is Clicked
    handleSchedule() {
        this.bShowScheduleC = true;
    }

    //set Is Schedule 1 Document value based on Adjusted value
    checkSchedule1DocValidity() {
        //Set Schedulec Doc complete based on Line12 entered & (Shcedule c enter value)
        if (this.scheduleCList.length.size === 0) {
            this.objInputFields.bScheduleCDocComplete = false;
            this.objInputFields.dLine12Adjusted = 0;

        } else if (!this.bLine3Disabled) {
            //value is entered in Line12 ShceduleC and check with Line 12 entered value & ShceduleC Line3
            this.objInputFields.dLine12Adjusted = this.dLine3Total;
            if (this.objInputFields.dLine12 === this.dLine3Total) {
                this.objInputFields.bScheduleCDocComplete = true;
            } else {
                this.objInputFields.bScheduleCDocComplete = false;;
            }
        } else if (!this.bLine29_31Disabled) {
            //value is entered in Line29/31 ShceduleC and check with Line 12 entered value & ShceduleC Line31
            this.objInputFields.dLine12Adjusted = this.dLine29Total;
            if (this.objInputFields.dLine12 === this.dLine31Total) {
                this.objInputFields.bScheduleCDocComplete = true;
            } else {
                this.objInputFields.bScheduleCDocComplete = false;;
            }
        }
    }

    //This methods adds an extra row in the ScheduleC table
    handleAdd() {
        this.scheduleCList.push({
            iScheduleCIndex: 0,
            sNumber: '1',
            dLine3: 0,
            dLine29: 0,
            dLine31: 0,
            sId: null
        });
        this.scheduleCList.forEach((elem, idx) => {
            elem.iScheduleCIndex = idx; // id starts from 0, 1, 2, 3 etc.
            elem.sNumber = (idx + 1); // iNumber starts from 1, 2, 3, 4, etc.            
        });
    }
    handleScheduleCAmountChange(event) {
        let index = event.target.dataset.id;
        let elemName = event.target.name;
        let elemValue = Number(event.detail.value);
        //round the decimal value
        let value = Math.trunc(elemValue);

        if (elemName === "ScheduleCline3") {
            this.scheduleCList[index].dLine3 = value;
            this.dLine3Total = 0;
            this.scheduleCList.forEach(element => {
                this.dLine3Total += element.dLine3;
            });

        } else if (elemName === "ScheduleCline29") {

            this.scheduleCList[index].dLine29 = value;
            this.dLine29Total = 0;
            this.scheduleCList.forEach(element => {
                this.dLine29Total += element.dLine29;
            });

        } else if (elemName === "ScheduleCline31") {
            this.scheduleCList[index].dLine31 = value;
            this.dLine31Total = 0;
            this.scheduleCList.forEach(element => {
                this.dLine31Total += element.dLine31;
            });
        }
        this.handleScheduleCLineEnable();
    }

    //handleScheduleC edit rows enable/Disable
    handleScheduleCLineEnable() {
        // Line 3, Lin29 & 31 is not entered enable all rows and updated Line12Ajusted field as zero
        if ((this.dLine3Total === 0 || this.dLine3Total === '' || this.dLine3Total === undefined) &&
            (this.dLine29Total === 0 || this.dLine29Total === '' || this.dLine29Total === undefined) &&
            (this.dLine31Total === 0 || this.dLine31Total === '' || this.dLine31Total === undefined)) {

            this.bLine3Disabled = false;
            this.bLine29_31Disabled = false;
            this.objInputFields.dLine12Adjusted = 0;
        } //Lin29 & 31 is entered disable Line3 and update Line12Ajusted field as Subtotal of  line 29 Sch C
        else if (this.dLine3Total === 0 || this.dLine3Total === '' ||
            this.dLine3Total === undefined) {

            this.bLine3Disabled = true;
            this.bLine29_31Disabled = false;
            this.objInputFields.dLine12Adjusted = this.dLine29Total;

        }
        //Line3 is entered disable Lin29 & 31 and update Line12Ajusted field as Subtotal of  line 3 Sch C
        else if (this.dLine29Total === 0 || this.dLine29Total === '' || this.dLine29Total === undefined ||
            this.dLine31Total === 0 || this.dLine31Total === '' || this.dLine31Total === undefined) {
            this.bLine3Disabled = false;
            this.bLine29_31Disabled = true;
            this.objInputFields.dLine12Adjusted = this.dLine3Total;
        }
    }
    //This method handles delete the ScheduleC rows
    handleDelete(event) {
        this.startIdx = Number(event.target.dataset.id);
        this.scheduleCList.splice(this.startIdx, 1);
        //refresh the list after deletion
        this.scheduleCList.forEach((elem, idx) => {
            elem.iScheduleCIndex = idx; // id starts from 0, 1, 2, 3 etc.
            elem.sNumber = (idx + 1); // iNumber starts from 1, 2, 3, 4, etc.            
        });
        //update the totalAmount based on the deleted row
        this.updateScheduleCTotalAmount();
        //if all the rows are deleted, reset the disable condition 
        if (this.scheduleCList.length === 0) {
            this.bLine3Disabled = false;
            this.bLine29_31Disabled = false;
        }
    }

    //update ScheduleC Total section based on row addition/deletion
    updateScheduleCTotalAmount() {
        this.dLine3Total = 0;
        this.dLine29Total = 0;
        this.dLine31Total = 0;
        this.scheduleCList.forEach(element => {
            this.dLine3Total += element.dLine3;
            this.dLine29Total += element.dLine29;
            this.dLine31Total += element.dLine31;
        });
    }


    //handle save for Income Document
    handleSave() {
        this.showLoadingSpinner = true;
        //Set ScheduleC Doc Complete if no value is entered in Line 12 and ScheduleC
        if ((this.objInputFields.dLine12 === null || this.objInputFields.dLine12 === undefined) &&
            (this.dLine3Total === 0) && (this.dLine31Total === 0)) {
            this.objInputFields.bScheduleCDocComplete = true;
        }
        this.objInputFields.idCareApp = this.idCareApp;
        this.objInputFields.idCareHouseholdDetail = this.idHouseholdMember;
        this.objInputFields.idCareHouseholdmemberIncome = this.idMemberIncome;
        this.objInputFields.dDiscountLength = this.dDiscountLength;
        this.objInputFields.sIncomeSourceType = this.sIncomeSource;
        this.objInputFields.sDocumentType = this.sDocumentType;
        this.objInputFields.sFormType = this.sFormType;
        this.objInputFields.listHouseholdMemberIncomeC = this.scheduleCList;

        saveHouseholdIncome({
                objWrapperFormInput: this.objInputFields
            })
            .then(result => {
                if (result) {
                    this.showToastMessage(this.label.SuccessHeader, this.label.IncomeDocSuccessMsg, 'success');
                    this.refreshData(); //refresh document section                      
                    this.showLoadingSpinner = false;
                    this.refreshIncomeInfo(); //refresh Parent income info section 
                } else {
                    this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
                    this.showLoadingSpinner = false;
                    console.log('error' + error);
                }
            })
            .catch(error => {
                this.showToastMessage(this.label.SuccessHeader, this.label.TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;
            });
    }

    // in order to refresh Income Document Section, execute this function:
    refreshData() {
        return refreshApex(this._wiredIncomeDocResult);
    }

    //refresh the parent component income info table through child event
    refreshIncomeInfo() {
        // Creates the event with the data.
        const refreshIncomeDetails = new CustomEvent("refreshincomeinfo", {});
        // Dispatches the event.
        this.dispatchEvent(refreshIncomeDetails);
    }

    //close ScheduleC modal
    closeModal() {
        this.bShowScheduleC = false;
        this.checkSchedule1DocValidity(); //handle doc complete logic
        this.handleAmountChangeSchedule1(); //handle logic for updating total amount
    }

    //Toast Message to shows  
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