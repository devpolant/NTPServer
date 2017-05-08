
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

var markers = [];

function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 7,
    center: {lat: 50.0, lng: 36.2 }
  });

  map.addListener('click', function(e) {
    placeMarkerAndPanTo(e.latLng, map);
  });
}

function placeMarkerAndPanTo(latLng, map) {
    clearMarkers();
    var marker = new google.maps.Marker({
        position: latLng,
        animation: google.maps.Animation.DROP,
        map: map
    });
    markers.push(marker);
    map.panTo(latLng);
}

function clearMarkers() {
    for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(null);
    }
    markers = [];
}

function selectedLocation() {
    return markers[0].getPosition();
}