{Parse} = require 'node-parse-api'
fs      = require 'fs'

config  = require '../../parseSecrets.json'

app = new Parse config.APP_ID, config.MASTER_KEY

THAI_LANG_ID = 'UYDv9gRZnB'

sounds =
  "ก": "/mp3/E131097.mp3"
  "ข": "/mp3/E131102.mp3"
  "ฃ": "/mp3/E131103.mp3"
  "ค": "/mp3/E131104.mp3"
  "ฅ": "/mp3/E131105.mp3"
  "ฆ": "/mp3/E131759.mp3"
  "ง": "/mp3/E131099.mp3"
  "จ": "/mp3/E131106.mp3"
  "ฉ": "/mp3/E131107.mp3"
  "ช": "/mp3/E131108.mp3"
  "ซ": "/mp3/E131765.mp3"
  "ฌ": "/mp3/E131109.mp3"
  "ญ": "/mp3/E131110.mp3"
  "ฎ": "/mp3/E131769.mp3"
  "ฏ": "/mp3/E131771.mp3"
  "ฐ": "/mp3/E131773.mp3"
  "ฑ": "/mp3/E131775.mp3"
  "ฒ": "/mp3/P197388.mp3"
  "ณ": "/mp3/E131111.mp3"
  "ด": "/mp3/E131112.mp3"
  "ต": "/mp3/E131113.mp3"
  "ถ": "/mp3/E131780.mp3"
  "ท": "/mp3/E131114.mp3"
  "ธ": "/mp3/E131088.mp3"
  "น": "/mp3/E131115.mp3"
  "บ": "/mp3/P196764.mp3"
  "ป": "/mp3/E131087.mp3"
  "ผ": "/mp3/E131117.mp3"
  "ฝ": "/mp3/E131790.mp3"
  "พ": "/mp3/E131791.mp3"
  "ฟ": "/mp3/E131118.mp3"
  "ภ": "/mp3/E131794.mp3"
  "ม": "/mp3/E131119.mp3"
  "ย": "/mp3/E131797.mp3"
  "ร": "/mp3/E131120.mp3"
  "ล": "/mp3/E131121.mp3"
  "ว": "/mp3/E131122.mp3"
  "ศ": "/mp3/E131802.mp3"
  "ษ": "/mp3/E131804.mp3"
  "ส": "/mp3/E131123.mp3"
  "ห": "/mp3/E131807.mp3"
  "ฬ": "/mp3/E131124.mp3"
  "อ": "/mp3/E131810.mp3"
  "ฮ": ""


insertRow = (name, soundNameUrl) ->
  obj =
    name: name
    language:
      __type: 'Pointer',
      className: 'Languages',
      objectId: THAI_LANG_ID

  if soundNameUrl
    obj.soundName =
      __type: 'File'
      name: soundNameUrl

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

for name, path of sounds
  fileName = path.split('/').pop().toLowerCase()

  fs.readFile "./#{name}.mp3", readFile name, fileName
