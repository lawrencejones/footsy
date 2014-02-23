################################################################################
# Wrapper for GoogleMap functions
################################################################################

angular.module('google')
  .factory 'GoogleMap', (CurrentLocation) ->
  
    # Hold these privately
    map = null
    service = null
    markers = []
  
    class GoogleMap
  
      # Initialise map, service
      constructor: (@elem, opt = {}) ->
        printMessage "Constructing map centered at #{CurrentLocation.latlng}"
        map = @map = new google.maps.Map @elem, {
          zoom:   opt.zoom || 10
          center: CurrentLocation.latlng
        }
        # Set timeout gives the map time to initialise
        if (opt.centerCrrt || true) then setTimeout (->
          map.setCenter CurrentLocation.latlng
          CurrentLocation.getLocation (ll) ->
            map.setCenter ll
            map.setZoom 14
        ), 10
        service  = new google.maps.places.PlacesService map

      # Moves a marker that is already on the map.
      #
      #   latlng:     LatLng instance to move marker to
      #   opt:
      #     recenter: Simply recenter screen to marker
      #
      moveMarker: (marker, latlng, opts = {}) ->
        if not marker? then return @addMarker latlng, opts
        printMessage "Moving marker from #{marker.getPosition()} to #{latlng}"
        marker.setPosition latlng
        marker.setMap (if (opts.visible || true) then map else null)
        if (opts.recenter || true) && !map.getBounds()?.contains?(latlng)
          map.setCenter marker.getPosition()
        
  
      # Adds a marker to the current map.
      #
      #   latlng:   LatLng instance for marker positioning
      #   recenter: If added marker is out of map bounds, then recenter
      #   drag:     Property of the new marker to allow dragging
      #
      addMarker: (latlng, opts = {}) ->
        printMessage "Marking map @(#{latlng})"
        if not latlng instanceof google.maps.LatLng
          throw new Error("Invalid latlng (#{latlng}), req LatLng type")
        marker = new google.maps.Marker {
          map: map
          draggable: opts.drag || true
          animation: google.maps.Animation.DROP
          position: latlng
        }
        if (opts.recenter || true) && !map.getBounds()?.contains?(latlng)
          map.setCenter marker.getPosition()
        markers.push marker; marker
  
      # Removes all markers from the map
      removeMarkers: ->
        marker.setMap null; marker = null for marker in markers
        markers = []
  
      # Makes use of CurrentLocation service, passes latlng value
      # to the optional callback.
      findMe: (args = {}, cb) ->
        CurrentLocation.getLocation (latlng) ->
          if args.recenter || true
            map.setCenter latlng
          if args.clearMarkers || false
            do @removeMarkers
          if args.dropMarker || false
            @addMarker latlng, false, false
          cb?(latlng)
  
  
