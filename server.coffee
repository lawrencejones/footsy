#!/usr/bin/env coffee
app = require './app/app'

server = app.listen (PORT = process.env.PORT || 3000), ->
  console.log "Listening at localhost:#{PORT}"

