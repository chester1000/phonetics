/**
 * How to use:
 * 1. GOTO: http://www.thai-language.com/?ref=consonants
 * 2. open inspector and paste the below code there
 * 3. copy output and open `downloadSounds.coffee` file
 */

var list = {};
var nc = document.getElementById('new-content');
var tbody = nc.getElementsByTagName('tbody')[0];
for(var i in tbody.rows) {
  var el = tbody.rows[i];
  if (el.hasAttribute && el.hasAttribute('bgcolor')) {

    // get sound name
    var span = el.getElementsByTagName('span')[0];
    var name = span.innerText.split(' ')[0];

    // get sound path
    var as = el.getElementsByTagName('a');
    var link = '';
    for(var j in as) {
      var a = as[j];
      if (a.hasAttribute && a.hasAttribute('onclick'))
        link = a.getAttribute('onclick').split("'")[1];
    }
    list[name] = link;
  }
}

console.log(JSON.stringify(list, null, '  '));
