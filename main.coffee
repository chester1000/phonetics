DEFAULT_THEME = 'blue-grey'

angular.module 'phoneticsApp', ['ngMaterial', 'angularRipple']
  .config ($sceDelegateProvider, $locationProvider, $mdThemingProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist [
      'self'
      'https://files.parsetfss.com/**'
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

  .factory 'ParseServ', (utils, $http) ->
    cbs = {}
    langs = null
    sounds = null

    processSounds = (data) ->
      data.reduce (langs, lang) ->
        langs[lang.code] = lang.items.map (sound) ->
          sound.localFile = "sounds/#{lang.code}/#{sound.type}/#{sound.name}.mp3"
          sound
        langs
      , {}

    processLangs = (data) ->
      data.map (lang) ->
        lang.color = utils.getColor lang.palette, 'A200'
        delete lang.items
        lang

    $http.jsonp 'https://phonetics.parseapp.com/fresh.json?callback=JSON_CALLBACK'
      .then (response) ->

        response.data.sort (a, b) ->
          a.name.localeCompare b.name

        # order here is important: `langs` after `sounds`
        sounds = processSounds response.data
        langs = processLangs response.data

        # execute all pending callbacks
        for name, cb of cbs
          if name is 'langs'
            cb langs
          else
            cb sounds[name]

        # clear callback cache
        cbs = {}

    getLangs: (cb) ->
      return cb langs if langs
      cbs['langs'] = cb

    getSounds: (lang, cb) ->
      return cb sounds[lang] if sounds[lang]?
      cbs[lang] = cb

  .factory 'panels', ->
    new class Panels
      _changeListeners = []
      _defaultHeight = 0

      current: 0
      panels: []

      init: (@panels) ->
        @panels.unshift
          name: 'langs'
          toggle: false
          height: _defaultHeight

        @panels.push
          name: 'about'
          toggle: false
          height: _defaultHeight

      setDefaultHeight: (defaultHeight) -> _defaultHeight = defaultHeight
      setHeight: (name, height) ->
        s.height = height for s in @panels when s.name is name

      getCurrent: -> @current
      setCurrent: (newCurrent) ->
        if @panels.length > 0 and newCurrent isnt @current
          @current = newCurrent
          cb @current, @getInfo(@current).toggle for cb in _changeListeners

      getInfo: (panelId) -> @panels[panelId]
      getBreakPoints: -> @panels.reduce ((p, c, i) -> p.push c.height + p[i]; p), [0]

      getCurrentLang: ->
        return null if @panels[@current].name in ['langs', 'about']
        return @current - 1

      getCurrentLabel: (state) ->
        return "loading..." if @panels.length is 0

        tmpLabels = @getInfo(@current)?.labels
        return switch true
          when not tmpLabels then null
          when tmpLabels.length is 1 then tmpLabels[0]
          else tmpLabels[+state]

      cacheToggleStatus: (state) -> @getInfo(@current).toggle = state
      getToggleFor: (idx) -> @getInfo(idx).toggle

      getAll: -> @panels
      getLastId: -> return i for v, i in @panels when v.name is 'about'

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

        panels.setCurrent _guessedPanel if _guessedPanel isnt null

        scrollToPoint

  .controller 'LangCtrl', ($scope, $rootScope, ParseServ, panels, utils) ->
    $scope.isLastPanel = false

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
      $scope.isLastPanel = false

      switch newGridIdx
        when 0
          setStuff DEFAULT_THEME

        when panels.getLastId()
          setStuff DEFAULT_THEME, ' '
          $scope.isLastPanel = true

        else
          c = $scope.langs[newGridIdx - 1]
          setStuff c.palette, c.name

      $scope.$apply()

    ParseServ.getLangs (langs) ->
      panels.init langs.map (l) ->
        name: l.code
        toggle: false
        labels: l.toggleLabel

      $scope.langs = langs

  .controller 'SoundBoardCtrl', ($scope, ParseServ, utils, panels) ->
    $scope.normalizedSoundName = (sound) -> utils.normalize sound.name
    $scope.toggleFilter = (sound) ->
      toggleStatus = panels.getToggleFor $scope.idx + 1

      if $scope.lang?.code is 'pl'
        return toggleStatus or sound.name.length is 1

      if $scope.lang?.code is 'en'
        shouldShow = sound.type is 'phonetic'

        unless toggleStatus
          shouldShow = not shouldShow

        return shouldShow

      return true

    $scope.getSoundLabel = (name, altName) ->
      toggleStatus = panels.getToggleFor $scope.idx + 1

      if $scope.lang?.code is 'bopo' and toggleStatus
        return altName

      return name

    ParseServ.getSounds $scope.lang.code, (sounds) ->
      $scope.sounds = sounds

  .directive 'aSound', ->
    restrict: 'A'
    link: (scope, element, attr) ->
      player = element.find('audio')[0]

      element.on 'click', ->
        player.currentTime = 0
        player.play()

  .directive 'aPanel', ($window, $timeout, utils, measurer, panels) ->
    restrict: 'A'
    link: (scope, el, attr) ->
      calculateHeight = ->
        loader = document.getElementById 'loader'
        if loader
          setTimeout (-> loader.remove()), 1200

        {clientHeight} = el.find('md-grid-list')[0] ? el[0]
        minHeight = Math.max measurer.getViewPortHeight(), clientHeight

        if attr.lastHeight isnt minHeight

          attr.$set 'lastHeight', minHeight

          idx = scope.lang?.code

          if not idx and scope.langs
            idx = 'langs'

          idx ?= 'about'

          panels.setHeight idx, minHeight

          el.css 'min-height', minHeight + 'px'
          $window.scrollBy 0, 1

        return

      scope.setMinHeight = calculateHeight

      angular.element($window).bind 'resize', utils.debounce 100, calculateHeight
      $timeout calculateHeight

  .directive 'snap', ($window, utils, measurer) ->
    (scope, element, attrs) ->

      debouncedScroll = utils.debounce 100, ->
        scrollToPoint = measurer.getCurrentPanelInfo()

        if scrollToPoint != false
          utils.scrollTo scrollToPoint, 200, utils.easingFunctions.easeInOutQuint

      angular.element($window).bind 'scroll', ->
        measurer.getCurrentPanelInfo()
        debouncedScroll()

  .directive 'preventPopups', ->
    (scope, element, attr) ->
      element.bind 'contextmenu', (e) ->
        scope.$apply -> e.preventDefault()
