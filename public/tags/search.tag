
<search>
  <form class='results-search-form' onsubmit={ add }>
    <input placeholder="Enter keyword or location" class="search-box" onkeyup={ onfilter }><select onchange={ oncategorize }>
      <option value="">All categories</option>
      <option each={categories} value="{ name}">{ name }</option>
    </select>
  </form>

  this.categories = [];
  var controller = this;

  onfilter(e){
    opts.trigger('filter', e.target.value);
  }

  oncategorize(e){
    opts.trigger('categorize', e.target.value);
  }

  opts.on('load', function(listings){
    var cats = {};
    listings.forEach(function(listing){
      cats[listing.category.name] = listing.category;
    });
    for (var k in cats) {
      controller.categories.push(cats[k]);
    }
    controller.update({
      categories: controller.categories
      })
  });

</search>