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
      socket.gid = gid
      Group.findById(gid).exec (err, group) ->
        if group?
          console.log "Group #{gid} verified"
          sockets[gid] = socket.id
        socket.on 'disconnect', ->
          console.log 'Socket disconnected!'
          delete sockets[this.gid]
          Group.findByIdAndRemove this.gid, (err, group) ->
            console.log group
            broadcast 'delete', group


  # Given a group id, group event and data, will pipe
  # down to client via the open socket
  sendToId = (gid, event, data) ->
    sid = sockets[gid]
    io.sockets.socket(sid).emit event, data

  # Broadcasts event with data to all sockets
  broadcast = (event, data) ->
    console.log sockets
    for own gid,sid of sockets
      Group.findById(gid).exec (err, addressee) ->
        console.log "Emitting event #{event}"
        console.log addressee
        sendToId addressee._id, event, data

  return {
    sendToId:  sendToId
    broadcast: broadcast
  }
   

