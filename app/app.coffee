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
  app.use express.session                         # sesson
    secret: 'mysecret'
  app.use express.bodyParser()                    # params
  app.use flash()                                 # cflash

  # Asset serving
  app.use stylus.middleware root_dir              # stylus
  app.use coffee.middleware root_dir              # coffee
  app.use express.static "#{root_dir}/public"     # static
  
  # Concatenates all coffeescript for webapp
  if not app.settings.env == 'production'
    app.get '/app.js', (req, res) ->
      globCoffee = (dpath) ->
        rexedFiles = []
        for fpath in fs.readdirSync dpath
          fpath = path.join dpath, fpath
          if fs.statSync(fpath).isDirectory()
            rexedFiles.push globCoffee fpath
          else if /^(.+)\.coffee$/.test fpath
            rexedFiles.push fpath
        [].concat.apply [], rexedFiles
      res.setHeader 'Content-Type', 'text/javascript'
      res.send (globCoffee path.join root_dir, 'web')
        .map((f) -> (require 'coffee-script').compile fs.readFileSync(f, 'utf8'))
        .reverse()
        .reduce (a,c) -> a + c
    

# Start database
db = require './db'

# Load app
server = app.listen (PORT = process.env.PORT || 8888), ->
  console.log "Listening at localhost:#{PORT}"

# Initialise sockets
sockets = (require './sockets')(server, db.models.Group)

# Load routes
(require './routes')(app, db, sockets)


