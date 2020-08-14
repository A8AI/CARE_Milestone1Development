//#region Import
import { LightningElement, track, api } from 'lwc';
import createTransactionForSendApp from '@salesforce/apex/CARE_SendAppController.createTransactionForSendApp';
import getSendAppDetails from '@salesforce/apex/CARE_SendAppController.getSendAppDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { formatString } from 'c/care_Utilities';
//#endregion

//Labels
import CARE_SendAppSuccessMsg from '@salesforce/label/c.CARE_SendAppSuccessMsg';
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader'
import CARE_SendAppConfirmationMsg from '@salesforce/label/c.CARE_SendAppConfirmationMsg';
import CARE_SendAppHeader from '@salesforce/label/c.CARE_SendAppHeader';

export default class Care_SendApp extends LightningElement {
//#region Variables
    @api sPersonId;// = '9999999999';
    @api sAccountId; // = '';
    @api sApplicantName;//='Sha';
    @api sBillingAccountId; //='46456456';
    @track bShowConfirmationModal = false;
    @track bShowLoadingSpinner = false;
    @track objInputParam = {
        sPerId: '',
        sAccId: '',
        sBillingAccId: '',
        sApplicantName: ''  
    }
//#endregion

label = {
    CARE_SendAppSuccessMsg,
    CARE_ErrorHeader,
    CARE_SuccessHeader,
    CARE_SendAppConfirmationMsg,
    CARE_SendAppHeader
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

    

    // to close modal window set 'bShowModal' tarck value as false
    closeConfirmationModal() {
        this.bShowLoadingSpinner = false;
        this.bShowConfirmationModal = false;
    }

    handleSendApp() {
            
        
        getSendAppDetails({ sPersonId: this.sPersonId })
        .then(result => {
            if (result.bSuccess) {
                //this.objInputParam.sContactCode = result.sContactCode;
                this.label.CARE_SendAppHeader = formatString(this.label.CARE_SendAppHeader, result.sContactCode);
                this.bShowConfirmationModal = true;
            }
            else {
                this.bShowConfirmationModal = false;
                this.showToastMessage(this.label.CARE_ErrorHeader, result.sErrorMessage, 'error');
            }
        })
        .catch(error => {
            this.bShowConfirmationModal = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
        });
    }

    sendApp(){
        const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
            detail: 'History'   //To refresh History Tab
        });
        this.bShowLoadingSpinner = true;
        if(this.sPersonId === '' || this.sPersonId === null || this.sPersonId === undefined){
            this.showToastMessage('Invalid Person Id', 'Person Id is either blank or null.', 'error');
        }
        if(this.sAccountId === '' || this.sAccountId === null || this.sAccountId === undefined){
            this.showToastMessage('Invalid Account Id', 'Account Id is either blank or null.', 'error');
        }
        if(this.sBillingAccountId === '' || this.sBillingAccountId === null || this.sBillingAccountId === undefined){
            this.showToastMessage('Invalid Billing Account Id', 'Billing Account Id is either blank or null.', 'error');
        }
        if(this.sApplicantName === '' || this.sApplicantName === null || this.sApplicantName === undefined){
            this.showToastMessage('Invalid Applicant Name', 'Applicant Name is either blank or null.', 'error');
        }
        this.objInputParam.sPerId = this.sPersonId;
        this.objInputParam.sAccId = this.sAccountId;
        this.objInputParam.sBillingAccId = this.sBillingAccountId;
        this.objInputParam.sApplicantName = this.sApplicantName;
        createTransactionForSendApp({ objSendApp: this.objInputParam })
        .then(result => {
            if (result.bSuccess) {
                this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_SendAppSuccessMsg, 'success');
                this.dispatchEvent(historyTabRefreshEvent);
            }
            else {
                this.showToastMessage(this.label.CARE_ErrorHeader, result.sErrorMessage, 'error');
            }
            this.closeConfirmationModal();
        })
        .catch(error => {
            this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
            this.closeConfirmationModal();
        });
    }
}