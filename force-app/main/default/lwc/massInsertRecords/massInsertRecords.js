import { LightningElement, track, wire } from 'lwc';
import insertCustomRecords from '@salesforce/apex/MassInsertController.insertCustomRecords';
import LeadDefaults from '@salesforce/apex/MassInsertController.LeadDefaults';
import getMultiplePicklistOptions from '@salesforce/apex/PicklistHelperController.getMultiplePicklistOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MassInsertRecords extends LightningElement {
    @track isPicklistReady = false;
    @track records = [
        { id: Date.now(), rowNumber: 1 }
    ];

    picklistOptions = {
        businessClients: [],
        projectCategory: [],
        projectSiteStage: [],
        state: [],
        status: [],
        region: [],
        orderStatus: [],
        year: [],
        month: [],
        reasonLost: [],
        doorApp: [],
        doorCat: [],
        leadSource: []
    };

    constructor() {
        super();
        console.log('Constructor');
    }

    connectedCallback() {
        console.log('Connected Callback');
    }

    renderedCallback(){
        console.log('Rendered Callback');
    }

    @wire(getMultiplePicklistOptions) wiredPicklists(result) {
        console.log('Picklist wire fired');
        const { data, error } = result;
        console.log('Picklist wire result: ', result);
        if (data) {
            this.picklistOptions.businessClients = data.Business_Clients__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.projectCategory = data.Project_Category__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.projectSiteStage = data.Project_Site_Stage__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.state = data.State__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.status = data.Status__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.region = data.Region__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.orderStatus = data.Order_Staus__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.year = data.Order_Time_line_Time_Frame_Year__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.month = data.Order_Time_line_Time_Frame_Month__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.reasonLost = data.Reason_for_Loosing_the_Order__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.doorApp = data.Door_Application__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.doorCat = data.Door_Category__c?.map(val => ({ label: val, value: val })) || [];
            this.picklistOptions.leadSource = data.Lead_Source__c?.map(val => ({ label: val, value: val })) || [];
            this.isPicklistReady = true;
        } else if (error) {
            console.error('Error fetching picklist options info: ', JSON.stringify(error));
        } else {
            console.warn('Wire method fired but no data or error returned');
        }
    }
    

    handleInputChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const field = event.target.dataset.field;
        let value = event.target.value;

        //Handle Number Type
        const inputType = event.target.inputType;
        if (inputType === 'number') {
            value = value === '' ? null : Number(value);
            if (isNaN(value)) {
                value = null;
            }
        }
        this.records[index][field] = value;
    }

    handleLookupChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.dataset.field;
        const selectedId = event.detail.selectedId;

        this.records[index][field] = selectedId;

        if (field === 'Lead__c') {
            this.fetchLeadDefaults(index,selectedId);
            console.log(selectedId);
        }
    }

    async fetchLeadDefaults(index,selectedId) {
        console.log('Fetching Lead Defaults for:', selectedId);
        if ( !selectedId ) {
            console.warn('Lead ID is undefined or null');
            return;
        }
        try {
            console.log(index, selectedId);
            const result = await LeadDefaults({ leadId : selectedId });
            console.log('Fetched Lead Defaults:', result);
            if (!result) {
                console.error('Received empty result from Apex');
                return;
            }
            const updatedRecords = [...this.records];
            Object.keys(result).forEach(field => {
                updatedRecords[index][field] = result[field];
                console.log(result.Business_Clients__c);
            });
        } catch (error) {
            console.error('Error in fetchLeadDefaults:', error);
            this.showToast('Error ', error.body?.message || 'Error fetching lead defaults', 'error');
        }
    }

    addRow = () => {
        try {
            console.log('Adding new row');
            const newRow = {
                id: Date.now(),
                rowNumber: this.records.length + 1,
                // Initialize all required fields to avoid undefined errors
                Lead__c: '',
                Key_Account__c: '',
                Opportunity__c: '',
                Channel_Partner__c: '',
                Sales_Person_Name__c: '',
                Business_Clients__c: '',
                Project_Category__c: '',
                Project_Name__c: '',
                Project_Site_Stage__c: '',
                State__c: '',
                Status__c: '',
                Customer_Name__c: '',
                Region__c: '',
                Order_Staus__c: '',
                Order_Time_line_Time_Frame_Year__c: '',
                Order_Time_line_Time_Frame_Month__c: '',
                Reason_for_Loosing_the_Order__c: '',
                Door_Application__c: '',
                Door_Category__c: '',
                Postpone_Door_Quality__c: '',
                Number_of_Doors__c: null,
                Lead_Source__c: '',
                Previous_Month_Backlog__c: null,
                Actual_Closed__c: null
            };
        
            this.records = [...this.records, newRow];
        } catch (err) {
        console.error('Add row error:', err);
        }
    }

    handleDeleteRow(event) {
        const index = parseInt(event.target.dataset.index, 10);
        if (this.records.length > 1) {
            this.records.splice(index, 1);
            this.records = this.records.map((r, i) => ({
                ...r,
                rowNumber: i + 1
            }));
        }
    }

    get isSingleRow() {
        return this.records.length === 1;
    }

    handleCancel = () => {
        this.records = [{ id: Date.now(), rowNumber: 1 }];
    }

    async handleSave() {
        console.log('Sending records to Apex: ', JSON.stringify(this.records));
        try {
            await insertCustomRecords({ recordsToInsert: this.records });
            this.showToast('Success', 'Records inserted successfully', 'success');
            this.handleCancel();
        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}