trigger LeadTrigger on Lead (before insert, after insert,before update) {
 /**************************************************************** 
* Class Name  : LeadTrigger  @Company  : Fingertip    @Created Date  : 08-4-2025  
@description : lead object trigger   @author  :Nachiketha   @User By  : - LeadTriggerHandler
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  08-4-2025 |   Initial version      
* -------------------------------------------------------------------
**************************************************************** */   
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            LeadTriggerHandler.mapFIeldsBeforeInsert(trigger.New);
        }
         if(Trigger.isUpdate) {
            LeadTriggerHandler.mapFIeldsBeforeUpdate(trigger.New,trigger.oldMap);
        }
    } 
        if(Trigger.isAfter) {
              if(Trigger.isInsert) {
            LeadTriggerHandler.leadTriggerAfterInsert(Trigger.New);
        }
        }
   
}