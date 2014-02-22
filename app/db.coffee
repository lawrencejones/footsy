# Require mongoose
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/footsy'


db = mongoose.connection
db.on 'error', ->
  console.error ''
db.once 'open', ->
  console.log 'Database successfully opened!'
 


module.exports = {
  db: db
  models: {}
}
 
