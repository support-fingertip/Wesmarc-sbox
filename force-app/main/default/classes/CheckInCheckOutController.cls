public class CheckInCheckOutController {
    @AuraEnabled
    public static void updateVisitCheckIn (decimal latitude, decimal longitude,string visitId) {
        // Query the Visit record by Id
        Visit__c visit = [SELECT Id,Actual_Start_Time__c, Actual_End_Time__c, Check_In_Location__Longitude__s, Check_In_Location__Latitude__s,Check_Out_Location__Latitude__s, Check_Out_Location__Longitude__s, Status__c FROM Visit__c WHERE Id = :visitId LIMIT 1];
       
            visit.Actual_Start_Time__c = System.now();
            visit.Check_In_Location__Longitude__s = latitude;
            visit.Check_In_Location__Latitude__s = longitude;
            visit.Status__c = 'In Progress' ;
         update visit;
 
    }
}