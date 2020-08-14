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
import SelectPeriodMsg from '@salesforce/label/c.CARE_SelectPeriodMsg';

export default class Care_BankStatementForm extends LightningElement {
    @api idCareApp;
    @api idHouseholdMember;
    @api sIncomeSource;
    @api sDocumentType;
    @api sFormType;
    @api dDiscountLength;
    @api idMemberIncome;
    @api bViewMode;

    @track showLoadingSpinner;
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
        iMonthNo: '0',
        sPeriodType: 'Monthly',
        dAmount1: null,
        dAmount2: null,
        dTotalAmount: 0
    }
    label = {
        IncomeDocSuccessMsg,
        TransactionErrorMsg,
        ErrorHeader,
        SuccessHeader,
        SelectPeriodMsg
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
            this.periodOptions = data.values;
            this.error = undefined;
        }
        if (error) {
            this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.periodOptions = undefined;
        }
    }
    /** Wired Apex result so it can be refreshed programmatically */
    _wiredIncomeFormResult;

    //wire Method to get the form entered Income details
    @wire(getHouseMemberIncomeDetails, {
        IdCareHouseholdmemberIncome: '$idMemberIncome'
    })
    wiredIncomeFormInformation(value) {
        this._wiredIncomeFormResult = value;
        const {
            data,
            error
        } = value;
        if (data) {
            console.log('Apex call is refreshed for showing in the child' + JSON.stringify(data));
            this.objInputFields.bIsValidDoc = data.bIsValidDoc;
            this.objInputFields.bIsFillingJointly = data.bIsFillingJointly;
            this.objInputFields.dAmount1 = data.dAmount1;
            this.objInputFields.dAmount2 = data.dAmount2;
            this.objInputFields.sPeriodType = data.sPeriodType;
            this.objInputFields.dTotalAmount = data.dTotalAmount;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showLoadingSpinner = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
        }
    }

    handleChecked(event) {
        let elemName = event.target.name;
        //checkbox is selected for "Is Document Valid" checkbox
        if (elemName === "DocValidChecked") {
            this.objInputFields.bIsValidDoc = event.target.checked;
        }
    }

    //handle logic when an amount/month is entered
    handleAmountChange(event) {
        let elemName = event.target.name;
        let elemValue = Number(event.detail.value);
        let value = Math.trunc(elemValue);

        if (elemName === "amount1TextBox") {
            this.objInputFields.dAmount1 = value;
            //this.objInputFields.dTotalAmount = this.objInputFields.dAmount1;
        } else if (elemName === "amount2TextBox") {
            this.objInputFields.dAmount2 = value;
        }
        this.updateAnnualSalary(); //update Annual Amount
    }

    //handle logic for updating Annual Salary based on the entered Amount & Period
    updateAnnualSalary() {
        //Amount 1 is entered & Amount  2 is not entered
        if ((this.objInputFields.dAmount1 > 0) &&
            (this.objInputFields.dAmount2 === 0 || this.objInputFields.dAmount2 === null || this.objInputFields.dAmount2 === undefined)) {
            let finalAmount = this.objInputFields.dAmount1 * 12;
            let finalAmountRoundedOf = Math.round(finalAmount);
            this.objInputFields.dTotalAmount = finalAmountRoundedOf;
        }
        //Amount 1 is not entered & Amount 2 is entered
        else if ((this.objInputFields.dAmount1 === 0 || this.objInputFields.dAmount1 === null || this.objInputFields.dAmount1 === undefined) &&
            (this.objInputFields.dAmount2 > 0)) {
            let finalAmount = this.objInputFields.dAmount2 * 12;
            let finalAmountRoundedOf = Math.round(finalAmount);
            this.objInputFields.dTotalAmount = finalAmountRoundedOf;
        }
        //Amount 1 is entered & Amount  2 is  entered
        else if ((this.objInputFields.dAmount1 > 0) && (this.objInputFields.dAmount2 > 0)) {
            let averageAmount = (this.objInputFields.dAmount1 + this.objInputFields.dAmount2) / 2;
            let finalAmount = averageAmount * 12;
            let finalAmountRoundedOf = Math.round(finalAmount);
            this.objInputFields.dTotalAmount = finalAmountRoundedOf;
        }
        //Amount 1 is not entered & Amount  2 is not entered
        else {
            this.objInputFields.dTotalAmount = 0;
        }
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

        saveHouseholdIncome({
                objWrapperFormInput: this.objInputFields
            })
            .then(result => {
                console.log('result after Income record Apex call ==>' + JSON.stringify(result));
                if (result) {
                    this.showToastMessage(this.label.SuccessHeader, this.label.IncomeDocSuccessMsg, 'success');
                    this.showLoadingSpinner = false;
                    //refresh the parent income Table
                    this.refreshIncomeInfo();
                    //refresh the wired form details
                    this.refreshData();
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

    // in order to refresh Income form data, execute this function:
    refreshData() {
        return refreshApex(this._wiredIncomeFormResult);
    }

    //refresh the parent component income info table through child event
    refreshIncomeInfo() {
        // Creates the event with the data.
        const refreshIncomeDetails = new CustomEvent("refreshincomeinfo", {});
        // Dispatches the event.
        this.dispatchEvent(refreshIncomeDetails);
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