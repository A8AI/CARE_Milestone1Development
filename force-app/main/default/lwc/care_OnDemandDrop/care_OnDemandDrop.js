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
import NotEligibleMsg from '@salesforce/label/c.CARE_NotEligibleMsg';
import DropValidationMsg from '@salesforce/label/c.CARE_DropValidationMsg';
import DropInvalidCaseIDMsg from '@salesforce/label/c.CARE_DropInvalidCaseIDMsg';
import DropEmailSourceValidationMsg from '@salesforce/label/c.CARE_DropEmailSourceValidationMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
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
        TransactionErrorMsg
        //OnDemandDropHeader
    };

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

    @wire(getReceivedDateSession)
    receiveDateValue({error, data}){
        if (data) {
            this.OnDemandDropObj.receiveDateValue = data;
            this.OnDemandDropObj.dropDateValue = data;
        }else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    openOnDemandModal() {
        this.showLoadingSpinner = true;
        console.log(` Person Id from parent `, this.sSelectedPerId);
        console.log(` Premise ID from parent `, this.listSelectedPremIds);
        console.log(` modal flag from parent `, this.bModalFlag);

        getPerIdValue({perIdValue : this.sSelectedPerId}).then(result =>{

            console.log(` result: ` + result);
            this.oldCareApplicationId = result.oldAppIdForCare;
            this.newCareApplicationId = result.NewAppIdForCare;
            this.OnDemandDropObj.dropReasonValue = result.descLongValue;
            this.OnDemandDropObj.sContactCCCode = result.sContactCode;

            console.log(` old care AppId----->: ` ,this.oldCareApplicationId);
            console.log(` new care AppId----->: ` ,this.newCareApplicationId);
            //if(result != '' || result != null){
                if(this.oldCareApplicationId != '' && this.oldCareApplicationId != null){
                this.isModalOpen = true;
                this.showLoadingSpinner = false; 
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    //message: 'Customer is Not enrolled in CARE/FERA!!',
                    message:this.label.NotEligibleMsg,
                    variant: 'error'
                }),); 
            }
            
        }).catch(error =>{
            this.error = error.message;
            console.error('error in getting the list', error.body.message);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                //message: 'Application Error!!. Please try after some time',
                message:this.label.TransactionErrorMsg,
                variant: 'error'
            }),);
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
            this.emailDropValue = this.OnDemandDropObj.dropSourceValue;
        }else if(this.caseIDLength === 15 || this.caseIDLength === 18){
            this.bCaseIdIncorrect = true;
        }else{
            this.bCaseIdIncorrect = false;
            this.disableImageButton = '';
        }
        
        this.bFormEdited = true;
        
    }

    submitDetails(event) {
        let nameEvent;
    if(event.target.name === 'confirm'){
        nameEvent = event.target.name;
    }
    console.log('event name is---->', nameEvent);

        if(this.OnDemandDropObj.dropSourceValue === '' || this.OnDemandDropObj.dropSourceValue === undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    //message: 'Drop Source is required in order to drop a customer!!',
                    message:this.label.DropValidationMsg,
                    variant: 'error',
                }),
            );
        
        }else if((this.OnDemandDropObj.dropSourceValue === 'CC&B Case' || this.OnDemandDropObj.dropSourceValue === 'SF Case') && (this.OnDemandDropObj.caseIDValue === '' || this.OnDemandDropObj.caseIDValue === undefined)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    //message:'Case ID is Required when Drop Source is SF Case or CC&B Case!!',
                    message:this.label.DropCaseourceValidationMsg,
                    variant: 'error',
                }),
            );
        }else if((this.OnDemandDropObj.dropSourceValue === 'CC&B Case' || this.OnDemandDropObj.dropSourceValue === 'SF Case') && this.OnDemandDropObj.caseIDValue != '' && this.bCaseIdIncorrect === false){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    //message: 'Case ID must be 15 or 18 character Salesforce ID if entered!!',
                    message:this.label.DropInvalidCaseIDMsg,
                    variant: 'error',
                }),
            );
        }else {
    console.log(` Customer values inside button click method `, this.OnDemandDropObj);
    this.showLoadingSpinner = true;
    getOnDemandDropInfoList({onDemandDropData : this.OnDemandDropObj, oldAppIdCare : this.oldCareApplicationId, perID: this.sSelectedPerId, newAppIdCare : this.newCareApplicationId, nameOfEvent : nameEvent}).then(result => {

        console.log('result ===> '+result);
        console.log('result Stringify===> '+JSON.stringify(result));
        //this.appEnrolledSA = result.careAppEnrolledID;
        //this.inCorrectCaseIdValue = result.inCorrectCaseId;
        //this.bCheckImageId = result.bImageCheck;
        //this.dropSourceName = result.dropSourceName;
        console.log(` App Enrolled SA ID`+ result.careAppEnrolledID);
        console.log(` In correct CASE ID `+ result.inCorrectCaseId);
        console.log(` drop source name `+ result.dropSourceName);
        console.log(` Image check value `+ result.bImageCheck);
        // Show success messsage
        if(result.careAppEnrolledID != '' && result.dropSourceName != ''){// || this.dropSourceName === 'Emailed' || this.dropSourceName === 'Called - In'){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                //message: 'Drop transaction successful. Click on History tab to view transaction details!!',
                message:this.label.TransactionSuccessMsg,
                variant: 'success' 
        }),)
        this.showLoadingSpinner = false;
        //this.OnDemandDropObj = {};
        this.OnDemandDropObj.dropSourceValue = '';
        this.oldCareApplicationId = '';
        this.caseIDLength = null;
        this.perIdValue = '';
        this.isModalOpen = false;
    }else if(result.careAppEnrolledID === '' && result.inCorrectCaseId === '' && result.bImageCheck === true){
        
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                //message: 'Case ID provided is incorrect. Please enter correct Case ID!!',
                message:this.label.DropInvalidCaseIDMsg,
                variant: 'error',          
        }),)
        this.showLoadingSpinner = false;
        this.isModalOpen = true;
    }else if(result.careAppEnrolledID === '' && result.inCorrectCaseId === '' && result.bImageCheck === false){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            //message: 'Please upload atleast one document or Image ID when Drop Source is Emailed!!',
            message:this.label.DropEmailSourceValidationMsg,
            variant: 'error',          
    }),)
    this.showLoadingSpinner = false;
    this.isModalOpen = true;
    }
    })

    .catch(error => {
        this.error = error.message;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            //message: 'Application Error!!. Please try after some time',
            message:this.label.TransactionErrorMsg,
            variant: 'error'
        }),);
        this.showLoadingSpinner = false;
        //this.caseIDLength = null;
        this.isModalOpen = true;
    });
        
        //this.isModalOpen = false;
        }
    }

    get checkAppId() {
        return this.disableImageButton.length > 0;
    }
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
        this.oldCareApplicationId = '';
        this.caseIDLength = null;
        this.perIdValue = '';
        this.isModalOpen = false;
    }
}
}