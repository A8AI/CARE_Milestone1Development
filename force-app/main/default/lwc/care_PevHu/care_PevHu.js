import { LightningElement, track, wire, api } from 'lwc';
import submitPEVForm from '@salesforce/apex/CARE_PEVHUController.submitPEVForm';
import getPevHuData from '@salesforce/apex/CARE_PEVHUController.getPevHuData';
import getRelatedSA from '@salesforce/apex/CARE_PEVHUController.getRelatedSA';
import deleteCareHouseholdDet from '@salesforce/apex/CARE_PEVHUController.deleteCareHouseholdDet';
import setCancelStatusCareApplication from '@salesforce/apex/CARE_UtilityController.setCancelStatusCareApplication';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { phoneMask, formatString, isBlank, isNotBlank } from 'c/care_Utilities';

//Label
import CARE_ConfirmationDeleteMsg from '@salesforce/label/c.CARE_ConfirmationDeleteMsg';
import CARE_CurrencySymbol from '@salesforce/label/c.CARE_CurrencySymbol';
import CARE_PEVHUSaveMsg from '@salesforce/label/c.CARE_PEVHUSaveMsg';
import CARE_PEVHUProcessingMsg from '@salesforce/label/c.CARE_PEVHUProcessingMsg';
import CARE_PEVHUAcceptMsg from '@salesforce/label/c.CARE_PEVHUAcceptMsg';
import CARE_EnrollmentDocumentValidationMsg from '@salesforce/label/c.CARE_EnrollmentDocumentValidationMsg';
import CARE_PEVHUCreateErrorMsg from '@salesforce/label/c.CARE_PEVHUCreateErrorMsg';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import CARE_CommentFieldLengthValidationMsg from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CARE_StartDateValidationMsg from '@salesforce/label/c.CARE_StartDateValidationMsg';
import CARE_RetroStartDateValidationMsg from '@salesforce/label/c.CARE_RetroStartDateValidationMsg';
import CARE_RetroDateValidationMsg from '@salesforce/label/c.CARE_RetroDateValidationMsg';
import CARE_EnrollmentEditErrorMsg from '@salesforce/label/c.CARE_EnrollmentEditErrorMsg';
import CARE_CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import CARE_ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CARE_TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import CARE_TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CARE_IncomePeopleMismatch from '@salesforce/label/c.CARE_IncomePeopleMismatch';
import CARE_IncomeDocumentInvalid from '@salesforce/label/c.CARE_IncomeDocumentInvalid';
import CARE_PEVHUVerificationError from '@salesforce/label/c.CARE_PEVHUVerificationError';
import CARE_NotModifiedRstREndMsg from '@salesforce/label/c.CARE_NotModifiedRstREndMsg';
import CARE_NoRecordsDoAdjustment from '@salesforce/label/c.CARE_NoRecordsDoAdjustment';
import CARE_SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg';
import CARE_COCLengthValidationMsg from '@salesforce/label/c.CARE_COCLengthValidationMsg';
import CARE_ValidValValidationMsg from '@salesforce/label/c.CARE_ValidValValidationMsg';
import CARE_PersonNameValidationMsg from '@salesforce/label/c.CARE_PersonNameValidationMsg';
import CARE_IncomeInfoDeleteMsg from '@salesforce/label/c.CARE_IncomeInfoDeleteMsg';


const columnsPevSADetails = [
    { label: 'SA ID (TYPE)', fieldName: 'sSaId', initialWidth: 130 },
    { label: 'YES DATE', fieldName: 'dYesDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'NO DATE', fieldName: 'dNoDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'SVC ADDRESS', fieldName: 'sSvcAdd' },
    { label: 'RATE SCHEDULE', fieldName: 'sRateSchedule' },
    { label: 'RETRO START DATE', fieldName: 'dRStartDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'RETRO END DATE', fieldName: 'dREndDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'CC&B START DATE', fieldName: 'dCcbSAstartDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'LAST BILL DATE', fieldName: 'dLastBillDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
];
const columnsPevSADetailsWithEditing = [
    { label: 'SA ID (TYPE)', fieldName: 'sSaId', initialWidth: 130 },
    { label: 'YES DATE', fieldName: 'dYesDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'NO DATE', fieldName: 'dNoDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'SVC ADDRESS', fieldName: 'sSvcAdd' },
    { label: 'RATE SCHEDULE', fieldName: 'sRateSchedule' },
    { label: 'RETRO START DATE', fieldName: 'dRStartDate', type: 'date-local', typeAttributes: { day: "2-digit", month: "2-digit" }, editable: true },
    { label: 'RETRO END DATE', fieldName: 'dREndDate', type: 'date-local', typeAttributes: { day: "2-digit", month: "2-digit" }, editable: true },
    { label: 'CC&B START DATE', fieldName: 'dCcbSAstartDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
    { label: 'LAST BILL DATE', fieldName: 'dLastBillDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric" } },
];

export default class Care_PevHu extends LightningElement {
    @api sSelectedPerId;
    @api listSelectedPremIds = [];
    @api sSelectedApplicantName;
    @api sSelectedAppId;
    @api bAccOnProbation;
    @api sSelectedAcctId;
    @api sSelectedAcctEmail;
    @api bModalFlag;
    @api sLiveCall;
    @track showLoadingSpinner = true;
    @track bPEV = false;
    @track bHU = false;
    @track objPEVFields = {
        sApplicantName: '',
        iAdultValue: 1,
        iChildrenValue: 0,
        iNoWithIncome: 1,
        sProcessDate: new Date(),
        sReceiveDate: new Date(),
        bRequestedDrop: false,
        bNoAttachment: false,
        sSourceChannelType: '',
        sFormCode: '',
        sCocCode: '',
        sEmail: '',
        iAnnualInc: 0,
        iTotalPersons: 1,
        bOnProbation: false,
        bPevForm: true,
        sApplicationStatus: '',
        bIsAdjustment: false,
        sAdjustReasonValue: '',
        sCcbContactCode: '',
        sCcbContactDesc: '',
        sCcbContactComment: '',
        sProcessNotes: '',
        sLastModifiedById: '',
        sLastModifiedDate: '',
        sQualifiedBy: '',
        sEIAccountName: '',
        sEIAccountId: '',
        bIsSuccess: false
    };
    @track incomeInfoList = [{
        iIncomeIndex: 0,
        sNumber: 'Per 1',
        sPersonName: '',
        dEstAnnSal: 0,
        sIncSrcStatus: '',
        iNoDocs: 0,
        sId: ''
    }];
    @track bShowDeleteModal = false;
    @track maskedPhone;
    @track adjustReasonList;
    @track sGeneratedCareAppId = '';
    @track careSAData = [];
    @track columnsPevSADetails = columnsPevSADetails;
    @track columnsPevSADetailsWithEditing = columnsPevSADetailsWithEditing;
    @track adjustReasonList;
    @track isAdjustmentReasonCheck = true;
    @track isDataTableEditable = false;
    @track draftValues = [];
    @track bOpenAsModal;
    @track bRecordInputsCheck = true;
    _bViewMode = false;
    bShowConfirmationModal = false;
    bDocumentEntryModal = false;
    sEventNameAction = '';
    sEventVariant = 'info';
    sPEVorHU = '';
    rowPersonName;
    bAdjustmentAtleastOneRowValid = false;
    _wiredRelatedSA;
    _wiredPEVData;

    label = {
        CARE_ConfirmationDeleteMsg,
        CARE_CurrencySymbol,
        CARE_PEVHUSaveMsg,
        CARE_PEVHUProcessingMsg,
        CARE_PEVHUAcceptMsg,
        CARE_EnrollmentDocumentValidationMsg,
        CARE_PEVHUCreateErrorMsg,
        CARE_SuccessHeader,
        CARE_ErrorHeader,
        CARE_CommentFieldValidationMsg,
        CARE_CommentFieldLengthValidationMsg,
        CARE_StartDateValidationMsg,
        CARE_RetroStartDateValidationMsg,
        CARE_RetroDateValidationMsg,
        CARE_EnrollmentEditErrorMsg,
        CARE_CancelHeader,
        CARE_ConfirmationMsg,
        CARE_TransactionSuccessMsg,
        CARE_TransactionErrorMsg,
        CARE_IncomePeopleMismatch,
        CARE_IncomeDocumentInvalid,
        CARE_PEVHUVerificationError,
        CARE_NotModifiedRstREndMsg,
        CARE_NoRecordsDoAdjustment,
        CARE_SelectCommentMsg,
        CARE_COCLengthValidationMsg,
        CARE_ValidValValidationMsg,
        CARE_PersonNameValidationMsg,
        CARE_IncomeInfoDeleteMsg
    }

    showToastMessage(toastTitle, msg, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: msg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    get rowId() {
        return this._rowId;
    }
    set rowId(value) {
        this._rowId = value;
    }

    get showViewOnly() {
        return this.objPEVFields.sApplicationStatus === "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled" || this.bModalFlag;
    };
    set showViewOnly(value) {
        this._bViewMode = value;
    }

    get getDocEntryIcon() {
        if (this.objPEVFields.sApplicationStatus === "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled" || this.bModalFlag) {
            return { iconName: "action:view_relationship", title: "View Income Document" };
        }
        else {
            return { iconName: "action:add_relationship", title: "Add Income Document" };
        }
    };

    get checkApplicationId() {
        return isNotBlank(this.sGeneratedCareAppId) && this.sGeneratedCareAppId.length > 0;
    }
    get checkResultDesc() {
        return (isBlank(this.objPEVFields.sCcbContactDesc) || this.objPEVFields.sApplicationStatus === "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled");
    }
    get checkAcceptedApplication() {
        return this.objPEVFields.sApplicationStatus === "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled" || this.bModalFlag;  // Added Viewonly flag for adjustment check box after accepting application not allow modify adjustment
    }
    get checkAppIdORAccepted() {
        return isBlank(this.sGeneratedCareAppId) || this.objPEVFields.sApplicationStatus == "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled";
    }
    get showSADatatable() {
        return isNotBlank(this.objPEVFields.sCcbContactDesc) && (this.careSAData !== null && this.careSAData !== undefined && this.careSAData.length > 0);
    }
    get checkDataTableNoEdit() {
        return this.objPEVFields.sApplicationStatus == "Decision Made" || this.objPEVFields.sApplicationStatus == "Cancelled" || this.bModalFlag || !this.objPEVFields.bIsAdjustment;  // Added Viewonly flag for adjutsment check box after accepting application not allow modify adjustment
    }
    
    //Wired method to populate PEV HU form with existing In-Progress record or blank form
    @wire(getPevHuData, { sPersonId: '$sSelectedPerId', sSelectedAppId: '$sSelectedAppId', sLiveCall: '$sLiveCall' })
    pevDataValue(resp) {
        this._wiredPEVData = resp;
        const { data, error } = resp;
        if (data !== undefined && data != null && data.bIsSuccess) {
            console.log('prePopulated data value is with JSON.Stringify' + JSON.stringify(data));

            //Start: Populate the Household Information
            this.objPEVFields = data;
            this.objPEVFields = { ...this.objPEVFields };
            //For viewing from History, retrieve Care_Application.On_Probation, else populate from Care_Application.Account.CARE_ON_PROBATION__c (passed from parent lwc)
            //Use the parent lwc sent value Care_Application.Account.CARE_ON_PROBATION__c for 'tab' mode
            if (this.sSelectedAppId === 'tab') {
                this.objPEVFields.bOnProbation = this.bAccOnProbation;
                this.objPEVFields.sApplicantName = this.sSelectedApplicantName;
                this.objPEVFields.sEmail = this.sSelectedAcctEmail;
            }
            //End: Populate the Household Information

            //Start: Populate the Income information table
            this.incomeInfoList = [];
            data.listCareHhDetailWrapper.forEach((element, idx) => {
                let incomeInfoObj = { ...element };
                incomeInfoObj.sId = incomeInfoObj.sId;
                incomeInfoObj.sPersonName = incomeInfoObj.sPersonName;
                incomeInfoObj.dEstAnnSal = incomeInfoObj.dEstAnnSal;
                incomeInfoObj.sIncSrcStatus = incomeInfoObj.sIncSrcStatus;
                incomeInfoObj.iNoDocs = incomeInfoObj.iNoDocs;
                incomeInfoObj.sNumber = 'Per ' + (idx + 1);; // iNumber starts from 1, 2, 3, 4, etc.
                incomeInfoObj.iIncomeIndex = idx; // id starts from 0, 1, 2, 3 etc.
                this.incomeInfoList.push(incomeInfoObj);
            });
            if (this.incomeInfoList.length === 0) { //Initialise with extra row in the table for no incomeInfolist
                this.handleAdd();
            }
            //End: Populate the Income information table

            //Start: Populate the Reason section
            this.objPEVFields.sCcbContactDesc = data.sCcbContactDesc;
            this.populateCommentsTextArea(data.sCcbContactComment);
            //this.objPEVFields.sCcbContactCode = data.sCcbContactCode;
            //this.objPEVFields.sApplicationStatus = data.sApplicationStatus;
            //End: Populate the Reason section

            //Start: Populate common values
            this.sGeneratedCareAppId = data.sId;
            this.sPEVorHU = data.sPevOrHu;
            if (this.sPEVorHU === 'PEV') {
                this.bPEV = true;
                this.bHU = false;
            }
            else {
                this.bPEV = false;
                this.bHU = true;
            }
            //End: Populate common values

            this.showLoadingSpinner = false;
        }
        else if (data !== undefined && data != null && !data.bIsSuccess) {
            console.log('data.sAppIdToCancel1-->' + data.sAppIdToCancel);
            //Cancel the old application
            if (isNotBlank(data.sAppIdToCancel)) {
                console.log('data.sAppIdToCancel2-->' + data.sAppIdToCancel);
                this.cancelRec(data.sAppIdToCancel, true);
                //Don't refresh
            }

            this.resetForm(); //Reset with blank values, and then update with returned sProcessDate, sReceiveDate, sPevOrHu

            this.objPEVFields.sProcessDate = data.sProcessDate;
            this.objPEVFields.sReceiveDate = data.sReceiveDate;
            //For viewing from History, retrieve Care_Application.On_Probation, else populate from Care_Application.Account.CARE_ON_PROBATION__c (passed from parent lwc)
            //Use the parent lwc sent value Care_Application.Account.CARE_ON_PROBATION__c for 'tab' mode
            if (this.sSelectedAppId === 'tab') {
                this.objPEVFields.bOnProbation = this.bAccOnProbation;
                this.objPEVFields.sApplicantName = this.sSelectedApplicantName;
                this.objPEVFields.sEmail = this.sSelectedAcctEmail;
            }
            this.sPEVorHU = data.sPevOrHu;
            if (this.sPEVorHU === 'PEV') {
                this.bPEV = true;
                this.bHU = false;
            }
            else {
                this.bPEV = false;
                this.bHU = true;
            }
            this.sGeneratedCareAppId = '';
            this.objPEVFields.sApplicationStatus = '';
            this.objPEVFields.sCcbContactDesc = '';
            this.objPEVFields.sCcbContactComment = '';
            this.showLoadingSpinner = false;
        }
        else if (error) {
            this.error = error;
            this.sGeneratedCareAppId = '';
            this.objPEVFields.sApplicationStatus = '';
            this.objPEVFields.sCcbContactDesc = '';
            this.objPEVFields.sCcbContactComment = '';
            this.showLoadingSpinner = false;
            console.log('this.error-->' + this.error)
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
        }
    }

    //Wired method to fetch SA details data
    @wire(getRelatedSA, { sSelectedAppId: '$sGeneratedCareAppId', sLiveCall: '$sLiveCall' })
    wiredRelatedSA(resp) {
        this._wiredRelatedSA = resp;
        const { data, error } = resp;

        if (data) {
            this.careSAData = data.listSA;
            this.adjustReasonList = data.listAdjustReason;
            this.bAdjustmentAtleastOneRowValid = data.bHavingRetroDates;
            console.log(` careSAData: `, this.careSAData);
            this.showLoadingSpinner = false;
        } else if (error) {
            this.error = error;
            this.data = undefined;
            this.showLoadingSpinner = false;
            console.log('this.error-->' + this.error)
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
        }
    }

    //Function called from each of lightning input fields
    handleChange(event) {
        let value;
        if (event.target.type === 'checkbox') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        if (event.target.dataset.id === 'textadultField') {
            this.objPEVFields.iAdultValue = value;
        } else if (event.target.dataset.id === 'textChildField') {
            this.objPEVFields.iChildrenValue = value;
        } else if (event.target.dataset.id === 'textNoIncomeField') {
            this.objPEVFields.iNoWithIncome = value;
        } else if (event.target.dataset.id === 'dateReceiveField') {
            this.objPEVFields.sReceiveDate = value;
        } else if (event.target.dataset.id === 'checkboxIsReqDropField') {
            this.objPEVFields.bRequestedDrop = value;
        } else if (event.target.dataset.id === 'checkboxNoAttachField') {
            this.objPEVFields.bNoAttachment = value;
        } else if (event.target.dataset.id === 'textCocField') {
            this.objPEVFields.sCocCode = value;
        } else if (event.target.dataset.id === 'emailField') {
            this.objPEVFields.sEmail = value;
        } else if (event.target.dataset.id === 'checkboxPEVFormField') {
            this.objPEVFields.bPevForm = value;
        } else if (event.target.dataset.id === 'checkboxIsAdjustField') {
            this.objPEVFields.bIsAdjustment = value;
        } else if (event.target.dataset.id === 'textAdjustField') {
            this.objPEVFields.sAdjustReasonValue = value;
        } else if (event.target.dataset.id === 'textCommentsField') {
            this.objPEVFields.sCcbContactComment = value;
        } else if (event.target.dataset.id === 'textProcessNotesField') {
            this.objPEVFields.sProcessNotes = value;
        }
        //Compute this at runtime, else display from the fetched existing record of getPevHuData
        this.objPEVFields.iTotalPersons = Number(this.objPEVFields.iAdultValue) + Number(this.objPEVFields.iChildrenValue);

        if (this.objPEVFields.bIsAdjustment === true) {
            this.isAdjustmentReasonCheck = false;
            this.isDataTableEditable = true;
        } else {
            this.isAdjustmentReasonCheck = true;
            this.isDataTableEditable = false;
        }
    }

    //Function called from Person Name lightning input fields
    handlePersonChange(event) {
        let index = event.target.dataset.id;
        let selectedValue = event.target.value.trim();
        this.incomeInfoList[index].sPersonName = selectedValue;
    }

    //Function called when Save/Verify/Accept buttons are clicked
    handleSave(event) {
        console.log('handleSave==>' + JSON.stringify(this.objPEVFields));
        console.log('handleSave2==>' + JSON.stringify(this.incomeInfoList));

        let formValidFlag = true;
        let ErrorMsg = '';
        //Set event name
        let nameEvent = event.target.name;

        //#region Validation of form fields
        //fetch the template input fields to check if all input values are valid
        const allInputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                var value = inputCmp.value.trim();
                if ((inputCmp.dataset.id === "textadultField" || inputCmp.dataset.id === "textNoIncomeField" || inputCmp.dataset.id === "dateReceiveField")
                    && (value === '' || value === null || value === undefined)) {
                    inputCmp.setCustomValidity(this.label.CARE_ValidValValidationMsg);
                }
                else if (inputCmp.dataset.id === "textCocField" && isNotBlank(value) && value.length > 4) {
                    inputCmp.setCustomValidity(this.label.CARE_COCLengthValidationMsg);
                }
                else if (inputCmp.dataset.api === "perName" && (value === '' || value === null || value === undefined)) {
                    inputCmp.setCustomValidity(this.label.CARE_PersonNameValidationMsg);
                }
                else {
                    inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const allInputValidTextArea = [...this.template.querySelectorAll('.textCommentsField')]
        //const allInputValidTextArea = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                var value = isNotBlank(inputCmp.value) ? inputCmp.value.trim() : '';
                if (nameEvent === 'accept' && inputCmp.dataset.id === "textCommentsField" && isBlank(value)) {
                    inputCmp.setCustomValidity(this.label.CARE_CommentFieldLengthValidationMsg);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_SelectCommentMsg, 'error');
                }
                else if (inputCmp.dataset.id === "textCommentsField" && isNotBlank(value) && value.length > 256) {
                    inputCmp.setCustomValidity(this.label.CARE_CommentFieldLengthValidationMsg);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldLengthValidationMsg, 'error');
                }
                else if (inputCmp.dataset.id === "textCommentsField" && isNotBlank(value) && value.indexOf(',') !== -1) {
                    inputCmp.setCustomValidity(this.label.CARE_CommentFieldValidationMsg);
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_CommentFieldValidationMsg, 'error');
                }
                else {
                    inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (this.objPEVFields.bIsAdjustment && (this.careSAData === undefined || (this.careSAData !== undefined && this.careSAData.length === 0))) {
            formValidFlag = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NoRecordsDoAdjustment, 'error');
        } else if (this.objPEVFields.bIsAdjustment && !this.bAdjustmentAtleastOneRowValid) {
            formValidFlag = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_NotModifiedRstREndMsg, 'error');
        }
        else if ((nameEvent === 'verify' || nameEvent === 'accept') && (isNotBlank(this.objPEVFields.iNoWithIncome) && this.incomeInfoList !== null && (Number(this.objPEVFields.iNoWithIncome) !== this.incomeInfoList.length))) {
            formValidFlag = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_IncomePeopleMismatch, 'error');
        }
        //#endregion


        if (allInputValid && allInputValidTextArea && formValidFlag) {
            this.showLoadingSpinner = true;

            //#region Set / Modify fields at runtime
            // if (this.maskedPhone !== '' && this.maskedPhone !== undefined && this.maskedPhone !== null) {
            //     this.objPEVFields.sPhone = this.maskedPhone.replace(/\D/g, ''); //remove mask
            // }
            // else {
            //     this.objPEVFields.sPhone = '';
            // }
            //this.objPEVFields.sApplicantName = this.sSelectedApplicantName;
            //#endregion


            //#region Set toast message variants
            if (nameEvent === 'save') {
                this.sEventNameAction = formatString(this.label.CARE_PEVHUSaveMsg, this.sPEVorHU);
                this.sEventVariant = 'info';
            } else if (nameEvent === 'verify') {
                this.sEventNameAction = formatString(this.label.CARE_PEVHUProcessingMsg, this.sPEVorHU);
                this.sEventVariant = 'info';
            } else if (nameEvent === 'accept') {
                this.sEventNameAction = formatString(this.label.CARE_PEVHUAcceptMsg, this.sPEVorHU);
                this.sEventVariant = 'success';
            }
            //#endregion

            submitPEVForm({
                wrapperObj: this.objPEVFields,
                listCareHhWrapper: this.incomeInfoList,
                sPersonId: this.sSelectedPerId,
                listPremId: this.listSelectedPremIds,
                sActionName: nameEvent,
                sCareAppId: this.sGeneratedCareAppId,
                eIAcctId: this.sSelectedAcctId,
                bIsHUForm: this.bHU
            })
                .then(result => {
                    console.log('result ===> ' + JSON.stringify(result));

                    this.showLoadingSpinner = false;

                    this.sGeneratedCareAppId = result.applicationId;
                    this.objPEVFields.sApplicationStatus = result.careApplicationStatus;

                    if (!result.bImageCheck) { //If ImageID is not uploaded
                        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_EnrollmentDocumentValidationMsg, 'error');
                    }
                    else if (!result.bDocCheck) { //If document validation error
                        this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_IncomeDocumentInvalid, 'error');
                        this.sLiveCall = new Date().toLocaleString();
                        return refreshApex(this._wiredPEVData);
                    }
                    else if (nameEvent === 'save') {
                        this.showToastMessage(this.label.CARE_SuccessHeader, this.sEventNameAction, this.sEventVariant);
                        this.incomeInfoList = [];
                        this.sLiveCall = new Date().toLocaleString();
                        return refreshApex(this._wiredPEVData);
                    }
                    else if (nameEvent === 'verify' || nameEvent === 'accept') {
                        if (isBlank(result.ccCode)) {
                            this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_PEVHUVerificationError, 'error');
                        }
                        else {
                            //if (this.objPEVFields.sCcbContactDesc !== result.ccCodeDescription) { // handle result if cc code changed after accept
                            if (nameEvent === 'verify') { // Update Comment only in Case Verify
                                this.objPEVFields.sCcbContactComment = result.careCCLongDescValue;
                                this.populateCommentsTextArea(result.careCCLongDescValue);
                            }
                            this.objPEVFields.sCcbContactDesc = result.ccCodeDescription;
                            this.objPEVFields.sCcbContactCode = result.ccCode;

                            this.showToastMessage(this.label.CARE_SuccessHeader, this.sEventNameAction, this.sEventVariant);
                            this.incomeInfoList = [];
                            this.objPEVFields.sGeneratedCareAppId = result.applicationId;
                            this.sSelectedAppId = result.applicationId;
                            this.sLiveCall = new Date().toLocaleString();
                            return refreshApex(this._wiredPEVData);
                        }
                    }
                })
                .catch(error => {

                    this.error = error.message;
                    console.log('err:' + this.error);

                    this.sGeneratedCareAppId = '';
                    this.objPEVFields.sApplicationStatus = '';
                    this.showLoadingSpinner = false;
                    this.incomeInfoList = [];
                    this.showToastMessage('Error', formatString(this.label.CARE_PEVHUCreateErrorMsg, this.sPEVorHU), 'error');
                });
        }
    }

    //This methods adds an extra row in the table
    handleAdd() {
        this.incomeInfoList.push({
            iIncomeIndex: 0,
            sNumber: 'Per 1',
            sPersonName: '',
            dEstAnnSal: 0,
            sIncSrcStatus: '',
            iNoDocs: 0,
            sId: ''
        });
        this.incomeInfoList.forEach((elem, idx) => {
            elem.iIncomeIndex = idx; // id starts from 0, 1, 2, 3 etc.
            elem.sNumber = 'Per ' + (idx + 1); // iNumber starts from 1, 2, 3, 4, etc.            
        });
    }

    //This methods called when 'Edit Document' icon is clicked against each person
    handleDocumentEntry(event) {
        this.startIdx = Number(event.target.dataset.id);
        let sName = event.target.dataset.name;

        let sId = event.target.dataset.api;
        if (sId !== '' && sId !== undefined) {
            this.rowId = sId;
            this.rowPersonName = sName;
            this.bOpenAsModal = true;
        }
        this.bDocumentEntryModal = true;

    }

    //This method deletes the rows of Household Detail
    handleDelete(event) {
        this.startIdx = Number(event.target.dataset.id);
        let sId = event.target.dataset.api;

        if (sId !== '' && sId !== undefined) {
            this.bShowDeleteModal = true;
            this.rowId = sId;
        }
        else {
            this.incomeInfoList.splice(this.startIdx, 1);
        }
    }

    //Method called from 'Yes' confirmation to delete the Household Detail
    delRec() {
        this.showLoadingSpinner = true;
        this.closeDeleteModal();
        console.log('this.rowId==>' + this.rowId)

        deleteCareHouseholdDet({ sId: this.rowId })
            .then(result => {
                if(result){
                    this.incomeInfoList.splice(this.startIdx, 1);
                    this.showToastMessage('Delete Success', this.label.CARE_IncomeInfoDeleteMsg, 'success');
    
                    this.sLiveCall = new Date().toLocaleString();
                    return refreshApex(this._wiredPEVData);
                }
                else{
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                }                
            })
            .catch(error => {
                console.log('error-->' + error.body.message);
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
            });
        this.showLoadingSpinner = false;
    }

    //This method closes the confirmation popup for Delete
    closeDeleteModal() {
        this.bShowDeleteModal = false;
    }

    //Mthod called when SA datatable is edited and Save button is clicked
    handleDataTableSave(event) {
        let today = new Date();
        let dateToday = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);

        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            console.log(` field draft values: `, fields);
            return { fields };
        });
        console.log(` field draft values recordInputs: `, recordInputs);
        let retroDateValues = [];
        let ret = -1;
        if (recordInputs) {
            this.bRecordInputsCheck = true;
            recordInputs.forEach((element, index) => {
                let retroDates = { ...element };
                let careSADataIndex = this.careSAData.findIndex(x => x.Id === retroDates.fields.Id);

                if (isNotBlank(retroDates.fields.dRStartDate) && isBlank(retroDates.fields.dREndDate) && isBlank(this.careSAData[careSADataIndex].dREndDate)) {
                    this.bRecordInputsCheck = false;
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_StartDateValidationMsg, 'error');
                }
                else if (isNotBlank(retroDates.fields.dRStartDate) && retroDates.fields.dRStartDate >= dateToday) {
                    this.bRecordInputsCheck = false;
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroStartDateValidationMsg, 'error');
                }
                else if (isNotBlank(retroDates.fields.dRStartDate) && isNotBlank(retroDates.fields.dREndDate) && (retroDates.fields.dREndDate <= retroDates.fields.dRStartDate || retroDates.fields.dREndDate > this.careSAData[careSADataIndex].dYesDate)) {
                    this.bRecordInputsCheck = false;
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroDateValidationMsg, 'error');
                }
                else if (isBlank(retroDates.fields.dRStartDate) && isNotBlank(retroDates.fields.dREndDate) && (retroDates.fields.dREndDate > this.careSAData[careSADataIndex].dYesDate || retroDates.fields.dREndDate <= this.careSAData[careSADataIndex].dRStartDate)) {
                    this.bRecordInputsCheck = false;
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroDateValidationMsg, 'error');
                }
                else if (isNotBlank(retroDates.fields.dRStartDate) && isBlank(retroDates.fields.dREndDate) && isNotBlank(this.careSAData[careSADataIndex].dREndDate) && (retroDates.fields.dRStartDate >= this.careSAData[careSADataIndex].dREndDate)) {
                    this.bRecordInputsCheck = false;
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_RetroDateValidationMsg, 'error');
                }
            });
        }

        if (this.bRecordInputsCheck) {
            for (let i = 0; i < recordInputs.length; i++) {
                if (recordInputs[i].fields.hasOwnProperty('dRStartDate') && recordInputs[i].fields.hasOwnProperty('dREndDate')) {
                    retroDateValues.push({ 'fields': { 'RETRO_START_DATE__c': recordInputs[i].fields.dRStartDate, 'RETRO_END_DATE__c': recordInputs[i].fields.dREndDate, 'Id': recordInputs[i].fields.Id } })
                } else if (recordInputs[i].fields.hasOwnProperty('dRStartDate')) {
                    retroDateValues.push({ 'fields': { 'RETRO_START_DATE__c': recordInputs[i].fields.dRStartDate, 'Id': recordInputs[i].fields.Id } })

                } else {
                    retroDateValues.push({ 'fields': { 'RETRO_END_DATE__c': recordInputs[i].fields.dREndDate, 'Id': recordInputs[i].fields.Id } })
                }
            }
            console.log(` field draft values retroDateValues: `, retroDateValues);
            const promises = retroDateValues.map(recordInput => updateRecord(recordInput));
            Promise.all(promises).then(result => {
                // Clear all draft values
                this.draftValues = [];
                return refreshApex(this._wiredRelatedSA);
            }).catch(error => {
                // Handle error
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_EnrollmentEditErrorMsg, 'error');
            });
        }
    }

    //Call method to cancel and show confirmation message
    handleCancel() {
        this.bShowConfirmationModal = true;
    }

    //close confirmation modal Popup
    closeConfirmationModal(event) {
        this.bShowConfirmationModal = false;
    }

    //confirmed to cancel the application in between
    cancelApplication(event) {
        this.closeConfirmationModal();
        this.showLoadingSpinner = true;

        this.cancelRec(this.sGeneratedCareAppId, false);
    }

    //Method called to cancel the Care Application record
    cancelRec(sAppId, isOldForm) {
        setCancelStatusCareApplication({ sSelectedAppId: sAppId })
            .then(result => {
                console.log('result setCancelStatusCareApplication call==>' + JSON.stringify(result));
                this.showLoadingSpinner = false;
                if (result) {
                    if (!isOldForm) {
                        this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_TransactionSuccessMsg, 'success');
                        //Refresh
                        this.objPEVFields.sApplicationStatus = "Cancelled";
                        this.sSelectedAppId = this.sGeneratedCareAppId;
                        this.sLiveCall = new Date().toLocaleString();
                        return refreshApex(this._wiredPEVData);
                    }
                } else {
                    this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
                }
            })
            .catch((error) => {
                this.showLoadingSpinner = false;
                console.log('err-->'+ error);
                this.showToastMessage(this.label.CARE_ErrorHeader, this.label.CARE_TransactionErrorMsg, 'error');
            });
    }
    
    //Resets the form with objPEVFields values and income information
    resetForm() {
        this.objPEVFields = {
            sApplicantName: '',
            iAdultValue: 1,
            iChildrenValue: 0,
            iNoWithIncome: 1,
            sProcessDate: new Date(),
            sReceiveDate: new Date(),
            bRequestedDrop: false,
            bNoAttachment: false,
            sSourceChannelType: '',
            sFormCode: '',
            sCocCode: '',
            sEmail: '',
            iAnnualInc: 0,
            iTotalPersons: 1,
            bOnProbation: false,
            bPevForm: true,
            sApplicationStatus: '',
            bIsAdjustment: false,
            sAdjustReasonValue: '',
            sCcbContactCode: '',
            sCcbContactDesc: '',
            sCcbContactComment: '',
            sProcessNotes: '',
            sLastModifiedById: '',
            sLastModifiedDate: '',
            sQualifiedBy: '',
            sEIAccountName: '',
            sEIAccountId: '',
            bIsSuccess: false
        };
        this.populateCommentsTextArea('');
        this.incomeInfoList = [{
            iIncomeIndex: 0,
            sNumber: 'Per 1',
            sPersonName: '',
            dEstAnnSal: 0,
            sIncSrcStatus: '',
            iNoDocs: 0,
            sId: ''
        }];
    }

    //This method is called from child lwc 'Document entry' for refreshing the parent with an event
    pevHuFormRefresh(event) {
        //Close child modal
        this.bOpenAsModal = false;
        this.bDocumentEntryModal = false;

        //Update the application Id to refresh the
        this.sGeneratedCareAppId = event.detail; //receives the care application Id from child
        this.sLiveCall = new Date().toLocaleString();
    }

    populateCommentsTextArea(inputVal){
        this.template.querySelectorAll('.textCommentsField').forEach(elem => {
            elem.value = inputVal;
        });

    }
}