({
    submitVisit : function(component, event, helper) {
        try{
            component.set('v.spinner', true);
            event.preventDefault();
            const fields = event.getParam('fields');
            var positionIn = component.get('v.checkedOut');
            fields["Status__c"] = 'Missed';
            component.find('visit').submit(fields);
            component.set('v.spinner', false);
        }catch(error){
            console.error(error.message);
        }
        
        
    },
  
    catchError : function(error,helper) {
        
        switch(error.code)
        {
            case error.TIMEOUT:
                helper.showToast("The request to get user location has aborted as it has taken too long.");
                break;
            case error.POSITION_UNAVAILABLE:
                helper.showToast("Location information is not available.");
                break;
            case error.PERMISSION_DENIED:
                helper.showToast("Permission to share location information has been denied!");
                break;
            default:
                helper.showToast("An unknown error occurred.");
        }
    },  
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    
})