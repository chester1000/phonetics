// Generated by IcedCoffeeScript 108.0.8
(function() {
  angular.module('phoneticsApp').service('utils', function($window, $mdColorPalette) {
    return {
      debounce: function(threshold, func) {
        var debounced, timeout;
        timeout = void 0;
        return debounced = function() {
          var args, delayed, obj;
          obj = this;
          args = arguments;
          delayed = function() {
            func.apply(obj, args);
            return timeout = null;
          };
          if (timeout) {
            clearTimeout(timeout);
          }
          return timeout = setTimeout(delayed, threshold);
        };
      },
      normalize: function(letter) {
        if (letter == null) {
          letter = '';
        }
        letter = letter.toLowerCase().replace(/\\s/g, '').replace(/[àáâãäåą]/g, 'a').replace(/æ/g, 'ae').replace(/[çć]/g, 'c').replace(/[èéêëę]/g, 'e').replace(/[ìíîï]/g, 'i').replace(/ł/g, 'l').replace(/ñń/g, 'n').replace(/[òóôõöó]/g, 'o').replace(/ś/g, 's').replace(/œ/g, 'oe').replace(/[ùúûü]/g, 'u').replace(/[ýÿ]/g, 'y').replace(/[żź]/g, 'z').replace(/\\W/g, '');
        return letter + '_';
      },
      easingFunctions: {
        linear: function(t) {
          return t;
        },
        easeInQuad: function(t) {
          return t * t;
        },
        easeInCubic: function(t) {
          return t * t * t;
        },
        easeInQuart: function(t) {
          return t * t * t * t;
        },
        easeInQuint: function(t) {
          return t * t * t * t * t;
        },
        easeOutQuad: function(t) {
          return t * (2 - t);
        },
        easeOutCubic: function(t) {
          return (--t) * t * t;
        },
        easeOutQuart: function(t) {
          return 1 - (--t) * t * t * t;
        },
        easeOutQuint: function(t) {
          return 1 + (--t) * t * t * t * t;
        },
        easeInOutQuad: function(t) {
          if (t < .5) {
            return 2 * t * t;
          } else {
            return -1 + (4 - 2 * t) * t;
          }
        },
        easeInOutCubic: function(t) {
          if (t < .5) {
            return 4 * t * t * t;
          } else {
            return (t - 1) * 2 * (2 * t - 2) + 1;
          }
        },
        easeInOutQuart: function(t) {
          if (t < .5) {
            return 8 * t * t * t * t;
          } else {
            return 1 - 8 * (--t) * t * t * t;
          }
        },
        easeInOutQuint: function(t) {
          if (t < .5) {
            return 16 * t * t * t * t * t;
          } else {
            return 1 + 16 * (--t) * t * t * t * t;
          }
        }
      },
      scrollTo: function(Y, duration, easingFunction, callback) {
        var from, scroll, start;
        if (duration == null) {
          duration = 1000;
        }
        start = Date.now();
        from = $window.scrollY;
        if (from === Y) {
          return typeof callback === "function" ? callback() : void 0;
        }
        scroll = function(timestamp) {
          var currentTime, easedT, time;
          currentTime = Date.now();
          time = Math.min(1, (currentTime - start) / duration);
          if (easingFunction == null) {
            easingFunction = this.easingFunctions.easeInOutQuint;
          }
          easedT = easingFunction(time);
          $window.scrollTo(0, (easedT * (Y - from)) + from);
          if (time < 1) {
            return requestAnimationFrame(scroll);
          } else {
            return typeof callback === "function" ? callback() : void 0;
          }
        };
        return requestAnimationFrame(scroll);
      },
      rgbToHex: function(r, g, b) {
        var _componentToHex;
        _componentToHex = function(c) {
          var hex;
          hex = c.toString(16);
          if (hex.length === 1) {
            hex = '0' + hex;
          }
          return hex;
        };
        return '#' + _componentToHex(r) + _componentToHex(g) + _componentToHex(b);
      },
      getColor: function(themeName, hue) {
        if (hue == null) {
          hue = '800';
        }
        return this.rgbToHex.apply(this, $mdColorPalette[themeName][hue].value);
      }
    };
  });

}).call(this);

//# sourceMappingURL=utils.js.map
