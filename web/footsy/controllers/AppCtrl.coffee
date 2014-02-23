angular.module('footsy').service 'Me', ->
  this.gid = null


angular.module('footsy').directive 'modal', ->
  restrict: 'C'
  link: (scope, $elem, attr) ->
    do $elem.modal

angular.module('footsy')
  .controller 'AppCtrl', ($scope) ->

    # Initialise
    console.log 'Init AppCtrl'
    $scope.groups = {}
    $scope.requests = []

    # Fetch data from server
    $.get '/api/groups', (groups) ->
      for group in groups
        $scope.groups[group._id] = group

    initialiseSockets = ->
      # Initialise socket
      socket = io.connect "http://#{window.location.hostname}:9000"
      
      # Create a new mapping
      for event in ['create', 'update']
        socket.on event, (group) ->
          _group = $scope.groups[group._id]
          if _group?
            angular.extend _group, group
          else
            $scope.groups[group._id] = group

      # Delete a group from the collection
      deleteGroup = (group) ->
        _group = $scope.groups[group._id]
        _group.marker?.setMap? null
        $scope.groups[group._id] = null

      # Delete single
      socket.on 'delete', deleteGroup
      # Delete all
      socket.on 'delete all', ->
        deleteGroup group for group in groups

      # Listen for a join request
      socket.on 'request', (gid) ->
        $scope.requests.push $scope.groups[gid]

    (waitForIo = ->
      if typeof io == 'undefined' then setTimeout waitForIo, 100
      else initialiseSockets())()






