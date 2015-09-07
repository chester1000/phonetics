url     = require 'url'
{spawn} = require 'child_process'
fs      = require 'fs'

{sounds} = require './sounds.json'

BASE_URL = 'https://www.zkorean.com/study/serve_audio_public/%s.mp3'
DOWNLOAD_DIR = './lala/'

download_file_curl = (file_url, file_name) ->
    file_name += '.mp3'
    file = fs.createWriteStream DOWNLOAD_DIR + file_name
    curl = spawn 'curl', [file_url]
    curl.stdout.on 'data', (data) -> file.write data
    curl.stdout.on 'end', (data) ->
      file.end()
      console.log file_name + ' downloaded to ' + DOWNLOAD_DIR

    curl.on 'exit', (code) ->
      if code isnt 0
        console.log 'Failed: ' + code

for name, path of sounds.consonants
  download_file_curl BASE_URL.replace('%s', path), name + '?'

for name, path of sounds.vowels
  download_file_curl BASE_URL.replace('%s', path), name
