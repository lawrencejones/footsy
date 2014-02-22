# Require coffee-script module
coffee  = require 'coffee-script'
midware = require './compiled_asset'

# Generate middleware for coffee-script
exports.middleware = (approot) -> midware
  approot: approot
  mime: 'application/javascript'
  respath: "web"
  srcpath: 'web'
  compile: coffee.compile
  rawsuffix: '.coffee'
  ressuffix: '.js'
