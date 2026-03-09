trigger Visit_Trigger on Visit__c (before insert) {
    
      if(trigger.isInsert && trigger.isBefore){
        visitTrigger_Handler.mapFIeldsBeforeInsert(trigger.New);
    }

}