({
    doInit : function(component, event, helper) {
        try{
            component.set('v.spinner', true);
            var action = component.get("c.convertLead");
            action.setParams({ 
                leadId:  component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var actionResponse = response.getState();
                if (actionResponse == "SUCCESS") {
                    component.set('v.spinner', false);
                     var result = response.getReturnValue();
                    if(result){
                    helper.showToast("Lead Converted Successfully..!", "success");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();  
                    } 
                }else{
                    component.set('v.spinner', false);
                    helper.showToast("There is some technical Issue, Please try again or contact System Admin.", "error");
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            });
            $A.enqueueAction(action);
        }catch(error){
            console.error(error.message);
        }
    },
  
})