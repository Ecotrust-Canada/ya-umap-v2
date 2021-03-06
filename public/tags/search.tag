
<search>

  <input placeholder="Search: ie) Bees, Soil, etc." name="q" class="search-box search-box-map" onkeyup={ onfilter }>

  <div class='category-toggle toggle' onclick={ toggle }>
    <div class='notification' if={ num_cats_showing() }>{ num_cats_showing() }</div>
    CATEGORY
  </div>
  <ul if={ showing } class='category-panel panel'>
    <li each={ key, value in categories } class='panel-item' value="{ key }" onclick={ oncategorize }>
      { key }
      <span if={ value.showing } class='on'>&#x2714;</span>
    </li>
  </ul>

  this.categories = opts.categories;
  
  var controller = this
     ,query = opts.kwargs['q']
     ,category = opts.kwargs['c']
     ,orig_listings
     ,showing=false;

  num_cats_showing(){
    var num_cats = Object.keys(controller.categories).filter(function(cat){ return controller.categories[cat].showing; }).length;
    return num_cats;
  }

  toggle(){
    controller.showing = !controller.showing;
  }

  function listing_visible(item){
    var include = 
      (category_cache[item.category.name])
      &&
      (!query || (item.name.indexOf(query) > -1));
    return include;
  }

  onfilter(e){
    query = e.target.value;
    filter_listings();
  }

  oncategorize(e){
    controller.categories[e.item.key].showing = !controller.categories[e.item.key].showing;
    filter_listings();
  }

  opts.on('initial_load', function(listings){
    orig_listings = listings;

    /*
    var cats = {};

    listings.forEach(function(listing){
      cats[listing.category.name] = listing.category;
    });
    for (var k in cats) {
      controller.categories.push(cats[k]);
    }
    controller.update({
      categories: controller.categories
    });
    */
    
    // initial categories    
    if (category) {
      controller.categories[category].showing = true
      controller.update();
      opts.trigger('categorize', controller.categories);
    }

    // initial query.
    if (query) {
      controller.q.value = query;
    }

    filter_listings();

  });
  

  function filter_listings(){
    category_cache = {};
    for(var cat in controller.categories) {
      if(controller.categories[cat].showing) controller.categories[cat].tags.forEach(function(tag){
        category_cache[tag] = 1;
      }); 
    }

    var current_listings = [];
    var matches = 0;

    for (var i=0; i<orig_listings.length; i++) {

      if (listing_visible(orig_listings[i])) {
        current_listings.push(orig_listings[i]);
        matches ++;
        //if (matches > 50) return results;
        orig_listings[i].show = true;
      } else {
        orig_listings[i].show = false;
      }
    }
    opts.trigger('load', current_listings);
  }

</search>