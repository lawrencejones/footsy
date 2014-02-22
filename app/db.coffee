mongo  = require 'mongodb'

# Takes app config as parameter
module.exports = (config, collections = []) ->

  # Deal with storing scores
  server = new mongo.Server config.DB_HOST, config.DB_PORT, {
    auto_reconnect: true
  }
  db     = new mongo.Db config.DB_NAME, server, { safe: true }

  # List all the mongodb connections
  seeds = {}; for c in collections
    seeds[c] = (require "./#{c}_seed")[c]

  # Push seed data into database
  seed = (cname, data = seeds[cname]) ->
    db.collection cname, (err, collection) ->
      collection.insert data, {safe:true}, (err, res) ->
        if err
          console.log "Failed to insert into collection"
          process.exit 1

  # Open db and seed if required
  db.open (err, db) ->
    if not err
      console.log "Connected to db!"
      for cname in collections
        db.collection cname, {strict: true} , (err, collection) ->
          if err
            cname = err
              .toString()
              .match(/(Collection )(\w+)( does not exist)/)?[2]
            console.log """The '#{cname}' collection doesn't exist.
                           Creating a new collection with sample data."""
            seed cname
    else
      console.log 'Failed to connect to mongodb.'

  return db

