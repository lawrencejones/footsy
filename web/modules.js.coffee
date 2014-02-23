# For dev logging only
window.printMessage = (args...) -> console.log args...

# Create the angular module
angular.module 'footsy', ['google']

# Create the google module
angular.module 'google', []

