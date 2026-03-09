({
	 handleSubmit: function (component, event, helper) {
          component.set('v.spinner', true);
        if (navigator.geolocation) {
            
            navigator.geolocation.getCurrentPosition(function (positionIn) {
                
                var currentlat = positionIn.coords.latitude;
                var currentlon = positionIn.coords.longitude;
                component.set('v.checkedOut', positionIn);
                component.set('v.spinner', false);
                helper.submitVisit(component, event, helper);
            }, function (err) {
                component.set('v.spinner', false);
                helper.catchError(err, helper);
            }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });
            
        } else {
            helper.showToast("Geo Location is not supported", "Error");
        }
    },
    handleSuccess : function(component ,event , helper){
        var record = event.getParam("response");
          helper.showToast("You Missed this Visit", "success");
           $A.get('e.force:refreshView').fire();   
      $A.get("e.force:closeQuickAction").fire();
      
     
    },
    handleError: function (component, event, helper) {
        component.set('v.spinner', false);
        var errorMessage = event.getParam("message"); 
        console.error(errorMessage);
       helper.showToast("There is some technical Issue, Please try again or contact System Admin.", "error");
    },
      closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();    
        $A.get('e.force:refreshView').fire();   
    },
})