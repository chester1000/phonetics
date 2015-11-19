fs = require 'fs-extra'

sounds = require './Sounds.json'

for sound in sounds.results
  if sound.sound and not sound.soundName
    sound.file = sound.sound
    sound.type = if sound.meta is 'p' then 'phonetic' else 'sound'
    delete sound.sound

  else if not sound.sound and sound.soundName
    sound.file = sound.soundName
    sound.type = 'name'
    delete sound.soundName

  else
    sound.type = 'name'

  delete sound.meta

outputJson = './Sounds2.json'
fs.writeJson outputJson, sounds, {spaces: 2}, (err) ->
  return console.error err if err

  console.log "written to #{outputJson}"
