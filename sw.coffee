'use strict'

VERSION = 'v1'

getCacheObject = (cb) ->
  caches
    .open "phonetics-#{VERSION}"
    .then cb


self.oninstall = (e) ->
  e.waitUntil getCacheObject (cache) ->
    cache.addAll [
      '/index.html'
      '/styles.css'
      '/js/angular-ripple.js'
      '/js/main.js'
      '/js/utils.js'
    ]


self.onfetch = (e) ->
  arr = e.request.url.split '?soundFallback='
  if arr.length is 2
    console.log "sound url: " + arr[0]

    e.respondWith fetch e.request
    # e.respondWith Promise.race [
    #   fetch e.request
    # ]

  else
    e.respondWith caches.match(e.request).then (cacheResponse) ->
      if cacheResponse
        console.log 'cache:', e.request.url
        return cacheResponse

      fetch e.request
        .then (response) ->
          getCacheObject (cache) ->
            cache
              .put e.request, response.clone()
              .then ->
                console.log 'fresh:', e.request.url
                response
