{Parse} = require 'node-parse-api'
fs      = require 'fs'

config  = require '../../parseSecrets.json'
{sounds}= require './sounds.json'

app = new Parse config.APP_ID, config.MASTER_KEY

KOREAN_LANG_ID = 'inTJ9fnMFt'

insertRow = (name, soundUrl) ->
  obj =
    name: name
    language:
      __type: 'Pointer',
      className: 'Languages',
      objectId: KOREAN_LANG_ID

  if soundUrl
    obj.sound =
      __type: 'File'
      name: soundUrl

  app.insert 'Sounds', obj, (err, response) ->
    console.log 'insertErr', err if err
    console.log 'insertRes', name, response

readFile = (name, fileName) ->
  (err, data) ->
    if err
      insertRow name, null
      return

    app.insertFile fileName, data, 'audio/mpeg', (err, response) ->
      console.log 'insertFileErr', err if err
      console.log 'insertFileRes', response

      insertRow name, response.name


for name, path of sounds.consonants
  fs.readFile "./#{name}?.mp3", readFile name, path

for name, path of sounds.vowels
  fs.readFile "./#{name}.mp3", readFile name, path
