import { LightningElement, api, wire } from 'lwc'; import { CurrentPageReference } from 'lightning/navigation'; import { NavigationMixin } from 'lightning/navigation'; import getLeadDetails from '@salesforce/apex/SalesPipelineController.getLeadDetails'; import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SalesPipelineForm extends NavigationMixin(LightningElement) { 
    @api recordId; 
    @api objectApiName; 
    isModalOpen = false; 
    isLoading = false;
    hasFetched = false;

    connectedCallback() {
        console.log('recordId:', this.recordId);
        console.log('Object:', this.objectApiName);
    }

    renderedCallback(){
        if (!this.hasFetched && this.recordId && this.objectApiName === 'Lead') {
            this.hasFetched = true;
            this.isModalOpen = false;
            this.fetchLeadData();
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.attributes) {
            this.objectApiName = currentPageReference.attributes.objectApiName;
            console.log('Captured via CurrentPageReference:', this.objectApiName);
            console.log('isModalOpen:', this.isModalOpen);
        }
        if (this.objectApiName === 'Sales_Funnel__c') {
            this.isModalOpen = true;
        }
    }

    async fetchLeadData() {
        try {
            const ldId = this.recordId;
            console.log('1. Lead ID selected:', ldId);

            if (!ldId) {
                console.log('No Lead ID provided');
                return;
            }

            this.isLoading = true;
            const ld1 = ldId.toString();
            const result = await getLeadDetails({ leadId: ld1 });

            console.log('3. Apex call successful:', JSON.parse(JSON.stringify(result)));

            if (!result) {
                console.error('4. Received empty result from Apex');
                return;
            }

            const fields = this.template.querySelectorAll('lightning-input-field');
            console.log(`5. Found ${fields.length} fields to update`);

            fields.forEach(field => {
                const fieldName = field.fieldName;
                if (result.hasOwnProperty(fieldName)) {
                    console.log(`6. Setting ${fieldName} to:, result[fieldName]`);
                    field.value = result[fieldName];
                }
            });
        } catch (error) {
            console.error('7. Error in fetchLeadData:', error);
            this.showToast(
                'Error',
                error.body?.message || error.message || 'Failed to fetch Lead details',
                'error'
            );
        } finally {
            this.isLoading = false;
            console.log('8. Completed fetchLeadData');
        }
    }

    async handleLeadChange(event) {
        try {
            const ldId = event.detail.value;
            console.log('1. Lead ID selected:', ldId);

            if (!ldId) {
                console.log('No Lead ID provided');
                return;
            }

            this.isLoading = true;
            const ld2 = ldId.toString();
            const result = await getLeadDetails({ leadId: ld2 });

            console.log('3. Apex call successful:', JSON.parse(JSON.stringify(result)));

            if (!result) {
                console.error('4. Received empty result from Apex');
                return;
            }

            const fields = this.template.querySelectorAll('lightning-input-field');
            console.log(`5. Found ${fields.length} fields to update`);

            fields.forEach(field => {
                const fieldName = field.fieldName;
                if (result.hasOwnProperty(fieldName)) {
                    console.log(`6. Setting ${fieldName} to:, result[fieldName]`);
                    field.value = result[fieldName];
                }
            });
        } catch (error) {
            console.error('7. Error in handleLeadChange:', error);
            this.showToast(
                'Error',
                error.body?.message || error.message || 'Failed to fetch Lead details',
                'error'
            );
        } finally {
            this.isLoading = false;
            console.log('8. Completed handleLeadChange');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleSuccess(event) {
        const newRecordId = event.detail.id;
        this.showToast('Success', 'Sales pipeline created successfully', 'success');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: newRecordId,
                objectApiName: 'Sales_Funnel__c',
                actionName: 'view'
            }
        });
    }

    handleError(event) {
        console.error('Form submission error:', event.detail);
        this.showToast('Error', 'Form submission failed: ' + (event.detail?.message || ''), 'error');
    }

    openModal() {
        console.log('Entered openModal');
        this.isModalOpen = true;
        this.fetchLeadData();
    }

    closeModal() {
        this.isModalOpen = false;
    }

}