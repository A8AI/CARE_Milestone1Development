import { LightningElement, track, wire, api } from 'lwc';
import getPhoneDetails from '@salesforce/apex/CARE_CommunicationModController.getPhoneDetails';
import savePhoneDetails from '@salesforce/apex/CARE_CommunicationModController.savePhoneDetails';
//import getCommunicationDetails from '@salesforce/apex/CARE_CommunicationModal.getCommunicationDetails';
//import saveCommunicationDetails from '@salesforce/apex/CARE_CommunicationModal.saveCommunicationDetails';
import fetchPickListValue from '@salesforce/apex/CARE_CommunicationModController.fetchPickListValue';
import getCommDetails from '@salesforce/apex/CARE_CommunicationModController.getCommDetails';
import saveCommDetails from '@salesforce/apex/CARE_CommunicationModController.saveCommDetails';
import getLangDetails from '@salesforce/apex/CARE_CommunicationModController.getLangDetails';
import saveLangDetails from '@salesforce/apex/CARE_CommunicationModController.saveLangDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';

//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import PREFERRED_CONTACT_METHOD__c_FIELD from '@salesforce/schema/Account.PREFERRED_CONTACT_METHOD__c';
import Id_FIELD from '@salesforce/schema/Account.Id';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LANGUAGE_SOURCE from '@salesforce/schema/Account.Languages_Other_Than_English_EI__c';
import {
    CurrentPageReference
} from 'lightning/navigation';

export default class ModalLwc extends LightningElement {
    @track bShowModal = false;
    @track cShowModal = false;
    @track dShowModal = false;
    showLoadingSpinner = false;
    @api sSelectedPerId;
    @api listSelectedPremIds = [];

    @track error;
    @track phoneDetails = {
        home: '',
        work: '',
        mobile: ''
    }

    @track pickListValues;
    @api Id;
    //@api Billing_Person_ID_EI__c;
    @track selectedVal =  [{'Id':'','PREFERRED_CONTACT_METHOD__c':''}];
    @track communication = {
        id: '',
        contactMethod: ''
    }

    @track saveLanguage = {
        id: '',
        lang: ''
    }

    @track fetchLanguage = {
        id: '',
        selectedLang: ''
    }



    /* javaScript functions start */

    @wire(fetchPickListValue, {
        objInfo: { 'sobjectType': 'Account' },
        picklistFieldApi: 'PREFERRED_CONTACT_METHOD__c'
    }) commPicklistValues;




    onValueSelection(event) {
        // eslint-disable-next-line no-alert
        //this.hasDefaultResults = false;
        /*this.accObj.id  = this.selectVal.data[0].Id;
        this.accObj.contactMethod  = event.target.value;
        console.log('Check msg value here===> ', this.selectVal.data); 
        console.log('ids---> ',this.selectVal.data[0].Id);*/
        this.communication.contactMethod = event.target.value;
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: LANGUAGE_SOURCE
    })
    wiredPickListValue({ data, error }) {
        if (data) {
            console.log(` Picklist values are `, data.values);
            this.pickListValues = data.values;
            this.error = undefined;
            console.log(` Picklist values`, this.pickListValues);
        }
        if (error) {
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.pickListValues = undefined;
        }
    }


    openModal() {
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
        this.showLoadingSpinner = true;

        getPhoneDetails({ selectedPerId: this.sSelectedPerId })
        .then(data => {
            // console.log('result==>' + JSON.stringify(result)); 

            this.phoneDetails.home = data[0].phone1;
            this.phoneDetails.work = data[0].phone2;
            this.phoneDetails.mobile = data[0].mobile1;
            console.log('Data1:', data);
            data = [];
           
            this.showLoadingSpinner = false;

        })
        .catch(error => {
            this.error = error;
            this.showLoadingSpinner = false;

        });

        
    }

    closeModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
        this.phoneDetails = {
            home: '',
            work: '',
            mobile: ''
        };

    }

    openCommunicationModal() {
        // to open modal window set 'bShowModal' tarck value as true
        this.cShowModal = true;
        this.showLoadingSpinner = true;
        getCommDetails({ selectedPerId: this.sSelectedPerId })
        .then(data => {
            if(data.hasOwnProperty(0)){
                this.selectedVal = data;
            }else{
                this.selectedVal = [{'Id':'','PREFERRED_CONTACT_METHOD__c':''}];
            }
           
            this.hasDefaultResults = true;
           
            this.showLoadingSpinner = false;

        })
        .catch(error => {
            this.error = error;
            this.showLoadingSpinner = false;

        });
    }

    closeCommunicationModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.cShowModal = false;
    }

    openLanguageModal() {
        // to open modal window set 'bShowModal' tarck value as true
        this.dShowModal = true;
        this.showLoadingSpinner = true;
        getLangDetails({ selectedPerId: this.sSelectedPerId })
        .then(data => {
            if(data.hasOwnProperty(0)){
                this.fetchLanguage.id = data[0].Id;
                this.fetchLanguage.selectedLang = data[0].Languages_Other_Than_English_EI__c;
                console.log('Fetched data:',data);
                /*console.log('Fetched id:', data[0].id);
                console.log('Fetched lang:', data[0].lang);*/
                console.log('Fetched lang id:', this.fetchLanguage.id);
                console.log('Fetched lang selectedLang:', this.fetchLanguage.selectedLang);
              
            }
           
           
           
            this.showLoadingSpinner = false;

        })
        .catch(error => {
            this.error = error;
            this.showLoadingSpinner = false;

        });


    }

    closeLanguageModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.dShowModal = false;
    }
    saveAndClose(event) {
        console.log('Save and close method value1:', this.phoneDetails.home);
        console.log('Save and close method value2:', this.phoneDetails.work);
        console.log('Save and close method value3:', this.phoneDetails.mobile);
        /*console.log('Saved Work Phone:',this.work);
        console.log('Saved Mobile Phone:',this.mobile); */
       
        this.showLoadingSpinner = true;
        savePhoneDetails({ updatePhoneRec: this.phoneDetails, perIdValue : this.sSelectedPerId })
            .then(result => {
                console.log('resultafterApex call==>' + JSON.stringify(result));

                if (result) {
                    //this.sReason = null;
                    //this.bFormEdited = false;
                    this.showToastMessage('Success', 'Successfully Saved details ', 'success');
                    //this.bShowModal = false;
                    
                    this.showLoadingSpinner = false;
                    
                }
                else {
                    this.showToastMessage('Application Error', ' Please try after sometime.', 'error');
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                //this.error = error.body.message;
                this.showToastMessage('Application Error', 'Internal Error', 'error');
                this.showLoadingSpinner = false;
            });



    }

    saveCommunicationModal(event) {
        //console.log('communication.Id---> ',this.communication.id);
        console.log('Selected Communication picklist value: ', this.communication.contactMethod);
        this.showLoadingSpinner = true;
        saveCommDetails({ updateCommRec: this.communication.contactMethod, perIdValue : this.sSelectedPerId })
        .then(result => {
            console.log('resultafterApex call==>' + JSON.stringify(result));

            if (result) {
                //this.sReason = null;
                //this.bFormEdited = false;
                this.showToastMessage('Success', 'Successfully Saved details ', 'success');
                //this.bShowModal = false;
                
                this.showLoadingSpinner = false;
                
            }
            else {
                this.showToastMessage('Application Error', ' Please try after sometime.', 'error');
                this.showLoadingSpinner = false;
            }
        })
        .catch(error => {
            //this.error = error.body.message;
            this.showToastMessage('Application Error', 'Internal Error', 'error');
            this.showLoadingSpinner = false;
        });


    }

    saveLanguageModal(event) {
        //console.log('accObj.Id---> ',this.accObj.id);
        console.log('Selected Language picklist value: ', this.saveLanguage.lang);
        this.showLoadingSpinner = true;
        saveLangDetails({ updateLangRec: this.saveLanguage.lang, perIdValue : this.sSelectedPerId }).then(result => {
            console.log('resultafterApex call==>' + JSON.stringify(result));

            if (result) {
                //this.sReason = null;
                //this.bFormEdited = false;
                this.showToastMessage('Success', 'Successfully Saved details ', 'success');
                //this.bShowModal = false;
                
                this.showLoadingSpinner = false;
                
            }
            else {
                this.showToastMessage('Application Error', ' Please try after sometime.', 'error');
                this.showLoadingSpinner = false;
            }
        })
        .catch(error => {
            //this.error = error.body.message;
            this.showToastMessage('Application Error', 'Internal Error', 'error');
            this.showLoadingSpinner = false;
        });


    }

    /* saveCommunicationModal(event) {
         saveCommunicationDetails({ upRec2: this.comDetails })
         console.log('Save Communication value:', this.comDetails);
 
     } */
    handleChangeHome(event) {
        this.phoneDetails.home = event.target.value;
    }
    handleChangeWork(event) {
        this.phoneDetails.work = event.target.value;
    }
    handleChangeMobile(event) {
        this.phoneDetails.mobile = event.target.value;
    }
    handleChangeLanguage(event) {
        this.saveLanguage.lang = event.target.value;
    }
    /* try {
         let response = await getAllPosts();
     } catch(e) {
         console.log(e);
     } */

    /*handleChangeCommunication(event) {
        this.comDetails = event.target.value;
    } */
    /* javaScript functions end */

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