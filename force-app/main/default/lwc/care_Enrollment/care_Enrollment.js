import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import determineisNewEnrollment from '@salesforce/apex/CARE_EnrollTabController.determineisNewEnrollment';
import getRelatedSA from '@salesforce/apex/CARE_EnrollTabController.getRelatedSA';
//import getCustomerInfoWrapper from '@salesforce/apex/CARE_EnrollTabController.CustomerInfoWrapper';
import handleButtonClickOnUI from '@salesforce/apex/CARE_EnrollTabController.handleButtonClickOnUI';
//import handleAcceptButtonClickOnUI from '@salesforce/apex/CARE_EnrollTabController.handleAcceptButtonClickOnUI';
import sendReceivedDate from '@salesforce/apex/CARE_EnrollTabController.sendReceivedDate';
import prePopulatEnrollData from '@salesforce/apex/CARE_EnrollTabController.prePopulatEnrollData';
import setCancelStatusCareApplication from '@salesforce/apex/CARE_UtilityController.setCancelStatusCareApplication';
import getSystemInfoCareAppData from '@salesforce/apex/CARE_UtilityController.getSystemInfoCareAppData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { isBlank, isNotBlank } from 'c/care_Utilities';
import SOURCE_CHANNEL_TYPE from '@salesforce/schema/CARE_Application__c.SOURCE_CHANNEL_TYPE__c';

//Labels
import EnrollmentCreateErrorMsg from '@salesforce/label/c.CARE_EnrollmentCreateErrorMsg';
import EnrollmentDocumentValidationMsg from '@salesforce/label/c.CARE_EnrollmentDocumentValidationMsg';
import EnrollmentEditErrorMsg from '@salesforce/label/c.CARE_EnrollmentEditErrorMsg';
import RetroDateValidationMsg from '@salesforce/label/c.CARE_RetroDateValidationMsg';
import ApplicantNameMsg from '@salesforce/label/c.CARE_ApplicantNameMsg';
import EmailIdValidation from '@salesforce/label/c.CARE_EmailIdValidation';
import CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import EnrollmentSaveMsg from '@salesforce/label/c.CARE_EnrollmentSaveMsg';
import EnrollmentProcessingMsg from '@salesforce/label/c.CARE_EnrollmentProcessingMsg';
import EnrollAcceptMsg from '@salesforce/label/c.CARE_EnrollAcceptMsg';
import BothRetroDateValidationMsg from '@salesforce/label/c.CARE_BothRetroDateValidationMsg';
import CommentFieldLengthValidationMsg from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import StartDateValidationMsg from '@salesforce/label/c.CARE_StartDateValidationMsg';
import AdultFieldValidationMsg from '@salesforce/label/c.CARE_AdultFieldValidationMsg';
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import SuccessHeader from '@salesforce/label/c.CARE_SuccessHeader';
import RetroStartDateValidationMsg from '@salesforce/label/c.CARE_RetroStartDateValidationMsg';
import ConfirmationMsg from '@salesforce/label/c.CARE_ConfirmationMsg';
import CancelHeader from '@salesforce/label/c.CARE_CancelHeader';
import TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import ReceiveDateMsg from '@salesforce/label/c.CARE_ReceiveDateMsg';
import CARE_NotModifiedRstREndMsg from '@salesforce/label/c.CARE_NotModifiedRstREndMsg';
import CARE_NoRecordsDoAdjustment from '@salesforce/label/c.CARE_NoRecordsDoAdjustment';



//import rStartDate from '@salesforce/schema/CARE_App_Enrolled_SA__c.RETRO_START_DATE__c';
//import rEndDate from '@salesforce/schema/CARE_App_Enrolled_SA__c.RETRO_END_DATE__c';

const columns = [

    {label: 'SA ID', fieldName: 'saID', type: 'text'},
    //{label: 'Application ID', fieldName: 'Name', type: 'text'},
     
    {label: 'Service Type', fieldName: 'saType',type: 'text'},
    
    {label: 'Yes Date', fieldName: 'yesDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},
    
    {label: 'No Date', fieldName: 'noDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

    {label: 'Retro Start Date', fieldName: 'rStartDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

    {label: 'Retro End Date', fieldName: 'rEndDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},
    
    //{label: 'Incentive Amt', fieldName: 'incentiveAmt',type: 'number', cellAttributes: { alignment: 'left' }},
    
    {label: 'CC&B SA Start Date', fieldName: 'ccbSAstartDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

    {label: 'Last Bill Date', fieldName: 'lastBillDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

];

const columnsWithEdit = [

    {label: 'SA ID', fieldName: 'saID', type: 'text'},
    //{label: 'Application ID', fieldName: 'Name', type: 'text'},
     
    {label: 'Service Type', fieldName: 'saType',type: 'text'},
    
    {label: 'Yes Date', fieldName: 'yesDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},
    
    {label: 'No Date', fieldName: 'noDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

    {label: 'Retro Start Date', fieldName: 'rStartDate',type: 'date-local', typeAttributes:{day:"2-digit",month:"2-digit"}, editable:true},

    {label: 'Retro End Date', fieldName: 'rEndDate',type: 'date-local', typeAttributes:{day:"2-digit",month:"2-digit"}, editable:true},
    
    //{label: 'Incentive Amt', fieldName: 'incentiveAmt',type: 'number', cellAttributes: { alignment: 'left' }},
    
    {label: 'CC&B SA Start Date', fieldName: 'ccbSAstartDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

    {label: 'Last Bill Date', fieldName: 'lastBillDate',type: 'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric"}},

];


export default class lwcCmpName extends NavigationMixin(LightningElement) {

    @track error;
    careResDesc;
    @track careResAppId = '';
    @track careResccDesc = '';
    @track enrollReturn;
    @track sCareAppStatus = '';
    @api sLiveAppCall;
    //@track careResultList = 
    @track values;
    //@track careSAData;
    @track careSAData = [];
    @track columns = columns;
    @track columnsWithEdit = columnsWithEdit;
    @track showLoadingSpinner = true;
    @track channelOptions;
    _wiredSolarProjectResult;
    @track isNewEnrollment = false;
    @track saMapdetails = [];
    @track publicAssistanceSection = false;
    @track houseHoldSection = false;
    @track enableAppName = true;
    @track isAdjustmentReasonCheck = true;
    @track isDataTableEditable = false;
    @track bIsDuplicate = false;
    @track receivedDate;
    @track bRecordInputsCheck = true;
    @track enrollRecordInsertResponse = false;
    @api sSelectedPerId;
    @api sSelectedAcctId;
    @api sSelectedBillingAcctId;
    @api listSelectedPremIds = [];
    @api sSelectedAppId;
    @api sSelectedName;
    @track draftValues = [];
    @api bModalFlag;
    @track adjustReasonList;
    @track saIDRecordForIsAdjust = [];
    sEventNameAction = '';
    sEventVariant = 'info';
    sRelatedSACall = 'first';
    bShowConfirmationModal = false;
    bAdjustmentAtleastOneRowValid = false;
    bRequestDrop = false;
    @track EnrollObjFields = {
        isCertValueCB: false,
        adultValue: 0,
        childrenValue: 0,
        isSignedValueCB: false,
        requestDropValueCB: false,
        nncValueCB: false,
        applicantNameValue: '',
        receiveDateValue: '',
        processDateValue: '',
        channelTypeValue: '',
        formCodeValue: '',
        cocCodeValue: '',
        /** Public Assistance  **/
        uHeapValue: false,
        wicValue: false,
        calFreshValue: false,
        calWorkValue: false,
        hsieValue: false,
        ssiValue: false,
        mediFamilyValue: false,
        nslpValue: false,
        boiaValue: false,
        mediUnderValue: false,
        mediOverValue: false,
        emailValue: '',       
        annualIncValue: 0,
        fixedIncValue: false,
        isAdjustValue: false,
        retroYDateValue: '',
        retroNDateValue: '',
        processNoteValue: '',
        adjustReasonValue: '',
        noDateValue: false,
        ccbCommentValue: '',
        isDuplicateValue: false,
        isNewEnrollmentValue: false,
        /** System Information */
        lastModifiedDate: '',
        lastModifiedById: '',
        qualifiedBy:'',
        accountIDLink:'',
        applicationStatus:''

    };

    label = {
        EnrollmentCreateErrorMsg,
        EnrollmentDocumentValidationMsg,
        EnrollmentEditErrorMsg,
        RetroDateValidationMsg,
        ApplicantNameMsg,
        EmailIdValidation,
        CommentFieldValidationMsg,
        EnrollmentSaveMsg,
        EnrollmentProcessingMsg,
        EnrollAcceptMsg,
        BothRetroDateValidationMsg,
        CommentFieldLengthValidationMsg,
        StartDateValidationMsg,
        AdultFieldValidationMsg,
        ErrorHeader,
        SuccessHeader,
        ConfirmationMsg,
        CancelHeader,
        TransactionSuccessMsg,
        TransactionErrorMsg,
        RetroStartDateValidationMsg,
        CARE_NotModifiedRstREndMsg,
        CARE_NoRecordsDoAdjustment,
        ReceiveDateMsg
    };
    
    
	/** Wired Apex result so it can be refreshed programmatically */
    

    @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : SOURCE_CHANNEL_TYPE
    })
    wiredPickListValue({ data, error }){
        if(data){
            //console.log(` Picklist values are `, data.values);
            this.channelOptions = data.values;
            this.error = undefined;
            //console.log(` bModalFlag Value is `, this.bModalFlag);
        }
        if(error){
            //console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.channelOptions = undefined;
        }
    }

    /*@wire(fatchPickListValue, {objInfo: {'sobjectType' : 'CARE_Application__c'},
                picklistFieldApi: 'SOURCE_CHANNEL_TYPE__c'}) stageNameValues;*/
       
    
    @wire(getRelatedSA, { selectedAppId: '$careResAppId', sMakeLivecall :'$sRelatedSACall' })
      wiredsolarProjectRes(resp) {
        this._wiredSolarProjectResult = resp;
        const { data, error } = resp;
        
		if(data) {
            //this.opporunity = data;
            this.careSAData = data.listAdjust;
            this.adjustReasonList = data.listAdjustReason;
            this.bAdjustmentAtleastOneRowValid = data.bHavingRetroDates;
            console.log(` careSAData: `,  this.careSAData);
            
            //this.error = undefined;
             
        
                this.showLoadingSpinner = false;
            
            
        }else if (error) {
            this.error = error;
            this.data = undefined;
            this.showLoadingSpinner = false;
        }
}

/*findRowIndexById(id) {
    let ret = -1;
    this.careSAData.some((row, index) => {
        if (row.Id === id) {
            ret = index;
            return ret;
        }
    });
    return ret;
}*/

handleDataTableSave(event){
    let today = new Date();
    let dateToday = today.getFullYear()+'-'+('0' + (today.getMonth()+1)).slice(-2)+'-'+('0' + today.getDate()).slice(-2);
    
    const recordInputs =  event.detail.draftValues.slice().map(draft => {
        const fields = Object.assign({}, draft);
        console.log(` field draft values: `, fields);
        
        return { fields };
        
    });
    console.log(` field draft values recordInputs: `, recordInputs);
    let retroDateValues = [];
    let ret = -1;
    let sErrorMsgAdjustment = '';
    if(recordInputs){
            this.bRecordInputsCheck = true;
            recordInputs.forEach((element,index) => {
                let retroDates = { ...element};
                //let careSADataIndex = this.findRowIndexById(retroDates.fields.Id);
                let careSADataIndex = this.careSAData.findIndex(x => x.Id === retroDates.fields.Id);
                
                if(isNotBlank(retroDates.fields.rStartDate) && isBlank(retroDates.fields.rEndDate) && isBlank(this.careSAData[careSADataIndex].rEndDate)){
                    this.bRecordInputsCheck = false;
                    sErrorMsgAdjustment = this.label.StartDateValidationMsg;
                }
                else if(isNotBlank(retroDates.fields.rStartDate) && retroDates.fields.rStartDate >= dateToday){
                    this.bRecordInputsCheck = false;
                    sErrorMsgAdjustment = this.label.RetroStartDateValidationMsg;
                }
                else if(isNotBlank(retroDates.fields.rStartDate) && isNotBlank(retroDates.fields.rEndDate) && (retroDates.fields.rStartDate > dateToday || retroDates.fields.rEndDate > this.careSAData[careSADataIndex].yesDate || retroDates.fields.rEndDate <= retroDates.fields.rStartDate)){
                    this.bRecordInputsCheck = false;
                    sErrorMsgAdjustment = this.label.RetroDateValidationMsg;
                }
                else if(isBlank(retroDates.fields.rStartDate) && isNotBlank(retroDates.fields.rEndDate) && (retroDates.fields.rEndDate > this.careSAData[careSADataIndex].yesDate || retroDates.fields.rEndDate < this.careSAData[careSADataIndex].rStartDate)){
                    this.bRecordInputsCheck = false;
                    sErrorMsgAdjustment = this.label.RetroDateValidationMsg;
                }
                else if(isNotBlank(retroDates.fields.rStartDate) && isBlank(retroDates.fields.rEndDate) && isNotBlank(this.careSAData[careSADataIndex].rEndDate) && (retroDates.fields.rStartDate > this.careSAData[careSADataIndex].rEndDate)){
                    this.bRecordInputsCheck = false;
                    sErrorMsgAdjustment = this.label.RetroDateValidationMsg;
                }
            });
        

        if(this.bRecordInputsCheck){
            for(let i =0; i < recordInputs.length; i++ ){
                if(recordInputs[i].fields.hasOwnProperty('rStartDate') && recordInputs[i].fields.hasOwnProperty('rEndDate')){
                    retroDateValues.push({'fields':{'RETRO_START_DATE__c':recordInputs[i].fields.rStartDate,'RETRO_END_DATE__c':recordInputs[i].fields.rEndDate,'Id':recordInputs[i].fields.Id}})
                }else if(recordInputs[i].fields.hasOwnProperty('rStartDate')){
                    retroDateValues.push({'fields':{'RETRO_START_DATE__c':recordInputs[i].fields.rStartDate,'Id':recordInputs[i].fields.Id}})
                }else{
                    retroDateValues.push({'fields':{'RETRO_END_DATE__c':recordInputs[i].fields.rEndDate,'Id':recordInputs[i].fields.Id}})
                }
                
            }
            
            //fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
            
            console.log(` field draft values retroDateValues: `, retroDateValues);
            const promises = retroDateValues.map(recordInput => updateRecord(recordInput));
            Promise.all(promises).then(result => {
                //this.returedDataTable = result;
                //console.log(` result values: `, result);
            /*this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contacts updated',
                    variant: 'success'
                })
            );*/
            // Clear all draft values
            this.draftValues = [];
            //this.careSAData = this._wiredSolarProjectResult;
            // Display fresh data in the datatable
            //console.log(` _wiredSolarProjectResult value: `, this._wiredSolarProjectResult);
            //console.log(` care SA Data value: `, this.careSAData);
            //this._wiredSolarProjectResult
            return refreshApex(this._wiredSolarProjectResult);
            //return this.returedDataTable;
            }).catch(error => {
                // Handle error
                this.showToastMessage(this.label.ErrorHeader, this.label.EnrollmentEditErrorMsg, 'error');
            });
        }else{
            this.showToastMessage(this.label.ErrorHeader, sErrorMsgAdjustment, 'error');
        }
   }
}

    @wire(sendReceivedDate,{sLiveCall: '$sLiveAppCall'})
    wiredUserRoles({ error, data }) {
        if (data) {
            console.log(` data value `, data);
            //this.receivedDate = data;
            //this.EnrollObjFields.receiveDateValue = data[0].Received_Date__c;
            this.EnrollObjFields.receiveDateValue = data.receiveDateValue;
            this.EnrollObjFields.processDateValue = data.processDateValue;
            console.log(` CDate received `, this.EnrollObjFields.processDateValue);
            //console.log(` CDate processed `, this.EnrollObjFields.receiveDateValue); 
        }else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    @wire(prePopulatEnrollData, {selectPerId: '$sSelectedPerId', sSelectedAppId: '$sSelectedAppId', sLiveCall: '$sLiveAppCall'})
    enrollDataValue({error, data}){
        if(data){
           if(data.hasOwnProperty(0)) {
            if(data[0].NEED_NAME_CHANGE__c === true && this.bModalFlag === false){
                this.enableAppName = false;
            }else{
                this.enableAppName = true;
            }

            console.log('prePopulated data value is'+ data);
            console.log('prePopulated data value is with JSON.Stringify'+ JSON.stringify(data));
            /*data.forEach(element => { 

        }) */ 
        this.EnrollObjFields.isCertValueCB = data[0].IS_RECERT__c;
        this.EnrollObjFields.adultValue = data[0].NO_ADULT__c;
        this.EnrollObjFields.childrenValue = data[0].NO_CHILD__c;
        this.EnrollObjFields.isSignedValueCB = data[0].IS_SIGNED__c;
        this.EnrollObjFields.requestDropValueCB = data[0].REQUEST_DROP__c;
        this.EnrollObjFields.nncValueCB = data[0].NEED_NAME_CHANGE__c;// === true ? data[0].NEED_NAME_CHANGE__c : false;
        this.EnrollObjFields.accountIDLink = this.sSelectedAcctId;
        this.EnrollObjFields.applicationStatus = data[0].APPLICATION_STATUS__c;
        if(this.bModalFlag === true){
        this.EnrollObjFields.processDateValue = data[0].PROCESSED_DATE__c;
        this.EnrollObjFields.accountIDLink = data[0].CARE_Account_ID__c;
        }

        this.EnrollObjFields.qualifiedBy = data[0].QUALIFIED_BY__c;
        this.EnrollObjFields.lastModifiedById = data[0].LastModifiedBy.LAN_ID_EI__c;
        this.EnrollObjFields.lastModifiedDate = data[0].LastModifiedDate;
        this.EnrollObjFields.channelTypeValue = data[0].SOURCE_CHANNEL_TYPE__c;
        this.EnrollObjFields.formCodeValue = data[0].FORM_CODE__c;
        this.EnrollObjFields.cocCodeValue = data[0].COC_CODE__c;
        this.EnrollObjFields.uHeapValue = data[0].LIHEAP__c === true ? data[0].LIHEAP__c : false;
        this.EnrollObjFields.wicValue = data[0].WIC__c;
        this.EnrollObjFields.calFreshValue = data[0].CALFRESH_SNAP__c;
        this.EnrollObjFields.calWorkValue = data[0].CALWORKS_TANF__c;
        this.EnrollObjFields.hsieValue = data[0].HEAD_START_INCOME__c;
        this.EnrollObjFields.ssiValue = data[0].SSI__c;
        this.EnrollObjFields.mediFamilyValue = data[0].HEALTHY_FAMILIES__c;
        this.EnrollObjFields.nslpValue = data[0].NSLP__c;
        this.EnrollObjFields.boiaValue = data[0].BUREAU_INDIAN_AFFAIRS__c;
        this.EnrollObjFields.mediUnderValue = data[0].MEDICAID_UNDER65__c;
        this.EnrollObjFields.mediOverValue = data[0].MEDICAID_OVER65__c;
        this.EnrollObjFields.emailValue = data[0].EMAIL_ADDRESS__c;
        this.EnrollObjFields.annualIncValue = data[0].ANNUAL_HOUSEHOLD_INCOME__c === null ? 0 : data[0].ANNUAL_HOUSEHOLD_INCOME__c;
        this.EnrollObjFields.fixedIncValue = data[0].FIXED_INCOME__c;
        this.EnrollObjFields.processNoteValue = data[0].PROCESS_NOTES__c;
        this.EnrollObjFields.applicantNameValue = data[0].APPLICANT_NAME__c;
        this.EnrollObjFields.isAdjustValue = data[0].IS_ADJUSTMENT__c;
        this.EnrollObjFields.adjustReasonValue = data[0].REASON_DESC__c;
        this.EnrollObjFields.receiveDateValue = data[0].RECEIVED_DATE__c != null ? data[0].RECEIVED_DATE__c : this.EnrollObjFields.processDateValue;
        this.careResccDesc = data[0].CCB_CONTACT_DESC__c != '' ? data[0].CCB_CONTACT_DESC__c : '';
        this.EnrollObjFields.ccbCommentValue = data[0].CCB_CONTACT_COMMENT__c != '' ? data[0].CCB_CONTACT_COMMENT__c : '';
        this.careResAppId = data[0].Id;
        //this.sLiveAppCall = 'second';


           }else{
               this.handleCancel(); // make cache clear while performing delete or fresh enroll
               this.careResccDesc = '';
               this.careResAppId = '';
               this.sCareAppStatus = '';
               this.EnrollObjFields.ccbCommentValue = '';
           }
           this.showLoadingSpinner = false;
        }else if (error) {
            this.error = error;
            this.contacts = undefined;
            this.showLoadingSpinner = false;
        }

        if(this.EnrollObjFields.applicantNameValue == '' || this.EnrollObjFields.applicantNameValue == undefined){
            this.EnrollObjFields.applicantNameValue = this.sSelectedName;
        }        
        if(this.bModalFlag === true){
            this.publicAssistanceSection = true;
            this.houseHoldSection = true;
        }
    }

    @wire(determineisNewEnrollment, { selectedPerId: '$sSelectedPerId', sMakeLiveCallDetermine: '$sLiveAppCall' })
    wiredSAmapData({ error, data }) {
        if (data) {

            console.log('determine is new enrollment data value' + data);

            this.EnrollObjFields.noDateValue = data.bIsNewCustomer;
            this.bRequestDrop = (this.bModalFlag) ? true : data.bRequestDrop;
            console.log('determine is new enrollment this.EnrollObjFields.noDateValue' , this.EnrollObjFields.noDateValue);

            if(!this.EnrollObjFields.noDateValue){
                this.EnrollObjFields.isNewEnrollmentValue = false;
                this.bIsDuplicate = true;
                console.log(` isNewEnrollment: `, this.EnrollObjFields.isNewEnrollmentValue); 
            }else if(this.EnrollObjFields.noDateValue === true){
                this.EnrollObjFields.isNewEnrollmentValue = true;
                this.isNewEnrollment = true;
                this.bIsDuplicate = false;
            }
  
        }else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
        
    }

    


/* assigning values to Customer Information section */
handleChange(event){
    let value;
    if(event.target.type === 'checkbox'){
        value = event.target.checked;
        //alert("checked value: "+ value);   
    }else{
        value = event.target.value;
        //alert("checked value1: "+ value);
    }
    if(event.target.dataset.id === 'checkboxisCertField'){
        this.EnrollObjFields.isCertValueCB = value;
        //getCustomerInfoWrapper.isCertValueCB = value;
    }else if(event.target.dataset.id === 'textadultField'){
        this.EnrollObjFields.adultValue = value;
        //getCustomerInfoWrapper.adultValue = value;       
    }else if(event.target.dataset.id === 'textChildField'){
        this.EnrollObjFields.childrenValue = value;
    }else if(event.target.dataset.id === 'checkboxisSignField'){
        this.EnrollObjFields.isSignedValueCB = value;
    }else if(event.target.dataset.id === 'checkboxreqDropField'){
        this.EnrollObjFields.requestDropValueCB = value;
    }else if(event.target.dataset.id === 'checkboxnncValField'){
        this.EnrollObjFields.nncValueCB = value;
        //this.enableAppName = false;
    }else if(event.target.dataset.id === 'textAppNameField'){
        this.EnrollObjFields.applicantNameValue = value;
    }else if(event.target.dataset.id === 'dateReceiveField'){
        this.EnrollObjFields.receiveDateValue = value;
    }else if(event.target.dataset.id === 'dateProcessField'){
        this.EnrollObjFields.processDateValue = value;
    }else if(event.target.dataset.id === 'textChannelField'){
        this.EnrollObjFields.channelTypeValue = value;
    }else if(event.target.dataset.id === 'textFormField'){
        this.EnrollObjFields.formCodeValue = value;
    }else if(event.target.dataset.id === 'textcocField'){
        this.EnrollObjFields.cocCodeValue = value;
        //alert("CustomerInfoWrapper Details: "+JSON.stringify(this.EnrollObjFields));
    }
    /*****  Public Assistance Fields *******/
    else if(event.target.dataset.id === 'UheapField'){
        this.EnrollObjFields.uHeapValue = value;
    }else if(event.target.dataset.id === 'wicField'){
        this.EnrollObjFields.wicValue = value;
    }else if(event.target.dataset.id === 'calFreshField'){
        this.EnrollObjFields.calFreshValue = value;
    }else if(event.target.dataset.id === 'calWorkField'){
        this.EnrollObjFields.calWorkValue = value;
    }else if(event.target.dataset.id === 'hsieField'){
        this.EnrollObjFields.hsieValue = value;
    }else if(event.target.dataset.id === 'ssiField'){
        this.EnrollObjFields.ssiValue = value;
    }else if(event.target.dataset.id === 'mediFamilyField'){
        this.EnrollObjFields.mediFamilyValue = value;
    }else if(event.target.dataset.id === 'nslpField'){
        this.EnrollObjFields.nslpValue = value;
    }else if(event.target.dataset.id === 'boiaField'){
        this.EnrollObjFields.boiaValue = value;
    }else if(event.target.dataset.id === 'mediUnderField'){
        this.EnrollObjFields.mediUnderValue = value;
    }else if(event.target.dataset.id === 'mediOverField'){
        this.EnrollObjFields.mediOverValue = value;
    }else if(event.target.dataset.id === 'emailField'){
        this.EnrollObjFields.emailValue = value;
    }else if(event.target.dataset.id === 'AnnualIncField'){
        this.EnrollObjFields.annualIncValue = value;
    }else if(event.target.dataset.id === 'fixedIncField'){
        this.EnrollObjFields.fixedIncValue = value;
    }/*else if(event.target.dataset.id === 'isAdjustField'){
        this.EnrollObjFields.isAdjustValue = value;
    }*/else if(event.target.dataset.id === 'isAdjustField'){
        this.EnrollObjFields.isAdjustValue = value;
        //this.isRetroDateEditable = true;
        //return refreshApex(this._wiredSolarProjectResult);
    }else if(event.target.dataset.id === 'processNoteField'){
        this.EnrollObjFields.processNoteValue = value;
    }else if(event.target.dataset.id === 'textAdjustField'){
        this.EnrollObjFields.adjustReasonValue = value;
    }else if(event.target.dataset.id === 'ccbCommentField'){
        this.EnrollObjFields.ccbCommentValue = value;
    }else if(event.target.dataset.id === 'isDuplicateField'){
        this.EnrollObjFields.isDuplicateValue = value;
    }else if(event.target.dataset.id === 'isNewEnrollField'){
        this.EnrollObjFields.isNewEnrollmentValue = value;
    }


    console.log(` Customer values are `, this.EnrollObjFields);
    console.log(` Person Id from parent `, this.sSelectedPerId);
    console.log(` Premise ID from parent `, this.listSelectedPremIds);
    console.log(` Modal flag ID from parent `, this.bModalFlag);
    console.log(` Energy Insight Acct Id `, this.sSelectedAcctId);
    

    if(this.EnrollObjFields.nncValueCB === true && this.bModalFlag === false){
        this.enableAppName = false;
    }else{
        this.enableAppName = true;
    }

    if(this.EnrollObjFields.isAdjustValue === true && this.bModalFlag === false){
        this.isAdjustmentReasonCheck = false;
        this.isDataTableEditable = true;
        console.log(` isDataTableEditable `, this.isDataTableEditable);
        //return refreshApex(this._wiredSolarProjectResult);
    }else{
        this.isAdjustmentReasonCheck = true;
        this.isDataTableEditable = false;
        console.log(` isDataTableEditable after uncheck if isAsdjustment `, this.isDataTableEditable);
    }
    
    if(this.EnrollObjFields.uHeapValue === true || this.EnrollObjFields.wicValue === true ||
      this.EnrollObjFields.calFreshValue === true || this.EnrollObjFields.calWorkValue === true || this.EnrollObjFields.hsieValue === true ||
      this.EnrollObjFields.ssiValue === true || this.EnrollObjFields.mediFamilyValue === true || this.EnrollObjFields.nslpValue === true ||
      this.EnrollObjFields.boiaValue === true || this.EnrollObjFields.mediUnderValue === true || this.EnrollObjFields.mediOverValue === true ||
      (this.EnrollObjFields.emailValue != '' && this.EnrollObjFields.emailValue != undefined )) {

        this.publicAssistanceSection = true;
        this.houseHoldSection = false;   
    
    }else{
        this.publicAssistanceSection = false;
        this.houseHoldSection = false;
    }

    if(this.bModalFlag === true){
        this.publicAssistanceSection = true;
        this.houseHoldSection = true;
    }
    
    /*if(this.EnrollObjFields.annualIncValue != null || this.EnrollObjFields.fixedIncValue === true){

        this.houseHoldSection = true;
    }else {
        this.houseHoldSection = false;
    }*/
}

handleApplicantNameSet(){
    if(this.EnrollObjFields.nncValueCB){
        this.EnrollObjFields.applicantNameValue = this.sSelectedName;
    }
}

goToAccountRecord(){
      // Navigate to record page
   /*   this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.EnrollObjFields.accountIDLink,
            //objectApiName: 'CARE_Application__c',
            actionName: 'view',
        },
    }); */

    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.EnrollObjFields.accountIDLink,
            actionName: 'view',
        },
    }).then(url => {
        window.open(url);
    });
}

handleSave(event){
    let nameEvent;
    let formValidFlag = true;
    let sErrorMsgSave = '';
    if((this.EnrollObjFields.adultValue === '' || this.EnrollObjFields.adultValue === undefined || this.EnrollObjFields.adultValue <= 0) && event.target.name !== 'save'){
        formValidFlag = false;
        sErrorMsgSave = this.label.AdultFieldValidationMsg;
    }
    else if(this.EnrollObjFields.receiveDateValue === '' || this.EnrollObjFields.receiveDateValue === undefined || this.EnrollObjFields.receiveDateValue === null){
        formValidFlag = false;
        sErrorMsgSave = this.label.ReceiveDateMsg;
    }
    else if(this.EnrollObjFields.nncValueCB && (this.EnrollObjFields.applicantNameValue == '' || this.EnrollObjFields.applicantNameValue == undefined)){
        formValidFlag = false;
        sErrorMsgSave = this.label.ApplicantNameMsg;
    }else if(this.EnrollObjFields.ccbCommentValue !=undefined && this.EnrollObjFields.ccbCommentValue.length > 256){
        formValidFlag = false;
        sErrorMsgSave = this.label.CommentFieldLengthValidationMsg;
    }
    else if(this.EnrollObjFields.ccbCommentValue !=undefined && this.EnrollObjFields.ccbCommentValue.length > 0 && (this.EnrollObjFields.ccbCommentValue.indexOf(',') !== -1)){ // !='' && this.EnrollObjFields.ccbCommentValue != undefined){
        formValidFlag = false;
        sErrorMsgSave = this.label.CommentFieldValidationMsg;
    }else if(this.EnrollObjFields.isAdjustValue && (this.careSAData ==undefined || (this.careSAData !=undefined && this.careSAData.length == 0))){
        formValidFlag = false;
        sErrorMsgSave = this.label.CARE_NoRecordsDoAdjustment;
    }else if(this.EnrollObjFields.isAdjustValue && !this.bAdjustmentAtleastOneRowValid){
        formValidFlag = false;
        sErrorMsgSave =this.label.CARE_NotModifiedRstREndMsg;
    }else if(this.EnrollObjFields.emailValue !=='' && this.EnrollObjFields.emailValue !== undefined){
        let allInputValid = [...this.template.querySelectorAll('.emailValidCheck')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        formValidFlag = allInputValid;
        if(!formValidFlag){
            sErrorMsgSave = this.label.EmailIdValidation;
        }
   }
       
    console.log(` formValidFlag value `, formValidFlag);
    if(formValidFlag){
        this.showLoadingSpinner = true;
        if((this.EnrollObjFields.adultValue == '' || this.EnrollObjFields.adultValue == undefined) && (event.target.name !== 'verify' || event.target.name !== 'accept')){
            this.EnrollObjFields.adultValue = 0;
        }
        if(this.EnrollObjFields.childrenValue == '' || this.EnrollObjFields.childrenValue == undefined){
            this.EnrollObjFields.childrenValue = 0;
        }
        if(this.EnrollObjFields.annualIncValue == '' || this.EnrollObjFields.annualIncValue == undefined){
            this.EnrollObjFields.annualIncValue = 0;
        }

        if(event.target.name === 'save'){
            nameEvent = event.target.name;
            //this.sEventNameAction = 'Enrollment record saved';
            this.sEventNameAction = this.label.EnrollmentSaveMsg;
            this.sEventVariant = 'info';
            //alert("checked  value: "+ value);   
        }else if(event.target.name === 'verify'){
            nameEvent = event.target.name;
            //this.sEventNameAction = 'Enrollment processing complete' ;
            this.sEventNameAction = this.label.EnrollmentProcessingMsg;
            this.sEventVariant = 'info';
            //alert("checked value1: "+ value);
        }else if(event.target.name === 'accept'){
            nameEvent = event.target.name;
            //this.sEventNameAction = 'Enrollment is accepted successfully';
            this.sEventNameAction = this.label.EnrollAcceptMsg;
            this.sEventVariant = 'success';
        }
        
        console.log(` Event Name `, nameEvent);
        
        console.log(` isAdjustValue `, this.EnrollObjFields.isAdjustValue);
        console.log(` Customer values inside Verify button click `, this.EnrollObjFields);
        handleButtonClickOnUI({MassRecordData : this.EnrollObjFields, perID : this.sSelectedPerId, premID : this.listSelectedPremIds, eventName : nameEvent, isAdjustCheckBox : this.EnrollObjFields.isAdjustValue, appIdCareApplication : this.careResAppId, eIAcctId: this.sSelectedAcctId, billingAccId: this.sSelectedBillingAcctId}).then(result => {
            // Clear the user enter values
            //this.EnrollObjFields = {};
            console.log('result ===> '+ JSON.stringify(result));
            console.log('result ===> '+ result);
            this.careResAppId = result.applicationId;
            this.sCareAppStatus  = result.careApplicationStatus;

            console.log(` Application Status VALUE---->: `, this.sCareAppStatus); 
            
            if(result.sEventName === 'verify' || (result.sEventName === 'accept' && result.bImageCheck === true)){
                if(result.sEventName === 'verify' ){ // Update Comment only in Case Verify
                    this.EnrollObjFields.ccbCommentValue = result.careCCLongDescValue;
                }
                if(result.sEventName === 'accept'){
                    this.getSystemInformationAfterAccept();
                }
                this.careResccDesc = result.ccCodeDescription;
                this.sRelatedSACall = new Date().toLocaleString();

            }

            
            console.log(` careResAppId VALUE---->: `, this.careResAppId); 
            console.log(` result careResccDesc---->: `, this.careResccDesc);
            /*console.log('result ===> '+ JSON.stringify(result));
            //this.careResDesc = result;
            this.careResult = result;
            console.log(` careresult final is `, this.careResult);*/
            /*if(result.success) {
                //let saIDValue;
                //let valueResult;
                //let valueResultFinal = [];
                this.careResAppId = result.applicationId;
                this.careResccDesc = result.ccCodeDescription;

                //valueResultFinal = result;
                //saIDValue = result.resList;
                console.log(` careResAppId VALUE---->: `, this.careResAppId); 
                console.log(` result careResccDesc---->: `, this.careResccDesc);
                //console.log(` result valueResultFinal---->: `, valueResultFinal);
                //this.opporunity = data;
                /*result.forEach((row) => {
                let rowData = {};
            
                    rowData.appId = row.applicationId;
                    rowData.ccCodeDesc = row.ccCodeDescription;
                    
                    resValue.push(rowData);
                    console.log(` saIDValue VALUE---->: `, saIDValue);                 
                });
                this.careResult = saIDValue;
                console.log(` careresult final is -->: `, this.careResult);
                
                
            }else if (error) {
                this.error = error;
                this.data = undefined;
            }*/

            //console.log(` result is `, this.careResDesc);
            // Show success messsage =
            this.showLoadingSpinner = false;
            if(result.bImageCheck){
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: this.sEventNameAction,
                    variant: this.sEventVariant
                }),);
            }else{
                this.showToastMessage(this.label.ErrorHeader, this.label.EnrollmentDocumentValidationMsg, 'error');
            }

        })
        .catch(error => {
            this.error = error.message;
            this.showLoadingSpinner = false;
            this.showToastMessage(this.label.ErrorHeader, this.label.EnrollmentCreateErrorMsg, 'error');
            
        });

      }else{
        this.showToastMessage(this.label.ErrorHeader,sErrorMsgSave, 'error');
      }
}
    

handleCancel(){
    this.template.querySelectorAll('lightning-input').forEach(elem => {
        if (elem.type === 'checkbox') {
            elem.checked = false;
        } else if(elem.name =='receiveDate' || elem.name == 'processDate' || elem.name == 'applicantName' ){
                // do not reset
        }else if(elem.name =='children' || elem.name == 'adult' || elem.name =='annualIncome'){
           elem.value = 0;
        }
        else{
            elem.value = ''; 
        }
            
        
    });
    //This is to clear all the picklist
    this.template.querySelectorAll('lightning-combobox').forEach(elem => {
        elem.value = null;
    });
    
    //Actual fields
    let rDate = this.EnrollObjFields.receiveDateValue;
    let pDate = this.EnrollObjFields.processDateValue;
    let sCustname = this.EnrollObjFields.applicantNameValue;
    

     this.EnrollObjFields = {
        isCertValueCB: false,
        adultValue: 0,
        childrenValue: 0,
        isSignedValueCB: false,
        requestDropValueCB: false,
        nncValueCB: false,
        applicantNameValue: sCustname,
        receiveDateValue: rDate,
        processDateValue: pDate,
        channelTypeValue: '',
        formCodeValue: '',
        cocCodeValue: '',
        /** Public Assistance  **/
        uHeapValue: false,
        wicValue: false,
        calFreshValue: false,
        calWorkValue: false,
        hsieValue: false,
        ssiValue: false,
        mediFamilyValue: false,
        nslpValue: false,
        boiaValue: false,
        mediUnderValue: false,
        mediOverValue: false,
        emailValue: '',       
        annualIncValue: 0,
        fixedIncValue: false,
        isAdjustValue: false,
        retroYDateValue: '',
        retroNDateValue: '',
        processNoteValue: '',
        adjustReasonValue: '',
        ccbCommentValue: '',
        isDuplicateValue: false,
        noDateValue: false       
        };

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

/*handleAccept(event){
    console.log(` SAID values inside accept button-->: `, this.saIDRecordForIsAdjust);
    handleAcceptButtonClickOnUI({listOfSAID : this.saIDRecordForIsAdjust}) 
}*/


   /* refreshData() {
        return refreshApex(this._wiredSolarProjectResult);
    }*/

    get checkApplicationId() {
        return this.careResAppId.length > 0;
    }
    get checkResultDesc() {
        return (this.careResccDesc =='' || this.careResccDesc == undefined || this.careResccDesc == null || this.sCareAppStatus == "Decision Made" || this.sCareAppStatus == "Cancelled");
    }
    get checkAcceptedApplication(){
        return this.sCareAppStatus == "Decision Made" || this.sCareAppStatus == "Cancelled" || this.bModalFlag;  // Added Viewonly flag for adjutsment check box after accepting application not allow modify adjustment
    }

    get checkDataTableNoEdit(){
        return this.sCareAppStatus == "Decision Made" || this.sCareAppStatus == "Cancelled" || this.bModalFlag || !this.EnrollObjFields.isAdjustValue;  // Added Viewonly flag for adjutsment check box after accepting application not allow modify adjustment
    }

    get checkAppIdORAccepted(){
        return this.careResAppId == '' || this.careResAppId == undefined || this.sCareAppStatus == "Decision Made" || this.sCareAppStatus == "Cancelled";
    }

    //close confirmation modal Popup
    closeConfirmationModal(event) {
        this.bShowConfirmationModal = false;
    }

    //confirmed to cancel the application in between
    cancelApplication(event) {
        this.closeConfirmationModal();
        this.showLoadingSpinner = true;
        setCancelStatusCareApplication({
            sSelectedAppId: this.careResAppId
            })
            .then(result => {
                console.log('result setCancelStatusCareApplication call==>' + JSON.stringify(result));
                this.showLoadingSpinner = false;
                if (result) {
                    this.getSystemInformationAfterAccept();
                    this.sCareAppStatus = "Cancelled";
                    this.showToastMessage(this.label.SuccessHeader, this.label.TransactionSuccessMsg, 'success');
                    
                } else {
                    this.showToastMessage(this.label.ErrorHeader, this.label.TransactionErrorMsg, 'error');
                }
 
            })
            .catch((error) => {
                this.showToastMessage(this.label.ErrorHeader, error.message, 'error');
            });
    }

    showConfirmationModal(){
        this.bShowConfirmationModal = true;
    }

    getSystemInformationAfterAccept(){
        getSystemInfoCareAppData({
            sSelectedAppId: this.careResAppId
            })
            .then(result => {
                console.log('result getSystemInfoCareAppData call==>' + JSON.stringify(result));
                if (result) {
                    this.EnrollObjFields.qualifiedBy = result[0].QUALIFIED_BY__c;
                    this.EnrollObjFields.lastModifiedById = result[0].LastModifiedBy.LAN_ID_EI__c;
                    this.EnrollObjFields.lastModifiedDate = result[0].LastModifiedDate;
                    this.EnrollObjFields.applicationStatus = result[0].APPLICATION_STATUS__c;
        
                } 
 
            })
            .catch((error) => {
                this.showToastMessage(this.label.ErrorHeader, error.message, 'error');
            });
    }
    

}