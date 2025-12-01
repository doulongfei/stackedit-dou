const chatgptConfigKey = 'chatgpt/config';

export default {
  namespaced: true,
  state: {
    config: {
      apiKey: null,
      url: '/chatgpt-api/v1/chat/completions',
      model: 'gpt-5-mini',
      contextLength: 2000,
    },
  },
  mutations: {
    setCurrConfig: (state, value) => {
      state.config = {
        ...state.config,
        ...value,
      };
    },
  },
  getters: {
    chatGptConfig: state => state.config,
  },
  actions: {
    setCurrConfig({ commit, state }, value) {
      const newConfig = {
        ...state.config,
        ...value,
      };
      commit('setCurrConfig', newConfig);
      localStorage.setItem(chatgptConfigKey, JSON.stringify(newConfig));
    },
  },
};
