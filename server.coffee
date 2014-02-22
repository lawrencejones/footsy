#!/usr/bin/env coffee
app = require './app/app'

app.listen (PORT = process.env.PORT || 3000), ->
  console.log "Listening at localhost:#{PORT}"
