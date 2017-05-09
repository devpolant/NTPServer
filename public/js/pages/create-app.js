
$(document).ready(function () {
    var token = getToken();
    $("#app-send-button").on("click", function () {

        var name = $("#inputAppName").val();
        var markerPosition = selectedLocation();
        var location = markerPosition.lat() + ";" + markerPosition.lng();
        var socialGroup = $("#inputGroupName").val();
        $.ajax({
            url:"http://localhost:8090/dashboard/apps/create",
            type:"POST",
            data: { 
                token: token,
                name: name,
                location: location,
                social_group: socialGroup
            },
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            success:function(data){
                console.log(data);
                try {
                    if(!data.error) {
                        window.location = '/dashboard';
                    } 
                } catch(err) {
                    alert(err.message);
                }
            },
            error:function(err) {
				console.log('Ошибка');
				console.log(err);
            }
        });

    });
});
