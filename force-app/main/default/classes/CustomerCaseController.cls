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
            // Validate and clean mobile number
            String cleanedMobile = cleanAndValidateMobile(mobileNumber);

            // Check for duplicate open cases
            checkDuplicateCase(cleanedMobile, customerName);

            // Get the Sales Support Team queue
            List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Support_Team' LIMIT 1];

            // Get the Customer Support record type
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();

            Case newCase = new Case();
            newCase.RecordTypeId = recordTypeId;
            newCase.Subject = 'Customer Issue - ' + String.escapeSingleQuotes(customerName);
            newCase.SuppliedName = customerName;
            newCase.SuppliedPhone = cleanedMobile;
            newCase.Description = 'Name: ' + customerName + '\n'
                                + 'Mobile: ' + cleanedMobile + '\n'
                                + 'Address: ' + address + '\n\n'
                                + 'Nature of Support:\n' + issueDetails;
            newCase.Origin = 'Web';
            newCase.Status = 'New';
            newCase.Priority = 'Medium';

            // Assign to Sales Support Team queue if it exists
            if (!queues.isEmpty()) {
                newCase.OwnerId = queues[0].Id;
            }

          


            insert newCase;

            Case createdCase = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1];
            caseNumber = createdCase.CaseNumber;
            isSubmitted = true;
        } catch (AuraHandledException e) {
            throw e;
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
            // Validate and clean mobile number
            String cleanedMobile = cleanAndValidateMobile(mobileNumber);

            // Check for duplicate open cases
            checkDuplicateCase(cleanedMobile, customerName);

            List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Support_Team' LIMIT 1];

            // Get the Customer Support record type
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();

            Case newCase = new Case();
            newCase.RecordTypeId = recordTypeId;
            newCase.Subject = 'Customer Issue - ' + customerName;
            newCase.SuppliedName = customerName;
            newCase.SuppliedPhone = cleanedMobile;
            newCase.Description = 'Name: ' + customerName + '\n'
                                + 'Mobile: ' + cleanedMobile + '\n'
                                + 'Address: ' + address + '\n\n'
                                + 'Nature of Support:\n' + issueDetails;
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
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }

    private static String cleanAndValidateMobile(String mobile) {
        if (mobile == null) {
            throw new AuraHandledException('Mobile number is required.');
        }
        String cleaned = mobile.replaceAll('[\\s\\-\\+]', '');
        if (cleaned.length() > 10 && cleaned.startsWith('91')) {
            cleaned = cleaned.substring(2);
        }
        Pattern mobilePattern = Pattern.compile('^[6-9][0-9]{9}$');
        Matcher m = mobilePattern.matcher(cleaned);
        if (!m.matches()) {
            throw new AuraHandledException('Please enter a valid 10-digit mobile number starting with 6, 7, 8, or 9');
        }
        return cleaned;
    }

    private static void checkDuplicateCase(String mobileNumber, String customerName) {
        List<Case> existingCases = [
            SELECT Id, CaseNumber, Status
            FROM Case
            WHERE SuppliedPhone = :mobileNumber
            AND SuppliedName = :customerName
            AND Status != 'Closed'
            AND Origin = 'Web'
            LIMIT 1
        ];
        if (!existingCases.isEmpty()) {
            throw new AuraHandledException('An open case (Case #' + existingCases[0].CaseNumber + ') already exists for this mobile number. Please wait for the existing case to be resolved before submitting a new one.');
        }
    }
}