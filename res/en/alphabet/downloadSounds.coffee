url     = require 'url'
{spawn} = require 'child_process'
fs      = require 'fs'

BASE_URL = 'http://www.letterland.com/images/parents-guide/2_alphabet-sounds/sounds/%s.mp3'
ALPHABET = 'abcdefghijklmnopqrstuvwxyz'
DOWNLOAD_DIR = './'

download_file_curl = (file_url) ->
    file_name = url.parse(file_url).pathname.split('/').pop()
    file = fs.createWriteStream DOWNLOAD_DIR + file_name
    curl = spawn 'curl', [file_url]
    curl.stdout.on 'data', (data) -> file.write data
    curl.stdout.on 'end', (data) ->
      file.end()
      console.log file_name + ' downloaded to ' + DOWNLOAD_DIR

    curl.on 'exit', (code) ->
      if code isnt 0
        console.log 'Failed: ' + code

for l in ALPHABET
  download_file_curl BASE_URL.replace '%s', l
