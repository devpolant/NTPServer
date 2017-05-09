var markers = [];
var map;

function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
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
