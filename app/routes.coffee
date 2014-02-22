routeHome = (db) ->

  # GET /
  index: (req, res) ->
    res.render 'home', {  # render home
      title: 'Footsy'
    }
        

# Takes app and appropriate parameters for route config
module.exports = (app, db) ->

  home = routeHome db

  # Routes for homepage
  app.get  '/',           home.index

