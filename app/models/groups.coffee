# Groups model
mongoose = require 'mongoose'

groupSchema = mongoose.Schema
  name: String
  size: Number

module.exports = mongoose.model 'Groups', groupSchema
