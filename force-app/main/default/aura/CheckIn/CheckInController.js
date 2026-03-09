({
	doInit : function(component, event, helper) {
        try{
         
        component.set('v.spinner', true);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (positionIn) {
                    var currentlat = positionIn.coords.latitude;
                    var currentlon = positionIn.coords.longitude;
                    component.set('v.checkedIn', positionIn);
                    helper.helperSaveCheckIn(component, event, helper);
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
})