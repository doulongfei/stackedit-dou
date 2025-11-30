// Service Worker 版本号 - 更新时修改此值
const CACHE_VERSION = 'v1.0.0';
const CACHE_NAME = `stackedit-cache-${CACHE_VERSION}`;

// 需要缓存的资源（可根据需要调整）
const PRECACHE_URLS = [
  '/',
  '/app',
  '/index.html',
];

// 安装事件 - 预缓存资源
self.addEventListener('install', (event) => {
  console.log('[SW] 安装中...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] 预缓存资源');
        return cache.addAll(PRECACHE_URLS);
      })
      .then(() => self.skipWaiting()) // 立即激活新 SW
  );
});

// 激活事件 - 清理旧缓存
self.addEventListener('activate', (event) => {
  console.log('[SW] 激活中...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name.startsWith('stackedit-cache-') && name !== CACHE_NAME)
          .map((name) => {
            console.log('[SW] 删除旧缓存:', name);
            return caches.delete(name);
          })
      );
    }).then(() => {
      // 通知所有客户端有更新
      self.clients.matchAll().then((clients) => {
        clients.forEach((client) => {
          client.postMessage({ type: 'SW_UPDATED', version: CACHE_VERSION });
        });
      });
      return self.clients.claim(); // 立即接管所有页面
    })
  );
});

// 请求拦截 - 缓存策略：网络优先，失败时使用缓存
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // 只处理同源请求
  if (url.origin !== location.origin) {
    return;
  }

  // 跳过 API 请求（不缓存动态数据）
  if (url.pathname.startsWith('/oauth2') ||
      url.pathname.startsWith('/conf') ||
      url.pathname.startsWith('/pdfExport') ||
      url.pathname.startsWith('/pandocExport')) {
    return;
  }

  // 对于导航请求和静态资源，使用网络优先策略
  event.respondWith(
    fetch(request)
      .then((response) => {
        // 请求成功，克隆响应并缓存
        if (response.ok) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // 网络失败，尝试从缓存获取
        return caches.match(request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          // 如果是导航请求，返回缓存的首页
          if (request.mode === 'navigate') {
            return caches.match('/index.html');
          }
          return new Response('离线不可用', { status: 503 });
        });
      })
  );
});

// 监听来自页面的消息
self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});
