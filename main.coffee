angular.module 'phoneticsApp', ['ngMaterial']
  .config ($sceDelegateProvider, $mdThemingProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist [
      'self'
      'http://files.parsetfss.com/**'
    ]

    $mdThemingProvider.alwaysWatchTheme true

    themes = [
      primary: 'light-green'
      accent: 'pink'
    ,
      primary: 'light-blue'
      accent: 'orange'
    ,
      primary: 'amber'
      accent: 'blue'
    ]

    for t in themes
      $mdThemingProvider
        .theme t.primary
        .primaryPalette t.primary
        .accentPalette t.accent

    lastTime = 0
    for v in ['ms', 'moz', 'webkit', 'o'] when not window.requestAnimationFrame
      window.requestAnimationFrame = window[v + 'RequestAnimationFrame']
      window.cancelAnimationFrame = window[v + 'CancelAnimationFrame'] or window[v + 'CancelRequestAnimationFrame']

    unless window.requestAnimationFrame
      window.requestAnimationFrame = (callback, element) ->
        currTime = new Date().getTime()
        timeToCall = Math.max 0, 16 - (currTime - lastTime)
        lastTime = currTime + timeToCall
        window.setTimeout (-> callback currTime + timeToCall), timeToCall

    unless window.cancelAnimationFrame
      window.cancelAnimationFrame = (id) ->
        clearTimeout id

  .service 'ParseServ', ->
    Parse.initialize 'BdvYraypXe3U33UV5mGBRgPmqC2xUyPoP54QgkML', 'kY4MCB6NyGtXjEY6TeAtFWr1zhLv377L3HIiBbas'

    Langs   = Parse.Object.extend 'Languages'
    Sounds  = Parse.Object.extend 'Sounds'

    @getLangs = (cb) ->
      query = new Parse.Query Langs
      query.find
        success: (results) ->
          cb null, results.map (r) ->
            id:           r.id
            name:         r.get 'name'
            originalName: r.get 'originalName'
            code:         r.get 'code'
            palette:      r.get 'palette'

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

  .controller 'LangCtrl', ($scope, ParseServ, measurer, $mdColorPalette, utils, $rootScope) ->
    $scope.dynamicTheme = 'default'
    $rootScope.currentThemeColor = utils.rgbToHex.apply @, $mdColorPalette['indigo']['800'].value

    measurer.registerGridChange (newGridIdx) ->
      if newGridIdx is 0
        $scope.dynamicTheme = 'default'
        $scope.title = null
        $rootScope.currentThemeColor = utils.rgbToHex.apply @, $mdColorPalette['indigo']['800'].value

      else
        $scope.dynamicTheme = $scope.langs[newGridIdx - 1].palette
        $scope.title = $scope.langs[newGridIdx - 1].name
        $rootScope.currentThemeColor = utils.rgbToHex.apply @, $mdColorPalette[$scope.dynamicTheme]['800'].value

      $scope.$apply()

    $scope.title = null
    $scope.soundNameInstead = false
    $scope.langTileSize = 2

    ParseServ.getLangs (err, langs) ->
      if langs.length < 4
        $scope.langTileSize = 2
      else
        $scope.langTileSize = 1

      tmpSizes = [
        idx: 0
        name: 'langs'
        height: measurer.getViewPortHeight()
      ]
      for v, i in langs
        tmpSizes.push
          idx: i + 1
          name: v.code

        v.color = utils.rgbToHex.apply @, $mdColorPalette[v.palette].A200.value

      measurer.initSizes tmpSizes

      $scope.langs = langs
      $scope.$apply()

  .controller 'SoundBoardCtrl', ($scope, ParseServ, utils) ->
    $scope.normalizedSoundName = (sound) -> utils.normalize sound.name

    lang = new Parse.Object 'Languages'
    lang.id = $scope.lang.id
    ParseServ.getSounds lang, (err, sounds) ->
      $scope.sounds = sounds
      $scope.$apply()

  .service 'measurer', ($window) ->
    sizes = []

    currentGrid = 0
    gridChangeListeners = []

    registerGridChange: (callback) -> gridChangeListeners.push callback
    getToolbarHeight: -> 64
    initSizes: (pre, s) -> sizes = pre
    setSize: (name, height) -> s.height = height for s in sizes when s.name is name
    getWindowHeight: -> $window.innerHeight
    getViewPortHeight: -> @getWindowHeight() - @getToolbarHeight()
    getBreakPoints: -> sizes.reduce ((p, c, i) -> p.push c.height + p[i]; p), [0]
    getCurrentGridInfo: ->
      status = {}

      top = $window.scrollY
      bottom = top + @getViewPortHeight()

      breakpoints = @getBreakPoints()
      for b, i in breakpoints when i + 1 < breakpoints.length
        if top >= b and bottom <= breakpoints[i + 1]
          status.needsScrolling = false
          status.gridIdx = i
          break

        else if top < b and bottom > b
          status.needsScrolling = true

          screenMiddle = top + @getViewPortHeight() / 2
          if screenMiddle < b
            status.gridIdx = i - 1
            status.nearestPoint = breakpoints[status.gridIdx]

            if sizes[i - 1].height > @getViewPortHeight()
              status.nearestPoint = breakpoints[i] - @getViewPortHeight()

          else if screenMiddle >= b
            status.gridIdx = i
            status.nearestPoint = breakpoints[i]

          break

      if status.gridIdx isnt currentGrid
        currentGrid = status.gridIdx
        cb currentGrid for cb in gridChangeListeners

      status

  .directive 'aSound', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      scope.playing = false
      player = element.find('audio')[0]

      element.on 'click', ->
        scope.playing = true
        player.currentTime = 0
        player.play()
        player.addEventListener 'ended', ->
          scope.playing = false
          scope.$apply()

  .directive 'gridBoard', (measurer) ->
    restrict: 'A'
    link: (scope, el, attr) ->
      scope.setMinHeight = ->
        minHeight = Math.max measurer.getViewPortHeight(), el[0].clientHeight

        l = scope.lang?.code
        if l
          measurer.setSize l, minHeight

        el.css 'min-height', minHeight + 'px'
        return

  .directive 'snap', ($window, utils, measurer) ->
    (scope, element, attrs) ->

      debounced = utils.debounce 100, ->
        info = measurer.getCurrentGridInfo()

        if info.needsScrolling
          utils.scrollTo info.nearestPoint, 200, utils.easingFunctions.easeInOutQuint

      angular.element($window).bind 'scroll', ->
        measurer.getCurrentGridInfo()
        debounced()
