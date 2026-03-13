public class StartDayEndDayController {
    @AuraEnabled
    public static void createAttendanceStartDay(decimal latitude, decimal longitude) {
        
        List<Attendance__c> attdList = [SELECT Id, Start_Time__c, Start_Location__Longitude__s, Start_Location__Latitude__s, End_Time__c, 
                              	End_Location__Latitude__s, End_Location__Longitude__s, OwnerId FROM Attendance__c
            						WHERE OwnerId = :UserInfo.getUserId()
            							AND Start_Time__c = TODAY
            									LIMIT 1];
        system.debug('1');
        if(attdList.isEmpty()) {
            system.debug('2');
            Attendance__c attd = New Attendance__c();
            attd.Start_Time__c = System.now();
            attd.Start_Location__Longitude__s = longitude;
            attd.Start_Location__Latitude__s = latitude;
            
            insert attd;
        }
    }
    
    @AuraEnabled
    public static void updateAttendanceEndDay(decimal latitude, decimal longitude) {
        
        List<Attendance__c> attdList = [SELECT Id, Start_Time__c, Start_Location__Longitude__s, Start_Location__Latitude__s, End_Time__c, 
                              	End_Location__Latitude__s, End_Location__Longitude__s, OwnerId FROM Attendance__c
            						WHERE OwnerId = :UserInfo.getUserId()
            							AND Start_Time__c = TODAY
            									LIMIT 1];
        system.debug('3');
        if(!attdList.isEmpty()) {
            system.debug('4');
            List<Attendance__c> attdUpdateList = New List<Attendance__c>();
            for(Attendance__c attd : attdList) {
                if(attd.End_Time__c == null) {
                    attd.End_Time__c = System.now();
                    attd.End_Location__Longitude__s = longitude;
                    attd.End_Location__Latitude__s = latitude;
                    
                    attdUpdateList.add(attd);
                }
            }
            update attdUpdateList;
        }
    }
    
    @AuraEnabled
    public static Attendance__c attendanceList() {
        Date today = System.today();
        
        Datetime startOfDay = Datetime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0);
        Datetime endOfDay = Datetime.newInstance(today.year(), today.month(), today.day(), 23, 59, 59);
        
        List<Attendance__c> attdList = [SELECT Id, Start_Time__c, Start_Location__Longitude__s, Start_Location__Latitude__s, End_Time__c, 
                              	End_Location__Latitude__s, End_Location__Longitude__s, OwnerId FROM Attendance__c
            						WHERE OwnerId = :UserInfo.getUserId()
            							AND CreatedDate = TODAY
            									LIMIT 1];
        Attendance__c attd = null;
        if(!attdList.isEmpty()) {
            attd = attdList[0];
        }
        
        return attd;
    }
}