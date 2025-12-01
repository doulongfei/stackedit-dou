import store from '../store';

export default {
  chat({ apiKey, content, url, model }, callback) {
    const xhr = new XMLHttpRequest();
    // Use provided URL or fallback (though UI ensures URL is present)
    const finalUrl = url || 'http://lfdou.dpdns.org:8066/v1/chat/completions';
    xhr.open('POST', finalUrl);
    xhr.setRequestHeader('Authorization', `Bearer ${apiKey}`);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
      model: model || 'gpt-5-mini',
      messages: [{ role: 'user', content }],
      temperature: 1,
      stream: true,
    }));
    let lastRespLen = 0;
    xhr.onprogress = () => {
      const responseText = xhr.response.substr(lastRespLen);
      lastRespLen = xhr.response.length;
      responseText.split('\n\n')
        .filter(l => l.length > 0)
        .forEach((text) => {
          const item = text.substr(6);
          if (item === '[DONE]') {
            callback({ done: true });
          } else {
            try {
              const data = JSON.parse(item);
              if (data.choices && data.choices[0] && data.choices[0].delta && data.choices[0].delta.content) {
                callback({ content: data.choices[0].delta.content });
              }
            } catch (e) {
              // Ignore parse errors for incomplete chunks
            }
          }
        });
    };
    xhr.onerror = () => {
      store.dispatch('notification/error', '接口请求异常！');
      callback({ error: '接口请求异常！' });
    };
    return xhr;
  },
};
