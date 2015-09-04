/**
 * How to use:
 * 1. GOTO: http://www.mdnkids.com/BoPoMo/
 * 2. open inspector and paste the below code there
 * 3. copy output and open `downloadSounds.coffee` file
 */


var list = [];

var spans = document.getElementsByTagName('span');
for(var i in spans) {
  var span = spans[i];
  if (span.hasAttribute && span.hasAttribute('onclick')) {
    list.push(span.getAttribute('onclick').split("'")[1]);
  }
}

console.log(JSON.stringify(list, null, '  '));
