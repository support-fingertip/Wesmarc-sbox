({
    doInit : function(component, event, helper) {
        try{
            component.set('v.spinner', true);
            var action = component.get("c.attendanceList");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.spinner', false);
                    component.set("v.attId", response.getReturnValue());
                } else {
                    component.set('v.spinner', false);
                    console.error("Error fetching field value:", response.getError());
                }
            });
            
            $A.enqueueAction(action);
        }catch(error){
            console.error(error.message);
        }
    },

    handleStart : function(component, event, helper) {
        try{
            component.set('v.spinner', true);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    var currentlat = positionIn.coords.latitude;
                    var currentlon = positionIn.coords.longitude;
                    component.set('v.StartTime', positionIn);
                    helper.helperSaveStartDay(component, event, helper);
                    component.set('v.spinner', false);
                }, function (err) {
                    component.set('v.spinner', false);
                    helper.catchError(err, helper);
                }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });
                
            } else {
                helper.showToast("Geo Location is not supported", "Error");
            }
            
        }catch(error){
            console.error(error.message);
        }
    },

    handleEnd : function(component, event, helper) {
        try{
			component.set('v.spinner', true);            
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    var currentlat = positionIn.coords.latitude;
                    var currentlon = positionIn.coords.longitude;
                    component.set('v.EndTime', positionIn);
                    helper.helperSaveEndDay(component, event, helper);
                    component.set('v.spinner', false);
                }, function (err) {
                    component.set('v.spinner', false);
                    helper.catchError(err, helper);
                }, { enableHighAccuracy: true, maximumAge: Infinity, timeout: 60000 });
                
            } else {
                helper.showToast("Geo Location is not supported", "Error");
            }
            
        }catch(error){
            console.error(error.message);
        }
    }
})