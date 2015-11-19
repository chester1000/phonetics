fs = require 'fs'

fs.readdir '.', (err, files) ->
  a = files
  .filter (file) -> -1 isnt file.indexOf '.mp3'
  .map (file) -> file.replace '.mp3', ''

  console.log JSON.stringify a, null, '  '
