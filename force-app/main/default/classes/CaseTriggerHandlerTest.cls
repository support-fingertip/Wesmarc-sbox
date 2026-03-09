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

}