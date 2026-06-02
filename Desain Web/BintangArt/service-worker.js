const cache_name = 'v1';
const cache_assets = [
    '/',
    'index.html',
    'contact.html',
    'about.html',
    'offline.html',
    'javas.js',
    'manifest.json',
    'style.css'
];

self.addEventListener('install', (e) => {
    e.waitUntil(
        caches.open(cache_name).then((cache) => {
            return cache.addAll(cache_assets);
        })
    );
});

self.addEventListener('fetch', (e) => {
    e.respondWith(
        fetch(e.request).catch(() => {
            return caches.match(e.request).then((response) => {
                if (response) {
                    return response;
                } else if (e.request.mode === 'navigate') {
                    return caches.match(/testinng_DW/'offline.html');
                }
            });
        })
    );
});

self.addEventListener('activate', (e) => {
    const cacheWhitelist = [cache_name];
    e.waitUntil(
        caches.keys().then(cacheNames => {
                return Promise.all(
                    cacheNames.map(cacheName => {
                            if (!cacheWhitelist.includes(cacheName)) {
                                return caches.delete(cacheName);
                            }
                        }
                    )
                );
            }
        )
    );
});

