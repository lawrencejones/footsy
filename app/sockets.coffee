# Require socket.io, listen on port 9000
io = require('socket.io').listen 9000
sockets = {}

Number.prototype.toRad = () ->
  return this * Math.PI / 180

distanceBetweenLatLng = (ll1, ll2) ->
  R = 6371
  lat1 = ll1.e
  lon1 = ll1.d
  lat2 = ll2.e
  lon2 = ll2.d
  console.log lat1
  console.log lon1
  console.log lat2
  console.log lon2
  dLat = (lat2-lat1).toRad()
  dLon = (lon2-lon1).toRad()
  lat1 = lat1.toRad()
  lat2 = lat2.toRad()

  a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  d = R * c

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
  broadcast = (event, group) ->
    for own gid,sid of sockets
      query = Group.findById(gid)
      query.exec (err, result) ->
        console.log group.latlng
        console.log result.latlng
        d = distanceBetweenLatLng(group.latlng, result.latlng)
        console.log d
        if d < 1.5
          console.log "Emitting event #{event} to #{gid}"
          sendToId gid, event, group

  return {
    sendToId:  sendToId
    broadcast: broadcast
  }
   

