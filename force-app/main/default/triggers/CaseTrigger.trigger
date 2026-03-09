trigger CaseTrigger on Case (before insert,after insert,after update) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            CaseTriggerHandler.caseInsert(Trigger.New);
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            CaseTriggerHandler.handlecaseBeforeInsert(Trigger.New);
        }
    }
    
     if(Trigger.isAfter) {
         if(Trigger.isUpdate) {
            CaseTriggerHandler.caseAfterUpdate(Trigger.New,trigger.oldMap);  
         }
     }
}