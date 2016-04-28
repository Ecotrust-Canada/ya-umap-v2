
<results>


  <div class='results-sidebar'>
    <div class="content-logo-wrap">
      <img src="../images/umap-text.png">
    </div>

    <ul class='results-list'>
      <li each={ whatShow(items) }>
        <div class='listing-icon'
             style='background:url(../images/icon/category/{ slugify(category) }.png) 10px 10px no-repeat'
        ></div>
        <p class='listing-text'>
          <label class='{ slugify(category) }'>{ category.name }</label>
          { name }<br>
          <span if={ city } class='city'>{ city }, { province }</span>
        </p>
        <div if={ latitude } class='view-on-map { slugify(category) }' onclick={ view_on_map }>
          VIEW ON<br>MAP
          <div class='triangle-arrow filled'></div>
        </div>
      </li>
    </ul>

  </div>

  <!-- this script tag is optional -->
  <script>
    var controller = this;
    this.items = opts.items
    
    view_on_map(e) {
      //map.setZoom(12);
      map.panTo(e.item.marker.getLatLng());
      markers.zoomToShowLayer(e.item.marker, function() {
        map.panTo(e.item.marker.getLatLng());
        e.item.marker.openPopup();
      });
    }
   
    slugify(category) {
      return slug(category)
    }

    // an two example how to filter items on the list
    whatShow(items) {
      var results = [], matches = 0;

      for (var i=0; i<items.length; i++) {

        if (listing_visible(items[i])) {
          results.push(items[i]);
          matches ++;
          //if (matches > 50) return results;
        } else {
          items[i].show = false;
        }
      }

      return results;
    }

    function listing_visible(item){
      var include = 
        (!controller.categorize || controller.categorize === item.category.name)
        &&
        (!controller.filter || (item.name.indexOf(controller.filter) > -1));
      return include;
    }
    
    var markers;

    ajax().get('../js/locations.json').then(function(response){

      controller.update({
        items: response
      });

      markers = new L.MarkerClusterGroup({
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

      updateMarkers();
      map.addLayer(markers);

      opts.trigger('load', response);
    });

    opts.on('categorize', function(value){
      controller.update({
        categorize: value
        });
      updateMarkers();
    });

    opts.on('filter', function(value){
      console.log('filter `'+value+'`');
      controller.update({
        filter: value
        });
      updateMarkers();
    });

    function updateMarkers(){
      markers.clearLayers();
      for (var i = 0; i < controller.items.length; i++) {
        var listing = controller.items[i];
        if (listing.latitude && listing.longitude && listing_visible(listing)) {

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

  </script>

</results>
