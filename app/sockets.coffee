# Require socket.io, listen on port 9000
io = require('socket.io').listen 9000
sockets = {}

module.exports = (Group) ->
  
  # On incoming connection, configure socket
  io.sockets.on 'connection', (socket) ->
    console.log 'New group connected!'
    socket.emit 'identify'
    socket.on 'checkin', (groupId) ->
      console.log "Group #{groupId} identified itself"
      Group.findById(groupId).exec (err, group) ->
        if group?
          console.log 'Group #{groupId} verified'
          sockets[groupId] = socket.id

  # Given a group id, group event and data, will pipe
  # down to client via the open socket
  sendToId = (gid, event, data) ->
    sid = sockets[gid]
    io.sockets.socket(sid).emit event, data

  # Broadcasts event with data to all sockets
  broadcast = (event, data) ->
    for own gid,sid of sockets
      console.log "Emitting event #{event} to #{gid}"
      sendToId gid, event, data

  return {
    sendToId:  sendToId
    broadcast: broadcast
  }
   

