public class PicklistHelperController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getMultiplePicklistOptions() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        
        //Define Fields
        Schema.DescribeFieldResult businessClientsField = Sales_Funnel__c.Business_Clients__c.getDescribe();
        Schema.DescribeFieldResult projectCategoryField = Sales_Funnel__c.Project_Category__c.getDescribe();
        Schema.DescribeFieldResult projectSiteStageField = Sales_Funnel__c.Project_Site_Stage__c.getDescribe();
        Schema.DescribeFieldResult stateField = Sales_Funnel__c.State__c.getDescribe();
        Schema.DescribeFieldResult statusField = Sales_Funnel__c.Status__c.getDescribe();
        Schema.DescribeFieldResult regionField = Sales_Funnel__c.Region__c.getDescribe();
        Schema.DescribeFieldResult orderStatusField = Sales_Funnel__c.Order_Staus__c.getDescribe();
        Schema.DescribeFieldResult yearField = Sales_Funnel__c.Order_Time_line_Time_Frame_Year__c.getDescribe();
        Schema.DescribeFieldResult monthField = Sales_Funnel__c.Order_Time_line_Time_Frame_Month__c.getDescribe();
        Schema.DescribeFieldResult reasonLostField = Sales_Funnel__c.Reason_for_Loosing_the_Order__c.getDescribe();
        Schema.DescribeFieldResult doorAppField = Sales_Funnel__c.Door_Application__c.getDescribe();
        Schema.DescribeFieldResult doorCatField = Sales_Funnel__c.Door_Category__c.getDescribe();
        Schema.DescribeFieldResult leadSourceField = Sales_Funnel__c.Lead_Source__c.getDescribe();
        
        //Helper method to get values
        picklistMap.put('Business_Clients__c', getValues(businessClientsField));
        picklistMap.put('Status__c', getValues(statusField));
        picklistMap.put('Project_Site_Stage__c', getValues(projectSiteStageField));
        picklistMap.put('Project_Category__c', getValues(projectCategoryField));
        picklistMap.put('Reason_for_Loosing_the_Order__c', getValues(reasonLostField));
        picklistMap.put('Door_Category__c', getValues(doorCatField));
        picklistMap.put('Door_Application__c', getValues(doorAppField));
        picklistMap.put('Region__c', getValues(regionField));
        picklistMap.put('State__c', getValues(stateField));
        picklistMap.put('Order_Time_line_Time_Frame_Month__c', getValues(monthField));
        picklistMap.put('Order_Time_line_Time_Frame_Year__c', getValues(yearField));
        picklistMap.put('Order_Staus__c', getValues(orderStatusField));
        picklistMap.put('Lead_Source__c', getValues(leadSourceField));
        
        return picklistMap;
    }
    
    private static List<String> getValues(Schema.DescribeFieldResult fieldResult) {
        List<String> values = new List<String>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                values.add(entry.getLabel());
            }
        }
        return values;
    }

}