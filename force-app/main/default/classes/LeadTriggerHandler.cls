public class LeadTriggerHandler {
    /**************************************************************** 
* Class Name  : LeadTriggerHandler  @Company  : Fingertip    @Created Date  : 08-4-2025  
@description : lead object trigger handler   @author  :Nachiketha   @User By  : - 
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  08-4-2025 |   Initial version      
* -------------------------------------------------------------------
**************************************************************** */    
    
    
    
/*  Method Name: mapFIeldsBeforeInsert  * Date: 07/04/2025  @author: Nachiketha  * @description: map company &owner id 
* @parameters: lead list */    
    public static void mapFIeldsBeforeInsert(list<lead> leadList){
        for(Lead ld : leadList) {
            string firstname = (ld.FirstName !=NULL?ld.FirstName: '');
            ld.Company = firstname +'' +ld.LastName;
            if(ld.Executive_Name__c != null && ld.Executive_Name__c != ld.ownerId){
                // ld.ownerId = ld.Executive_Name__c;
            }
            
            // Phone validation and formatting
            if (ld.Phone != null) {
                String phone = ld.Phone;
                
                // Check if phone number length is greater than 10
                if (phone.length() > 10 && phone.startsWith('91')) {
                    // Remove spaces, plus sign, and country code '91' if present
                    phone = phone.replaceAll('\\s+', '');   // Remove spaces
                    phone = phone.replaceAll('\\+', '');    // Remove plus sign
                    if (phone.startsWith('91')) {
                        phone = phone.substring(2);  // Remove the country code '91'
                        phone ='91 '+phone;
                    }
                    
                    // Now you can use the cleaned phone number for further processing
                    ld.Phone = phone;
                }
            }
            if (ld.MobilePhone != null) {
                String MobilePhone = ld.MobilePhone;
                
                if (MobilePhone.length() > 10 && MobilePhone.startsWith('91')) {
                    // Remove spaces, plus sign, and country code '91' if present
                    MobilePhone = MobilePhone.replaceAll('\\s+', '');   // Remove spaces
                    MobilePhone = MobilePhone.replaceAll('\\+', '');    // Remove plus sign
                    if (MobilePhone.startsWith('91')) {
                        MobilePhone = MobilePhone.substring(2);  // Remove the country code '91'
                          MobilePhone ='91 '+MobilePhone;
                    }
                    
                    // Now you can use the cleaned MobilePhone number for further processing
                    ld.MobilePhone = MobilePhone;
                }
                
            }
        } 
    }
 
  /*  Method Name: mapFIeldsBeforeUpdate  * Date: 07/04/2025  @author: Nanma  * @description: map company 
* @parameters: lead list */    
    public static void mapFIeldsBeforeUpdate(list<lead> leadList,map<Id,lead> triggeroldMap){
        for(Lead ld : leadList) {
             string firstname = (ld.FirstName !=NULL?ld.FirstName: '');
            ld.Company = firstname +'' +ld.LastName;
            
             // Phone validation and formatting
            if (ld.Phone != null && triggeroldMap.get(ld.Id).Phone !=ld.Phone) {
                String phone = ld.Phone;
                
              // Check if phone number length is greater than 10
                if (phone.length() > 10 && phone.startsWith('91')) {
                    // Remove spaces, plus sign, and country code '91' if present
                    phone = phone.replaceAll('\\s+', '');   // Remove spaces
                    phone = phone.replaceAll('\\+', '');    // Remove plus sign
                    if (phone.startsWith('91')) {
                        phone = phone.substring(2);  // Remove the country code '91'
                        phone ='91 '+phone;
                    }
                    
                    // Now you can use the cleaned phone number for further processing
                    ld.Phone = phone;
                }
            }
            if (ld.MobilePhone != null && triggeroldMap.get(ld.Id).MobilePhone !=ld.MobilePhone) {
                String MobilePhone = ld.MobilePhone;
                
               if (MobilePhone.length() > 10 && MobilePhone.startsWith('91')) {
                    // Remove spaces, plus sign, and country code '91' if present
                    MobilePhone = MobilePhone.replaceAll('\\s+', '');   // Remove spaces
                    MobilePhone = MobilePhone.replaceAll('\\+', '');    // Remove plus sign
                    if (MobilePhone.startsWith('91')) {
                        MobilePhone = MobilePhone.substring(2);  // Remove the country code '91'
                          MobilePhone ='91 '+MobilePhone;
                    }
                    // Now you can use the cleaned MobilePhone number for further processing
                    ld.MobilePhone = MobilePhone;
                }
                
            }
            
        }
        
    }  
    
    
/*  Method Name: leadTriggerAfterInsert  * Date: 07/04/2025  @author: Nachiketha  * @description:  
* @parameters: lead list */        
  public static void leadTriggerAfterInsert(list<lead> leadist){
        map<Id,lead> leadOwnerMap= new map<Id,lead>();
        map<Id,lead> leadManagerMap= new map<Id,lead>();
        for(lead l : leadist){
          //  leadOwnerMap.put(l.OwnerId,l);  
            if( l.Manager__c != null){
                leadManagerMap.put(l.Manager__c,l);   
            }
           
        }
       sendNotificationToUser(leadOwnerMap,leadManagerMap);
    }
    
    
    
 
    
    
    
    public static void sendNotificationToUser( map<Id,lead> leadOwnerMap , map<Id,lead> leadManagerMap ){  
        Set<string> userIds =new Set<string>();
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName ='Lead_Notification'];
        
        
      /*  for(string userId :leadOwnerMap.keySet()){
            userIds.add(userId);
            string title = leadOwnerMap.get(userId).LastName +' Assigned To You';
            SendNotification.sendNotification('New Lead Assigned To you',title,userinfo.getUserId(),type.Id,leadOwnerMap.get(userId).Id, userIds);
            userIds.clear(); 
        }
        */
        if(!leadManagerMap.isEmpty()){
            for(string userId :leadManagerMap.keySet()){
                userIds.add(userId);
                string title = leadManagerMap.get(userId).LastName +' Assigned To '+leadManagerMap.get(userId).Lead_Owner_Full_Name__c;
                SendNotification.sendNotification('New Lead Assigned To '+leadManagerMap.get(userId).Lead_Owner_Full_Name__c,title,userinfo.getUserId(),type.Id,leadManagerMap.get(userId).Id, userIds);
                userIds.clear(); 
            }
        }
        
    }  
}