# Creates an input field with two buttons 'Locate' and 'Suggest'.
# The user can then enter an address or location, press locate
# and using Googles API services, will attempt to parse a LatLng
# value.
# Example usage.
#
#   <div class="google-map-query"
#        map-handle="gmap"
#        location-label="location.label">
#        location-latlng="location.latlng">
#   </div>
#
# The user would enter their search term into the input box,
# then once inputted click locate to attempt to generate the
# LatLng position for that query.
angular.module('google')
  .directive 'googleMapQuery', (ParseLocation, $parse, $rootScope) ->
    restrict: 'EC'
    scope: true
    template: """
      <div class="input-group input-xs">
        <input type="text" ng-model="query"
               class="form-control map-query-input">
        </input>
        <span class="input-group-btn">
          <button class="btn btn-default locate-btn"
                  type="button">Locate</button>
          <button class="btn btn-default suggest-btn"
                ng-class="{'btn-primary': suggestions,
                            disabled: query.length == 0}"
                ng-click="toggleSuggestion()"
                type="button">Suggest?</button>
        </span>
      </div>
      <div class="suggestions-wrapper">
        <table class="table suggestions" ng-show="suggestions">
          <tbody>
            <tr ng-repeat="loc in results" ng-click="selectionHandler(loc)">
             <td>{{ loc.formatted_address }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    """
    link: (scope, $elem, attr) ->

      # Where to store the results
      scope.results     = []
      scope.suggestions = false
      marker            = null

      # Extract components
      $input   = $elem.find 'input.map-query-input:eq(0)'
      $locate  = $elem.find 'button.locate-btn:eq(0)'
      $suggest = $elem.find 'button.suggest-btn:eq(0)'
      _label   = $parse attr.locationLabel
      _latlng  = $parse attr.locationLatlng

      # Set default query value
      scope.query = scope.$eval attr.locationLabel

      # Click handler for the selection of a suggested label
      # Will be passed a google place object, once finished will
      # close the suggestion box
      scope.selectionHandler = (place) ->
        label = place.formatted_address
        $parse(attr.locationLabel).assign scope, label
        scope.query = label
        scope.suggestions = false

      # Takes a query and retrives the search results from ParseLocation,
      # passing them back to the callback
      genLatLngFromQuery = (query, cb) ->
        if not query? or query?.trim?() == '' then return
        fetchResults {address: query.trim()}, cb

      # Fetches the google places results for a query
      fetchResults = (query, cb) ->
        query.region = 'UK'
        ParseLocation query, (latlngs) ->
          scope.results = latlngs[0..2]
          do scope.$digest
          cb?(scope.results)

      # Using the given query, will generate a LatLng object, assign the said
      # value to the scope latlng var, then $digest from root upwards.
      locateHandler = (query) ->
        _label.assign scope, query
        genLatLngFromQuery query, (res) ->
          ll = res[0].geometry.location
          _latlng.assign scope, ll
          do $rootScope.$digest

      # Available in scope, toggles the suggestion variable and refreshes
      # suggestions again location.
      scope.toggleSuggestion = ->
        if scope.query.length != 0
          scope.suggestions = !scope.suggestions

      # Watch for the map to become active
      scope.$watch attr.mapHandle, ->

        # Click handles for location, queries and updates the change location
        printMessage 'Detected map assignment'
        $locate.click (-> locateHandler $input.val())

        scope.$watch attr.locationLatlng, (latlng) ->
          printMessage 'LatLng has changed!'
          fetchResults {latlng: latlng}
            
