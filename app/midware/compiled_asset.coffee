fs     = require 'fs'
path   = require 'path'

# Generate middleware for a compiled asset
# Takes options as
#     respath:   <relative path to compiled>
#     srcpath:   <folder to find raw src>
#     compile:   <function to compile raw source>
#     rawsuffix: <file suffix of raw src>   eg. (.coffee)
#     ressuffix: <file suffix of res path>  eg. (.js)
module.exports = (options) ->

  # Generate regexp for matching urls
  regexp = new RegExp "^(\/#{options.respath}\/)(.+)#{options.ressuffix}"
  
  # Returns compiled source if file is found
  getCompiledSrc = (url) ->
    if url && regexp.test url
      fname = (url.match regexp)[2]
      return if not fname?
      fpath = path.join options.approot, options.srcpath
      fpath = path.join fpath, "#{fname}#{options.rawsuffix}"
      if fs.existsSync fpath
        raw = fs.readFileSync fpath, 'utf8'
        return options.compile raw

  # Return middleware
  (req, res, next) ->
    if (src = getCompiledSrc req.url)
      res.setHeader 'Content-Type', options.mime
      res.send src
    else next()
