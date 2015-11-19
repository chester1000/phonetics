{Parse} = require 'node-parse-api'
fs      = require 'fs'

config  = require '../../parseSecrets.json'

app = new Parse config.APP_ID, config.MASTER_KEY

ZHUYIN_LANG_ID = 'K2fo62JPpX'

sounds =
  "ㄅ": "audio/01.mp3"
  "ㄆ": "audio/02.mp3"
  "ㄇ": "audio/03.mp3"
  "ㄈ": "audio/04.mp3"
  "ㄉ": "audio/05.mp3"
  "ㄊ": "audio/06.mp3"
  "ㄋ": "audio/07.mp3"
  "ㄌ": "audio/08.mp3"
  "ㄍ": "audio/09.mp3"
  "ㄎ": "audio/10.mp3"
  "ㄏ": "audio/11.mp3"
  "ㄐ": "audio/12.mp3"
  "ㄑ": "audio/13.mp3"
  "ㄒ": "audio/14.mp3"
  "ㄓ": "audio/15.mp3"
  "ㄔ": "audio/16.mp3"
  "ㄕ": "audio/17.mp3"
  "ㄖ": "audio/18.mp3"
  "ㄗ": "audio/19.mp3"
  "ㄘ": "audio/20.mp3"
  "ㄙ": "audio/21.mp3"
  "ㄚ": "audio/22.mp3"
  "ㄛ": "audio/23.mp3"
  "ㄜ": "audio/24.mp3"
  "ㄝ": "audio/25.mp3"
  "ㄞ": "audio/26.mp3"
  "ㄟ": "audio/27.mp3"
  "ㄠ": "audio/28.mp3"
  "ㄡ": "audio/29.mp3"
  "ㄢ": "audio/30.mp3"
  "ㄣ": "audio/31.mp3"
  "ㄤ": "audio/32.mp3"
  "ㄥ": "audio/33.mp3"
  "ㄦ": "audio/34.mp3"
  "ㄧ": "audio/35.mp3"
  "ㄨ": "audio/36.mp3"
  "ㄩ": "audio/37.mp3"


insertRow = (name, soundNameUrl) ->
  obj =
    name: name
    language:
      __type: 'Pointer',
      className: 'Languages',
      objectId: ZHUYIN_LANG_ID

  if soundNameUrl
    obj.sound =
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
