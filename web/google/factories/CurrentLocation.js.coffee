################################################################################
# Seed data
################################################################################

CITIES = {      #    LAT,   LONG
  london:       [51.5009, 0.1774]
  manchester:   [53.4667, 2.2333]
  newcastle:    [54.9740, 1.6132]
  bristol:      [51.4500, 2.5833]
  southampton:  [50.8970, 1.4042]
}
DEFAULT_CENTER = new google.maps.LatLng CITIES.london...

################################################################################
# Holds current user location
################################################################################

angular.module('google')
  .factory 'CurrentLocation', ->

    # List of callbacks waiting on resolved position
    waiters = []

    new class CurrentLocation

      # Initially false, sticky switch
      resolved: false
      # Set to default initially
      latlng: DEFAULT_CENTER
      
      # Uses html5 api to location current position.
      constructor: ->
        me = this
        navigator.geolocation.getCurrentPosition (pos) ->
          if pos?
            # Add salt to the location for testing
            [x,y] = [Math.random(), Math.random()].map (n) -> 0.01*(n - 0.5)
            # [x,y] = [0,0]
            coords = [pos.coords.latitude + x, pos.coords.longitude + y]
            me.latlng = new google.maps.LatLng coords...
            printMessage "Resolved current position #{me.latlng}"
          else
            printMessage "Could not resolve current position [#{pos}]"
          me.resolved = true
          printMessage "Notifying #{waiters.length} current location waiters"
          cb?(me.latlng) for cb in waiters

      # Adds a new callback to the queue
      getLocation: (cb) ->
        if not @resolved
          printMessage 'Adding waiter for current location'
          waiters.push cb
        else
          printMessage 'Calling current location instantly'
          _ll = @latlng
          setTimeout (-> cb?(_ll)), 10
        
    
  
