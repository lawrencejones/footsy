#!/usr/bin/env coffee
url = process.argv[2]
if not url
  console.log 'No url supplied, terminating script'
  process.exit 1

najax = require 'najax'

groups = [
  {
    name: 'Batmans closet!'
    size: 1, football: true
    latlng: { e: 50.12, d: -0.14 }
  }, {
    name: 'Dead mans chest'
    size: 8, football: false
    latlng: { e: 50.14, d: -0.168 }
  }
]

najax.delete "#{url}/api/groups", ->
  console.log 'Successfully deleted all groups'
  for group in groups
    najax.post
      url: "#{url}/api/groups"
      data: group
      contentType: 'json'
      success: (data) ->
        data = JSON.parse data
        console.log "Added team **#{data.name}** to db"
