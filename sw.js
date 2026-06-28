const CACHE = 'pinball-v1';
const BASE = self.registration.scope;

const SHELL = [
  BASE,
  BASE + 'assets/main.css',
  BASE + 'manifest.json',
  BASE + 'assets/images/icon.svg',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  if (url.origin !== self.location.origin) return;

  // Images: cache-first (pinball images don't change)
  if (request.destination === 'image') {
    event.respondWith(
      caches.match(request).then(cached =>
        cached || fetch(request).then(response => {
          caches.open(CACHE).then(cache => cache.put(request, response.clone()));
          return response;
        })
      )
    );
    return;
  }

  // CSS/JS assets: cache-first
  if (request.destination === 'style' || request.destination === 'script') {
    event.respondWith(
      caches.match(request).then(cached =>
        cached || fetch(request).then(response => {
          caches.open(CACHE).then(cache => cache.put(request, response.clone()));
          return response;
        })
      )
    );
    return;
  }

  // HTML pages: network-first, cache as fallback (fresh content when online,
  // readable offline when at an arcade with bad signal)
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then(response => {
          caches.open(CACHE).then(cache => cache.put(request, response.clone()));
          return response;
        })
        .catch(() => caches.match(request))
    );
  }
});
