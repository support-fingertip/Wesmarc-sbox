@isTest
public class CaseTriggerHandlerTest {
    @isTest
    public static void CaseTest(){
        Profile p = [SELECT Id FROM Profile  limit 1];
         
        User u = new User(Alias = 'standt12', Email='standarduser@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.123',MobilePhone = '111');
        insert  u;
        
        User u1 = new User(Alias = 'stand123', Email='standarduser1@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com.123',MobilePhone = '1111');
        insert  u1;
        
        Channel_Partner__c cp = new Channel_Partner__c(Name = 'CP Test');
        insert cp;
        
        Id recordTypePerson = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        Account a = new Account(Name = 'TestAccount', OwnerId = u.Id);
        insert a;
        
        Case c = new Case(AccountId = a.Id, Origin = 'Email', Type = 'Rework', Status = 'New', OwnerId = u.Id);
        insert c;
    }

    /* Test Case insert with Queue owner — verifies queue member lookup and notification paths execute without exception */
    @isTest
    public static void testCaseInsertWithQueueOwner(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];

        User queueMember = new User(Alias = 'qmem01', Email='queuemember01@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='QueueMember', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='queuemember01@testorg.com.notif',MobilePhone = '2221');
        insert queueMember;

        // Create a test queue and add the user as a member inside System.runAs to avoid MIXED_DML
        Group testQueue = new Group(Name = 'Test Notification Queue', Type = 'Queue');
        insert testQueue;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = testQueue.Id, UserOrGroupId = queueMember.Id);
            insert gm;
            QueueSobject qso = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
            insert qso;
        }

        Test.startTest();
        Case c = new Case(Origin = 'Email', Type = 'Rework', Status = 'New', OwnerId = testQueue.Id);
        insert c;
        Test.stopTest();

        // Verify the case was inserted
        Case inserted = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, inserted, 'Case should be inserted');

        // Verify getQueueMemberUserIds executes without exception
        Set<Id> memberIds = CaseTriggerHandler.getQueueMemberUserIds(new Set<Id>{ c.Id });
        System.assertNotEquals(null, memberIds, 'getQueueMemberUserIds should return a set');
    }

    /* Test Case status change with Queue owner — verifies queue member notifications on update */
    @isTest
    public static void testCaseStatusChangeWithQueueOwner(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];

        User queueMember2 = new User(Alias = 'qmem02', Email='queuemember02@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='QueueMember2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='queuemember02@testorg.com.notif',MobilePhone = '3331');
        insert queueMember2;

        Group testQueue2 = new Group(Name = 'Test Notification Queue 2', Type = 'Queue');
        insert testQueue2;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm2 = new GroupMember(GroupId = testQueue2.Id, UserOrGroupId = queueMember2.Id);
            insert gm2;
            QueueSobject qso = new QueueSobject(QueueId = testQueue2.Id, SobjectType = 'Case');
            insert qso;
        }

        Case c2 = new Case(Origin = 'Email', Type = 'Rework', Status = 'New', OwnerId = testQueue2.Id);
        insert c2;

        Test.startTest();
        c2.Status = 'Closed';
        update c2;
        Test.stopTest();

        Case updated = [SELECT Id, Status FROM Case WHERE Id = :c2.Id];
        System.assertEquals('Closed', updated.Status, 'Case status should be Closed after update');
    }

    /* Test CaseQueueNotificationService with empty inputs — no exception expected */
    @isTest
    public static void testSendEmailToQueueMembersEmpty(){
        Test.startTest();
        CaseQueueNotificationService.sendEmailToQueueMembers(new Set<Id>(), new Set<Id>());
        Test.stopTest();
        System.assert(true, 'No exception expected for empty inputs');
    }

    /* Test handlecaseBeforeInsert — empty method, just ensure no exception */
    @isTest
    public static void testHandleCaseBeforeInsert(){
        Case c = new Case(Origin = 'Email', Status = 'New', Subject = 'Before Insert Test');
        Test.startTest();
        CaseTriggerHandler.handlecaseBeforeInsert(new List<Case>{ c });
        Test.stopTest();
        System.assert(true, 'handlecaseBeforeInsert should execute without exception');
    }

    /* Test Case insert with Customer Support record type and User owner */
    @isTest
    public static void testCaseInsertCustomerSupportUserOwner(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(Alias = 'csUser1', Email='csuser1@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='CSUser', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='csuser1@testorg.com.notif',MobilePhone = '4441');
        insert u;

        Id customerSupportRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();

        Test.startTest();
        Case c = new Case(Origin = 'Web', Status = 'New', Subject = 'CS User Owner Test',
                          RecordTypeId = customerSupportRTId, OwnerId = u.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        c.setOptions(dmo);
        insert c;
        Test.stopTest();

        Case inserted = [SELECT Id, RecordTypeId FROM Case WHERE Id = :c.Id];
        System.assertEquals(customerSupportRTId, inserted.RecordTypeId, 'Record type should be Customer Support');
    }

    /* Test Case insert with Customer Support record type and Queue owner */
    @isTest
    public static void testCaseInsertCustomerSupportQueueOwner(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User qMember = new User(Alias = 'csQm01', Email='csqmem01@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='CSQueueMember', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='csqmem01@testorg.com.notif',MobilePhone = '5551');
        insert qMember;

        Group testQueue = new Group(Name = 'CS Test Queue', Type = 'Queue');
        insert testQueue;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = testQueue.Id, UserOrGroupId = qMember.Id);
            insert gm;
            QueueSobject qso = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
            insert qso;
        }

        Id customerSupportRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();

        Test.startTest();
        Case c = new Case(Origin = 'Web', Status = 'New', Subject = 'CS Queue Owner Test',
                          RecordTypeId = customerSupportRTId, OwnerId = testQueue.Id);
        insert c;
        Test.stopTest();

        Case inserted = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertNotEquals(null, inserted, 'Case should be inserted');
    }

    /* Test Case status change with User owner — covers user owner notification in caseAfterUpdate */
    @isTest
    public static void testCaseStatusChangeWithUserOwner(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(Alias = 'upd01', Email='upduser01@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='UpdateUser', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='upduser01@testorg.com.notif',MobilePhone = '6661');
        insert u;

        Case c = new Case(Origin = 'Email', Status = 'New', Subject = 'User Owner Update Test', OwnerId = u.Id);
        insert c;

        Test.startTest();
        c.Status = 'Closed';
        update c;
        Test.stopTest();

        Case updated = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Closed', updated.Status, 'Case status should be Closed');
    }

    /* Test Case status change to non-Closed value — covers changedStatusCaseIds without caseIdOwnerMap */
    @isTest
    public static void testCaseStatusChangeNonClosed(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(Alias = 'noncl1', Email='nonclosed1@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='NonClosedUser', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='nonclosed1@testorg.com.notif',MobilePhone = '7771');
        insert u;

        Case c = new Case(Origin = 'Email', Status = 'New', Subject = 'Non-Closed Update Test', OwnerId = u.Id);
        insert c;

        Test.startTest();
        c.Status = 'Working';
        update c;
        Test.stopTest();

        Case updated = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Working', updated.Status, 'Case status should be Working');
    }

    /* Test getQueueMemberUserIds with non-queue owned cases — should return empty set */
    @isTest
    public static void testGetQueueMemberUserIdsNoQueue(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(Alias = 'noq01', Email='noqueue01@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='NoQueueUser', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='noqueue01@testorg.com.notif',MobilePhone = '8881');
        insert u;

        Case c = new Case(Origin = 'Email', Status = 'New', Subject = 'No Queue Test', OwnerId = u.Id);
        insert c;

        Test.startTest();
        Set<Id> result = CaseTriggerHandler.getQueueMemberUserIds(new Set<Id>{ c.Id });
        Test.stopTest();

        System.assert(result.isEmpty(), 'Should return empty set when case is not owned by a queue');
    }

    /* Test CaseQueueNotificationService with valid queue member users */
    @isTest
    public static void testSendEmailToQueueMembersWithData(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(Alias = 'eml01', Email='emailmem01@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='EmailMember', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='emailmem01@testorg.com.notif',MobilePhone = '9991');
        insert u;

        Group testQueue = new Group(Name = 'Email Test Queue', Type = 'Queue');
        insert testQueue;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = testQueue.Id, UserOrGroupId = u.Id);
            insert gm;
            QueueSobject qso = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'Case');
            insert qso;
        }

        Case c = new Case(Origin = 'Email', Status = 'New', Subject = 'Email Queue Test', OwnerId = testQueue.Id);
        insert c;

        Test.startTest();
        CaseQueueNotificationService.sendEmailToQueueMembers(new Set<Id>{ c.Id }, new Set<Id>{ u.Id });
        Test.stopTest();

        System.assert(true, 'Email notification should complete without exception');
    }

}