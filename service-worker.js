// =====================================================
//  service-worker.js  —  CalcDelay PWA
//  Strategi : Network First → fallback Cache
//  - Online  : ambil dari network, simpan cache baru, hapus cache lama
//  - Offline : pakai cache lama
//  Update    : otomatis aktif saat ada versi baru (skipWaiting)
// =====================================================

// ── Naikkan versi ini setiap kali ada update file ────
const CACHE_VERSION = 'delay-calc-v5';

const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './service-worker.js',
  'https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Nunito:wght@300;400;600;700;800&family=Sora:wght@300;400;600;700&display=swap'
];

// ── INSTALL : cache semua asset penting ──────────────
self.addEventListener('install', event => {
  // Langsung aktif, tidak nunggu tab lama ditutup
  self.skipWaiting();

  event.waitUntil(
    caches.open(CACHE_VERSION).then(cache => {
      return cache.addAll(ASSETS);
    })
  );
});

// ── ACTIVATE : hapus semua cache versi lama ──────────
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => {
      return Promise.all(
        keys
          .filter(key => key !== CACHE_VERSION)   // semua cache selain versi sekarang
          .map(key => {
            console.log('[SW] Hapus cache lama:', key);
            return caches.delete(key);
          })
      );
    }).then(() => {
      // Ambil alih semua tab yang terbuka tanpa perlu refresh manual
      return self.clients.claim();
    })
  );
});

// ── FETCH : Network First, fallback ke Cache ──────────
self.addEventListener('fetch', event => {
  // Lewati request non-GET (POST, dll)
  if (event.request.method !== 'GET') return;

  // Lewati request ke chrome-extension atau yang bukan http/https
  const url = event.request.url;
  if (!url.startsWith('http')) return;

  event.respondWith(networkFirst(event.request));
});

async function networkFirst(request) {
  try {
    // ── ONLINE: coba ambil dari network ──────────────
    const networkResponse = await fetch(request);

    // Simpan response segar ke cache (hanya jika status OK)
    if (networkResponse && networkResponse.status === 200) {
      const cache = await caches.open(CACHE_VERSION);
      cache.put(request, networkResponse.clone());
    }

    return networkResponse;

  } catch (err) {
    // ── OFFLINE: network gagal, pakai cache lama ─────
    console.log('[SW] Offline — pakai cache untuk:', request.url);
    const cached = await caches.match(request);
    if (cached) return cached;

    // Kalau tidak ada di cache sama sekali, kembalikan offline page sederhana
    if (request.destination === 'document') {
      return new Response(
        `<!DOCTYPE html>
        <html lang="id">
        <head><meta charset="UTF-8"><title>Offline</title>
        <style>
          body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
               background:#060b18;color:#eef6ff;font-family:sans-serif;text-align:center;}
          h2{color:#00d4ff;margin-bottom:8px;}p{color:#7ba8cc;font-size:14px;}
        </style></head>
        <body>
          <div>
            <h2>📡 Tidak ada koneksi</h2>
            <p>Koneksi internet terputus.<br>Hubungkan kembali lalu refresh halaman.</p>
          </div>
        </body></html>`,
        { headers: { 'Content-Type': 'text/html' } }
      );
    }

    return new Response('Offline', { status: 503 });
  }
}

// ── Terima pesan dari halaman (opsional) ─────────────
self.addEventListener('message', event => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});
