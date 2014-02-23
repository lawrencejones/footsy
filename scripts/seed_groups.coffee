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
    latlng: {d:51.50911558011393, e:-0.18211752753904875}
  }, {
    name: 'Dead mans chest'
    size: 8, football: false
    latlng: {d:51.509436100020565, e:-0.16580969672850188}
  }
]

seed = (i) ->
  if i then groups = [groups[i]]
  for group in groups
    najax.post
      url: "#{url}/api/groups"
      data: group
      contentType: 'json'
      success: (data) ->
        data = JSON.parse data
        console.log "Added team **#{data.name}** to db"

if process.argv[3] == 'force'
  najax.delete "#{url}/api/groups", ->
    console.log 'Successfully deleted all groups'
    do seed
else seed (parseInt(process.argv[3],10))
