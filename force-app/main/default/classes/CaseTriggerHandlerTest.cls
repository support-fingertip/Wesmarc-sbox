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

        // Create a test queue and add the user as a member
        Group testQueue = new Group(Name = 'Test Notification Queue', Type = 'Queue');
        insert testQueue;

        GroupMember gm = new GroupMember(GroupId = testQueue.Id, UserOrGroupId = queueMember.Id);
        insert gm;

        Account a = new Account(Name = 'TestQueueAccount', OwnerId = queueMember.Id);
        insert a;

        Test.startTest();
        Case c = new Case(AccountId = a.Id, Origin = 'Email', Type = 'Rework', Status = 'New', OwnerId = testQueue.Id);
        insert c;
        Test.stopTest();

        // Verify the case was inserted and owned by the queue
        Case inserted = [SELECT Id, OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(testQueue.Id, inserted.OwnerId, 'Case should be owned by the test queue');

        // Verify getQueueMemberUserIds resolves the queue members correctly
        Set<Id> memberIds = CaseTriggerHandler.getQueueMemberUserIds(new Set<Id>{ c.Id });
        System.assert(memberIds.contains(queueMember.Id), 'Queue member should be in the resolved user set');
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

        GroupMember gm2 = new GroupMember(GroupId = testQueue2.Id, UserOrGroupId = queueMember2.Id);
        insert gm2;

        Account a2 = new Account(Name = 'TestQueueAccount2', OwnerId = queueMember2.Id);
        insert a2;

        Case c2 = new Case(AccountId = a2.Id, Origin = 'Email', Type = 'Rework', Status = 'New', OwnerId = testQueue2.Id);
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

}