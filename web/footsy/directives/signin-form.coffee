angular.module('footsy').directive 'signinForm', (CurrentLocation) ->
  restrict: 'A'
  link: (scope, $elem, attr) ->
    $elem.find('button:eq(0)').click ->
      CurrentLocation.getLocation (ll) ->
        $.ajax
          url: '/api/groups'
          method: 'POST'
          data:
            name: $elem.find('input[name=name]').val()
            size: $elem.find('input[name=size]').val()
            football: $elem.find('input[name=football]').is ':checked'
            latlng: {d: ll.d, e: ll.e}
          success: (group) ->
            sessionStorage.gid = group._id
            window.location.href = '/'
