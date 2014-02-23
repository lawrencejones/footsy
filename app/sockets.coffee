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
    socket.on 'checkin', (gid) ->
      console.log "Group #{gid} identified itself"
      Group.findById(gid).exec (err, group) ->
        if group?
          console.log "Group #{gid} verified"
          sockets[gid] = socket.id
        socket.on 'disconnect', ->
          console.log 'Socket disconnected!'
          console.log gid
          Group.findByIdAndRemove gid, (err) ->
            broadcast 'delete', group
            delete sockets[gid]


  # Given a group id, group event and data, will pipe
  # down to client via the open socket
  sendToId = (gid, event, data) ->
    sid = sockets[gid]
    io.sockets.socket(sid).emit event, data

  # Broadcasts event with data to all sockets
  broadcast = (event, data) ->
    for own gid,sid of sockets
      Group.findById(gid).exec (err, addressee) ->
        if not addressee?
          delete sockets[gid]
        else
          console.log "Emitting event #{event} to #{gid}"
          sendToId gid, event, data

  return {
    sendToId:  sendToId
    broadcast: broadcast
  }
   

