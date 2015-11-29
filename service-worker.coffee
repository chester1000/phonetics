'use strict'

console.log 'Installing service worker...'
self.oninstall = (e) ->
  console.log 'oninstall'

self.onactivate = (e) ->
  console.log 'onactivate'

self.onfetch = (e) ->
  arr = e.request.url.split '?soundFallback='
  if arr.length is 2
    console.log "sound url: " + arr[0]

  else
    console.log "url: " + e.request.url
