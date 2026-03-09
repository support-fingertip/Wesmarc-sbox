public class CaseTriggerHandler {
    /**************************************************************** 
* Class Name  : CaseTriggerHandler  @Company  : Fingertip    @Created Date  : 21-4-2025  
@description : case object trigger handler   @author  :Nachiketha   @User By  : - 
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  21-4-2025 |   Initial version      
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
        sendNotificationToUser(caseIdSet);
    }
    
 /*  Method Name: caseUpdate  * Date: 9/05/2025  @author: Nanma  * @description: send notification tocase owner * @parameters: case list */
    public static void caseAfterUpdate(List<Case> caseList, map<Id,case> oldcaseMap) {
        map<Id,string> caseIdOwnerMap = New map<Id,string> ();
        for(Case c : caseList) {
            if(c.Status =='Closed' && c.Status != oldcaseMap.get(c.Id).Status){
               caseIdOwnerMap.put(c.Id,c.CreatedById); 
            }
        }
       sendNotificationToCaseCreatedBy(caseIdOwnerMap);
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
}