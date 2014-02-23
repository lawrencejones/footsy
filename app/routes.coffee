routeHome = (Group) ->

  # GET /
  index: (req, res) ->
    res.render 'home', {  # render home
      title: 'Footsy'
    }

  # GET /signin
  signin: (req, res) ->
    res.render 'signin'

  # Redirects to signin if not registered
  redirect: (req, res, next) ->
    if req.session?.group_id?
      Group.findById(req.session.group_id).exec (err, group) ->
        if group? then next()
        else res.redirect '/signin'
    else res.redirect '/signin'


routeGroup = (Group, sockets) ->

  # GET /groups
  # Returns an index of all the groups
  index: (req, res) ->
    Group.find({}).exec (err, groups) ->
      return res.send 500 if err
      res.send groups

  # DELETE /groups
  # Clears all groups
  deleteAll: (req, res) ->
    Group.remove {}, (err) ->
      console.log 'Deleted all records'
      # sockets.broadcast 'deleteall', {}
      res.send 200

  # GET /group/:id
  # Returns a single group element
  findById: (req, res) ->
    query = Group.findById req.params.id
    query.exec (err, group) ->
      return res.send 500 if err
      res.send group

  # POST /groups/(name, size, latlng)
  # Create a new group with the parameters
  create: (req, res) ->
    Group.create req.body, (err, group) ->
      return res.send 400 if err
      sockets.broadcast 'create', group
      req.session.group_id = group._id
      res.send group

  # DELETE /group/:id
  # Remove group from database
  deleteById: (req, res) ->
    Group.findByIdAndRemove req.params.id, (err, group) ->
      if group != null
        sockets.broadcast 'delete', group
      res.send 200

  # PUT /group/:id
  # Update group with given params
  updateById: (req, res) ->
    Group.findOneAndUpdate {
      _id: req.params.id
    }, { $set: req.body }, (err, group) ->
      sockets.broadcast 'update', group
      res.send group
  
  # POST /api/group/:id/request
  # Log a request
  request: (req, res) ->
    sockets.sendToId req.params.id, 'request', req.session.group_id
    res.send 200

  # POST /api/group/:id/accept
  # Accept a request
  accept: (req, res) ->
    Group.findByIdAndRemove req.params.id, (err, joining) ->
      sockets.broadcast 'delete', joining
      Group.findById req.session.group_id (err, group) ->
        group.add(joining.size)
        sockets.broadcast 'update', group
        sockets.sendToId req.params.id, 'accept', req.session.group_id
        res.send 200

# Takes app and appropriate parameters for route config
module.exports = (app, db, sockets) ->

  # Run route generation
  home    = routeHome    db.models.Group
  group   = routeGroup   db.models.Group, sockets

  # Routes for homepage
  app.get  '/',               home.redirect, home.index
  app.get  '/signin',         home.signin

  # Whoami for querying group_id
  app.get  '/whoami',  (req, res) ->
    res.send req.session.group_id

  # Routes for api
  app.get    '/api/groups',      group.index
  app.post   '/api/groups',      group.create
  app.delete '/api/groups',      group.deleteAll
  app.get    '/api/group/:id',   group.findById
  app.delete '/api/group/:id',   group.deleteById
  app.put    '/api/group/:id',   group.updateById

  # Routes for requests
  app.post   '/api/group/:id/request',     group.request
  app.post   '/api/group/:id/accept',      group.accept

