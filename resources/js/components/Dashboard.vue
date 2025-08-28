<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-primary-600 text-white shadow-lg">
      <div class="max-w-4xl mx-auto px-4 py-4">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-xl font-bold">KENALI PASLON</h1>
            <p class="text-primary-100 text-sm">Percaya Kite Pacak</p>
          </div>
          <button 
            @click="handleLogout"
            class="bg-primary-700 hover:bg-primary-800 px-4 py-2 rounded-lg text-sm transition-colors"
          >
            Keluar
          </button>
        </div>
      </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-6">
      <!-- Welcome section -->
      <div class="bg-white rounded-2xl shadow-lg p-6 mb-6 animate-fade-in">
        <div class="text-center">
          <h2 class="text-2xl font-bold text-gray-800 mb-2">
            Selamat datang, {{ volunteer?.full_name }}!
          </h2>
          <p class="text-gray-600 mb-6">
            Mulai survey dan bantu warga Pangkal Pinang menentukan pilihan terbaik
          </p>
          
          <!-- Action buttons -->
          <div class="space-y-4">
            <router-link
              to="/search"
              class="block bg-primary-600 hover:bg-primary-700 text-white font-semibold py-4 px-6 rounded-xl text-lg transition-colors shadow-lg hover:shadow-xl transform hover:scale-105 duration-200"
            >
              <div class="flex items-center justify-center">
                <svg class="w-6 h-6 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
                Mulai Sensus Baru
              </div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Statistics -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div class="bg-gradient-to-r from-blue-500 to-blue-600 rounded-2xl p-6 text-white animate-slide-up">
          <div class="flex items-center">
            <div class="bg-blue-400 rounded-full p-3 mr-4">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
            </div>
            <div>
              <p class="text-blue-100 text-sm">Total Sensus</p>
              <p class="text-2xl font-bold">{{ fieldRecords.length }}</p>
            </div>
          </div>
        </div>

        <div class="bg-gradient-to-r from-green-500 to-green-600 rounded-2xl p-6 text-white animate-slide-up">
          <div class="flex items-center">
            <div class="bg-green-400 rounded-full p-3 mr-4">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
              </svg>
            </div>
            <div>
              <p class="text-green-100 text-sm">Sensus Hari Ini</p>
              <p class="text-2xl font-bold">{{ todayRecords }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent records -->
      <div class="bg-white rounded-2xl shadow-lg animate-fade-in">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-xl font-bold text-gray-800">Sensus Terbaru</h3>
        </div>
        
        <div v-if="isLoading" class="p-6">
          <div class="flex items-center justify-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          </div>
        </div>

        <div v-else-if="fieldRecords.length === 0" class="p-6 text-center text-gray-500">
          <svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
          </svg>
          <p>Belum ada data survey</p>
        </div>

        <div v-else class="divide-y divide-gray-200">
          <div
            v-for="record in recentRecords"
            :key="record.id"
            @click="$router.push({ name: 'RecordDetails', params: { recordId: record.id } })"
            class="p-4 hover:bg-gray-50 cursor-pointer transition-colors"
          >
            <div class="flex items-center justify-between">
              <div>
                <h4 class="font-semibold text-gray-800">{{ record.voter_name }}</h4>
                <p class="text-sm text-gray-600">{{ record.voter_village }}, RT {{ record.voter_rt }}</p>
                <p class="text-xs text-gray-400">{{ formatDate(record.responded_at) }}</p>
              </div>
              <div class="text-right">
                <div class="flex items-center">
                  <span 
                    :class="{
                      'bg-green-100 text-green-800': record.completion_status === 'complete',
                      'bg-yellow-100 text-yellow-800': record.completion_status === 'partial',
                      'bg-red-100 text-red-800': record.completion_status === 'incomplete'
                    }"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  >
                    {{ record.completion_status === 'complete' ? 'Selesai' : 
                       record.completion_status === 'partial' ? 'Sebagian' : 'Belum Selesai' }}
                  </span>
                </div>
                <p class="text-xs text-gray-400 mt-1">{{ record.completion_percentage }}%</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'Dashboard',
  computed: {
    ...mapGetters('auth', ['volunteer']),
    ...mapGetters('survey', ['fieldRecords', 'isLoading']),
    
    recentRecords() {
      return this.fieldRecords.slice(0, 5)
    },
    
    todayRecords() {
      const today = new Date().toISOString().split('T')[0]
      return this.fieldRecords.filter(record => 
        record.responded_at.startsWith(today)
      ).length
    }
  },
  
  async mounted() {
    await this.fetchFieldRecords()
  },
  
  methods: {
    ...mapActions('auth', ['logout']),
    ...mapActions('survey', ['fetchFieldRecords']),
    
    async handleLogout() {
      await this.logout()
      this.$router.push({ name: 'Login' })
    },
    
    formatDate(dateString) {
      const date = new Date(dateString)
      return new Intl.DateTimeFormat('id-ID', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date)
    }
  }
}
</script>