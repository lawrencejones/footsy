angular.module('footsy').directive 'modal', ->
  restrict: 'C'
  link: (scope, $elem, attr) ->
    do $elem.modal


