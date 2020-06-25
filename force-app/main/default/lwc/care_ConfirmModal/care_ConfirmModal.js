import { LightningElement, api } from 'lwc';

export default class Care_ConfirmModal extends LightningElement {

    @api headerText;
    @api bodyText;
    @api footerYesText;
    @api footerNoText;

    handleNoClick() {
        // Create the event with the data.
        const selectedNoEvent = new CustomEvent("nobuttonevent", {
            detail: {showChildModal: false}
        });
        // Dispatches the event.
        this.dispatchEvent(selectedNoEvent);
    }

    handleYesClick() {
        // Creates the event with the data.
        const selectedYesEvent = new CustomEvent("yesbuttonevent", {
            detail: {showChildModal: false, showParentModal: false, }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedYesEvent);
    }
}