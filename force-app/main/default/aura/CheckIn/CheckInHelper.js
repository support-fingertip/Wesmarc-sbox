({

  helperSaveCheckIn : function (component, event,helper) {
      try{
        component.set('v.spinner', true);
        var positionIn = component.get('v.checkedIn');
        var action = component.get("c.updateVisitCheckIn");
        action.setParams({ 
            latitude: positionIn.coords.latitude,
            longitude: positionIn.coords.longitude,
            visitId:  component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var actionResponse = response.getState();
            if (actionResponse == "SUCCESS") {
                  component.set('v.spinner', false);
                helper.showToast("Checked In Successfully..!", "success");
                $A.get("e.force:closeQuickAction").fire();
                  $A.get('e.force:refreshView').fire();  
                
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