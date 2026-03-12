public without sharing class CustomerCaseController {

    public String customerName { get; set; }
    public String mobileNumber { get; set; }
    public String address { get; set; }
    public String issueDetails { get; set; }
    public Boolean isSubmitted { get; set; }
    public String caseNumber { get; set; }
    public String errorMessage { get; set; }

    public CustomerCaseController() {
        isSubmitted = false;
        caseNumber = '';
        errorMessage = '';
    }

    public PageReference submitCase() {
        errorMessage = '';
        try {
            // Get the Sales Support Team queue
            List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Support_Team' LIMIT 1];

            Case newCase = new Case();
            newCase.Subject = 'Customer Issue - ' + String.escapeSingleQuotes(customerName);
            newCase.SuppliedName = customerName;
            newCase.SuppliedPhone = mobileNumber;
            newCase.Description = 'Name: ' + customerName + '\n'
                                + 'Mobile: ' + mobileNumber + '\n'
                                + 'Address: ' + address + '\n\n'
                                + 'Issue Details:\n' + issueDetails;
            newCase.Origin = 'Web';
            newCase.Status = 'New';
            newCase.Priority = 'Medium';

            // Assign to Sales Support Team queue if it exists
            if (!queues.isEmpty()) {
                newCase.OwnerId = queues[0].Id;
            }

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = false;
            newCase.setOptions(dmo);
            insert newCase;

            Case createdCase = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1];
            caseNumber = createdCase.CaseNumber;
            isSubmitted = true;
        } catch (Exception e) {
            errorMessage = 'Error creating case. Please try again.';
        }
        return null;
    }

    public PageReference resetForm() {
        customerName = '';
        mobileNumber = '';
        address = '';
        issueDetails = '';
        isSubmitted = false;
        caseNumber = '';
        errorMessage = '';
        return null;
    }

    @AuraEnabled
    public static String createCase(String customerName, String mobileNumber, String address, String issueDetails) {
        try {
            List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Support_Team' LIMIT 1];

            Case newCase = new Case();
            newCase.Subject = 'Customer Issue - ' + customerName;
            newCase.SuppliedName = customerName;
            newCase.SuppliedPhone = mobileNumber;
            newCase.Description = 'Name: ' + customerName + '\n'
                                + 'Mobile: ' + mobileNumber + '\n'
                                + 'Address: ' + address + '\n\n'
                                + 'Issue Details:\n' + issueDetails;
            newCase.Origin = 'Web';
            newCase.Status = 'New';
            newCase.Priority = 'Medium';

            if (!queues.isEmpty()) {
                newCase.OwnerId = queues[0].Id;
            }

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = false;
            newCase.setOptions(dmo);
            insert newCase;
            return newCase.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }
}