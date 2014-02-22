routeHome = (db) ->

  # GET /
  index: (req, res) ->
    res.render 'home', {  # render home
      title: 'Footsy'
    }
 
  # POST / route for posting a new group
  # return html view for 

  # POST / request for joining a group
  
  

# Takes app and appropriate parameters for route config
module.exports = (app, db) ->

  home = routeHome db

  # Routes for homepage
  app.get  '/',           home.index

