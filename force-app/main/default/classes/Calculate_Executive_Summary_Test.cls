@isTest
public class Calculate_Executive_Summary_Test {
@isTest
     public static void method1(){
         User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Team'].Id,
            LastName = 'last',
            Email = 'testbrm@brm.com',
            Username = 'testbrm@brm.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'     
        );
        insert u;  
            Channel_Partner__c cp = new Channel_Partner__c(Name = 'CP Test');
        insert cp;
        
        Id recordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
        
        Lead l = new Lead(Salutation = 'Mr.', FirstName = 'Lead', LastName = 'Test', Executive_Name__c = u.Id, Manager__c = u.Id,
                         	Exisiting_Customer__c = 'No', Channel_Partner__c = cp.Id, Enquiry_Type__c = 'Builders', RecordTypeId = recordType);
        insert l;
         Sales_Funnel__c sf = NEW Sales_Funnel__c();
         sf.Status__c='Open';
         sf.Number_of_Doors__c=2;
         sf.Sales_Person_Name__c=u.id;
         sf.Order_Time_line_Time_Frame_Month__c ='JULY';
          sf.Order_Time_line_Time_Frame_Year__c ='2025';
         insert sf;
          Test.startTest();
        database.executeBatch(new Calculate_Executive_Summary(date.newInstance(2025,7,01)));


        Test.stopTest();
    }
}