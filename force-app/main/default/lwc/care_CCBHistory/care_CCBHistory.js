import { LightningElement,api,wire,track } from 'lwc';
import getCCBHistory from '@salesforce/apex/CARE_CCBHistoryController.getCCBHistory';
 
export default class ModalLwc extends LightningElement {
     @api sSelectedCCBPerId;
     @track bShowModal = false;
    

     @track columns = [{
        label: 'Send/Rcv Date',
        fieldName: 'dttm',
        type: 'date-local',
        typeAttributes:{day:"2-digit",month:"2-digit"},
        sortable: true
    },
    {
        label: 'Discount Type',
        fieldName: 'cl_cd',
        type: 'text',
        sortable: true
    },
    {
        label: 'SA ID',
        fieldName: 'sa_id',
        type: 'text',
        sortable: true
    },
    {
        label: 'SA Type',
        fieldName: 'sa_type',
        type: 'text',
        sortable: true
    },
    {
        label: 'Yes Date',
        fieldName: 'date1',
        type: 'date-local',
        typeAttributes:{day:"2-digit",month:"2-digit"},
        sortable: true
    },
    {
        label: 'No Date',
        fieldName: 'date2',
        type: 'date-local',
        typeAttributes:{day:"2-digit",month:"2-digit"},
        sortable: true
    },
    {
        label: 'Contact',
        fieldName: 'cc_type_cd',
        type: 'text',
        sortable: true
    },
    {
        label: 'Transaction',
        fieldName: 'descr',
        type: 'text',
        sortable: true
    },
    {
        label: 'Committed By',
        fieldName: 'userid',
        type: 'text',
        sortable: true
    }
];

@track error;
@track ccbHistoryList ;
@track data = [] ;
@wire(getCCBHistory,{sPerID:'$sSelectedCCBPerId'})
wiredAccounts({
    error,
    data
}) {
    if (data) {
        //this.ccbHistoryList = data;
        this.data = data;
        this.error = undefined
        console.log('CCb history data' + data);
        console.log('CCb history data Stringify' + JSON.stringify(data));
    } else if (error) {
        this.error = error;
            this.data = undefined;
    }
} 
 
    /* javaScipts functions start */ 
    openModal() {    
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }
 
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    get checkCCBHistoryData() {
        return this.data.length > 0;
    }
    /* javaScipt functions end */ 
}