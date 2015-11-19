{Parse} = require 'node-parse-api'
{spawn} = require 'child_process'

fs  = require 'fs-extra'
url = require 'url'

config = require '../parseSecrets.json'

app = new Parse config.APP_ID, config.MASTER_KEY

idToCode = {}

downloadFileCurl = (file_url, file_name) ->
    file_name += '.mp3'
    file = fs.createWriteStream file_name, flags: 'w'
    curl = spawn 'curl', [file_url]

    curl.stdout.on 'data', (data) ->
      file.write data

    curl.stdout.on 'end', (data) ->
      file.end()
      console.log 'Downloaded:', file_name

    curl.on 'exit', (code) ->
      if code isnt 0
        console.log 'Failed: ' + code

saveSound = (sound) ->
  soundDir = [
    idToCode[sound.language.objectId]
    sound.type
  ].join '/'
  fs.mkdirsSync soundDir

  soundName = [
    soundDir
    sound.name
  ].join '/'

  url = sound?.file?.url

  if url
    downloadFileCurl url, soundName
  else
    console.log 'thailand silent sounds meh'

getLangSounds = (langId) ->
  langPointer =
    __type: 'Pointer'
    className: 'Languages',
    objectId: langId

  app.find 'Sounds2', where: language:langPointer, (err, sounds) ->
    console.error 'sounds', err if err

    saveSound sound for sound in sounds.results


app.find 'Languages', '', (err, langs) ->
  console.error 'langs', err if err

  for lang in langs.results
    idToCode[lang.objectId] = lang.code
    getLangSounds lang.objectId
