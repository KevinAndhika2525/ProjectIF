if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() => {
        navigator.serviceWorker.register('./service-worker.js').then(function(registration) {
            console.log('Service-Worker registered with scope: ', registration.scope);
        }, function(err) {
            console.log('ServiceWorker registration failed: ', err);
        });
    });
}
