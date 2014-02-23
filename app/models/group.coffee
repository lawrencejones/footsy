# Groups model
mongoose = require 'mongoose'

groupSchema = mongoose.Schema
  name:      String
  size:      Number
  football:  Boolean
  latlng:
    e: Number, d: Number

module.exports = mongoose.model 'Group', groupSchema
