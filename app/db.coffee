fs = require 'fs'
path = require 'path'
# Require mongoose
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/footsy'

# Reference connection
db = mongoose.connection
db.on 'error', ->
  console.error ''
db.once 'open', ->
  console.log 'Database successfully opened!'
 
# Glob all models
fetchModels = ->
  models = {}
  coffeeRex = /(.*)\.(coffee|js)/
  modelsDir = path.join __dirname, 'models'
  for f in fs.readdirSync modelsDir
    if coffeeRex.test f
      key = f.match(coffeeRex)[1]
      key = key.charAt(0).toUpperCase() + key[1..]
      models[key] = require path.join modelsDir, f
  return models

# Export databases and models
module.exports = {
  db: db
  models: do fetchModels
}
 
