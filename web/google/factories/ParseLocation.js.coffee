################################################################################
# Utilities
################################################################################

# Evaluates the distance between fa() and fb(), where both arguments
# give objects of the form {d,e} when called.
distanceBetween = (fa, fb) ->
  [a,b] = (do f for f in [fa, db])
  Math.sqrt (Math.pow(a.d - b.d, 2) + Math.pow(a.e - b.e, 2))

# Generates a function to be supplied to Array.sort to sort elements
# by distance from origin.
# The returned function takes fp as an argument, which when called
# will return an object of the form {d,e}
sortByDisFunction = (origin) ->
  ((fp) -> Math.abs (distanceBetween (-> origin), fp))

################################################################################
# Google Location Parser, wrapper around Google APIs
################################################################################

angular.module('google').factory 'ParseLocation', (CurrentLocation) ->

  # Initiate the map, service, geocoder and marker
  geocoder = new google.maps.Geocoder()
  
  getParams = (query) ->
    if query instanceof google.maps.LatLng
      { latLng: query }
    else if typeof query == 'string'
      { address: query }
    else if typeof query == 'object'
      query.latLng = query.latlng
      delete query.latlng
      query

  # Google requests are expensive!
  cache = {}
  cacheGeocode = (query, cb) ->
    if query?.address?
      store = cache[query.address]
      return cb?(store) if store?
    geocoder.geocode query, (res, sts) ->
      if sts == google.maps.GeocoderStatus.OK
        if res.length is 0
          printMessage "No results found for #{query?.address}"
        cb?(res)
      else throw new Error('Querying geocode failed')
    
  # Given a query, will call the callback with the results from
  # reverse geocode lookup.
  #
  #   query: Either a LatLng instance or text query
  #   cb:    Callback that receives an array of results
  #
  ParseLocation = (query, cb) ->
    # Verify arguments
    if not cb? then return # exit silently
    params = getParams query
    if not params.latlng? and params.address?.trim() == ''
      return null
    cacheGeocode params, cb

