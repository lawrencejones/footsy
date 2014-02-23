sockets = {}

calcDis = (ll, _ll) ->
  x = (_ll.e - ll.e) * Math.cos ((ll.d+_ll.d)/2)
  y = _ll.d-ll.d
  Math.sqrt (x*x + y*y) * 6341 # radius of the planet

module.exports = (server, Group) ->
  
  # Require socket.io, listen on port 9000
  io = require('socket.io').listen server

  # On incoming connection, configure socket
  io.sockets.on 'connection', (socket) ->
    console.log 'New group connected!'
    socket.emit 'identify'
    socket.on 'checkin', (groupId) ->
      console.log "Group #{groupId} identified itself"
      Group.findById(groupId).exec (err, group) ->
        if group?
          console.log "Group #{groupId} verified"
          sockets[groupId] = socket.id
          socket.gid = groupId
    socket.on 'disconnect', ->
      console.log 'Socket disconnected!'
      Group.findByIdAndRemove socket.gid, (err, group) ->
        broadcast 'delete', group if group?
        delete sockets[group?._id]


  # Given a group id, group event and data, will pipe
  # down to client via the open socket
  sendToId = (gid, event, data) ->
    sid = sockets[gid]
    io.sockets.socket(sid).emit event, data

  # Broadcasts event with data to all sockets
  broadcast = (event, group) ->
    for own gid,sid of sockets
      Group.findById(gid)
        .exec (err, result) ->
          return if not (group && result)
          d = calcDis group.latlng, result.latlng
          console.log d
          if d < 5
            console.log "Emitting event #{event} to #{gid}"
            sendToId gid, event, group

  return {
    sendToId:  sendToId
    broadcast: broadcast
  }
   

