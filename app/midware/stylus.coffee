# Require stylus module
stylus  = require 'stylus'
midware = require './compiled_asset'

# Generate middleware for stylus
exports.middleware = (approot) -> midware
  approot: approot
  mime: 'text/css'
  respath: 'stylesheets'
  srcpath: 'stylesheets'
  compile: stylus.render
  rawsuffix: '.styl'
  ressuffix: '.css'
