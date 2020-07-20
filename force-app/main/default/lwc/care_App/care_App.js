import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomerList from '@salesforce/apex/CARE_SearchController.getCustomerList';
import { phoneMask } from 'c/care_Utilities';

import SearchFieldMissingMsg from '@salesforce/label/c.CARE_SearchFieldMissingMsg';
import InvalidPersonIdMsg from '@salesforce/label/c.CARE_InvalidPersonIdMsg';
import CARE_RecordsCustNotFound from '@salesforce/label/c.CARE_RecordsCustNotFound';
import CARE_NoCitySearchAllowMsg from '@salesforce/label/c.CARE_NoCitySearchAllowMsg';
import CARE_ValidValuesMsg from '@salesforce/label/c.CARE_ValidValuesMsg';	

// datatable columns
const columns = [
    { label: 'Customer Name', fieldName: 'sCustName', type: 'text', sortable: true, initialWidth: 140 },
   
    { label: 'Per ID', fieldName: 'sPerId', type: 'text', sortable: true,initialWidth: 100 },
    { label: 'Acct ID', fieldName: 'sAccId', type: 'text', sortable: true,initialWidth: 100 },
    { label: 'Prem ID', fieldName: 'sPremId', type: 'text', sortable: true,initialWidth: 100 },
    { label: 'SA ID', fieldName: 'sSAId', type: 'text', sortable: true,initialWidth: 100 },
    { label: 'SA Type', fieldName: 'sSAType', type: 'text', sortable: true, initialWidth: 10 },
    { label: 'SA Status', fieldName: 'sSAStatus', type: 'text', sortable: true, initialWidth: 10 },
    { label: 'Res/Non Res', fieldName: 'sResNonRes', type: 'text', sortable: true, initialWidth: 10 },
    { label: 'FH Type', fieldName: 'sFHType', type: 'text', sortable: true,initialWidth: 10 },
    { label: 'Discount', fieldName: 'sDiscount', type: 'text', sortable: true, initialWidth: 10 },
    { label: 'Rate', fieldName: 'sRate', type: 'text', sortable: true },
    { label: 'Service Address', fieldName: 'sSvcAddr', type: 'text',initialWidth: 150, wrapText:true, sortable: true,  typeAttributes: { label: {fieldName: 'sSvcAddr'}} },
    { label: 'Facility/Housing Org', fieldName: 'sFacility', type: 'text', sortable: true },
    { label: 'Space Unit', fieldName: 'sSpaceUnit', type: 'text', sortable: true },
    { label: 'Probation', fieldName: 'sProbation', type: 'text', sortable: true }
];



export default class Care_App extends LightningElement {
    @track searchData = null;
    @track searchDataSliced = null;
    @track columns = columns;
    @track errorMsg = '';
    sHistoryRefresh = 'firstCall';
    //@track strSearchAccName;// to be removed
    @track selectedRows1 = [];
    @track selectedRowsId = '';
    @track searchInput = {
        sAccountID: '',
        sPersonID: '',
        sPremiseID: '',
        bInactiveCustomer: false,
        sSAID: '',
        sName: '',
        sPhone: '',
        sStreet: '',
        sCity: '',
        sZip: '',
        sSpace: '',
        bMFHC: false,
        sFacilityHousing: '',
        bEnrolledTenant: false,
        bProbation: false
    };
    @track showLoadingSpinner = false;
    @track personIdList = [];
    @track page = 1; //this is initialize for 1st page
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 10; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @api bCustomerDetailFlag  = false;
    @api sSelectedPersonId;
    @api listSelectedPremId;
    listActiveSections = ["SearchForm"];
    sSelectedEIAccountId ='';
    sSelectedBillingAccId = '';
    sSelectedCustName = '';
    sSelectedProbStatus = false;
    @api bCallFromModal = false;
    sortedBy = 'sAccId';
    sortedDirection = 'asc';
    @track maskedPhone;

    label = {
        SearchFieldMissingMsg,
        InvalidPersonIdMsg,
        CARE_NoCitySearchAllowMsg,
        CARE_ValidValuesMsg,
        CARE_RecordsCustNotFound
    };

    showToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleSectionToggle(event){
        this.listActiveSections = event.detail.openSections;
    }

    //////////////////
    //On selecting the record from the child lwc (same used in different place), 
    //the values are captured in the specific track fields.
    //The 'name' attribute is used to identify the controlling fields in the parent lwc
    handleRecordSelection(event) {
        let elemName = event.target.name;
        console.log("event",event);
        switch (elemName) {
            case 'accountField':
                this.searchInput.sAccountID = event.detail.trim();
                break;
            case 'SAIDField':
                this.searchInput.sSAID = event.detail.trim();
                break;
            case 'personField':
                this.searchInput.sPersonID = event.detail.trim();
                break;
            case 'premiseField':
                this.searchInput.sPremiseID = event.detail.trim();
                break;
            default:
        }
    }

    //On typing in the field from the child lwc (same used in different place), 
    //the values are captured in the specific track fields.
    //The 'name' attribute is used to identify the controlling fields in the parent lwc
    handletyping(event) {
        let elemName = event.target.name;
        switch (elemName) {
            case 'accountField':
                this.searchInput.sAccountID = event.detail.trim();
                break;
            case 'SAIDField':
                this.searchInput.sSAID = event.detail.trim();
                break;
            case 'personField':
                this.searchInput.sPersonID = event.detail.trim();
                break;
            case 'premiseField':
                this.searchInput.sPremiseID = event.detail.trim();
                break;
            default:
        }
    }

    //On focusout from the field (other than child lwc), the values are captured in the specific track fields.
    //The 'data-id' attribute is used to identify the controlling fields in the parent lwc
    handleChange(event) {
        var value;
        if (event.target.type === 'checkbox') {
            value = event.target.checked;
        } else {
            value = event.target.value.trim();
        }

        let datasetId = event.target.dataset.id;
        switch (datasetId) {
            case 'custNameField':
                this.searchInput.sName = value;
                break;
            case 'phoneField':
                //this.searchInput.sPhone = value;
                this.maskedPhone = phoneMask(value);
                break;            
            case 'streetField':
                this.searchInput.sStreet = value;
                break;
            case 'spaceField':
                this.searchInput.sSpace = value;
                break;
            case 'cityField':
                this.searchInput.sCity = value;
                break;
            case 'zipField':
                this.searchInput.sZip = value;
                break;
            case 'facilityField':
                this.searchInput.sFacilityHousing = value;
                break;
            case 'inactiveCustField':
                this.searchInput.bInactiveCustomer = value;
                break;
            case 'probationField':
                this.searchInput.bProbation = value;
                break;
            case 'enrolledTenField':
                this.searchInput.bEnrolledTenant = value;
                break;
            case 'mfhcField':
                this.searchInput.bMFHC = value;
                break;
            default:
        }
    }

    get showCustomerList() {
        return this.searchData.length > 0;
    }

    //This method is called when Search button is clicked
    handleSearch() {
        this.bCustomerDetailFlag = false; //hide customer details section

        if(this.maskedPhone !== '' && this.maskedPhone !== undefined && this.maskedPhone !== null){
            this.searchInput.sPhone = this.maskedPhone.replace(/\D/g,''); //remove mask
        }
        else{
            this.searchInput.sPhone = '';
        }       

        //If none of the fields are entered, throw error message
        if (this.searchInput.sAccountID === '' && this.searchInput.sPersonID === '' && this.searchInput.sPremiseID === '' && this.searchInput.sSAID === '' && this.searchInput.sName === ''
            && this.searchInput.sPhone === '' && this.searchInput.sStreet === '' && this.searchInput.sCity === '' && this.searchInput.sZip === '' && this.searchInput.sFacilityHousing === '') {
            //this.showToast("Please enter atleast one field.");
            this.showToast(this.label.SearchFieldMissingMsg);
        }
        else if(this.searchInput.sCity !== '' && (this.searchInput.sAccountID === '' && this.searchInput.sPersonID === '' && this.searchInput.sPremiseID === '' && this.searchInput.sSAID === '' && this.searchInput.sName === ''
        && this.searchInput.sPhone === '' && this.searchInput.sStreet === '' && this.searchInput.sZip === '' && this.searchInput.sFacilityHousing === '')){
            this.showToast(this.label.CARE_NoCitySearchAllowMsg);
            
        }else {

        //This is to check valid values in the Child LWC (Account Id, SAID, PerID, PremID)
        let childValidFlag = true;
        this.template.querySelectorAll('c-care_-search-auto-complete').forEach(elem => {
            elem.handleSubmitFields();
            if(!elem.checkInpulValidFlag){
                childValidFlag = false;
            }
            
        });

            //fetch the template input fields to check if all input values are valid
            const allInputValid = this.assignValidityFields();
            if(!allInputValid || !childValidFlag){
                this.showToast(this.label.CARE_ValidValuesMsg);
            }else{
                this.showLoadingSpinner = true;
                console.log('this.searchInput12==>' + JSON.stringify(this.searchInput));

                getCustomerList({ searchDetails: this.searchInput })
                    .then(result => {
                        console.log('result==>' + JSON.stringify(result));
                        if (result.success) {
                            this.searchData = result.listCustomers;
                            /*this.totalRecountCount = this.searchData.length;
                            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                            //slice will take 0th element and ends with 5, but it doesn't include 5th element
                            //so 0 to 4th rows will be display in the table
                            this.searchDataSliced = this.searchData.slice(0, this.pageSize);
                            this.endingRecord = this.pageSize;
                            */
                            this.showLoadingSpinner = false;
                            this.listActiveSections = ['SearchForm','CustomerList'];
                            this.template.querySelector(".setCustomerListIdClass").style.visibility = "visible";


                            
                        }
                        else {
                            this.error = (result.errorMessage !== '') ? result.errorMessage : "There is some technical error. Please try after sometime.";
                            this.showToast(error.body.message);
                            this.searchData = null;
                            this.showLoadingSpinner = false;
                            this.template.querySelector(".setCustomerListIdClass").style.visibility = "hidden";

                        }
                    })
                    .catch(error => {
                        this.error = error.body.message;
                        this.showToast(error.body.message);
                        this.searchData = null;
                        this.showLoadingSpinner = false;
                    });
            }
        }
    }

    assignValidityFields(){
        const allInputValidForm = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allInputValidForm;
    }

    //This method is called when Clear button is clicked
    handleClear() {
        //This is to clear all the input fields (text and checkbox)
        this.template.querySelectorAll('lightning-input').forEach(elem => {
            if (elem.type === 'checkbox') {
                elem.checked = false;
            } else {
                //UI fields
                elem.value = '';
            }
            elem.setCustomValidity("");
        });
        //This is to clear all the picklist
        this.template.querySelectorAll('lightning-combobox').forEach(elem => {
            elem.value = null;
        });

        this.assignValidityFields(); 


        //This is to clear the Child LWC (Account Id, SAID, PerID, PremID)
        this.template.querySelectorAll('c-care_-search-auto-complete').forEach(elem => {
            elem.handleClearFields();
            
        });
        //Actual fields
        this.searchInput = {
            sAccountID: '',
            sPersonID: '',
            sPremiseID: '',
            bInactiveCustomer: false,
            sSAID: '',
            sName: '',
            sPhone: '',
            sStreet: '',
            sCity: '',
            sZip: '',
            sSpace: '',
            bMFHC: false,
            sFacilityHousing: '',
            bEnrolledTenant: false,
            bProbation: false
        };
        this.maskedPhone = '';
    }

    //Pagination: Start

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //this method displays records page by page
    displayRecordPerPage(page) {
        /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
        page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
        so, slice(5,10) will give 5th to 9th records.
        */
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.searchDataSliced = this.searchData.slice(this.startingRecord, this.endingRecord);
        console.log('this.searchDataSliced',this.searchDataSliced);
        // this.dgdata1  = this.dgdata.slice(this.startingRecord, this.endingRecord);
        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
    }
    //Pagination: End




    //On row selection pass the Id to the child lwc for fetching the history record
    handleRowSelection(event) {
        let stringId = '';
        let listPersonId = []; 
        let listPremId = []
        let listPersonIdUnique = [];
        let selectedRows = event.detail.selectedRows;
        for (let cnt = 0; cnt < selectedRows.length; cnt++) {
            listPersonId.push(selectedRows[cnt].sPerId);
            listPremId.push(selectedRows[cnt].sPremId);
        } 
        this.bCustomerDetailFlag = selectedRows.length > 0 ?true:false;
        listPersonIdUnique = listPersonId.filter((item, i, ar) => ar.indexOf(item) === i);
        if(listPersonIdUnique.length > 1){
            this.bCustomerDetailFlag = false;
            //this.showToast("You can't select this SAID as it belongs to different Person ID. Please do reselection of all records of same person");
            this.showToast(this.label.InvalidPersonIdMsg);
        }
        this.sSelectedPersonId = listPersonIdUnique[0];
        if(selectedRows.length > 0){
            this.sSelectedEIAccountId = selectedRows[0].sEIAccountId;
            this.sSelectedBillingAccId = selectedRows[0].sAccId;
            this.sSelectedCustName = selectedRows[0].sCustName;
            this.sSelectedProbStatus = (selectedRows[0].sProbation == "Y")?true:false;
        }
        
        this.listSelectedPremId = listPremId.filter((item, i, ar) => ar.indexOf(item) === i);
        this.listActiveSections = ["SearchForm","CustomerList","CustomerDetails"];
        this.template.querySelector(".setCustomerDetailIdClass").style.visibility = (this.bCustomerDetailFlag)? "visible":"hidden";
        
    }

    refreshTabData(event) {
        if(event.target.label == 'History' || event.target.label == 'Enroll' || event.target.label == 'PEV'){
            //this.template.querySelector("c-care_-history").refreshData();
            this.sHistoryRefresh = new Date().toLocaleString();
        }

    }

    historyTabRefreshFromChild(event){
        if(event.detail == 'History'){
            this.sHistoryRefresh = new Date().toLocaleString();
        }
        
    }



    // The method onsort event handler
    updateColumnSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.searchData));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.searchData = parseData;

    }

}