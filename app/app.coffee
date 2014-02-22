express  = require 'express'
stylus   = require 'stylus'
nib      = require 'nib'
flash    = require 'connect-flash'
fs       = require 'fs'
path     = require 'path'
coffee   = require './midware/cs'

# Init app
app = express()
root_dir = path.join __dirname, '..'

# Configure app
config = require './config'
app.configure 'production', 'development', 'testing', ->
  config.setEnvironment app.settings.env

  # Init app settings
  app.set 'title', 'Footsy'
  app.set 'views', "#{root_dir}/views"
  app.set 'view engine', 'jade'
  
  # Configure middleware
  app.use express.logger('dev')                   # logger
  app.use express.cookieParser()                  # cookie
  app.use express.bodyParser()                    # params
  app.use flash()                                 # cflash
  
  # Asset serving
  app.use stylus.middleware                       # stylus
    src: "#{root_dir}/stylesheets"
    dest: "#{root_dir}/public"
    compile: (str, path) ->
      stylus(str).set('filename', path)
  app.use coffee.middleware                       # coffee
    src: "#{root_dir}/web"
  app.use express.static "#{root_dir}/public"     # static
  

# Start database
db = require('./db') config, []

# Load routes
(require './routes')(app, db)

# Export the app
module.exports = app

