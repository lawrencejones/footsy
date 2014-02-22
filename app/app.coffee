express  = require 'express'
nib      = require 'nib'
flash    = require 'connect-flash'
fs       = require 'fs'
path     = require 'path'
coffee   = require './midware/cs'
stylus   = require './midware/stylus'

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
  app.use stylus.middleware root_dir              # stylus
  app.use coffee.middleware root_dir              # coffee
  app.use express.static "#{root_dir}/public"     # static
  

# Start database
db = require('./db')

# Load routes
(require './routes')(app, db)

# Export the app
module.exports = app

