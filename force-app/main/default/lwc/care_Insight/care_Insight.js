import { LightningElement, track, api } from 'lwc';

export default class careInsight extends LightningElement {
    @track bRes = true;
    setResidentialTabFlag(event) {
        if(event.target.label == 'Residential'){
           this.bRes = true;
           if(this.template.querySelector('.resTab') != null){
            this.template.querySelector('.resTab').handleClear();   
           }
        }else{
           this.bRes = false;
           if(this.template.querySelector('.nonResTab') != null){
            this.template.querySelector('.nonResTab').handleClear();   
           }
        }
        
    }
}