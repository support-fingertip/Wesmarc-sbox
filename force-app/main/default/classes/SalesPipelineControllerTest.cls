@isTest
public class SalesPipelineControllerTest {
	@isTest
    public static void testGetLeads() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'  LIMIT 1];
         
        User u = new User(Alias = 'standt12', Email='standarduser@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.123',MobilePhone = '111',
                          //@01/07/2025
                          IsStudioUser__c=true, Studio_Location__c='HYD Studio');
        insert  u;
        
        Lead ld = new Lead(LastName='test', Enquiry_Type__c='Architects');
        insert ld;
        
        SalesPipelineController.getLeadDetails(ld.Id);
    }
}