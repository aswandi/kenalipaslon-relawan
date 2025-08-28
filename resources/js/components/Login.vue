<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-600 to-primary-800 flex items-center justify-center px-4">
    <div class="max-w-md w-full">
      <!-- Logo and branding -->
      <div class="text-center mb-8 animate-fade-in">
        <div class="bg-white rounded-full w-24 h-24 mx-auto mb-4 flex items-center justify-center shadow-lg">
          <div class="text-primary-600 text-3xl font-bold">KP</div>
        </div>
        <h1 class="text-3xl font-bold text-white mb-2">KENALI PASLON</h1>
        <p class="text-primary-100 text-lg">Percaya Kite Pacak</p>
      </div>

      <!-- Login form -->
      <div class="bg-white rounded-2xl shadow-2xl p-8 animate-slide-up">
        <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Login Relawan</h2>
        
        <form @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Nomor Handphone
            </label>
            <input
              v-model="form.phone_number"
              type="tel"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
              placeholder="Contoh: 081234567890"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              v-model="form.password"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
              placeholder="Masukkan password Anda"
            >
          </div>

          <button
            type="submit"
            :disabled="isLoading"
            class="w-full bg-primary-600 hover:bg-primary-700 disabled:bg-primary-300 text-white font-semibold py-3 px-4 rounded-lg transition-colors"
          >
            <div v-if="isLoading" class="flex items-center justify-center">
              <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Memproses...
            </div>
            <span v-else>Masuk</span>
          </button>
        </form>

        <!-- Error message -->
        <div v-if="error" class="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-red-600 text-sm">{{ error }}</p>
        </div>
      </div>

      <!-- Footer -->
      <p class="text-center text-primary-100 text-sm mt-8">
        Aplikasi Sensus Pilkada Pangkal Pinang 2024
      </p>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'Login',
  data() {
    return {
      form: {
        phone_number: '',
        password: ''
      }
    }
  },
  computed: {
    ...mapGetters('auth', ['isLoading', 'error'])
  },
  methods: {
    ...mapActions('auth', ['login', 'clearError']),
    
    async handleLogin() {
      this.clearError()
      
      try {
        await this.login(this.form)
        this.$router.push({ name: 'Dashboard' })
      } catch (error) {
        // Error is handled by store
      }
    }
  }
}
</script>