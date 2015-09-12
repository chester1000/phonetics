fs = require 'fs'
{exec} = require 'child_process'

fs.readFile 'audio_ids.txt', encoding: 'utf-8', (err, data) ->
  lines = data.split '\n'
  for l in lines
    exec "swfextract -s #{l} -o #{l}.mp3 TEphonemic_GreyBlue2_0.swf"
