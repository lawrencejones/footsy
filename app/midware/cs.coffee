# Require coffee-script module
coffee = require 'coffee-script'
fs     = require 'fs'
path   = require 'path'

# Generate middleware for coffeescript
exports.middleware = (options) ->

  srcdir = options.src
  rexJs  = /^(\/web\/)(\w+).js/
  
  # Returns js if corresponding cs src exists and is compileable
  getCoffeeSrc = (url) ->
    if url && rexJs.test url
      fname = (url.match rexJs)[2]
      return if not fname?
      fpath = path.join srcdir, "#{fname}.coffee"
      if fs.existsSync fpath
        return coffee.compile (fs.readFileSync fpath, 'utf8'), {bare:true}

  # Return middleware
  (req, res, next) ->
    if (src = getCoffeeSrc req.url)
      res.send src
    else next()
