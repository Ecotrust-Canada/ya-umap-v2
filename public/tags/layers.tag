<layers>

  <div class='layer-toggle' onclick={ toggle }>

  </div>

  <ul class='layer-panel' if={ showing }>
    <li class='layer' each={ wms_layers } onclick={ layer_on_off }>
      { name } <span if={ map_has_layer(layer) } class='on'>&#x2714;</span>
    </li>
  </ul>

  var controller=this
    , showing=false;

  controller.wms_layers = wms_layers;

  toggle(){
    controller.showing = !controller.showing;
  }

  map_has_layer(layer){
    return map.hasLayer(layer);
  }

  layer_on_off(e){
    if (map.hasLayer(e.item.layer)) {
      map.removeLayer(e.item.layer);
    }
    else{
      map.addLayer(e.item.layer);
    }
  }


</layers>
