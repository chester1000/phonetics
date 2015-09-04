angular.module 'phoneticsApp'
  .service 'utils', ($window) ->
    debounce: (threshold, func) ->
      timeout = undefined

      debounced = ->
        obj = @
        args = arguments

        delayed = ->
          func.apply obj, args
          timeout = null

        if timeout
          clearTimeout timeout

        timeout = setTimeout delayed, threshold


    normalize: (letter = '') ->
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


    easingFunctions:
      linear:         (t) -> t

      easeInQuad:     (t) -> t * t
      easeInCubic:    (t) -> t * t * t
      easeInQuart:    (t) -> t * t * t * t
      easeInQuint:    (t) -> t * t * t * t * t

      easeOutQuad:    (t) -> t * (2 - t)
      easeOutCubic:   (t) ->     (--t) * t * t
      easeOutQuart:   (t) -> 1 - (--t) * t * t * t
      easeOutQuint:   (t) -> 1 + (--t) * t * t * t * t

      easeInOutQuad:  (t) -> if t < .5 then  2 * t * t              else -1 + (4 - 2 * t) * t
      easeInOutCubic: (t) -> if t < .5 then  4 * t * t * t          else (t - 1) * 2 * (2 * t - 2) + 1
      easeInOutQuart: (t) -> if t < .5 then  8 * t * t * t * t      else 1 -  8 * (--t) * t * t * t
      easeInOutQuint: (t) -> if t < .5 then 16 * t * t * t * t * t  else 1 + 16 * (--t) * t * t * t * t

    scrollTo: (Y, duration=1000, easingFunction, callback) ->
      start = Date.now()
      from = $window.scrollY

      return callback?() if from is Y

      scroll = (timestamp) ->
        currentTime = Date.now()
        time = Math.min 1, (currentTime - start) / duration
        easedT = easingFunction time

        $window.scrollTo 0, (easedT * (Y - from)) + from

        if time < 1
          requestAnimationFrame scroll
        else
          callback?()

      requestAnimationFrame scroll

    rgbToHex: (r, g, b) ->
      _componentToHex = (c) ->
        hex = c.toString 16
        if hex.length is 1
          hex = '0' + hex
        hex

      '#' + _componentToHex(r) + _componentToHex(g) + _componentToHex(b)
