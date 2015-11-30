'use strict'

VERSION = 'v1'

getCacheObject = (cb) ->
  caches
    .open "phonetics-#{VERSION}"
    .then cb


self.oninstall = (e) ->
  e.waitUntil getCacheObject (cache) ->
    cache.addAll [
      '/'
      '/styles.css'
      '/js/angular-ripple.js'
      '/js/main.js'
      '/js/utils.js'
    ]


self.onfetch = (e) ->
  arr = e.request.url.split '?soundFallback='
  if arr.length isnt 2
    e.respondWith caches.match(e.request).then (cacheResponse) ->
      if cacheResponse
        console.log 'cache (any):', e.request.url
        return cacheResponse

      fetch e.request
        .then (response) ->
          getCacheObject (cache) ->
            cache
              .put e.request, response.clone()
              .then ->
                console.log 'fresh (any):', e.request.url
                response

  else
    [parseFile, localFile] = arr
    e.respondWith caches.match(localFile).then (cacheRespose) ->
      if cacheRespose
        console.log 'cache (sound):', e.request.url
        return cacheRespose

      Promise.race [
          fetch localFile
          fetch parseFile
        ]
        .then (response) ->
          getCacheObject (cache) ->
            cache
              .put localFile, response.clone()
              .then ->
                console.log 'fresh (sound):', localFile
                response
