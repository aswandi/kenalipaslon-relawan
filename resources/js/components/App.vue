<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <!-- Loading overlay -->
    <div v-if="isInitializing" class="fixed inset-0 bg-primary-600 flex items-center justify-center z-50">
      <div class="text-center text-white">
        <div class="animate-pulse-slow">
          <h1 class="text-3xl font-bold mb-2">KENALI PASLON</h1>
          <p class="text-primary-100">Percaya Kite Pacak</p>
        </div>
        <div class="mt-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto"></div>
        </div>
      </div>
    </div>

    <!-- Main app -->
    <router-view v-else />

    <!-- Global notifications -->
    <div v-if="globalError" class="fixed top-4 left-4 right-4 z-40">
      <div class="bg-red-500 text-white p-4 rounded-lg shadow-lg animate-slide-up">
        <div class="flex justify-between items-center">
          <p>{{ globalError }}</p>
          <button @click="clearGlobalError" class="ml-4 text-red-100 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Success notification -->
    <div v-if="successMessage" class="fixed top-4 left-4 right-4 z-40">
      <div class="bg-green-500 text-white p-4 rounded-lg shadow-lg animate-slide-up">
        <div class="flex justify-between items-center">
          <p>{{ successMessage }}</p>
          <button @click="clearSuccessMessage" class="ml-4 text-green-100 hover:text-white">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'App',
  data() {
    return {
      isInitializing: true,
      globalError: null,
      successMessage: null
    }
  },
  computed: {
    ...mapGetters('auth', ['error'])
  },
  watch: {
    error(newError) {
      if (newError) {
        this.globalError = newError
        setTimeout(() => {
          this.clearError()
        }, 5000)
      }
    }
  },
  async mounted() {
    // Initialize app
    await this.checkAuth()
    
    // Check for success message in URL params
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.has('success')) {
      this.successMessage = decodeURIComponent(urlParams.get('success'))
      // Auto hide after 5 seconds
      setTimeout(() => {
        this.clearSuccessMessage()
      }, 5000)
      
      // Clean URL by removing success parameter
      const url = new URL(window.location)
      url.searchParams.delete('success')
      window.history.replaceState({}, '', url)
    }
    
    // Register service worker for PWA
    if ('serviceWorker' in navigator) {
      try {
        await navigator.serviceWorker.register('/sw.js')
        console.log('Service Worker registered successfully')
      } catch (error) {
        console.log('Service Worker registration failed:', error)
      }
    }
    
    this.isInitializing = false
  },
  methods: {
    ...mapActions('auth', ['checkAuth', 'clearError']),
    clearGlobalError() {
      this.globalError = null
      this.clearError()
    },
    clearSuccessMessage() {
      this.successMessage = null
    }
  }
}
</script>