import axios from 'axios';

const state = {
    volunteer: null,
    isLoading: false,
    error: null,
};

const mutations = {
    SET_VOLUNTEER(state, volunteer) {
        state.volunteer = volunteer;
    },
    SET_LOADING(state, status) {
        state.isLoading = status;
    },
    SET_ERROR(state, error) {
        state.error = error;
    },
    CLEAR_ERROR(state) {
        state.error = null;
    },
};

const actions = {
    async login({ commit }, credentials) {
        commit('SET_LOADING', true);
        commit('CLEAR_ERROR');
        
        try {
            
            const response = await axios.post('/api/login', credentials);
            commit('SET_VOLUNTEER', response.data.volunteer);
            return response.data;
        } catch (error) {
            const errorMessage = error.response?.data?.message || 'Login gagal';
            commit('SET_ERROR', errorMessage);
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async logout({ commit }) {
        try {
            await axios.post('/api/logout');
            commit('SET_VOLUNTEER', null);
        } catch (error) {
            console.error('Logout error:', error);
            // Clear local state anyway
            commit('SET_VOLUNTEER', null);
        }
    },

    async checkAuth({ commit }) {
        try {
            
            const response = await axios.get('/api/me');
            if (response.data.success) {
                commit('SET_VOLUNTEER', response.data.volunteer);
            } else {
                commit('SET_VOLUNTEER', null);
            }
        } catch (error) {
            commit('SET_VOLUNTEER', null);
        }
    },

    clearError({ commit }) {
        commit('CLEAR_ERROR');
    },
};

const getters = {
    isLoggedIn: (state) => !!state.volunteer,
    volunteer: (state) => state.volunteer,
    isLoading: (state) => state.isLoading,
    error: (state) => state.error,
};

export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters,
};