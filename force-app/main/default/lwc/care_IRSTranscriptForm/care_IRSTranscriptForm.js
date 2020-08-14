import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    refreshApex
} from '@salesforce/apex';

import {
    getPicklistValues
} from 'lightning/uiObjectInfoApi';
import PERIOD_TYPE from '@salesforce/schema/CARE_Household_Member_Income__c.PERIOD_TYPE__c';

import saveHouseholdIncome from '@salesforce/apex/CARE_IncomeInformationController.saveHouseholdIncome';
import getHouseMemberIncomeDetails from '@salesforce/apex/CARE_IncomeInformationController.getHouseMemberIncomeDetails';
//Labels
import IncomeDocSuccessMsg from '@salesforce/label/c.CARE_IncomeDocSuccessMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';

export default class Care_IRSTranscriptForm extends LightningElement {
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
    @track objInputFields = {
        idCareApp: '',
        idCareHouseholdDetail: '',
        idCareHouseholdmemberIncome: '',
        dDiscountLength: null,
        sIncomeSourceType: '',
        sDocumentType: '',
        sFormType: '',
        bIsValidDoc: false,
        bIsSchedule1: false,
        bIsFillingJointly: false,
        bRollover: false,
        bIsSchedule1: false,
        bSchedule1DocValid: false,
        bScheduleCDocComplete: false,
        iMonthNo: 0,
        sPeriodType: 'Annually',
        dAmount1: null,
        dAmount2: null,
        dAmount3: null,
        dAmount4: null,
        dAmount5: null,
        dAmount6: null,
        dAmount7: null,
        dAmount8: null,
        dAmount9: null,
        dTotalAmount: 0
    }
    label = {
        IncomeDocSuccessMsg,
        TransactionErrorMsg,
        ErrorHeader,
        SuccessHeader
    };

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

            this.objInputFields.bIsValidDoc = data.bIsValidDoc;
            this.objInputFields.bIsFillingJointly = data.bIsFillingJointly;
            this.objInputFields.dAmount1 = data.dAmount1;
            this.objInputFields.dAmount2 = data.dAmount2;
            this.objInputFields.dAmount3 = data.dAmount3;
            this.objInputFields.dAmount4 = data.dAmount4;
            this.objInputFields.dAmount5 = data.dAmount5;
            this.objInputFields.dAmount6 = data.dAmount6;
            this.objInputFields.dAmount7 = data.dAmount7;
            this.objInputFields.dAmount8 = data.dAmount8;
            this.objInputFields.dAmount9 = data.dAmount9;
            this.objInputFields.dTotalAmount = data.dTotalAmount;
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
        }
    }
    //handle logic when an amount is entered
    handleAmountChange(event) {
        let elemName = event.target.name;
        let elemValue = Number(event.detail.value);
        let value = Math.trunc(elemValue);

        if (elemName === "amount1TextBox") {
            this.objInputFields.dAmount1 = value;
        } else if (elemName === "amount2TextBox") {
            this.objInputFields.dAmount2 = value;
        } else if (elemName === "amount3TextBox") {
            this.objInputFields.dAmount3 = value;
        } else if (elemName === "amount4TextBox") {
            this.objInputFields.dAmount4 = value;
        } else if (elemName === "amount5TextBox") {
            this.objInputFields.dAmount5 = value;
        } else if (elemName === "amount6TextBox") {
            this.objInputFields.dAmount6 = value;
        } else if (elemName === "amount7TextBox") {
            this.objInputFields.dAmount7 = value;
        } else if (elemName === "amount8TextBox") {
            this.objInputFields.dAmount8 = value;
        } else if (elemName === "amount9TextBox") {
            this.objInputFields.dAmount9 = value;
        }
        //handle total Amount calculation
        this.objInputFields.dTotalAmount = this.objInputFields.dAmount1 + this.objInputFields.dAmount2 +
            this.objInputFields.dAmount3 + this.objInputFields.dAmount4 + this.objInputFields.dAmount5 +
            this.objInputFields.dAmount6 + this.objInputFields.dAmount7 +
            this.objInputFields.dAmount8 + this.objInputFields.dAmount9;
    }
    //handle save for Income Document
    handleSave() {
        this.showLoadingSpinner = true;

        this.objInputFields.idCareApp = this.idCareApp;
        this.objInputFields.idCareHouseholdDetail = this.idHouseholdMember;
        this.objInputFields.idCareHouseholdmemberIncome = this.idMemberIncome;
        this.objInputFields.dDiscountLength = this.dDiscountLength;
        this.objInputFields.sIncomeSourceType = this.sIncomeSource;
        this.objInputFields.sDocumentType = this.sDocumentType;
        this.objInputFields.sFormType = this.sFormType;
        console.log('objInputField1==>' + JSON.stringify(this.objInputFields))

        saveHouseholdIncome({
                objWrapperFormInput: this.objInputFields
            })
            .then(result => {
                console.log('result after Income record Apex call ==>' + JSON.stringify(result));
                if (result) {
                    this.showToastMessage(this.label.SuccessHeader, this.label.IncomeDocSuccessMsg, 'success');
                    this.refreshData(); //refresh document section                      
                    this.showLoadingSpinner = false;
                    this.refreshIncomeInfo(); //refresh Parent income info section 
                } else {
                    this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
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