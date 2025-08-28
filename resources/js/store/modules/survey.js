import axios from 'axios';

const state = {
    questions: [],
    voters: [],
    selectedVoter: null,
    fieldRecords: [],
    isLoading: false,
    error: null,
    searchQuery: '',
};

const mutations = {
    SET_QUESTIONS(state, questions) {
        state.questions = questions;
    },
    SET_VOTERS(state, voters) {
        state.voters = voters;
    },
    SET_SELECTED_VOTER(state, voter) {
        state.selectedVoter = voter;
    },
    SET_FIELD_RECORDS(state, records) {
        state.fieldRecords = records;
    },
    ADD_FIELD_RECORD(state, record) {
        state.fieldRecords.unshift(record);
    },
    UPDATE_FIELD_RECORD(state, updatedRecord) {
        const index = state.fieldRecords.findIndex(r => r.id === updatedRecord.id);
        if (index !== -1) {
            state.fieldRecords.splice(index, 1, updatedRecord);
        }
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
    SET_SEARCH_QUERY(state, query) {
        state.searchQuery = query;
    },
};

const actions = {
    async fetchQuestions({ commit }) {
        commit('SET_LOADING', true);
        try {
            const response = await axios.get('/api/questions');
            commit('SET_QUESTIONS', response.data.questions);
        } catch (error) {
            commit('SET_ERROR', 'Gagal memuat pertanyaan');
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async searchVoters({ commit }, query) {
        if (query.length < 3) {
            commit('SET_VOTERS', []);
            return;
        }

        commit('SET_LOADING', true);
        commit('SET_SEARCH_QUERY', query);
        
        try {
            const response = await axios.get('/api/voters/search', {
                params: { query }
            });
            commit('SET_VOTERS', response.data.voters);
        } catch (error) {
            commit('SET_ERROR', 'Gagal mencari data pemilih');
            commit('SET_VOTERS', []);
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async fetchVoter({ commit }, voterId) {
        commit('SET_LOADING', true);
        try {
            const response = await axios.get(`/api/voters/${voterId}`);
            commit('SET_SELECTED_VOTER', response.data.voter);
            return response.data;
        } catch (error) {
            commit('SET_ERROR', 'Gagal memuat data pemilih');
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async submitSurvey({ commit }, surveyData) {
        commit('SET_LOADING', true);
        commit('CLEAR_ERROR');
        
        try {
            const formData = new FormData();
            
            // Add basic data
            formData.append('voter_id', surveyData.voter_id);
            formData.append('notes', surveyData.notes || '');
            
            // Add GPS coordinates if available
            if (surveyData.latitude) formData.append('latitude', surveyData.latitude);
            if (surveyData.longitude) formData.append('longitude', surveyData.longitude);
            
            // Add photo if available
            if (surveyData.photo) {
                formData.append('photo', surveyData.photo);
            }
            
            // Add responses
            surveyData.responses.forEach((response, index) => {
                formData.append(`responses[${index}][question_id]`, response.question_id);
                if (response.answer_option_id) {
                    formData.append(`responses[${index}][answer_option_id]`, response.answer_option_id);
                }
                if (response.text_answer) {
                    formData.append(`responses[${index}][text_answer]`, response.text_answer);
                }
            });
            
            const response = await axios.post('/api/field-records', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            
            return response.data;
        } catch (error) {
            const errorMessage = error.response?.data?.message || 'Gagal menyimpan data survey';
            commit('SET_ERROR', errorMessage);
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async fetchFieldRecords({ commit }) {
        commit('SET_LOADING', true);
        try {
            const response = await axios.get('/api/field-records');
            commit('SET_FIELD_RECORDS', response.data.records);
        } catch (error) {
            commit('SET_ERROR', 'Gagal memuat data lapangan');
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async fetchFieldRecord({ commit }, recordId) {
        commit('SET_LOADING', true);
        try {
            const response = await axios.get(`/api/field-records/${recordId}`);
            return response.data.record;
        } catch (error) {
            commit('SET_ERROR', 'Gagal memuat detail record');
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    async updateFieldRecord({ commit }, { recordId, surveyData }) {
        commit('SET_LOADING', true);
        commit('CLEAR_ERROR');
        
        try {
            const formData = new FormData();
            
            formData.append('notes', surveyData.notes || '');
            
            if (surveyData.photo) {
                formData.append('photo', surveyData.photo);
            }
            
            surveyData.responses.forEach((response, index) => {
                formData.append(`responses[${index}][question_id]`, response.question_id);
                if (response.answer_option_id) {
                    formData.append(`responses[${index}][answer_option_id]`, response.answer_option_id);
                }
                if (response.text_answer) {
                    formData.append(`responses[${index}][text_answer]`, response.text_answer);
                }
            });
            
            const response = await axios.put(`/api/field-records/${recordId}`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });
            
            return response.data;
        } catch (error) {
            const errorMessage = error.response?.data?.message || 'Gagal memperbarui data survey';
            commit('SET_ERROR', errorMessage);
            throw error;
        } finally {
            commit('SET_LOADING', false);
        }
    },

    clearError({ commit }) {
        commit('CLEAR_ERROR');
    },

    clearVoters({ commit }) {
        commit('SET_VOTERS', []);
    },
};

const getters = {
    questions: (state) => state.questions,
    voters: (state) => state.voters,
    selectedVoter: (state) => state.selectedVoter,
    fieldRecords: (state) => state.fieldRecords,
    isLoading: (state) => state.isLoading,
    error: (state) => state.error,
    searchQuery: (state) => state.searchQuery,
};

export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters,
};