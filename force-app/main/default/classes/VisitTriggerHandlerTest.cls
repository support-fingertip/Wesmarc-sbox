@isTest
public class VisitTriggerHandlerTest {
    @isTest
    public static void VisitTest() {
        Profile p = [SELECT Id FROM Profile  LIMIT 1];
         
        User u = new User(Alias = 'standt12', Email='standarduser@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.123',MobilePhone = '111');
        insert  u;
        
        Account a = new Account(Name = 'TestAccount', OwnerId = u.Id);
        insert a;
        
        Visit__c v = new Visit__c(Planned_Visit_Date__c = system.today(), Visit_Type__c = 'New Visit', Related_to__c = 'Key Account', Key_Account__c = a.Id);
        insert v;
        
        String visitId = v.Id;
        CheckInCheckOutController.updateVisitCheckIn(12.971599, 77.594566, visitId);

    }
    
    /*@isTest
    public static void CheckINCheckOutTest() {
        String visitId;
        List<Visit__c> lstV = [SELECT Id FROM Visit__c LIMIT 1];
        for(Visit__c v : lstV) {
            visitId = v.Id;
        }
        
        
    }*/
}