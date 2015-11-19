// from: https://www.zkorean.com/hangul/appearance

var out = {
  consonants: {},
  vowels: {}
};

var consonants = document.getElementsByTagName("table")[0];
for (var i in consonants.rows) {
  var el = consonants.rows[i];

  if (el.getElementsByTagName) {
    var tds = el.getElementsByTagName('td');
    for (var j in tds) {
      var td = tds[j];

      if (td.getElementsByClassName && td.getElementsByClassName('playButtonClass').length > 0) {
        out.consonants[td.innerText.trim()] = td.getElementsByClassName('playButtonClass')[0].name;
      }
    }
  }
}

var vowels = document.getElementsByTagName("table")[1];
for (var i in vowels.rows) {
  var el = vowels.rows[i];

  if (el.getElementsByTagName) {
    var tds = el.getElementsByTagName('td');
    for (var j in tds) {
      var td = tds[j];

      if (td.getElementsByClassName && td.getElementsByClassName('playButtonClass').length > 0) {
        out.vowels[td.innerText.trim()] = td.getElementsByClassName('playButtonClass')[0].name;
      }
    }
  }
}

console.log(JSON.stringify(out, null, "  "));
