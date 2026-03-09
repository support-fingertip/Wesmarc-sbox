@isTest
private class CustomerCaseControllerTest {

    @TestSetup
    static void setupData() {
        // Create the Sales Support Team queue
        Group testQueue = new Group(
            Name = 'Sales Support Team',
            DeveloperName = 'Sales_Support_Team',
            Type = 'Queue'
        );
        insert testQueue;

        // Associate Case sObject type with the queue
        QueueSobject queueSobj = new QueueSobject(
            QueueId = testQueue.Id,
            SobjectType = 'Case'
        );
        insert queueSobj;
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

        // Verify queue assignment
        Group queue = [SELECT Id FROM Group WHERE DeveloperName = 'Sales_Support_Team' AND Type = 'Queue' LIMIT 1];
        System.assertEquals(queue.Id, createdCase.OwnerId, 'Case should be assigned to Sales Support Team queue');
    }

    @isTest
    static void testCreateCaseWithEmptyFields() {
        Test.startTest();
        String caseId = CustomerCaseController.createCase(
            '',
            '',
            '',
            ''
        );
        Test.stopTest();

        System.assertNotEquals(null, caseId, 'Case Id should not be null even with empty fields');
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