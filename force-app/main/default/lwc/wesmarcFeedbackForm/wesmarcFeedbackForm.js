import { LightningElement, track, wire } from 'lwc';
import saveFeedback from '@salesforce/apex/FeedbackFormController.saveFeedback';
import userStudioLocation from '@salesforce/apex/FeedbackFormController.userStudioLocation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WesmarcFeedbackForm extends LightningElement {
    qrImageUrl;
    @track fullName = '';
    @track mobileNumber = '';
    @track occupation = '';
    @track email = '';
    @track city = '';
    @track showOtherCity = false;
    @track otherCity = '';
    @track referralSources = [];
    @track showOtherReferral = false;
    @track showReferralCheckboxes = true;
    @track otherReferral = '';
    @track overallExperience = '';
    @track detailedRatings = [
        { label: 'Staff Courtesy & Knowledge', name: 'staffCourtesy', value: '' },
        { label: 'Cleanliness & Hygiene of Store & Staff', name: 'cleanliness', value: '' },
        { label: 'Ambience / Mood / Feel of the Studio', name: 'ambience', value: '' },
        { label: 'Product Display & Demo Experience', name: 'productDisplay', value: '' },
        { label: 'Ease of Understanding the Product', name: 'easeOfUnderstanding', value: '' }
    ];
    @track impressions = [];
    @track uncheckedAll = true;
    @track showImpressionCheckboxes = true;
    @track recommendation = '';
    @track purchaseIntent = '';
    @track suggestions = '';
    @track link = '';
    /*@track toast = {
        show: false,
        message: '',
        type: ''
    };*/

    connectedCallback() {
        userStudioLocation().then(studio => {
            this.qrImageUrl = `/resource/${studio}`;
        })
        .catch(error => {
            console.error('Error fetching QR resource name: ', error);
        });
    }

    cityOptions = [
        { label: 'Bangalore', value: 'Bangalore' },
        { label: 'Chennai', value: 'Chennai' },
        { label: 'Hyderabad', value: 'Hyderabad' },
        { label: 'Pune', value: 'Pune' },
        { label: "Other's", value: "Other's" }
    ];

    referralOptions = [
        { label: 'Instagram / Social Media', value: 'Instagram/Social Media' },
        { label: 'Google Search', value: 'Google Search' },
        { label: 'Architects', value: 'Architects' },
        { label: 'Builders', value: 'Builders' },
        { label: 'Interior Designers', value: 'Interior Designers' },
        { label: 'Delight Studio Store', value: 'Delight Studio Store' },
        { label: 'Other', value: 'Other' }
    ];

    experienceOptions = [
        { label: 'Poor', value: 'Poor' },
        { label: 'Good', value: 'Good' },
        { label: 'Very Good', value: 'Very Good' },
        { label: 'Excellent', value: 'Excellent' }
    ];

    impressionOptions = [
        { label: 'Design & Aesthetics', value: 'Design & Aesthetics' },
        { label: 'German Engineering', value: 'German Engineering' },
        { label: 'Rebated Sound Proof Technology', value: 'Rebated Sound Proof Technology' },
        { label: 'Customization Option', value: 'Customization Option' },
        { label: 'Innovation in Mechanism', value: 'Innovation in Mechanism' },
        { label: 'Look, Feel & Finish', value: 'Look, Feel & Finish' },
        { label: 'All the above', value: 'All the above' }
    ];

    recommendationOptions = [
        { label: '1', value: '1' },
        { label: '2', value: '2' },
        { label: '3', value: '3' },
        { label: '4', value: '4' },
        { label: '5', value: '5' }
    ];

    purchaseIntentOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
        { label: 'Maybe', value: 'Maybe' }
    ];

    handleInputChange(event) {
        const field = event.target.label;
        const value = event.target.value;

        switch (field) {
            case 'Full Name':
                this.fullName = value;
                break;
            case 'Mobile Number':
                this.mobileNumber = value;
                break;
            case 'Occupation':
                this.occupation = value;
                break;
            case 'Email ID':
                this.email = value;
                break;
            case 'City':
                this.city = value;
                this.showOtherCity = value === "Other's";
                break;
            case 'Please specify your City':
                this.otherCity = value;
                break;
            case 'Please specify other referral source':
                this.otherReferral = value;
                break;
            case 'Rate the overall studio experience':
                this.overallExperience = value;
                break;
            case 'On a scale of 1 to 5, how likely are you to recommend Wesmarc to others?':
                this.recommendation = value;
                break;
            case 'Do you plan to buy Wesmarc doors for your home or project?':
                this.purchaseIntent = value;
                break;
            case 'What could we improve at Wesmarc Delight Studios?':
                this.suggestions = value;
                break;
            default:
                break;
        }
    }

    handleReferralChange(event) {
        const value = event.target.dataset.id;
        if (event.target.checked) {
            this.referralSources = [...this.referralSources, value];
            if (value === 'Other') {
                this.showOtherReferral = true;
            }
        } else {
            this.referralSources = this.referralSources.filter(item => item !== value);
            if (value === 'Other') {
                this.showOtherReferral = false;
                this.otherReferral = '';
            }
        }
    }


    handleDetailedRatingChange(event) {
        const name = event.target.dataset.id;
        const value = event.target.value;
        this.detailedRatings = this.detailedRatings.map(rating => {
            if (rating.name === name) {
                return { ...rating, value: value };
            }
            return rating;
        });
    }

    handleImpressionChange(event) {
        const value = event.target.dataset.id;
        if (event.target.checked) {
            if (value === 'All the above') {
                this.impressions = this.impressionOptions
                    .filter(opt => opt.value !== 'All the above')
                    .map(opt => opt.value);

                this.uncheckedAll = false;
                setTimeout(() => {
                    this.uncheckedAll = true;
                }, 0);
            }
            else {
                if(this.uncheckedAll = true) {
                    this.impressions = [...this.impressions, value];
                }
                
            }
        } else {
            if (value === 'All the above') {
                this.impressions = [];
            }
            else {
                this.impressions = this.impressions.filter(item => item !== value);
            }
        }
    }

    /*showCustomToast(message, type) {
        this.toast = {
            show: true,
            message,
            type
        };

        //Auto-hide after 4 seconds
        setTimeout(() => {
            this.toast.show = false;
        }, 4000);
    }

    get toastClass() {
        return 'toast ${this.toast.type}';
    }*/


    handleSubmit() {
    //validate required fields
        if(!this.fullName || !this.mobileNumber || !this.city || (this.showOtherCity && !this.otherCity) || (this.showOtherReferral && !this.otherReferral)) {
            //this.showCustomToast('Please fill all the required fields.', 'error');

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the required fields.',
                variant: 'error'
            }));
            return;
        }
        const feedbackList = [
            {
                Name: this.fullName,
                Phone__c: this.mobileNumber,
                Occupation__c: this.occupation,
                Email__c: this.email,
                City__c: this.city,
                Please_Specify_Other_City__c: this.otherCity,
                Referral_Sources__c: this.referralSources.join(';'),
                Please_Specify_Other_Referral_Source__c	: this.otherReferral,
                Overall_Experience__c: this.overallExperience,
                Staff_Courtesy_Knowledge__c: this.getRating('staffCourtesy'),
                Cleanliness_Hygiene__c: this.getRating('cleanliness'),
                Ambience__c: this.getRating('ambience'),
                Product_Display__c: this.getRating('productDisplay'),
                Ease_of_Understanding_the_Product__c: this.getRating('easeOfUnderstanding'),
                Product_Impressions__c: this.impressions.join(';'),
                Recommendation__c: this.recommendation,
                Purchase_Intent__c: this.purchaseIntent,
                Suggestions__c: this.suggestions
            }
        ];

        saveFeedback({ feedbackList: feedbackList })
            .then(() => {
                //this.showCustomToast('Thank you for your Feedback!', 'success');

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Thank you for your Feedback!',
                    variant: 'success'
                }));
                this.resetForm();
            })
            .catch(error => {
                //this.showCustomToast(error.body.message, 'error');

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }

    getRating(name) {
        const rating = this.detailedRatings.find(item => item.name === name);
        return rating ? rating.value : '';
    }

    resetForm() {
        this.fullName = '';
        this.mobileNumber = '';
        this.occupation = '';
        this.email = '';
        this.city = '';
        this.otherCity = '';
        this.referralSources = [];
        this.otherReferral = '';
        this.overallExperience = '';
        this.detailedRatings = this.detailedRatings.map(rating => ({ ...rating, value: '' }));
        this.impressions = [];
        this.recommendation = '';
        this.purchaseIntent = '';
        this.suggestions = '';

        // Toggle flags to force rerender of checkbox blocks
        this.showReferralCheckboxes = false;
        this.showImpressionCheckboxes = false;
        setTimeout(() => {
            this.showReferralCheckboxes = true;
            this.showImpressionCheckboxes = true;
        }, 0); 
    }
}