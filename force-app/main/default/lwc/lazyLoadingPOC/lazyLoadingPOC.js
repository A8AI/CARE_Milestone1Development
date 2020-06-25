import { LightningElement, track, wire } from 'lwc';
import initRecords from '@salesforce/apex/LazyLoadingControllerPOC.initRecords';

const columns = [{label: 'Send/Rcv Date',fieldName: 'dReceiveDate', type: 'date',
                        typeAttributes: {day: "numeric", month: "numeric",year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Transaction Number', fieldName: 'sApplicationName',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Contact',fieldName: 'sContact',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Discount Type',fieldName: 'sDiscountType',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Status',fieldName: 'sApplicationStatus',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'SA ID', fieldName: 'sSAID', type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'SA Type',fieldName: 'sSAType',type: 'text',
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'Yes date', fieldName: 'dStartDate', type: 'date', 
                        typeAttributes: {day: "numeric", month: "numeric", year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {label: 'No Date',fieldName: 'dEndDate',type: 'date',
                        typeAttributes: {day: "numeric",month: "numeric", year: "numeric"},
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
               //{ label: 'CC&B Comment', fieldName: 'sCCBComment', type: 'text', cellAttributes: { class: { fieldName: 'sFormatText' }}},
                {label: 'App Source', fieldName: 'sAppSource', type: 'text', 
                        cellAttributes: {class: {fieldName: 'sFormatText'}}},
                {type: "button", 
                        typeAttributes: {label: 'View', name: 'View', title: 'View',
                                        disabled: false, value: 'view', iconPosition: 'left',
                        class: {fieldName: 'sViewButton'}}},
                {type: "button",
                        typeAttributes: {label: 'Msg', name: 'Msg', title: 'Msg',
                                        disabled: false, value: 'Msg', iconPosition: 'left',}},
                {type: "button",
                        typeAttributes: {label: 'Delete', name: 'Delete', title: 'Delete',
                                        disabled: {fieldName: 'bDeleteButton'},value: 'Delete',iconPosition: 'left'}}
                ];

export default class LazyLoadingPOC extends LightningElement {

  @track data = [];
  @track columns = columns;
  @track loadMoreStatus;
  @track totalCount = 0;
  tableElement;
  @track bIsLoaded = true;

  @wire(initRecords, { recordId: ''})
  wiredHistoryResp(resp) {
    this._wiredHistoryResult = resp;
    const {data,error} = resp;

    if (data) {
        this.data = data.listHistoryWrapper;
        this.totalCount = data.iTotalRecCount;
        console.log('total listHistoryWrapper data length ------->' , this.data.length);
        console.log('total count of select clause ------->' , this.totalCount);
        //this.totalCount = 30;
        this.error = undefined;

    } else if (error) {
        this.error = error;
        this.data = undefined;
    }
}

loadMoreData(event) {
    //Display a spinner to signal that data is being loaded
    //Display "Loading" when more data is being loaded
    //event.target.isLoading = true;
    if(event.target){
        event.target.isLoading = true;
    }
    this.tableElement = event.target;
    this.loadMoreStatus = 'Loading';
    const currentRecord = this.data;
    const lastRecId = currentRecord[currentRecord.length - 1].sId;
    console.log('lastRecId ------->' + lastRecId);
    initRecords({ recordId: lastRecId})
    .then(result => {
        console.log('result length before concat ------->' + result.listHistoryWrapper.length);
        //console.log('result with recordID ------->' + JSON.stringify(result));
        const currentData = result.listHistoryWrapper;
        //Appends new data to the end of the table
        const newData = currentRecord.concat(currentData);
        this.data = newData;
        console.log('data length after concat ------->' + this.data.length); 
        if (this.data.length >= this.totalCount) {
        console.log('Inside If block of LoadMoreData'); 
            this.bIsLoaded = false;
            //event.target.enableInfiniteLoading = false;
            this.loadMoreStatus = 'No more data to load';
        } else {
            console.log('Inside else block of LoadMoreData'); 
            this.loadMoreStatus = '';
        }
        if(this.tableElement){
            this.tableElement.isLoading = false;
        } 
    })
    .catch(error => {
        console.log('-------error-------------'+error);
        console.log(error);
    });
}
}
