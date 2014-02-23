angular.module('footsy')
  .controller 'AppCtrl', ($scope) ->

    # Initialise
    console.log 'Init AppCtrl'
    $scope.groups    =  {}
    $scope.requests  =  []

    # Fetch data from server
    $.get '/api/groups', (groups) ->
      for group in groups
        $scope.groups[group._id] = group
      $scope.$apply()

    $scope.clickRow = (group) ->
      group.marker.toggleInfo()

    initialiseSockets = ->

      # Initialise socket
      socket = io.connect window.location.origin
      
      # Create a new mapping
      for event in ['create', 'update']
        socket.on event, (group) ->
          console.log " >> EVENT [create/update]"
          console.log group
          _group = $scope.groups[group._id]
          if _group? and _group != null
            angular.extend _group, group
          else
            $scope.groups[group._id] = group
          $scope.$apply()

      # Delete a group from the collection
      deleteGroup = (group) ->
        console.log " >> EVENT [delete]"
        _group = $scope.groups[group._id]
        _group?.marker?.setMap? null
        delete $scope.groups[group._id]
        $scope.$apply()

      # Delete single
      socket.on 'delete', deleteGroup
      # Delete all
      socket.on 'delete all', ->
        deleteGroup group for group in groups

      # Listen for a join request
      socket.on 'request', (gid) ->
        console.log " >> EVENT [request]"
        $scope.requests.push $scope.groups[gid]

      # Identify my connection
      socket.on 'identify', ->
        console.log sessionStorage.gid
        if not sessionStorage.gid? and sessionStorage.gid.trim() != ''
          socket.emit 'checkin', sessionStorage.gid
        else $.get '/whoami', (gid) ->
          sessionStorage.gid = gid
          socket.emit 'checkin', gid

    (waitForIo = ->
      if typeof io == 'undefined' then setTimeout waitForIo, 100
      else initialiseSockets())()






