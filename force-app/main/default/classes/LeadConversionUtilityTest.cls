@isTest
public class LeadConversionUtilityTest {
    @isTest
    public static void conversionTest() {
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
        
        Id recordTypePerson = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('New_Channel_Partner').getRecordTypeId();
        
        List<Lead> leadList = new List<Lead>();
        Lead l = new Lead(Salutation = 'Mr.', FirstName = 'Lead', LastName = 'Test', Enquiry_Type__c = 'Channel Partner', RecordTypeId = recordTypePerson);
        insert l;
        leadList.add(l);
        
        Id recordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
        
        Lead l1 = new Lead(Salutation = 'Mr.', FirstName = 'Lead', LastName = 'Test', Executive_Name__c = u.Id, Manager__c = u1.Id,
                         	Exisiting_Customer__c = 'No', Channel_Partner__c = cp.Id, Enquiry_Type__c = 'Builders', RecordTypeId = recordType);
        insert l1;
        leadList.add(l1);
        
        for(Lead ld : leadList) {
            String leadId = ld.Id;
            LeadConversionUtility.convertLead(leadId);
        }
        
    }
}