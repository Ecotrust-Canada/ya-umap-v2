<listing>

  <div class='listing-detail' if={ listing }>
    <div class='listing-header { slug(listing.category) }'>
      <div class='category-icon' style='background-image:url(../images/icon/category/{ slug(listing.category) }.png)'></div>
      { listing.category.name }
      <img src="../images/umap-content-title.png">
      <div class="filled"></div>
    </div>
    <div class='back' onclick={ close }>Return to Listings</div>
    <h1>{ listing.name }</h1>
    <p>{ listing.description }</p>
    <h3>Learn More</h3>
    <p><a href="{ url }">{ listing.url }</a></p>
    <p>{ listing.street_address }, { listing.city }, { listing.province }, { listing.postal }</p>
  </div>

  var controller = this;
    
  slugify(category) {
    return slug(category)
  }
  
  close(){
    controller.listing = null;
  }

  opts.on('detail', function(listing_id){
    var listing = controller.listings.filter(function(l){return l.id == listing_id})[0];
    console.log(listing)

    controller.update({
      listing: listing
    });
  });

  opts.on('load', function(listings){
    controller.listings = listings;
    });
</listing>