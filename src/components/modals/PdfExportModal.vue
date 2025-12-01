<template>
  <modal-inner aria-label="导出到PDF">
    <div class="modal__content">
      <p>请为您的<b> pdf导出</b>选择模板。(该导出很消耗服务器资源，文档太大或图片太多可能会导出超时失败！可参考 <a href="https://github.com/doulongfei/stackedit-dou/blob/master/docs/大文档导出PDF方式.md" target="_blank">大文档导出PDF方式</a> 自行导出大文档！)</p>
      <form-entry label="模板">
        <template v-slot:field>
          <select class="textfield" v-model="selectedTemplate" @keydown.enter="resolve()">
            <option v-for="(template, id) in allTemplatesById" :key="id" :value="id">
              {{ template.name }}
            </option>
          </select>
        </template>
        <div class="form-entry__actions">
          <a href="javascript:void(0)" @click="configureTemplates">配置模板</a>
        </div>
      </form-entry>
    </div>
    <div class="modal__button-bar">
      <button class="button" @click="config.reject()">取消</button>
      <button class="button button--resolve" @click="resolve()">确认</button>
    </div>
  </modal-inner>
</template>

<script>
import FileSaver from 'file-saver';
import exportSvc from '../../services/exportSvc';
import networkSvc from '../../services/networkSvc';
import modalTemplate from './common/modalTemplate';
import store from '../../store';
import badgeSvc from '../../services/badgeSvc';

export default modalTemplate({
  computedLocalSettings: {
    selectedTemplate: 'pdfExportTemplate',
  },
  methods: {
    async resolve() {
      this.config.resolve();
      const currentFile = store.getters['file/current'];
      store.dispatch('queue/enqueue', async () => {
        const html = await exportSvc.applyTemplate(
          currentFile.id,
          this.allTemplatesById[this.selectedTemplate],
          true,
        );

        try {
          // Vercel deployment change: Use browser print instead of backend wkhtmltopdf
          const printWindow = window.open('', '_blank');
          printWindow.document.write(html);
          printWindow.document.close();
          printWindow.focus();

          // Wait for resources to load then print
          setTimeout(() => {
            printWindow.print();
            printWindow.close();
          }, 500);

          badgeSvc.addBadge('exportPdf');
        } catch (err) {
          console.error(err); // eslint-disable-line no-console
          store.dispatch('notification/error', err);
        }
      });
    },
  },
});
</script>
