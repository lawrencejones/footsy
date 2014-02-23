# Groups model
mongoose = require 'mongoose'

groupSchema = mongoose.Schema
  name:      String
  size:      Number
  football:  Boolean
  latlng:
    e: Number, d: Number

groupSchema.methods.add = (n) ->
  this.size = this.size + n
  
module.exports = mongoose.model 'Group', groupSchema
