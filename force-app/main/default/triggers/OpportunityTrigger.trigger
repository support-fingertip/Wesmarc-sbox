trigger OpportunityTrigger on Opportunity (after update) {
/**************************************************************** 
* Trigger Name : OpportunityTrigger  @Company  : Fingertip    @Created Date  : 21-05-2025  
@description : Opportunity object trigger   @author  :Nachiketha   @User By  : - OpportunityTriggerHandler
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  21-05-2025   |   Initial version      
* -------------------------------------------------------------------
**************************************************************** */
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            OpportunityTriggerHandler.caseCreation(Trigger.New);
        }
    }
}