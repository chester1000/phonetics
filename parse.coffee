express = require 'express'

app = express()

app.get '/favicon.ico', (req, res) ->
  res.send 404, 'nope.'
  return

cleanLang = (l) ->
  code:         l?.get 'code'
  name:         l?.get 'name'
  originalName: l?.get 'originalName'
  toggleLabel:  l?.get 'toggleLabel'
  palette:      l?.get 'palette'
  items:        []

cleanSound = (s) ->
  name:     s?.get 'name'
  altNames: s?.get 'altNames'
  type:     s?.get 'type'
  file:     s?.get('file')?.url()?.replace /^http/, 'https'

getLang = (langs, code) ->
  return l for l in langs when l.code is code
  return null

app.get '/fresh.json', (req, res) ->
  new Parse.Query 'Sounds2'
    .include 'language'
    .limit 1000
    .find
      success: (records) ->
        res.jsonp 200, records.reduce (p, c) ->
          sLang = c?.get 'language'
          code = sLang?.get 'code'

          lang = getLang p, code
          unless lang
            lang = cleanLang sLang
            p.push lang

          lang.items.push cleanSound c

          p
        ,  []

      error: (err) ->
        res.send 500, err

app.listen()
