public class LeadConversionUtility  {
    /**************************************************************** 
* Class Name  : LeadConversionUtility   @Company  : Fingertip    @Created Date  : 15-4-2025  
@description : lead object to contact ,account, opportunity conversion   @author  :Nachiketha   @User By  : - LeadToOpportunity_Conversion_Cmp
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nanma  |  15-4-2025 |   Initial version      
* -------------------------------------------------------------------
**************************************************************** */    
  
    /*  Method Name: convertLead  * Date: 15/04/2025  @author: Nanma  * @description: custom Lead Conversion
* @parameters: lead list */    
    @auraEnabled
    public static string convertLead(string leadId) {
            String accRecordTypeID, recordId;
            // Retrieve the lead
            Lead lead = [SELECT Id, Phone, Appx_Display_Space_They_Own_Sqft__c, Architect_Name__c, Company_Location__c, 
                         	Display_Size_can_be_given_to_Westeam__c, Email, Existing_Business_experience_in_this_Ind__c,
                         	Exiting_Business__c, Looking_for_Wesmarc_dealership__c, MobilePhone, Showroom_Address__c, Source_Type__c, 
                         	Sub_Source__c, Tentative_Date_of_Lead_Closure__c, Turnover__c, Type_of_Display__c, Website, Wesmarc_Factory_Visit__c, 
                         	Wesmarc_Factory_Visit_Remarks__c, Where_they_got_to_know_about_us__c, Years_in_Business__c, IsConverted,Key_Account__c, 
                         	Enquiry_Type__c,LastName,FirstName,Exisiting_Customer__c,recordType.Name FROM Lead WHERE Id = :leadId LIMIT 1];
        	if (lead.IsConverted) {
                System.debug('Lead is already converted.');
                return null;
            }
        
        if(lead.recordType.Name != 'New Channel Partner') {
            Account acc = new Account();
            
            if(lead.Key_Account__c !=null ){
                acc.Id = lead.Key_Account__c;
            }else{
                string firstname = (lead.FirstName !=NULL?lead.FirstName: '');
                acc.Name = firstname +'' +lead.LastName;
                if(lead.recordType.Name == 'B2B'){
                    accRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get(lead.Enquiry_Type__c).getRecordTypeId();
                    
                }else if(lead.recordType.Name == 'B2C'){
                    accRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();   
                }else if(lead.recordType.Name == 'Others'){
                    accRecordTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Others').getRecordTypeId();  
                }
                acc.RecordTypeId = accRecordTypeID;
            }
            try{
            upsert acc;
            }catch(Exception ex){
                ExceptionHandler.addLog(ex, string.valueof(acc), 'LeadConversionUtility',leadId );
            }
            
            // Set up lead conversion with this Account
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(lead.Id);
            leadConvert.setAccountId(acc.Id);
            leadConvert.setDoNotCreateOpportunity(false);
            leadConvert.setConvertedStatus('Qualified');
            
            Database.LeadConvertResult result = Database.convertLead(leadConvert);
            if (result.isSuccess()) {
              
                Id contactId = result.getContactId();
                Id opportunityId = result.getOpportunityId();
                  recordId = opportunityId;
                System.debug('Conversion successful:');
                System.debug('Account Id: ' +result.getAccountId());
                System.debug('Contact Id: ' + contactId);
                System.debug('Opportunity Id: ' + opportunityId);
                Opportunity opp = new opportunity();
                opp.Id = opportunityId;
                string oppRecordTypeID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get(lead.recordType.Name).getRecordTypeId();  
                opp.recordTypeId = oppRecordTypeID;
                try{
                    update opp;
                }catch(Exception ex){
                    ExceptionHandler.addLog(ex, string.valueof(opp), 'LeadConversionUtility',leadId );
                }
                
                
            } else {
                System.debug('Lead conversion failed.');
                throw new AuraHandledException('An Error Occured');
            }
            
        }
        
        else if(lead.recordType.Name == 'New Channel Partner') {
            Channel_Partner__c cp = New Channel_Partner__c();
              string firstname = (lead.FirstName !=NULL?lead.FirstName: '');
            cp.Name = firstname + lead.LastName;
            cp.Alternate_Mobile__c = lead.Phone;
            cp.Appx_Display_Space_They_Own_Sqft__c = lead.Appx_Display_Space_They_Own_Sqft__c;
            cp.Architect_Name__c = lead.Architect_Name__c;
            cp.Company_Location__c = lead.Company_Location__c;
            cp.Display_Size_can_be_given_to_Westeam__c = lead.Display_Size_can_be_given_to_Westeam__c;
            cp.Email__c = lead.Email;
            cp.Existing_Business_experience_in_this_Ind__c = lead.Existing_Business_experience_in_this_Ind__c;
            cp.Exiting_Business__c = lead.Exiting_Business__c;
            cp.Looking_for_Wesmarc_dealership__c = lead.Looking_for_Wesmarc_dealership__c;
            cp.Mobile__c = lead.MobilePhone;
            cp.Showroom_Address__c = lead.Showroom_Address__c;
            cp.Source_Type__c = lead.Source_Type__c;
            cp.Status__c = 'Onboarded';
            cp.Sub_Source__c = lead.Sub_Source__c;
            cp.Tentative_Date_of_Lead_Closure__c = lead.Tentative_Date_of_Lead_Closure__c;
            cp.Turnover__c = lead.Turnover__c;
            cp.Type_of_Display__c = lead.Type_of_Display__c;
            cp.Website__c = lead.Website;
            cp.Wesmarc_Factory_Visit__c = lead.Wesmarc_Factory_Visit__c;
            cp.Wesmarc_Factory_Visit_Remarks__c = lead.Wesmarc_Factory_Visit_Remarks__c;
            cp.Where_they_got_to_know_about_us__c = lead.Where_they_got_to_know_about_us__c;
            cp.Years_in_Business__c = lead.Years_in_Business__c;
            try {
                insert cp;
                
                recordId = cp.Id;
            }
            catch(DmlException ex) {
                System.debug('Lead conversion failed.');
                  ExceptionHandler.addLog(ex, string.valueof(cp), 'LeadConversionUtility',leadId );
                throw new AuraHandledException('An Error Occured');
            }
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(lead.Id);
            leadConvert.setDoNotCreateOpportunity(true);
            leadConvert.setConvertedStatus('Qualified');
            
            Database.LeadConvertResult result = Database.convertLead(leadConvert);
            Account ac = new Account();
            ac.Id = result.getAccountId();
            
            delete ac;
            
        }
        return recordId;
    }
    
    
    
}