import { LightningElement, track, api, wire } from 'lwc';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import fatchPickListValue from '@salesforce/apex/care_EnrollTabController.fatchPickListValue';
//import SOURCE_CHANNEL_TYPE from '@salesforce/schema/CARE_Application__c.SOURCE_CHANNEL_TYPE__c';

export default class lwcCmpName extends LightningElement {

    @track channelOptions;
    @track error;
    @track values;
    @track adultChange;
    @track data;

   /* @wire(getPicklistValues, {
        recordTypeId : '012000000000000AAA',
        fieldApiName : SOURCE_CHANNEL_TYPE
    })
        wiredPickListValue({ data, error }){
            if(data){
                console.log(` Picklist values are `, data);
                this.channelOptions = data.values;
                alert(this.channelOptions);
                alert(data.values);
                alert(data);

                this.error = undefined;
            }
            if(error){
                console.log(` Error while fetching Picklist values  ${error}`);
                this.error = error;
                this.channelOptions = undefined;
            }
        }*/
    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'CARE_Application__c'},
                picklistFieldApi: 'SOURCE_CHANNEL_TYPE__c'}) stageNameValues;
 
    onValueSelection(event){
  // eslint-disable-next-line no-alert
        alert(event.target.value);
    }           
    

    handleAdultChange(event){
        this.adultChange = event.target.value;
        alert(event.target.value);
    }
}
