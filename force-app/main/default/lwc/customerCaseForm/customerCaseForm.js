import { LightningElement, track } from 'lwc';
import createCase from '@salesforce/apex/CustomerCaseController.createCase';

export default class CustomerCaseForm extends LightningElement {
    @track customerName = '';
    @track mobileNumber = '';
    @track address = '';
    @track issueDetails = '';
    @track isSubmitted = false;
    @track isLoading = false;
    @track isSubmitting = false;
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
    let value = event.target.value.replace(/[^0-9]/g, '');
    if (value.length > 10) {
        value = value.substring(0, 10);
    }
    this.mobileNumber = value;
    // Do NOT set event.target.value
} else if (field === 'address') {
            this.address = event.target.value;
        } else if (field === 'issueDetails') {
            this.issueDetails = event.target.value;
        }
    }

validateMobileNumber() {
    const mobileInput = this.template.querySelector('[data-field="mobileNumber"]');
    if (!mobileInput) return false;

    // Use a local variable to handle null/undefined values safely
    const val = this.mobileNumber || ''; 
    const regex = /^[6-9][0-9]{9}$/;
    const isValid = regex.test(val);

    if (!isValid && val.length > 0) {
        mobileInput.setCustomValidity('Please enter a valid 10-digit mobile number starting with 6-9');
    } else {
        mobileInput.setCustomValidity(''); // Reset error
    }

    mobileInput.reportValidity();
    return isValid;
}
    handleSubmit() {
        if (this.isSubmitting) {
            return;
        }

        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            return;
        }

        if (!this.validateMobileNumber()) {
            return;
        }

        this.isSubmitting = true;
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
                this.isSubmitting = false;
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
        this.isSubmitting = false;
        this.caseNumber = '';
    }
}