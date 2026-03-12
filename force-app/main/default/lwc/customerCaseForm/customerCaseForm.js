import { LightningElement, track } from 'lwc';
import createCase from '@salesforce/apex/CustomerCaseController.createCase';

export default class CustomerCaseForm extends LightningElement {
    @track customerName = '';
    @track mobileNumber = '';
    @track address = '';
    @track issueDetails = '';
    @track isSubmitted = false;
    @track isLoading = false;
    @track caseNumber = '';

    get wesmarkLogoUrl() {
        return '/resource/WesmarcLogo';
    }

    handleLogoError(event) {
        event.target.style.display = 'none';
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        if (field === 'customerName') {
            this.customerName = event.target.value;
        } else if (field === 'mobileNumber') {
            this.mobileNumber = event.target.value;
        } else if (field === 'address') {
            this.address = event.target.value;
        } else if (field === 'issueDetails') {
            this.issueDetails = event.target.value;
        }
    }

    handleSubmit() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            return;
        }

        this.isLoading = true;
        createCase({
            customerName: this.customerName,
            mobileNumber: this.mobileNumber,
            address: this.address,
            issueDetails: this.issueDetails
        })
            .then(result => {
                this.caseNumber = result;
                this.isSubmitted = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                const errorMsg = error.body ? error.body.message : 'An error occurred. Please try again.';
                alert(errorMsg);
            });
    }

    handleReset() {
        this.customerName = '';
        this.mobileNumber = '';
        this.address = '';
        this.issueDetails = '';
        this.isSubmitted = false;
        this.caseNumber = '';
    }
}