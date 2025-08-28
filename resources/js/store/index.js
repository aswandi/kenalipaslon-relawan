import { createStore } from 'vuex';
import auth from './modules/auth';
import survey from './modules/survey';

const store = createStore({
    modules: {
        auth,
        survey,
    },
});

export default store;