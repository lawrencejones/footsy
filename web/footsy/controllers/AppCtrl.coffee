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

    initialiseSockets = ->
      # Initialise socket
      socket = io.connect 'http://localhost'
      
      # Create a new mapping
      for event in ['create', 'update']
        socket.on event, (group) ->
          console.log " >> EVENT [create/update]"
          _group = $scope.groups[group._id]
          if _group?
            angular.extend _group, group
          else
            $scope.groups[group._id] = group
          $scope.$apply()

      # Delete a group from the collection
      deleteGroup = (group) ->
        console.log " >> EVENT [delete]"
        _group = $scope.groups[group._id]
        _group.marker?.setMap? null
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
        socket.emit 'checkin', sessionStorage.gid

    (waitForIo = ->
      if typeof io == 'undefined' then setTimeout waitForIo, 100
      else initialiseSockets())()






