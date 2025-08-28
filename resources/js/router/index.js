import { createRouter, createWebHistory } from 'vue-router';
import store from '../store';
import Login from '../components/Login.vue';
import Dashboard from '../components/Dashboard.vue';
import VoterSearch from '../components/VoterSearch.vue';
import SurveyForm from '../components/SurveyForm.vue';
import RecordDetails from '../components/RecordDetails.vue';

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: Login,
        meta: { requiresGuest: true }
    },
    {
        path: '/',
        name: 'Dashboard',
        component: Dashboard,
        meta: { requiresAuth: true }
    },
    {
        path: '/search',
        name: 'VoterSearch',
        component: VoterSearch,
        meta: { requiresAuth: true }
    },
    {
        path: '/survey/:voterId',
        name: 'SurveyForm',
        component: SurveyForm,
        meta: { requiresAuth: true }
    },
    {
        path: '/record/:recordId',
        name: 'RecordDetails',
        component: RecordDetails,
        meta: { requiresAuth: true }
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach(async (to, from, next) => {
    // Always check auth status before routing
    try {
        await store.dispatch('auth/checkAuth');
    } catch (error) {
        console.error('Auth check failed:', error);
    }

    const isLoggedIn = store.getters['auth/isLoggedIn'];

    // Debug logging
    console.log('Router guard:', {
        to: to.name,
        from: from.name,
        isLoggedIn,
        requiresAuth: to.meta.requiresAuth,
        requiresGuest: to.meta.requiresGuest
    });

    if (to.meta.requiresAuth && !isLoggedIn) {
        console.log('Redirecting to login - auth required but not logged in');
        next({ name: 'Login' });
    } else if (to.meta.requiresGuest && isLoggedIn) {
        console.log('Redirecting to dashboard - guest only but logged in');
        next({ name: 'Dashboard' });
    } else {
        console.log('Allowing navigation');
        next();
    }
});

export default router;