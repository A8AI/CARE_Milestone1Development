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

import getPersonIncomeInformation from '@salesforce/apex/CARE_IncomeInformationController.getPersonIncomeInformation';
import getIncomeDocumentType from '@salesforce/apex/CARE_IncomeInformationController.getIncomeDocumentType';
import getIncomeFormType from '@salesforce/apex/CARE_IncomeInformationController.getIncomeFormType';
import deleteHouseholdIncomeRecord from '@salesforce/apex/CARE_IncomeInformationController.deleteHouseholdIncomeRecord';

//Labels
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import IncomeDocDeleteSuccessMsg from '@salesforce/label/c.CARE_IncomeDocDeleteSuccessMsg';
import ConfirmationDeleteMsg from '@salesforce/label/c.CARE_ConfirmationDeleteMsg';
import DeleteMsgHeader from '@salesforce/label/c.CARE_DeleteMsgHeader';
import RecordSelectMsg from '@salesforce/label/c.CARE_RecordSelectMsg';
import CurrencySymbol from '@salesforce/label/c.CARE_CurrencySymbol';

export default class Care_IncomeInformation extends LightningElement {

    @api idCareApp;
    @api idHouseholdMember; //Individual House hold member Id
    @api sHouseholdMemberName; ///Individual House hold member Name
    @api sAppType; //Type of Application PEV /HU
    @api bViewMode;
    @api sAdultCount;//no:of Adult 

    @api bShowModal;
    @track showLoadingSpinner = false;
    @track bShowDeleteModal = false
    @track bIncomeSourceDisabled = true;
    @track bShowIncomeTable = false;
    @track bAddDisabled = false;
    @track bResetDisabled = true;
    @track bIncreaseModalHeight = false;
    @track dataIncomeInformation;
    @track dataIncomeSourceOptions;
    @track totalAnnualAmount;
    @track bDisableIncomeDocType = true;
    @track sFormName;
    @track sIncomeSourceName = '';
    @track sDocName = '';
    @track dDiscountLength;
    @track bCategoricalForm = false;
    @track bTranscriptForm = false;
    @track bIRS2018Form = false;
    @track bCategoricalFixedForm = false;
    @track b1099Form = false;
    @track b1040XForm = false;
    @track bBankStatementForm = false;
    @track bMultiPayPeriodsTwoForm = false;
    @track bMultiPayPeriodsForm = false;
    @track bIRS2019Form = false;
    @track bIRS1040SRForm = false;
    @track idSelectedRecord = null;

    @track error;
    @track objInputFields = {
        sIncomeSource: '',
        sDocumentType: ''
    }
    label = {
        TransactionErrorMsg,
        ErrorHeader,
        SuccessHeader,
        IncomeDocDeleteSuccessMsg,
        ConfirmationDeleteMsg,
        DeleteMsgHeader,
        RecordSelectMsg,
        CurrencySymbol
    }
    /** Wired Apex result so it can be refreshed programmatically */
    _wiredIncomeInfoResult;

    @wire(getPersonIncomeInformation, {
        idHouseholdDetail: '$idHouseholdMember',
        idCareApplication: '$idCareApp',
        sApplicationType: '$sAppType'
    })
    wiredIncomeInformation(value) {
        this._wiredIncomeInfoResult = value;
        const {
            data,
            error
        } = value;
        if (data) {
            console.log('Apex call is refreshed for showing in the Parent' + JSON.stringify(data));
            this.dataIncomeInformation = data.listHouseholdIncome;
            this.totalAnnualAmount = data.dMemberAnnualSalary;
            this.dataIncomeSourceOptions = data.listIncomeSource;
            //hide income add section ,if document is already added
            if (this.dataIncomeInformation.length > 0) {
                this.bShowIncomeTable = true;
            }
            //hide Income Table
            else {
                this.bShowIncomeTable = false;
                this.bIncomeSourceDisabled = false;
                this.bAddDisabled = true;
                this.bResetDisabled = false;
                this.bIncreaseModalHeight = true;
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showLoadingSpinner = false;
            this.bShowModal = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
        }
    }

    getDocumentType() {
        this.showLoadingSpinner = true;
        console.log('input' + this.objInputFields);
        getIncomeDocumentType({
                objIncomeInput: this.objInputFields
            })
            .then(result => {
                this.dataIncomeDocumentOptions = result.listIncomeDocument;
                this.showLoadingSpinner = false;
            })
            .catch(error => {
                this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;
            });

    }

    getFormType() {
        this.showLoadingSpinner = true;
        console.log('input' + this.objInputFields);
        getIncomeFormType({
                objIncomeInput: this.objInputFields
            })
            .then(result => {
                this.sFormName = result.sFormType;
                this.sIncomeSourceName = result.sSourceTypeName;
                this.sDocName = result.sDocTypeName;
                this.dDiscountLength = result.dDiscountLength;

                this.handleFormAssignment();
                this.bIncreaseModalHeight = false;
                this.showLoadingSpinner = false;
            })
            .catch(error => {
                this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
                this.showLoadingSpinner = false;

            });

    }

    //show Income Document section on clicking on Add button      
    handleAdd() {

        this.reintializeForm();
        this.refreshData();
        this.bIncomeSourceDisabled = false;
        this.bAddDisabled = true;
        this.bResetDisabled = false;
        this.bIncreaseModalHeight = true;
    }

    //reset the income source,document & form selected
    handleReset() {

        this.bIncomeSourceDisabled = false;
        this.bDisableIncomeDocType = false;
        this.bIncreaseModalHeight = true;
        this.sDocName = '';
        this.idSelectedRecord = null;
        this.bCategoricalForm = false;
        this.bTranscriptForm = false;
        this.bIRS2018Form = false;
        this.bCategoricalFixedForm = false;
        this.b1099Form = false;
        this.b1040XForm = false;
        this.bBankStatementForm = false;
        this.bMultiPayPeriodsTwoForm = false;
        this.bMultiPayPeriodsForm = false;
        this.bIRS2019Form = false;
        this.bIRS1040SRForm = false;

    }
    //call confirmation modal before deleting the record      
    handleDelete(event) {
        //Validate if record is selected  
        this.idSelectedRecord = event.target.dataset.id;
        this.bShowDeleteModal = true;
    }
    //delete income information record after confirmation
    deleteRec() {
        deleteHouseholdIncomeRecord({
                idHouseholdMember: this.idSelectedRecord,
                idCareApp: this.idCareApp,
                idHouseholdDetail: this.idHouseholdMember
            })

            .then(() => {
                this.showToastMessage('Record Deleted', this.label.IncomeDocDeleteSuccessMsg, 'success');
                this.refreshData();
                this.bShowDeleteModal = false;
                this.idSelectedRecord = null;
            })
            .catch((error) => {
                this.showToastMessage('Application Error', this.label.TransactionErrorMsg, 'error');
            });
    }
    //show Income Document of selected record on clicking on View button      
    handleView(event) {
        this.reintializeForm();
        this.idSelectedRecord = event.target.dataset.id;
        this.sIncomeSourceName = event.target.dataset.incomeSource;
        this.objInputFields.sIncomeSource = this.sIncomeSourceName;
        this.dDiscountLength = event.target.dataset.discountLength;

        //set up the Doc Type combobox for showing in the UI .
        let incomeDocument = event.target.dataset.docType;
        this.dataIncomeDocumentOptions = [{
            label: incomeDocument,
            value: incomeDocument
        }];
        this.sDocName = incomeDocument;

        //set up the form
        let formName = event.target.dataset.formType;
        this.sFormName = formName;
        this.handleFormAssignment(); //handle for Assignment
        this.bIncomeSourceDisabled = true;
        this.bDisableIncomeDocType = true;

    }

    handleFormAssignment() {
        console.log('this.sFormName' + this.sFormName);
        switch (this.sFormName) {
            case 'Award Letter Categorical':
                this.bCategoricalForm = true;
                break;
            case 'Award Letter Categorical Fixed':
                this.bCategoricalFixedForm = true;
                break;
            case '1099':
                this.b1099Form = true;
                break;
            case '1040 X':
                this.b1040XForm = true;
                break;
            case 'Bank Statement':
                this.bBankStatementForm = true;
                break;
            case 'Multi Pay Periods Two':
                this.bMultiPayPeriodsTwoForm = true;
                break;
            case 'Multi Pay Periods':
                this.bMultiPayPeriodsForm = true;
                break;
            case 'Transcript':
                this.bTranscriptForm = true;
                break;
            case 'IRS 1040 2019':
                this.bIRS2019Form = true;
                break;
            case 'IRS 1040 SR':
                this.bIRS1040SRForm = true;
                break;
            case 'IRS 1040 2018':
                this.bIRS2018Form = true;
                break;
            default:
        }
    }
    // in order to refresh Income data, execute this function:
    refreshData() {
        this.reintializeForm();
        return refreshApex(this._wiredIncomeInfoResult);
    }


    // handle logic once after Income Source is Selected
    handleChange(event) {
        let elemName = event.target.name;
        let value = event.target.value;

        //Income Source picklist is selected
        if (elemName === "incomeSourceCombo") {
            this.objInputFields.sIncomeSource = value;
            this.bDisableIncomeDocType = false; //enable selection of document type
            this.getDocumentType();
        }
        //Income Document Type picklist is selected
        else if (elemName === "incomeDocumentCombo") {
            this.objInputFields.sDocumentType = value;
            this.getFormType();
            this.bIncomeSourceDisabled = true;
            this.bDisableIncomeDocType = true;
        }
    }
    //re intialize form values.
    reintializeForm() {
        this.bAddDisabled = false;
        this.bResetDisabled = true;
        this.bIncreaseModalHeight = false;
        this.bIncomeSourceDisabled = true;
        this.bDisableIncomeDocType = true;
        this.sIncomeSourceName = '';
        this.sDocName = '';
        this.idSelectedRecord = null;
        this.bCategoricalForm = false;
        this.bTranscriptForm = false;
        this.bIRS2018Form = false;
        this.bCategoricalFixedForm = false;
        this.b1099Form = false;
        this.b1040XForm = false;
        this.bBankStatementForm = false;
        this.bMultiPayPeriodsTwoForm = false;
        this.bMultiPayPeriodsForm = false;
        this.bIRS2019Form = false;
        this.bIRS1040SRForm = false;

    }
    //Close  IncomeInformation Modal Popup
    closeModal() {
        this.dataIncomeSourceOptions = null;
        this.bShowModal = false;
        this.bIncomeSourceDisabled = true;
        this.bDisableIncomeDocType = true;
        this.sFormName = '';
        this.idSelectedRecord = null;
        this.reintializeForm();
        this.refreshPEVParentComp();
    }
    //Close Delete confirmation  Modal Popup
    closeConfirmationModal() {
        this.bShowDeleteModal = false;
    }

    //rfresh the parent PEV/HU Tab on closing income Modal Popup
    refreshPEVParentComp() {
        const pevHuFormRefreshEvent = new CustomEvent("pevhuformrefresh", {
            detail: this.idCareApp //Pass the application Id
        });

        this.dispatchEvent(pevHuFormRefreshEvent);
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