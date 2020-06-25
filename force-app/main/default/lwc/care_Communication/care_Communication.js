import { LightningElement, track, wire, api } from 'lwc';
import getPhoneDetails from '@salesforce/apex/CARE_CommunicationController.getPhoneDetails';
import savePhoneDetails from '@salesforce/apex/CARE_CommunicationController.savePhoneDetails';
import fetchPickListValue from '@salesforce/apex/CARE_CommunicationController.fetchPickListValue';
import getCommDetails from '@salesforce/apex/CARE_CommunicationController.getCommDetails';
import saveCommDetails from '@salesforce/apex/CARE_CommunicationController.saveCommDetails';
import getLangDetails from '@salesforce/apex/CARE_CommunicationController.getLangDetails';
import saveLangDetails from '@salesforce/apex/CARE_CommunicationController.saveLangDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LANGUAGE_SOURCE from '@salesforce/schema/Account.Languages_Other_Than_English_EI__c';
import { phoneMask } from 'c/care_Utilities';

export default class Care_Communication extends LightningElement {
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

    @track maskedPhoneDetails = {
        home: '',
        work: '',
        mobile: ''
    }

    @track pickListValues;
    @api Id;
    @track selectedVal = [{ 'Id': '', 'PREFERRED_CONTACT_METHOD__c': '' }];
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

    @wire(fetchPickListValue, {
        objInfo: { 'sobjectType': 'Account' },
        picklistFieldApi: 'PREFERRED_CONTACT_METHOD__c'
    }) commPicklistValues;




    onValueSelection(event) {
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
        this.bShowModal = true;
        this.showLoadingSpinner = true;

        getPhoneDetails({ selectedPerId: this.sSelectedPerId })
            .then(data => {
                this.maskedPhoneDetails.home = phoneMask(data[0].phone1);
                this.maskedPhoneDetails.work = phoneMask(data[0].phone2);
                this.maskedPhoneDetails.mobile = phoneMask(data[0].mobile1);
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
        this.bShowModal = false;
        this.phoneDetails = {
            home: '',
            work: '',
            mobile: ''
        };

    }

    openCommunicationModal() {
        this.cShowModal = true;
        this.showLoadingSpinner = true;
        getCommDetails({ selectedPerId: this.sSelectedPerId })
            .then(data => {
                if (data.hasOwnProperty(0)) {
                    this.selectedVal = data;
                } else {
                    this.selectedVal = [{ 'Id': '', 'PREFERRED_CONTACT_METHOD__c': '' }];
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
        this.cShowModal = false;
    }

    openLanguageModal() {
        this.dShowModal = true;
        this.showLoadingSpinner = true;
        getLangDetails({ selectedPerId: this.sSelectedPerId })
            .then(data => {
                if (data.hasOwnProperty(0)) {
                    this.fetchLanguage.id = data[0].Id;
                    this.fetchLanguage.selectedLang = data[0].Languages_Other_Than_English_EI__c;
                    console.log('Fetched data:', data);
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
        this.dShowModal = false;
    }
    saveAndClose(event) {
        console.log('Save and close method value1:', this.maskedPhoneDetails.home);
        console.log('Save and close method value2:', this.maskedPhoneDetails.work);
        console.log('Save and close method value3:', this.maskedPhoneDetails.mobile);

        if(this.maskedPhoneDetails.home !== '' && this.maskedPhoneDetails.home !== undefined && this.maskedPhoneDetails.home !== null){
            this.phoneDetails.home = this.maskedPhoneDetails.home.replace(/\D/g,''); //remove mask
        }
        else{
            this.phoneDetails.home = '';
        }    
        if(this.maskedPhoneDetails.work !== '' && this.maskedPhoneDetails.work !== undefined && this.maskedPhoneDetails.work !== null){
            this.phoneDetails.work = this.maskedPhoneDetails.work.replace(/\D/g,''); //remove mask
        }
        else{
            this.phoneDetails.work = '';
        } 
        if(this.maskedPhoneDetails.mobile !== '' && this.maskedPhoneDetails.mobile !== undefined && this.maskedPhoneDetails.mobile !== null){
            this.phoneDetails.mobile = this.maskedPhoneDetails.mobile.replace(/\D/g,''); //remove mask
        }
        else{
            this.phoneDetails.mobile = '';
        } 

        console.log('Save and close method value1:', this.phoneDetails.home);
        console.log('Save and close method value2:', this.phoneDetails.work);
        console.log('Save and close method value3:', this.phoneDetails.mobile);

        this.showLoadingSpinner = true;
        savePhoneDetails({ updatePhoneRec: this.phoneDetails, perIdValue: this.sSelectedPerId })
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
                this.showToastMessage('Application Error', 'Internal Error', 'error');
                this.showLoadingSpinner = false;
            });



    }

    saveCommunicationModal(event) {
        console.log('Selected Communication picklist value: ', this.communication.contactMethod);
        this.showLoadingSpinner = true;
        saveCommDetails({ updateCommRec: this.communication.contactMethod, perIdValue: this.sSelectedPerId })
            .then(result => {
                console.log('resultafterApex call==>' + JSON.stringify(result));

                if (result) {
                    this.showToastMessage('Success', 'Successfully Saved details ', 'success');
                    this.showLoadingSpinner = false;

                }
                else {
                    this.showToastMessage('Application Error', ' Please try after sometime.', 'error');
                    this.showLoadingSpinner = false;
                }
            })
            .catch(error => {
                this.showToastMessage('Application Error', 'Internal Error', 'error');
                this.showLoadingSpinner = false;
            });


    }

    saveLanguageModal(event) {
        console.log('Selected Language picklist value: ', this.saveLanguage.lang);
        this.showLoadingSpinner = true;
        saveLangDetails({ updateLangRec: this.saveLanguage.lang, perIdValue: this.sSelectedPerId }).then(result => {
            console.log('resultafterApex call==>' + JSON.stringify(result));

            if (result) {
                this.showToastMessage('Success', 'Successfully Saved details ', 'success');
                this.showLoadingSpinner = false;

            }
            else {
                this.showToastMessage('Application Error', ' Please try after sometime.', 'error');
                this.showLoadingSpinner = false;
            }
        })
            .catch(error => {
                this.showToastMessage('Application Error', 'Internal Error', 'error');
                this.showLoadingSpinner = false;
            });


    }

    handleChangeHome(event) {
        this.maskedPhoneDetails.home = phoneMask(event.target.value);
    }
    handleChangeWork(event) {
        this.maskedPhoneDetails.work = phoneMask(event.target.value);
    }
    handleChangeMobile(event) {
        this.maskedPhoneDetails.mobile = phoneMask(event.target.value);
    }
    handleChangeLanguage(event) {
        this.saveLanguage.lang = event.target.value;
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

}