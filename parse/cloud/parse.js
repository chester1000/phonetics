// Generated by IcedCoffeeScript 108.0.9
var app, cleanLang, cleanSound, express, getLang;

express = require('express');

app = express();

app.get('/favicon.ico', function(req, res) {
  res.send(404, 'nope.');
});

cleanLang = function(l) {
  return {
    code: l != null ? l.get('code') : void 0,
    name: l != null ? l.get('name') : void 0,
    originalName: l != null ? l.get('originalName') : void 0,
    toggleLabel: l != null ? l.get('toggleLabel') : void 0,
    palette: l != null ? l.get('palette') : void 0,
    items: []
  };
};

cleanSound = function(s) {
  var _ref, _ref1;
  return {
    name: s != null ? s.get('name') : void 0,
    type: s != null ? s.get('type') : void 0,
    file: s != null ? (_ref = s.get('file')) != null ? (_ref1 = _ref.url()) != null ? _ref1.replace(/^http/, 'https') : void 0 : void 0 : void 0
  };
};

getLang = function(langs, code) {
  var l, _i, _len;
  for (_i = 0, _len = langs.length; _i < _len; _i++) {
    l = langs[_i];
    if (l.code === code) {
      return l;
    }
  }
  return null;
};

app.get('/fresh.json', function(req, res) {
  return new Parse.Query('Sounds2').include('language').limit(1000).find({
    success: function(records) {
      return res.jsonp(200, records.reduce(function(p, c) {
        var code, lang, sLang;
        sLang = c != null ? c.get('language') : void 0;
        code = sLang != null ? sLang.get('code') : void 0;
        lang = getLang(p, code);
        if (!lang) {
          lang = cleanLang(sLang);
          p.push(lang);
        }
        lang.items.push(cleanSound(c));
        return p;
      }, []));
    },
    error: function(err) {
      return res.send(500, err);
    }
  });
});

app.listen();
