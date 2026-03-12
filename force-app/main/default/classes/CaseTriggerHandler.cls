public class CaseTriggerHandler {
    /**************************************************************** 
* Class Name  : CaseTriggerHandler  @Company  : Fingertip    @Created Date  : 21-4-2025  
@description : case object trigger handler   @author  :Nachiketha   @User By  : - 
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  21-4-2025 |   Initial version      
* 2.0 |   Nanma       |  12-03-2026  |   Queue member in-app + email notifications
* -------------------------------------------------------------------
**************************************************************** */    
    
    public static void handlecaseBeforeInsert(List<Case> caseList) {


        
    }  
    
/*  Method Name: caseInsert  * Date: 21/04/2025  @author: Nachiketha  * @description: map owner id &case
* @parameters: case list */
    public static void caseInsert(List<Case> caseList) {
        Set<Id> caseIdSet = New Set<Id>();
        for(Case c : caseList) {
            caseIdSet.add(c.Id);
        }

        // Split cases by record type
        Id customerSupportRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();
        Set<Id> customerSupportCaseIds = new Set<Id>();
        Set<Id> otherCaseIds = new Set<Id>();
        for (Case c : caseList) {
            if (c.RecordTypeId == customerSupportRTId) {
                customerSupportCaseIds.add(c.Id);
            } else {
                otherCaseIds.add(c.Id);
            }
        }

        // For non-Customer Support record types, use the default notification
        if (!otherCaseIds.isEmpty()) {
            sendNotificationToUser(otherCaseIds);
        }

        // For Customer Support record type, notify queue members and user owners
        if (!customerSupportCaseIds.isEmpty()) {
            // Notify all active queue members when the Case owner is a queue
            Set<Id> queueMemberIds = getQueueMemberUserIds(customerSupportCaseIds);
            if (!queueMemberIds.isEmpty()) {
                CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Record_Creation_Notification' LIMIT 1];
                Set<String> userIdStrings = new Set<String>();
                for (Id uid : queueMemberIds) {
                    userIdStrings.add(String.valueOf(uid));
                }
                for (Id caseId : customerSupportCaseIds) {
                    String title = 'New Case in your queue';
                    String body  = 'A new Case has been created and assigned to your queue. Click to view.';
                    SendNotification.sendNotification(body, title, UserInfo.getUserId(), notifType.Id, caseId, userIdStrings);
                }
              CaseQueueNotificationService.sendEmailToQueueMembers(customerSupportCaseIds, queueMemberIds);
            }

            // Notify Case owner if the owner is a User (not a Queue)
            for (Case c : caseList) {
                if (c.RecordTypeId == customerSupportRTId && c.OwnerId.getSObjectType() == User.SObjectType) {
                    CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Record_Creation_Notification' LIMIT 1];
                    Set<String> ownerSet = new Set<String>{ String.valueOf(c.OwnerId) };
                    String title = 'New Case assigned to you';
                    String body  = 'A new Case has been created and assigned to you. Click to view.';
                    SendNotification.sendNotification(body, title, UserInfo.getUserId(), notifType.Id, c.Id, ownerSet);
                }
            }
        }
    }
    
 /*  Method Name: caseAfterUpdate  * Date: 9/05/2025  @author: Nanma  * @description: send notification to case owner and queue members on status change * @parameters: case list */
    public static void caseAfterUpdate(List<Case> caseList, map<Id,case> oldcaseMap) {
        map<Id,string> caseIdOwnerMap = New map<Id,string> ();
        Set<Id> changedStatusCaseIds = new Set<Id>();
        for(Case c : caseList) {
            if(c.Status =='Closed' && c.Status != oldcaseMap.get(c.Id).Status){
               caseIdOwnerMap.put(c.Id,c.CreatedById); 
            }
            if(c.Status != oldcaseMap.get(c.Id).Status){
                changedStatusCaseIds.add(c.Id);
            }
        }
        sendNotificationToCaseCreatedBy(caseIdOwnerMap);

        // Notify all active queue members when Case status changes
        if (!changedStatusCaseIds.isEmpty()) {
            Set<Id> queueMemberIds = getQueueMemberUserIds(changedStatusCaseIds);
            if (!queueMemberIds.isEmpty()) {
                CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Record_Creation_Notification' LIMIT 1];
                Set<String> userIdStrings = new Set<String>();
                for (Id uid : queueMemberIds) {
                    userIdStrings.add(String.valueOf(uid));
                }
                Map<Id, Case> caseMap = new Map<Id, Case>(caseList);
                for (Id caseId : changedStatusCaseIds) {
                    Case c = caseMap.get(caseId);
                    String title = 'Case status updated: ' + c.Status;
                    String body  = 'Status of a Case in your queue has changed to ' + c.Status + '. Click to view.';
                    SendNotification.sendNotification(body, title, UserInfo.getUserId(), notifType.Id, caseId, userIdStrings);
                }
                CaseQueueNotificationService.sendEmailToQueueMembers(changedStatusCaseIds, queueMemberIds);
            }

            // Notify Case owner if the owner is a User (not a Queue)
            Map<Id, Case> caseMapForOwner = new Map<Id, Case>(caseList);
            for (Id caseId : changedStatusCaseIds) {
                Case c = caseMapForOwner.get(caseId);
                if (c != null && c.OwnerId.getSObjectType() == User.SObjectType) {
                    CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Record_Creation_Notification' LIMIT 1];
                    Set<String> ownerSet = new Set<String>{ String.valueOf(c.OwnerId) };
                    String title = 'Case status updated: ' + c.Status;
                    String body  = 'Status of a Case assigned to you has changed to ' + c.Status + '. Click to view.';
                    SendNotification.sendNotification(body, title, UserInfo.getUserId(), notifType.Id, caseId, ownerSet);
                }
            }
        }
    }
       
    
    public static void sendNotificationToCaseCreatedBy(map<Id,string> caseIdOwnerMap) {
        Set<string> userIds =new Set<string>();
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName ='Record_Creation_Notification'];
        for(string recId :caseIdOwnerMap.keyset()){
              userIds.add(caseIdOwnerMap.get(recId));
            string title = 'Your Case has been Closed';
            SendNotification.sendNotification('Click to view case status',title,userinfo.getUserId(),type.Id, recId, userIds);
            userIds.clear(); 
        }
    } 
    
    public static void sendNotificationToUser(Set<Id> caseIdSet) {
        Set<string> userIds =new Set<string>();
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName ='Record_Creation_Notification'];
        
        
        for(string recId :caseIdSet){
            userIds.add(Label.Sowjanya_UseId);
            string title = 'New Case has been created!';
            SendNotification.sendNotification('New Case Assigned To you',title,userinfo.getUserId(),type.Id, recId, userIds);
            userIds.clear(); 
        }
    }

    /*  Method Name: getQueueMemberUserIds  * Date: 12/03/2026  @author: Nanma
     *  @description: Returns active User Ids who are members of the queue(s) owning the given Cases
     *  @parameters: Set of Case Ids */
    @TestVisible
    private static Set<Id> getQueueMemberUserIds(Set<Id> caseIds) {
        Set<Id> queueIds = new Set<Id>();
        for (Case c : [SELECT OwnerId FROM Case WHERE Id IN :caseIds
                        AND OwnerId IN (SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Support_Team1')]) {
            queueIds.add(c.OwnerId);
        }
        if (queueIds.isEmpty()) {
            return new Set<Id>();
        }
        Map<Id, User> userMap = new Map<Id, User>(
            [SELECT Id FROM User
             WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds)
             AND IsActive = true]
        );
        return new Set<Id>(userMap.keySet());
    }
}