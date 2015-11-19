{Parse} = require 'node-parse-api'
fs      = require 'fs-extra'
encoding= require 'encoding'


config  = require '../../parseSecrets.json'

app = new Parse config.APP_ID, config.MASTER_KEY

POLISH_LANG_ID = 'aiBJX0JgfA'

normalize = (letter = '') ->
  letter.toLowerCase()
    .replace /\\s/g,        ''
    .replace /[àáâãäåą]/g,  'a_'
    .replace /æ/g,          'ae_'
    .replace /[çć]/g,       'c_'
    .replace /[èéêëę]/g,    'e_'
    .replace /[ìíîï]/g,     'i_'
    .replace /ł/g,          'l_'
    .replace /ñń/g,         'n_'
    .replace /[òóôõöó]/g,   'o_'
    .replace /ś/g,          's_'
    .replace /œ/g,          'oe_'
    .replace /[ùúûü]/g,     'u_'
    .replace /[ýÿ]/g,       'y_'
    .replace /[żź]/g,       'z_'
    .replace /\\W/g,        ''

sounds = [
  'a'
  'ą'
  'b'
  'c'
  'ch'
  'ci'
  'cz'
  'ć'
  'd'
  'dzi'
  'dź'
  'dż'
  'e'
  'ę'
  'f'
  'g'
  'h'
  'i'
  'j'
  'k'
  'l'
  'ł'
  'm'
  'n'
  'ń'
  'o'
  'ó'
  'p'
  'r'
  'rz'
  's'
  'si'
  'sz'
  'szcz'
  'ś'
  't'
  'u'
  'w'
  'y'
  'z'
  'ź'
  'ż'
]

insertRow = (name, soundNameUrl) ->
  obj =
    name: name
    language:
      __type: 'Pointer',
      className: 'Languages',
      objectId: POLISH_LANG_ID

  if soundNameUrl
    obj.soundName =
      __type: 'File'
      name: soundNameUrl

  app.insert 'Sounds', obj, (err, response) ->
    console.log 'insertErr', err if err
    console.log 'insertRes', name, response

readFile = (name, fileName) ->
  (err, data) ->
    normFileName = normalize fileName

    if err
      insertRow name, null
      return

    app.insertFile normFileName, data, 'audio/mpeg', (err, response) ->
      console.log 'insertFileErr', err if err
      console.log 'insertFileRes', response

      insertRow name, response.name

for s in sounds
  fileName = s + '.mp3'
  fs.readFile "./#{fileName}", readFile fileName.split('.')[0], fileName
