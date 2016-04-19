
var
    restify     = require('restify'),
    fs          = require('fs'),
    app = restify.createServer();

app.use(restify.queryParser())
app.use(restify.CORS())
app.use(restify.fullResponse())
 


var pg = require('pg');
var conString = "postgres://postgres:postgres@db/postgres";
var psql;

//this initializes a connection pool
//it will keep idle connections open for a (configurable) 30 seconds
//and set a limit of 10 (also configurable)
pg.connect(conString, function(err, client, done){
  if(err) throw err;
  psql = client;
  done();
});

function select_box(req, res, next){
  //clean our input variables before forming our DB query:
  console.log(Object.keys(req));
  var query = req.query;
  var limit = (typeof(query.limit) !== "undefined") ? query.limit : 40;
  if(!(Number(query.lat1) 
    && Number(query.lon1) 
    && Number(query.lat2) 
    && Number(query.lon2)
    && Number(limit)))
  {
    res.send(500, {http_status:400,error_msg: "this endpoint requires two pair of lat, long coordinates: lat1 lon1 lat2 lon2\na query 'limit' parameter can be optionally specified as well."});
    return console.error('could not connect to postgres', err);
  }
  psql.query('SELECT ST_AsGeoJSON(geom) FROM soil WHERE ST_Intersects( ST_MakeEnvelope('+query.lon1+", "+query.lat1+", "+query.lon2+", "+query.lat2+", 4326), soil.geom) LIMIT "+limit+";", function(err, result) {

    console.log(result);
    if(err) {
      res.send(500, {http_status:500,error_msg: err})
      return console.error('error running query', err);
    }
    res.send("[" + result.rows.map(function(i){return i.st_asgeojson}).join(',') + "]");
    return result;
  })
};

// Routes
app.get('/soil/within', select_box);


app.get(/\/(html|css|vendor|js|tags|images)\/?.*/, restify.serveStatic({
  directory: './public',
  default: 'index.html'
}));
 

app.listen(3000, '0.0.0.0', function () {
});


