<template>
  <modal-inner aria-label="ChatGPT配置">
    <div class="modal__content">
      <div class="modal__image">
        <icon-chat-gpt></icon-chat-gpt>
      </div>
      <p> <b>AI</b> 模型配置 (兼容 OpenAI 格式)</p>
      <form-entry label="API Key" error="apiKey">
        <input slot="field" class="textfield" type="text" v-model.trim="apiKey" placeholder="请输入 API Key" @keydown.enter="resolve()">
      </form-entry>
      <form-entry label="API 地址 (URL)" error="url">
        <input slot="field" class="textfield" type="text" v-model.trim="url" placeholder="例如: http://lfdou.dpdns.org:8066/v1/chat/completions" @keydown.enter="resolve()">
      </form-entry>
      <form-entry label="模型名称 (Model)" error="model">
        <input slot="field" class="textfield" type="text" v-model.trim="model" placeholder="例如: gpt-5-mini" @keydown.enter="resolve()">
      </form-entry>
      <form-entry label="上下文长度 (Context Length)" error="contextLength">
        <input slot="field" class="textfield" type="number" v-model.number="contextLength" placeholder="默认: 2000" @keydown.enter="resolve()">
      </form-entry>
      <div class="form-entry__info" style="margin-top: 10px; font-size: 0.9em; color: #666;">
        此处配置仅保存在前端浏览器缓存中。API 地址已默认配置代理以解决跨域问题。
      </div>
    </div>
    <div class="modal__button-bar">
      <button class="button" @click="config.reject()">取消</button>
      <button class="button button--resolve" @click="resolve()">确认</button>
    </div>
  </modal-inner>
</template>

<script>
import modalTemplate from './common/modalTemplate';
import store from '../../store';

export default modalTemplate({
  data() {
    return {
      apiKey: '',
      url: '',
      model: '',
      contextLength: 2000,
    };
  },
  created() {
    const config = store.getters['chatgpt/chatGptConfig'];
    this.apiKey = config.apiKey;
    this.url = config.url || '/chatgpt-api/v1/chat/completions';
    this.model = config.model || 'gpt-5-mini';
    this.contextLength = config.contextLength || 2000;
  },
  methods: {
    resolve() {
      // Allow empty API Key for custom endpoints
      if (!this.url) {
        this.setError('url');
        return;
      }
      if (!this.model) {
        this.setError('model');
        return;
      }
      this.config.resolve({
        apiKey: this.apiKey,
        url: this.url,
        model: this.model,
        contextLength: this.contextLength,
      });
    },
  },
});
</script>
