public class MassInsertController {

    @AuraEnabled
    public static void insertCustomRecords(List<Map<String, Object>> recordsToInsert) {
        List<Sales_Funnel__c> funnels = new List<Sales_Funnel__c>();

        for (Map<String, Object> row : recordsToInsert) {
            Sales_Funnel__c funnel = new Sales_Funnel__c();
            system.debug(row);
            if (row != null) {
                system.debug(row.keyset());
                system.debug(row.values());
                if (row.containsKey('Lead__c')) funnel.Lead__c = (Id)row.get('Lead__c');
                if (row.containsKey('Key_Account__c')) funnel.Key_Account__c = (Id)row.get('Key_Account__c');
                if (row.containsKey('Opportunity__c')) funnel.Opportunity__c = (Id)row.get('Opportunity__c');
                if (row.containsKey('Channel_Partner__c')) funnel.Channel_Partner__c = (Id)row.get('Channel_Partner__c');
                if (row.containsKey('Sales_Person_Name__c')) funnel.Sales_Person_Name__c = (Id)row.get('Sales_Person_Name__c');
                if (row.containsKey('Business_Clients__c')) funnel.Business_Clients__c = (String)row.get('Business_Clients__c');
                if (row.containsKey('Project_Category__c')) funnel.Project_Category__c = (String)row.get('Project_Category__c');
                if (row.containsKey('Project_Name__c')) funnel.Project_Name__c = (String)row.get('Project_Name__c');
                if (row.containsKey('Project_Site_Stage__c')) funnel.Project_Site_Stage__c = (String)row.get('Project_Site_Stage__c');
                if (row.containsKey('State__c')) funnel.State__c = (String)row.get('State__c');
                if (row.containsKey('Status__c')) funnel.Status__c = (String)row.get('Status__c');
                if (row.containsKey('Customer_Name__c')) funnel.Customer_Name__c = (String)row.get('Customer_Name__c');
                if (row.containsKey('Region__c')) funnel.Region__c = (String)row.get('Region__c');
                if (row.containsKey('Order_Staus__c')) funnel.Order_Staus__c = (String)row.get('Order_Staus__c');
                if (row.containsKey('Order_Time_line_Time_Frame_Year__c')) funnel.Order_Time_line_Time_Frame_Year__c = (String)row.get('Order_Time_line_Time_Frame_Year__c');
                if (row.containsKey('Order_Time_line_Time_Frame_Month__c')) funnel.Order_Time_line_Time_Frame_Month__c = (String)row.get('Order_Time_line_Time_Frame_Month__c');
                if (row.containsKey('Reason_for_Loosing_the_Order__c')) funnel.Reason_for_Loosing_the_Order__c = (String)row.get('Reason_for_Loosing_the_Order__c');
                if (row.containsKey('Door_Application__c')) funnel.Door_Application__c = (String)row.get('Door_Application__c');
                if (row.containsKey('Door_Category__c')) funnel.Door_Category__c = (String)row.get('Door_Category__c');
                if (row.containsKey('Postpone_Door_Quality__c')) funnel.Postpone_Door_Quality__c = row.get('Postpone_Door_Quality__c') != null ? Integer.valueOf(row.get('Postpone_Door_Quality__c').toString()) : null;
                if (row.containsKey('Number_of_Doors__c')) funnel.Number_of_Doors__c = row.get('Number_of_Doors__c') != null ? Integer.valueOf(row.get('Number_of_Doors__c').toString()) : null;
                if (row.containsKey('Lead_Source__c')) funnel.Lead_Source__c = (String)row.get('Lead_Source__c');
                if (row.containsKey('Previous_Month_Backlog__c')) funnel.Previous_Month_Backlog__c = row.get('Previous_Month_Backlog__c') != null ? Integer.valueOf(row.get('Previous_Month_Backlog__c').toString()) : null;
                if (row.containsKey('Actual_Closed__c')) funnel.Actual_Closed__c = row.get('Actual_Closed__c') != null ? Integer.valueOf(row.get('Actual_Closed__c').toString()) : null;
                
                funnels.add(funnel);
                system.debug(funnel);
            } else {
                throw new AuraHandledException('Row is not having any values');
            }
            
        }

        if (!funnels.isEmpty()) {
            insert funnels;
        }
    }
    
    @AuraEnabled
    public static Map<String, String> LeadDefaults(String leadId) {
        Map<String, String> leadValues = new Map<String, String>();
        system.debug('Lead Record Id: '+ leadId);
        
        Lead ld = [SELECT Id, Name, Source_Type__c, Timeline_Year__c, Timeline_Month__c, Primary_Contact_Person__c, Enquiry_Type__c, State__c, 
                   Region__c, Door_Application__c, Door_Category__c, Number_of_Doors_Client_Looking_for__c, Project_Category__c, 
                   Project_Site_Stage__c, Project_Name__c, Key_Account__c, Sub_Source__c, Channel_Partner__c 
                   FROM Lead WHERE Id =: leadId];
        System.debug('Lead Record: '+ld);
        
        Map<String, String> SrcMap = new Map<String, String>();
            for (Source_Mapping__mdt src : [SELECT Lead_source__c, Sales_Pipeline_source__c FROM Source_Mapping__mdt]) {
                SrcMap.put(src.Lead_source__c, src.Sales_Pipeline_source__c);
            }
        
        if(ld.Id != null) {
            if(ld.Project_Name__c !=null && ld.Project_Name__c !=''){
                leadValues.put('Project_Name__c', ld.Project_Name__c);
            }else{
                leadValues.put('Project_Name__c', ld.Name);
            }        
            leadValues.put('Customer_Name__c', ld.Name);
            leadValues.put('State__c', ld.State__c);
            leadValues.put('Region__c', ld.Region__c);
            leadValues.put('Key_Account__c', ld.Key_Account__c);
            leadValues.put('Sales_Person_Name__c', UserInfo.getUserId());
            leadValues.put('Project_Category__c', ld.Project_Category__c);
            leadValues.put('Business_Clients__c', ld.Enquiry_Type__c);
            leadValues.put('Channel_Partner__c', ld.Channel_Partner__c);
            leadValues.put('Door_Application__c', ld.Door_Application__c);
            if(ld.Source_Type__c!=null && SrcMap.containskey(ld.Source_Type__c)){
                leadValues.put('Lead_Source__c', SrcMap.get(ld.Source_Type__c));
            }
            leadValues.put('Door_Category__c', ld.Door_Category__c);
            leadValues.put('Project_Site_Stage__c', ld.Project_Site_Stage__c);
            leadValues.put('Order_Time_line_Time_Frame_Year__c', ld.Timeline_Year__c);
            leadValues.put('Order_Time_line_Time_Frame_Month__c', ld.Timeline_Month__c);
            leadValues.put('Number_of_Doors__c', String.valueOf(ld.Number_of_Doors_Client_Looking_for__c));
        }
        
        system.debug(leadValues);
        return leadValues;
    }
}