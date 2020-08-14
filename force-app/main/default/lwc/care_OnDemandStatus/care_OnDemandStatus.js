import { LightningElement,wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DISCOUNT_TYPE from '@salesforce/schema/Account.CARE_DISCOUNT_TYPE__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSADetails from '@salesforce/apex/CARE_OnDemandStatusController.getSADetails';
import getDetailsOnButtonClick from '@salesforce/apex/CARE_OnDemandStatusController.getDetailsOnButtonClick';

//custom labels
import ErrorHeader from '@salesforce/label/c.CARE_ErrorHeader';
import TransactionErrorMsg from '@salesforce/label/c.CARE_TransactionErrorMsg';
import YesNoDateMsg from '@salesforce/label/c.CARE_YesNoDateMsg';
import SelectReasonMsg from '@salesforce/label/c.CARE_SelectReasonMsg';
import SelectCommentMsg from '@salesforce/label/c.CARE_SelectCommentMsg';
import DiscountTypeMsg from '@salesforce/label/c.CARE_DiscountTypeMsg';
import NoDateMsg from '@salesforce/label/c.CARE_NoDateMsg';
import SAIDValidationMsg from '@salesforce/label/c.CARE_SAIDValidationMsg';
import CommentFieldLengthValidationMsg from '@salesforce/label/c.CARE_CommentFieldLengthValidationMsg';
import CommentFieldValidationMsg from '@salesforce/label/c.CARE_CommentFieldValidationMsg';
import TransactionSuccessMsg from '@salesforce/label/c.CARE_TransactionSuccessMsg';
import EnrollmentCreateErrorMsg from '@salesforce/label/c.CARE_EnrollmentCreateErrorMsg';
import AccountPersonIdValidationMsg from '@salesforce/label/c.CARE_AccountPersonIdValidationMsg';

export default class Care_OnDemandStatus extends LightningElement {

    
    //@track sBillAcctId = '';
    @track saData = [];
    @track discountOptions;
    @track sCustomerProbation;
    @track sOnProbation = '';
    @track sCommentTransferDrop = '';
    @track sCommentTransfer = '';
    @track bShowSAList = false;
    @track reasonSelected = false;
    @track bDiscountSelected = false;
    @track showLoadingSpinner = false;
    @track bSAidEntered = false;
    @track bSAidIncorrect = false;
    @track saIDLength = 0;
    @track listYesNoDate = [];
    @track listDuplicateNoDate = [];
    @track dDateToday;
    @track objInputFields = {
        sPerId: '',
        sReason: '',
        sBillAcctId: '',
        sDiscountType: '',
        sComment: ''
    };

    label = {
        ErrorHeader,
        TransactionErrorMsg,
        YesNoDateMsg,
        SelectReasonMsg,
        SelectCommentMsg,
        DiscountTypeMsg,
        NoDateMsg,
        SAIDValidationMsg,
        CommentFieldLengthValidationMsg,
        CommentFieldValidationMsg,
        TransactionSuccessMsg,
        EnrollmentCreateErrorMsg,
        AccountPersonIdValidationMsg
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
        fieldApiName : DISCOUNT_TYPE
    })
    wiredPickListValue({ data, error }){
        if(data){
            //console.log(` Picklist values are `, data.values);
            this.discountOptions = data.values;
            this.error = undefined;
            //console.log(` bModalFlag Value is `, this.bModalFlag);
        }
        if(error){
            //console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.discountOptions = undefined;
        }
    }

    ShowSADetails(){
        getSADetails({ sBillingAcctID: this.objInputFields.sBillAcctId })
        .then(result => {
           console.log('result1==>', JSON.stringify(result));

            let saDataList = [];
            this.objInputFields.sPerId = result.listOnDemandStatus[0].sPerId;
            //this.objInputFields.sPremId = result.listOnDemandStatus[0].sPremId;
            //this.objInputFields.sRate = result.listOnDemandStatus[0].sRate;

            result.listOnDemandStatus.forEach(element => {
               let OnDemandStatusRecord = {};
               OnDemandStatusRecord.sExtId = element.sExtId;
               OnDemandStatusRecord.idSARecID = element.idSARecID;
               OnDemandStatusRecord.idAccRecID = element.idAccRecID;
               OnDemandStatusRecord.sPerId = element.sPerId;
               OnDemandStatusRecord.sPremId = element.sPremId;
               OnDemandStatusRecord.sSAID = element.sSAID;
               OnDemandStatusRecord.saStatus = element.saStatus;
               OnDemandStatusRecord.sRate = element.sRate;
               OnDemandStatusRecord.sSiteName = element.sSiteName;
               OnDemandStatusRecord.bSF = (element.sType === 'SF') ? true : false ;
               OnDemandStatusRecord.bWS = (element.sType === 'WS') ? true : false ;
               OnDemandStatusRecord.bDM = (element.sType === 'DM') ? true : false ;

               saDataList.push(OnDemandStatusRecord);
            })       
            this.saData = saDataList;
            this.dataReasonOptions = result.listTransferReason;
            this.sCommentTransferDrop = result.sCommentTransferWithDrop;
            this.sCommentTransfer = result.sCommentTransfer;
            this.sOnProbation = result.sProbation;
            this.dDateToday = result.dTodaysDate;
            
            console.log('saData------>', this.saData);

            if(this.saData[0].sSAID !== undefined && this.saData[0].sSAID !== ''){
                this.bShowSAList = true;
            }else {
                this.bShowSAList = false;
                this.showToastMessage('Error!!', this.label.AccountPersonIdValidationMsg, 'error');
            }
        })
        .catch(error => {
            this.error = error;
            this.bShowSAList = false;
            //this.showLoadingSpinner = true;
            this.showToastMessage('Error!!', this.label.TransactionErrorMsg, 'error');
            console.log('ERROR==>', this.error);
        });
    }

    handleChange(event){
        let elemName = event.target.name;
        let value  = event.target.value;
        //reason picklist is selected
        if (elemName === "reasonField") {
            this.objInputFields.sReason = value;
            this.reasonSelected = true;
        }
        //comment text area is selected
        else if (elemName === "commentField") {
            this.objInputFields.sComment = value;
        }
        else if (elemName === "acctIdField") {
            this.objInputFields.sBillAcctId = value;
        }
        else if (elemName === "discountField") {
            this.objInputFields.sDiscountType = value;
            this.bDiscountSelected = true;
        }
        
    }


    //Date fields are edited
    handleDetailsChange(event) {
        //this.bFormEdited = true;
        let elemName = event.target.name;
        let index = event.target.dataset.index;
        let selectedValue = event.target.value;
        //Date is changed for Retro Start Date
        if (elemName === "yesDate") {
            this.saData[index].dYesDate = selectedValue;
        }
        //Date is changed for Retro End Date
        else if (elemName === "noDate") {
            this.saData[index].dNoDate = selectedValue;
        }
        else if (elemName === "saName") {
            this.saData[index].dSaName = selectedValue;
            this.bSAidEntered = true;
            this.saIDLength = this.saData[index].dSaName.length;
        }
        else if (elemName === "premName") {
            this.saData[index].dPremName = selectedValue;
            //this.bSAidEntered = true;
            //this.saIDLength = this.saData[index].dSaName.length;
        }
        else if (elemName === "rateName") {
            this.saData[index].dRateName = selectedValue;
            //this.bSAidEntered = true;
            //this.saIDLength = this.saData[index].dSaName.length;
        }
        console.log('saDATA after dates adjustment----->', this.saData);

        this.saData.forEach(element => {
            console.log('element.dYesDate', element.dYesDate);
            console.log('element.dNoDate', element.dNoDate);
            //if no date is future, then comment should be transfer only
            //if no date is past or todays date, then comment should be transfer with drop
            if (element.dNoDate > this.dDateToday) {
                this.objInputFields.sComment = this.sCommentTransfer;
            } else if (element.dNoDate <= this.dDateToday || (element.dYesDate !== null  && element.dYesDate !== undefined)) {
                this.objInputFields.sComment = this.sCommentTransferDrop;
            }
            
        });
        console.log('this.objInputFields.sComment', this.objInputFields.sComment);

        if(this.bSAidEntered){
            if(this.saIDLength !== 10){
                this.bSAidIncorrect = true;
            }else if(this.saIDLength === 10){
                this.bSAidIncorrect = false;
            }
        }
        
    }

    submitOnDemandStatus(){
        let bValidInput = true;
        let listUniqueNoDate = [];
        let isDuplicate = false;
        
        this.listYesNoDate = [];
        //check if atleast one Yes Date or No Date is Edited or Inserted
        this.saData.forEach(element => {
            if ((element.dYesDate !== null && element.dYesDate !== undefined && element.dYesDate !== '') || (element.dNoDate !== null && element.dNoDate !== undefined && element.dNoDate !== '') || (element.dSaName !== '' && element.dSaName !== undefined) || (element.dPremName !== '' && element.dPremName !== undefined) || (element.rateName !== '' && element.rateName !== undefined)) {
                this.listYesNoDate.push(element);  
                this.listDuplicateNoDate.push(element.dNoDate);             
            }
            
        });
        console.log('this.listYesNoDate---->', this.listYesNoDate);
        console.log('this.listDuplicateNoDate---->', this.listDuplicateNoDate);
        //console.log('this.listDuplicateNoDate length---->', this.listDuplicateNoDate.length);


        listUniqueNoDate = this.listDuplicateNoDate.filter((item, i, ar) => ar.indexOf(item) === i);
        if(listUniqueNoDate.length > 1){
            isDuplicate = true;
        }else {
            isDuplicate = false;
        }

        console.log('isDuplicate---->', isDuplicate);
        console.log('listUniqueNoDate---->', listUniqueNoDate);
        console.log('listUniqueNoDate length---->', listUniqueNoDate.length);

        /*if(this.bSAidEntered){
            if(this.saIDLength !== 10){
                this.bSAidIncorrect = true;
            }
            this.saData.forEach(element => {
                if(element.dSaName.length !== 10){
                    this.bSAidIncorrect = true;
                }else if(element.dSaName.length === 10){
                    this.bSAidIncorrect = false;
                }
            }); 
        }*/

        
        
        //VAlidations....
        if (this.listYesNoDate.length === 0) {
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.YesNoDateMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if(!this.reasonSelected){
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.SelectReasonMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
           listUniqueNoDate = [];
        }
        else if (this.objInputFields.sComment === '' || this.objInputFields.sComment === undefined) {
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.SelectCommentMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if (!this.bDiscountSelected) {
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.DiscountTypeMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if(isDuplicate === true){
            bValidInput = false;
            //
            this.showToastMessage('Error!!', this.label.NoDateMsg, 'error');
            this.listYesNoDate = [];
            isDuplicate = false;
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if(this.bSAidIncorrect === true){
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.SAIDValidationMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if(this.objInputFields.sComment.length > 256){
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.CommentFieldLengthValidationMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        else if(this.objInputFields.sComment.indexOf(',') !== -1){
            bValidInput = false;
            isDuplicate = false;
            this.showToastMessage('Error!!', this.label.CommentFieldValidationMsg, 'error');
            this.listYesNoDate = [];
            this.listDuplicateNoDate = [];
            listUniqueNoDate = [];
        }
        /*else if (this.bDiscountSelected === true){
            if(this.objInputFields.sDiscountType !== 'CARE' || this.objInputFields.sDiscountType !== 'FERA') {
            bValidInput = false;
            this.showToastMessage('Error!!', 'Discount type entered should be either CARE or FERA', 'error');
            this.listYesNoDate = [];
        }
    }*/
        console.log('this.listYesNoDate final---->', this.listYesNoDate);

        if (bValidInput) {
            this.doSAChanges();
        }
    }
    doSAChanges(){
        this.showLoadingSpinner = true;
        this.objInputFields.sPerId = this.saData[0].sPerId;
        console.log('this.objInputFields---->', this.objInputFields);
        
        getDetailsOnButtonClick({ listOnDemandStatus: this.listYesNoDate, objOnDemandStatusList: this.objInputFields})
        .then(result => {

            if(result){
                this.showToastMessage('Success!!', this.label.TransactionSuccessMsg, 'success');
                this.showLoadingSpinner = false;
                this.reasonSelected = false;
                this.bDiscountSelected = false;
                this.bSAidEntered = false;
                this.listYesNoDate = [];
                this.listDuplicateNoDate = [];
                this.bSAidIncorrect = false;
                this.bShowSAList = false;
                this.objInputFields = {
                    sPerId: '',
                    sReason: '',
                    sBillAcctId: '',
                    sDiscountType: '',
                    sComment: ''
                };
                

            }else{
                this.showToastMessage('Error!!', this.label.EnrollmentCreateErrorMsg, 'error');
                this.showLoadingSpinner = false;
                //this.reasonSelected = false;
                //this.bDiscountSelected = false;
                //this.bSAidEntered = false;
                //this.bSAidEntered = false;
                //this.listYesNoDate = [];
               // this.listDuplicateNoDate = [];
            }
        })
        .catch(error => {
            this.showToastMessage('Error!!', this.label.TransactionErrorMsg, 'error');
            this.showLoadingSpinner = false;
                this.reasonSelected = false;
                this.bDiscountSelected = false;
                this.bSAidEntered = false;
                this.listYesNoDate = [];
                this.listDuplicateNoDate = [];
                this.objInputFields = {};
                this.bSAidIncorrect = false;
                this.bShowSAList = false;
                this.objInputFields = {
                    sPerId: '',
                    sReason: '',
                    sBillAcctId: '',
                    sDiscountType: '',
                    sComment: ''
                };
        });
    }
}