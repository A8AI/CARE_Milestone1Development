import {LightningElement, wire, api, track} from 'lwc';

// importing apex class methods
//import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getRelatedSA from '@salesforce/apex/care_EnrollTabController.getRelatedSA';
//import getPfTaskDetails from '@salesforce/apex/pFStories_Controller.getPfTaskDetails';
import { refreshApex } from '@salesforce/apex';

/*const actions = [
    { label: 'Show details', name: 'show_details' },
];*/

// datatable columns with row actions
const columns = [

    {label: 'SA ID', fieldName: 'saID', type: 'text'},
    //{label: 'Application ID', fieldName: 'Name', type: 'text'},
     
    {label: 'SA Type', fieldName: 'saType',type: 'text'},
    
    {label: 'Yes Date', fieldName: 'yesDate',type: 'date'},
    
    {label: 'No Date', fieldName: 'noDate',type: 'date'},

    {label: 'Retro Yes date', fieldName: 'yesDate',type: 'date'},

    {label: 'Retro No Date', fieldName: 'noDate',type: 'date'},
    
    //{label: 'Incentive Amt', fieldName: 'incentiveAmt',type: 'number', cellAttributes: { alignment: 'left' }},
    
    {label: 'CC&B SA Start Date', fieldName: 'yesDate',type: 'date'},

    {label: 'Last Bill Date', fieldName: 'yesDate',type: 'date'},

];

export default class DataTableLWC extends LightningElement { 
    // reactive variable
    @track data = [];
    @track columns = columns;
    @track select;
    @track row = [];
    @track record;
    @track showLoadingSpinner = true;
    //@track whichOne;
    @track selectedRows = [];
    @track selectIds = [];
    @track result = [];
    @track taskdata;
    @track error;
    @track items = []; //this will hold key, value pair
    @track value = ''; //initialize combo box value
    //@track chosenValue = '';
    @track value1 = 'new';
    
	/** Wired Apex result so it can be refreshed programmatically */
    _wiredSolarProjectResult;
	
    //@wire(getproject , {solarId:'$recordId' })
      @wire(getRelatedSA)
      wiredsolarProjectRes(resp) {
        this._wiredSolarProjectResult = resp;
        const { data, error } = resp;
        
		if(data) {

            //this.opporunity = data;
            this.data = data;
            //this.error = undefined;
             
            if(this.data){
                this.showLoadingSpinner = false;
            }
            
        }
        else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    

    refreshData() {
        return refreshApex(this._wiredSolarProjectResult);
    }

}