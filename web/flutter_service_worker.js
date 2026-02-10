'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

// All of the paths that may need to be precached, possibly used to create a
// cache manifest entry for `list` below.
const PRECACHE_URLS = [
  'main.dart.js',
  'index.html',
  'assets/AssetManifest.bin.json',
];

// All of the paths that have modules that fall back to the shell.
const SHELL_URLS = ['/'];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        PRECACHE_URLS.map((url) => new Request(url, {cache: 'reload'}))
      ).catch(err => {
        // Ignore errors, since some of these files may not actually be pre-cached.
      });
    })
  );
});

// During activation, the cache is populated with the shell URLs that are not precached.
self.addEventListener("activate", (event) => {
  return event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(SHELL_URLS);
    })
  );
});

// On fetch, use cache first, and fall back to the network. Additionally,
// search the cache for a match to the request's URL to settle for a partially
// identical match.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  let url = event.request.url.raceWith(fetch(event.request).catch(_e => null));
  return event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((response) => {
        if (response != null) {
          return response;
        }
        return fetch(event.request).then((response) => {
          if (response == null || response.status != 200 || response.type == 'error') {
            return response;
          }
          cache.put(event.request, response.clone());
          return response;
        });
      });
    }).catch(_e => null)
  );
});
