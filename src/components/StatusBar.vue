<template>
  <div class="stat-panel panel no-overflow">
    <div class="stat-panel__block stat-panel__block--left" v-if="styles.showEditor">
      <span class="stat-panel__value" v-if="isLoading" style="color: #4dc9ff; margin-right: 15px; display: inline-flex; align-items: center;">
        <icon-chat-gpt style="width: 14px; height: 14px; margin-right: 4px;" class="icon-spin"></icon-chat-gpt> AI 生成中...
      </span>
      <span class="stat-panel__block-name">
        Markdown
        <span v-if="textSelection">selection</span>
      </span>
      <span v-for="stat in textStats" :key="stat.id">
        <span class="stat-panel__value">{{stat.value}}</span> {{stat.name}}
      </span>
      <span class="stat-panel__value">第 {{line}} 行, 第 {{column}} 列</span>
    </div>
    <div class="stat-panel__block stat-panel__block--right">
      <span class="stat-panel__block-name">
        HTML
        <span v-if="htmlSelection">selection</span>
      </span>
      <span v-for="stat in htmlStats" :key="stat.id">
        <span class="stat-panel__value">{{stat.value}}</span> {{stat.name}}
      </span>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import editorSvc from '../services/editorSvc';
import utils from '../services/utils';
import IconChatGpt from '../icons/ChatGpt';

class Stat {
  constructor(name, regex) {
    this.id = utils.uid();
    this.name = name;
    this.regex = new RegExp(regex, 'gm');
    this.value = null;
  }
}

export default {
  components: {
    IconChatGpt,
  },
  data: () => ({
    textSelection: false,
    htmlSelection: false,
    line: 0,
    column: 0,
    textStats: [
      new Stat('字符', '[\\s\\S]'),
      new Stat('字数', '\\S'),
      new Stat('行数', '\n'),
    ],
    htmlStats: [
      new Stat('字数', '\\S'),
      new Stat('段落', '\\S.*'),
    ],
  }),
  computed: {
    ...mapGetters('layout', [
      'styles',
    ]),
    ...mapGetters('chatgpt', [
      'isLoading',
    ]),
  },
  created() {
    editorSvc.on('sectionList', () => this.computeText());
    editorSvc.on('selectionRange', () => this.computeText());
    editorSvc.on('previewCtx', () => this.computeHtml());
    editorSvc.on('previewSelectionRange', () => this.computeHtml());
  },

  methods: {
    computeText() {
      setTimeout(() => {
        this.textSelection = false;
        let text = editorSvc.clEditor.getContent();
        const beforeText = text.slice(0, editorSvc.clEditor.selectionMgr.selectionEnd);
        const beforeLines = beforeText.split('\n');
        this.line = beforeLines.length;
        this.column = beforeLines.pop().length;

        const selectedText = editorSvc.clEditor.selectionMgr.getSelectedText();
        if (selectedText) {
          this.textSelection = true;
          text = selectedText;
        }
        this.textStats.forEach((stat) => {
          stat.value = (text.match(stat.regex) || []).length;
        });
      }, 10);
    },
    computeHtml() {
      setTimeout(() => {
        let text;
        if (editorSvc.previewSelectionRange) {
          text = `${editorSvc.previewSelectionRange}`;
        }
        this.htmlSelection = true;
        if (!text) {
          this.htmlSelection = false;
          ({ text } = editorSvc.previewCtx);
        }
        if (text != null) {
          this.htmlStats.forEach((stat) => {
            stat.value = (text.match(stat.regex) || []).length;
          });
        }
      }, 10);
    },
  },
};
</script>

<style lang="scss">
.stat-panel {
  position: absolute;
  width: 100%;
  height: 100%;
  color: #fff;
  font-size: 12px;
}

.stat-panel__block {
  margin: 0 10px;
}

.stat-panel__block--left {
  float: left;
}

.stat-panel__block--right {
  float: right;
}

.stat-panel__value {
  font-weight: 600;
  margin-left: 5px;
}
</style>
