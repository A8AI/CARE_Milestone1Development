import { LightningElement,track,api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getPerIdValue from '@salesforce/apex/CARE_OnDemandDropController.getPerIdValue';
import getReceivedDateSession from '@salesforce/apex/CARE_UtilityController.getReceivedDateSession';
import deleteCareAppRecord from '@salesforce/apex/CARE_OnDemandDropController.deleteCareAppRecord';
import getOnDemandDropInfoList from '@salesforce/apex/CARE_OnDemandDropController.getOnDemandDropInfoList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DROP_SOURCE_TYPE from '@salesforce/schema/CARE_Application__c.DROP_SOURCE__c';
//import custom labels
import DropCaseourceValidationMsg from '@salesforce/label/c.CARE_DropCaseourceValidationMsg';
import TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import NotEligibleMsg from '@salesforce/label/c.CARE_NotEligiblePersonMsg';
import DropValidationMsg from '@salesforce/label/c.CARE_DropValidationMsg';
import DropInvalidCaseIDMsg from '@salesforce/label/c.CARE_DropInvalidCaseIDMsg';
import DropEmailSourceValidationMsg from '@salesforce/label/c.CARE_DropEmailSourceValidationMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import CommentFieldLengthValidationMsg from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import DropReasonMsg from '@salesforce/label/c.CARE_DropReasonMsg';
import ReceiveDateMsg from '@salesforce/label/c.CARE_ReceiveDateMsg';


//import OnDemandDropHeader from '@salesforce/label/c.CARE_OnDemandDropHeader';



export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track bShowConfirmationModal = false;
    @track bFormEdited = false;
    @track lenMapOfSAValues = 0;
    @track sourceOptions;
    @track caseIDLength = 0;
    @track bCaseField = false;
    @track disableImageButton = '';
    @track bOtherOptions = false;
    @track appEnrolledSA = '';
    @track inCorrectCaseIdValue = '';
    @track nameEvent;
    @api sSelectedPerId;
    @api listSelectedPremIds;
    @api bModalFlag;
    @track oldCareApplicationId = '';
    @track newCareApplicationId = '';
    @track showLoadingSpinner = false;
    @track bCaseIdIncorrect = false;
    @track emailDropValue = '';
    @track bCheckImageId = true;
    @track dropSourceName = '';
    @track OnDemandDropObj = {
            dropReasonValue: '',
            dropSourceValue: '',
            caseIDValue: '',
            dropDateValue: '',
            receiveDateValue: '',
            sContactCCCode: ''
    };

    label = {
        DropCaseourceValidationMsg,
        TransactionSuccessMsg,
        NotEligibleMsg,
        DropValidationMsg,
        DropInvalidCaseIDMsg,
        DropEmailSourceValidationMsg,
        TransactionErrorMsg,
        CommentFieldLengthValidationMsg,
        CommentFieldValidationMsg,
        ErrorHeader,
        SuccessHeader,
        DropReasonMsg,
        ReceiveDateMsg
        //OnDemandDropHeader
    };

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

    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : DROP_SOURCE_TYPE
    })
    wiredPickListValue({ data, error }){
        if(data){
            this.sourceOptions = data.values;
            this.error = undefined;
        }
        if(error){
            this.error = error;
            this.channelOptions = undefined;
        }
    }

 /*   @wire(getReceivedDateSession)
    receiveDateValue({error, data}){
        if (data) {
            this.OnDemandDropObj.receiveDateValue = data;
            this.OnDemandDropObj.dropDateValue = data;
        }else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
*/
    openOnDemandModal() {
        this.showLoadingSpinner = true;
        console.log(` Person Id from parent `, this.sSelectedPerId);
        console.log(` Premise ID from parent `, this.listSelectedPremIds);
        console.log(` modal flag from parent `, this.bModalFlag);

        getPerIdValue({perIdValue : this.sSelectedPerId}).then(result =>{

            console.log(` result: ` , result);
            this.oldCareApplicationId = result.oldAppIdForCare;
            this.newCareApplicationId = result.NewAppIdForCare;
            this.OnDemandDropObj.dropReasonValue = result.descLongValue;
            this.OnDemandDropObj.sContactCCCode = result.sContactCode;
            this.OnDemandDropObj.receiveDateValue = result.dReceiveDate;
            this.OnDemandDropObj.dropDateValue = result.dDropDate;

            console.log(` old care AppId----->: ` ,this.oldCareApplicationId);
            console.log(` new care AppId----->: ` ,this.newCareApplicationId);
            //if(result != '' || result != null){
                if(this.oldCareApplicationId != '' && this.oldCareApplicationId != null){
                this.isModalOpen = true;
                this.showLoadingSpinner = false; 
            }else{
                this.showToastMessage(this.label.ErrorHeader, this.label.NotEligibleMsg, 'error');
            }
            
        }).catch(error =>{
            this.error = error.message;
            //console.error('error in getting the list', error.body.message);
            this.showToastMessage(this.label.ErrorHeader, this.label.NotEligibleMsg, 'error');
            /*this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                //message: 'Application Error!!. Please try after some time',
                message:this.label.TransactionErrorMsg,
                variant: 'error'
            }),);*/
            //this.showLoadingSpinner = false;
            
        });

    }

    handleChange(event){
        let value;
        if(event.target.type === 'checkbox'){
            value = event.target.checked;
           
        }else{
            value = event.target.value;
            
        }
        if(event.target.dataset.id === 'dropReasonField'){
            this.OnDemandDropObj.dropReasonValue = value;
            //this.dropReasonValueLength = this.OnDemandDropObj.dropReasonValue.length;

        }else if(event.target.dataset.id === 'dropSourceField'){
            this.OnDemandDropObj.dropSourceValue = value;
                 
        }else if(event.target.dataset.id === 'caseIDField'){
            this.OnDemandDropObj.caseIDValue = value;
            this.caseIDLength = this.OnDemandDropObj.caseIDValue.length;
        console.log(` length of case ID entered `, this.caseIDLength);      
        }else if(event.target.dataset.id === 'dropDateField'){
            this.OnDemandDropObj.dropDateValue = value;
                  
        }else if(event.target.dataset.id === 'receivedDateField'){
            this.OnDemandDropObj.receiveDateValue = value;
        }

        if(this.OnDemandDropObj.dropSourceValue === 'Emailed' ) {
            this.disableImageButton = this.OnDemandDropObj.dropSourceValue;
        }else{
            this.disableImageButton = '';
        }
        if(this.caseIDLength === 15 || this.caseIDLength === 18){
            this.bCaseIdIncorrect = true;
        }else{
            this.bCaseIdIncorrect = false;            
        }
        
        this.bFormEdited = true;
        
    }

    submitDetails(event) {
               //let nameEvent;
        let bReasonCheck = true;
    if(event.target.name === 'confirm'){
        this.nameEvent = event.target.name;
    }
    console.log('event name is---->', this.nameEvent);

        //Validations
        if(this.OnDemandDropObj.dropSourceValue === '' || this.OnDemandDropObj.dropSourceValue === undefined){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.DropValidationMsg, 'error');

        }
        else if(this.OnDemandDropObj.dropReasonValue === '' || this.OnDemandDropObj.dropReasonValue === undefined){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.DropReasonMsg, 'error');
            
        }
        else if((this.OnDemandDropObj.dropSourceValue === 'CC&B Case' || this.OnDemandDropObj.dropSourceValue === 'SF Case') && (this.OnDemandDropObj.caseIDValue === '' || this.OnDemandDropObj.caseIDValue === undefined)){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.DropCaseourceValidationMsg, 'error');
            
        }
        else if((this.OnDemandDropObj.dropSourceValue === 'CC&B Case' || this.OnDemandDropObj.dropSourceValue === 'SF Case') && this.OnDemandDropObj.caseIDValue !== '' && this.bCaseIdIncorrect === false){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.DropInvalidCaseIDMsg, 'error');
            
        }
        else if(this.OnDemandDropObj.receiveDateValue === '' || this.OnDemandDropObj.receiveDateValue === undefined || this.OnDemandDropObj.receiveDateValue === null){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.ReceiveDateMsg, 'error');
        }
        else if(this.OnDemandDropObj.dropReasonValue.length > 256){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.CommentFieldLengthValidationMsg, 'error');
            
        }
        else if(this.OnDemandDropObj.dropReasonValue.indexOf(',') !== -1){
            bReasonCheck = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.CommentFieldValidationMsg, 'error');     
        }
        
        if(bReasonCheck){
            this.doOnDemandDrop();
        }
    }

    doOnDemandDrop() {  
        const historyTabRefreshEvent = new CustomEvent("historytabrefreshfromchild", {
            detail: 'History'   //To refresh History Tab
        });                 
    console.log(` Customer values inside button click method `, this.OnDemandDropObj);
    this.showLoadingSpinner = true;
    getOnDemandDropInfoList({onDemandDropData : this.OnDemandDropObj, oldAppIdCare : this.oldCareApplicationId, perID: this.sSelectedPerId, newAppIdCare : this.newCareApplicationId, nameOfEvent : this.nameEvent}).then(result => {

        console.log('result ===> '+result);
        console.log('result Stringify===> '+JSON.stringify(result));
        //this.appEnrolledSA = result.careAppEnrolledID;
        //this.inCorrectCaseIdValue = result.inCorrectCaseId;
        //this.bCheckImageId = result.bImageCheck;
        //this.dropSourceName = result.dropSourceName;
        //console.log(` App Enrolled SA ID`+ result.careAppEnrolledID);
        //console.log(` In correct CASE ID `+ result.inCorrectCaseId);
        //console.log(` drop source name `+ result.dropSourceName);
        //console.log(` Image check value `+ result.bImageCheck);
        // Show success messsage
        if(result.careAppEnrolledID != '' && result.dropSourceName != ''){// || this.dropSourceName === 'Emailed' || this.dropSourceName === 'Called - In'){
        this.showToastMessage(this.label.SuccessHeader, this.label.TransactionSuccessMsg, 'success');    
    
        this.dispatchEvent(historyTabRefreshEvent);
        this.showLoadingSpinner = false;
        //this.OnDemandDropObj = {};
        this.OnDemandDropObj.dropSourceValue = '';
        this.OnDemandDropObj.caseIDValue = '';
        this.OnDemandDropObj.sContactCCCode = '';
        this.OnDemandDropObj.dropSourceValue = '';
        this.oldCareApplicationId = '';
        this.caseIDLength = null;
        this.perIdValue = '';
        this.isModalOpen = false;
    }
    else if(result.careAppEnrolledID === '' && result.inCorrectCaseId === '' && result.bImageCheck === true){
        this.showToastMessage(this.label.ErrorHeader, this.label.DropInvalidCaseIDMsg, 'error');
        this.showLoadingSpinner = false;
        this.isModalOpen = true;
    }
    else if(result.careAppEnrolledID === '' && result.inCorrectCaseId === '' && result.bImageCheck === false){
        this.showToastMessage(this.label.ErrorHeader, this.label.DropEmailSourceValidationMsg, 'error');

    this.showLoadingSpinner = false;
    this.isModalOpen = true;
    }
    })

    .catch(error => {
        this.error = error.message;
        this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
        this.showLoadingSpinner = false;
        //this.caseIDLength = null;
        this.isModalOpen = true;
    });
        
    }
    

    /*get checkAppId() {
        return this.disableImageButton.length > 0;
    }*/
    closeConfirmationModal(event) {
        //this.bShowConfirmationModal = false;
        this.bShowConfirmationModal = event.detail.showChildModal; //read from child lwc and assign here
    }

    //confirmed to close the transaction in between
    cancelTransaction(event) {
        deleteCareAppRecord({ newCareIdToDelete : this.newCareApplicationId });
            this.isModalOpen = event.detail.showParentModal;
            this.bShowConfirmationModal = event.detail.showChildModal;
            this.bFormEdited = false; 
    }

    closeModal() {

        if (this.bFormEdited) {
            this.bShowConfirmationModal = true;
        }else{
        deleteCareAppRecord({ newCareIdToDelete : this.newCareApplicationId });
        this.OnDemandDropObj.dropSourceValue = '';
        this.OnDemandDropObj.caseIDValue = '';
        this.OnDemandDropObj.sContactCCCode = '';
        this.OnDemandDropObj.dropSourceValue = '';
        this.oldCareApplicationId = '';
        this.caseIDLength = null;
        this.perIdValue = '';
        this.isModalOpen = false;

    }
}
}