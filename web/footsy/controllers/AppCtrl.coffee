angular.module('footsy')
  .controller 'AppCtrl', ($scope) ->
    console.log 'Init AppCtrl'
    $scope.groups = {}
    $.get '/api/groups', (groups) ->
      for group in groups
        $scope.groups[group._id] = group
