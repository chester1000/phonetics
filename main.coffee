Parse.initialize 'BdvYraypXe3U33UV5mGBRgPmqC2xUyPoP54QgkML', 'kY4MCB6NyGtXjEY6TeAtFWr1zhLv377L3HIiBbas'

Langs   = Parse.Object.extend 'Languages'
Sounds  = Parse.Object.extend 'Sounds'

angular.module 'phoneticsApp', []
  .filter 'soundName', -> (input) -> input.toUpperCase() + input.toLowerCase()
  .config ($sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist [
      'self'
      'http://files.parsetfss.com/**'
    ]

  .service 'ParseServ', ->
    @getLangs = (cb) ->
      query = new Parse.Query Langs
      query.find
        success: (results) ->
          cb null, results.map (r) ->
            id:           r.id
            name:         r.get 'name'
            originalName: r.get 'originalName'
            code:         r.get 'code'
            color:        r.get 'color'

        error: (err) ->
          cb err, []

    @getSounds = (langId, cb) ->
      query = new Parse.Query Sounds
      query.equalTo 'language', langId
      query.find
        success: (results) ->
          cb null, results.map (r) ->
            sound = r.get 'sound'
            soundUrl = sound?.url()

            soundName = r.get 'soundName'
            soundNameUrl = soundName?.url()

            name:       r.get 'name'
            altNames:   r.get 'altNames'
            sound:      soundUrl
            soundName:  soundNameUrl

        error: (err) ->
          cb err, []
    @

  .controller 'LangCtrl', ($scope, ParseServ) ->
    $scope.title = "Choose a language"
    $scope.soundsType = "sound"

    ParseServ.getLangs (err, langs) ->
      $scope.langs = langs
      $scope.$apply()

  .controller 'SoundBoardCtrl', ($scope, ParseServ) ->

    $scope.normalizedSoundName = (sound) -> normalize sound.name

    lang = new Parse.Object 'Languages'
    lang.id = $scope.lang.id
    ParseServ.getSounds lang, (err, sounds) ->
      $scope.sounds = sounds
      $scope.$apply()


  .directive 'aSound', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      console.log scope.name
      player = element.find('audio')[0]
      element.on 'click', ->
        player.currentTime = 0
        player.play()


debounce = (func, threshold, execAsap) ->
  timeout = undefined

  debounced = ->
    obj = @
    args = arguments

    delayed = ->
      unless execAsap
        func.apply obj, args

      timeout = null

    if timeout
      clearTimeout timeout
    else if execAsap
      func.apply obj, args

    timeout = setTimeout delayed, threshold or 100

normalize = (letter = '') ->
  letter = letter.toLowerCase()
    .replace /\\s/g,        ''
    .replace /[àáâãäåą]/g,  'a'
    .replace /æ/g,          'ae'
    .replace /[çć]/g,       'c'
    .replace /[èéêëę]/g,    'e'
    .replace /[ìíîï]/g,     'i'
    .replace /ł/g,          'l'
    .replace /ñń/g,         'n'
    .replace /[òóôõöó]/g,   'o'
    .replace /ś/g,          's'
    .replace /œ/g,          'oe'
    .replace /[ùúûü]/g,     'u'
    .replace /[ýÿ]/g,       'y'
    .replace /[żź]/g,       'z'
    .replace /\\W/g,        ''

  letter + '.'
