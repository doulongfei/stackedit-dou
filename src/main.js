import { createApp } from 'vue';
import 'indexeddbshim/dist/indexeddbshim';
import './extensions';
import './services/optional';
import icons from './icons';
import App from './components/App.vue';
import store from './store';
import localDbSvc from './services/localDbSvc';
import timeSvc from './services/timeSvc';

if (!indexedDB) {
  throw new Error('不支持您的浏览器，请升级到最新版本。');
}

// 注册 Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('Service Worker 注册成功:', registration.scope);

        // 检测更新
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          if (newWorker) {
            newWorker.addEventListener('statechange', () => {
              if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                // 有新版本可用
                console.log('发现新版本，准备更新...');
              }
            });
          }
        });
      })
      .catch((error) => {
        console.error('Service Worker 注册失败:', error);
      });

    // 监听 SW 发来的更新消息
    navigator.serviceWorker.addEventListener('message', async (event) => {
      if (event.data?.type === 'SW_UPDATED') {
        // 同步本地数据后刷新
        if (!store.state.light) {
          try {
            await localDbSvc.sync();
          } catch (e) {
            console.error('同步失败:', e);
          }
        }
        store.dispatch('notification/info', 'StackEdit中文版刚刚更新了！');
      }
    });
  });
}

// PWA 安装提示
if (!localStorage.installPrompted) {
  window.addEventListener('beforeinstallprompt', async (promptEvent) => {
    promptEvent.preventDefault();
    try {
      await store.dispatch('notification/confirm', '将StackEdit中文版添加到您的主屏幕上？');
      promptEvent.prompt();
      await promptEvent.userChoice;
    } catch (err) {
      // 用户取消
    }
    localStorage.installPrompted = true;
  });
}

const app = createApp(App);

// Global directives
app.directive('focus', {
  mounted(el) {
    el.focus();
    const { value } = el;
    if (value && el.setSelectionRange) {
      el.setSelectionRange(0, value.length);
    }
  },
});

const setElTitle = (el, title) => {
  el.title = title;
  el.setAttribute('aria-label', title);
};
app.directive('title', {
  mounted(el, { value }) {
    setElTitle(el, value);
  },
  updated(el, { value, oldValue }) {
    if (value !== oldValue) {
      setElTitle(el, value);
    }
  },
});

// Clipboard 使用浏览器原生的复制
app.directive('clipboard', {
  mounted(el, { value }) {
    el.addEventListener('click', () => {
      navigator.clipboard.writeText(value)
        .then(() => {
          console.log('复制成功');
        })
        .catch((err) => {
          console.error('复制失败:', err);
        });
    });
  },
  updated(el, { value }) {
    el.value = value; // 更新绑定的值
  }
});

// Global filters
app.config.globalProperties.$filters= {
  formatTime(time) {
    return timeSvc.format(time, store.state.timeCounter);
  }
}

for (const key in icons) {
  app.component(key, icons[key]);
}

app.use(store)
  .mount('#app');
