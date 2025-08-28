const CACHE_NAME = 'kenali-paslon-v1';
const STATIC_CACHE_URLS = [
  '/',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png',
];

// Install event - cache static resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Caching static resources');
        return cache.addAll(STATIC_CACHE_URLS);
      })
      .catch((error) => {
        console.error('Failed to cache static resources:', error);
      })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - serve cached content when offline
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip requests to API endpoints for now (they need network)
  if (event.request.url.includes('/api/')) {
    // For API requests, try network first, fallback to cache if offline
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Clone response before caching
          const responseClone = response.clone();
          
          // Cache successful API responses for offline use
          if (response.status === 200) {
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseClone);
              });
          }
          
          return response;
        })
        .catch(() => {
          // Network failed, try to serve from cache
          return caches.match(event.request)
            .then((cachedResponse) => {
              if (cachedResponse) {
                return cachedResponse;
              }
              
              // Return offline page for failed API requests
              return new Response(
                JSON.stringify({
                  success: false,
                  message: 'Tidak ada koneksi internet. Data akan disinkronkan saat online kembali.',
                  offline: true
                }),
                {
                  status: 503,
                  statusText: 'Service Unavailable',
                  headers: {
                    'Content-Type': 'application/json'
                  }
                }
              );
            });
        })
    );
    return;
  }

  // For static resources, serve from cache first, fallback to network
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }
        
        return fetch(event.request)
          .then((response) => {
            // Don't cache non-successful responses
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // Clone response for caching
            const responseToCache = response.clone();
            
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          });
      })
  );
});

// Background sync for offline data
self.addEventListener('sync', (event) => {
  if (event.tag === 'survey-sync') {
    event.waitUntil(syncSurveyData());
  }
});

// Sync offline survey data when back online
async function syncSurveyData() {
  try {
    // Get pending survey data from IndexedDB
    const pendingSurveys = await getPendingSurveys();
    
    for (const survey of pendingSurveys) {
      try {
        // Send to server
        const response = await fetch('/api/field-records', {
          method: 'POST',
          body: survey.formData
        });
        
        if (response.ok) {
          // Remove from pending list
          await removePendingSurvey(survey.id);
          console.log('Survey synced successfully:', survey.id);
        }
      } catch (error) {
        console.error('Failed to sync survey:', survey.id, error);
      }
    }
  } catch (error) {
    console.error('Background sync failed:', error);
  }
}

// IndexedDB helpers for offline storage
function getPendingSurveys() {
  return new Promise((resolve) => {
    const request = indexedDB.open('KenaliPaslonDB', 1);
    
    request.onsuccess = (event) => {
      const db = event.target.result;
      const transaction = db.transaction(['pending_surveys'], 'readonly');
      const store = transaction.objectStore('pending_surveys');
      const getAllRequest = store.getAll();
      
      getAllRequest.onsuccess = () => {
        resolve(getAllRequest.result);
      };
      
      getAllRequest.onerror = () => {
        resolve([]);
      };
    };
    
    request.onerror = () => {
      resolve([]);
    };
  });
}

function removePendingSurvey(surveyId) {
  return new Promise((resolve) => {
    const request = indexedDB.open('KenaliPaslonDB', 1);
    
    request.onsuccess = (event) => {
      const db = event.target.result;
      const transaction = db.transaction(['pending_surveys'], 'readwrite');
      const store = transaction.objectStore('pending_surveys');
      
      store.delete(surveyId);
      
      transaction.oncomplete = () => {
        resolve();
      };
      
      transaction.onerror = () => {
        resolve();
      };
    };
    
    request.onerror = () => {
      resolve();
    };
  });
}

// Push notification handling
self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'Ada pembaruan baru!',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-192x192.png',
    vibrate: [200, 100, 200],
    data: {
      url: '/'
    }
  };
  
  event.waitUntil(
    self.registration.showNotification('KENALI PASLON', options)
  );
});

// Notification click handling
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow(event.notification.data.url || '/')
  );
});