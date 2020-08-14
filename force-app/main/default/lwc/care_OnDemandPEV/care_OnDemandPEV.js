import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomerDetails from '@salesforce/apex/CARE_OnDemandPEVController.getCustomerDetails';
import createTransactionForOnDemandPEV from '@salesforce/apex/CARE_OnDemandPEVController.createTransactionForOnDemandPEV';

//labels
import CARE_ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import CARE_SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader'
import CARE_AccountPersonIdValidationMsg from '@salesforce/label/c.CARE_AccountPersonIdValidationMsg'
import CARE_PEVSuccessMsg from '@salesforce/label/c.CARE_PEVSuccessMsg'



export default class Care_OnDemandPEV extends LightningElement {

    @api sPersonId;// = '9999999999';
    @api sAccountId;// '';
    @api sApplicantName;//='Anupam';
    @api sBillingAccountId;

    @track bShowConfirmationModal = false;
    @track bShowLoadingSpinner = false;
    @track objInputParam = {
        sPerId: '',
        sAccId: '',
        sBillingAccId: '',
        sApplicantName: ''  
    };

    label = {
        CARE_ErrorHeader,
        CARE_SuccessHeader,
        CARE_AccountPersonIdValidationMsg,
        CARE_PEVSuccessMsg
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

    handleOnDemandPEV(){
        this.bShowLoadingSpinner = true;
        if(this.sPersonId === '' || this.sPersonId === null || this.sPersonId === undefined){
            this.showToastMessage('Error!!', this.label.CARE_AccountPersonIdValidationMsg, 'error');
        }

        getCustomerDetails({sPersonId : this.sPersonId})
        .then(result => {
            if (result.bSuccess) {
                //this.objInputParam.sContactCode = result.sContactCode;
                //this.label.CARE_SendAppHeader = formatString(this.label.CARE_SendAppHeader, result.sContactCode);
                this.bShowConfirmationModal = true;
                this.bShowLoadingSpinner = false;
            }
            else {
                this.bShowConfirmationModal = false;
                this.showToastMessage(this.label.CARE_ErrorHeader, result.sErrorCode, 'error');
            }
        })
        .catch(error => {
            this.bShowConfirmationModal = false;
            this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
        });
    }

    onDemandPEV(){
        const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
            detail: 'History'   //To refresh History Tab
        });  

        if(this.sAccountId === '' || this.sAccountId === null || this.sAccountId === undefined){
            this.showToastMessage('Error!!', this.label.CARE_AccountPersonIdValidationMsg, 'error');
        }
        if(this.sBillingAccountId === '' || this.sBillingAccountId === null || this.sBillingAccountId === undefined){
            this.showToastMessage('Error!!', 'Billing Account Id is either blank or null.', 'error');
        }
        if(this.sApplicantName === '' || this.sApplicantName === null || this.sApplicantName === undefined){
            this.showToastMessage('Error!!', 'Applicant Name is either blank or null.', 'error');
        }

        this.objInputParam.sPerId = this.sPersonId;
        this.objInputParam.sAccId = this.sAccountId;
        this.objInputParam.sBillingAccId = this.sBillingAccountId;
        this.objInputParam.sApplicantName = this.sApplicantName;

        createTransactionForOnDemandPEV({objOnDemandPEV: this.objInputParam})
        .then(result => {
            if (result.bSuccess) {
                this.showToastMessage(this.label.CARE_SuccessHeader, this.label.CARE_PEVSuccessMsg, 'success');
                this.dispatchEvent(historyTabRefreshEvent);
            }
            else {
                this.showToastMessage(this.label.CARE_ErrorHeader, result.sErrorMessage, 'error');
            }
            this.closeConfirmationModal();
        })
        .catch(error => {
            this.showToastMessage(this.label.CARE_ErrorHeader, error.message, 'error');
        });
    }
    
}