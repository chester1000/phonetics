DEFAULT_THEME = 'indigo'

angular.module 'phoneticsApp', ['ngMaterial', 'angularRipple']
  .config ($sceDelegateProvider, $locationProvider, $mdThemingProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist [
      'self'
      'http://files.parsetfss.com/**'
    ]

    $locationProvider.html5Mode true

    $mdThemingProvider.alwaysWatchTheme true

    themes = [
      primary: DEFAULT_THEME # default - DO NOT USE
      accent: 'pink'
    ,
      primary: 'light-green'
      accent: 'pink'
    ,
      primary: 'light-blue'
      accent: 'orange'
    ,
      primary: 'amber'
      accent: 'blue'
    ,
      primary: 'teal'
      accent: 'deep-purple'
    ,
      primary: 'red'
      accent: 'green'
    ]

    for t in themes
      $mdThemingProvider
        .theme          t.primary
        .primaryPalette t.primary
        .accentPalette  t.accent

  .service 'ParseServ', (utils) ->
    Parse.initialize 'BdvYraypXe3U33UV5mGBRgPmqC2xUyPoP54QgkML', 'kY4MCB6NyGtXjEY6TeAtFWr1zhLv377L3HIiBbas'

    Langs   = Parse.Object.extend 'Languages'
    Sounds  = Parse.Object.extend 'Sounds'

    @getLangs = (cb) ->
      query = new Parse.Query Langs
      query.find
        success: (results) ->
          cb null, results.map (r) ->
            palette = r.get 'palette'

            id:           r.id
            name:         r.get 'name'
            originalName: r.get 'originalName'
            code:         r.get 'code'
            palette:      palette
            color:        utils.getColor palette, 'A200'

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

  .service 'measurer', ($window) ->
    _panelChangeListeners = []

    panels = []
    currentPanel = 0

    getToolbarHeight: -> 64
    getWindowHeight: -> $window.innerHeight
    getViewPortHeight: -> @getWindowHeight() - @getToolbarHeight()
    onPanelChange: (callback) -> _panelChangeListeners.push callback

    initPanels: (pre) ->
      pre.unshift
        name: 'langs'
        height: @getViewPortHeight()

      # pre.push
      #   name: 'about'
      #   height: @getViewPortHeight()

      panels = pre

    setSize: (name, height) -> s.height = height for s in panels when s.name is name
    getBreakPoints: -> panels.reduce ((p, c, i) -> p.push c.height + p[i]; p), [0]
    getCurrentPanelInfo: ->
      _guessedPanel = null
      scrollToPoint = false

      top     = $window.scrollY
      bottom  = top + @getViewPortHeight()

      breakpoints = @getBreakPoints()
      for b, i in breakpoints when i + 1 < breakpoints.length
        if top >= b and bottom <= breakpoints[i + 1]
          _guessedPanel = i
          break

        else if top < b and bottom > b
          screenMiddle = top + @getViewPortHeight() / 2
          if screenMiddle < b
            _guessedPanel = i - 1

            scrollToPoint = breakpoints[_guessedPanel]
            if panels[i - 1].height > @getViewPortHeight()
              scrollToPoint = breakpoints[i] - @getViewPortHeight()

          else if screenMiddle >= b
            _guessedPanel = i
            scrollToPoint = breakpoints[i]

          break

      if _guessedPanel isnt currentPanel
        currentPanel = _guessedPanel
        cb currentPanel for cb in _panelChangeListeners

      scrollToPoint

  .controller 'LangCtrl', ($scope, ParseServ, measurer, utils, $rootScope) ->

    $scope.soundNameInstead = false

    setStuff = (theme, title) ->
      $scope.title = title
      $scope.dynamicTheme = theme
      $rootScope.currentThemeColor = utils.getColor theme

    setStuff DEFAULT_THEME

    measurer.onPanelChange (newGridIdx) ->
      if newGridIdx is 0
        setStuff DEFAULT_THEME

      else
        c = $scope.langs[newGridIdx - 1]
        setStuff c.palette, c.name

      $scope.$apply()

    ParseServ.getLangs (err, langs) ->
      measurer.initPanels
        name: v.code for v in langs

      $scope.langs = langs
      $scope.$apply()

  .controller 'SoundBoardCtrl', ($scope, ParseServ, utils) ->
    $scope.normalizedSoundName = (sound) -> utils.normalize sound.name

    lang = new Parse.Object 'Languages'
    lang.id = $scope.lang.id
    ParseServ.getSounds lang, (err, sounds) ->
      $scope.sounds = sounds
      $scope.$apply()

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

  .directive 'aPanel', (measurer, $window, utils) ->
    restrict: 'A'
    link: (scope, el, attr) ->
      calculateHeight = ->
        minHeight = Math.max measurer.getViewPortHeight(), el[0].clientHeight

        if attr.lastHeight isnt minHeight
          attr.$set 'lastHeight', minHeight

          idx = scope.lang?.code

          if not idx and scope.langs
            idx = 'langs'

          idx ?= 'about'

          measurer.setSize idx, minHeight

          el.css 'min-height', minHeight + 'px'
        return

      scope.setMinHeight = calculateHeight

      debouncedCalculate = utils.debounce 100, calculateHeight

      angular.element($window).bind 'resize', ->
        el.css 'min-height', '0px'
        debouncedCalculate()

  .directive 'snap', ($window, utils, measurer) ->
    (scope, element, attrs) ->

      debouncedScroll = utils.debounce 100, ->
        scrollToPoint = measurer.getCurrentPanelInfo()

        if scrollToPoint != false
          utils.scrollTo scrollToPoint, 200, utils.easingFunctions.easeInOutQuint

      angular.element($window).bind 'scroll', ->
        measurer.getCurrentPanelInfo()
        debouncedScroll()
