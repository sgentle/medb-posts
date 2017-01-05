fetch = require 'node-fetch'
striptags = require 'striptags'

get = (query_url) ->
  fetch query_url
  .then (res) -> res.json()
  .then (result) ->
    streak = 1
    lastDate = 0
    streakStart = new Date("2017-01-01")

    posts =
      for row in result.rows
        values = {}

        values.wordcount = striptags(row.value.body).split(/\s+/).length
        values.time = new Date(row.value.created)
        values.revisions = Number row.value._rev.split('-')[0]

        thisDate = new Date(row.value.created.slice(0,10))
        if thisDate > streakStart and thisDate - lastDate <= 1000*60*60*24
          streak++
        else
          streak = 1

        values.streak = streak
        lastDate = thisDate

        attachments = 0
        attachments++ for k of row.value._attachments
        values.attachments = attachments

        tags = {id: row.id.replace(/^posts\//,'')}

        {values, tags}
    {posts}


module.exports = (config) -> get config.query_url


