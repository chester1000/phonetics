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

  .factory 'ParseServ', (utils) ->
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
            toggleLabel:  r.get 'toggleLabel'
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

  .factory 'panels', ->
    new class Panels
      _changeListeners = []
      _defaultHeight = 0

      current: 0
      panels: []

      constructor: ->
      init: (@panels) ->
        @panels.unshift
          name: 'langs'
          toggle: off
          height: _defaultHeight

        @panels.push
          name: 'about'
          toggle: off
          height: _defaultHeight

      setDefaultHeight: (defaultHeight) -> _defaultHeight = defaultHeight
      setHeight: (name, height) ->
        s.height = height for s in @panels when s.name is name

      getCurrent: -> @current
      setCurrent: (newCurrent) ->
        if newCurrent isnt @current
          @current = newCurrent
          cb @current, @getInfo(@current).toggle for cb in _changeListeners

      getInfo: (panelId) -> @panels[panelId]
      getBreakPoints: -> @panels.reduce ((p, c, i) -> p.push c.height + p[i]; p), [0]

      getCurrentLang: ->
        return null if @panels[@current].name in ['langs', 'about']
        return @current - 1

      getCurrentLabel: (state) ->
        return "loading..." if @panels.length is 0

        tmpLabels = @getInfo(@current).labels
        return switch true
          when not tmpLabels then null
          when tmpLabels.length is 1 then tmpLabels[0]
          else tmpLabels[+state]

      cacheToggleStatus: (state) -> @getInfo(@current).toggle = state

      getAll: -> @panels

      onChange: (callback) ->
        _changeListeners.push callback

  .factory 'measurer', ($window, panels) ->
    new class Measurer
      constructor: -> panels.setDefaultHeight @getViewPortHeight()
      getToolbarHeight: -> 64
      getWindowHeight: -> $window.innerHeight
      getViewPortHeight: -> @getWindowHeight() - @getToolbarHeight()
      getCurrentPanelInfo: ->
        _guessedPanel = null
        scrollToPoint = false

        top     = $window.scrollY
        bottom  = top + @getViewPortHeight()

        breakpoints = panels.getBreakPoints()
        for b, i in breakpoints when i + 1 < breakpoints.length
          if top >= b and bottom <= breakpoints[i + 1]
            _guessedPanel = i
            break

          else if top < b and bottom > b
            screenMiddle = top + @getViewPortHeight() / 2
            if screenMiddle < b
              _guessedPanel = i - 1

              scrollToPoint = breakpoints[_guessedPanel]
              if panels.getInfo(i - 1).height > @getViewPortHeight()
                scrollToPoint = breakpoints[i] - @getViewPortHeight()

            else if screenMiddle >= b
              _guessedPanel = i
              scrollToPoint = breakpoints[i]

            break

        panels.setCurrent _guessedPanel

        scrollToPoint

  .controller 'LangCtrl', ($scope, $rootScope, ParseServ, panels, utils) ->
    $scope.toggleStatus = false
    $scope.notifyChange   = -> panels.cacheToggleStatus $scope.toggleStatus
    $scope.getToggleLabel = -> panels.getCurrentLabel   $scope.toggleStatus

    setStuff = (theme, title) ->
      $scope.title = title
      $scope.dynamicTheme = theme
      $rootScope.currentThemeColor = utils.getColor theme

    setStuff DEFAULT_THEME

    panels.onChange (newGridIdx, toggleStatus) ->
      $scope.toggleStatus = toggleStatus

      if newGridIdx is 0
        setStuff DEFAULT_THEME

      else
        c = $scope.langs[newGridIdx - 1]
        setStuff c.palette, c.name

      $scope.$apply()

    ParseServ.getLangs (err, langs) ->
      panels.init langs.map (l) ->
        name: l.code
        toggle: off
        labels: l.toggleLabel

      $scope.langs = langs
      $scope.$apply()

  .controller 'SoundBoardCtrl', ($scope, ParseServ, utils) ->
    $scope.normalizedSoundName = (sound) -> utils.normalize sound.name
    $scope.toggleFilter = (sound) ->
      if $scope.lang?.code is 'pl'
        return $scope.toggleStatus or sound.name.length is 1

      # if $scope.lang?.code is 'en'
      #   console.log sound

      return true

    $scope.getSoundLabel = (name, altName) ->
      if $scope.lang?.code is 'bopo'
        unless $scope.toggleStatus
          return name
        else
          return altName

      return name

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

  .directive 'aPanel', ($window, utils, measurer, panels) ->
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

          panels.setHeight idx, minHeight

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
