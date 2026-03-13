/**************************************************************** 
* Class Name  : OpportunityTriggerHandler  @Company  : Fingertip    @Created Date  : 21-05-2025  
* @description : Opportunity object trigger handler   @author  :Nachiketha    
* Change Log: 
* ----------------------------------------------------------------------------- 
* Ver |   Author      |   Date        |   Description 
* ----------------------------------------------------------------------------- 
* 1.0 |   Nachiketha  |  21-05-2025   |   Initial version      
* -------------------------------------------------------------------
**************************************************************** */
public class OpportunityTriggerHandler {
    
    /*  Method Name: caseCreation  
     *  Date: 07/04/2025  @author: Nachiketha  
     *  @description: Creates related case records
	 *  @parameters: Opportunity list */ 
    public static void caseCreation(List<Opportunity> listOpp) {
        List<Case> lstCase = new List<Case>();
        
        for(Opportunity opp : listOpp) {
            if(opp.StageName == 'JAMR') {
                Case cs = new Case();
                cs.AccountId = opp.AccountId;
                cs.Subject = opp.Name+' Opportunity Status Updated to JAMR';
                cs.Case_Reason__c = 'Opportunity Status Update';
                cs.Opportunity__c = opp.Id;
                cs.Priority = 'Medium';
                cs.Type = 'JAMR';
                cs.Status = 'New';
                cs.Origin = 'Phone';
                lstCase.add(cs);
            }
            if(opp.StageName == 'Installation') {
                Case cs = new Case();
                cs.AccountId = opp.AccountId;
                cs.Subject = opp.Name+' Opportunity Status Updated to Installation';
                cs.Case_Reason__c = 'Opportunity Status Update';
                cs.Opportunity__c = opp.Id;
                cs.Priority = 'Medium';
                cs.Type = 'Installation';
                cs.Status = 'New';
                cs.Origin = 'Phone';
                lstCase.add(cs);
            }
        }
        if(!lstCase.isEmpty()) {
            insert lstCase;
        }
    }
}