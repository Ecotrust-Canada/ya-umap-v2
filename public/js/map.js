
var map = L.map('map', {
  center: [49.104430, -122.801094],
  zoom: 11,
  zoomControl: false
});

//add zoom control with your options
L.control.zoom({
     position:'bottomleft'
}).addTo(map);

// https: also suppported.
var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});
var OpenStreetMap_BlackAndWhite = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
  maxZoom: 18,
  attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
});

map.addLayer(OpenStreetMap_BlackAndWhite);

map.locate({setView: true, maxZoom: 12});

bounds = map.getBounds();
url = "parks/within?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;  

var geo;

myStyle = {
    fillColor: "#ffaa00",
    color: "#000",
    weight: 2,
    opacity: 0.7,
    fillOpacity: 0.1
}

ajax().get('../js/surrey_4326.json').then(function(response){
  L.geoJson(response, {style:myStyle}).addTo(map);
});


function getSoil(e){
  if (geo) map.removeLayer(geo);
  var bounds = map.getBounds();
  var url = "soil/within?lat1=" + bounds.getSouthWest().lat + "&lon1=" + bounds.getSouthWest().lng + "&lat2=" + bounds.getNorthEast().lat + "&lon2=" + bounds.getNorthEast().lng;
  var request = ajax().get(url).then(function(response){
    geo = {
      "type": "FeatureCollection",
      "features": JSON.parse(response)
    }
    geo = L.geoJson(geo, {
      style:{
        "color": "#ff7800",
        "weight": 5,
        "opacity": 0.65
      }
    }).addTo(map);
  });
}


var markers = new L.MarkerClusterGroup({
  maxClusterRadius: 20,
  iconCreateFunction: function(cluster) {
    
    // get most frequent category for coloring.
    var counters = {};
    var highest_counter_value = 0;
    var highest_counter = null;

    cluster.getAllChildMarkers().forEach(function(marker){
      var cn = marker.item.category.name.toLowerCase();
      counters[cn] = (counters[cn] || 0) + 1;
      if (counters[cn] > highest_counter_value) {
        highest_counter_value = counters[cn];
        highest_counter = marker.item.category;
      }
    });

    //console.log(counters, highest_counter);

    return new L.DivIcon({
      iconSize: [25, 25],
      html: '<div class="cluster-icon '
        +slug(highest_counter)
        +'"><div class="filled">' + cluster.getChildCount() + '</div></div>'
    });
  }
});


map.addLayer(markers);

pubsub.on('load', function(response){
  updateMarkers(response);
});


function updateMarkers(response){
  markers.clearLayers();

  for (var i = 0; i < response.length; i++) {
    var listing = response[i];
    if (listing.latitude && listing.longitude) {

      var the_slug = slug(listing.category);
      var title = listing.name;
      var marker = L.marker(new L.LatLng(listing.latitude, listing.longitude), {
        icon: L.divIcon({
          html:'<div class="map-icon '
            + slug(listing.category)
            + '"><div class="filled"></div></div>',
          iconSize: [12, 12],
          iconAnchor: [6, 6],
          popupAnchor: [3, 0]
        }),
        title: title
      });

      // link items to markers and vice versa.
      marker.item = listing;
      listing.marker = marker;

      marker.bindPopup(
      "<div class='popup'>"
        +"<div class='listing-icon' style='background-image:url(../images/icon/category/" + the_slug + ".png)'></div>"
        +"<label class='" + the_slug + "'>" + listing.category.name + "</label>"
          +"<p class='description'>" + listing.name + "</p><p class='city'>" + listing.city + "," + listing.province+"</p>"
        +"<div data-id='" + listing.id + "' class='info " + the_slug +"'>MORE INFO"
          +"<div class='triangle-arrow filled'></div>"
        +"</div>"
      +"</div>"
      );
      markers.addLayer(marker);
    }
  }
}

pubsub.on('zoom_to', function(marker){ 
    //map.setZoom(12);
    map.panTo(marker.getLatLng());
    markers.zoomToShowLayer(marker, function() {
      map.panTo(marker.getLatLng());
      marker.openPopup();
    });
})
/*
map.on('dragend', getSoil);
map.on('zoomend', getSoil);
map.whenReady(getSoil);
*/

