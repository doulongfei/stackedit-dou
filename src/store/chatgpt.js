const chatgptConfigKey = 'chatgpt/config';

export default {
  namespaced: true,
  state: {
    config: {
      apiKey: null,
      url: '/chatgpt-api/v1/chat/completions',
      model: 'gpt-5-mini',
      contextLength: 2000,
      promptTemplate: 'Please complete the following markdown/code. Output ONLY the completion content. Do not repeat the input. Do not explain.\n\n{{context}}',
    },
    isLoading: false,
  },
  mutations: {
    setCurrConfig: (state, value) => {
      state.config = {
        ...state.config,
        ...value,
      };
    },
    setIsLoading: (state, value) => {
      state.isLoading = value;
    },
  },
  getters: {
    chatGptConfig: state => state.config,
    isLoading: state => state.isLoading,
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
