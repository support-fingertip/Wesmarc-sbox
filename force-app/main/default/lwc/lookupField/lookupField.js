import { LightningElement, api, track } from 'lwc';
import findRecords from '@salesforce/apex/LookupFieldController.findRecords';

export default class LookupField extends LightningElement {
    @api objectApiName; // Example: 'Lead', 'Opportunity', etc.
    @api label = 'Search'; // Optional custom label

    @track searchKey = '';
    @track records = [];

    handleSearch(event) {
        this.searchKey = event.target.value;

        if (this.searchKey.length >= 2) {
            findRecords({ searchKey: this.searchKey, objectName: this.objectApiName })
                .then(result => {
                    this.records = result;
                })
                .catch(error => {
                    console.error('Lookup search error:', error);
                    this.records = [];
                });
        } else {
            this.records = [];
        }
    }

    handleSelect(event) {
        const selectedId = event.target.dataset.id;
        const selectedName = event.target.dataset.name;

        this.dispatchEvent(new CustomEvent('lookupselected', {
            detail: {
                selectedId,
                selectedName
            },
            bubbles: true,
            composed: true
        }));

        this.searchKey = selectedName;
        this.records = [];
    }

    handleKeySelect(event) {
        if (event.key === 'Enter') {
            this.handleSelect(event);
        }
    }
}