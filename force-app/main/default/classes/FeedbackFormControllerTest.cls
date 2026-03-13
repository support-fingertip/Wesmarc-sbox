@isTest
public class FeedbackFormControllerTest {
    @isTest
    public static void feedbackFormTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'  LIMIT 1];
         
        User u = new User(Alias = 'standt12', Email='standarduser@testorgfil.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.123',MobilePhone = '111',
                          //@01/07/2025
                          IsStudioUser__c=true, Studio_Location__c='HYD Studio');
        insert  u;
        
        
        List<Feedback__c> fdList = new List<Feedback__c>();
        Feedback__c fd = new Feedback__c();
        fd.City__c = 'Hyderabad';
        fd.Email__c = 'test@gmail.com';
        fd.Name = 'Test';
        fd.Phone__c = '7898759565';
        fdList.add(fd);
        
        FeedbackFormController.saveFeedback(fdList);
        FeedbackFormController.userStudioLocation();
        FeedbackFormController.codeCoverage();
    }
}