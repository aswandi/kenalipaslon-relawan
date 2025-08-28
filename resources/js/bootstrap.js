import axios from 'axios';

window.axios = axios;

// Set default headers
window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

// Set CSRF token for all requests
const token = document.head.querySelector('meta[name="csrf-token"]');
if (token) {
    window.axios.defaults.headers.common['X-CSRF-TOKEN'] = token.content;
} else {
    console.error('CSRF token not found: https://laravel.com/docs/csrf#csrf-x-csrf-token');
}

// Enable cookies for session handling
window.axios.defaults.withCredentials = true;

// Add request interceptor to get fresh CSRF token on each request
window.axios.interceptors.request.use(
    config => {
        // First try meta tag
        const token = document.head.querySelector('meta[name="csrf-token"]');
        if (token) {
            config.headers['X-CSRF-TOKEN'] = token.content;
        } else {
            // Fallback to XSRF cookie
            const xsrfToken = document.cookie
                .split('; ')
                .find(row => row.startsWith('XSRF-TOKEN='));
            if (xsrfToken) {
                const tokenValue = decodeURIComponent(xsrfToken.split('=')[1]);
                config.headers['X-XSRF-TOKEN'] = tokenValue;
            }
        }
        return config;
    },
    error => {
        return Promise.reject(error);
    }
);
