angular.module('footsy')
  .controller 'AppCtrl', ($scope) ->

    # Initialise
    console.log 'Init AppCtrl'
    $scope.groups = {}

    # Fetch data from server
    $.get '/api/groups', (groups) ->
      for group in groups
        $scope.groups[group._id] = group
