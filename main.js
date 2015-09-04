// Generated by CoffeeScript 1.9.3
(function() {
  angular.module('phoneticsApp', ['ngMaterial']).config(function($sceDelegateProvider, $locationProvider, $mdThemingProvider) {
    var j, k, lastTime, len, len1, ref, t, themes, v;
    $sceDelegateProvider.resourceUrlWhitelist(['self', 'http://files.parsetfss.com/**']);
    $locationProvider.html5Mode(true);
    $mdThemingProvider.alwaysWatchTheme(true);
    themes = [
      {
        primary: 'light-green',
        accent: 'pink'
      }, {
        primary: 'light-blue',
        accent: 'orange'
      }, {
        primary: 'amber',
        accent: 'blue'
      }
    ];
    for (j = 0, len = themes.length; j < len; j++) {
      t = themes[j];
      $mdThemingProvider.theme(t.primary).primaryPalette(t.primary).accentPalette(t.accent);
    }
    lastTime = 0;
    ref = ['ms', 'moz', 'webkit', 'o'];
    for (k = 0, len1 = ref.length; k < len1; k++) {
      v = ref[k];
      if (!(!window.requestAnimationFrame)) {
        continue;
      }
      window.requestAnimationFrame = window[v + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[v + 'CancelAnimationFrame'] || window[v + 'CancelRequestAnimationFrame'];
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, timeToCall;
        currTime = new Date().getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        lastTime = currTime + timeToCall;
        return window.setTimeout((function() {
          return callback(currTime + timeToCall);
        }), timeToCall);
      };
    }
    if (!window.cancelAnimationFrame) {
      return window.cancelAnimationFrame = function(id) {
        return clearTimeout(id);
      };
    }
  }).service('ParseServ', function() {
    var Langs, Sounds;
    Parse.initialize('BdvYraypXe3U33UV5mGBRgPmqC2xUyPoP54QgkML', 'kY4MCB6NyGtXjEY6TeAtFWr1zhLv377L3HIiBbas');
    Langs = Parse.Object.extend('Languages');
    Sounds = Parse.Object.extend('Sounds');
    this.getLangs = function(cb) {
      var query;
      query = new Parse.Query(Langs);
      return query.find({
        success: function(results) {
          return cb(null, results.map(function(r) {
            return {
              id: r.id,
              name: r.get('name'),
              originalName: r.get('originalName'),
              code: r.get('code'),
              palette: r.get('palette')
            };
          }));
        },
        error: function(err) {
          return cb(err, []);
        }
      });
    };
    this.getSounds = function(langId, cb) {
      var query;
      query = new Parse.Query(Sounds);
      query.equalTo('language', langId);
      return query.find({
        success: function(results) {
          return cb(null, results.map(function(r) {
            var sound, soundName, soundNameUrl, soundUrl;
            sound = r.get('sound');
            soundUrl = sound != null ? sound.url() : void 0;
            soundName = r.get('soundName');
            soundNameUrl = soundName != null ? soundName.url() : void 0;
            return {
              name: r.get('name'),
              altNames: r.get('altNames'),
              sound: soundUrl,
              soundName: soundNameUrl
            };
          }));
        },
        error: function(err) {
          return cb(err, []);
        }
      });
    };
    return this;
  }).controller('LangCtrl', function($scope, ParseServ, measurer, $mdColorPalette, utils, $rootScope) {
    $scope.dynamicTheme = 'default';
    $rootScope.currentThemeColor = utils.rgbToHex.apply(this, $mdColorPalette['indigo']['800'].value);
    measurer.registerGridChange(function(newGridIdx) {
      if (newGridIdx === 0) {
        $scope.dynamicTheme = 'default';
        $scope.title = null;
        $rootScope.currentThemeColor = utils.rgbToHex.apply(this, $mdColorPalette['indigo']['800'].value);
      } else {
        $scope.dynamicTheme = $scope.langs[newGridIdx - 1].palette;
        $scope.title = $scope.langs[newGridIdx - 1].name;
        $rootScope.currentThemeColor = utils.rgbToHex.apply(this, $mdColorPalette[$scope.dynamicTheme]['800'].value);
      }
      return $scope.$apply();
    });
    $scope.title = null;
    $scope.soundNameInstead = false;
    $scope.langTileSize = 2;
    return ParseServ.getLangs(function(err, langs) {
      var i, j, len, tmpSizes, v;
      if (langs.length < 4) {
        $scope.langTileSize = 2;
      } else {
        $scope.langTileSize = 1;
      }
      tmpSizes = [
        {
          idx: 0,
          name: 'langs',
          height: measurer.getViewPortHeight()
        }
      ];
      for (i = j = 0, len = langs.length; j < len; i = ++j) {
        v = langs[i];
        tmpSizes.push({
          idx: i + 1,
          name: v.code
        });
        v.color = utils.rgbToHex.apply(this, $mdColorPalette[v.palette].A200.value);
      }
      measurer.initSizes(tmpSizes);
      $scope.langs = langs;
      return $scope.$apply();
    });
  }).controller('SoundBoardCtrl', function($scope, ParseServ, utils) {
    var lang;
    $scope.normalizedSoundName = function(sound) {
      return utils.normalize(sound.name);
    };
    lang = new Parse.Object('Languages');
    lang.id = $scope.lang.id;
    return ParseServ.getSounds(lang, function(err, sounds) {
      $scope.sounds = sounds;
      return $scope.$apply();
    });
  }).service('measurer', function($window) {
    var currentGrid, gridChangeListeners, sizes;
    sizes = [];
    currentGrid = 0;
    gridChangeListeners = [];
    return {
      registerGridChange: function(callback) {
        return gridChangeListeners.push(callback);
      },
      getToolbarHeight: function() {
        return 64;
      },
      initSizes: function(pre, s) {
        return sizes = pre;
      },
      setSize: function(name, height) {
        var j, len, results1, s;
        results1 = [];
        for (j = 0, len = sizes.length; j < len; j++) {
          s = sizes[j];
          if (s.name === name) {
            results1.push(s.height = height);
          }
        }
        return results1;
      },
      getWindowHeight: function() {
        return $window.innerHeight;
      },
      getViewPortHeight: function() {
        return this.getWindowHeight() - this.getToolbarHeight();
      },
      getBreakPoints: function() {
        return sizes.reduce((function(p, c, i) {
          p.push(c.height + p[i]);
          return p;
        }), [0]);
      },
      getCurrentGridInfo: function() {
        var b, bottom, breakpoints, cb, i, j, k, len, len1, screenMiddle, status, top;
        status = {};
        top = $window.scrollY;
        bottom = top + this.getViewPortHeight();
        breakpoints = this.getBreakPoints();
        for (i = j = 0, len = breakpoints.length; j < len; i = ++j) {
          b = breakpoints[i];
          if (i + 1 < breakpoints.length) {
            if (top >= b && bottom <= breakpoints[i + 1]) {
              status.needsScrolling = false;
              status.gridIdx = i;
              break;
            } else if (top < b && bottom > b) {
              status.needsScrolling = true;
              screenMiddle = top + this.getViewPortHeight() / 2;
              if (screenMiddle < b) {
                status.gridIdx = i - 1;
                status.nearestPoint = breakpoints[status.gridIdx];
                if (sizes[i - 1].height > this.getViewPortHeight()) {
                  status.nearestPoint = breakpoints[i] - this.getViewPortHeight();
                }
              } else if (screenMiddle >= b) {
                status.gridIdx = i;
                status.nearestPoint = breakpoints[i];
              }
              break;
            }
          }
        }
        if (status.gridIdx !== currentGrid) {
          currentGrid = status.gridIdx;
          for (k = 0, len1 = gridChangeListeners.length; k < len1; k++) {
            cb = gridChangeListeners[k];
            cb(currentGrid);
          }
        }
        return status;
      }
    };
  }).directive('aSound', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attr) {
        var player;
        scope.playing = false;
        player = element.find('audio')[0];
        return element.on('click', function() {
          scope.playing = true;
          player.currentTime = 0;
          player.play();
          return player.addEventListener('ended', function() {
            scope.playing = false;
            return scope.$apply();
          });
        });
      }
    };
  }).directive('gridBoard', function(measurer) {
    return {
      restrict: 'A',
      link: function(scope, el, attr) {
        return scope.setMinHeight = function() {
          var l, minHeight, ref;
          minHeight = Math.max(measurer.getViewPortHeight(), el[0].clientHeight);
          l = (ref = scope.lang) != null ? ref.code : void 0;
          if (l) {
            measurer.setSize(l, minHeight);
          }
          el.css('min-height', minHeight + 'px');
        };
      }
    };
  }).directive('snap', function($window, utils, measurer) {
    return function(scope, element, attrs) {
      var debounced;
      debounced = utils.debounce(100, function() {
        var info;
        info = measurer.getCurrentGridInfo();
        if (info.needsScrolling) {
          return utils.scrollTo(info.nearestPoint, 200, utils.easingFunctions.easeInOutQuint);
        }
      });
      return angular.element($window).bind('scroll', function() {
        measurer.getCurrentGridInfo();
        return debounced();
      });
    };
  });

}).call(this);
