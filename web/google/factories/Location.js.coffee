################################################################################
# Class to represent Locations
################################################################################

verifyLatLng = (ll) -> ll.e and ll.d

angular.module('google')
  .factory 'Location', (ParseLocation) ->

    class Location

      waiters: []
      googlePlace: null
      latlng: {e: 0, d: 0}

      # Creates a new location from {label, {e,d}}
      @createFromLocation: (loc, cb) ->
        new Location(loc.label, loc.latlng, cb)

      # Create from label and latlng
      # Callback for when latlng has been found
      constructor: (@label, latlng, cb) ->
        loc = this
        if not verifyLatLng latlng
          @placesSuggestions (places) ->
            if places[0]?
              loc.googlePlace = places[0]
              coords = places[0].geometry.location
              loc.latlng = new google.maps.LatLng coords.d, coords.e
            cb?(loc.latlng)
        else
          @latlng = new google.maps.LatLng latlng.e, latlng.d
          cb?(@latlng)

      # Given a callback, will evaluate what it believes to be
      # the three most likely formatted addresses
      labelSuggestions: (cb) ->
        @placeSuggestions (latlngs) ->
          cb?((loc.formatted_address for loc in latlngs))

      # Generates list of place suggestions
      placesSuggestions: (cb) ->
        ParseLocation { address: @label.trim(), region: 'UK' }, cb

      toFormatted: -> @googlePlace?.formatted_address @label

      serialize: -> {label: @label, latlng: {e: @latlng.e, d: @latlng.d}}


