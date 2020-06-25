import { LightningElement, track, api } from 'lwc';
import getListOfStrings from '@salesforce/apex/CARE_SearchController.getListOfStrings';

export default class Care_SearchAutoComplete extends LightningElement {
    @api idOfRec; //ids of record
    @track searchKey = '';
    @track listOfRec = [];
    @api error;
    @api objectApiName;
    @api fieldApiName;
    @api inputLabel;
    @api name;
    listRecordsSession = [];

    //public method
    @api handleClearFields() {
        this.searchKey = '';
    }

    get showListBox() {
        return this.listOfRec.length > 0;
        //return true;
    }

    //On typing, this method is called to fetch the data from database
    handleKeyChange(event) {
        this.listOfRec = '';
        const search = event.target.value;
        const eventTyping = new CustomEvent("handletyping", {
            detail: search   //here we are storing the text to parent variable when the text length is less than three
        });
        this.dispatchEvent(eventTyping);
        let bSessionFlag = false;
        let sField = this.fieldApiName;

        if (search.length >= 0) {

            if (search.length === 0) {
                this.searchKey = '';
                //this.listOfRec = ''; //refreshing the accout value
            }
           
            bSessionFlag = (sField == "Billing_Account_ID_EI__c" || sField == "SAID_EI__c" || sField == "Person_ID_EI__c" || sField == "Site_Premise_ID_EI__c")?true:false;
            this.searchKey = search;
            //console.log('search==>' + search + '==obj==>'+ this.objectApiName + '==fld==>'+ this.fieldApiName);
            if(search.length === 0 || search.length === 10){
                getListOfStrings({
                    searchKey: this.searchKey,
                    objectApiName: this.objectApiName,
                    fieldApiName: this.fieldApiName
                })
                    .then(result => {
                        console.log('result==>' + JSON.stringify(result));
                        this.listOfRec =  (search.length === 0)?result.listResultsSession:result.listResults;
                        if(search.length === 0)
                        this.listRecordsSession = result.listResultsSession;
                        console.log("this.listOfRec" + JSON.stringify(this.listOfRec));
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }else if(this.listRecordsSession.length > 0 && this.searchKey.length > 0 && bSessionFlag){
                let listTemp  =  this.listRecordsSession;
                this.listOfRec = listTemp.filter(item => item.toLowerCase().indexOf(this.searchKey) == 0);
                console.log("this.listOfRec Session Data" + JSON.stringify(this.listOfRec));
            }
        }
        else {
            this.listOfRec = '';// last change
        }
        this.idOfRec = '';   //refreshing id of record selected
    }

    //On selecting the record, this method is called to fire an event to the parent, to send the selected value in detail
    handleOnClick(event) {
        console.log("onclick");

            this.idOfRec = event.currentTarget.dataset.item;
            this.searchKey = this.idOfRec;
            //console.log("event.currentTarget.dataset.item",event.currentTarget.dataset.item); 
            const selectedEvent = new CustomEvent("recordselect", {
                detail: this.idOfRec
            });
            this.dispatchEvent(selectedEvent);
       
            this.listOfRec = '';
              


        
    }

    //This is called on keypress
    lastSpace(event) {
        if (this.idOfRec) {
            if (event.which === 32) {
                event.preventDefault();
                return false;
            }
        }
    }

    //Make the list blank and hide the list when focus is removed
    handleOnBlur(event) {
       /* let sInputVal = event.target.value;
        if(this.searchKey.length == 10 && sInputVal.length < 10){
            this.listOfRec =  '';
        }
        */
       console.log("Blur");
       this.listOfRec =  '';
        
    }
}