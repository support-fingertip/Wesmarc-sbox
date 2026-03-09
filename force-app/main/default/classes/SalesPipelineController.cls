/**
* @File Name : SalesPipelineController.cls
* @Description : custom new salespipeline form controller
* @Author : Rakesh Reddy
* @Last Modified By : Rakesh Reddy
* @Last Modified On : June 24, 2025
* @Modification Log : 
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 24, 2025 |   | Initial Version
**/

public class SalesPipelineController {
    @AuraEnabled
    public static Map<String, Object> getLeadDetails(string leadId) {
        system.debug('leadId '+leadId);
        //Querying the lead
         Lead ld =  [
            SELECT Id, Name, Region__c, State__c, Project_Name__c, Sub_Source__c, Enquiry_Type__c, Key_Account__c, Project_Category__c, Channel_Partner__c, 
             Door_Application__c, Door_Category__c, Source_Type__c, Project_Site_Stage__c, Timeline_Year__c, Timeline_Month__c, Number_of_Doors_Client_Looking_for__c
             FROM Lead
             WHERE Id = :leadId
             LIMIT 1
        ];

        Map<String, String> SrcMap = new Map<String, String>();
        for (Source_Mapping__mdt src : [SELECT Lead_source__c, Sales_Pipeline_source__c FROM Source_Mapping__mdt]) {
            SrcMap.put(src.Lead_source__c, src.Sales_Pipeline_source__c);
        }
        Map<String, String> clientTypeMap = new Map<String, String>();
        for (Business_Client_Mapping__mdt client : [SELECT Lead_Enquiry_Type__c, Sales_Pipeline_Business_Client__c FROM Business_Client_Mapping__mdt]) {
            clientTypeMap.put(client.Lead_Enquiry_Type__c, client.Sales_Pipeline_Business_Client__c);
        }
        //Mapping Values to the fields
        Map<String, Object> fieldMap = new Map<String, Object>();
        if(ld.Project_Name__c !=null && ld.Project_Name__c !=''){
            fieldMap.put('Project_Name__c', ld.Project_Name__c);
        }else{
            fieldMap.put('Project_Name__c', ld.Name);
        }        
        fieldMap.put('Lead__c', ld.Id);
        fieldMap.put('Customer_Name__c', ld.Name);
        fieldMap.put('State__c', ld.State__c);
        fieldMap.put('Region__c', ld.Region__c);
        fieldMap.put('Order_Time_line_Time_Frame_Year__c', ld.Timeline_Year__c);
        fieldMap.put('Order_Time_line_Time_Frame_Month__c', ld.Timeline_Month__c);
        fieldMap.put('Number_of_Doors__c', ld.Number_of_Doors_Client_Looking_for__c);
        fieldMap.put('Key_Account__c', ld.Key_Account__c);
        fieldMap.put('Sales_Person_Name__c', UserInfo.getUserId());
        fieldMap.put('Project_Category__c', ld.Project_Category__c);
        if(ld.Enquiry_Type__c!=null && clientTypeMap.containskey(ld.Enquiry_Type__c)){
            fieldMap.put('Business_Clients__c', clientTypeMap.get(ld.Enquiry_Type__c));
        }
        fieldMap.put('Channel_Partner__c', ld.Channel_Partner__c);
        fieldMap.put('Door_Application__c', ld.Door_Application__c);
        if(ld.Source_Type__c!=null && SrcMap.containskey(ld.Source_Type__c)){
            fieldMap.put('Lead_Source__c', SrcMap.get(ld.Source_Type__c));
        }
        fieldMap.put('Door_Category__c', ld.Door_Category__c);
        fieldMap.put('Project_Site_Stage__c', ld.Project_Site_Stage__c);
        System.debug(fieldMap);
        return fieldMap;
    }
}