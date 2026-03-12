@isTest
private class CustomerCaseControllerTest {

    @TestSetup
    static void setupData() {
        // Use System.runAs to avoid MIXED_DML_OPERATION with setup objects
        User adminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(adminUser) {
            // Check if queue already exists to avoid DUPLICATE_DEVELOPER_NAME error
            List<Group> existingQueues = [SELECT Id FROM Group WHERE DeveloperName = 'Sales_Support_Team' AND Type = 'Queue' LIMIT 1];
            if (existingQueues.isEmpty()) {
                Group testQueue = new Group(
                    Name = 'Sales Support Team',
                    DeveloperName = 'Sales_Support_Team',
                    Type = 'Queue'
                );
                insert testQueue;

                QueueSobject queueSobj = new QueueSobject(
                    QueueId = testQueue.Id,
                    SobjectType = 'Case'
                );
                insert queueSobj;
            }
        }
    }

    @isTest
    static void testCreateCaseSuccess() {
        Test.startTest();
        String caseId = CustomerCaseController.createCase(
            'John Doe',
            '9876543210',
            '123 Main Street, City',
            'Door handle is not working properly'
        );
        Test.stopTest();

        System.assertNotEquals(null, caseId, 'Case Id should not be null');

        Case createdCase = [SELECT Id, Subject, SuppliedName, SuppliedPhone, Description, Origin, Status, OwnerId FROM Case WHERE Id = :caseId];
        System.assertEquals('Customer Issue - John Doe', createdCase.Subject);
        System.assertEquals('John Doe', createdCase.SuppliedName);
        System.assertEquals('9876543210', createdCase.SuppliedPhone);
        System.assertEquals('Web', createdCase.Origin);
        System.assertEquals('New', createdCase.Status);
    }

    @isTest
    static void testCreateCaseWithEmptyFields() {
        Test.startTest();
        try {
            CustomerCaseController.createCase('', '', '', '');
            System.assert(false, 'Expected AuraHandledException for empty mobile number');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'Should throw validation error for empty mobile number');
        }
        Test.stopTest();
    }

    @isTest
    static void testSubmitCaseVF() {
        CustomerCaseController ctrl = new CustomerCaseController();
        ctrl.customerName = 'Jane Doe';
        ctrl.mobileNumber = '9876543210';
        ctrl.address = '456 Test Street';
        ctrl.issueDetails = 'Test issue from VF page';

        Test.startTest();
        ctrl.submitCase();
        Test.stopTest();

        System.assertEquals(true, ctrl.isSubmitted);
        System.assertNotEquals('', ctrl.caseNumber);
        System.assertEquals('', ctrl.errorMessage);
    }

    @isTest
    static void testResetFormVF() {
        CustomerCaseController ctrl = new CustomerCaseController();
        ctrl.customerName = 'Jane Doe';
        ctrl.mobileNumber = '9876543210';

        ctrl.resetForm();

        System.assertEquals('', ctrl.customerName);
        System.assertEquals('', ctrl.mobileNumber);
        System.assertEquals(false, ctrl.isSubmitted);
    }
}